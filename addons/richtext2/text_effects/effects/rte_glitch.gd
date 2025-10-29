@tool
extends RichTextEffectBase

## Syntax: [glitch intensity=1.0 freq=6.0 color=true seed=0][]
var bbcode = "glitch"

func _process_custom_fx(c: CharFXTransform):
	var intensity := float(c.env.get("intensity", 1.0))
	var freq := float(c.env.get("freq", 6.0))
	var color_shift := bool(c.env.get("color", true))

	# small per-character seed (stable between frames)
	var seed: int = int(c.range.x)
	
	var lbl := label
	if lbl != null and lbl.has_method("_get_character_random"):
		seed = int(lbl._get_character_random(c.range.x))

	# probabilistic glitch trigger based on time + seed
	var p: float = sin(c.elapsed_time * freq + seed * 0.123)
	var trigger: bool = p > (1.0 - 0.2 * intensity)

	if trigger:
		# jitter offset
		var dx := (randf() * 2.0 - 1.0) * intensity * 4.0
		var dy := (randf() * 2.0 - 1.0) * intensity * 4.0
		c.offset.x += dx
		c.offset.y += dy

		# color shift by hue or add channel offsets
		if color_shift:
			var s_val: float = 1.0 - clamp(float(intensity) * 0.6, 0.0, 1.0)
			c.color.v = clamp(c.color.v * s_val + sin(c.elapsed_time * 10.0 + seed) * 0.2, 0.0, 1.0)

		# occasionally swap glyph to a random visible ASCII glyph
		if randf() < 0.25 * intensity:
			var ts := TextServerManager.get_primary_interface()
			var font_size: int = 16
			if lbl:
				font_size = int(lbl.font_size)
			var code: int = randi() % (126 - 33 + 1) + 33
			c.glyph_index = ts.font_get_glyph_index(c.font, font_size, code, 0)

	return true

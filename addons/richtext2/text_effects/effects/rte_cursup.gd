@tool
extends RichTextEffectBase
## Enlarges characters near the mouse cursor and restores them when leaving.
## Syntax: [cursup scale radius][]
const bbcode = "cursup"

func _process_custom_fx(c: CharFXTransform):
	# params: desired max scale and effect radius in pixels
	var max_scale: float = c.env.get("scale", 1.5)
	var radius: float = c.env.get("radius", 48.0)

	# local mouse and character positions
	var mp := get_mouse_pos(c)
	var pos := c.transform.origin
	var dist := pos.distance_to(mp)

	# compute influence 0..1 (1 = at cursor, 0 = beyond radius)
	var t := clamp(1.0 - dist / radius, 0.0, 1.0)

	# smooth the influence for nicer feel
	var smooth := ease_back_out(t)

	# scale factor (1.0 .. max_scale)
	var scale_factor := lerp(1.0, max_scale, smooth)

	# scale around approximate character center
	var cs := get_char_size(c) * Vector2(0.5, -0.25)
	c.transform *= Transform2D.IDENTITY.translated(cs)
	c.transform *= Transform2D.IDENTITY.scaled(Vector2.ONE * scale_factor)
	c.transform *= Transform2D.IDENTITY.translated(-cs)
	
	return true

@tool
extends RichTextEffectBase
## Changes character color near the mouse cursor. Color can be passed as a Color or a hex string like "#ff00ff".
## Syntax: [curscolor color radius intensity][]
const bbcode = "curscolor"

func _process_custom_fx(c: CharFXTransform):
	# Params
	var clr_name = c.env.get("color", "gold")
	var radius: float = c.env.get("radius", 48.0)
	var intensity: float = c.env.get("intensity", 1.0)

	var clr := RicherTextLabel.to_color(clr_name, c.color) if clr_name else c.color

	# compute distance-based influence
	var mp := get_mouse_pos(c)
	var pos := c.transform.origin
	var dist := pos.distance_to(mp)
	var t := clamp(1.0 - dist / radius, 0.0, 1.0)
	var smooth := ease_back_out(t)

	var alpha := clamp(smooth * intensity, 0.0, 1.0)

	# apply color blend (preserves original alpha unless target provides different alpha)
	# Use lerp() on Color for compatibility
	c.color = c.color.lerp(clr, alpha)

	return true

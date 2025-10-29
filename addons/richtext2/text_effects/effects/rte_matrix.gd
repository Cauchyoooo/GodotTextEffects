@tool
extends RichTextEffectBase

## Syntax: [matrix clean=2.0 dirty=1.0 span=50][]
var bbcode = "matrix"

## Example: [matrix clean=2.5 dirty=0.8 span=48]Text[]
## - clean: how long the glyph stays "clear" (seconds)
## - dirty: how long it cycles random/gibberish glyphs (seconds)
## - span: per-character phase spacing

func get_text_server():
	return TextServerManager.get_primary_interface()

func _process_custom_fx(c: CharFXTransform):
	# Read parameters with defaults and type-safety
	var clear_time: float = float(c.env.get("clean", 2.0))
	var dirty_time: float = float(c.env.get("dirty", 1.0))
	var text_span: float = float(c.env.get("span", 50.0))

	# protect against zero span
	if text_span == 0.0:
		text_span = 0.0001

	# get font size from the label (use scalar font_size to avoid Vector2 mixing)
	var lbl := label
	var font_size: int = lbl.font_size if lbl else 16

	var ts = get_text_server()

	# compute where we are inside the clear+dirty cycle, offset per-character
	var cycle_len := clear_time + dirty_time
	var matrix_time := fmod(c.elapsed_time + (float(c.range.x) / text_span), cycle_len)

	# if we're in the dirty phase, remap to 0..1 across the dirty_time
	matrix_time = 0.0 if matrix_time < clear_time else (matrix_time - clear_time) / dirty_time

	# Determine original glyph's codepoint and glyph index so we can restore it
	var orig_codepoint: int = 0
	var ch = get_char(c)
	if ch != null and len(ch) > 0:
		orig_codepoint = ch.unicode_at(0)
	var orig_glyph_index: int = ts.font_get_glyph_index(c.font, font_size, orig_codepoint, 0) if orig_codepoint != 0 else int(c.glyph_index)

	if matrix_time > 0.0:
		# pick a glyph code between ASCII 65..125 (roughly letters and symbols)
		var v := int(1 * matrix_time * (126 - 65))
		v = v % (126 - 65)
		v += 65
		c.glyph_index = ts.font_get_glyph_index(c.font, font_size, v, 0)
	else:
		# restore original glyph for this character
		c.glyph_index = orig_glyph_index
	return true

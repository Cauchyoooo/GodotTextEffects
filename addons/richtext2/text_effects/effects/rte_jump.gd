@tool
extends RichTextEffectBase

# Syntax: [jump angle=0 word=false angle=45][]
var bbcode = "jump"

const SPLITTERS := " .,"

var _w_char = 0
var _last = 999
var _in_word = false
var _current_word_offset = 0

## - word=true : whole-word jump
## - word=false: per-character jump
func _process_custom_fx(c: CharFXTransform):
	# Reset per-run state at start of a layout/render pass
	if c.relative_index == 0:
		_w_char = 0
		_last = 999
		_in_word = false
		_current_word_offset = 0

	# typed label reference to help analyzer
	var lbl := label
	var scale: float = c.env.get("scale", 1.0) * .25 * lbl.font_size * weight
	var word_mode: bool = bool(c.env.get("word", false))
	var splitters = str(c.env.get("splitters", SPLITTERS))
	var angle := deg_to_rad(c.env.get("angle", 0))
	var speed: float = c.env.get("speed", 6.0)
	var s

	if word_mode:
		# WORD MODE: group characters into words using splitters, move whole word together
		var maybe_ch := get_char(c)
		var ch := ""
		if maybe_ch != null:
			ch = str(maybe_ch)

		var abs_idx := c.range.x
		# start of a new word when current char is not a splitter but previous was
		if abs_idx < _last or ch in splitters:
			_w_char = abs_idx

		_last = abs_idx
		s = sin(-c.elapsed_time * speed + _w_char * .2)
		s = -maxf(0.0, s)
		s *= scale

	else:
		# CHARACTER MODE: independent per-character pulses (jump2 behaviour)
		s = sin(-c.elapsed_time * speed + c.relative_index * PI * .125)
		s = -maxf(0.0, s)
		s *= scale

	c.offset.x += sin(angle) * s
	c.offset.y += cos(angle) * s
	return true

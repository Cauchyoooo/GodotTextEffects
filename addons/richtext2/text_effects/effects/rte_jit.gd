@tool
extends RichTextEffectBase
## Makes words shake around.

## Syntax: [jit scale=1.0 freq=8.0 word=false splitters=" .!?,-，。！？；、"][]
var bbcode = "jit"
const SPLITTERS := " .!?,-"

# Internal state used for word-mode grouping. These persist across characters while a
# single layout/render pass is happening; they're reset when c.relative_index == 0.
var _word := 0.0
var _last := ""
var _in_word := false
var _current_word_offset := 0

func _process_custom_fx(c: CharFXTransform):
	# Reset per-label processing when a new run starts
	if c.relative_index == 0:
		_word = 0
		_in_word = false
		_current_word_offset = 0

	# env parameters
	var scale: float = c.env.get("scale", 1.0)
	var freq: float = c.env.get("freq", 16.0)
	# new bool param: whether to operate on words (true) or characters (false)
	var word_mode: bool = bool(c.env.get("word", false))
	# new string param: custom splitters override
	var splitters = str(c.env.get("splitters", SPLITTERS))

	var t = c.elapsed_time

	if word_mode:
		# WORD MODE: group characters into words using splitters, move whole word together
		var raw_ch = get_char(c)
		var ch: String = ""
		if raw_ch != null:
			ch = str(raw_ch)

		var is_split: bool = (ch in splitters)
		# Start of a new word: when current char is not a splitter but previous was.
		if not is_split:
			if not _in_word:
				_in_word = true
				_current_word_offset = c.glyph_index
				if _last in splitters:
					_word += PI * .33
		else:
			# current char is a splitter -> end any current word
			_in_word = false

		# Use the per-word offset when inside a word so all chars in the same word share phase
		var seed_offset = _current_word_offset if _in_word else c.glyph_index
		var s = fmod((_word + t + seed_offset) * PI * 1.25, TAU)
		var p = sin(t * freq * 16.0) * .5
		c.offset.x += sin(s) * p * scale
		c.offset.y += cos(s) * p * scale

		# Update last character (use normalized string 'ch' to avoid Nil assignments)
		_last = ch

	else:
		# CHARACTER MODE: original per-character jit2 behaviour
		var s = fmod((c.relative_index + t) * PI * 1.25, TAU)
		# use c.range.x as seed for small per-character variation
		var p = sin(t * freq + float(c.range.x)) * .33
		c.offset.x += sin(s) * p * scale
		c.offset.y += cos(s) * p * scale

	return true

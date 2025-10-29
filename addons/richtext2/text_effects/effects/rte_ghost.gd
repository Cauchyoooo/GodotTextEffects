@tool
extends RichTextEffectBase

## Syntax: [ghost freq=5.0 span=10.0 intensity=1.0][]
var bbcode = "ghost"

## Example: [ghost freq=3.0 span=8.0 intensity=0.8]Hello[]
## - freq: how fast the alpha oscillates (Hz-like)
## - span: per-character phase spacing (larger -> characters more out-of-phase)
## - intensity: multiplier on resulting alpha (keeps value in [0,1])

func _process_custom_fx(c: CharFXTransform):
	# Read parameters from environment, with safe defaults
	var speed: float = float(c.env.get("freq", 5.0))
	var span: float = float(c.env.get("span", 10.0))
	var intensity: float = float(c.env.get("intensity", 1.0))

	# protect against division by zero (if user passes span=0)
	if span == 0.0:
		span = 0.0001

	# Compute alpha in [0,1] using a sine wave offset by character index
	var alpha: float = sin(c.elapsed_time * speed + (float(c.range.x) / span)) * 0.5 + 0.5

	# apply intensity and clamp
	alpha = clamp(alpha * intensity, 0.0, 1.0)

	# Set the character color alpha. Many effects in this repo directly modify c.color.a
	# which is respected by the rendering pipeline.
	c.color.a = alpha
	return true

extends Control

var tween: Tween
var base_scale := Vector2.ONE

func _ready():
	base_scale = scale

func focus_on():
	if tween:
		tween.kill()

	tween = create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(self, "scale", base_scale * 1.08, 0.6)
	tween.tween_property(self, "scale", base_scale, 0.6)

func focus_off():
	if tween:
		tween.kill()
	scale = base_scale

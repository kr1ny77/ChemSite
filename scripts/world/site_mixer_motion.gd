extends Node
## Presentation-only motion; the authored collision proxy stays fixed.

var _animation: AnimationPlayer
var _running := false
var reduced_motion := false

func configure(prop: Node3D, static_motion: bool) -> void:
	reduced_motion = static_motion
	_animation = prop.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if _animation == null or not _animation.has_animation("DrumRotate"):
		push_error("Mixer is missing its authored DrumRotate clip")
		return
	_animation.get_animation("DrumRotate").loop_mode = Animation.LOOP_LINEAR
	_animation.play("DrumRotate")
	_animation.seek(0.0, true)
	_animation.pause()

func set_running(enabled: bool) -> void:
	var next := enabled and not reduced_motion
	if _animation == null or next == _running:
		return
	_running = next
	if _running:
		_animation.play("DrumRotate")
	else:
		_animation.pause()

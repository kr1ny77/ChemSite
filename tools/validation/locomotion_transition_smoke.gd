extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var player := (load("res://scenes/player/player.tscn") as PackedScene).instantiate() as CharacterBody3D
	root.add_child(player)
	# Horizontal state behavior is isolated from station collisions here.
	player.set_collision_mask_value(1, false)
	Input.action_press("move_right")
	await _frames(60)
	if not _check(player._current_animation == "Run", "Full movement did not enter Run"):
		return
	for strength in [0.73, 0.76, 0.74, 0.75]:
		Input.action_press("move_right", strength)
		await _frames(20)
		if not _check(player._current_animation == "Run", "Run flickered near the transition threshold"):
			return
	Input.action_press("move_right", 0.68)
	await _frames(30)
	if not _check(player._current_animation == "Walk", "Slower movement did not enter Walk"):
		return
	for strength in [0.73, 0.76, 0.74, 0.75]:
		Input.action_press("move_right", strength)
		await _frames(20)
		if not _check(player._current_animation == "Walk", "Walk flickered near the transition threshold"):
			return
	Input.action_release("move_right")
	await _frames(30)
	if not _check(player._current_animation == "Idle", "Released movement did not settle to Idle"):
		return
	if not _check(Vector2(player.velocity.x, player.velocity.z).length() < 0.01, "Player kept drifting after release"):
		return
	player.set_physics_process(false)
	player._animation_tree.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	for states in [["Walk", "Run"], ["Run", "Walk"]]:
		for phase in [0.12, 0.35, 0.62, 0.89]:
			player._set_animation_rate(states[0], 1.3)
			player._set_animation_rate(states[1], 1.8)
			player._playback.start(states[0])
			player._current_animation = states[0]
			player._animation_tree.advance(0.0)
			player._animation_tree.set("parameters/%s/TimeSeek/seek_request" % states[0], phase * float(player._clip_lengths[states[0]]))
			player._animation_tree.advance(0.0)
			player._travel(states[1])
			player._animation_tree.advance(0.0)
			var actual: float = player._playback.get_current_play_position() / float(player._clip_lengths[states[1]])
			if not _check(absf(actual - phase) < 0.001, "Locomotion phase lost: %s -> %s, %.3f -> %.3f" % [states[0], states[1], phase, actual]):
				return
	print("LOCOMOTION_PHASE_TRANSFER_OK")
	print("LOCOMOTION_TRANSITION_SMOKE_OK")
	quit()

func _frames(count: int) -> void:
	for frame in range(count):
		await physics_frame

func _check(condition: bool, message: String) -> bool:
	if not condition:
		push_error(message)
		quit(1)
	return condition

extends SceneTree

var events: Array[float] = []
var player: CharacterBody3D

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	root.add_child(site)
	player = site.get_node("Player")
	for frame in range(30):
		await physics_frame
	player.set_physics_process(false)
	player._animation_tree.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	player.footstep.connect(func(): events.append(player._playback.get_current_play_position() / float(player._clip_lengths[player._step_state])))
	for state in ["Walk", "Run"]:
		events.clear()
		player._step_state = ""
		player._playback.start(state)
		player._current_animation = state
		player._set_animation_rate(state, 1.0)
		player._animation_tree.advance(0.0)
		player._update_footstep(1.0)
		for frame in range(120):
			player._animation_tree.advance(1.0 / 60.0)
			player._update_footstep(1.0)
		var duration: float = player._clip_lengths[state]
		var expected := 0
		for contact in [0.25, 0.75]:
			expected += maxi(0, floori(2.0 / duration - contact) + 1)
		if not _check(events.size() == expected, "%s contact count: %d" % [state, events.size()]):
			return
		for event in events:
			var phase := fposmod(event, 1.0)
			var error := minf(absf(phase - 0.25), absf(phase - 0.75))
			if not _check(error < 1.0 / (60.0 * duration) + 0.0001, "%s footstep missed contact: %.3f" % [state, phase]):
				return
		var count := events.size()
		for frame in range(60):
			player._animation_tree.advance(1.0 / 60.0)
			player._update_footstep(0.0)
		if not _check(events.size() == count, "Stationary player emitted footsteps"):
			return
		player.controls_enabled = false
		for frame in range(60):
			player._animation_tree.advance(1.0 / 60.0)
			player._update_footstep(1.0)
		if not _check(events.size() == count, "Disabled controls emitted footsteps"):
			return
		player.controls_enabled = true
	print("FOOTSTEP_TIMING_SMOKE_OK")
	site.queue_free()
	await process_frame
	quit()

func _check(condition: bool, message: String) -> bool:
	if not condition:
		push_error(message)
		quit(1)
	return condition

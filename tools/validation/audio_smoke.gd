extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var main := (load("res://scenes/main/main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	await process_frame
	main.start_game("career", "")
	var site: Node3D = main._current
	var mixer_audio := site.get_node("World/Mixer Ambience") as AudioStreamPlayer3D
	assert(mixer_audio.stream != null and mixer_audio.bus == "SFX" and mixer_audio.stream.loop_mode == AudioStreamWAV.LOOP_FORWARD)
	var steps := [0]
	site.footstep.connect(func() -> void: steps[0] += 1)
	Input.action_press("move_right")
	for frame in range(55):
		await physics_frame
	Input.action_release("move_right")
	assert(steps[0] >= 2, "Movement did not trigger footsteps")
	assert(main.get_node("AudioController")._step_index >= 2)
	main.queue_free()
	await process_frame
	print("CHEMSITE_AUDIO_SMOKE_OK")
	quit()

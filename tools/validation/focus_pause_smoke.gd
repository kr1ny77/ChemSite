extends SceneTree

func _initialize() -> void:
	call_deferred("_run")
	create_timer(30).timeout.connect(func(): quit(1))

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	site.save_path = "user://focus-pause-smoke-progress.json"
	root.size = Vector2i(1028, 642)
	root.add_child(site)
	for frame in range(5): await physics_frame
	var player: CharacterBody3D = site._player
	player.velocity = Vector3(2, 0, 1)
	player._motion_acceleration = Vector2(4, 3)
	var remaining: float = site._time_left
	root.focus_exited.emit()
	assert(not player.controls_enabled and site._hud.is_panel_open())
	assert(not site._wayfinder._arrow.visible)
	await physics_frame
	await physics_frame
	var stopped: Vector3 = player.position
	for frame in range(10): await physics_frame
	assert(player.position.distance_to(stopped) < .0001)
	assert(Vector2(player.velocity.x, player.velocity.z).is_zero_approx())
	assert(player._motion_acceleration.is_zero_approx())
	assert(site._time_left == remaining)
	var resume: Button = site._hud._panel_content.get_child(1)
	assert(resume.has_focus())
	if OS.get_cmdline_user_args().has("--capture"):
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png("res://artifacts/focus-pause.png") == OK)
	root.focus_entered.emit()
	assert(not player.controls_enabled, "Focus return resumed without confirmation")
	resume.pressed.emit()
	assert(player.controls_enabled and not site._hud.is_panel_open())
	site._hud.show_task(site._tasks[0], site._tasks[0].station)
	player.controls_enabled = false
	var prompt: Label = site._hud._panel_content.get_child(1)
	var heading: String = prompt.text
	root.focus_exited.emit()
	assert(site._hud._panel_content.get_child(1) == prompt and prompt.text == heading)
	site._resume()
	site._round_done = true
	root.focus_exited.emit()
	assert(not site._hud.is_panel_open())
	site.queue_free()
	for frame in range(5): await process_frame
	print("FOCUS_PAUSE_SMOKE_OK")
	quit()

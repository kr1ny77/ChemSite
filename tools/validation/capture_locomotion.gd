extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	root.add_child(site)
	# Automated capture owns focus; desktop focus-loss behavior has its own gate.
	root.focus_exited.disconnect(site._pause_on_focus_loss)
	site.get_node("CanvasLayer").visible = false
	var camera := site.get_node("CameraRig/Camera3D") as Camera3D
	camera.position = Vector3(4.0, 5.0, 7.0)
	camera.look_at(Vector3(0, 1.0, 0), Vector3.UP)
	camera.size = 7.0
	if OS.get_cmdline_user_args().has("--side-view"):
		camera.position = Vector3(7.5, 3.5, 2.0)
		camera.look_at(Vector3(0, 1.0, 3.0), Vector3.UP)
	if OS.get_cmdline_user_args().has("--isolated"):
		for mesh in site.get_node("World").find_children("*", "MeshInstance3D", true, false):
			var bounds: AABB = mesh.global_transform * mesh.get_aabb()
			if bounds.size.y > 0.12:
				mesh.visible = false
	var player := site.get_node("Player") as CharacterBody3D
	if OS.get_cmdline_user_args().has("--no-plant"):
		player._foot_plant.active = false
	var walking := OS.get_cmdline_user_args().has("--walk")
	var transitions := OS.get_cmdline_user_args().has("--transitions")
	var turning := OS.get_cmdline_user_args().has("--turns")
	var dense := OS.get_cmdline_user_args().has("--dense")
	if walking:
		camera.size = 4.5
		player.global_position = Vector3(-5.0, 0.04, 0.0)
	else:
		player.global_position = Vector3(0.0, 0.04, 5.0)
	var folder := "res://artifacts/walk-grounding-frames" if walking else "res://artifacts/locomotion-frames"
	if transitions:
		folder = "res://artifacts/locomotion-transition-frames"
	if turning:
		folder = "res://artifacts/locomotion-turn-frames"
	if dense:
		folder += "-dense"
	if OS.get_cmdline_user_args().has("--no-plant"):
		folder += "-unplanted"
	if OS.get_cmdline_user_args().has("--side-view"):
		folder += "-side"
	if OS.get_cmdline_user_args().has("--isolated"):
		folder += "-isolated"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	var movement := "move_right" if walking else "move_forward"
	Input.action_press(movement, 0.68 if transitions else (0.3 if walking else 1.0))
	for frame in range(150 if turning else (120 if transitions else (240 if walking else 96))):
		if turning:
			if frame == 30 or frame == 90:
				Input.action_release(movement)
				movement = "move_back" if frame == 30 else "move_right"
				Input.action_press(movement)
			elif frame == 120:
				Input.action_release(movement)
		if transitions:
			if frame == 30:
				Input.action_press(movement, 0.95)
			elif frame == 60:
				Input.action_press(movement, 0.68)
			elif frame == 90:
				Input.action_release(movement)
		await physics_frame
		assert(player.controls_enabled, "Capture unexpectedly paused player controls")
		if frame > 0 and frame % (2 if dense else 8) == 0:
			await process_frame
			await RenderingServer.frame_post_draw
			var image := root.get_viewport().get_texture().get_image()
			var center := camera.unproject_position(player.global_position + Vector3(0, 1.0, 0))
			var origin := Vector2i(
				clampi(int(center.x) - 260, 0, image.get_width() - 520),
				clampi(int(center.y) - 300, 0, image.get_height() - 600)
			)
			var detail := image.get_region(Rect2i(origin, Vector2i(520, 600)))
			var path := folder + "/frame-%02d.png" % frame
			assert(detail.save_png(path) == OK, "Locomotion frame capture failed")
	Input.action_release(movement)
	print("LOCOMOTION_PLANT_BOUNDS correction_m=", player._foot_plant.maximum_correction, " boot_twist_deg=", rad_to_deg(player._foot_plant.maximum_boot_twist))
	print("LOCOMOTION_CAPTURE_OK")
	quit()

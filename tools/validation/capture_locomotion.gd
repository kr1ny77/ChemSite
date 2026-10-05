extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	root.add_child(site)
	site.get_node("CanvasLayer").visible = false
	var camera := site.get_node("CameraRig/Camera3D") as Camera3D
	camera.position = Vector3(4.0, 5.0, 7.0)
	camera.look_at(Vector3(0, 1.0, 0), Vector3.UP)
	camera.size = 7.0
	var player := site.get_node("Player") as CharacterBody3D
	var walking := OS.get_cmdline_user_args().has("--walk")
	var transitions := OS.get_cmdline_user_args().has("--transitions")
	if walking:
		camera.size = 4.5
		player.global_position = Vector3(-5.0, 0.04, 0.0)
	else:
		player.global_position = Vector3(0.0, 0.04, 5.0)
	var folder := "res://artifacts/walk-grounding-frames" if walking else "res://artifacts/locomotion-frames"
	if transitions:
		folder = "res://artifacts/locomotion-transition-frames"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	var movement := "move_right" if walking else "move_forward"
	Input.action_press(movement, 0.68 if transitions else (0.3 if walking else 1.0))
	for frame in range(120 if transitions else (240 if walking else 96)):
		if transitions:
			if frame == 30:
				Input.action_press(movement, 0.95)
			elif frame == 60:
				Input.action_press(movement, 0.68)
			elif frame == 90:
				Input.action_release(movement)
		await physics_frame
		if frame > 0 and frame % 8 == 0:
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
	print("LOCOMOTION_CAPTURE_OK")
	quit()

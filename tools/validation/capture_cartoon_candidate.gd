extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	root.add_child(site)
	var player: CharacterBody3D = site.get_node("Player")
	player.controls_enabled = false
	for frame in range(30):
		await physics_frame
	player.set_physics_process(false)
	var visual: Node3D = player.get_node("Visual")
	for child in visual.get_children():
		child.free()
	var document := GLTFDocument.new()
	var state := GLTFState.new()
	var path := ProjectSettings.globalize_path("res://artifacts/cartoon-character/cartoon_chemist.glb")
	if document.append_from_file(path, state) != OK:
		push_error("Cartoon candidate GLB failed to parse")
		quit(1)
		return
	var model := document.generate_scene(state)
	visual.add_child(model)
	model.position.y = 0.005
	var rear := OS.get_cmdline_user_args().has("--rear")
	visual.rotation.y = PI if rear else 0.0
	var animations := model.find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer
	for clip in ["Idle", "Walk", "Run", "UseStation"]:
		animations.get_animation(clip).loop_mode = Animation.LOOP_LINEAR
	var motion := OS.get_cmdline_user_args().has("--motion")
	var running := OS.get_cmdline_user_args().has("--run")
	animations.play("Run" if running else ("Walk" if motion else "Idle"))
	animations.speed_scale = 1.5 if running else 1.0
	site.get_node("CanvasLayer").visible = false
	var camera := site.get_node("CameraRig/Camera3D") as Camera3D
	player.global_position = Vector3(0, player.global_position.y, 0)
	camera.position = Vector3(3.0, 4.0, 5.0)
	camera.look_at(Vector3(0, 0.8, 0), Vector3.UP)
	camera.size = 4.0
	# Bound capture after synchronous GLB generation has completed.
	create_timer(20.0).timeout.connect(func():
		push_error("Cartoon capture exceeded its 20-second runtime bound")
		quit(1)
	)
	if motion:
		var speed := 3.130435 if running else 0.503607
		for frame in range(120):
			await process_frame
			player.global_position.z += speed / 60.0
			if frame % 30 == 0:
				print("CARTOON_MOTION_FRAME ", frame)
			camera.global_position = player.global_position + Vector3(3.0, 4.0, 5.0)
			camera.look_at(player.global_position + Vector3(0, 0.8, 0), Vector3.UP)
			if frame % 10 == 0:
				await process_frame
				# Read the completed viewport buffer without waiting on a new draw signal.
				var detail := root.get_viewport().get_texture().get_image()
				detail.save_png("res://artifacts/cartoon-character/native-%s-%03d.png" % ["run" if running else "walk", frame])
	for frame in range(5):
		await process_frame
	# Five process frames above allow the completed viewport buffer to refresh.
	var image := root.get_viewport().get_texture().get_image()
	if image.save_png("res://artifacts/cartoon-character/native-equipment-rear.png" if rear else "res://artifacts/cartoon-character/native-candidate.png") != OK:
		push_error("Cartoon candidate capture failed")
		quit(1)
		return
	print("CHEMSITE_CARTOON_CANDIDATE_CAPTURE_OK")
	quit()

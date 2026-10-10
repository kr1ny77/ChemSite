extends SceneTree

const DRIVER = preload("res://tools/validation/turn_motion_candidate_driver.gd")

func _initialize() -> void:
	create_timer(30.0).timeout.connect(func(): quit(1))
	call_deferred("_run")

func _run() -> void:
	root.size = Vector2i(640, 640)
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("263445")
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color("d5e5f6")
	environment.environment.ambient_light_energy = 0.7
	root.add_child(environment)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45, -30, 0)
	sun.light_energy = 1.4
	sun.shadow_enabled = true
	root.add_child(sun)
	var camera := Camera3D.new()
	root.add_child(camera)
	camera.position = Vector3(3, 2.5, 4)
	if OS.get_cmdline_user_args().has("--side-view"):
		camera.position = Vector3(4, 1.5, 0.3)
	camera.look_at(Vector3(0, 0.8, 0))
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 2.6
	camera.current = true
	var floor_body := StaticBody3D.new()
	var collider := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(10, 0.2, 10)
	collider.shape = box
	floor_body.add_child(collider)
	floor_body.position.y = -0.1
	root.add_child(floor_body)
	var floor_mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(10, 10)
	floor_mesh.mesh = plane
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("76818c")
	material.roughness = 0.85
	floor_mesh.material_override = material
	root.add_child(floor_mesh)
	var folder := "res://artifacts/cartoon-turn-candidate/native-frames"
	if OS.get_cmdline_user_args().has("--side-view"): folder += "-side"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	for action in ["TurnLeftStep", "TurnRightStep"]:
		var document := GLTFDocument.new()
		var state := GLTFState.new()
		assert(document.append_from_file("res://artifacts/cartoon-turn-candidate/cartoon_turn.glb", state) == OK)
		var body = DRIVER.new()
		root.add_child(body)
		body.configure(document.generate_scene(state, 384.0), action)
		body.paused = true
		await physics_frame
		await process_frame
		for phase in [0.0, 0.2, 0.397, 0.42, 0.6, 0.8, 1.0]:
			while body.elapsed < body.duration * phase:
				await physics_frame
				await process_frame
			RenderingServer.force_draw(false)
			root.get_texture().get_image().save_png(folder + "/%s-%03d.png" % [action, roundi(phase * 100)])
			body.paused = false
		body.queue_free()
		await process_frame
	print("TURN_ROOT_CAPTURE_OK frames=14")
	quit()

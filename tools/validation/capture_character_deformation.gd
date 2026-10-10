extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	root.add_child(site)
	if root.focus_exited.is_connected(site._pause_on_focus_loss):
		root.focus_exited.disconnect(site._pause_on_focus_loss)
	var player: CharacterBody3D = site.get_node("Player")
	player.controls_enabled = false
	for frame in range(10):
		await physics_frame
	player.set_physics_process(false)
	player.global_position = Vector3.ZERO
	player.visual.rotation.y = 0.0
	player._animation_tree.active = false
	player._foot_plant.active = false
	site.get_node("CanvasLayer").visible = false
	site.set_process(false)
	site.get_node("CameraRig").set_process(false)
	site.get_node("CameraRig").set_physics_process(false)
	for mesh in site.get_node("World").find_children("*", "MeshInstance3D", true, false):
		mesh.visible = false
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(20, 20)
	ground.mesh = plane
	ground.position.y = -.001
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(.3, .35, .38)
	material.roughness = 1.0
	ground.material_override = material
	site.add_child(ground)
	var camera: Camera3D = site.get_node("CameraRig/Camera3D")
	camera.size = 2.4
	var animations := player.visual.find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer
	var folder := "res://artifacts/cartoon-sleeve-repair/native"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	for view in ["front", "side"]:
		camera.global_position = Vector3(0, 1.1, 5) if view == "front" else Vector3(5, 1.1, 0)
		camera.look_at(Vector3(0, .82, 0))
		for action in ["Run", "Interact", "Celebrate"]:
			animations.play(action)
			animations.seek(animations.get_animation(action).length * (.8 if action == "Celebrate" else .65), true)
			animations.pause()
			for frame in range(3):
				await process_frame
			RenderingServer.force_draw()
			var capture := root.get_texture().get_image()
			if capture.save_png("%s/%s-%s.png" % [folder, action.to_lower(), view]) != OK:
				push_error("Character deformation capture failed")
				quit(1)
				return
	print("CHARACTER_DEFORMATION_CAPTURE_OK views=2 actions=3")
	quit()

extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	root.add_child(site)
	site.set_process(false)
	var player := site.get_node("Player") as CharacterBody3D
	player.controls_enabled = false
	player.global_position = Vector3(9.7, 0.04, 4.5)
	site.get_node("CanvasLayer").visible = false
	var rig := site.get_node("CameraRig") as Node3D
	rig.set_process(false)
	rig.set_physics_process(false)
	rig.position = Vector3.ZERO
	var camera := rig.get_node("Camera3D") as Camera3D
	camera.position = Vector3(12.7, 4.0, 8.0)
	camera.look_at(Vector3(9.7, 0.75, 3.0), Vector3.UP)
	camera.size = 4.5
	for frame in range(15):
		await process_frame
	var image := root.get_viewport().get_texture().get_image()
	if image.save_png("res://artifacts/water-bay/native-detail.png") != OK:
		quit(1)
		return
	print("WATER_BAY_CAPTURE_OK")
	quit()

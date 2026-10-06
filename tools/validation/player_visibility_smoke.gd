extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	root.add_child(site)
	await process_frame
	site.set_process(false)
	var player: CharacterBody3D = site.get_node("Player")
	player.controls_enabled = false
	player.set_physics_process(false)
	var camera: Camera3D = site.get_node("CameraRig/Camera3D")
	camera.position = Vector3(4, 5, 7)
	camera.look_at(Vector3(0, 1, 0), Vector3.UP)
	camera.size = 4.5
	var visibility: Node = site.get_node("CameraRig/PlayerVisibility")
	visibility.set_process(false)
	visibility.refresh_occluders()
	if not _check(visibility._occluders.size() > 0, "Camera occluder group empty"):
		return
	player.global_position = Vector3(-5, 0.04, 0)
	visibility.reduced_motion = false
	for frame in range(60):
		visibility._process(1.0 / 60.0)
	var faded := 0
	for mesh in visibility._occluders:
		if mesh.transparency > 0.8:
			faded += 1
	if not _check(faded > 0, "Beam failed to fade over the player"):
		return
	player.global_position = Vector3(9, 0.04, 5)
	for frame in range(60):
		visibility._process(1.0 / 60.0)
	for mesh in visibility._occluders:
		if not _check(mesh.transparency == 0.0, "Clear beam failed to restore opacity"):
			return
	visibility.reduced_motion = true
	player.global_position = Vector3(-5, 0.04, 0)
	visibility._process(1.0 / 60.0)
	var immediate := 0
	for mesh in visibility._occluders:
		if is_equal_approx(mesh.transparency, visibility.obscured_transparency):
			immediate += 1
	if not _check(immediate > 0, "Reduced motion fade failed to update immediately"):
		return
	for mesh in player.find_children("*", "MeshInstance3D", true, false):
		if not _check(mesh.transparency == 0.0, "Player material faded with the environment"):
			return
	print("PLAYER_VISIBILITY_SMOKE_OK faded=", faded, " immediate=", immediate)
	quit()

func _check(condition: bool, message: String) -> bool:
	if not condition:
		push_error(message)
		quit(1)
	return condition

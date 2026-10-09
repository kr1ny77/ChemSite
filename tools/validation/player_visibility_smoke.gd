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
	var station_fades := 0
	for level in [2, 4, 5]:
		var context := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
		context.level = level
		context.save_path = "user://visibility-context-isolated.json"
		root.add_child(context)
		await process_frame
		context.set_process(false)
		context._player.set_physics_process(false)
		context._player.global_position = Vector3(-4.1, .04, 0)
		context._camera_rig.global_position = context._player.global_position * Vector3(.6, 0, .6)
		var contextual_visibility: Node = context.get_node("CameraRig/PlayerVisibility")
		contextual_visibility.set_process(false)
		contextual_visibility.refresh_occluders()
		contextual_visibility.reduced_motion = true
		contextual_visibility._process(1.0 / 60.0)
		var stations: Array[MeshInstance3D] = []
		var count := 0
		for mesh in contextual_visibility._occluders:
			var asset: Node = mesh
			while asset.get_parent() != context._world and asset.get_parent() != null:
				asset = asset.get_parent()
			if "/stations/" in asset.scene_file_path:
				stations.append(mesh)
				if is_equal_approx(mesh.transparency, contextual_visibility.obscured_transparency):
					count += 1
		if not _check(count > 0, "Inspection station failed to reveal player on Level %d" % level):
			return
		station_fades += count
		context._player.global_position = Vector3(9, .04, 7)
		context._camera_rig.global_position = context._player.global_position * Vector3(.6, 0, .6)
		contextual_visibility._process(1.0 / 60.0)
		for mesh in stations:
			if not _check(mesh.transparency == 0.0, "Station failed to restore opacity after player leaves"):
				return
		context.queue_free()
		await process_frame
	print("PLAYER_VISIBILITY_SMOKE_OK faded=", faded, " immediate=", immediate, " contextual_station_fades=", station_fades)
	quit()

func _check(condition: bool, message: String) -> bool:
	if not condition:
		push_error(message)
		quit(1)
	return condition

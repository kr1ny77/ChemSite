extends SceneTree

const SETTINGS = preload("res://scripts/core/settings_data.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	var reduced := OS.get_cmdline_user_args().has("--reduced-motion")
	var settings_path := "user://qa-camera-perimeter-settings.json"
	var settings := {"reduced_motion": reduced}
	assert(SETTINGS.save_settings(settings, settings_path) == OK)
	site.settings_path = settings_path
	root.add_child(site)
	var player := site.get_node("Player") as CharacterBody3D
	player.controls_enabled = false
	var folder := "camera-perimeter-reduced" if reduced else "camera-perimeter"
	var directory := ProjectSettings.globalize_path("res://artifacts/" + folder)
	DirAccess.make_dir_recursive_absolute(directory)
	var positions := {
		"left": Vector3(-9.0, 0.04, 0.0),
		"right": Vector3(9.0, 0.04, 0.0),
		"rear": Vector3(0.0, 0.04, -7.0),
		"front": Vector3(0.0, 0.04, 7.0),
	}
	for name in positions:
		player.global_position = positions[name]
		for frame in range(45):
			await process_frame
		await RenderingServer.frame_post_draw
		print("CAMERA_POSITION ", name, " player=", player.global_position,
			" rig=", (site.get_node("CameraRig") as Node3D).global_position,
			" reduced=", site.reduced_motion)
		var image := root.get_viewport().get_texture().get_image()
		assert(image.save_png(directory.path_join(name + ".png")) == OK)
	print("CAMERA_PERIMETER_CAPTURE_OK")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(settings_path))
	quit()

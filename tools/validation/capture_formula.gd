extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var oxidation := OS.get_cmdline_user_args().has("--oxidation")
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	site.save_path = "user://capture-formula-progress.json"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(site.save_path))
	root.add_child(site)
	var player := site.get_node("Player") as CharacterBody3D
	player.global_position = Vector3(5.7, .05, -1.5)
	if oxidation:
		for index in range(site._tasks.size()):
			if site._tasks[index].id == "L1-027":
				site._task_index = index
				break
	else:
		site._task_index = 1
	site._update_hud()
	site._find_nearest_station()
	var event := InputEventAction.new(); event.action = "interact"; event.pressed = true
	site._unhandled_input(event)
	for i in range(5): await process_frame
	var image := root.get_viewport().get_texture().get_image()
	var screenshot_path := "res://artifacts/godot-oxidation-panel.png" if oxidation else "res://artifacts/godot-formula-panel.png"
	print("PANEL_CAPTURE ", image.save_png(screenshot_path))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(site.save_path))
	quit()

extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	site.save_path = "user://capture-results-progress.json"
	root.add_child(site)
	await process_frame
	for index in range(5):
		var task: Dictionary = site._tasks[site._task_index]
		site._active_station = task.station
		site._submit_answer(str(task.correctAnswer))
		site._resume()
	await create_timer(0.3).timeout
	await process_frame
	var image := root.get_viewport().get_texture().get_image()
	assert(image.save_png("res://artifacts/godot-results.png") == OK)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(site.save_path))
	print("RESULTS_CAPTURE_OK")
	quit()

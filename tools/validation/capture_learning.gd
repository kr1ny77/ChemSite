extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	site.save_path = "user://capture-learning-progress.json"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(site.save_path))
	root.add_child(site)
	await process_frame
	var task: Dictionary = site._tasks[0]
	site._active_station = task.station
	site.get_node("Player").controls_enabled = false
	site._submit_answer("wrong-answer")
	await create_timer(0.2).timeout
	await process_frame
	var image := root.get_viewport().get_texture().get_image()
	assert(image.save_png("res://artifacts/learning-feedback.png") == OK)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(site.save_path))
	print("LEARNING_FEEDBACK_CAPTURE_OK")
	quit()

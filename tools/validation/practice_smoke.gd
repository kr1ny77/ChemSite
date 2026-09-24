extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var main := (load("res://scenes/main/main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	await process_frame
	main._current.start_requested.emit("practice", "Формулы")
	await process_frame
	assert(main._current.mode == "practice" and main._current.practice_topic == "Формулы", "Menu did not route practice mode")
	main.queue_free()
	var save_path := "user://practice-smoke-progress.json"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	site.mode = "practice"
	site.practice_topic = "Формулы"
	site.save_path = save_path
	root.add_child(site)
	await process_frame
	assert(site._tasks.size() == 3 and site._target_count == 3)
	var starting_time: float = site._time_left
	await create_timer(0.1).timeout
	assert(site._time_left == starting_time, "Practice timer changed")
	for index in range(3):
		var task: Dictionary = site._tasks[site._task_index]
		site._active_station = task.station
		site._submit_answer(str(task.correctAnswer))
		if index < 2:
			site._resume()
	assert(site._round_done and site._completed == 3, "Practice did not finish")
	assert(not FileAccess.file_exists(save_path), "Practice changed career save")
	print("CHEMSITE_PRACTICE_SMOKE_OK")
	quit()

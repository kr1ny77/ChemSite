extends SceneTree

const TASK_BANK = preload("res://scripts/chemistry/task_bank.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var tasks: Array[Dictionary] = TASK_BANK.load_verified_tasks(4)
	assert(tasks.size() == 40, "Level 4 task count changed")
	var hud := (load("res://scenes/ui/game_hud.tscn") as PackedScene).instantiate()
	root.add_child(hud)
	var numeric_count := 0
	for task in tasks:
		hud.show_task(task, str(task.station))
		assert(hud.is_panel_open(), "Task panel did not open: " + str(task.id))
		if task.correctAnswer is Dictionary:
			numeric_count += 1
			assert(hud._panel_content.get_child(4) is LineEdit, "Hess input missing: " + str(task.id))
			assert(TASK_BANK.validate_choice(task, str(task.correctAnswer.value)), "Hess answer rejected: " + str(task.id))
		else:
			var valid_option := false
			for option in task.options:
				if TASK_BANK.validate_choice(task, str(option)):
					valid_option = true
			assert(valid_option, "Correct option unavailable: " + str(task.id))
		await process_frame
	assert(numeric_count == 2, "Level 4 Hess task count changed")
	hud.queue_free()
	await process_frame
	print("CHEMSITE_LEVEL4_CONTENT_OK: 40 tasks, 2 Hess calculations")
	quit()

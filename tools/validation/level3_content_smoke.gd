extends SceneTree

const TASK_BANK = preload("res://scripts/chemistry/task_bank.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var tasks: Array[Dictionary] = TASK_BANK.load_verified_tasks(3)
	assert(tasks.size() == 40, "Level 3 task count changed")
	var hud := (load("res://scenes/ui/game_hud.tscn") as PackedScene).instantiate()
	root.add_child(hud)
	var numeric_count := 0
	var equation_count := 0
	for task in tasks:
		hud.show_task(task, str(task.station))
		assert(hud.is_panel_open(), "Task panel did not open: " + str(task.id))
		var answer: Variant = task.correctAnswer
		if answer is Dictionary:
			numeric_count += 1
			assert(hud._panel_content.get_child(4) is LineEdit, "Numeric input missing: " + str(task.id))
			assert(TASK_BANK.validate_choice(task, str(answer.value)), "Numeric answer rejected: " + str(task.id))
			assert(not TASK_BANK.validate_choice(task, "not a number"), "Invalid number accepted: " + str(task.id))
		elif str(task.interactionType) == "dissociation":
			equation_count += 1
			assert(hud._panel_content.get_child(4) is LineEdit, "Dissociation input missing: " + str(task.id))
			assert(TASK_BANK.validate_choice(task, str(answer).replace(" -> ", " → ")), "Dissociation arrow rejected: " + str(task.id))
		elif task.has("options"):
			var valid_option := false
			for option in task.options:
				if TASK_BANK.validate_choice(task, str(option)):
					valid_option = true
			assert(valid_option, "Correct option unavailable: " + str(task.id))
		await process_frame
	assert(numeric_count == 24 and equation_count == 4, "Level 3 interaction distribution changed")
	hud.queue_free()
	await process_frame
	print("CHEMSITE_LEVEL3_CONTENT_OK: 40 tasks, 24 numeric, 4 dissociation")
	quit()

extends SceneTree

const TASK_BANK = preload("res://scripts/chemistry/task_bank.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var tasks: Array[Dictionary] = TASK_BANK.load_verified_tasks(1)
	assert(tasks.size() == 40, "Level 1 task count changed")
	var hud := (load("res://scenes/ui/game_hud.tscn") as PackedScene).instantiate()
	root.add_child(hud)
	for task in tasks:
		hud.show_task(task, str(task.station))
		assert(hud.is_panel_open(), "Task panel did not open: " + str(task.id))
		assert(TASK_BANK.validate_choice(task, str(task.correctAnswer)), "Curated answer rejected: " + str(task.id))
		if task.get("interactionType", "") == "formula-builder":
			var tokens: Array = task.get("parameters", {}).get("formulaTokens", [])
			for token in tokens:
				hud._append_token(str(token))
			assert(TASK_BANK.validate_choice(task, hud._formula_buffer), "Formula tiles did not build answer: " + str(task.id))
		elif task.has("options"):
			var has_valid_option := false
			for option in task.options:
				if TASK_BANK.validate_choice(task, str(option)):
					has_valid_option = true
			assert(has_valid_option, "No valid option: " + str(task.id))
		await process_frame
	hud.queue_free()
	await process_frame
	print("CHEMSITE_LEVEL1_CONTENT_OK: 40 tasks")
	quit()

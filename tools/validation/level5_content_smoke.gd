extends SceneTree

const TASK_BANK = preload("res://scripts/chemistry/task_bank.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var tasks: Array[Dictionary] = TASK_BANK.load_verified_tasks(5)
	assert(tasks.size() == 40, "Level 5 task count changed")
	var hud := (load("res://scenes/ui/game_hud.tscn") as PackedScene).instantiate()
	root.add_child(hud)
	var equation_count := 0
	var numeric_count := 0
	var formula_count := 0
	for task in tasks:
		hud.show_task(task, str(task.station))
		assert(hud.is_panel_open(), "Task panel did not open: " + str(task.id))
		if task.correctAnswer is Dictionary:
			numeric_count += 1
			assert(hud._panel_content.get_child(4) is LineEdit, "Numeric input missing: " + str(task.id))
			assert(TASK_BANK.validate_choice(task, str(task.correctAnswer.value)), "Numeric answer rejected: " + str(task.id))
		elif task.interactionType == "formula-builder":
			formula_count += 1
			assert(hud._panel_content.get_child(4) is GridContainer, "Formula tiles missing: " + str(task.id))
			assert(TASK_BANK.validate_choice(task, str(task.correctAnswer)), "Formula rejected: " + str(task.id))
		elif task.interactionType == "equation-completion":
			equation_count += 1
			assert(hud._panel_content.get_child(4) is LineEdit, "Equation input missing: " + str(task.id))
			assert(TASK_BANK.validate_choice(task, str(task.correctAnswer).replace(" -> ", " → ")), "Equation rejected: " + str(task.id))
		elif task.interactionType == "oxidation-state":
			assert(hud._panel_content.get_child(3) is LineEdit, "Oxidation input missing")
		else:
			var valid_option := false
			for option in task.options:
				if TASK_BANK.validate_choice(task, str(option)):
					valid_option = true
			assert(valid_option, "Correct option unavailable: " + str(task.id))
		await process_frame
	assert(equation_count == 3 and numeric_count == 1 and formula_count == 2)
	hud.queue_free()
	await process_frame
	print("CHEMSITE_LEVEL5_CONTENT_OK: 40 panels, 3 equations, 2 formulas, 1 numeric")
	quit()

extends SceneTree

const TASK_BANK = preload("res://scripts/chemistry/task_bank.gd")
const EQUATION_TYPES := ["equation-completion", "equation-balancing", "virtual-mixing", "ionic-equation"]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var tasks: Array[Dictionary] = TASK_BANK.load_verified_tasks(2)
	assert(tasks.size() == 39, "Level 2 verified task count changed")
	var hud := (load("res://scenes/ui/game_hud.tscn") as PackedScene).instantiate()
	root.add_child(hud)
	var equation_count := 0
	for task in tasks:
		hud.show_task(task, str(task.station))
		assert(hud.is_panel_open(), "Task panel did not open: " + str(task.id))
		assert(TASK_BANK.validate_choice(task, str(task.correctAnswer)), "Curated answer rejected: " + str(task.id))
		if str(task.interactionType) in EQUATION_TYPES:
			equation_count += 1
			assert(hud._panel_content.get_child(4) is LineEdit, "Equation input missing: " + str(task.id))
			var displayed := str(task.correctAnswer).replace("->", " → ")
			assert(TASK_BANK.validate_choice(task, displayed), "Display notation rejected: " + str(task.id))
			assert(not TASK_BANK.validate_choice(task, "NaCl -> NaCl"), "Incorrect equation accepted: " + str(task.id))
		elif task.has("options"):
			var has_valid_option := false
			for option in task.options:
				if TASK_BANK.validate_choice(task, str(option)):
					has_valid_option = true
			assert(has_valid_option, "No valid choice: " + str(task.id))
		await process_frame
	assert(equation_count == 19, "Equation task count changed")
	var first := tasks[0]
	assert(TASK_BANK.validate_choice(first, "CaO + H₂O → Ca(OH)₂"), "Subscript notation rejected")
	assert(not TASK_BANK.load_verified_tasks(2).any(func(task: Dictionary) -> bool: return task.id == "L2-050"), "Review task entered production")
	hud.queue_free()
	await process_frame
	print("CHEMSITE_LEVEL2_CONTENT_OK: 39 tasks, 19 equations")
	quit()

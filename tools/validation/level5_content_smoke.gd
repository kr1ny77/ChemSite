extends SceneTree

const TASK_BANK = preload("res://scripts/chemistry/task_bank.gd")
const ROUND_SMOKE = preload("res://scripts/qa/export_round_smoke.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var tasks: Array[Dictionary] = TASK_BANK.load_verified_tasks(5)
	assert(tasks.size() == 40, "Level 5 task count changed")
	var station_ids := ["construction-materials-station", "reaction-bench", "corrosion-test-rig", "inspection-station"]
	var hud := (load("res://scenes/ui/game_hud.tscn") as PackedScene).instantiate()
	root.add_child(hud)
	var submitted: Array[String] = []
	hud.answer_submitted.connect(func(answer: String) -> void: submitted.append(answer))
	var equation_count := 0
	var numeric_count := 0
	var formula_count := 0
	var mission_count := 0
	for task in tasks:
		assert(station_ids.has(str(task.station)), "Level 5 task has no site station: " + str(task.id))
		hud.show_task(task, str(task.station))
		assert(hud.is_panel_open(), "Task panel did not open: " + str(task.id))
		if task.correctAnswer is Dictionary:
			numeric_count += 1
			var numeric_input_found := false
			for control in hud._panel_content.get_children():
				if control is LineEdit:
					numeric_input_found = true
			assert(numeric_input_found, "Numeric input missing: " + str(task.id))
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
		var mission_steps: Array = task.get("parameters", {}).get("missionSteps", [])
		if not mission_steps.is_empty():
			mission_count += 1
			var stage: Control = hud.get("_mission_stage")
			assert(stage != null and not stage.is_complete(), "Mission stages missing: " + str(task.id))
			assert(root.get_viewport().gui_get_focus_owner() == stage.get_node("NextButton"), "Mission focus missing: " + str(task.id))
			for control in hud._panel_content.get_children():
				if control is GridContainer:
					for choice in control.get_children():
						assert(choice.disabled, "Answer enabled before inspection: " + str(task.id))
				elif control is LineEdit:
					assert(not control.editable, "Numeric answer enabled before inspection: " + str(task.id))
		assert(ROUND_SMOKE._submit_through_ui(hud, task), "HUD submission control failed: " + str(task.id))
		assert(submitted.size() == 1, "HUD submission count failed: " + str(task.id))
		assert(TASK_BANK.validate_choice(task, submitted[0]), "HUD emitted wrong answer: " + str(task.id))
		submitted.clear()
		await process_frame
	assert(equation_count == 3 and numeric_count == 1 and formula_count == 2 and mission_count == 9)
	hud.queue_free()
	await process_frame
	print("CHEMSITE_LEVEL5_CONTENT_OK: 40 panels, 3 equations, 2 formulas, 1 numeric")
	quit()

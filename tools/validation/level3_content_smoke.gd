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
	var scale_count := 0
	var solution_count := 0
	var ph_count := 0
	for task in tasks:
		hud.show_task(task, str(task.station))
		assert(hud.is_panel_open(), "Task panel did not open: " + str(task.id))
		var answer: Variant = task.correctAnswer
		if answer is Dictionary:
			numeric_count += 1
			var input: Control = hud._panel_content.get_child(5 if task.interactionType in ["virtual-scales", "solution-preparation"] else 4)
			assert(input is LineEdit, "Numeric input missing: " + str(task.id))
			if task.interactionType == "virtual-scales":
				scale_count += 1
				var scale: VBoxContainer = hud._scale_view
				assert(scale != null and not scale.is_ready(), "Scale was skipped: " + str(task.id))
				assert(not input.editable, "Numeric input opened before measurement: " + str(task.id))
				scale.prepare_sample()
				var wrong := "m = n · M" if task.parameters.scaleMode == "mass-to-moles" else "n = m / M"
				scale.select_formula(wrong)
				assert(not scale.is_ready() and not input.editable, "Wrong scale formula unlocked answer: " + str(task.id))
				scale.select_formula("n = m / M" if task.parameters.scaleMode == "mass-to-moles" else "m = n · M")
				assert(scale.is_ready() and input.editable, "Scale formula did not unlock answer: " + str(task.id))
			if task.interactionType == "solution-preparation":
				solution_count += 1
				var setup: VBoxContainer = hud._solution_view
				assert(setup != null and not setup.is_ready() and not input.editable, "Solution setup was skipped: " + str(task.id))
				setup.select_volume(-1.0)
				assert(not setup.is_ready() and not input.editable, "Wrong volume unlocked answer: " + str(task.id))
				setup.select_volume(float(task.parameters.targetVolumeMl) / 1000.0)
				assert(not setup.is_ready() and not input.editable, "Volume alone unlocked answer: " + str(task.id))
				var mass_mode: bool = str(task.parameters.solutionMode) == "mass"
				setup.select_formula("m = C / (V · M)" if mass_mode else "C₁ + V₁ = C₂ + V₂")
				assert(not setup.is_ready() and not input.editable, "Wrong formula unlocked answer: " + str(task.id))
				setup.select_formula("m = C · V · M" if mass_mode else "C₁V₁ = C₂V₂")
				assert(setup.is_ready() and input.editable, "Solution setup did not unlock answer: " + str(task.id))
			assert(TASK_BANK.validate_choice(task, str(answer.value)), "Numeric answer rejected: " + str(task.id))
			assert(not TASK_BANK.validate_choice(task, "not a number"), "Invalid number accepted: " + str(task.id))
		elif str(task.interactionType) == "dissociation":
			equation_count += 1
			assert(hud._panel_content.get_child(4) is LineEdit, "Dissociation input missing: " + str(task.id))
			assert(TASK_BANK.validate_choice(task, str(answer).replace(" -> ", " → ")), "Dissociation arrow rejected: " + str(task.id))
		elif task.has("options"):
			if task.interactionType == "pH-terminal":
				ph_count += 1
				var meter: VBoxContainer = hud._ph_view
				var cards: GridContainer = hud._panel_content.get_child(4)
				assert(meter != null and not meter.is_complete() and (cards.get_child(0) as Button).disabled, "pH reading gate missing: " + str(task.id))
				meter.read_sample(0)
				if task.parameters.phSamples.size() == 2:
					assert(not meter.is_complete() and (cards.get_child(0) as Button).disabled, "One pH reading unlocked comparison: " + str(task.id))
					meter.read_sample(1)
				assert(meter.is_complete() and not (cards.get_child(0) as Button).disabled, "pH reading did not unlock answer: " + str(task.id))
			var valid_option := false
			for option in task.options:
				if TASK_BANK.validate_choice(task, str(option)):
					valid_option = true
			assert(valid_option, "Correct option unavailable: " + str(task.id))
		await process_frame
	assert(numeric_count == 24 and equation_count == 4 and scale_count == 5 and solution_count == 3 and ph_count == 4, "Level 3 interaction distribution changed")
	hud.queue_free()
	await process_frame
	print("CHEMSITE_LEVEL3_CONTENT_OK: 40 tasks, 24 numeric, 5 scales, 3 solutions, 4 pH readings, 4 dissociation")
	quit()

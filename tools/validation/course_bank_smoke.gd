extends SceneTree
const BANK = preload("res://scripts/chemistry/task_bank.gd")
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var counts := [200, 160, 240, 240, 160]
	var hud := (load("res://scenes/ui/game_hud.tscn") as PackedScene).instantiate()
	root.add_child(hud)
	var checked := 0
	for level in range(1, 6):
		var tasks := BANK.load_verified_tasks(level)
		assert(tasks.size() == counts[level - 1])
		for task in tasks:
			var answer: Variant = task.correctAnswer
			var text := str(answer.value) if answer is Dictionary else str(answer)
			assert(BANK.validate_choice(task, text), str(task.id))
			if answer is Dictionary:
				assert(not BANK.validate_choice(task, str(float(answer.value) + maxf(1.0, absf(float(answer.value))))), str(task.id))
			if str(task.id).begins_with("C"):
				hud.show_task(task, str(task.station))
				assert(hud.is_panel_open())
				if task.interactionType == "formula-builder":
					for token in task.parameters.formulaTokens:
						hud._append_token(str(token))
					assert(BANK.validate_choice(task, hud._formula_buffer))
				await process_frame
			checked += 1
	print("COURSE_BANK_NATIVE_OK tasks=", checked)
	quit()

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
	var route_count := 0
	for task in tasks:
		hud.show_task(task, str(task.station))
		assert(hud.is_panel_open(), "Task panel did not open: " + str(task.id))
		if task.correctAnswer is Dictionary:
			numeric_count += 1
			var input: Control = hud._panel_content.get_child(5)
			assert(input is LineEdit, "Hess input missing: " + str(task.id))
			var route: VBoxContainer = hud._hess_view
			assert(route != null and not route.is_ready() and not input.editable, "Hess route was skipped: " + str(task.id))
			route_count += 1
			if task.id == "L4-127":
				route.choose_step("A", "B")
				route.choose_step("B", "A")
			else:
				route.choose_step("B", "A")
				route.choose_step("A", "B")
			assert(not route.is_ready() and not input.editable, "Loop unlocked Hess answer: " + str(task.id))
			route.reset_route()
			if task.id == "L4-127":
				route.choose_step("A", "B")
				route.choose_step("B", "C")
				assert(route.selected_deltas() == [20, -50], "Hess step signs changed")
			else:
				route.choose_step("B", "A")
				route.choose_step("A", "C")
				assert(route.selected_deltas() == [100, -40], "Reversed Hess step sign changed")
			assert(route.is_ready() and input.editable, "Hess route did not unlock answer: " + str(task.id))
			assert(TASK_BANK.validate_choice(task, str(task.correctAnswer.value)), "Hess answer rejected: " + str(task.id))
		else:
			var valid_option := false
			for option in task.options:
				if TASK_BANK.validate_choice(task, str(option)):
					valid_option = true
			assert(valid_option, "Correct option unavailable: " + str(task.id))
		await process_frame
	assert(numeric_count == 2 and route_count == 2, "Level 4 Hess task count changed")
	hud.queue_free()
	await process_frame
	print("CHEMSITE_LEVEL4_CONTENT_OK: 40 tasks, 2 Hess routes and calculations")
	quit()

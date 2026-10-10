extends SceneTree

const TASK_BANK = preload("res://scripts/chemistry/task_bank.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var hud := (load("res://scenes/ui/game_hud.tscn") as PackedScene).instantiate()
	root.add_child(hud)
	var checked := 0
	var failures: Array[String] = []
	for level in range(1, 6):
		for task in TASK_BANK.load_verified_tasks(level):
			hud.close_panel()
			hud.update_status(task, 0, 0, 900.0, {})
			if not hud._prompt.get_parent().visible: failures.append(str(task.id) + " missing exploration navigation")
			hud.show_task(task, str(task.station))
			await process_frame
			checked += 1
			_check_panel(hud, str(task.id), "unread", failures)
			assert(not hud._hint.visible and not hud._hint_button.button_pressed, "Hint visible on task open")
			hud._hint_button.set_pressed(true)
			await process_frame
			await process_frame
			assert(hud._hint.visible and hud._hint.text == "ПОДСКАЗКА: " + task.hint)
			_check_panel(hud, str(task.id), "hint", failures)
			var expanded := false
			if hud._comparison_view != null:
				hud._comparison_view.inspect_run(0)
				hud._comparison_view.inspect_run(1)
				expanded = true
			elif hud._ph_view != null:
				for index in range(task.parameters.phSamples.size()):
					hud._ph_view.read_sample(index)
				expanded = true
			elif hud._ionization_view != null:
				for index in range(task.parameters.ionizationSamples.size()):
					hud._ionization_view.scan_sample(index)
				expanded = true
			elif hud._mission_stage != null:
				while not hud._mission_stage.is_complete():
					hud._mission_stage.reveal_next()
				expanded = true
			if expanded:
				await process_frame
				_check_panel(hud, str(task.id), "read", failures)
			hud._hint_button.set_pressed(false)
			assert(not hud._hint.visible, "Hint toggle failed to hide")
			hud.close_panel()
			if not hud._prompt.get_parent().visible: failures.append(str(task.id) + " navigation not restored after close")
	var feedback_checked := 0
	for level in range(1, 6):
		for task in TASK_BANK.load_verified_tasks(level):
			for correct in [true, false]:
				hud.show_feedback(correct, task, 200, 5)
				await process_frame
				await process_frame
				_check_panel(hud, str(task.id), "feedback_correct" if correct else "feedback_wrong", failures)
				feedback_checked += 1
	for mode in ["career", "practice"]:
		hud.show_results(700, 5, 600.0, 5, mode)
		await process_frame
		await process_frame
		_check_panel(hud, mode, "results", failures)
	hud.show_pause()
	await process_frame
	await process_frame
	_check_panel(hud, "pause", "pause", failures)
	hud.queue_free()
	await process_frame
	for failure in failures:
		push_error(failure)
	if not failures.is_empty():
		quit(1)
		return
	print("CHEMSITE_HUD_LAYOUT_OK: %d verified task panels at %dx%d" % [checked, root.get_viewport().size.x, root.get_viewport().size.y])
	print("CHEMSITE_FEEDBACK_LAYOUT_OK: %d correct/wrong panels and career/practice results" % feedback_checked)
	quit()

func _check_panel(hud: Control, identifier: String, phase: String, failures: Array[String]) -> void:
	if hud._prompt.get_parent().visible:
		failures.append(identifier + " " + phase + " navigation visible behind modal")
	var panel: PanelContainer = hud._panel
	var panel_rect := panel.get_global_rect()
	var screen := Vector2(root.get_viewport().get_visible_rect().size)
	if panel_rect.position.y < -1.0 or panel_rect.end.y > screen.y + 1.0:
		failures.append("%s %s panel outside screen: %s / %s" % [identifier, phase, panel_rect, screen])
	if panel.get_combined_minimum_size().y > panel.size.y + 1.0:
		failures.append("%s %s panel content overflow: %.1f > %.1f" % [identifier, phase, panel.get_combined_minimum_size().y, panel.size.y])
	var children: Array = hud._panel_content.get_children()
	var close_button: Button = children.back() as Button
	if close_button == null or close_button.get_global_rect().end.y > panel_rect.end.y - 5.0:
		failures.append("%s %s close button clipped" % [identifier, phase])

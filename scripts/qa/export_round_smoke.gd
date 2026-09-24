extends RefCounted

const TASK_BANK = preload("res://scripts/chemistry/task_bank.gd")

static func run(main: Node, capture_visual: bool = false, level: int = 1) -> bool:
	var save_path := "user://export-round-smoke-progress.json"
	var capture_dir := "user://qa-visual-round" if level == 1 else "user://qa-visual-level%d-round" % level
	DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
	if capture_visual:
		var directory_error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(capture_dir))
		if directory_error != OK:
			push_error("Export visual smoke: could not create capture directory")
			return false
	main.start_game("career", "", level)
	var site: Node3D = main._current
	var audio: Node = main.get_node("AudioController")
	site.disconnect("feedback_given", audio.play_feedback)
	site.disconnect("station_used", audio.play_interact)
	site.save_path = save_path
	site._load_tasks()
	site._update_hud()
	await main.get_tree().process_frame
	if site._tasks.size() < 5:
		push_error("Export smoke: task data did not load")
		return false
	var hud: Control = site.get_node("CanvasLayer/GameHud")
	var player: CharacterBody3D = site.get_node("Player")
	var interact := InputEventAction.new()
	interact.action = "interact"
	interact.pressed = true
	for index in range(5):
		var task: Dictionary = site._tasks[site._task_index]
		var station: Dictionary = site._stations().filter(func(entry: Dictionary) -> bool: return entry.id == task.station)[0]
		player.global_position = station.position + Vector3(0, 0.05, 1.8)
		site._find_nearest_station()
		site._unhandled_input(interact)
		if not hud.is_panel_open():
			push_error("Export smoke: station panel failed at task %d" % index)
			return false
		if capture_visual and not await _capture(main, "%s/task_%02d.png" % [capture_dir, index + 1]):
			return false
		if not _submit_through_ui(hud, task):
			push_error("Export smoke: UI answer submission failed at task %d" % index)
			return false
		if site._completed != index + 1:
			push_error("Export smoke: task completion failed at %d" % index)
			return false
		if capture_visual and not await _capture(main, "%s/feedback_%02d.png" % [capture_dir, index + 1]):
			return false
		site._resume()
	if capture_visual and not await _capture(main, capture_dir + "/results.png"):
		return false
	var progress: Dictionary = load("res://scripts/core/save_data.gd").load_progress(save_path)
	var expected_score := int({1: 700, 2: 840, 3: 980}.get(level, -1))
	var passed: bool = site._round_done and site._score == expected_score and int(progress.best_stars) == 3 and int(progress.completed_rounds) == 1
	DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
	if capture_visual:
		site.queue_free()
		await main.get_tree().process_frame
		audio.queue_free()
		await main.get_tree().process_frame
		await main.get_tree().create_timer(0.8).timeout
	if passed:
		print("CHEMSITE_EXPORT_VISUAL_ROUND_OK: " + ProjectSettings.globalize_path(capture_dir) if capture_visual else "CHEMSITE_EXPORT_LEVEL%d_ROUND_OK" % level)
	else:
		push_error("Export smoke: results or save are invalid")
	return passed

static func _capture(main: Node, path: String) -> bool:
	for frame in range(4):
		await main.get_tree().process_frame
	var screenshot := main.get_viewport().get_texture().get_image()
	var capture_error := screenshot.save_png(path)
	if capture_error != OK:
		push_error("Export visual smoke: screenshot failed: " + path)
		return false
	return true

static func _submit_through_ui(hud: Control, task: Dictionary) -> bool:
	var panel_content := hud.get("_panel_content") as VBoxContainer
	var interaction := str(task.get("interactionType", ""))
	if interaction == "formula-builder":
		var tile_grid: GridContainer
		for child in panel_content.get_children():
			if child is GridContainer:
				tile_grid = child
				break
		if tile_grid == null:
			return false
		for token in task.get("tokenOptions", task.get("parameters", {}).get("formulaTokens", [])):
			var matched := false
			for button in tile_grid.get_children():
				if button is Button and button.text == str(token):
					button.pressed.emit()
					matched = true
					break
			if not matched:
				return false
		if not TASK_BANK.validate_choice(task, str(hud.get("_formula_buffer"))):
			return false
		for child in panel_content.get_children():
			if child is HBoxContainer:
				for button in child.get_children():
					if button is Button and button.text.begins_with("ПРОВЕРИТЬ"):
						button.pressed.emit()
						return true
		return false
	if interaction in ["oxidation-state", "equation-completion", "equation-balancing", "virtual-mixing", "ionic-equation", "dissociation", "numeric-calculation", "virtual-scales", "solution-preparation"]:
		for child in panel_content.get_children():
			if child is LineEdit:
				child.text = str(task.correctAnswer.value) if task.correctAnswer is Dictionary else str(task.correctAnswer)
				child.text_submitted.emit(child.text)
				return true
		return false
	for child in panel_content.get_children():
		if child is GridContainer:
			for button in child.get_children():
				if button is Button and TASK_BANK.validate_choice(task, button.text):
					button.pressed.emit()
					return true
	return false

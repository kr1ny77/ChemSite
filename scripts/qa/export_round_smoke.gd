extends RefCounted

const TASK_BANK = preload("res://scripts/chemistry/task_bank.gd")

static func run(main: Node, capture_visual: bool = false, level: int = 1, task_ids: Array[String] = []) -> bool:
	var save_path := "user://export-round-smoke-progress.json"
	var capture_dir := "user://qa-visual-round" if level == 1 else "user://qa-visual-level%d-round" % level
	if not task_ids.is_empty():
		capture_dir += "-mission"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
	if capture_visual:
		var directory_error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(capture_dir))
		if directory_error != OK:
			push_error("Export visual smoke: could not create capture directory")
			return false
		for filename in DirAccess.get_files_at(capture_dir):
			if filename.ends_with(".png") and (filename.begins_with("task_") or filename.begins_with("feedback_") or filename.begins_with("observation_") or filename == "results.png"):
				if DirAccess.remove_absolute(ProjectSettings.globalize_path(capture_dir.path_join(filename))) != OK:
					push_error("Export visual smoke: could not clear prior QA capture")
					return false
	main.start_game("career", "", level)
	var site: Node3D = main._current
	var audio: Node = main.get_node("AudioController")
	site.disconnect("feedback_given", audio.play_feedback)
	site.disconnect("station_used", audio.play_interact)
	site.save_path = save_path
	site._load_tasks()
	if not task_ids.is_empty():
		site._tasks.clear()
		var bank := TASK_BANK.load_verified_tasks(level)
		for identifier in task_ids:
			var matches := bank.filter(func(task: Dictionary) -> bool: return task.id == identifier)
			if matches.size() != 1:
				push_error("Export smoke: mission task missing: " + identifier)
				return false
			site._tasks.append(matches[0])
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
		if not _prepare_through_ui(hud, task):
			push_error("Export smoke: observation preparation failed at task %d" % index)
			return false
		if capture_visual and task.get("parameters", {}).has("comparisonVisuals"):
			await main.get_tree().create_timer(1.3).timeout
			if not await _capture(main, "%s/observation_%02d.png" % [capture_dir, index + 1]):
				return false
		if not _answer_through_ui(hud, task):
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
	var expected_score := int({1: 700, 2: 840, 3: 980, 4: 1120, 5: 1260}.get(level, -1))
	var passed: bool = site._round_done and site._score == expected_score and int(progress.best_stars) == 3 and int(progress.completed_rounds) == 1
	DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
	if capture_visual:
		site.queue_free()
		await main.get_tree().process_frame
		audio.queue_free()
		await main.get_tree().process_frame
		await main.get_tree().create_timer(0.8).timeout
	if passed:
		print("CHEMSITE_EXPORT_VISUAL_ROUND_OK: " + ProjectSettings.globalize_path(capture_dir) if capture_visual else "CHEMSITE_EXPORT_LEVEL%d%s_ROUND_OK" % [level, "_MISSION" if not task_ids.is_empty() else ""])
	else:
		push_error("Export smoke: results or save are invalid")
	return passed

static func _capture(main: Node, path: String) -> bool:
	for frame in range(4):
		await main.get_tree().process_frame
	RenderingServer.force_draw(false)
	var screenshot := main.get_viewport().get_texture().get_image()
	var capture_error := screenshot.save_png(path)
	if capture_error != OK:
		push_error("Export visual smoke: screenshot failed: " + path)
		return false
	return true

static func _submit_through_ui(hud: Control, task: Dictionary) -> bool:
	return _prepare_through_ui(hud, task) and _answer_through_ui(hud, task)

static func _prepare_through_ui(hud: Control, task: Dictionary) -> bool:
	var panel_content := hud.get("_panel_content") as VBoxContainer
	for child in panel_content.get_children():
		if child.has_method("is_complete") and child.has_method("reveal_next"):
			while not child.is_complete():
				(child.get_node("NextButton") as Button).pressed.emit()
		if child.has_method("is_mixed") and not child.is_mixed():
			for reagent in task.get("parameters", {}).get("mixingReagents", []):
				var selected := false
				for button in child.get_node("Choices").get_children():
					if button is Button and button.text == str(reagent):
						button.pressed.emit()
						selected = true
						break
				if not selected:
					return false
			if not child.is_mixed():
				return false
		if child.has_method("is_ready") and child.has_method("prepare_sample") and not child.is_ready():
			(child.get_node("PrepareButton") as Button).pressed.emit()
			var formula := "n = m / M" if str(task.get("parameters", {}).get("scaleMode", "")) == "mass-to-moles" else "m = n · M"
			for button in child.get_node("FormulaButtons").get_children():
				if button is Button and button.text == formula:
					button.pressed.emit()
					break
			if not child.is_ready():
				return false
		if child.has_method("select_volume") and not child.is_ready():
			var expected_volume: float = float(task.get("parameters", {}).get("targetVolumeMl", 0.0)) / 1000.0
			var matched_volume := false
			for button in child.get_node("VolumeButtons").get_children():
				if button is Button and button.text == "%.3f л" % expected_volume:
					button.pressed.emit()
					matched_volume = true
					break
			if not matched_volume:
				return false
			var formula := "m = C · V · M" if str(task.get("parameters", {}).get("solutionMode", "")) == "mass" else "C₁V₁ = C₂V₂"
			for button in child.get_node("FormulaButtons").get_children():
				if button is Button and button.text == formula:
					button.pressed.emit()
					break
			if not child.is_ready():
				return false
		if child.has_method("choose_step") and not child.is_ready():
			if not _complete_hess_route(child, task.get("parameters", {})):
				return false
		if child.has_method("inspect_run") and not child.is_complete():
			for button in child.get_node("RunButtons").get_children():
				(button as Button).pressed.emit()
			if not child.is_complete():
				return false
		if child.has_method("read_sample") and not child.is_complete():
			for button in child.get_node("SampleButtons").get_children():
				(button as Button).pressed.emit()
			if not child.is_complete():
				return false
		if child.has_method("scan_sample") and not child.is_complete():
			for row in child.get_node("SampleRows").get_children():
				(row.get_child(0) as Button).pressed.emit()
			if not child.is_complete():
				return false
		if child.has_method("select_count") and not child.is_ready():
			var ions: Dictionary = task.get("parameters", {}).get("dissociationIons", {})
			child.select_count("cation", int(ions.cation.count))
			child.select_count("anion", int(ions.anion.count))
			if not child.is_ready():
				return false
	return true

static func _answer_through_ui(hud: Control, task: Dictionary) -> bool:
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
	if task.correctAnswer is Dictionary or interaction in ["oxidation-state", "equation-completion", "equation-balancing", "virtual-mixing", "ionic-equation", "dissociation", "numeric-calculation", "virtual-scales", "solution-preparation"]:
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

static func _complete_hess_route(view: Control, parameters: Dictionary) -> bool:
	var edges: Array[Dictionary] = []
	for source in parameters.get("hessEdges", []):
		var edge: Dictionary = source
		edges.append({"from": str(edge.from), "to": str(edge.to)})
		edges.append({"from": str(edge.to), "to": str(edge.from)})
	var queue: Array[Dictionary] = [{"node": str(parameters.get("hessStart", "")), "path": []}]
	var visited := {}
	var target := str(parameters.get("hessEnd", ""))
	while not queue.is_empty():
		var candidate: Dictionary = queue.pop_front()
		var node: String = candidate.node
		if node == target:
			for step in candidate.path:
				var pressed := false
				for button in view.get_node("Choices").get_children():
					if button is Button and not button.disabled and button.text.begins_with("%s → %s" % [step.from, step.to]):
						button.pressed.emit()
						pressed = true
						break
				if not pressed:
					return false
			return view.is_ready()
		if visited.has(node):
			continue
		visited[node] = true
		for edge in edges:
			if edge.from == node and not visited.has(edge.to):
				var path: Array = candidate.path.duplicate()
				path.append(edge)
				queue.append({"node": edge.to, "path": path})
	return false

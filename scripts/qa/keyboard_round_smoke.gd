extends RefCounted

const SAVE = preload("res://scripts/core/save_data.gd")
const BANK = preload("res://scripts/chemistry/task_bank.gd")
const SAVE_PATH := "user://qa-keyboard-progress.json"
static func selected_level() -> int:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--qa-keyboard-level="):
			return argument.get_slice("=", 1).to_int()
	return 1

static func save_path() -> String:
	return SAVE_PATH if selected_level() == 1 else "user://qa-keyboard-level%d-progress.json" % selected_level()

static func _route(station: Dictionary) -> Array:
	var position: Vector3 = station.position
	if position.x < 0:
		return [[KEY_A, -4.1, "x"]] if absf(position.z) < 1 else [[KEY_A, -3.3, "x"], [KEY_W, -1.7, "z"]]
	return [[KEY_S, 4.5, "z"], [KEY_D, 4.0, "x"]] if position.z > 0 else [[KEY_W, -3.4, "z"], [KEY_D, 4.35, "x"]]

static func run(main: Node) -> bool:
	var tree := main.get_tree()
	var level := selected_level()
	if level < 1 or level > 5: return false
	var path := save_path()
	var user_hash := FileAccess.get_sha256(ProjectSettings.globalize_path(SAVE.SAVE_PATH))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	var seed := SAVE.load_progress(path)
	seed.unlocked_level = level
	if SAVE._write_progress(seed, path) != OK: return false
	main.show_menu()
	await tree.process_frame
	var focus := main.get_viewport().gui_get_focus_owner()
	if not (focus is Button and focus.text.begins_with("КАРЬЕРА")):
		push_error("Keyboard round check failed at step %d" % 19)
		return false
	if level == 1:
		await _tap(main, KEY_SPACE)
	else:
		var selected := false
		for child in main._current._menu_content.get_children():
			if child is Button and child.text.begins_with("УРОВЕНЬ %d ·" % level):
				selected = await _button(main, child.text)
				break
		if not selected: return false
	var site: Node = main._current
	if not (site is Node3D and site.save_path == path and site.level == level):
		push_error("Keyboard round check failed at step %d" % 22)
		return false
	var player: CharacterBody3D = site._player
	for index in range(5):
		var task: Dictionary = site._tasks[site._task_index]
		print("KEYBOARD_TASK_BEGIN level=", level, " id=", task.id)
		var stations: Array = site._stations().filter(func(entry: Dictionary): return entry.id == task.station)
		if stations.size() != 1: return false
		var route: Array = _route(stations[0])
		for step in route:
			if not (await _walk(main, player, step[0], step[1], step[2])):
				push_error("Keyboard round check failed at step %d" % 29)
				return false
		site._find_nearest_station()
		if not (site._nearest_station.get("id", "") == task.station):
			push_error("Keyboard round check failed at step %d" % 31)
			return false
		if index == 0:
			await _tap(main, KEY_ESCAPE)
			if not (site._hud.is_panel_open() and not player.controls_enabled):
				push_error("Keyboard round check failed at step %d" % 34)
				return false
			var time_left: float = site._time_left
			await _tap(main, KEY_SPACE)
			if not (player.controls_enabled and not site._hud.is_panel_open()):
				push_error("Keyboard round check failed at step %d" % 37)
				return false
			if not (time_left - site._time_left < .1):
				push_error("Keyboard round check failed at step %d" % 38)
				return false
		await _tap(main, KEY_E)
		var hud: Control = site._hud
		if not (hud.is_panel_open() and not player.controls_enabled):
			push_error("Keyboard round check failed at step %d" % 41)
			return false
		if not (await _capture(main, "task_%02d" % (index + 1), level)):
			push_error("Keyboard round check failed at step %d" % 42)
			return false
		if not await _prepare(main, hud, task): return false
		if task.interactionType == "formula-builder":
			for token in task.get("tokenOptions", task.get("parameters", {}).get("formulaTokens", [])):
				if not (await _button(main, str(token))):
					push_error("Keyboard round check failed at step %d" % 45)
					return false
			if not (BANK.validate_choice(task, hud._formula_buffer)):
				push_error("Keyboard round check failed at step %d" % 46)
				return false
			if not (await _button(main, "ПРОВЕРИТЬ  →")):
				push_error("Keyboard round check failed at step %d" % 47)
				return false
		elif task.correctAnswer is Dictionary or task.interactionType in ["oxidation-state", "equation-completion", "equation-balancing", "virtual-mixing", "ionic-equation", "dissociation"]:
			var answer: String = str(task.correctAnswer.value) if task.correctAnswer is Dictionary else str(task.correctAnswer)
			if not await _enter_text(main, answer): return false
		else:
			if not (await _button(main, "", task)):
				push_error("Keyboard round check failed at step %d" % 49)
				return false
		print("KEYBOARD_TASK_SUBMITTED id=", task.id, " completed=", site._completed, " score=", site._score)
		if not (site._completed == index + 1):
			push_error("Keyboard round check failed at step %d" % 50)
			return false
		if not (await _capture(main, "feedback_%02d" % (index + 1), level)):
			push_error("Keyboard round check failed at step %d" % 51)
			return false
		if not (main.get_viewport().gui_get_focus_owner() is Button):
			push_error("Keyboard round check failed at step %d" % 52)
			return false
		await _tap(main, KEY_SPACE)
		if index < 4:
			if not (player.controls_enabled and not hud.is_panel_open()):
				push_error("Keyboard round check failed at step %d" % 55)
				return false
			for step_index in range(route.size() - 1, -1, -1):
				var step: Array = route[step_index]
				var opposite: int = {KEY_A: KEY_D, KEY_D: KEY_A, KEY_W: KEY_S, KEY_S: KEY_W}[step[0]]
				if not (await _walk(main, player, opposite, 0.0, step[2])):
					push_error("Keyboard round check failed at step %d" % 59)
					return false
	if not (site._round_done):
		push_error("Keyboard round check failed at step %d" % 60)
		return false
	var plant = player._foot_plant
	if plant == null or plant.corrected_ticks == 0 or plant.maximum_correction > .06501 or plant.maximum_length_error > .0001 or plant.maximum_height_error > .0001 or plant.maximum_boot_twist > deg_to_rad(65.01):
		push_error("Packaged foot planting was absent or exceeded pose bounds")
		return false
	print("KEYBOARD_FOOT_PLANT_OK corrected_ticks=", plant.corrected_ticks)
	if not (await _capture(main, "results", level)):
		push_error("Keyboard round check failed at step %d" % 61)
		return false
	var progress := SAVE.load_progress(path)
	if not (int(progress.completed_rounds) == 1 and int(progress.unlocked_level) == mini(level + 1, 5)):
		push_error("Keyboard round check failed at step %d" % 63)
		return false
	if not (int(progress.best_score) == site._score and site._score == int({1: 700, 2: 840, 3: 980, 4: 1120, 5: 1260}[level]) and int(progress.best_stars) == 3):
		push_error("Keyboard round check failed at step %d" % 64)
		return false
	await _tap(main, KEY_SPACE)
	if not (main._current is Control):
		push_error("Keyboard round check failed at step %d" % 66)
		return false
	if not (FileAccess.get_sha256(ProjectSettings.globalize_path(SAVE.SAVE_PATH)) == user_hash):
		push_error("Keyboard round check failed at step %d" % 67)
		return false
	main._current.queue_free()
	main.get_node("AudioController").queue_free()
	for frame in range(5): await tree.process_frame
	await tree.create_timer(.8).timeout
	print("KEYBOARD_ROUND_SMOKE_OK level=", level, " completed=5 score=", progress.best_score)
	return true

static func _send(key: int, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = key
	event.physical_keycode = key
	event.pressed = pressed
	Input.parse_input_event(event)

static func _tap(main: Node, key: int) -> void:
	_send(key, true)
	await main.get_tree().process_frame
	_send(key, false)
	for frame in range(3): await main.get_tree().process_frame

static func _walk(main: Node, player: CharacterBody3D, key: int, target: float, axis: String) -> bool:
	_send(key, true)
	var reached := false
	for frame in range(300):
		await main.get_tree().physics_frame
		if not player.controls_enabled:
			var focus := main.get_viewport().gui_get_focus_owner()
			if not (focus is Button and focus.text == "ПРОДОЛЖИТЬ"):
				push_error("Keyboard round check failed at step %d" % 94)
				return false
			print("KEYBOARD_QA_RESUME_FOCUS_PAUSE")
			await _tap(main, KEY_SPACE)
			_send(key, true)
		var current: float = player.position.x if axis == "x" else player.position.z
		if absf(current - target) < .14:
			reached = true
			break
	_send(key, false)
	for frame in range(20): await main.get_tree().physics_frame
	if not reached: push_error("Keyboard route blocked at " + str(player.position))
	return reached

static func _button(main: Node, text: String, task: Dictionary = {}, target: Control = null) -> bool:
	for attempt in range(80):
		var focused := main.get_viewport().gui_get_focus_owner()
		if focused is Button and (focused == target if target != null else (focused.text == text if task.is_empty() else BANK.validate_choice(task, focused.text))) and not focused.disabled:
			await _tap(main, KEY_SPACE)
			return true
		await _tap(main, KEY_TAB)
	push_error("Keyboard focus cannot reach: " + text)
	return false

static func _capture(main: Node, name: String, level: int) -> bool:
	if DisplayServer.get_name() == "headless": return true
	var directory := "user://qa-keyboard-level%d-round" % level
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	for frame in range(4): await main.get_tree().process_frame
	RenderingServer.force_draw(false)
	if not (main.get_viewport().get_texture().get_image().save_png(directory + "/" + name + ".png") == OK):
		push_error("Keyboard round check failed at step %d" % 123)
		return false
	return true

static func _enter_text(main: Node, answer: String) -> bool:
	for attempt in range(80):
		var focus := main.get_viewport().gui_get_focus_owner()
		if focus is LineEdit and focus.editable:
			for character in answer:
				var event := InputEventKey.new()
				event.keycode = character.to_upper().unicode_at(0)
				event.unicode = character.unicode_at(0)
				event.pressed = true
				Input.parse_input_event(event)
				await main.get_tree().process_frame
				event = event.duplicate()
				event.pressed = false
				Input.parse_input_event(event)
				await main.get_tree().process_frame
			if focus.text != answer:
				push_error("Keyboard text mismatch: " + focus.text)
				return false
			await _tap(main, KEY_ENTER)
			return true
		await _tap(main, KEY_TAB)
	push_error("Editable answer input could not be reached")
	return false

static func _prepare(main: Node, hud: Control, task: Dictionary) -> bool:
	var parameters: Dictionary = task.get("parameters", {})
	for child in hud._panel_content.get_children():
		if child.has_method("reveal_next"):
			for step in range(12):
				if child.is_complete(): break
				if not await _button(main, child.get_node("NextButton").text): return false
			if not child.is_complete(): return false
		elif child.has_method("is_mixed"):
			for reagent in parameters.get("mixingReagents", []):
				if not await _button(main, str(reagent)): return false
			if not child.is_mixed(): return false
		elif child.has_method("prepare_sample"):
			if not await _button(main, child.get_node("PrepareButton").text): return false
			var formula := "n = m / M" if parameters.scaleMode == "mass-to-moles" else "m = n · M"
			if not await _button(main, formula): return false
		elif child.has_method("select_volume"):
			if not await _button(main, "%.3f л" % (float(parameters.targetVolumeMl) / 1000.0)): return false
			var formula := "m = C · V · M" if parameters.solutionMode == "mass" else "C₁V₁ = C₂V₂"
			if not await _button(main, formula): return false
		elif child.has_method("inspect_run"):
			for button in child.get_node("RunButtons").get_children():
				if not await _button(main, button.text): return false
		elif child.has_method("read_sample"):
			for button in child._buttons.get_children():
				if not await _button(main, button.text): return false
		elif child.has_method("scan_sample"):
			for row in child.get_node("SampleRows").get_children():
				if not await _button(main, row.get_child(0).text): return false
		elif child.has_method("select_count"):
			for index in range(2):
				var role: String = ["cation", "anion"][index]
				var count: int = int(parameters.dissociationIons[role].count)
				var button: Button = child._rows.get_child(index).get_child(count)
				if not await _button(main, button.text, {}, button): return false
	return true

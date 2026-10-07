extends RefCounted

const SAVE = preload("res://scripts/core/save_data.gd")
const BANK = preload("res://scripts/chemistry/task_bank.gd")
const SAVE_PATH := "user://qa-keyboard-progress.json"
const ROUTES := {
	"substance-storage": [[KEY_A, -3.3, "x"], [KEY_W, -1.7, "z"]],
	"formula-board": [[KEY_W, -3.4, "z"], [KEY_D, 4.35, "x"]],
	"periodic-table-terminal": [[KEY_S, 4.5, "z"], [KEY_D, 4.0, "x"]],
}

static func run(main: Node) -> bool:
	var tree := main.get_tree()
	var user_hash := FileAccess.get_sha256(ProjectSettings.globalize_path(SAVE.SAVE_PATH))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	main.show_menu()
	await tree.process_frame
	var focus := main.get_viewport().gui_get_focus_owner()
	if not (focus is Button and focus.text.begins_with("КАРЬЕРА")):
		push_error("Keyboard round check failed at step %d" % 19)
		return false
	await _tap(main, KEY_SPACE)
	var site: Node = main._current
	if not (site is Node3D and site.save_path == SAVE_PATH):
		push_error("Keyboard round check failed at step %d" % 22)
		return false
	var player: CharacterBody3D = site._player
	for index in range(5):
		var task: Dictionary = site._tasks[site._task_index]
		if not (ROUTES.has(task.station)):
			push_error("Keyboard round check failed at step %d" % 26)
			return false
		var route: Array = ROUTES[task.station]
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
		if not (await _capture(main, "task_%02d" % (index + 1))):
			push_error("Keyboard round check failed at step %d" % 42)
			return false
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
		else:
			if not (await _button(main, "", task)):
				push_error("Keyboard round check failed at step %d" % 49)
				return false
		if not (site._completed == index + 1):
			push_error("Keyboard round check failed at step %d" % 50)
			return false
		if not (await _capture(main, "feedback_%02d" % (index + 1))):
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
	if not (await _capture(main, "results")):
		push_error("Keyboard round check failed at step %d" % 61)
		return false
	var progress := SAVE.load_progress(SAVE_PATH)
	if not (int(progress.completed_rounds) == 1 and int(progress.unlocked_level) == 2):
		push_error("Keyboard round check failed at step %d" % 63)
		return false
	if not (int(progress.best_score) == site._score and site._score == 700 and int(progress.best_stars) == 3):
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
	print("KEYBOARD_ROUND_SMOKE_OK completed=5 score=", progress.best_score)
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

static func _button(main: Node, text: String, task: Dictionary = {}) -> bool:
	for attempt in range(80):
		var focused := main.get_viewport().gui_get_focus_owner()
		if focused is Button and (focused.text == text if task.is_empty() else BANK.validate_choice(task, focused.text)) and not focused.disabled:
			await _tap(main, KEY_SPACE)
			return true
		await _tap(main, KEY_TAB)
	push_error("Keyboard focus cannot reach: " + text)
	return false

static func _capture(main: Node, name: String) -> bool:
	if DisplayServer.get_name() == "headless": return true
	var directory := "user://qa-keyboard-round"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	for frame in range(4): await main.get_tree().process_frame
	await RenderingServer.frame_post_draw
	if not (main.get_viewport().get_texture().get_image().save_png(directory + "/" + name + ".png") == OK):
		push_error("Keyboard round check failed at step %d" % 123)
		return false
	return true

extends RefCounted

const BANK = preload("res://scripts/chemistry/task_bank.gd")
const SAVE = preload("res://scripts/core/save_data.gd")
const PATH := "user://practice-levels-smoke-progress.json"

static func run(main: Node) -> bool:
	var tree := main.get_tree()
	var menu := (load("res://scenes/ui/main_menu.tscn") as PackedScene).instantiate()
	menu.save_path = PATH
	tree.root.add_child(menu)
	var selections: Array[Dictionary] = []
	menu.topics_requested.connect(func(topics: Array) -> void: selections.append({"topics": topics}))
	var duplicate_buttons: Array[Button] = []
	var other_button: Button
	var begin_button: Button
	for button in menu.find_children("*", "Button", true, false):
		if button.text == "НАЧАТЬ ТРЕНИРОВКУ": begin_button = button
		if not button.has_meta("practice_topic"): continue
		if button.get_meta("practice_topic") == "Окисление и восстановление":
			duplicate_buttons.append(button)
		else:
			other_button = button
	if duplicate_buttons.size() != 2 or other_button == null or begin_button == null:
		return _fail("Duplicate-topic regression fixture missing")
	duplicate_buttons[0].button_pressed = true
	if not duplicate_buttons[1].button_pressed or begin_button.disabled:
		return _fail("Repeated topic selection did not synchronize")
	begin_button.pressed.emit()
	if selections.back().topics != ["Окисление и восстановление"]:
		return _fail("Repeated topic emitted duplicate selections")
	other_button.button_pressed = true
	duplicate_buttons[1].button_pressed = false
	if duplicate_buttons[0].button_pressed or begin_button.disabled:
		return _fail("Repeated topic deselection lost another selection")
	begin_button.pressed.emit()
	if selections.back().topics != [other_button.get_meta("practice_topic")]:
		return _fail("Repeated topic deselection retained stale selection")
	other_button.button_pressed = false
	if not begin_button.disabled: return _fail("Empty practice selection remained enabled")
	print("PRACTICE_DUPLICATE_TOPIC_OK synchronized=2 unique_selection, independent_deselection")
	var keys: Array[String] = []
	for button in menu.find_children("*", "Button", true, false):
		if not button.has_meta("practice_level"): continue
		button.button_pressed = true
		for begin in menu.find_children("*", "Button", true, false):
			if begin.text == "НАЧАТЬ ТРЕНИРОВКУ": begin.pressed.emit()
		if selections.is_empty() or selections.back().topics != [button.get_meta("practice_topic")]:
			return _fail("Practice menu binding mismatch")
		var selection := {"level":button.get_meta("practice_level"), "topic":button.get_meta("practice_topic")}
		button.button_pressed = false
		keys.append("%d:%s" % [selection.level, selection.topic])
	var expected: Array[String] = []
	for level in range(1, 6):
		for task in BANK.load_verified_tasks(level):
			var key := "%d:%s" % [level, task.topic]
			if not expected.has(key): expected.append(key)
	keys.sort()
	expected.sort()
	if keys != expected: return _fail("Practice menu omits or duplicates verified topics")
	menu.queue_free()
	await tree.process_frame
	var original_hash := FileAccess.get_sha256(ProjectSettings.globalize_path(SAVE.SAVE_PATH))
	var test_hash := FileAccess.get_sha256(ProjectSettings.globalize_path(PATH))
	for level in range(1, 6):
		var topic: String = BANK.load_verified_tasks(level)[0].topic
		main.start_game("practice", topic, level, PATH)
		var site: Node3D = main._current
		var starting_time: float = site._time_left
		if site._tasks.is_empty(): return _fail("Practice level has no tasks")
		for task in site._tasks:
			if task.level != level or task.topic != topic: return _fail("Practice task escaped selected level/topic")
		var target: int = site._target_count
		for index in range(target):
			var task: Dictionary = site._tasks[site._task_index]
			var correct: Variant = task.correctAnswer
			var answer := str(correct.get("value", "")) if correct is Dictionary else str(correct)
			if not BANK.validate_choice(task, answer): return _fail("Practice answer fixture invalid: " + str(task.id))
			site._active_station = task.station
			site._submit_answer(answer)
			site._resume()
		if not site._round_done or site._completed != target or site._time_left != starting_time:
			return _fail("Practice did not finish without timer")
		print("PRACTICE_LEVEL_OK level=", level, " completed=", target)
		site.queue_free()
		await tree.process_frame
	if original_hash != FileAccess.get_sha256(ProjectSettings.globalize_path(SAVE.SAVE_PATH)) or test_hash != FileAccess.get_sha256(ProjectSettings.globalize_path(PATH)):
		return _fail("Practice changed career progress")
	print("PRACTICE_LEVELS_SMOKE_OK topics=", keys.size(), " levels=5")
	main.show_menu()
	main.get_node("AudioController").queue_free()
	await tree.create_timer(.8).timeout
	return true

static func _fail(message: String) -> bool:
	push_error(message)
	return false

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
	menu.start_requested.connect(func(mode: String, topic: String, level: int) -> void: selections.append({"mode": mode, "topic": topic, "level": level}))
	var keys: Array[String] = []
	for button in menu.find_children("*", "Button", true, false):
		if not button.has_meta("practice_level"): continue
		button.pressed.emit()
		var selection: Dictionary = selections.back()
		if selection.mode != "practice" or selection.level != button.get_meta("practice_level") or selection.topic != button.get_meta("practice_topic"):
			return _fail("Practice menu binding mismatch")
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

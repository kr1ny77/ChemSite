extends RefCounted
const SAVE = preload("res://scripts/core/save_data.gd")
const COURSE = preload("res://scripts/chemistry/course_catalog.gd")
const UI = preload("res://scripts/qa/export_round_smoke.gd")
const PATH := "user://qa-course-rounds-isolated.json"
static func run(main: Node) -> bool:
	var hash_before := FileAccess.get_sha256(SAVE.SAVE_PATH)
	DirAccess.remove_absolute(PATH)
	for chapter in COURSE.chapters():
		main.start_game("career", "", int(chapter.environment), PATH, int(chapter.id))
		var site: Node = main._current
		await main.get_tree().process_frame
		for index in range(5):
			var task: Dictionary = site._tasks[site._task_index]
			var station: Dictionary = site._stations().filter(func(entry: Dictionary) -> bool: return entry.id == task.station)[0]
			site._player.global_position = station.position + Vector3(0, 0.05, 1.8)
			site._find_nearest_station()
			var interact := InputEventAction.new()
			interact.action = "interact"
			interact.pressed = true
			site._unhandled_input(interact)
			if not site._hud.is_panel_open() or not UI._answer_through_ui(site._hud, task): return false
			if site._completed != index + 1: return false
			site._resume()
		if not site._round_done: return false
		var progress := SAVE.load_progress(PATH)
		if progress.chapter_records[str(int(chapter.id))].correct != 5: return false
		if progress.unlocked_chapter != mini(13, int(chapter.id) + 1): return false
		# Reload the same chapter and verify the completed five are excluded.
		var previous: Array = site._tasks.slice(0, 5).map(func(task: Dictionary) -> String: return str(task.id))
		main.start_game("career", "", int(chapter.environment), PATH, int(chapter.id))
		for task in main._current._tasks:
			if task.id in previous: return false
		print("COURSE_ROUND_OK chapter=", int(chapter.id))
	main.start_game("practice", "", 5, PATH, 0, ["Строение атома", "Химия цемента"])
	var practice: Node = main._current
	for index in range(5):
		var task: Dictionary = practice._tasks[practice._task_index]
		practice._hud.show_task(task, task.station)
		if not UI._answer_through_ui(practice._hud, task): return false
		practice._resume()
	if not practice._round_done or SAVE.load_progress(PATH).career_answered_ids.size() != 65: return false
	if FileAccess.get_sha256(SAVE.SAVE_PATH) != hash_before: return false
	DirAccess.remove_absolute(PATH)
	main.show_menu()
	main.get_node("AudioController").queue_free()
	for frame in range(5): await main.get_tree().process_frame
	await main.get_tree().create_timer(0.8).timeout
	print("COURSE_ROUNDS_SMOKE_OK version=", ProjectSettings.get_setting("application/config/version"), " chapters=13 answers=65 practice=5")
	return true

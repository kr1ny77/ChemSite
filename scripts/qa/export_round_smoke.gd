extends RefCounted

static func run(main: Node) -> bool:
	var save_path := "user://export-round-smoke-progress.json"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
	main.start_game("career", "")
	var site: Node3D = main._current
	var audio: Node = main.get_node("AudioController")
	site.disconnect("feedback_given", audio.play_feedback)
	site.disconnect("station_used", audio.play_interact)
	site.save_path = save_path
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
		var station: Dictionary = site.STATION_CONFIG.filter(func(entry: Dictionary) -> bool: return entry.id == task.station)[0]
		player.global_position = station.position + Vector3(0, 0.05, 1.8)
		site._find_nearest_station()
		site._unhandled_input(interact)
		if not hud.is_panel_open():
			push_error("Export smoke: station panel failed at task %d" % index)
			return false
		site._submit_answer(str(task.correctAnswer))
		if site._completed != index + 1:
			push_error("Export smoke: task completion failed at %d" % index)
			return false
		if index < 4:
			site._resume()
	var progress: Dictionary = load("res://scripts/core/save_data.gd").load_progress(save_path)
	var passed: bool = site._round_done and site._score == 700 and int(progress.best_stars) == 3 and int(progress.completed_rounds) == 1
	DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
	if passed:
		print("CHEMSITE_EXPORT_ROUND_SMOKE_OK")
	else:
		push_error("Export smoke: results or save are invalid")
	return passed

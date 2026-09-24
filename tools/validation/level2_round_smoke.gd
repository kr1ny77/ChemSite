extends SceneTree

const SAVE_DATA = preload("res://scripts/core/save_data.gd")
const TEST_PATH := "user://level2-round-smoke.json"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	site.level = 2
	site.save_path = TEST_PATH
	root.add_child(site)
	await process_frame
	assert(site._tasks.size() == 39, "Level 2 task selection is incomplete")
	assert(site._stations().size() == 4, "Level 2 station set is incomplete")
	var player := site.get_node("Player") as CharacterBody3D
	var hud := site.get_node("CanvasLayer/GameHud") as Control
	var interact := InputEventAction.new()
	interact.action = "interact"
	interact.pressed = true
	var used_stations: Array[String] = []
	for index in range(5):
		var task: Dictionary = site._tasks[site._task_index]
		var matching: Array = site._stations().filter(func(station: Dictionary) -> bool: return station.id == task.station)
		assert(matching.size() == 1, "Task station unavailable: " + str(task.id))
		var station: Dictionary = matching[0]
		if not used_stations.has(str(station.id)):
			used_stations.append(str(station.id))
		player.global_position = station.position + Vector3(0, 0.05, 1.8)
		site._find_nearest_station()
		assert(site._nearest_station.get("id", "") == station.id, "Station proximity failed: " + str(station.id))
		site._unhandled_input(interact)
		assert(hud.is_panel_open() and site._active_station == task.station, "Interaction failed: " + str(task.id))
		site._submit_answer(str(task.correctAnswer))
		assert(site._completed == index + 1, "Correct Level 2 answer rejected: " + str(task.id))
		site._resume()
	assert(site._round_done and site._completed == 5, "Level 2 round did not finish")
	assert(used_stations.size() >= 3, "Round did not alternate station types")
	var progress: Dictionary = SAVE_DATA.load_progress(TEST_PATH)
	assert(int(progress.completed_rounds) == 1 and int(progress.total_xp) == 250, "Level 2 progress not saved")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))
	site.queue_free()
	await process_frame
	print("CHEMSITE_LEVEL2_ROUND_OK: %d stations" % used_stations.size())
	quit()

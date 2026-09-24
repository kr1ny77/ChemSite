extends SceneTree

const SAVE_DATA = preload("res://scripts/core/save_data.gd")
const TEST_PATH := "user://round-smoke-progress.json"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	site.save_path = TEST_PATH
	root.add_child(site)
	await process_frame
	var player := site.get_node("Player") as CharacterBody3D
	var hud := site.get_node("CanvasLayer/GameHud") as Control
	var interact := InputEventAction.new()
	interact.action = "interact"
	interact.pressed = true
	for i in range(5):
		var task: Dictionary = site._tasks[site._task_index]
		var station: Dictionary = site.STATION_CONFIG.filter(func(entry: Dictionary) -> bool: return entry.id == task.station)[0]
		player.global_position = station.position + Vector3(0, 0.05, 1.8)
		site._find_nearest_station()
		site._unhandled_input(interact)
		assert(hud.is_panel_open(), "Task panel did not open at task %d" % i)
		site._submit_answer(str(task.correctAnswer))
		assert(site._completed == i + 1, "Task did not complete")
		if i < 4:
			site._resume()
	assert(site._round_done and site._score == 700 and site._streak == 5, "Round results or combo scoring are invalid")
	assert(hud.is_panel_open() and not player.controls_enabled, "Result panel state is invalid")
	var progress: Dictionary = SAVE_DATA.load_progress(TEST_PATH)
	assert(progress.best_score == 700 and progress.best_stars == 3 and progress.total_xp == 250 and progress.completed_rounds == 1)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))
	site.queue_free()
	await process_frame
	await create_timer(0.1).timeout
	print("CHEMSITE_ROUND_SMOKE_OK")
	quit()

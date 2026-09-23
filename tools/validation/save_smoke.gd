extends SceneTree

const SAVE_DATA = preload("res://scripts/core/save_data.gd")
const TEST_PATH := "user://progress-smoke.json"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))
	var initial: Dictionary = SAVE_DATA.load_progress(TEST_PATH)
	assert(initial.best_score == 0 and initial.total_xp == 0 and initial.completed_rounds == 0)
	assert(SAVE_DATA.record_round(300, 3, TEST_PATH) == OK)
	assert(SAVE_DATA.record_round(200, 2, TEST_PATH) == OK)
	var saved: Dictionary = SAVE_DATA.load_progress(TEST_PATH)
	assert(saved.best_score == 300)
	assert(saved.total_xp == 250)
	assert(saved.completed_rounds == 2)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))
	print("SAVE SMOKE PASS")
	quit()

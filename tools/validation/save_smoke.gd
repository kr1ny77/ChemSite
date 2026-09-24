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
	var legacy_file := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	legacy_file.store_string('{"save_version":1,"best_score":420,"total_xp":100,"completed_rounds":2}')
	legacy_file.close()
	var migrated: Dictionary = SAVE_DATA.load_progress(TEST_PATH)
	assert(migrated.save_version == 3 and migrated.best_score == 420 and migrated.best_stars == 0 and migrated.topic_mastery.is_empty())
	var version_two := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	version_two.store_string('{"save_version":2,"best_score":540,"best_stars":2,"total_xp":200,"completed_rounds":3}')
	version_two.close()
	var migrated_two: Dictionary = SAVE_DATA.load_progress(TEST_PATH)
	assert(migrated_two.save_version == 3 and migrated_two.best_score == 540 and migrated_two.best_stars == 2 and migrated_two.topic_mastery.is_empty())
	var file := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	file.store_string("{bad data")
	file.close()
	var recovered: Dictionary = SAVE_DATA.load_progress(TEST_PATH)
	assert(recovered.best_score == 0 and recovered.total_xp == 0)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))
	print("SAVE SMOKE PASS")
	quit()

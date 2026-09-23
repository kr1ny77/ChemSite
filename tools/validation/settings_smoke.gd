extends SceneTree

const SETTINGS_DATA = preload("res://scripts/core/settings_data.gd")
const TEST_PATH := "user://settings-smoke.json"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))
	var defaults: Dictionary = SETTINGS_DATA.load_settings(TEST_PATH)
	assert(defaults.music_volume == 0.7 and defaults.sfx_volume == 0.8)
	assert(SETTINGS_DATA.save_settings({"music_volume": 0.25, "sfx_volume": 0.0}, TEST_PATH) == OK)
	var saved: Dictionary = SETTINGS_DATA.load_settings(TEST_PATH)
	assert(saved.music_volume == 0.25 and saved.sfx_volume == 0.0)
	var file := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	file.store_string("{bad data")
	file.close()
	var recovered: Dictionary = SETTINGS_DATA.load_settings(TEST_PATH)
	assert(recovered.music_volume == 0.7 and recovered.sfx_volume == 0.8)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))
	print("SETTINGS SMOKE PASS")
	quit()

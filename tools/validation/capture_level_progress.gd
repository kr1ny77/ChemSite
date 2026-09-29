extends SceneTree

const SAVE_DATA = preload("res://scripts/core/save_data.gd")
const TEST_PATH := "user://level-progress-visual.json"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))
	for level in range(1, 6):
		assert(SAVE_DATA.record_round(500 + level * 25, 5, TEST_PATH, level) == OK)
	var menu := (load("res://scenes/ui/main_menu.tscn") as PackedScene).instantiate()
	menu.save_path = TEST_PATH
	root.add_child(menu)
	for frame in range(5):
		await process_frame
	for child in menu._menu_content.get_children():
		if child is Button and "УРОВЕНЬ" in child.text:
			assert("★" in child.text and "→" in child.text, "Level record missing from menu: " + child.text)
	assert(root.get_viewport().get_texture().get_image().save_png("res://artifacts/level_progress_menu.png") == OK)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))
	print("LEVEL_PROGRESS_VISUAL_OK")
	quit()

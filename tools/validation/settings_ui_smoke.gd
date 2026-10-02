extends SceneTree

const MENU = preload("res://scenes/ui/main_menu.tscn")
const SETTINGS = preload("res://scripts/core/settings_data.gd")
const SETTINGS_PATH := "user://settings-ui-smoke.json"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SETTINGS_PATH))
	var menu := MENU.instantiate()
	menu.settings_path = SETTINGS_PATH
	root.add_child(menu)
	await process_frame
	var motion_button: Button
	for button in menu.find_children("*", "Button", true, false):
		if button.text.begins_with("МЕНЬШЕ ДВИЖЕНИЯ"):
			motion_button = button
			break
	assert(motion_button != null)
	assert(not SETTINGS.load_settings(SETTINGS_PATH).reduced_motion)
	motion_button.button_pressed = true
	assert(SETTINGS.load_settings(SETTINGS_PATH).reduced_motion)
	assert(motion_button.text.ends_with("ВКЛ"))
	motion_button.button_pressed = false
	assert(not SETTINGS.load_settings(SETTINGS_PATH).reduced_motion)
	assert(motion_button.text.ends_with("ВЫКЛ"))
	menu.queue_free()
	await process_frame
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SETTINGS_PATH))
	print("SETTINGS_UI_SMOKE_OK")
	quit()

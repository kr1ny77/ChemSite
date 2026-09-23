extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var menu := (load("res://scenes/ui/main_menu.tscn") as PackedScene).instantiate()
	root.add_child(menu)
	await process_frame
	for button in menu.find_children("*", "Button", true, false):
		if button.text == "НАСТРОЙКИ":
			button.pressed.emit()
			break
	await process_frame
	var image := root.get_viewport().get_texture().get_image()
	var error := image.save_png("res://artifacts/godot-settings.png")
	print("SETTINGS_CAPTURE_RESULT ", error, " ", image.get_width(), "x", image.get_height())
	var escape := InputEventAction.new()
	escape.action = "ui_cancel"
	escape.pressed = true
	menu._unhandled_input(escape)
	assert(not menu._settings_panel.visible and menu._menu_content.visible)
	quit()

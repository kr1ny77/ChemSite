extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var menu := (load("res://scenes/ui/main_menu.tscn") as PackedScene).instantiate()
	root.add_child(menu)
	await process_frame
	menu._practice_button.pressed.emit()
	await process_frame
	var image := root.get_viewport().get_texture().get_image()
	assert(image.save_png("res://artifacts/practice-menu.png") == OK)
	print("PRACTICE_MENU_CAPTURE_OK")
	quit()

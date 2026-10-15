extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _capture(path: String) -> void:
	await process_frame
	await process_frame
	RenderingServer.force_draw(false)
	root.get_texture().get_image().save_png(path)
func _run() -> void:
	root.size = Vector2i(1440, 900)
	root.content_scale_size = Vector2i(1440, 900)
	DirAccess.make_dir_recursive_absolute("res://artifacts/course-ui")
	var menu := preload("res://scenes/ui/main_menu.tscn").instantiate()
	root.add_child(menu)
	await _capture("res://artifacts/course-ui/menu.png")
	menu._menu_content.hide()
	menu._practice_panel.show()
	await _capture("res://artifacts/course-ui/topics.png")
	menu.queue_free()
	await process_frame
	var hud := preload("res://scenes/ui/game_hud.tscn").instantiate()
	root.add_child(hud)
	var tasks := preload("res://scripts/chemistry/task_bank.gd").load_verified_tasks(3)
	hud.show_task(tasks[70], str(tasks[70].station))
	await _capture("res://artifacts/course-ui/task.png")
	var materials := preload("res://scripts/ui/learning_materials.gd").new()
	hud.add_child(materials)
	await _capture("res://artifacts/course-ui/periodic.png")
	materials._display(2)
	await _capture("res://artifacts/course-ui/solutions.png")
	materials._display(7)
	await _capture("res://artifacts/course-ui/corrosion-photo.png")
	materials._display(8)
	await _capture("res://artifacts/course-ui/concrete-photo.png")
	materials._display(materials._catalog.size())
	await _capture("res://artifacts/course-ui/workbench.png")
	materials.queue_free()
	await process_frame
	hud.show_feedback(false, tasks[70])
	for child in hud._panel_content.get_children():
		if child is Button and child.text == "РЕШЕНИЕ ПО ШАГАМ": child.button_pressed = true
	await _capture("res://artifacts/course-ui/worked.png")
	hud.show_course_complete()
	await _capture("res://artifacts/course-ui/exhausted.png")
	print("COURSE_UI_CAPTURE_OK")
	quit()

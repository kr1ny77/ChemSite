extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	root.add_child(site)
	for frame in range(10):
		await process_frame
	var task: Dictionary = site._tasks[0]
	site._hud.show_task(task, str(task.station))
	for frame in range(5):
		await process_frame
	var path := "res://artifacts/visual-overhaul-task.png"
	assert(root.get_viewport().get_texture().get_image().save_png(path) == OK)
	print("VISUAL_OVERHAUL_CAPTURE_OK: ", path)
	quit()

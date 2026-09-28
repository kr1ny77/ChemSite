extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	site.level = 5
	root.add_child(site)
	for frame in range(12):
		await process_frame
	var capture := root.get_viewport().get_texture().get_image()
	assert(capture.save_png("res://artifacts/level5_site.png") == OK)
	print("LEVEL5_SITE_CAPTURE_OK")
	quit()

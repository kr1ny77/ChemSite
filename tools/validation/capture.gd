extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene := load("res://scenes/levels/construction_site.tscn") as PackedScene
	var site := scene.instantiate()
	root.add_child(site)
	for i in range(12):
		await process_frame
	var image := root.get_viewport().get_texture().get_image()
	var error := image.save_png("res://artifacts/godot-site.png")
	print("CAPTURE_RESULT ", error, " ", image.get_width(), "x", image.get_height())
	quit()

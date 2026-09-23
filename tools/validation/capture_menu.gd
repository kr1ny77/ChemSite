extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var scene := load("res://scenes/ui/main_menu.tscn") as PackedScene
	root.add_child(scene.instantiate())
	for i in range(4): await process_frame
	var image := root.get_viewport().get_texture().get_image()
	print("MENU_CAPTURE ", image.save_png("res://artifacts/godot-menu-render.png"))
	quit()

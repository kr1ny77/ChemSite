extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	root.add_child(site)
	var player := site.get_node("Player") as CharacterBody3D
	player.global_position = Vector3(-6, .05, -1.6)
	site._find_nearest_station()
	var event := InputEventAction.new(); event.action = "interact"; event.pressed = true
	site._unhandled_input(event)
	for i in range(5): await process_frame
	var image := root.get_viewport().get_texture().get_image()
	print("PANEL_CAPTURE ", image.save_png("res://artifacts/godot-station-panel.png"))
	quit()

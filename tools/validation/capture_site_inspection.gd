extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	root.add_child(site)
	var longest := OS.get_cmdline_user_args().has("--longest")
	var entry: Dictionary = site._site_inspections[2] if longest else site._site_inspections[0]
	var player := site.get_node("Player") as CharacterBody3D
	player.global_position = entry.position + Vector3(0, 0.05, 0)
	site._find_nearest_station()
	var interact := InputEventAction.new()
	interact.action = "interact"
	interact.pressed = true
	site._unhandled_input(interact)
	assert((site.get_node("CanvasLayer/GameHud") as Control).is_panel_open())
	for frame in range(8):
		await process_frame
	await RenderingServer.frame_post_draw
	var path := "res://artifacts/site-inspection-long.png" if longest else "res://artifacts/site-inspection.png"
	assert(root.get_viewport().get_texture().get_image().save_png(path) == OK)
	print("SITE_INSPECTION_CAPTURE_OK")
	quit()

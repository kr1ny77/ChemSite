extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	root.add_child(site)
	await process_frame
	site._active_station = "substance-storage"
	site._submit_answer("сульфат бария")
	site._resume()
	await create_timer(0.18).timeout
	await process_frame
	var image := root.get_viewport().get_texture().get_image()
	assert(image.save_png("res://artifacts/station-pulse.png") == OK)
	await create_timer(0.6).timeout
	assert(site.find_children("*", "Node3D", true, false).filter(func(node: Node) -> bool: return node.get_script() == preload("res://scripts/effects/station_pulse.gd")).is_empty(), "Station pulse did not clean up")
	print("STATION_PULSE_CAPTURE_OK")
	quit()

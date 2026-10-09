extends SceneTree

const CASES := [
	{"name": "right-edge", "player": Vector3(-9, 0.04, 7), "station": "formula-board"},
	{"name": "top-edge", "player": Vector3(9, 0.04, 7), "station": "substance-storage"},
	{"name": "bottom-edge", "player": Vector3(-9, 0.04, -7), "station": "periodic-table-terminal"},
	{"name": "visible", "player": Vector3.ZERO, "station": "substance-storage"},
]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	site.save_path = "user://station-edge-capture-isolated.json"
	root.add_child(site)
	await process_frame
	# This capture controls camera placement; desktop focus is covered separately.
	site.get_window().focus_exited.disconnect(site._pause_on_focus_loss)
	site.set_process(false)
	site._player.set_physics_process(false)
	site._wayfinder.reduced_motion = true
	var suffix := "baseline" if OS.get_cmdline_user_args().has("--baseline") else "final"
	var folder := "res://artifacts/station-edge-" + suffix
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	for entry in CASES:
		site._player.global_position = entry.player
		site._player.reset_physics_interpolation()
		site._camera_rig.global_position = entry.player * Vector3(.6, 0, .6)
		for index in range(site._tasks.size()):
			if site._tasks[index].station == entry.station:
				site._task_index = index
				break
		site._update_hud()
		await process_frame
		await process_frame
		RenderingServer.force_draw()
		if root.get_texture().get_image().save_png(folder + "/" + entry.name + ".png") != OK:
			push_error("Station edge image write failed")
			quit(1)
			return
	site.queue_free()
	await process_frame
	print("STATION_EDGE_CAPTURE_OK ", suffix)
	quit()

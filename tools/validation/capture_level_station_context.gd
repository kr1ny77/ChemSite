extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var folder := "res://artifacts/level-station-context"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	var captures := 0
	for level in range(1, 6):
		var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
		site.level = level
		site.save_path = "user://level-station-context-isolated.json"
		root.add_child(site)
		await process_frame
		site.get_window().focus_exited.disconnect(site._pause_on_focus_loss)
		site.set_process(false)
		site._player.set_physics_process(false)
		site._wayfinder.reduced_motion = true
		site.get_node("CameraRig/PlayerVisibility").reduced_motion = true
		for station in site._stations():
			var found := false
			for index in range(site._tasks.size()):
				if site._tasks[index].station == station.id:
					site._task_index = index
					found = true
					break
			if not found:
				push_error("Station has no curated contextual task: " + str(station.id))
				quit(1)
				return
			# Match the endpoints exercised by the existing traversal gates.
			var approach := Vector3(4.0, .04, 4.5)
			if station.position.z < -2.0:
				approach = Vector3(-3.3, .04, -1.7) if station.position.x < 0 else Vector3(4.35, .04, -3.4)
			elif station.position.x < 0:
				approach = Vector3(-4.1, .04, 0)
			site._player.global_position = approach
			site._player.reset_physics_interpolation()
			site._camera_rig.global_position = site._player.global_position * Vector3(.6, 0, .6)
			site._find_nearest_station()
			site._update_hud()
			if site._nearest_station.get("id", "") != station.id:
				push_error("Context capture approach is outside station reach: " + str(station.id))
				quit(1)
				return
			await process_frame
			await process_frame
			RenderingServer.force_draw()
			var path := folder + "/level-%d-%s.png" % [level, station.id]
			if root.get_texture().get_image().save_png(path) != OK:
				push_error("Station context image write failed")
				quit(1)
				return
			captures += 1
			site._hud.show_task(site._tasks[site._task_index], station.id)
			if not site._hud.is_panel_open():
				push_error("Context station interaction failed to open task")
				quit(1)
				return
			site._hud.close_panel()
		site.queue_free()
		await process_frame
	print("LEVEL_STATION_CONTEXT_CAPTURE_OK captures=", captures)
	quit()

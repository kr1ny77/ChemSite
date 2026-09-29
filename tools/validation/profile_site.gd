extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	if OS.get_cmdline_user_args().has("--uncapped"):
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		Engine.max_fps = 0
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	root.add_child(site)
	await _measure("exploration")
	var task: Dictionary = site._tasks[0]
	var station: Dictionary = site.STATION_CONFIG.filter(func(entry: Dictionary) -> bool: return entry.id == task.station)[0]
	site._player.global_position = station.position + Vector3(0, 0.05, 1.8)
	site._hud.show_task(task, str(task.station))
	await _measure("task_panel")
	quit()

func _measure(label: String) -> void:
	for frame in range(120):
		await process_frame
	var fps_samples: Array[float] = []
	var draw_samples: Array[float] = []
	var frame_samples: Array[float] = []
	var wall_samples: Array[float] = []
	var previous_usec := Time.get_ticks_usec()
	for frame in range(360):
		await process_frame
		var current_usec := Time.get_ticks_usec()
		wall_samples.append(float(current_usec - previous_usec) / 1000.0)
		previous_usec = current_usec
		fps_samples.append(Performance.get_monitor(Performance.TIME_FPS))
		draw_samples.append(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
		frame_samples.append(Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0)
	fps_samples.sort()
	draw_samples.sort()
	frame_samples.sort()
	wall_samples.sort()
	print("CHEMSITE_SITE_PROFILE %s fps_median=%.1f fps_p10=%.1f frame_ms_p90=%.2f frame_ms_p99=%.2f draw_calls_median=%.0f process_ms_p90=%.2f nodes=%.0f static_mb=%.1f" % [label, fps_samples[180], fps_samples[36], wall_samples[324], wall_samples[356], draw_samples[180], frame_samples[324], Performance.get_monitor(Performance.OBJECT_NODE_COUNT), Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0])

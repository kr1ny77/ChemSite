extends SceneTree

const BANK = preload("res://scripts/chemistry/task_bank.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	site.level = 4
	site.save_path = "user://capture-comparison-visual-progress.json"
	root.add_child(site)
	site._player.controls_enabled = false
	var thermal := OS.get_cmdline_user_args().has("--thermal")
	var directory := "res://artifacts/thermal-vfx" if thermal else "res://artifacts/comparison-vfx"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	var tasks: Array[Dictionary] = BANK.load_verified_tasks(4)
	for static_motion in [false, true]:
		for identifier in (["L4-133", "L4-143", "L4-144"] if thermal else ["L4-147", "L4-155", "L4-157", "L4-158"]):
			var task: Dictionary = tasks.filter(func(value): return value.id == identifier)[0]
			site._tasks = [task]
			site._task_index = 0
			site._hud.reduced_motion = static_motion
			site._update_hud()
			site._hud.show_task(task, task.station)
			var comparison: Control = site._hud._comparison_view
			var suffix := "-reduced" if static_motion else "-normal"
			if not await _capture(directory + "/" + identifier + suffix + "-unread.png"): return
			comparison.inspect_run(0)
			if not await _capture(directory + "/" + identifier + suffix + "-partial.png"): return
			comparison.inspect_run(1)
			for frame in range(78): await process_frame
			if not await _capture(directory + "/" + identifier + suffix + "-read.png"): return
	site.queue_free()
	for frame in range(5): await process_frame
	print("COMPARISON_VISUAL_CAPTURE_OK")
	quit()

func _capture(path: String) -> bool:
	for frame in range(5): await process_frame
	RenderingServer.force_draw(false)
	if root.get_texture().get_image().save_png(path) != OK:
		quit(1)
		return false
	return true

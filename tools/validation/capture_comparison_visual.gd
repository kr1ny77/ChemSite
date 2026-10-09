extends SceneTree

const BANK = preload("res://scripts/chemistry/task_bank.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	var hydrolysis := OS.get_cmdline_user_args().has("--hydrolysis")
	site.level = 3 if hydrolysis else 4
	site.save_path = "user://capture-comparison-visual-progress.json"
	root.add_child(site)
	site._player.controls_enabled = false
	var corrosion := OS.get_cmdline_user_args().has("--corrosion-extended")
	var kinetics := OS.get_cmdline_user_args().has("--kinetics")
	var thermal := OS.get_cmdline_user_args().has("--thermal")
	var directory := "res://artifacts/comparison-vfx"
	var identifiers := ["L4-147", "L4-155", "L4-157", "L4-158"]
	if corrosion:
		directory = "res://artifacts/corrosion-extended-vfx"
		identifiers = ["L4-138", "L4-153", "L4-154", "L4-156", "L4-159"]
	elif kinetics:
		directory = "res://artifacts/kinetics-vfx"
		identifiers = ["L4-131", "L4-132", "L4-134", "L4-135"]
	elif hydrolysis:
		directory = "res://artifacts/hydrolysis-vfx"
		identifiers = ["L3-117", "L3-118", "L3-119"]
	elif thermal:
		directory = "res://artifacts/thermal-vfx"
		identifiers = ["L4-133", "L4-143", "L4-144"]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	var tasks: Array[Dictionary] = BANK.load_verified_tasks(site.level)
	for static_motion in [false, true]:
		for identifier in identifiers:
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
	RenderingServer.force_draw()
	if root.get_texture().get_image().save_png(path) != OK:
		quit(1)
		return false
	return true

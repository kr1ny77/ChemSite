extends SceneTree

const TASK_BANK = preload("res://scripts/chemistry/task_bank.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	site.level = 3
	root.add_child(site)
	var hud: Control = site.get_node("CanvasLayer/GameHud")
	for identifier in ["L3-095", "L3-097"]:
		var task: Dictionary = TASK_BANK.load_verified_tasks(3).filter(func(entry: Dictionary) -> bool: return entry.id == identifier)[0]
		site._tasks = [task]
		site._task_index = 0
		site._update_hud()
		hud.show_task(task, str(task.station))
		for frame in range(5):
			await process_frame
		assert(root.get_viewport().get_texture().get_image().save_png("res://artifacts/%s_solution_start.png" % identifier) == OK)
		var setup: VBoxContainer = hud._solution_view
		setup.select_volume(float(task.parameters.targetVolumeMl) / 1000.0)
		setup.select_formula("m = C · V · M" if task.parameters.solutionMode == "mass" else "C₁V₁ = C₂V₂")
		for frame in range(5):
			await process_frame
		assert(root.get_viewport().get_texture().get_image().save_png("res://artifacts/%s_solution_ready.png" % identifier) == OK)
	print("LEVEL3_SOLUTION_VISUAL_OK")
	quit()

extends SceneTree

const TASK_BANK = preload("res://scripts/chemistry/task_bank.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	site.level = 4
	root.add_child(site)
	var hud: Control = site.get_node("CanvasLayer/GameHud")
	var task: Dictionary = TASK_BANK.load_verified_tasks(4).filter(func(entry: Dictionary) -> bool: return entry.id == "L4-138")[0]
	site._tasks = [task]
	site._task_index = 0
	site._update_hud()
	hud.show_task(task, str(task.station))
	for frame in range(5):
		await process_frame
	assert(root.get_viewport().get_texture().get_image().save_png("res://artifacts/level4_kinetics_runs.png") == OK)
	var comparison: VBoxContainer = hud.get("_comparison_view")
	(comparison.get_node("RunButtons").get_child(0) as Button).pressed.emit()
	(comparison.get_node("RunButtons").get_child(1) as Button).pressed.emit()
	for frame in range(5):
		await process_frame
	assert(root.get_viewport().get_texture().get_image().save_png("res://artifacts/level4_kinetics_compare.png") == OK)
	print("LEVEL4_KINETICS_VISUAL_OK")
	quit()

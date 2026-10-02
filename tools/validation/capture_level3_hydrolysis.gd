extends SceneTree

const TASK_BANK = preload("res://scripts/chemistry/task_bank.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	site.level = 3
	root.add_child(site)
	var hud: Control = site.get_node("CanvasLayer/GameHud")
	var task: Dictionary = TASK_BANK.load_verified_tasks(3).filter(func(entry: Dictionary) -> bool: return entry.id == "L3-118")[0]
	site._tasks = [task]
	site._task_index = 0
	site._update_hud()
	hud.show_task(task, str(task.station))
	for frame in range(5):
		await process_frame
	assert(root.get_viewport().get_texture().get_image().save_png("res://artifacts/level3_hydrolysis_unread.png") == OK)
	var probes: VBoxContainer = hud.get("_comparison_view")
	for button in probes.get_node("RunButtons").get_children():
		(button as Button).pressed.emit()
	for frame in range(5):
		await process_frame
	assert(root.get_viewport().get_texture().get_image().save_png("res://artifacts/level3_hydrolysis_read.png") == OK)
	print("LEVEL3_HYDROLYSIS_VISUAL_OK")
	quit()

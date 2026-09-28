extends SceneTree

const TASK_BANK = preload("res://scripts/chemistry/task_bank.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	site.level = 4
	root.add_child(site)
	var hud: Control = site.get_node("CanvasLayer/GameHud")
	var task: Dictionary = TASK_BANK.load_verified_tasks(4).filter(func(entry: Dictionary) -> bool: return entry.id == "L4-128")[0]
	hud.show_task(task, str(task.station))
	for frame in range(5):
		await process_frame
	assert(root.get_viewport().get_texture().get_image().save_png("res://artifacts/level4_hess_route.png") == OK)
	var route: VBoxContainer = hud.get("_hess_view")
	route.choose_step("B", "A")
	route.choose_step("A", "C")
	for frame in range(5):
		await process_frame
	assert(root.get_viewport().get_texture().get_image().save_png("res://artifacts/level4_hess_ready.png") == OK)
	print("LEVEL4_HESS_VISUAL_OK")
	quit()

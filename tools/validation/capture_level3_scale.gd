extends SceneTree

const TASK_BANK = preload("res://scripts/chemistry/task_bank.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	site.level = 3
	root.add_child(site)
	var hud: Control = site.get_node("CanvasLayer/GameHud")
	var task: Dictionary = TASK_BANK.load_verified_tasks(3).filter(func(entry: Dictionary) -> bool: return entry.id == "L3-086")[0]
	hud.show_task(task, str(task.station))
	for frame in range(5):
		await process_frame
	assert(root.get_viewport().get_texture().get_image().save_png("res://artifacts/level3_scale_prepare.png") == OK)
	var scale: VBoxContainer = hud.get("_scale_view")
	(scale.get_node("PrepareButton") as Button).pressed.emit()
	for button in scale.get_node("FormulaButtons").get_children():
		if button is Button and button.text == "n = m / M":
			button.pressed.emit()
			break
	for frame in range(5):
		await process_frame
	assert(root.get_viewport().get_texture().get_image().save_png("res://artifacts/level3_scale_ready.png") == OK)
	print("LEVEL3_SCALE_VISUAL_OK")
	quit()

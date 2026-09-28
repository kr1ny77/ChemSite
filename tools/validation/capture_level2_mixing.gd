extends SceneTree

const TASK_BANK = preload("res://scripts/chemistry/task_bank.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	site.level = 2
	root.add_child(site)
	var hud: Control = site.get_node("CanvasLayer/GameHud")
	var task: Dictionary = TASK_BANK.load_verified_tasks(2).filter(func(entry: Dictionary) -> bool: return entry.id == "L2-051")[0]
	hud.show_task(task, str(task.station))
	for frame in range(5):
		await process_frame
	assert(root.get_viewport().get_texture().get_image().save_png("res://artifacts/level2_mixing_choose.png") == OK)
	var mixer: VBoxContainer = hud.get("_mix_view")
	for reagent in task.parameters.mixingReagents:
		for button in mixer.get_node("Choices").get_children():
			if button is Button and button.text == reagent:
				button.pressed.emit()
				break
	for frame in range(5):
		await process_frame
	assert(root.get_viewport().get_texture().get_image().save_png("res://artifacts/level2_mixing_observation.png") == OK)
	print("LEVEL2_MIXING_VISUAL_OK")
	quit()

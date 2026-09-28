extends SceneTree

const TASK_BANK = preload("res://scripts/chemistry/task_bank.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	site.level = 4
	root.add_child(site)
	var hud: Control = site.get_node("CanvasLayer/GameHud")
	var tasks := TASK_BANK.load_verified_tasks(5)
	for identifier in ["L5-167", "L5-190", "L5-200"]:
		var matches := tasks.filter(func(task: Dictionary) -> bool: return task.id == identifier)
		assert(matches.size() == 1)
		hud.show_task(matches[0], str(matches[0].station))
		for frame in range(5):
			await process_frame
		var capture := root.get_viewport().get_texture().get_image()
		assert(capture.save_png("res://artifacts/level5_%s.png" % identifier) == OK)
	print("LEVEL5_VISUAL_CAPTURE_OK")
	quit()

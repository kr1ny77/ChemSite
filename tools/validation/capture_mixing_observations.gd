extends SceneTree

const BANK = preload("res://scripts/chemistry/task_bank.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var hud := (load("res://scenes/ui/game_hud.tscn") as PackedScene).instantiate()
	root.add_child(hud)
	var animated := OS.get_cmdline_user_args().has("--animated")
	hud.reduced_motion = not animated
	for task in BANK.load_verified_tasks(2):
		if not task.get("parameters", {}).has("mixingVisual"):
			continue
		hud.show_task(task, str(task.station))
		for reagent in task.parameters.mixingReagents:
			hud._mix_view._select(reagent)
		for frame in range(80 if animated else 8):
			await process_frame
		var im := root.get_viewport().get_texture().get_image()
		assert(im.save_png("res://artifacts/mixing-observations/" + str(task.id) + ".png") == OK)
	print("MIXING_OBSERVATIONS_CAPTURE_OK")
	quit()

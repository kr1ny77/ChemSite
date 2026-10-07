extends SceneTree

const BANK = preload("res://scripts/chemistry/task_bank.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	site.save_path = "user://capture-input-theme-progress.json"
	root.add_child(site)
	var hud: Control = site._hud
	site._player.controls_enabled = false
	var directory := "res://artifacts/hud-light-input"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	for entry in [[1, "L1-027"], [2, "L2-041"], [3, "L3-081"], [3, "L3-095"]]:
		var task: Dictionary = BANK.load_verified_tasks(entry[0]).filter(func(value): return value.id == entry[1])[0]
		hud.show_task(task, task.station)
		for frame in range(5): await process_frame
		await RenderingServer.frame_post_draw
		if root.get_texture().get_image().save_png(directory + "/" + task.id + "-empty.png") != OK:
			quit(1)
			return
		for control in hud._panel_content.get_children():
			if control is LineEdit and control.editable:
				control.text = str(task.correctAnswer.value) if task.correctAnswer is Dictionary else str(task.correctAnswer)
				control.grab_focus()
				control.caret_column = control.text.length()
				for frame in range(5): await process_frame
				await RenderingServer.frame_post_draw
				if root.get_texture().get_image().save_png(directory + "/" + task.id + "-entered.png") != OK:
					quit(1)
					return
	site.queue_free()
	for frame in range(5): await process_frame
	print("INPUT_THEME_CAPTURE_OK")
	quit()

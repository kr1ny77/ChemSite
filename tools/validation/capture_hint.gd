extends SceneTree

const TASK_BANK = preload("res://scripts/chemistry/task_bank.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	root.add_child(site)
	root.focus_exited.disconnect(site._pause_on_focus_loss)
	var hud: Control = site.get_node("CanvasLayer/GameHud")
	var task: Dictionary = TASK_BANK.load_verified_tasks(1)[0]
	site._tasks = [task]
	site._task_index = 0
	site._update_hud()
	hud.show_task(task, str(task.station))
	await _capture("hidden")
	assert(not hud._hint.visible)
	hud._hint_button.grab_focus()
	await process_frame
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.keycode = KEY_SPACE
		event.pressed = pressed
		Input.parse_input_event(event)
		await process_frame
	assert(hud._hint.visible and hud._hint_button.has_focus())
	await _capture("shown")
	hud.show_task(TASK_BANK.load_verified_tasks(1)[1], str(task.station))
	assert(not hud._hint.visible and not hud._hint_button.button_pressed)
	print("HINT_KEYBOARD_RESET_CAPTURE_OK")
	quit()

func _capture(state: String) -> void:
	for frame in range(5): await process_frame
	RenderingServer.force_draw(false)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://artifacts/hint-review"))
	assert(root.get_viewport().get_texture().get_image().save_png("res://artifacts/hint-review/" + state + ".png") == OK)

extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene := load("res://scenes/levels/construction_site.tscn") as PackedScene
	var site := scene.instantiate()
	site.save_path = "user://gameplay-smoke-progress.json"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(site.save_path))
	root.add_child(site)
	await process_frame
	var player := site.get_node("Player") as CharacterBody3D
	var start_x := player.position.x
	Input.action_press("move_right")
	for i in range(30):
		await physics_frame
	Input.action_release("move_right")
	assert(player.position.x > start_x + 0.2, "Player movement failed")
	player.global_position = Vector3(-3.3, 0.05, -1.6)
	site._find_nearest_station()
	var event := InputEventAction.new()
	event.action = "interact"
	event.pressed = true
	site._unhandled_input(event)
	var hud := site.get_node("CanvasLayer/GameHud")
	assert(hud.is_panel_open(), "Station panel did not open")
	site._submit_answer("сульфат бария")
	assert(site._completed == 1, "Correct answer did not complete task")
	assert(site._score == 100, "Correct answer did not score")
	site._resume()
	player.global_position = Vector3(5.7, 0.05, -1.5)
	site._find_nearest_station()
	site._unhandled_input(event)
	assert(hud.is_panel_open(), "Formula board did not open")
	hud._append_token("Ca")
	hud._append_token("CO₃")
	assert(hud._formula_buffer == "CaCO₃", "Formula assembly failed")
	site._submit_answer(hud._formula_buffer)
	assert(site._completed == 2 and site._score == 200, "Formula task did not score")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(site.save_path))
	site.queue_free()
	await process_frame
	print("CHEMSITE_GAMEPLAY_SMOKE_OK")
	quit()

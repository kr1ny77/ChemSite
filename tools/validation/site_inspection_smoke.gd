extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	root.add_child(site)
	await process_frame
	var player := site.get_node("Player") as CharacterBody3D
	var hud := site.get_node("CanvasLayer/GameHud") as Control
	var interact := InputEventAction.new()
	interact.action = "interact"
	interact.pressed = true
	assert(site._site_inspections.size() == 8, "Expected eight curated site observations")
	for entry in site._site_inspections:
		player.global_position = entry.position + Vector3(0, 0.05, 0)
		player.velocity = Vector3.ZERO
		site._find_nearest_station()
		assert(site._nearest_inspection.get("id", "") == entry.id, "Inspection marker unavailable: " + str(entry.id))
		site._update_hud()
		assert(str((hud.get("_prompt") as Label).text).begins_with("[ E ]"), "Inspection prompt missing")
		site._unhandled_input(interact)
		assert(hud.is_panel_open(), "Inspection panel failed: " + str(entry.id))
		assert(not player.controls_enabled, "Player was not paused for inspection")
		assert(site._completed == 0 and site._task_index == 0, "Inspection changed the round")
		site._resume()
		assert(player.controls_enabled and not hud.is_panel_open(), "Inspection failed to close")
	print("SITE_INSPECTION_SMOKE_OK")
	quit()

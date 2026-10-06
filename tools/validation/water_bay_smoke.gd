extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	root.add_child(site)
	var player := site.get_node("Player") as CharacterBody3D
	player.controls_enabled = false
	player.global_position = Vector3(9.7, 0.04, 5.1)
	for frame in range(90):
		player.velocity = Vector3(0, -0.2, -3.5)
		player.move_and_slide()
		await physics_frame
	if player.global_position.z < 3.78 or player.global_position.z > 4.12:
		push_error("Water bay proxy failed to stop approach: " + str(player.global_position))
		quit(1)
		return
	site._find_nearest_station()
	if site._nearest_inspection.get("id", "") != "water_bay":
		push_error("Water bay inspection unavailable at physical contact")
		quit(1)
		return
	print("WATER_BAY_SMOKE_OK position=", player.global_position)
	quit()

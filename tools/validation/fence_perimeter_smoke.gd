extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	root.add_child(site)
	await physics_frame
	var player := site.get_node("Player") as CharacterBody3D
	var checks := [
		{"start": Vector3(11.0, 0.05, 0.0), "action": "move_right", "axis": "x", "limit": 12.0, "positive": true},
		{"start": Vector3(-11.0, 0.05, 0.0), "action": "move_left", "axis": "x", "limit": -12.0, "positive": false},
		{"start": Vector3(0.0, 0.05, 8.2), "action": "move_back", "axis": "z", "limit": 9.3, "positive": true},
		{"start": Vector3(0.0, 0.05, -8.2), "action": "move_forward", "axis": "z", "limit": -9.3, "positive": false},
	]
	for check in checks:
		player.global_position = check.start
		player.velocity = Vector3.ZERO
		Input.action_press(check.action)
		for frame in range(90):
			await physics_frame
		assert(Vector2(player.velocity.x, player.velocity.z).length() < 0.08, "Player should stop against the fence")
		assert(player._current_animation == "Idle", "Blocked movement should use the stationary animation")
		Input.action_release(check.action)
		var coordinate: float = player.global_position.x if check.axis == "x" else player.global_position.z
		if check.positive:
			assert(coordinate < check.limit, "Player crossed positive fence boundary")
		else:
			assert(coordinate > check.limit, "Player crossed negative fence boundary")
	print("FENCE_PERIMETER_SMOKE_OK")
	quit()

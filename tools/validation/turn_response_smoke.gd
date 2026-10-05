extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var ground := StaticBody3D.new()
	var collision := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(100, 0.2, 100)
	collision.shape = box
	ground.add_child(collision)
	ground.position.y = -0.1
	root.add_child(ground)
	var player := (load("res://scenes/player/player.tscn") as PackedScene).instantiate() as CharacterBody3D
	root.add_child(player)
	player.position.y = 0.04
	Input.action_press("move_right")
	await _frames(90)
	for turn in [["move_right", "move_left"], ["move_left", "move_forward"]]:
		Input.action_release(turn[0])
		Input.action_press(turn[1])
		var previous: float = player.visual.rotation.y
		var largest_step := 0.0
		for frame in range(90):
			await physics_frame
			var angle: float = player.visual.rotation.y
			largest_step = maxf(largest_step, absf(wrapf(angle - previous, -PI, PI)))
			previous = angle
		var target := atan2(player.velocity.x, player.velocity.z)
		var error: float = absf(wrapf(player.visual.rotation.y - target, -PI, PI))
		print("TURN_RESPONSE ", turn[1], " maximum_step_deg=", rad_to_deg(largest_step), " settled_error_deg=", rad_to_deg(error))
		if largest_step > deg_to_rad(12.1) or error > deg_to_rad(0.5):
			push_error("Turn response exceeds angular step/settling gate")
			quit(1)
			return
	Input.action_release("move_forward")
	player.set_physics_process(false)
	var responses: Array[float] = []
	for frequency in [30, 60, 120]:
		player.visual.rotation.y = 0.0
		player._yaw_velocity = 0.0
		var largest_rate := 0.0
		for frame in range(int(frequency * 0.6)):
			var before: float = player.visual.rotation.y
			player._update_heading(PI, 1.0 / frequency)
			largest_rate = maxf(largest_rate, absf(wrapf(player.visual.rotation.y - before, -PI, PI)) * frequency)
		responses.append(player.visual.rotation.y)
		var error: float = absf(wrapf(player.visual.rotation.y - PI, -PI, PI))
		print("TURN_FREQUENCY ", frequency, " max_rate_deg=", rad_to_deg(largest_rate), " error_deg=", rad_to_deg(error))
		if largest_rate > deg_to_rad(720.1) or error > deg_to_rad(1.0):
			push_error("Turn speed/settling varies outside frame-rate gate")
			quit(1)
			return
	if absf(responses.max() - responses.min()) > deg_to_rad(0.5):
		push_error("Turn final heading differs across frame rates")
		quit(1)
		return
	print("TURN_RESPONSE_SMOKE_OK")
	quit()

func _frames(count: int) -> void:
	for frame in range(count):
		await physics_frame

extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var player := (load("res://scenes/player/player.tscn") as PackedScene).instantiate() as CharacterBody3D
	root.add_child(player)
	player.set_physics_process(false)
	var ends: Array[Vector2] = []
	for frequency in [30, 60, 120]:
		player._motion_acceleration = Vector2.ZERO
		var speed := Vector2.ZERO
		var previous := 0.0
		for frame in range(int(frequency * .4)):
			speed = player._smooth_velocity(speed, Vector2(3.5, 0), player.acceleration_response, 1.0 / frequency)
			if speed.x < previous or speed.x > 3.50001:
				push_error("Acceleration overshoots or reverses")
				quit(1)
				return
			previous = speed.x
		ends.append(speed)
		for frame in range(int(frequency * .4)):
			speed = player._smooth_velocity(speed, Vector2.ZERO, player.deceleration_response, 1.0 / frequency)
		if speed.length() > .01:
			push_error("Stop drifts beyond the settling gate")
			quit(1)
			return
	if ends[0].distance_to(ends[2]) > .0001:
		push_error("Movement easing varies across physics rates")
		quit(1)
		return
	print("MOVEMENT_EASING_SMOKE_OK speed_after_400ms=", ends[1].x)
	quit()

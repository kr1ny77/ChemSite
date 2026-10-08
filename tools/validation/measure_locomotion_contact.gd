extends "res://tools/validation/player_grounding_smoke.gd"

# Diagnostic of the actual AnimationTree/controller, including transitions.
# Reports sole motion during authored support windows; thresholds are established
# after reviewing the native sequence and comparing straight travel with turns.
func _run() -> void:
	var physics_hz := 60
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--physics-hz="):
			physics_hz = argument.trim_prefix("--physics-hz=").to_int()
	assert(physics_hz in [30, 60, 120])
	Engine.physics_ticks_per_second = physics_hz
	var baseline := OS.get_cmdline_user_args().has("--idle-animation")
	var floor_body := StaticBody3D.new()
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(100, 0.2, 100)
	collider.shape = shape
	floor_body.position.y = -0.1
	floor_body.add_child(collider)
	root.add_child(floor_body)
	var reports: Array[Dictionary] = []
	for scenario in ["straight_run", "corner_run", "reverse_run", "start_stop_walk"]:
		var player := (load("res://scenes/player/player.tscn") as PackedScene).instantiate() as CharacterBody3D
		root.add_child(player)
		if baseline:
			player._animation_tree.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_IDLE
		player.position.y = 0.04
		player.visual.rotation.y = PI / 2.0
		var soles: Array[MeshInstance3D] = []
		for mesh in player.find_children("*", "MeshInstance3D", true, false):
			if mesh.name.begins_with("Sole"):
				soles.append(mesh as MeshInstance3D)
		assert(soles.size() == 2)
		var previous: Dictionary = {}
		var samples: Array[Dictionary] = []
		var skipped_pairs := 0
		var action := "move_right"
		Input.action_press(action, 0.3 if scenario == "start_stop_walk" else 1.0)
		for frame in range(180):
			if frame == 75:
				if scenario in ["corner_run", "reverse_run"]:
					Input.action_release(action)
					action = "move_forward" if scenario == "corner_run" else "move_left"
					Input.action_press(action)
				elif scenario == "start_stop_walk":
					Input.action_release(action)
			if frame == 120 and scenario == "start_stop_walk":
				Input.action_press(action, 0.3)
			await physics_frame
			await process_frame
			var state: String = player._playback.get_current_node()
			var phase := 0.0
			if state in ["Walk", "Run"]:
				phase = fposmod(player._playback.get_current_play_position() / float(player._clip_lengths[state]), 1.0)
			for sole in soles:
				var skeleton := sole.get_node(sole.skeleton) as Skeleton3D
				skeleton.force_update_all_bone_transforms()
				var point := _skinned_vertex(sole, skeleton, _sole_vertex(sole, 0))
				assert(point.is_finite())
				var shifted := fposmod(phase - 0.25 + (0.5 if "-1" in sole.name else 0.0), 1.0)
				var supporting := state in ["Walk", "Run"] and shifted < (0.2 if state == "Run" else 0.5)
				if previous.has(sole.name):
					var last: Dictionary = previous[sole.name]
					if supporting and last.supporting and last.state == state and phase >= float(last.phase):
						if Engine.get_physics_frames() - int(last.tick) != 1:
							skipped_pairs += 1
							previous[sole.name] = {"supporting": supporting, "state": state, "phase": phase, "point": point, "tick": Engine.get_physics_frames()}
							continue
						var drift := Vector2(point.x - last.point.x, point.z - last.point.z).length()
						samples.append({"frame": frame, "sole": str(sole.name), "state": state, "drift_m": drift, "height_m": point.y, "speed": Vector2(player.velocity.x, player.velocity.z).length(), "yaw": player.visual.rotation.y})
				previous[sole.name] = {"supporting": supporting, "state": state, "phase": phase, "point": point, "tick": Engine.get_physics_frames()}
		Input.action_release(action)
		var maximum := 0.0
		var turn_maximum := 0.0
		var steady_maximum := 0.0
		var steady_count := 0
		for sample in samples:
			maximum = maxf(maximum, sample.drift_m)
			if sample.frame >= 55 and sample.frame < 74:
				steady_maximum = maxf(steady_maximum, sample.drift_m)
				steady_count += 1
			if sample.frame >= 75 and sample.frame < 105:
				turn_maximum = maxf(turn_maximum, sample.drift_m)
		if steady_count < 5:
			push_error("Insufficient consecutive steady contact samples")
			quit(1)
			return
		if not baseline:
			if steady_maximum >= 0.001:
				push_error("Steady sole motion exceeds 1 mm per physics tick: " + scenario)
				quit(1)
				return
		var report := {"physics_hz": physics_hz, "idle_animation_baseline": baseline, "steady_maximum_m": steady_maximum, "steady_samples": steady_count, "skipped_pairs": skipped_pairs, "scenario": scenario, "maximum_support_frame_drift_m": maximum, "turn_window_maximum_m": turn_maximum, "samples": samples}
		reports.append(report)
		print("CONTACT_DIAGNOSTIC ", scenario, " maximum_m=", maximum, " turn_window_m=", turn_maximum, " steady_m=", steady_maximum)
		player.queue_free()
		await process_frame
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://artifacts"))
	var filename := "res://artifacts/locomotion-contact-%s-%d.json" % ["idle" if baseline else "physics", physics_hz]
	var file := FileAccess.open(filename, FileAccess.WRITE)
	file.store_string(JSON.stringify(reports, "\t"))
	file.close()
	print("LOCOMOTION_CONTACT_DIAGNOSTIC_OK")
	quit()

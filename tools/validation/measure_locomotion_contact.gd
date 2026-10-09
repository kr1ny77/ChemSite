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
		var plant: SkeletonModifier3D = player._foot_plant
		if OS.get_cmdline_user_args().has("--no-plant"):
			plant.active = false
		player.position.y = 0.04
		player.visual.rotation.y = PI / 2.0
		var soles: Array[MeshInstance3D] = []
		for mesh in player.find_children("*", "MeshInstance3D", true, false):
			if mesh.name.begins_with("Sole"):
				soles.append(mesh as MeshInstance3D)
		assert(soles.size() == 2)
		var evaluated: Dictionary = {}
		var final_length_error := [0.0]
		var evaluated_skeleton := soles[0].get_node(soles[0].skeleton) as Skeleton3D
		evaluated_skeleton.skeleton_updated.connect(func() -> void:
			for sole in soles:
				evaluated[sole.name] = _skinned_vertex(sole, evaluated_skeleton, _sole_vertex(sole, 0))
			for side in ["l", "r"]:
				var hip := evaluated_skeleton.get_bone_global_pose(evaluated_skeleton.find_bone("thigh_" + side)).origin
				var knee := evaluated_skeleton.get_bone_global_pose(evaluated_skeleton.find_bone("calf_" + side)).origin
				var ankle := evaluated_skeleton.get_bone_global_pose(evaluated_skeleton.find_bone("foot_" + side)).origin
				final_length_error[0] = maxf(final_length_error[0], maxf(absf(hip.distance_to(knee) - 0.15), absf(knee.distance_to(ankle) - 0.14)))
		)
		var previous: Dictionary = {}
		var samples: Array[Dictionary] = []
		var skipped_pairs := 0
		var action := "move_right"
		Input.action_press(action, 0.3 if scenario == "start_stop_walk" else 1.0)
		for frame in range(physics_hz * 3):
			if frame == roundi(physics_hz * 1.25):
				if scenario in ["corner_run", "reverse_run"]:
					Input.action_release(action)
					action = "move_forward" if scenario == "corner_run" else "move_left"
					Input.action_press(action)
				elif scenario == "start_stop_walk":
					Input.action_release(action)
			if frame == physics_hz * 2 and scenario == "start_stop_walk":
				Input.action_press(action, 0.3)
			await physics_frame
			await process_frame
			var state: String = player._playback.get_current_node()
			var phase := 0.0
			if state in ["Walk", "Run"]:
				phase = fposmod(player._playback.get_current_play_position() / float(player._clip_lengths[state]), 1.0)
			for sole in soles:
				assert(evaluated.has(sole.name), "Final skeleton pose was not sampled")
				var point: Vector3 = evaluated[sole.name]
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
						samples.append({"frame": frame, "time_s": float(frame) / physics_hz, "sole": str(sole.name), "state": state, "drift_m": drift, "height_m": point.y, "speed": Vector2(player.velocity.x, player.velocity.z).length(), "yaw": player.visual.rotation.y})
				previous[sole.name] = {"supporting": supporting, "state": state, "phase": phase, "point": point, "tick": Engine.get_physics_frames()}
		Input.action_release(action)
		var maximum := 0.0
		var turn_maximum := 0.0
		var steady_maximum := 0.0
		var steady_count := 0
		var steady_soles: Dictionary = {}
		for sample in samples:
			maximum = maxf(maximum, sample.drift_m)
			if sample.time_s >= 0.4 and sample.time_s < 1.2:
				steady_maximum = maxf(steady_maximum, sample.drift_m)
				steady_count += 1
				steady_soles[sample.sole] = true
			if sample.time_s >= 1.25 and sample.time_s < 1.75:
				turn_maximum = maxf(turn_maximum, sample.drift_m)
		# Run support lasts about 57 ms: at 30 Hz some contacts span one tick.
		var minimum_samples := 3 if physics_hz == 30 else 5
		if steady_count < minimum_samples or steady_soles.size() != 2:
			push_error("Insufficient consecutive steady contact samples: %s count=%d soles=%d" % [scenario, steady_count, steady_soles.size()])
			quit(1)
			return
		if not baseline:
			if steady_maximum >= 0.001:
				push_error("Steady sole motion exceeds 1 mm per physics tick: " + scenario)
				quit(1)
				return
		if not baseline and physics_hz == 60 and scenario == "reverse_run" and turn_maximum >= 0.095:
			push_error("Reversal contact exceeds 95 mm per tick at 60 Hz")
			quit(1)
			return
		var report := {"physics_hz": physics_hz, "idle_animation_baseline": baseline, "steady_maximum_m": steady_maximum, "steady_samples": steady_count, "skipped_pairs": skipped_pairs, "scenario": scenario, "maximum_support_frame_drift_m": maximum, "turn_window_maximum_m": turn_maximum, "samples": samples}
		if final_length_error[0] > 0.0001:
			push_error("Final evaluated leg length changed")
			quit(1)
			return
		if plant != null and plant.active:
			if physics_hz == 60 and ((scenario == "reverse_run" and turn_maximum >= 0.07) or (scenario == "corner_run" and turn_maximum >= 0.04)):
				push_error("Planted turn contact exceeds its displacement gate")
				quit(1)
				return
			if plant.maximum_length_error > 0.0001 or plant.maximum_height_error > 0.0001 or plant.maximum_correction > 0.06501 or plant.maximum_boot_twist > deg_to_rad(65.01):
				push_error("Foot plant changed leg length/height or exceeded correction bounds")
				quit(1)
				return
			report["plant"] = {"reach_clamped_ticks": plant.reach_clamped_ticks, "maximum_reach_loss_m": plant.maximum_reach_loss, "processed": plant.processed_ticks, "corrected": plant.corrected_ticks, "maximum_correction_m": plant.maximum_correction, "length_error_m": plant.maximum_length_error, "height_error_m": plant.maximum_height_error, "boot_twist_degrees": rad_to_deg(plant.maximum_boot_twist), "final_length_error_m": final_length_error[0]}
			print("PLANT_METRICS ", scenario, " ", report.plant)
			if not await _verify_plant_release(player, plant, action, scenario):
				quit(1)
				return
		reports.append(report)
		print("CONTACT_DIAGNOSTIC ", scenario, " maximum_m=", maximum, " turn_window_m=", turn_maximum, " steady_m=", steady_maximum)
		player.queue_free()
		await process_frame
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://artifacts"))
	var filename := "res://artifacts/locomotion-contact-%s-%d%s.json" % ["idle" if baseline else "physics", physics_hz, "-unplanted" if OS.get_cmdline_user_args().has("--no-plant") else ""]
	var file := FileAccess.open(filename, FileAccess.WRITE)
	file.store_string(JSON.stringify(reports, "\t"))
	file.close()
	print("LOCOMOTION_CONTACT_DIAGNOSTIC_OK")
	quit()

func _verify_plant_release(player: CharacterBody3D, plant: SkeletonModifier3D, action: String, scenario: String) -> bool:
	var opposite: String = {"move_left": "move_right", "move_right": "move_left", "move_forward": "move_back", "move_back": "move_forward"}[action]
	# Establish steady Run before testing a release from an actual turn lock.
	Input.action_press(action)
	for frame in range(roundi(Engine.physics_ticks_per_second * 0.5)):
		await physics_frame
		await process_frame
	Input.action_release(action)
	Input.action_press(opposite)
	var locked := false
	for frame in range(60):
		await physics_frame
		await process_frame
		for foot in plant._feet:
			if foot.support and foot.offset.length() > 0.005:
				locked = true
		if locked:
			break
	Input.action_release(opposite)
	if not locked:
		push_error("Release check failed to establish an active foot lock: " + scenario)
		return false
	match scenario:
		"straight_run": player.controls_enabled = false
		"corner_run": player.play_interact()
		"reverse_run": player.position.y += 2.0
		"start_stop_walk": player._animation_tree.active = false
	for frame in range(2):
		await physics_frame
		await process_frame
	for foot in plant._feet:
		if foot.support or not foot.offset.is_zero_approx():
			push_error("Foot lock survived its release condition: " + scenario)
			return false
	print("PLANT_RELEASE_OK ", scenario)
	return true

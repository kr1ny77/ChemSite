extends "res://tools/validation/cartoon_turn_candidate_smoke.gd"

const DRIVER = preload("res://tools/validation/turn_motion_candidate_driver.gd")

func _run() -> void:
	var floor_body := StaticBody3D.new()
	var floor_shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(10, 0.2, 10)
	floor_shape.shape = box
	floor_body.add_child(floor_shape)
	floor_body.position.y = -0.1
	root.add_child(floor_body)
	var reports: Array = []
	for hz in [30, 60, 120]:
		Engine.physics_ticks_per_second = hz
		for action in ["TurnLeftStep", "TurnRightStep"]:
			for heading in [0.0, PI / 2.0]:
				var document := GLTFDocument.new()
				var state := GLTFState.new()
				assert(document.append_from_file("res://artifacts/cartoon-turn-candidate/cartoon_turn.glb", state) == OK)
				var model := document.generate_scene(state, 384.0)
				var body = DRIVER.new()
				root.add_child(body)
				body.rotation.y = heading
				body.configure(model, action)
				await physics_frame
				var soles: Dictionary = {}
				for mesh in model.find_children("*", "MeshInstance3D", true, false):
					if mesh.name.begins_with("Sole"):
						soles["r" if "-1" in mesh.name else "l"] = mesh
				var previous: Dictionary = {}
				var sole_drift := 0.0
				var sole_height := 0.0
				var samples: Array = []
				for tick in range(ceili(body.duration * hz) + 3):
					await physics_frame
					await process_frame
					var phase: float = body.elapsed / body.duration
					var side := "l" if phase < 0.4 or phase >= 0.8 else "r"
					var sole := soles[side] as MeshInstance3D
					var skeleton := sole.get_node(sole.skeleton) as Skeleton3D
					skeleton.force_update_all_bone_transforms()
					var point := _candidate_vertex(sole, skeleton, _sole_vertex(sole, 0))
					sole_height = maxf(sole_height, absf(point.y))
					if previous.has(side): sole_drift = maxf(sole_drift, point.distance_to(previous[side]))
					samples.append({"phase": phase, "tree_time": body.playback.get_current_play_position(), "body_time": body.elapsed, "side": side, "point": str(point), "drift_m": point.distance_to(previous[side]) if previous.has(side) else 0.0})
					previous = {side: point}
				print("TURN_ROOT_SOLES ", hz, " ", action, " drift=", sole_drift, " height=", sole_height)
				# Physical floor profile uses the production grounding gate (3 mm).
				# Horizontal/vertical support displacement retains the 1 mm gate.
				if sole_drift >= 0.001 or sole_height >= 0.003:
					var failure := FileAccess.open("res://artifacts/cartoon-turn-candidate/root_motion_contact_failure.json", FileAccess.WRITE)
					failure.store_string(JSON.stringify(samples, "\t"))
					push_error("Root-motion support contact gate failed")
					quit(1)
					return
				var expected := Vector3(-0.07041628, 0, 0.07041632 if action == "TurnLeftStep" else -0.07041632)
				expected = Basis(Vector3.UP, heading) * expected
				var position_error := Vector2(body.position.x - expected.x, body.position.z - expected.z).length()
				var yaw: float = body.rotation.y
				var expected_yaw: float = heading + (PI / 2.0 if action == "TurnLeftStep" else -PI / 2.0)
				var yaw_error := absf(wrapf(yaw - expected_yaw, -PI, PI))
				print("TURN_ROOT_METRICS ", hz, " ", action, " requested=", body.requested_total, " blocked=", body.blocked_ticks, " rotation=", body.rotation, " position=", body.position, " error=", position_error, " yaw=", yaw, " yaw_error=", yaw_error)
				if position_error > 0.001 or yaw_error > 0.001:
					push_error("Extracted root motion differs from authored endpoint")
					quit(1)
					return
				reports.append({"physics_hz": hz, "action": action, "initial_heading_rad": heading, "position_error_m": position_error, "yaw_error_rad": yaw_error, "maximum_step_m": body.maximum_step, "support_drift_m": sole_drift, "support_height_error_m": sole_height})
				body.queue_free()
				await process_frame
	for hz in [30, 60, 120]:
		Engine.physics_ticks_per_second = hz
		for scenario in ["pause", "interrupt_early", "interrupt_transfer", "interrupt_settle", "wall"]:
			var document := GLTFDocument.new()
			var state := GLTFState.new()
			assert(document.append_from_file("res://artifacts/cartoon-turn-candidate/cartoon_turn.glb", state) == OK)
			var body = DRIVER.new()
			root.add_child(body)
			body.configure(document.generate_scene(state, 384.0), "TurnLeftStep")
			var wall: StaticBody3D
			if scenario == "wall":
				wall = StaticBody3D.new()
				var shape := CollisionShape3D.new()
				var wall_box := BoxShape3D.new()
				wall_box.size = Vector3(0.1, 3, 3)
				shape.shape = wall_box
				wall.add_child(shape)
				wall.position = Vector3(-0.39, 1.5, 0)
				root.add_child(wall)
			var fraction := 0.2 if scenario in ["pause", "interrupt_early"] else (0.55 if scenario == "interrupt_transfer" else 0.9)
			while body.elapsed < body.duration * fraction and not body.interrupted:
				await physics_frame
				await process_frame
			var before: Vector3 = body.position
			var before_rotation: Quaternion = body.quaternion
			var before_time: float = body.elapsed
			if scenario == "pause": body.paused = true
			elif scenario != "wall": body.interrupt()
			for tick in range(hz / 3):
				await physics_frame
				await process_frame
			var stopped_drift := Vector2(body.position.x - before.x, body.position.z - before.z).length()
			var stopped_yaw := before_rotation.angle_to(body.quaternion)
			if scenario != "wall":
				assert(stopped_drift < 0.0001 and stopped_yaw < 0.001)
				if scenario == "pause":
					assert(body.elapsed == before_time)
					body.paused = false
					while body.elapsed < body.duration:
						await physics_frame
						await process_frame
					assert(Vector2(body.position.x + 0.07041628, body.position.z - 0.07041632).length() < 0.001)
				else:
					assert(body.playback.get_current_node() == "Idle")
			else:
				assert(body.blocked_ticks > 0 and body.interrupted)
				assert(body.position.x >= -0.022, "Capsule crossed wall")
			reports.append({"physics_hz": hz, "scenario": scenario, "stopped_drift_m": stopped_drift, "stopped_yaw_rad": stopped_yaw, "blocked_ticks": body.blocked_ticks, "final_x": body.position.x})
			body.queue_free()
			if wall != null: wall.queue_free()
			await process_frame
	var file := FileAccess.open("res://artifacts/cartoon-turn-candidate/root_motion_checks.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(reports, "\t"))
	print("TURN_ROOT_MOTION_OK ", reports.size())
	quit()

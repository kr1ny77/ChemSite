extends "res://tools/validation/cartoon_turn_candidate_smoke.gd"

const DRIVER = preload("res://tools/validation/turn_motion_candidate_driver.gd")
const FOLDER := "res://artifacts/cartoon-turn-root-candidate"

func _initialize() -> void:
	create_timer(90.0).timeout.connect(func(): quit(1))
	call_deferred("_run")

func _run() -> void:
	var floor_body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(20, 0.2, 20)
	shape.shape = box
	floor_body.add_child(shape)
	floor_body.position.y = -0.1
	root.add_child(floor_body)
	var reports: Array = []
	for hz in [30, 60, 120]:
		Engine.physics_ticks_per_second = hz
		for action in ["TurnLeftStep", "TurnRightStep"]:
			for phase in [0.2, 0.55, 0.9, 1.0]:
				for gait in ["Walk", "Run"]:
					var document := GLTFDocument.new()
					var state := GLTFState.new()
					assert(document.append_from_file(FOLDER + "/cartoon_turn.glb", state) == OK)
					var model := document.generate_scene(state, 384.0)
					var body = DRIVER.new()
					root.add_child(body)
					body.configure(model, action)
					while body.elapsed < body.duration * phase:
						await physics_frame
						await process_frame
					var before_yaw: Quaternion = body.quaternion
					var before_position: Vector3 = body.position
					var soles: Array[MeshInstance3D] = []
					for mesh in model.find_children("*", "MeshInstance3D", true, false):
						if mesh.name.begins_with("Sole"): soles.append(mesh)
					assert(soles.size() == 2)
					var skeleton := soles[0].get_node(soles[0].skeleton) as Skeleton3D
					var previous: Array[Vector3] = []
					for sole in soles: previous.append(_candidate_vertex(sole, skeleton, _sole_vertex(sole, 0)))
					body.start_locomotion(gait)
					var penetration := 0.0
					var lowest_height := 0.0
					var point_speed := 0.0
					var first_point_step := 0.0
					var ticks := ceili(hz * 0.4)
					for tick in range(ticks):
						await physics_frame
						await process_frame
						skeleton.force_update_all_bone_transforms()
						var low := INF
						for i in range(soles.size()):
							var point := _candidate_vertex(soles[i], skeleton, _sole_vertex(soles[i], 0))
							var step := point.distance_to(previous[i])
							point_speed = maxf(point_speed, step * hz)
							if tick == 0: first_point_step = maxf(first_point_step, step)
							penetration = maxf(penetration, -point.y)
							low = minf(low, point.y)
							previous[i] = point
						lowest_height = maxf(lowest_height, low)
					var direction := before_yaw * Vector3(0, 0, 1)
					var expected: Vector3 = before_position + direction * body.locomotion_speed * ticks / hz
					var travel_error := Vector2(body.position.x - expected.x, body.position.z - expected.z).length()
					var yaw_error := before_yaw.angle_to(body.quaternion)
					assert(travel_error < 0.001 and yaw_error < 0.001)
					assert(body.playback.get_current_node() == gait)
					reports.append({"physics_hz": hz, "turn": action, "release_phase": phase, "gait": gait, "travel_error_m": travel_error, "yaw_error_rad": yaw_error, "penetration_m": penetration, "maximum_lowest_sole_height_m": lowest_height, "maximum_sole_point_speed_m_s": point_speed, "first_sole_step_m": first_point_step, "matched_contact_phase": body.match_contact_phase})
					print("TURN_GAIT_SAMPLE ", reports[-1])
					body.queue_free()
					await process_frame
	var file := FileAccess.open(FOLDER + ("/matched_phase_transition_audit.json" if OS.get_cmdline_user_args().has("--match-contact-phase") else "/locomotion_transition_audit.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(reports, "\t"))
	print("TURN_GAIT_AUDIT_COMPLETE ", reports.size())
	quit()

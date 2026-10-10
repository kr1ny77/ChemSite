extends "res://tools/validation/cartoon_turn_candidate_smoke.gd"

const DRIVER = preload("res://tools/validation/turn_motion_candidate_driver.gd")
const FOLDER := "res://artifacts/cartoon-turn-root-candidate"

func _initialize() -> void:
	create_timer(120.0).timeout.connect(func(): quit(1))
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
	for hz in ([60] if OS.get_cmdline_user_args().has("--quick") else [30, 60, 120]):
		Engine.physics_ticks_per_second = hz
		for action in ["TurnLeftStep", "TurnRightStep"]:
			for phase in ([0.55] if OS.get_cmdline_user_args().has("--quick") else [0.2, 0.55, 0.9, 1.0]):
				for gait in ["Walk", "Run"]:
					var document := GLTFDocument.new()
					var state := GLTFState.new()
					assert(document.append_from_file(FOLDER + "/cartoon_turn.glb", state) == OK)
					var model := document.generate_scene(state, 384.0)
					var body = DRIVER.new()
					root.add_child(body)
					body.configure(model, action)
					assert(not OS.get_cmdline_user_args().has("--ground-transition") or body.grounding != null)
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
					var evaluated: Array[PackedVector3Array] = []
					var observed_tick := [-1]
					var final_length_error := [0.0]
					skeleton.skeleton_updated.connect(func() -> void:
						evaluated.clear()
						for sole in soles: evaluated.append(_sole_points(sole, skeleton))
						observed_tick[0] = Engine.get_physics_frames()
						for side in ["l", "r"]:
							var hip := skeleton.get_bone_global_pose(skeleton.find_bone("thigh_" + side)).origin
							var knee := skeleton.get_bone_global_pose(skeleton.find_bone("calf_" + side)).origin
							var ankle := skeleton.get_bone_global_pose(skeleton.find_bone("foot_" + side)).origin
							final_length_error[0] = maxf(final_length_error[0], maxf(absf(hip.distance_to(knee) - 0.15), absf(knee.distance_to(ankle) - 0.14)))
					)
					var previous: Array[PackedVector3Array] = []
					for sole in soles: previous.append(_sole_points(sole, skeleton))
					body.start_locomotion(gait)
					var penetration := 0.0
					var peak: Dictionary = {}
					var lowest_height := 0.0
					var point_speed := 0.0
					var first_point_step := 0.0
					var ticks := ceili(hz * 0.4)
					for tick in range(ticks):
						await physics_frame
						await process_frame
						assert(evaluated.size() == 2 and observed_tick[0] == Engine.get_physics_frames(), "Final skeleton tick missing")
						var low := INF
						for i in range(soles.size()):
							var points := evaluated[i]
							for v in range(points.size()):
								var point := points[v]
								var step := point.distance_to(previous[i][v])
								point_speed = maxf(point_speed, step * hz)
								if tick == 0: first_point_step = maxf(first_point_step, step)
								if -point.y > penetration:
									penetration = -point.y
									peak = {"time_s": body.locomotion_elapsed, "fading_from": body.playback.get_fading_from_node(), "gait_time_s": body.playback.get_current_play_position(), "sole": soles[i].name, "vertex": v, "world_point": str(point), "body_y": body.position.y}
								low = minf(low, point.y)
							previous[i] = points
						lowest_height = maxf(lowest_height, low)
					var direction := before_yaw * Vector3(0, 0, 1)
					var expected: Vector3 = before_position + direction * body.locomotion_speed * ticks / hz
					var travel_error := Vector2(body.position.x - expected.x, body.position.z - expected.z).length()
					var yaw_error := before_yaw.angle_to(body.quaternion)
					assert(travel_error < 0.001 and yaw_error < 0.001)
					assert(body.playback.get_current_node() == gait)
					if body.grounding != null:
						assert(penetration < 0.003, "Corrected sole penetrates floor")
						assert(final_length_error[0] < 0.00001, "Corrected final leg lengths changed")
						assert(body.grounding.maximum_lift < 0.035, "Transition lift exceeds bounded pose correction")
					reports.append({"physics_hz": hz, "turn": action, "release_phase": phase, "gait": gait, "travel_error_m": travel_error, "yaw_error_rad": yaw_error, "penetration_m": penetration, "maximum_lowest_sole_height_m": lowest_height, "maximum_sole_point_speed_m_s": point_speed, "first_sole_step_m": first_point_step, "matched_contact_phase": body.match_contact_phase, "peak_penetration": peak, "sole_vertices": previous[0].size() + previous[1].size(), "grounding_enabled": body.grounding != null, "maximum_leg_length_error_m": final_length_error[0], "maximum_lift_m": body.grounding.maximum_lift if body.grounding != null else 0.0})
					print("TURN_GAIT_SAMPLE ", reports[-1])
					body.queue_free()
					await process_frame
	var filename := "/grounded_sole_transition_audit.json" if OS.get_cmdline_user_args().has("--ground-transition") else ("/matched_complete_sole_transition_audit.json" if OS.get_cmdline_user_args().has("--match-contact-phase") else "/complete_sole_transition_audit.json")
	if OS.get_cmdline_user_args().has("--quick"): filename = filename.replace(".json", "_quick.json")
	var file := FileAccess.open(FOLDER + filename, FileAccess.WRITE)
	file.store_string(JSON.stringify(reports, "\t"))
	print("TURN_GAIT_AUDIT_COMPLETE ", reports.size())
	quit()

func _sole_points(sole: MeshInstance3D, skeleton: Skeleton3D) -> PackedVector3Array:
	var transforms: Array[Transform3D] = []
	for bind in range(sole.skin.get_bind_count()):
		var name := sole.skin.get_bind_name(bind)
		var bone := skeleton.find_bone(name) if not name.is_empty() else sole.skin.get_bind_bone(bind)
		transforms.append(skeleton.global_transform * skeleton.get_bone_global_pose(bone) * sole.skin.get_bind_pose(bind))
	var result := PackedVector3Array()
	for surface in range(sole.mesh.get_surface_count()):
		var arrays := sole.mesh.surface_get_arrays(surface)
		var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
		var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
		var influences := bones.size() / vertices.size()
		for vertex in range(vertices.size()):
			var point := Vector3.ZERO
			for influence in range(influences):
				var index := vertex * influences + influence
				if weights[index] > 0.0: point += (transforms[bones[index]] * vertices[vertex]) * weights[index]
			result.append(point)
	return result

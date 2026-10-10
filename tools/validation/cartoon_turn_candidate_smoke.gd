extends "res://tools/validation/player_grounding_smoke.gd"

# Candidate-only import; the production player and its AnimationTree stay unchanged.
func _initialize() -> void:
	create_timer(30.0).timeout.connect(func(): quit(1))
	call_deferred("_run")

func _run() -> void:
	var document := GLTFDocument.new()
	var state := GLTFState.new()
	assert(document.append_from_file("res://artifacts/cartoon-turn-candidate/cartoon_turn.glb", state) == OK)
	var model := document.generate_scene(state, 384.0)
	root.add_child(model)
	await process_frame
	var animations := model.find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer
	var soles: Dictionary = {}
	for mesh in model.find_children("*", "MeshInstance3D", true, false):
		if mesh.name.begins_with("Sole"):
			soles["r" if "-1" in mesh.name else "l"] = mesh
	assert(soles.size() == 2)
	var reports: Array = []
	for action in ["TurnLeftStep", "TurnRightStep"]:
		assert(animations.has_animation(action))
		animations.play(action)
		var length := animations.get_animation(action).length
		assert(absf(length - 0.7552083333) < 0.001)
		var previous: Dictionary = {}
		var height := 0.0
		var drift := 0.0
		for sample in range(233):
			var phase := sample / 232.0
			animations.seek(length * phase, true)
			var side := "l" if phase < 0.4 or phase >= 0.8 else "r"
			var sole := soles[side] as MeshInstance3D
			var skeleton := sole.get_node(sole.skeleton) as Skeleton3D
			skeleton.force_update_all_bone_transforms()
			var point := _candidate_vertex(sole, skeleton, _sole_vertex(sole, 0))
			height = maxf(height, absf(point.y))
			if previous.has(side):
				drift = maxf(drift, point.distance_to(previous[side]))
			previous = {side: point}
		print("TURN_CANDIDATE_METRICS ", action, " height=", height, " drift=", drift)
		if height >= 0.001 or drift >= 0.001:
			push_error("Candidate supporting sole moved")
			quit(1)
			return
		reports.append({"action": action, "duration_s": length, "samples": 233, "height_error_m": height, "support_drift_m": drift})
	var file := FileAccess.open("res://artifacts/cartoon-turn-candidate/native_checks.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(reports, "\t"))
	print("CARTOON_TURN_CANDIDATE_OK ", reports)
	quit()

func _candidate_vertex(sole: MeshInstance3D, skeleton: Skeleton3D, vertex: Vector2i) -> Vector3:
	var arrays := sole.mesh.surface_get_arrays(vertex.x)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
	var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
	var influences := bones.size() / vertices.size()
	var point := Vector3.ZERO
	for influence in range(influences):
		var index := vertex.y * influences + influence
		if weights[index] <= 0.0: continue
		var bind := bones[index]
		var name := sole.skin.get_bind_name(bind)
		var bone := skeleton.find_bone(name) if not name.is_empty() else sole.skin.get_bind_bone(bind)
		assert(bone >= 0)
		point += (skeleton.get_bone_global_pose(bone) * sole.skin.get_bind_pose(bind) * vertices[vertex.y]) * weights[index]
	return skeleton.global_transform * point

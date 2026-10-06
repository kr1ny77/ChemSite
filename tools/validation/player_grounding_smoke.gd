extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	root.add_child(site)
	var player: CharacterBody3D = site.get_node("Player")
	player.controls_enabled = false
	player.position = Vector3(0, 0.1, 1.0)
	for frame in range(30):
		await physics_frame
	var soles: Array[MeshInstance3D] = []
	for mesh in player.find_children("*", "MeshInstance3D", true, false):
		if mesh.name.begins_with("Sole"):
			soles.append(mesh as MeshInstance3D)
	if soles.size() != 2:
		push_error("Two imported cartoon sole meshes required")
		quit(1)
		return
	var animations := player.find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer
	player._animation_tree.active = false
	for clip in ["Idle", "Walk", "Run", "UseStation"]:
		if animations.get_animation(clip).loop_mode != Animation.LOOP_LINEAR:
			push_error("Cyclic player animation does not loop: " + clip)
			quit(1)
			return
	var query := PhysicsRayQueryParameters3D.create(player.global_position + Vector3.UP, player.global_position + Vector3.DOWN, 1)
	var hit := player.get_world_3d().direct_space_state.intersect_ray(query)
	assert(not hit.is_empty(), "Physical walking surface missing")
	var ground: float = hit.position.y
	for clip in ["Idle", "Walk", "Run"]:
		animations.play(clip)
		var duration := animations.get_animation(clip).length
		var maximum_error := 0.0
		for sample in range(417):
			var phase := float(sample) / 416.0
			animations.seek(duration * phase, true)
			for sole in soles:
				var skeleton := sole.get_node(sole.skeleton) as Skeleton3D
				skeleton.force_update_all_bone_transforms()
				var shift := 0.5 if "-1" in sole.name else 0.0
				var height := 0.0
				if clip in ["Walk", "Run"]:
					var support := 0.2 if clip == "Run" else 0.5
					var p := fposmod(phase - 0.25 + shift, 1.0)
					if p >= support:
						height = (0.065 if clip == "Run" else 0.055) * pow(sin(PI * (p - support) / (1.0 - support)), 2)
				maximum_error = maxf(maximum_error, absf(_minimum_skinned_height(sole, skeleton) - ground - height))
		if maximum_error >= 0.003:
			push_error("%s sole profile differs from physical floor by %.4f m" % [clip, maximum_error])
			quit(1)
			return
		print("PLAYER_GROUNDING ", clip, " maximum_error_m=", maximum_error)
	for clip in ["Walk", "Run"]:
		animations.play(clip)
		var duration := animations.get_animation(clip).length
		var stance_length := 0.5 if clip == "Walk" else 0.2
		var nominal_speed: float = player.WALK_NOMINAL_SPEED if clip == "Walk" else player.RUN_NOMINAL_SPEED
		for sole in soles:
			var skeleton := sole.get_node(sole.skeleton) as Skeleton3D
			var vertex := _sole_vertex(sole, 0)
			var start := 0.75 if "-1" in sole.name else 0.25
			var first_point := Vector3.ZERO
			var maximum_drift := 0.0
			for sample in range(105):
				var phase := start + stance_length * float(sample) / 104.0
				animations.seek(fposmod(phase, 1.0) * duration, true)
				skeleton.force_update_all_bone_transforms()
				var point := _skinned_vertex(sole, skeleton, vertex)
				point.z += nominal_speed * (phase - start) * duration
				if sample == 0:
					first_point = point
				maximum_drift = maxf(maximum_drift, Vector2(point.x - first_point.x, point.z - first_point.z).length())
			if maximum_drift >= 0.004:
				push_error("Steady %s sole vertex drifts by %.4f m" % [clip, maximum_drift])
				quit(1)
				return
			print("PLAYER_STANCE ", clip, " sole=", sole.name, " maximum_drift_m=", maximum_drift)
	var duration := animations.get_animation("Walk").length
	animations.stop()
	animations.play("Walk")
	animations.advance(duration * 2.37)
	if absf(animations.current_animation_position - duration * 0.37) >= 0.0001:
		push_error("Walk playback failed to repeat across two cycles")
		quit(1)
		return
	print("PLAYER_WALK_LOOP_OK")
	print("PLAYER_GROUNDING_SMOKE_OK")
	site.queue_free()
	await process_frame
	quit()

func _minimum_skinned_height(shoes: MeshInstance3D, skeleton: Skeleton3D) -> float:
	var transforms: Array[Transform3D] = []
	for index in range(shoes.skin.get_bind_count()):
		var bone := skeleton.find_bone(shoes.skin.get_bind_name(index))
		assert(bone >= 0, "Shoe skin bone missing")
		transforms.append(skeleton.get_bone_global_pose(bone) * shoes.skin.get_bind_pose(index))
	var minimum := INF
	for surface in range(shoes.mesh.get_surface_count()):
		var arrays := shoes.mesh.surface_get_arrays(surface)
		var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
		var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
		var influences := bones.size() / vertices.size()
		for index in range(vertices.size()):
			var deformed := Vector3.ZERO
			for influence in range(influences):
				var skin_index := index * influences + influence
				deformed += (transforms[bones[skin_index]] * vertices[index]) * weights[skin_index]
			minimum = minf(minimum, (skeleton.global_transform * deformed).y)
	return minimum

func _sole_vertex(shoes: MeshInstance3D, side: int) -> Vector2i:
	var result := Vector2i(-1, -1)
	var minimum := INF
	for surface in range(shoes.mesh.get_surface_count()):
		var vertices: PackedVector3Array = shoes.mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX]
		for index in range(vertices.size()):
			if (side == 0 or vertices[index].x * side > 0) and vertices[index].y < minimum:
				minimum = vertices[index].y
				result = Vector2i(surface, index)
	assert(result.x >= 0, "Sole vertex missing")
	return result

func _skinned_vertex(shoes: MeshInstance3D, skeleton: Skeleton3D, vertex: Vector2i) -> Vector3:
	var arrays := shoes.mesh.surface_get_arrays(vertex.x)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
	var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
	var influences := bones.size() / vertices.size()
	var point := Vector3.ZERO
	for influence in range(influences):
		var index := vertex.y * influences + influence
		var bind := bones[index]
		var bone := skeleton.find_bone(shoes.skin.get_bind_name(bind))
		point += (skeleton.get_bone_global_pose(bone) * shoes.skin.get_bind_pose(bind) * vertices[vertex.y]) * weights[index]
	return skeleton.global_transform * point

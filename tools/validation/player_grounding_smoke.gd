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
	var shoes: MeshInstance3D
	for mesh in player.find_children("*", "MeshInstance3D", true, false):
		if "shoes06" in mesh.name:
			shoes = mesh
	assert(shoes != null and shoes.skin != null, "Imported skinned shoes missing")
	var skeleton := shoes.get_node(shoes.skeleton) as Skeleton3D
	var animations := player.find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer
	player._animation_tree.active = false
	var query := PhysicsRayQueryParameters3D.create(player.global_position + Vector3.UP, player.global_position + Vector3.DOWN, 1)
	var hit := player.get_world_3d().direct_space_state.intersect_ray(query)
	assert(not hit.is_empty(), "Physical walking surface missing")
	var ground: float = hit.position.y
	for clip in ["Idle", "Walk"]:
		animations.play(clip)
		var duration := animations.get_animation(clip).length
		var maximum_error := 0.0
		for sample in range(105):
			animations.seek(duration * float(sample) / 104.0, true)
			skeleton.force_update_all_bone_transforms()
			var sole := _minimum_skinned_height(shoes, skeleton)
			maximum_error = maxf(maximum_error, absf(sole - ground))
		assert(maximum_error < 0.003, "%s sole differs from physical floor by %.4f m" % [clip, maximum_error])
		print("PLAYER_GROUNDING ", clip, " maximum_error_m=", maximum_error)
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

extends "res://scripts/player/foot_plant.gd"

# Candidate-only sole-plane correction during the turn/gait crossfade.
const HANDOFF_SECONDS := 0.12

var contacts: Array[Dictionary] = []
var maximum_lift := 0.0
var maximum_flatten_angle := 0.0

func _ready() -> void:
	var skeleton := get_skeleton()
	for sole in player.model.find_children("Sole*", "MeshInstance3D", true, false):
		var side := "r" if "-1" in sole.name else "l"
		var bone := skeleton.find_bone("foot_" + side)
		var points := PackedVector3Array()
		for surface in range(sole.mesh.get_surface_count()):
			var arrays: Array = sole.mesh.surface_get_arrays(surface)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
			var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
			var influences := bones.size() / vertices.size()
			for vertex in range(vertices.size()):
				var point := Vector3.ZERO
				for influence in range(influences):
					var index := vertex * influences + influence
					if weights[index] <= 0.0: continue
					var bind := bones[index]
					var bind_name: StringName = sole.skin.get_bind_name(bind)
					var bind_bone: int = skeleton.find_bone(bind_name) if not bind_name.is_empty() else sole.skin.get_bind_bone(bind)
					assert(bind_bone == bone, "Transition correction requires rigid sole skinning")
					point += (sole.skin.get_bind_pose(bind) * vertices[vertex]) * weights[index]
				points.append(point)
		contacts.append({"hip": skeleton.find_bone("thigh_" + side), "knee": skeleton.find_bone("calf_" + side), "foot": bone, "points": points, "rest_basis": skeleton.get_bone_global_rest(bone).basis})

func _process_modification_with_delta(_delta: float) -> void:
	if player == null or player.locomotion_state.is_empty() or player.locomotion_elapsed > HANDOFF_SECONDS or not player.is_on_floor():
		return
	var skeleton := get_skeleton()
	for contact in contacts:
		var target := skeleton.get_bone_global_pose(contact.foot)
		var relative: Basis = target.basis * contact.rest_basis.inverse()
		var yaw := atan2(relative.z.x, relative.z.z)
		var flat: Basis = Basis(Vector3.UP, yaw) * contact.rest_basis
		maximum_flatten_angle = maxf(maximum_flatten_angle, target.basis.get_rotation_quaternion().angle_to(flat.get_rotation_quaternion()))
		target.basis = flat
		var world := skeleton.global_transform * target
		var query := PhysicsRayQueryParameters3D.create(world.origin + Vector3.UP, world.origin + Vector3.DOWN, 1)
		var hit := player.get_world_3d().direct_space_state.intersect_ray(query)
		if hit.is_empty() or hit.normal.dot(Vector3.UP) < 0.99: continue
		var low := INF
		for point in contact.points: low = minf(low, (world * point).y)
		var lift := maxf(0.0, float(hit.position.y) - low)
		maximum_lift = maxf(maximum_lift, lift)
		target.origin += skeleton.global_basis.inverse() * Vector3(0, lift, 0)
		_solve_leg(skeleton, contact, target)

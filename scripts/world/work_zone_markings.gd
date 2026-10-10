extends Node3D
## Painted bay boundaries connect each authored equipment cluster to its work area.
## Flat visual marks share the physical floor and leave traversal unchanged.
const ZONES := [
	{"center": Vector3(-9.6, 0, 0.4), "size": Vector2(3.1, 2.3), "color": Color("599f9e")},
	{"center": Vector3(6.15, 0, -0.05), "size": Vector2(7.0, 3.6), "color": Color("c39551")},
	{"center": Vector3(9.7, 0, 3.0), "size": Vector2(3.0, 2.2), "color": Color("599f9e")},
]

func _ready() -> void:
	for index in range(ZONES.size()):
		_build_zone(index, ZONES[index])

func _build_zone(index: int, zone: Dictionary) -> void:
	var segments: Array[Transform3D] = []
	var half: Vector2 = zone.size * 0.5
	# Corner brackets preserve open approaches and keep the floor visually quiet.
	for x_sign in [-1.0, 1.0]:
		for z_sign in [-1.0, 1.0]:
			var corner: Vector3 = zone.center + Vector3(x_sign * half.x, 0.006, z_sign * half.y)
			segments.append(Transform3D(Basis(), corner + Vector3(-x_sign * 0.3, 0, 0)))
			segments.append(Transform3D(Basis(Vector3.UP, PI * 0.5), corner + Vector3(0, 0, -z_sign * 0.3)))
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.7, 0.002, 0.065)
	var material := StandardMaterial3D.new()
	material.albedo_color = zone.color
	material.roughness = 0.95
	var batch := MultiMesh.new()
	batch.transform_format = MultiMesh.TRANSFORM_3D
	batch.mesh = mesh
	batch.instance_count = segments.size()
	for segment in range(segments.size()):
		batch.set_instance_transform(segment, segments[segment])
	var visual := MultiMeshInstance3D.new()
	visual.name = "WorkBay%d" % index
	visual.multimesh = batch
	visual.material_override = material
	visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(visual)

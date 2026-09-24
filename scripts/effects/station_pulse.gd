extends Node3D

func start(success: bool) -> void:
	var tint := Color("55e5bd") if success else Color("f2a35a")
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(tint.r, tint.g, tint.b, 0.72)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.emission_enabled = true
	material.emission = tint
	material.emission_energy_multiplier = 2.2
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	var mesh := TorusMesh.new()
	mesh.inner_radius = 1.02
	mesh.outer_radius = 1.12
	mesh.rings = 8
	mesh.ring_segments = 48
	var halo := MeshInstance3D.new()
	halo.mesh = mesh
	halo.material_override = material
	halo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(halo)
	scale = Vector3(0.35, 1.0, 0.35)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector3(1.12, 1.0, 1.12), 0.42).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(material, "albedo_color:a", 0.0, 0.42).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(queue_free)

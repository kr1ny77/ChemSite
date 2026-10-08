extends GPUParticles3D

func start(success: bool) -> void:
	var tint := Color("75e6ba") if success else Color("e99352")
	amount = 14 if success else 8
	lifetime = 0.68
	one_shot = true
	explosiveness = 1.0
	local_coords = false
	visibility_aabb = AABB(Vector3(-2, -1, -2), Vector3(4, 4, 4))
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	emitting = false
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = 0.5
	process.direction = Vector3.UP
	process.spread = 55.0
	process.initial_velocity_min = 1.4
	process.initial_velocity_max = 2.6
	process.gravity = Vector3(0, -2.5, 0)
	process.scale_min = 0.7
	process.scale_max = 1.3
	var gradient := Gradient.new()
	gradient.set_color(0, tint)
	gradient.set_color(1, Color(tint.r, tint.g, tint.b, 0.0))
	var ramp := GradientTexture1D.new()
	ramp.gradient = gradient
	process.color_ramp = ramp
	process_material = process
	var bead := SphereMesh.new()
	bead.radius = 0.05
	bead.height = 0.1
	bead.radial_segments = 8
	bead.rings = 4
	var finish := StandardMaterial3D.new()
	finish.albedo_color = Color.WHITE
	finish.vertex_color_use_as_albedo = true
	finish.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	finish.emission_enabled = true
	finish.emission = tint
	finish.emission_energy_multiplier = 1.35
	finish.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bead.material = finish
	draw_pass_1 = bead
	finished.connect(queue_free)
	emitting = true
	call_deferred("restart")

extends SceneTree

const BURST = preload("res://scripts/effects/answer_burst.gd")
var origin_tick := -1
var last_tick := -1
var effects: Array[GPUParticles3D] = []
var folder := "res://artifacts/answer-burst-fade"

func _initialize() -> void:
	call_deferred("_setup")

func _setup() -> void:
	Engine.physics_ticks_per_second = 60
	var scene := Node3D.new()
	root.add_child(scene)
	var camera := Camera3D.new()
	scene.add_child(camera)
	camera.position = Vector3(0, 2, 7)
	camera.look_at(Vector3(0, .9, 0))
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 5.5
	var environment := WorldEnvironment.new()
	var settings := Environment.new()
	settings.background_mode = Environment.BG_COLOR
	settings.background_color = Color("101820")
	environment.environment = settings
	scene.add_child(environment)
	var baseline := OS.get_cmdline_user_args().has("--opaque-baseline")
	if baseline: folder += "-opaque-baseline"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	for correct in [true, false]:
		var burst := BURST.new()
		scene.add_child(burst)
		burst.position.x = -1.2 if correct else 1.2
		burst.start(correct)
		if baseline:
			burst.draw_pass_1.material.albedo_color = Color("75e6ba") if correct else Color("e99352")
			burst.draw_pass_1.material.vertex_color_use_as_albedo = false
			burst.draw_pass_1.material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
		effects.append(burst)
	origin_tick = Engine.get_physics_frames()
	process_frame.connect(_tick)

func _tick() -> void:
	var tick := Engine.get_physics_frames()
	if tick == last_tick: return
	last_tick = tick
	var elapsed := tick - origin_tick
	if elapsed in [6, 18, 30, 36, 90]:
		RenderingServer.force_draw()
		var image := root.get_viewport().get_texture().get_image()
		if image.save_png(folder + "/tick-%03d.png" % elapsed) != OK:
			push_error("Answer burst image write failed")
			quit(1)
			return
	if elapsed >= 90:
		for effect in effects:
			if is_instance_valid(effect):
				push_error("Answer burst did not finish and free")
				quit(1)
				return
		print("ANSWER_BURST_FADE_CAPTURE_OK cleanup_ticks=", elapsed)
		quit()

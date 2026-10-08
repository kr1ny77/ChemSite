extends SceneTree

var site: Node3D
var player: CharacterBody3D
var camera: Camera3D
var segment := -1
var last_tick := -1
var ticks := 0
var loops := 0
var previous_phase := 0.0
var seen := {}
var folder := "res://artifacts/complete-gait-frames-final"

func _initialize() -> void:
	call_deferred("_setup")

func _setup() -> void:
	Engine.physics_ticks_per_second = 60
	site = (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	root.add_child(site)
	root.focus_exited.disconnect(site._pause_on_focus_loss)
	site.set_process(false)
	site.get_node("CanvasLayer").visible = false
	for mesh in site.get_node("World").find_children("*", "MeshInstance3D", true, false):
		var bounds: AABB = mesh.global_transform * mesh.get_aabb()
		if bounds.size.y > .12: mesh.visible = false
	player = site.get_node("Player")
	camera = site.get_node("CameraRig/Camera3D")
	camera.size = 2.8
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	process_frame.connect(_tick)
	_next()

func _next() -> void:
	Input.action_release("move_right")
	segment += 1
	if segment >= 4:
		print("COMPLETE_GAITS_CAPTURE_OK")
		quit()
		return
	ticks = 0
	loops = 0
	previous_phase = 0.0
	seen.clear()
	player.global_position = Vector3(-5, .04, 0)
	player.velocity = Vector3.ZERO
	player.controls_enabled = true
	Input.action_press("move_right", .3 if segment % 2 == 0 else 1.0)

func _tick() -> void:
	var tick := Engine.get_physics_frames()
	if tick == last_tick or segment >= 4: return
	last_tick = tick
	ticks += 1
	var target := player.global_position + Vector3(0, .95, 0)
	camera.global_position = target + (Vector3(3, 1.65, 5) if segment < 2 else Vector3(5, 1.25, .5))
	camera.look_at(target)
	var action := "Walk" if segment % 2 == 0 else "Run"
	if ticks > 240:
		push_error("Complete gait capture timed out: " + action)
		quit(1)
		return
	if ticks < 30 or str(player._playback.get_current_node()) != action: return
	var phase := fposmod(player._playback.get_current_play_position() / float(player._clip_lengths[action]), 1.0)
	if phase < previous_phase - .5: loops += 1
	previous_phase = phase
	var bin := floori(phase * 12.0)
	if loops == 1 and not seen.has(bin):
		RenderingServer.force_draw()
		var image := root.get_viewport().get_texture().get_image()
		var view := "quarter" if segment < 2 else "front"
		if image.save_png(folder + "/%s-%s-%02d.png" % [view, action, bin]) != OK:
			push_error("Gait capture write failed")
			quit(1)
			return
		seen[bin] = true
	if loops >= 2:
		if seen.size() < 10:
			push_error("Gait phase coverage too sparse: " + str(seen.size()))
			quit(1)
			return
		print("COMPLETE_GAIT_OK action=", action, " view=", "quarter" if segment < 2 else "front", " cycles=", loops, " phase_bins=", seen.size(), " distinct_ticks=", ticks)
		_next()

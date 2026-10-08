extends SceneTree

var site: Node3D
var player: CharacterBody3D
var camera: Camera3D
var segment := -1
var elapsed := 0.0
var captured_sample := -1
var started := false
var segment_draw_start := 0
var draw_count := 0
var last_physics_tick := -1
var folder := "res://artifacts/upright-action-frames-final"
var actions := ["Interact", "PickUp", "UseStation"]

func _initialize() -> void:
	call_deferred("_setup")

func _setup() -> void:
	Engine.physics_ticks_per_second = 60
	site = (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	root.add_child(site)
	root.focus_exited.disconnect(site._pause_on_focus_loss)
	site.get_node("CanvasLayer").visible = false
	site.set_process(false)
	for mesh in site.get_node("World").find_children("*", "MeshInstance3D", true, false):
		var bounds: AABB = mesh.global_transform * mesh.get_aabb()
		if bounds.size.y > .12: mesh.visible = false
	player = site.get_node("Player")
	player.global_position = Vector3.ZERO
	player.controls_enabled = false
	camera = site.get_node("CameraRig/Camera3D")
	camera.size = 2.8
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	process_frame.connect(_tick)
	_next_segment()

func _next_segment() -> void:
	segment += 1
	if segment == 6:
		print("UPRIGHT_ACTIONS_CAPTURE_OK")
		quit()
		return
	elapsed = 0.0
	captured_sample = -1
	started = false
	segment_draw_start = draw_count
	player.clear_reaction()
	camera.global_position = Vector3(3, 2.6, 5) if segment < 3 else Vector3(5, 2.2, .5)
	camera.look_at(Vector3(0, .95, 0))

func _advance() -> void:
	if segment < 0 or segment >= 6: return
	elapsed = float(draw_count - segment_draw_start) / 60.0
	var action: String = actions[segment % 3]
	if not started and elapsed >= .35:
		if str(player._playback.get_current_node()) != "Idle":
			push_error("Action failed to return to Idle")
			quit(1)
			return
		started = true
		player._reaction_state = action
		player._travel(action)
	if elapsed >= .35 + float(player._clip_lengths[action]) + .3:
		var rendered := draw_count - segment_draw_start
		if rendered < 50:
			push_error("Action capture omitted rendered time")
			quit(1)
			return
		print("UPRIGHT_ACTION_CAPTURE_OK segment=", segment, " action=", action, " distinct_physics_ticks=", rendered)
		_next_segment()
	return

func _tick() -> void:
	var tick := Engine.get_physics_frames()
	if tick == last_physics_tick: return
	last_physics_tick = tick
	draw_count += 1
	_advance()
	RenderingServer.force_draw()
	_capture()

func _capture() -> void:
	if segment < 0 or segment >= 6 or not started: return
	var sample := floori((elapsed - .35) * 10.0)
	if sample == captured_sample: return
	captured_sample = sample
	var action: String = actions[segment % 3]
	var view := "front" if segment < 3 else "side"
	var image := root.get_viewport().get_texture().get_image()
	var error := image.save_png(folder + "/%s-%s-%03d.png" % [view, action, sample])
	if error != OK:
		push_error("Action image write failed")
		quit(1)

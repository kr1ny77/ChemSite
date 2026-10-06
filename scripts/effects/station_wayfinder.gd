extends Node3D

const ARROW = preload("res://scripts/effects/station_arrow.gd")
var target_station_id := ""
var reduced_motion := false
var _camera: Camera3D
var _arrow: Control
var _ring: MeshInstance3D
var _time := 0.0
var _enabled := false

func _ready() -> void:
	_ring = MeshInstance3D.new()
	_ring.name = "Target ground outline"
	var mesh := TorusMesh.new()
	mesh.inner_radius = 1.15
	mesh.outer_radius = 1.21
	mesh.rings = 48
	mesh.ring_segments = 6
	_ring.mesh = mesh
	_ring.position.y = 0.09
	_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color("ffcc48")
	_ring.material_override = material
	add_child(_ring)
	var overlay := CanvasLayer.new()
	# Navigation feedback stays behind the modal HUD (layer 1).
	overlay.layer = 0
	add_child(overlay)
	_arrow = ARROW.new() as Control
	overlay.add_child(_arrow)
	set_process(false)
	_ring.hide()
	_arrow.hide()

func show_station(station: Dictionary, camera: Camera3D, active: bool) -> void:
	target_station_id = str(station.get("id", ""))
	_camera = camera
	_enabled = active and not station.is_empty()
	if _enabled:
		global_position = station.position
	_ring.visible = _enabled
	_arrow.visible = _enabled
	set_process(_enabled)
	if _enabled:
		_position_arrow()

func _process(delta: float) -> void:
	if not reduced_motion:
		_time += delta
	_position_arrow()

func _position_arrow() -> void:
	var anchor := global_position + Vector3(0, 2.8, 0)
	if _camera == null or _camera.is_position_behind(anchor):
		_arrow.hide()
		return
	_arrow.show()
	var point := _camera.unproject_position(anchor)
	var viewport_size := get_viewport().get_visible_rect().size
	var hover := 0.0 if reduced_motion else sin(_time * 2.6) * 4.0
	_arrow.position = Vector2(clampf(point.x - 28.0, 8.0, viewport_size.x - 64.0), clampf(point.y - 52.0 + hover, 112.0, viewport_size.y - 60.0))

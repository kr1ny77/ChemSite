extends Node

@export var camera_path: NodePath = NodePath("../Camera3D")
@export var player_path: NodePath = NodePath("../../Player")
@export_range(0.0, 0.95) var obscured_transparency: float = 0.94
@export var response: float = 12.0
var reduced_motion := false
var _occluders: Array[MeshInstance3D] = []
@onready var _camera: Camera3D = get_node(camera_path)
@onready var _player: Node3D = get_node(player_path)

func _ready() -> void:
	process_priority = 1
	call_deferred("refresh_occluders")

func refresh_occluders() -> void:
	_occluders.clear()
	for mesh in get_tree().get_nodes_in_group("player_camera_occluder"):
		if mesh is MeshInstance3D:
			_occluders.append(mesh)

func _process(delta: float) -> void:
	var rays: Array[Vector3] = []
	var right := _camera.global_basis.x
	for height in [0.65, 1.1, 1.5]:
		for offset in [-0.23, 0.0, 0.23]:
			var target: Vector3 = _player.global_position + Vector3.UP * height + right * offset
			rays.append(_camera.project_ray_origin(_camera.unproject_position(target)))
			rays.append(target)
	for mesh in _occluders:
		if not is_instance_valid(mesh) or not mesh.is_visible_in_tree():
			continue
		var inverse := mesh.global_transform.affine_inverse()
		var bounds := mesh.get_aabb().grow(0.025)
		var obstructs := false
		for index in range(0, rays.size(), 2):
			if bounds.intersects_segment(inverse * rays[index], inverse * rays[index + 1]) != null:
				obstructs = true
				break
		var target := obscured_transparency if obstructs else 0.0
		mesh.transparency = target if reduced_motion else lerpf(mesh.transparency, target, 1.0 - exp(-response * delta))
		if absf(mesh.transparency - target) < 0.001:
			mesh.transparency = target

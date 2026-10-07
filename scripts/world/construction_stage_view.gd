extends Node

var stage: int = 0
var _parts: Array[Node3D] = []
var _rail: Node3D
var _formwork: Node3D

func configure(model: Node3D, initial_stage: int) -> void:
	_parts.clear()
	for index in range(6):
		var part := model.find_child("Stage%d" % index, true, false) as Node3D
		if part == null:
			push_error("Construction asset missing Stage%d" % index)
			return
		_parts.append(part)
	_rail = model.find_child("TemporaryRearRail", true, false) as Node3D
	_formwork = model.find_child("TemporaryFormwork", true, false) as Node3D
	set_stage(initial_stage)

func set_stage(value: int) -> void:
	stage = clampi(value, 0, 5)
	for index in range(_parts.size()):
		_parts[index].visible = index <= stage
	if _rail != null: _rail.visible = stage < 3
	if _formwork != null: _formwork.visible = stage < 2

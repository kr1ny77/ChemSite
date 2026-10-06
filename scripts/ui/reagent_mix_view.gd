extends VBoxContainer

signal mixed

const OBSERVATION_VIEW = preload("res://scripts/ui/mixing_observation_view.gd")
var _visual: Dictionary = {}
var reduced_motion := false

var _reagents: Array[String] = []
var _selected: Array[String] = []
var _observation: String = ""
var _status: Label
var _choices: GridContainer
var _mixed: bool = false

func configure(parameters: Dictionary, static_motion: bool = false) -> void:
	reduced_motion = static_motion
	_visual = parameters.get("mixingVisual", {})
	_reagents.clear()
	for reagent in parameters.get("mixingReagents", []):
		_reagents.append(str(reagent))
	_observation = str(parameters.get("mixingObservation", ""))
	_build(parameters.get("mixingOptions", []))

func is_mixed() -> bool:
	return _mixed

func focus_first() -> void:
	if _choices.get_child_count() > 0:
		(_choices.get_child(0) as Button).grab_focus()

func _build(options: Array) -> void:
	add_theme_constant_override("separation", 6)
	_status = Label.new()
	_status.text = "ВИРТУАЛЬНЫЕ ПРОБЫ · ВЫБЕРИ ДВА РЕАГЕНТА"
	_status.add_theme_font_size_override("font_size", 16)
	_status.add_theme_color_override("font_color", Color("243b43"))
	add_child(_status)
	_choices = GridContainer.new()
	_choices.name = "Choices"
	_choices.columns = 2
	_choices.add_theme_constant_override("h_separation", 8)
	_choices.add_theme_constant_override("v_separation", 8)
	add_child(_choices)
	for option in options:
		var reagent := str(option)
		var button := Button.new()
		button.text = reagent
		button.custom_minimum_size = Vector2(140, 44)
		button.add_theme_font_size_override("font_size", 19)
		button.pressed.connect(_select.bind(reagent))
		_choices.add_child(button)

func _select(reagent: String) -> void:
	if _mixed or _selected.has(reagent):
		return
	_selected.append(reagent)
	if _selected.size() < 2:
		_status.text = "ВЫБРАНО: %s · ВЫБЕРИ ВТОРУЮ ПРОБУ" % reagent
		return
	var expected := _reagents.duplicate()
	var selected := _selected.duplicate()
	expected.sort()
	selected.sort()
	if selected == expected:
		_mixed = true
		_status.text = "НАБЛЮДЕНИЕ: " + _observation + " · ЗАПИШИ УРАВНЕНИЕ"
		_choices.hide()
		if not _visual.is_empty():
			var observation := OBSERVATION_VIEW.new() as Control
			observation.name = "ObservationVisual"
			observation.configure(_visual, reduced_motion)
			add_child(observation)
		mixed.emit()
	else:
		_status.text = "ЭТА ПАРА НЕ СООТВЕТСТВУЕТ ЗАДАНИЮ · ВЫБЕРИ СНОВА"
		_selected.clear()

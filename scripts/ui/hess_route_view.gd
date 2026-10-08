extends VBoxContainer

signal route_completed

var _start: String
var _target: String
var _current: String
var _edges: Array[Dictionary] = []
var _route: Array[Dictionary] = []
var _readout: Label
var _choices: GridContainer
var _reset: Button
var _complete := false

func configure(parameters: Dictionary) -> void:
	_start = str(parameters.get("hessStart", ""))
	_target = str(parameters.get("hessEnd", ""))
	assert(not _start.is_empty() and not _target.is_empty() and _start != _target)
	_current = _start
	for entry in parameters.get("hessEdges", []):
		var edge: Dictionary = entry
		var from_node := str(edge.get("from", ""))
		var to_node := str(edge.get("to", ""))
		var delta := int(edge.get("deltaH", 0))
		assert(from_node != to_node)
		_edges.append({"from": from_node, "to": to_node, "deltaH": delta})
		_edges.append({"from": to_node, "to": from_node, "deltaH": -delta})
	_build()

func is_ready() -> bool:
	return _complete

func selected_deltas() -> Array[int]:
	var values: Array[int] = []
	for edge in _route:
		values.append(int(edge.deltaH))
	return values

func focus_first() -> void:
	for button in _choices.get_children():
		if button is Button and not button.disabled:
			button.grab_focus()
			return

func choose_step(from_node: String, to_node: String) -> void:
	if _complete or from_node != _current:
		return
	for edge in _edges:
		if edge.from == from_node and edge.to == to_node:
			_route.append(edge)
			_current = to_node
			_complete = _current == _target
			_refresh()
			if _complete:
				route_completed.emit()
			return

func reset_route() -> void:
	if _complete:
		return
	_route.clear()
	_current = _start
	_refresh()

func _build() -> void:
	add_theme_constant_override("separation", 6)
	_readout = Label.new()
	_readout.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_readout.add_theme_font_size_override("font_size", 16)
	_readout.add_theme_color_override("font_color", Color("243b43"))
	add_child(_readout)
	_choices = GridContainer.new()
	_choices.name = "Choices"
	_choices.columns = 2
	_choices.add_theme_constant_override("h_separation", 8)
	_choices.add_theme_constant_override("v_separation", 8)
	add_child(_choices)
	for edge in _edges:
		var button := Button.new()
		button.text = "%s → %s   %s kJ" % [edge.from, edge.to, _signed(int(edge.deltaH))]
		button.custom_minimum_size = Vector2(0, 46)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_style_button(button, Color("c3dbd3"))
		button.pressed.connect(choose_step.bind(str(edge.from), str(edge.to)))
		_choices.add_child(button)
	_reset = Button.new()
	_reset.name = "ResetButton"
	_reset.text = "СБРОСИТЬ МАРШРУТ"
	_reset.custom_minimum_size = Vector2(0, 44)
	_style_button(_reset, Color("dce8de"))
	_reset.pressed.connect(reset_route)
	add_child(_reset)
	_refresh()

func _refresh() -> void:
	if _complete:
		var terms: Array[String] = []
		for edge in _route:
			terms.append("(%s)" % _signed(int(edge.deltaH)))
		_readout.text = "ПУТЬ %s → %s: ΔH = %s = ? kJ" % [_start, _target, " + ".join(terms)]
		_reset.hide()
	else:
		_readout.text = "ЗАКОН ГЕССА · ПОСТРОЙ ПУТЬ %s → %s · ТЕКУЩИЙ УЗЕЛ: %s" % [_start, _target, _current]
	for index in range(_choices.get_child_count()):
		var button := _choices.get_child(index) as Button
		button.disabled = _complete or str(_edges[index].from) != _current

func _signed(value: int) -> String:
	return "+%d" % value if value >= 0 else "−%d" % abs(value)

func _style_button(button: Button, color: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = color
	normal.set_corner_radius_all(7)
	normal.set_content_margin_all(8)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = color.lightened(0.12)
	var disabled := normal.duplicate() as StyleBoxFlat
	disabled.bg_color = Color("b4b3ad")
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("font_color", Color("173744"))
	button.add_theme_color_override("font_hover_color", Color("173744"))
	button.add_theme_color_override("font_pressed_color", Color("173744"))
	button.add_theme_color_override("font_focus_color", Color("173744"))
	button.add_theme_color_override("font_disabled_color", Color("575c58"))

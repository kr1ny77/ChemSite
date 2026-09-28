extends HBoxContainer

signal inspected

var _steps: Array = []
var _index: int = 0
var _readout: Label
var _next: Button

func configure(steps: Array) -> void:
	_steps = steps.duplicate(true)
	_index = 0
	_build()

func is_complete() -> bool:
	return _index >= _steps.size()

func focus_stage_button() -> void:
	if _next != null and _next.visible:
		_next.grab_focus()

func _build() -> void:
	add_theme_constant_override("separation", 8)
	_readout = Label.new()
	_readout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_readout.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_readout.add_theme_font_size_override("font_size", 16)
	_readout.add_theme_color_override("font_color", Color("243b43"))
	add_child(_readout)
	_next = Button.new()
	_next.name = "NextButton"
	_next.text = "СЛЕДУЮЩИЙ  →"
	_next.custom_minimum_size = Vector2(170, 48)
	_next.add_theme_font_size_override("font_size", 16)
	var button_style := StyleBoxFlat.new()
	button_style.bg_color = Color("e8a447")
	button_style.set_corner_radius_all(7)
	button_style.set_content_margin_all(8)
	_next.add_theme_stylebox_override("normal", button_style)
	_next.add_theme_stylebox_override("hover", button_style)
	_next.add_theme_color_override("font_color", Color("173744"))
	_next.pressed.connect(reveal_next)
	add_child(_next)
	_update_readout()

func reveal_next() -> void:
	if is_complete():
		return
	_index += 1
	_update_readout()
	if is_complete():
		inspected.emit()

func _update_readout() -> void:
	if is_complete():
		_readout.text = "ЭТАПЫ ИЗУЧЕНЫ · ВЫБЕРИ ОТВЕТ"
		_next.hide()
		return
	var step: Dictionary = _steps[_index]
	_readout.text = "ЭТАП %d/%d · %s: %s" % [_index + 1, _steps.size(), step.get("title", ""), step.get("readout", "")]
	_next.text = "К ОТВЕТУ  →" if _index == _steps.size() - 1 else "СЛЕДУЮЩИЙ  →"

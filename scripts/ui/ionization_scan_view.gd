extends VBoxContainer

signal scans_completed

var _samples: Array[Dictionary] = []
var _scanned: Array[bool] = []
var _status: Label
var _buttons: VBoxContainer
var _readouts: Array[Label] = []

func configure(parameters: Dictionary) -> void:
	for entry in parameters.get("ionizationSamples", []):
		_samples.append(entry)
		_scanned.append(false)
	assert(_samples.size() >= 1 and _samples.size() <= 4)
	_build()

func is_complete() -> bool:
	return not _scanned.has(false)

func focus_first() -> void:
	(_buttons.get_child(0).get_child(0) as Button).grab_focus()

func scan_sample(index: int) -> void:
	if index < 0 or index >= _samples.size() or _scanned[index]:
		return
	_scanned[index] = true
	(_buttons.get_child(index).get_child(0) as Button).disabled = true
	_readouts[index].text = str(_samples[index].observation)
	_status.text = "ИОННЫЙ АНАЛИЗ · %d/%d ОБРАЗЦОВ" % [_scanned.count(true), _samples.size()]
	if is_complete():
		_status.text = "ИОННЫЙ АНАЛИЗ ЗАВЕРШЁН · ВЫБЕРИ ВЫВОД"
		scans_completed.emit()
	else:
		for next_index in range(_samples.size()):
			if not _scanned[next_index]:
				(_buttons.get_child(next_index).get_child(0) as Button).grab_focus()
				break

func _build() -> void:
	add_theme_constant_override("separation", 5)
	_status = Label.new()
	_status.text = "ВИРТУАЛЬНЫЙ ИОННЫЙ АНАЛИЗ · ИССЛЕДУЙ ОБРАЗЦЫ"
	_status.add_theme_font_size_override("font_size", 16)
	_status.add_theme_color_override("font_color", Color("243b43"))
	add_child(_status)
	_buttons = VBoxContainer.new()
	_buttons.name = "SampleRows"
	_buttons.add_theme_constant_override("separation", 5)
	add_child(_buttons)
	for index in range(_samples.size()):
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		_buttons.add_child(row)
		var button := Button.new()
		button.text = "СКАН: " + str(_samples[index].label)
		button.custom_minimum_size = Vector2(165, 50)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.size_flags_stretch_ratio = 0.7
		_style_button(button)
		button.pressed.connect(scan_sample.bind(index))
		row.add_child(button)
		var readout := Label.new()
		readout.text = "ПОКАЗАНИЕ ЗАКРЫТО"
		readout.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		readout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		readout.size_flags_stretch_ratio = 1.3
		readout.add_theme_font_size_override("font_size", 15)
		readout.add_theme_color_override("font_color", Color("243b43"))
		row.add_child(readout)
		_readouts.append(readout)

func _style_button(button: Button) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("e8a447")
	normal.set_corner_radius_all(7)
	normal.set_content_margin_all(8)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("f2b95b")
	var disabled := normal.duplicate() as StyleBoxFlat
	disabled.bg_color = Color("b4b3ad")
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("font_color", Color("173744"))
	button.add_theme_color_override("font_focus_color", Color("173744"))
	button.add_theme_color_override("font_hover_color", Color("173744"))
	button.add_theme_color_override("font_pressed_color", Color("173744"))
	button.add_theme_color_override("font_disabled_color", Color("575c58"))

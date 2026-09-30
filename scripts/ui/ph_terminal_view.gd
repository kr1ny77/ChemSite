extends VBoxContainer

signal readings_completed

var _samples: Array[Dictionary] = []
var _read: Array[bool] = []
var _buttons: HBoxContainer
var _readouts: HBoxContainer
var _status: Label

func configure(parameters: Dictionary) -> void:
	for entry in parameters.get("phSamples", []):
		_samples.append(entry)
		_read.append(false)
	assert(_samples.size() >= 1 and _samples.size() <= 2)
	_build()

func is_complete() -> bool:
	return not _read.has(false)

func focus_first() -> void:
	(_buttons.get_child(0) as Button).grab_focus()

func read_sample(index: int) -> void:
	if index < 0 or index >= _samples.size() or _read[index]:
		return
	_read[index] = true
	var button := _buttons.get_child(index) as Button
	button.disabled = true
	var sample: Dictionary = _samples[index]
	var output := _readouts.get_child(index) as Label
	output.text = "%s  ·  pH %s" % [str(sample.label), str(sample.value)]
	output.show()
	if is_complete():
		_status.text = "ИЗМЕРЕНИЯ ГОТОВЫ · ВЫБЕРИ ВЫВОД"
		readings_completed.emit()
	else:
		_status.text = "ИЗМЕРЬ ВТОРОЙ ОБРАЗЕЦ"
		(_buttons.get_child(1 - index) as Button).grab_focus()

func _build() -> void:
	add_theme_constant_override("separation", 6)
	_status = Label.new()
	_status.text = "ВИРТУАЛЬНЫЙ pH-МЕТР · СНИМИ ПОКАЗАНИЯ"
	_status.add_theme_font_size_override("font_size", 16)
	_status.add_theme_color_override("font_color", Color("243b43"))
	add_child(_status)
	_buttons = HBoxContainer.new()
	_buttons.name = "SampleButtons"
	_buttons.add_theme_constant_override("separation", 8)
	add_child(_buttons)
	_readouts = HBoxContainer.new()
	_readouts.name = "Readouts"
	_readouts.add_theme_constant_override("separation", 8)
	add_child(_readouts)
	for index in range(_samples.size()):
		var button := Button.new()
		button.text = "ИЗМЕРИТЬ: " + str(_samples[index].label)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size = Vector2(0, 46)
		_style_button(button)
		button.pressed.connect(read_sample.bind(index))
		_buttons.add_child(button)
		var readout := Label.new()
		readout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		readout.add_theme_font_size_override("font_size", 19)
		readout.add_theme_color_override("font_color", Color("173744"))
		readout.hide()
		_readouts.add_child(readout)

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
	button.add_theme_color_override("font_disabled_color", Color("575c58"))

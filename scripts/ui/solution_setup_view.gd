extends VBoxContainer

signal setup_completed

var _parameters: Dictionary
var _mode: String
var _readout: Label
var _volume_buttons: HBoxContainer
var _formula_buttons: HBoxContainer
var _volume_selected := false
var _ready := false

func configure(parameters: Dictionary) -> void:
	_parameters = parameters.duplicate(true)
	_mode = str(parameters.get("solutionMode", ""))
	assert(_mode in ["mass", "dilution"])
	_build()

func is_ready() -> bool:
	return _ready

func focus_first() -> void:
	(_volume_buttons.get_child(0) as Button).grab_focus()

func select_volume(volume_l: float) -> void:
	if _volume_selected:
		return
	var expected: float = float(_parameters.get("targetVolumeMl", 0.0)) / 1000.0
	if absf(volume_l - expected) > 0.00001:
		_readout.text = "ПРОВЕРЬ ПЕРЕВОД: 1000 мл = 1 л"
		return
	_volume_selected = true
	_readout.text = "ОБЪЁМ ПЕРЕВЕДЁН · ВЫБЕРИ СООТНОШЕНИЕ"
	for button in _volume_buttons.get_children():
		(button as Button).disabled = true
	for button in _formula_buttons.get_children():
		(button as Button).disabled = false
	(_formula_buttons.get_child(0) as Button).grab_focus()

func select_formula(formula: String) -> void:
	if not _volume_selected or _ready:
		return
	var expected := "m = C · V · M" if _mode == "mass" else "C₁V₁ = C₂V₂"
	if formula != expected:
		_readout.text = "ВЫБЕРИ СООТНОШЕНИЕ ДЛЯ ИСКОМОЙ ВЕЛИЧИНЫ"
		return
	_ready = true
	_readout.text = "СООТНОШЕНИЕ ВЫБРАНО · РАССЧИТАЙ ОТВЕТ"
	for button in _formula_buttons.get_children():
		(button as Button).disabled = true
	setup_completed.emit()

func _build() -> void:
	add_theme_constant_override("separation", 6)
	var details := Label.new()
	if _mode == "mass":
		details.text = "РАСТВОР %s · V = %s мл · C = %s моль/л · M = %s г/моль" % [str(_parameters.get("compound", "")), str(_parameters.get("targetVolumeMl", "")), str(_parameters.get("targetConcentration", "")), str(_parameters.get("molarMass", ""))]
	else:
		details.text = "РАЗБАВЛЕНИЕ · C₁ = %s моль/л · C₂ = %s моль/л · V₂ = %s мл" % [str(_parameters.get("stockConcentration", "")), str(_parameters.get("targetConcentration", "")), str(_parameters.get("targetVolumeMl", ""))]
	details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details.add_theme_font_size_override("font_size", 16)
	details.add_theme_color_override("font_color", Color("243b43"))
	add_child(details)
	_readout = Label.new()
	_readout.text = "ШАГ 1 · ПЕРЕВЕДИ ОБЪЁМ В ЛИТРЫ"
	_readout.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_readout.add_theme_font_size_override("font_size", 16)
	_readout.add_theme_color_override("font_color", Color("627679"))
	add_child(_readout)
	_volume_buttons = HBoxContainer.new()
	_volume_buttons.name = "VolumeButtons"
	_volume_buttons.add_theme_constant_override("separation", 8)
	add_child(_volume_buttons)
	for choice in _parameters.get("solutionVolumeChoicesL", []):
		var button := Button.new()
		button.text = "%.3f л" % float(choice)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size.y = 44
		_style_button(button, Color("e8a447"))
		button.pressed.connect(select_volume.bind(float(choice)))
		_volume_buttons.add_child(button)
	var formula_label := Label.new()
	formula_label.text = "ШАГ 2 · ВЫБЕРИ СООТНОШЕНИЕ"
	formula_label.add_theme_font_size_override("font_size", 16)
	formula_label.add_theme_color_override("font_color", Color("627679"))
	add_child(formula_label)
	_formula_buttons = HBoxContainer.new()
	_formula_buttons.name = "FormulaButtons"
	_formula_buttons.add_theme_constant_override("separation", 8)
	add_child(_formula_buttons)
	var formulas := ["m = C · V · M", "m = C / (V · M)"] if _mode == "mass" else ["C₁V₁ = C₂V₂", "C₁ + V₁ = C₂ + V₂"]
	for formula in formulas:
		var button := Button.new()
		button.text = formula
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size.y = 44
		_style_button(button, Color("c3dbd3"))
		button.disabled = true
		button.pressed.connect(select_formula.bind(formula))
		_formula_buttons.add_child(button)

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
	button.add_theme_color_override("font_focus_color", Color("173744"))
	button.add_theme_color_override("font_hover_color", Color("173744"))
	button.add_theme_color_override("font_pressed_color", Color("173744"))
	button.add_theme_color_override("font_disabled_color", Color("575c58"))

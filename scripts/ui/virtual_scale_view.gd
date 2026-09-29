extends VBoxContainer

signal prepared

var _mode: String
var _parameters: Dictionary
var _readout: Label
var _measurement: String = ""
var _prepare: Button
var _formula_buttons: HBoxContainer
var _is_prepared := false
var _formula_selected := false

func configure(parameters: Dictionary) -> void:
	_parameters = parameters.duplicate(true)
	_mode = str(parameters.get("scaleMode", ""))
	assert(_mode in ["mass-to-moles", "moles-to-mass"])
	_build()

func is_ready() -> bool:
	return _formula_selected

func focus_prepare() -> void:
	_prepare.grab_focus()

func prepare_sample() -> void:
	if _is_prepared:
		return
	_is_prepared = true
	_prepare.disabled = true
	var compound := str(_parameters.get("compound", ""))
	var molar_mass := str(_parameters.get("molarMass", ""))
	if _mode == "mass-to-moles":
		_measurement = "ВЕСЫ: %s g %s · СПРАВОЧНИК: M = %s g/mol" % [str(_parameters.get("sampleMass", "")), compound, molar_mass]
	else:
		_measurement = "ЗАДАНО: %s mol %s · СПРАВОЧНИК: M = %s g/mol" % [str(_parameters.get("sampleMoles", "")), compound, molar_mass]
	_readout.text = _measurement
	for button in _formula_buttons.get_children():
		(button as Button).disabled = false
	(_formula_buttons.get_child(0) as Button).grab_focus()

func select_formula(formula: String) -> void:
	if not _is_prepared or _formula_selected:
		return
	var expected := "n = m / M" if _mode == "mass-to-moles" else "m = n · M"
	if formula == expected:
		_formula_selected = true
		_readout.text = _measurement + " · ФОРМУЛА ВЫБРАНА"
		for button in _formula_buttons.get_children():
			(button as Button).disabled = true
		prepared.emit()
	else:
		_readout.text = _measurement + " · ВЫБЕРИ ФОРМУЛУ ДЛЯ ИСКОМОЙ ВЕЛИЧИНЫ"

func _build() -> void:
	add_theme_constant_override("separation", 6)
	_readout = Label.new()
	_readout.text = "ВИРТУАЛЬНЫЕ ВЕСЫ · ПОДГОТОВЬ ИЗМЕРЕНИЕ"
	_readout.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_readout.add_theme_font_size_override("font_size", 16)
	_readout.add_theme_color_override("font_color", Color("243b43"))
	add_child(_readout)
	_prepare = Button.new()
	_prepare.name = "PrepareButton"
	_prepare.text = "ОБНУЛИТЬ ВЕСЫ  →" if _mode == "mass-to-moles" else "ЗАДАТЬ КОЛИЧЕСТВО  →"
	_prepare.custom_minimum_size = Vector2(0, 46)
	_style_button(_prepare, Color("e8a447"))
	_prepare.pressed.connect(prepare_sample)
	add_child(_prepare)
	_formula_buttons = HBoxContainer.new()
	_formula_buttons.name = "FormulaButtons"
	_formula_buttons.add_theme_constant_override("separation", 8)
	add_child(_formula_buttons)
	for formula in ["n = m / M", "m = n · M"]:
		var button := Button.new()
		button.text = formula
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size = Vector2(0, 44)
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

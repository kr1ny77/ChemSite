extends VBoxContainer

signal composition_ready

var _ions: Dictionary
var _selected: Dictionary = {"cation": 0, "anion": 0}
var _status: Label
var _rows: VBoxContainer
var _ready := false

func configure(parameters: Dictionary) -> void:
	_ions = parameters.get("dissociationIons", {}).duplicate(true)
	assert(_ions.has("cation") and _ions.has("anion"))
	assert(int(_ions.cation.count) * int(_ions.cation.charge) + int(_ions.anion.count) * int(_ions.anion.charge) == 0)
	_build()

func is_ready() -> bool:
	return _ready

func focus_first() -> void:
	(_rows.get_child(0).get_child(1) as Button).grab_focus()

func select_count(role: String, count: int) -> void:
	if _ready or not _ions.has(role) or count < 1 or count > 3:
		return
	_selected[role] = count
	if int(_selected.cation) == 0 or int(_selected.anion) == 0:
		_status.text = "ВЫБЕРИ ЧИСЛО КАТИОНОВ И АНИОНОВ"
		return
	var total_charge := int(_selected.cation) * int(_ions.cation.charge) + int(_selected.anion) * int(_ions.anion.charge)
	if int(_selected.cation) == int(_ions.cation.count) and int(_selected.anion) == int(_ions.anion.count) and total_charge == 0:
		_ready = true
		_status.text = "%s × %d  +  %s × %d  ·  ЗАРЯД 0 · ЗАПИШИ УРАВНЕНИЕ" % [str(_ions.cation.label), int(_selected.cation), str(_ions.anion.label), int(_selected.anion)]
		for row in _rows.get_children():
			for child in row.get_children():
				if child is Button:
					child.disabled = true
		composition_ready.emit()
	else:
		_status.text = "ПРОВЕРЬ ИНДЕКСЫ И ЗАРЯДЫ · СУММА ЗАРЯДОВ: %+d" % total_charge

func _build() -> void:
	add_theme_constant_override("separation", 5)
	_status = Label.new()
	_status.text = "ИОННЫЙ СОСТАВ · СОБЕРИ ОДНУ ФОРМУЛЬНУЮ ЕДИНИЦУ"
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.add_theme_font_size_override("font_size", 16)
	_status.add_theme_color_override("font_color", Color("243b43"))
	add_child(_status)
	_rows = VBoxContainer.new()
	_rows.add_theme_constant_override("separation", 5)
	add_child(_rows)
	for role in ["cation", "anion"]:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		_rows.add_child(row)
		var label := Label.new()
		label.text = ("КАТИОН  " if role == "cation" else "АНИОН  ") + str(_ions[role].label) + " · шт."
		label.custom_minimum_size.x = 180
		label.add_theme_font_size_override("font_size", 16)
		label.add_theme_color_override("font_color", Color("243b43"))
		row.add_child(label)
		var group := ButtonGroup.new()
		for count in [1, 2, 3]:
			var button := Button.new()
			button.text = str(count)
			button.toggle_mode = true
			button.button_group = group
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			button.custom_minimum_size = Vector2(0, 38)
			_style_button(button)
			button.pressed.connect(select_count.bind(role, count))
			row.add_child(button)

func _style_button(button: Button) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("e8a447")
	normal.set_corner_radius_all(7)
	normal.set_content_margin_all(7)
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

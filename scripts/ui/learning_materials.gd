extends PanelContainer

var _content: VBoxContainer
var _catalog: Array
var _previous_focus: Control
var initial_material := "periodic"
var _close_button: Button
var _closing := false

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	offset_left = 24
	offset_right = -24
	offset_top = 24
	offset_bottom = -24
	var style := StyleBoxFlat.new()
	style.bg_color = Color("f4efdf")
	style.set_content_margin_all(22)
	style.set_corner_radius_all(16)
	add_theme_stylebox_override("panel", style)
	var material_theme := theme.duplicate() if theme != null else Theme.new()
	material_theme.set_color("font_color", "Label", Color("243b43"))
	material_theme.set_color("font_color", "Button", Color("243b43"))
	material_theme.set_color("font_color", "OptionButton", Color("243b43"))
	var button_style := StyleBoxFlat.new()
	button_style.bg_color = Color("dce8de")
	button_style.set_content_margin_all(12)
	button_style.set_corner_radius_all(8)
	for type_name in ["Button", "OptionButton"]:
		for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
			material_theme.set_color(state, type_name, Color("243b43"))
		material_theme.set_stylebox("normal", type_name, button_style)
		material_theme.set_stylebox("hover", type_name, button_style)
	theme = material_theme
	_catalog = JSON.parse_string(FileAccess.get_file_as_string("res://data/chemistry/materials/catalog.json"))
	_previous_focus = get_viewport().gui_get_focus_owner()
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	add_child(column)
	var row := HBoxContainer.new()
	column.add_child(row)
	var selector := OptionButton.new()
	selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	selector.custom_minimum_size.y = 48
	selector.add_theme_font_size_override("font_size", 22)
	for entry in _catalog:
		selector.add_item(entry.title)
	selector.add_item("Интерактивный черновик")
	selector.item_selected.connect(_display)
	row.add_child(selector)
	var close := Button.new()
	_close_button = close
	close.text = "К ЗАДАНИЮ  ←"
	close.pressed.connect(_close)
	row.add_child(close)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.follow_focus = true
	column.add_child(scroll)
	_content = VBoxContainer.new()
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.add_theme_constant_override("separation", 18)
	scroll.add_child(_content)
	var initial_index := 0
	for index in range(_catalog.size()):
		if _catalog[index].id == initial_material: initial_index = index
	selector.select(initial_index)
	_display(initial_index)
	get_viewport().gui_focus_changed.connect(_confine_focus)
	close.grab_focus()

func _confine_focus(control: Control) -> void:
	if not _closing and control != null and not is_ancestor_of(control):
		_close_button.grab_focus.call_deferred()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()

func _close() -> void:
	_closing = true
	if is_instance_valid(_previous_focus): _previous_focus.grab_focus()
	queue_free()

func _text(value: String, font_size: int = 22) -> Label:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("243b43"))
	return label

func _display(index: int) -> void:
	for child in _content.get_children():
		_content.remove_child(child)
		child.queue_free()
	if index == _catalog.size():
		_content.add_child(preload("res://scripts/ui/learning_workbench.gd").new())
		return
	var entry: Dictionary = _catalog[index]
	_content.add_child(_text(entry.title, 30))
	_content.add_child(_text(entry.text))
	if entry.has("image"):
		var image := TextureRect.new()
		image.texture = load(entry.image)
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		image.custom_minimum_size = Vector2(1100, 770)
		var zoom := HSlider.new()
		zoom.min_value = 0.7
		zoom.max_value = 2.0
		zoom.step = 0.1
		zoom.value = 1.0
		zoom.custom_minimum_size.y = 40
		zoom.tooltip_text = "Масштаб таблицы; прокрутка по горизонтали и вертикали"
		zoom.value_changed.connect(func(value: float) -> void: image.custom_minimum_size = Vector2(1100, 770) * value)
		_content.add_child(_text("Масштаб таблицы", 18))
		_content.add_child(zoom)
		_content.add_child(image)
	if entry.has("diagram"):
		var diagram := TextureRect.new()
		diagram.texture = load(entry.diagram)
		diagram.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		diagram.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		diagram.custom_minimum_size.y = 300
		_content.add_child(diagram)
		_content.add_child(_text(str(entry.get("diagramCaption", "")), 21))
		_content.add_child(_text("Условная схема; размеры, траектории и энергетические уровни иллюстративны.", 16))
	if entry.has("columns"):
		var grid := GridContainer.new()
		grid.columns = entry.columns.size()
		grid.add_theme_constant_override("h_separation", 24)
		grid.add_theme_constant_override("v_separation", 16)
		_content.add_child(grid)
		for heading in entry.columns:
			var label := _text(heading, 23)
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			grid.add_child(label)
		for row in entry.rows:
			for cell in row:
				grid.add_child(_text(cell, 21))
	_content.add_child(_text(str(entry.get("source", "Учебный справочник ChemSite; значения округлены.")), 16))
	for source in entry.get("sourceRefs", [entry.url]):
		_content.add_child(_text("Источник: " + str(source), 15))

extends Control

signal start_requested
signal settings_changed(settings: Dictionary)

const SAVE_DATA = preload("res://scripts/core/save_data.gd")
const SETTINGS_DATA = preload("res://scripts/core/settings_data.gd")
var _menu_content: VBoxContainer
var _settings_panel: PanelContainer
var _settings_button: Button

func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color("142531")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var accent := ColorRect.new()
	accent.color = Color("f3a846")
	accent.anchor_right = 0.012
	accent.anchor_bottom = 1.0
	add_child(accent)
	var illustration := TextureRect.new()
	illustration.texture = load("res://assets/ui/menu_illustration.svg") as Texture2D
	illustration.anchor_left = 0.02
	illustration.anchor_right = 0.52
	illustration.anchor_top = 0.05
	illustration.anchor_bottom = 0.97
	illustration.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	illustration.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	illustration.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(illustration)
	var content := VBoxContainer.new()
	content.anchor_left = 0.5
	content.anchor_right = 0.5
	content.anchor_top = 0.23
	content.anchor_bottom = 0.23
	content.offset_right = 600
	content.custom_minimum_size = Vector2(600, 420)
	content.add_theme_constant_override("separation", 18)
	add_child(content)
	_menu_content = content
	var eyebrow := Label.new()
	eyebrow.text = "ПРОЕКТ 01  /  СТРОИТЕЛЬНАЯ ХИМИЯ"
	eyebrow.add_theme_color_override("font_color", Color("f3a846"))
	eyebrow.add_theme_font_size_override("font_size", 21)
	content.add_child(eyebrow)
	var title := Label.new()
	title.text = "CHEMSITE"
	title.add_theme_color_override("font_color", Color("f6f0df"))
	title.add_theme_font_size_override("font_size", 84)
	content.add_child(title)
	var description := Label.new()
	description.text = "Знания строят будущее.\nИсследуй площадку и решай химические задачи."
	description.add_theme_color_override("font_color", Color("afc6c9"))
	description.add_theme_font_size_override("font_size", 24)
	content.add_child(description)
	var progress: Dictionary = SAVE_DATA.load_progress()
	var record := Label.new()
	record.text = "ЛУЧШИЙ РЕЗУЛЬТАТ: %d  /  ОПЫТ: %d" % [progress.best_score, progress.total_xp]
	record.add_theme_color_override("font_color", Color("f3a846"))
	record.add_theme_font_size_override("font_size", 18)
	content.add_child(record)
	var start := Button.new()
	start.text = "НАЧАТЬ СМЕНУ   →"
	start.custom_minimum_size = Vector2(280, 68)
	start.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	start.add_theme_font_size_override("font_size", 24)
	start.pressed.connect(func() -> void: start_requested.emit())
	content.add_child(start)
	start.grab_focus()
	var settings_button := Button.new()
	settings_button.text = "НАСТРОЙКИ"
	settings_button.custom_minimum_size = Vector2(280, 48)
	settings_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	settings_button.add_theme_font_size_override("font_size", 19)
	content.add_child(settings_button)
	_settings_button = settings_button
	var settings: Dictionary = SETTINGS_DATA.load_settings()
	var settings_panel := PanelContainer.new()
	settings_panel.anchor_left = 0.55
	settings_panel.anchor_right = 0.94
	settings_panel.anchor_top = 0.18
	settings_panel.anchor_bottom = 0.82
	settings_panel.visible = false
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("1c3740")
	panel_style.set_corner_radius_all(12)
	panel_style.set_content_margin_all(28)
	settings_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(settings_panel)
	_settings_panel = settings_panel
	var settings_content := VBoxContainer.new()
	settings_content.add_theme_constant_override("separation", 20)
	settings_panel.add_child(settings_content)
	var settings_title := Label.new()
	settings_title.text = "НАСТРОЙКИ ЗВУКА"
	settings_title.add_theme_color_override("font_color", Color("f3a846"))
	settings_title.add_theme_font_size_override("font_size", 30)
	settings_content.add_child(settings_title)
	_add_volume_slider(settings_content, "МУЗЫКА", "music_volume", settings)
	_add_volume_slider(settings_content, "ЭФФЕКТЫ", "sfx_volume", settings)
	var close_settings := Button.new()
	close_settings.text = "НАЗАД  ←"
	close_settings.custom_minimum_size.y = 54
	close_settings.add_theme_font_size_override("font_size", 20)
	settings_content.add_child(close_settings)
	settings_button.pressed.connect(func() -> void:
		content.visible = false
		settings_panel.visible = true
		close_settings.grab_focus()
	)
	close_settings.pressed.connect(_close_settings)
	var footer := Label.new()
	footer.text = "WASD / СТРЕЛКИ — ДВИЖЕНИЕ     E — ВЗАИМОДЕЙСТВИЕ     ESC — МЕНЮ"
	footer.add_theme_color_override("font_color", Color("769198"))
	footer.add_theme_font_size_override("font_size", 16)
	content.add_child(footer)

func _unhandled_input(event: InputEvent) -> void:
	if _settings_panel != null and _settings_panel.visible and event.is_action_pressed("ui_cancel"):
		_close_settings()
		get_viewport().set_input_as_handled()

func _close_settings() -> void:
	_settings_panel.visible = false
	_menu_content.visible = true
	_settings_button.grab_focus()

func _add_volume_slider(parent: VBoxContainer, title: String, key: String, settings: Dictionary) -> void:
	var label := Label.new()
	label.text = title
	label.add_theme_color_override("font_color", Color("e2ece6"))
	label.add_theme_font_size_override("font_size", 20)
	parent.add_child(label)
	var slider := HSlider.new()
	slider.min_value = 0
	slider.max_value = 100
	slider.step = 1
	slider.value = float(settings[key]) * 100.0
	slider.custom_minimum_size = Vector2(350, 42)
	parent.add_child(slider)
	var value_label := Label.new()
	value_label.text = "%d%%" % int(slider.value)
	value_label.add_theme_color_override("font_color", Color("a9c7c9"))
	parent.add_child(value_label)
	slider.value_changed.connect(func(value: float) -> void:
		settings[key] = value / 100.0
		value_label.text = "%d%%" % int(value)
		var save_error: Error = SETTINGS_DATA.save_settings(settings)
		if save_error != OK:
			push_warning("Could not save audio settings: %s" % error_string(save_error))
		settings_changed.emit(settings)
	)

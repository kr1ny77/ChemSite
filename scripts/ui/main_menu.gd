extends Control

signal start_requested

const SAVE_DATA = preload("res://scripts/core/save_data.gd")

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
	content.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	content.custom_minimum_size = Vector2(600, 420)
	content.add_theme_constant_override("separation", 18)
	add_child(content)
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
	var footer := Label.new()
	footer.text = "WASD / СТРЕЛКИ — ДВИЖЕНИЕ     E — ВЗАИМОДЕЙСТВИЕ     ESC — МЕНЮ"
	footer.add_theme_color_override("font_color", Color("769198"))
	footer.add_theme_font_size_override("font_size", 16)
	content.add_child(footer)

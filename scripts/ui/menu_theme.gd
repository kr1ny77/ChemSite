extends RefCounted

static func create() -> Theme:
	var result := Theme.new()
	result.default_font = load("res://assets/fonts/Onest-Variable.ttf") as Font
	result.default_font_size = 20
	result.set_stylebox("normal", "Button", _box(Color("304e59")))
	result.set_stylebox("hover", "Button", _box(Color("3a5c68")))
	result.set_stylebox("pressed", "Button", _box(Color("3a5c68")))
	result.set_stylebox("disabled", "Button", _box(Color("243d47")))
	result.set_stylebox("focus", "Button", _focus(Color("f3a846")))
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		result.set_color(state, "Button", Color("f3efe1"))
	result.set_color("font_disabled_color", "Button", Color("a9c0c5"))
	result.set_type_variation("PrimaryMenuButton", "Button")
	result.set_stylebox("normal", "PrimaryMenuButton", _box(Color("e8a447")))
	result.set_stylebox("hover", "PrimaryMenuButton", _box(Color("f2b95b")))
	result.set_stylebox("pressed", "PrimaryMenuButton", _box(Color("f2b95b")))
	result.set_stylebox("focus", "PrimaryMenuButton", _focus(Color("173744")))
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		result.set_color(state, "PrimaryMenuButton", Color("173744"))
	result.set_stylebox("focus", "HSlider", _focus(Color("f3a846")))
	return result

static func _box(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(9)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	return style

static func _focus(color: Color) -> StyleBoxFlat:
	var style := _box(Color.TRANSPARENT)
	style.draw_center = false
	style.set_border_width_all(3)
	style.border_color = color
	return style

extends SceneTree

const MENU = preload("res://scenes/ui/main_menu.tscn")
const SETTINGS = preload("res://scripts/core/settings_data.gd")
const SETTINGS_PATH := "user://menu-accessibility-settings.json"
var checks := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SETTINGS_PATH))
	var menu := MENU.instantiate()
	menu.save_path = "user://menu-accessibility-no-progress.json"
	menu.settings_path = SETTINGS_PATH
	root.add_child(menu)
	await process_frame
	if not _check(menu): return
	if not _capture("menu"): return
	menu._settings_button.grab_focus()
	await _key(KEY_SPACE)
	if not menu._settings_panel.visible: return _fail("Keyboard settings entry failed")
	if not _check(menu): return
	if not _capture("settings"): return
	var slider: HSlider = menu.find_children("*", "HSlider", true, false)[0]
	slider.grab_focus()
	var before := slider.value
	await _key(KEY_LEFT)
	if slider.value >= before or float(SETTINGS.load_settings(SETTINGS_PATH).music_volume) >= before / 100.0:
		return _fail("Keyboard volume adjustment was not saved")
	for button in menu.find_children("*", "Button", true, false):
		if button.text.begins_with("МЕНЬШЕ ДВИЖЕНИЯ"):
			button.grab_focus()
			await _key(KEY_SPACE)
			if not SETTINGS.load_settings(SETTINGS_PATH).reduced_motion: return _fail("Keyboard reduced-motion toggle failed")
	await _key(KEY_ESCAPE)
	if not menu._menu_content.visible or menu.get_viewport().gui_get_focus_owner() != menu._settings_button:
		return _fail("Settings exit did not restore focus")
	menu._practice_button.grab_focus()
	await _key(KEY_SPACE)
	if not menu._practice_panel.visible: return _fail("Keyboard practice entry failed")
	if not _check(menu): return
	if not _capture("practice"): return
	await _key(KEY_ESCAPE)
	if not menu._menu_content.visible or menu.get_viewport().gui_get_focus_owner() != menu._practice_button:
		return _fail("Practice exit did not restore focus")
	print("MENU_ACCESSIBILITY_OK contrast_checks=", checks, " keyboard_volume_toggle_escape=passed")
	menu.queue_free()
	await process_frame
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SETTINGS_PATH))
	quit()

func _check(menu: Control) -> bool:
	for label in menu.find_children("*", "Label", true, false):
		if not label.is_visible_in_tree() or label.text.is_empty(): continue
		var background := Color("142531")
		var ancestor: Node = label.get_parent()
		while ancestor != null and ancestor != menu:
			if ancestor is PanelContainer:
				var style: StyleBox = ancestor.get_theme_stylebox("panel")
				if style is StyleBoxFlat:
					background = style.bg_color
					break
			ancestor = ancestor.get_parent()
		if _ratio(label.get_theme_color("font_color"), background) < 4.5:
			_fail("Menu label contrast failed: " + label.text)
			return false
		checks += 1
	for button in menu.find_children("*", "Button", true, false):
		if not button.is_visible_in_tree(): continue
		var focus: StyleBox = button.get_theme_stylebox("focus")
		if not focus is StyleBoxFlat or focus.border_width_left < 3:
			_fail("Menu focus border is absent")
			return false
		for state in ["disabled"] if button.disabled else ["normal", "hover", "pressed"]:
			var style: StyleBox = button.get_theme_stylebox(state)
			var text: Color = button.get_theme_color("font_color" if state == "normal" else "font_" + state + "_color")
			if not style is StyleBoxFlat or _ratio(text, style.bg_color) < 4.5:
				_fail("Menu button text contrast failed: " + button.text + " " + state)
				return false
			checks += 1
			if not button.disabled and _ratio(focus.border_color, style.bg_color) < 3.0:
				_fail("Menu focus contrast failed: " + button.text)
				return false

	return true

func _capture(name: String) -> bool:
	RenderingServer.force_draw()
	var folder := "res://artifacts/menu-accessibility"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	if root.get_texture().get_image().save_png(folder + "/" + name + ".png") != OK:
		_fail("Menu image write failed")
		return false
	return true

func _key(code: int) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	await process_frame
	event = InputEventKey.new()
	event.keycode = code
	event.pressed = false
	Input.parse_input_event(event)
	await process_frame
	await process_frame

func _ratio(a: Color, b: Color) -> float:
	var x := a.srgb_to_linear()
	var y := b.srgb_to_linear()
	var la := .2126 * x.r + .7152 * x.g + .0722 * x.b
	var lb := .2126 * y.r + .7152 * y.g + .0722 * y.b
	return (maxf(la, lb) + .05) / (minf(la, lb) + .05)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)

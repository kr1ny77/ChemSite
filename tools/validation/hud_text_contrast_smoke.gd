extends "res://tools/validation/all_hud_layout_smoke.gd"

var contrast_checks := 0

func _check_panel(hud: Control, identifier: String, phase: String, failures: Array[String]) -> void:
	if OS.get_cmdline_user_args().has("--capture") and ((identifier == "L2-041" and phase == "unread") or (identifier == "L1-001" and phase.begins_with("feedback")) or identifier in ["career", "pause"]):
		RenderingServer.force_draw()
		var folder := "res://artifacts/hud-text-contrast"
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		if root.get_texture().get_image().save_png(folder + "/%s-%s.png" % [identifier, phase]) != OK:
			failures.append("Contrast image write failed")
	super._check_panel(hud, identifier, phase, failures)
	for label in hud._panel.find_children("*", "Label", true, false):
		if not label.is_visible_in_tree() or label.text.is_empty(): continue
		var background := Color("f3efe1")
		var ancestor: Node = label.get_parent()
		while ancestor != hud:
			if ancestor is PanelContainer or ancestor is Panel:
				var style: StyleBox = ancestor.get_theme_stylebox("panel")
				if style is StyleBoxFlat and style.bg_color.a >= .99:
					background = style.bg_color
					break
			ancestor = ancestor.get_parent()
		var foreground: Color = label.get_theme_color("font_color")
		foreground = background.lerp(foreground, foreground.a)
		var lighter := maxf(_luminance(foreground), _luminance(background))
		var darker := minf(_luminance(foreground), _luminance(background))
		var ratio := (lighter + .05) / (darker + .05)
		contrast_checks += 1
		if ratio < 4.5:
			var failure := "Contrast %.2f:1 fg=%s bg=%s text=%s" % [ratio, foreground.to_html(false), background.to_html(false), label.text.left(48)]
			if not failures.has(failure): failures.append(failure)
	for button in hud._panel.find_children("*", "Button", true, false):
		if not button.is_visible_in_tree() or button.disabled: continue
		for state in ["normal", "hover", "pressed"]:
			var style: StyleBox = button.get_theme_stylebox(state)
			if not style is StyleBoxFlat: continue
			var foreground: Color = button.get_theme_color("font_color" if state == "normal" else "font_" + state + "_color")
			var background: Color = style.bg_color
			var a := _luminance(foreground)
			var b := _luminance(background)
			var ratio := (maxf(a, b) + .05) / (minf(a, b) + .05)
			contrast_checks += 1
			if ratio < 4.5:
				var failure := "Button contrast %.2f:1 state=%s text=%s" % [ratio, state, button.text.left(48)]
				if not failures.has(failure): failures.append(failure)
	if identifier == "pause": print("HUD_TEXT_CONTRAST_CHECKS=", contrast_checks)

func _luminance(color: Color) -> float:
	var linear := color.srgb_to_linear()
	return .2126 * linear.r + .7152 * linear.g + .0722 * linear.b

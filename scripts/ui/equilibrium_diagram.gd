extends RefCounted

# Qualitative symbols only. Curves share an endpoint and have no numeric axes.
# A finite reveal animates presentation, never a computed chemical trajectory.
static func render(view: Control, offset: Vector2, kind: String, progress: float, caption: String) -> void:
	var ink := Color("3f6470")
	var accent := Color("3b9b83")
	var font := view.get_theme_default_font()
	for line_index in range(caption.split("\n").size()):
		view.draw_string(font, offset + Vector2(12, 17 + line_index * 16), caption.split("\n")[line_index], HORIZONTAL_ALIGNMENT_LEFT, -1, 15, ink)
	if kind in ["equilibrium-slow", "equilibrium-fast"]:
		view.draw_line(offset + Vector2(24, 60), offset + Vector2(204, 60), ink, 1)
		view.draw_line(offset + Vector2(24, 60), offset + Vector2(24, 28), ink, 1)
		var points := PackedVector2Array()
		var reach := 65.0 if kind == "equilibrium-fast" else 145.0
		for index in range(41):
			var x := float(index) / 40.0 * 176.0 * progress
			var y := lerpf(57.0, 33.0, smoothstep(0.0, reach, x))
			points.append(offset + Vector2(25 + x, y))
		view.draw_polyline(points, accent, 2, true)
		view.draw_string(font, offset + Vector2(45, 29), "Состав · время →", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, ink)
	elif kind in ["equilibrium-forward", "equilibrium-reverse"]:
		var left := offset + Vector2(32, 45)
		var right := offset + Vector2(181, 45)
		var color := accent
		color.a = progress
		if kind == "equilibrium-forward": view._arrow(left, right, color)
		else: view._arrow(right, left, color)
		view.draw_string(font, offset + Vector2(32, 64), "v прямой = v обратной", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, ink)
	elif kind in ["equilibrium-volume", "equilibrium-compressed", "equilibrium-expanded"]:
		var width := 110.0
		if kind == "equilibrium-compressed": width = lerpf(110.0, 72.0, progress)
		elif kind == "equilibrium-expanded": width = lerpf(110.0, 152.0, progress)
		view.draw_rect(Rect2(offset + Vector2(24, 36), Vector2(width, 28)), Color("c4dfe5"))
		view.draw_rect(Rect2(offset + Vector2(24, 36), Vector2(width, 28)), ink, false, 1.5)
		var label := "N₂ + 3H₂ ⇌ 2NH₃"
		if kind == "equilibrium-compressed": label = "Доля NH₃ ↑"
		elif kind == "equilibrium-expanded": label = "Доля NH₃ ↓"
		view.draw_string(font, offset + Vector2(28, 55), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, ink)
	else:
		view.draw_rect(Rect2(offset + Vector2(24, 31), Vector2(142, 33)), Color("c4dfe5"))
		view.draw_rect(Rect2(offset + Vector2(24, 31), Vector2(142, 33)), ink, false, 1.5)
		view.draw_string(font, offset + Vector2(31, 53), "Реагенты ⇌ продукт", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, ink)
		var color := accent
		color.a = progress
		if kind == "equilibrium-added":
			view._arrow(offset + Vector2(8, 47), offset + Vector2(23, 47), color)
			view._arrow(offset + Vector2(72, 59), offset + Vector2(126, 59), color)
		elif kind == "equilibrium-removed":
			view._arrow(offset + Vector2(167, 47), offset + Vector2(206, 47), color)
			view.draw_string(font, offset + Vector2(172, 62), "NH₃", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, ink)

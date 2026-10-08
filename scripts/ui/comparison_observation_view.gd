extends Control

# Qualitative diagrams illustrate the curated observation. Motion duration and
# geometry are presentation values; chemistry quantities/rates are never inferred.
const KINDS := ["metal-oxidation", "metal-reduction", "intact-coating", "damaged-coating", "bare-surface", "passive-film", "dry-surface", "electrolyte-film", "thermal-low", "thermal-reference", "thermal-high"]
var kinds: Array[String] = []
var _captions: Array[String] = []
var _colors: Array[Color] = []
var observed: Array[bool] = [false, false]
var reduced_motion := false
var _elapsed: Array[float] = [0.0, 0.0]
var _background: StyleBoxFlat

func _ready() -> void:
	# Godot enables an overridden _process on tree entry. Preserve the reveal gate.
	set_process(observed.has(true) and not reduced_motion)

func configure(visuals: Array, static_motion: bool) -> void:
	reduced_motion = static_motion
	for visual in visuals:
		kinds.append(str(visual.get("kind", "")))
		_captions.append(str(visual.get("caption", "")))
		_colors.append(Color(str(visual.get("color", "8eaaaf"))))
	_background = StyleBoxFlat.new()
	_background.bg_color = Color("e8efe9")
	_background.set_corner_radius_all(8)
	custom_minimum_size = Vector2(480, 88)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(false)
	hide()

func reveal(index: int) -> void:
	if index < 0 or index >= kinds.size() or observed[index]: return
	observed[index] = true
	_elapsed[index] = 1.2 if reduced_motion else 0.0
	show()
	set_process(not reduced_motion)
	queue_redraw()

func _process(delta: float) -> void:
	var animating := false
	for index in range(2):
		if observed[index]:
			_elapsed[index] = minf(_elapsed[index] + delta, 1.2)
			animating = animating or _elapsed[index] < 1.2
	queue_redraw()
	set_process(animating)

func _draw() -> void:
	draw_style_box(_background, Rect2(Vector2.ZERO, size))
	var font := get_theme_default_font()
	var half := size.x * .5
	for index in range(2):
		var offset := Vector2(float(index) * half, 0)
		if not observed[index]:
			draw_string(font, offset + Vector2(18, 42), "%d · ОБРАЗЕЦ ОЖИДАЕТ ОСМОТРА" % (index + 1), HORIZONTAL_ALIGNMENT_LEFT, half - 24, 14, Color("637d84"))
			continue
		var progress := smoothstep(0.0, 1.0, _elapsed[index] / 1.2)
		if kinds[index] in ["metal-oxidation", "metal-reduction"]:
			_electrode(offset, kinds[index], progress, _captions[index], _colors[index])
		elif kinds[index].begins_with("thermal-"):
			_thermal(offset, kinds[index], progress, _captions[index])
		else:
			_surface(offset, kinds[index], progress)
		var label := "%d · МАСШТАБ УСЛОВНЫЙ" % (index + 1)
		draw_string(font, offset + Vector2(12, 79), label, HORIZONTAL_ALIGNMENT_LEFT, half - 20, 13, Color("52666c"))
	draw_line(Vector2(half, 8), Vector2(half, size.y - 8), Color("bdcfc8"), 1)

func _electrode(offset: Vector2, kind: String, progress: float, caption: String, metal: Color) -> void:
	var ink := Color("3f6470")
	var reducing := kind == "metal-reduction"
	draw_rect(Rect2(offset + Vector2(22, 31), Vector2(112, 31)), Color("c4dfe5"))
	draw_polyline(PackedVector2Array([offset + Vector2(19, 28), offset + Vector2(22, 28), offset + Vector2(22, 62), offset + Vector2(134, 62), offset + Vector2(134, 28), offset + Vector2(137, 28)]), ink, 2, true)
	var width := 18.0 + progress * 5.0 * (1 if reducing else -1)
	draw_rect(Rect2(offset + Vector2(49 - width * .5, 28), Vector2(width, 29)), metal)
	draw_string(get_theme_default_font(), offset + Vector2(12, 22), caption, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, ink)
	for index in range(3):
		var start := Vector2(98 + index * 11, 39 + index * 6)
		var end := Vector2(58, 39 + index * 6)
		var point := start.lerp(end, progress) if reducing else end.lerp(start, progress)
		var ion_color := ink
		if reducing: ion_color.a = 1.0 - smoothstep(.75, 1.0, progress)
		draw_arc(offset + point, 3, 0, TAU, 12, ion_color, 1.5, true)
	var left := offset + Vector2(167, 43)
	var right := offset + Vector2(211, 43)
	_arrow(right, left, ink) if reducing else _arrow(left, right, ink)
	draw_string(get_theme_default_font(), offset + Vector2(171, 28), "e⁻", HORIZONTAL_ALIGNMENT_LEFT, -1, 21, ink)

func _surface(offset: Vector2, kind: String, progress: float) -> void:
	var origin := offset + Vector2(24, 39)
	var steel := Rect2(origin, Vector2(176, 20))
	draw_rect(steel, Color("8eaaaf"))
	draw_line(origin + Vector2(0, 20), origin + Vector2(176, 20), Color("3f6470"), 2)
	if kind in ["intact-coating", "damaged-coating", "passive-film"]:
		var width := 176.0 * progress
		var thickness := 4.0 if kind == "passive-film" else 8.0
		draw_rect(Rect2(origin - Vector2(0, thickness), Vector2(width, thickness)), Color("3b9b83"))
		if kind == "damaged-coating":
			draw_rect(Rect2(origin + Vector2(71, -thickness), Vector2(25, thickness)), Color("e8efe9"))
			_arrow(origin + Vector2(83, -27), origin + Vector2(83, -2), Color("c57839"))
	elif kind == "electrolyte-film":
		draw_rect(Rect2(origin - Vector2(0, 13), Vector2(176 * progress, 13)), Color("80becb"))
		for index in range(6):
			var point := origin + Vector2(19 + index * 27, -7)
			draw_circle(point, 3, Color("3f6470"))
			if index % 2 == 0: draw_line(point - Vector2(0, 2), point + Vector2(0, 2), Color("e8efe9"), 1)
			draw_line(point - Vector2(2, 0), point + Vector2(2, 0), Color("e8efe9"), 1)
	else:
		# Bare/dry surfaces show exposed steel; the observation text distinguishes
		# their environment. A schematic never predicts visible rust or a rate.
		for index in range(5):
			draw_line(origin + Vector2(19 + index * 34, 3), origin + Vector2(8 + index * 34, 16), Color("b8c8c7"), 1)

func _arrow(from: Vector2, to: Vector2, color: Color) -> void:
	draw_line(from, to, color, 2, true)
	var direction := (to - from).normalized()
	var normal := Vector2(-direction.y, direction.x)
	draw_colored_polygon(PackedVector2Array([to, to - direction * 7 + normal * 4, to - direction * 7 - normal * 4]), color)

func _thermal(offset: Vector2, kind: String, progress: float, caption: String) -> void:
	# Qualitative temperature icon. No temperature, concentration, reaction rate
	# or gas formation is inferred from the illustrated level or heat-wave timing.
	var ink := Color("3f6470")
	var hot := kind == "thermal-high"
	var cold := kind == "thermal-low"
	var tint := Color("ce7939") if hot else (Color("4296b4") if cold else Color("789c94"))
	var level := 28.0 if hot else (10.0 if cold else 19.0)
	draw_string(get_theme_default_font(), offset + Vector2(12, 21), caption, HORIZONTAL_ALIGNMENT_LEFT, size.x * .5 - 24, 16, ink)
	var bulb := offset + Vector2(31, 56)
	draw_circle(bulb, 8, ink)
	draw_rect(Rect2(offset + Vector2(27, 28), Vector2(8, 27)), ink)
	draw_circle(bulb, 5.5, tint)
	draw_rect(Rect2(offset + Vector2(29, 56 - level * progress), Vector2(4, level * progress)), tint)
	for tick in range(4):
		draw_line(offset + Vector2(39, 30 + tick * 8), offset + Vector2(45, 30 + tick * 8), ink, 1)
	var sample := Rect2(offset + Vector2(73, 32), Vector2(76, 27))
	var surface := Color("d9e5df").lerp(tint.lightened(.5), progress)
	draw_rect(sample, surface)
	draw_rect(sample, ink, false, 2)
	draw_string(get_theme_default_font(), offset + Vector2(78, 50), "СИСТЕМА", HORIZONTAL_ALIGNMENT_LEFT, 66, 11, ink)
	if hot:
		for wave in range(3):
			var points := PackedVector2Array()
			for step in range(12):
				var y := 54.0 - step * 2.0
				points.append(offset + Vector2(169 + wave * 12 + sin(step * .7 + progress * TAU) * 2.5, y))
			draw_polyline(points, Color(tint, progress), 2, true)
	elif cold:
		_arrow(offset + Vector2(178, 31), offset + Vector2(178, 56), Color(tint, progress))
		draw_string(get_theme_default_font(), offset + Vector2(190, 47), "T", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, tint)

extends Control

var effect_kind := ""
var effect_color := Color.WHITE
var reduced_motion := false
var _elapsed := 0.0
var _background_style: StyleBoxFlat

func configure(visual: Dictionary, static_motion: bool) -> void:
	_background_style = _background()
	effect_kind = str(visual.get("kind", ""))
	effect_color = Color(str(visual.get("color", "ffffff")))
	reduced_motion = static_motion
	custom_minimum_size = Vector2(240, 88)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(not reduced_motion)
	queue_redraw()

func _ready() -> void:
	set_process(not reduced_motion)

func _process(delta: float) -> void:
	_elapsed = minf(_elapsed + delta, 1.2)
	queue_redraw()
	if _elapsed >= 1.2:
		set_process(false)

func _draw() -> void:
	draw_style_box(_background_style, Rect2(Vector2.ZERO, size))
	var ink := Color("3f6470")
	draw_rect(Rect2(33, 31, 64, 44), Color("d4e7ed"))
	draw_polyline(PackedVector2Array([Vector2(28, 9), Vector2(33, 9), Vector2(33, 75), Vector2(97, 75), Vector2(97, 9), Vector2(103, 9)]), ink, 3.0, true)
	draw_line(Vector2(37, 31), Vector2(93, 31), Color("8eb7c5"), 2.0, true)
	var progress := 1.0 if reduced_motion else clampf(_elapsed / 1.2, 0.0, 1.0)
	if effect_kind == "precipitate":
		draw_rect(Rect2(35, 69, 60, 5), effect_color)
		for index in range(18):
			var x := 39.0 + fmod(float(index * 17), 50.0)
			var y := 68.0 - float(index % 4) * 3.0 - (1.0 - progress) * (18.0 + float(index % 5) * 3.0)
			draw_circle(Vector2(x, y), 2.0 + float(index % 3) * .4, effect_color)
	elif effect_kind == "gas":
		for index in range(9):
			var x := 43.0 + float(index % 3) * 20.0
			var y := 69.0 - fmod(float(index * 9) + progress * 29.0, 36.0)
			draw_arc(Vector2(x, y), 2.5 + float(index % 2), 0, TAU, 16, ink, 1.5, true)
	var font := get_theme_default_font()
	draw_string(font, Vector2(124, 37), "СХЕМА НАБЛЮДЕНИЯ", HORIZONTAL_ALIGNMENT_LEFT, size.x - 132, 15, ink)
	draw_string(font, Vector2(124, 59), "Анимация условная", HORIZONTAL_ALIGNMENT_LEFT, size.x - 132, 14, Color("637d84"))

func _background() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("e8efe9")
	style.set_corner_radius_all(8)
	return style

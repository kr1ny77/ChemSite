extends Control

var value := 7.0
var reduced_motion := false
var _flash := 1.0

func configure(reading: float, static_motion: bool) -> void:
	value = reading
	reduced_motion = static_motion
	custom_minimum_size = Vector2(180, 56)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _ready() -> void:
	set_process(not reduced_motion)
	if reduced_motion:
		_flash = 0.0

func _process(delta: float) -> void:
	_flash = maxf(0.0, _flash - delta / .35)
	queue_redraw()
	if _flash == 0.0:
		set_process(false)

func marker_fraction() -> float:
	return clampf(value / 14.0, 0.0, 1.0)

func _draw() -> void:
	var width := maxf(1.0, size.x - 24.0)
	var ink := Color("244851")
	draw_rect(Rect2(12, 14, width, 9), Color("afc8cd"))
	for tick in range(15):
		var x := 12.0 + width * float(tick) / 14.0
		draw_line(Vector2(x, 23), Vector2(x, 29 if tick % 7 == 0 else 26), ink, 1.0)
	var marker := 12.0 + width * marker_fraction()
	var gold := Color("e8a447").lerp(Color("fff0b3"), _flash * .7)
	draw_colored_polygon(PackedVector2Array([Vector2(marker - 6, 3), Vector2(marker + 6, 3), Vector2(marker, 13)]), gold)
	draw_line(Vector2(marker, 14), Vector2(marker, 23), ink, 2.0)
	var font := get_theme_default_font()
	draw_string(font, Vector2(10, 47), "0", HORIZONTAL_ALIGNMENT_LEFT, 30, 14, ink)
	draw_string(font, Vector2(12 + width * .5 - 4, 47), "7", HORIZONTAL_ALIGNMENT_LEFT, 30, 14, ink)
	draw_string(font, Vector2(12 + width - 16, 47), "14", HORIZONTAL_ALIGNMENT_LEFT, 30, 14, ink)

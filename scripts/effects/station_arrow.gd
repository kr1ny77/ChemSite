extends Control

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(56, 52)
	size = custom_minimum_size

func _draw() -> void:
	var outline := PackedVector2Array([Vector2(16, 2), Vector2(40, 2), Vector2(40, 23), Vector2(53, 23), Vector2(28, 49), Vector2(3, 23), Vector2(16, 23)])
	var arrow := PackedVector2Array([Vector2(20, 6), Vector2(36, 6), Vector2(36, 27), Vector2(44, 27), Vector2(28, 43), Vector2(12, 27), Vector2(20, 27)])
	draw_colored_polygon(outline, Color("173b49"))
	draw_colored_polygon(arrow, Color("ffcc48"))
	draw_line(Vector2(24, 9), Vector2(24, 24), Color("fff3bd"), 3.0, true)

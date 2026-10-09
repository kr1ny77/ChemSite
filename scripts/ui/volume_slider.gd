extends HSlider
## Theme-owned focus outline for keyboard audio adjustment.

var _focus_style: StyleBox

func _ready() -> void:
	_refresh_focus_style()

func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED and is_inside_tree():
		_refresh_focus_style()
	elif what in [NOTIFICATION_FOCUS_ENTER, NOTIFICATION_FOCUS_EXIT, NOTIFICATION_RESIZED]:
		queue_redraw()

func _refresh_focus_style() -> void:
	_focus_style = get_theme_stylebox("focus", "HSlider")
	queue_redraw()

func _draw() -> void:
	if has_focus() and _focus_style != null:
		draw_style_box(_focus_style, Rect2(Vector2.ZERO, size))

extends VBoxContainer

var _result: Label
var _protons := 6
var _neutrons := 6
var _charge := 0

func _ready() -> void:
	add_theme_constant_override("separation", 14)
	var heading := Label.new()
	heading.text = "УЧЕБНЫЙ ЧЕРНОВИК"
	heading.add_theme_font_size_override("font_size", 25)
	add_child(heading)
	var expression := LineEdit.new()
	expression.placeholder_text = "Расчёт: например, (2 + 3) * 4 / 1000"
	expression.custom_minimum_size.y = 52
	add_child(expression)
	var calculate := Button.new()
	calculate.text = "ВЫЧИСЛИТЬ"
	add_child(calculate)
	var output := Label.new()
	output.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(output)
	calculate.pressed.connect(func() -> void:
		var allowed := RegEx.new()
		allowed.compile("^[0-9eE+*/()., \\-]+$")
		var input := expression.text.replace(",", ".")
		if allowed.search(input) == null:
			output.text = "Используйте числа, скобки и знаки + − * /."
			return
		var numbers := RegEx.new()
		numbers.compile("(?:[0-9]+(?:\\.[0-9]*)?|\\.[0-9]+)(?:[eE][+-]?[0-9]+)?")
		var matches := numbers.search_all(input)
		for index in range(matches.size() - 1, -1, -1):
			var match_text: String = matches[index].get_string()
			if "." not in match_text and "e" not in match_text.to_lower():
				input = input.insert(matches[index].get_end(), ".0")
		var parser := Expression.new()
		if parser.parse(input) != OK:
			output.text = "Проверьте запись выражения."
			return
		var value: Variant = parser.execute([], null, false)
		if parser.has_execute_failed() or not (value is int or value is float) or not is_finite(float(value)):
			output.text = "Проверьте выражение и деление на ноль."
		else:
			output.text = "Результат: %s. Единицы укажите в ответе по условию." % str(value)
	)
	var note := Label.new()
	note.text = "МОДЕЛЬ АТОМА И ИОНА · исследуйте число частиц"
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(note)
	_add_setting("Протоны Z", 1, 30, 6, func(value: float) -> void: _protons = int(value); _refresh())
	_add_setting("Нейтроны N", 0, 50, 6, func(value: float) -> void: _neutrons = int(value); _refresh())
	_add_setting("Заряд иона q", -3, 3, 0, func(value: float) -> void: _charge = int(value); _refresh())
	_result = Label.new()
	_result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_result)
	_refresh()
	var disclaimer := Label.new()
	disclaimer.text = "Счётная модель: A = Z + N, e = Z − q. Произвольная комбинация служит счёту частиц; устойчивость изотопа и существование иона проверяются отдельно. При смене раздела материалы черновика очищаются."
	disclaimer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(disclaimer)
	for label in find_children("*", "Label", true, false):
		label.add_theme_color_override("font_color", Color("243b43"))
		label.add_theme_font_size_override("font_size", 21)

func _add_setting(title: String, low: int, high: int, initial: int, changed: Callable) -> void:
	var row := HBoxContainer.new()
	var label := Label.new()
	label.text = title
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	var value := SpinBox.new()
	value.min_value = low
	value.max_value = high
	value.value = initial
	value.custom_minimum_size = Vector2(150, 48)
	value.value_changed.connect(changed)
	row.add_child(value)
	add_child(row)

func _refresh() -> void:
	if _result == null: return
	_result.text = "Протоны: %d   •   Нейтроны: %d\nМассовое число A: %d   •   Электроны: %d" % [_protons, _neutrons, _protons + _neutrons, _protons - _charge]
	if _protons - _charge < 0:
		_result.text = "Для выбранного Z заряд q должен быть ≤ Z."

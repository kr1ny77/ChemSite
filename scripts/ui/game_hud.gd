extends Control

signal answer_submitted(answer: String)
signal resume_requested
signal exit_requested

var _objective: Label
var _status: Label
var _score_label: Label
var _timer_label: Label
var _combo_label: Label
var _xp_label: Label
var _prompt: Label
var _panel: PanelContainer
var _panel_content: VBoxContainer
var _feedback: Label
var _formula_buffer: String = ""
var _formula_tokens: Array[String] = []
var _formula_output: Label

func _ready() -> void:
	var top := PanelContainer.new()
	top.anchor_right = 0.58
	top.offset_left = 24
	top.offset_top = 20
	top.offset_bottom = 112
	top.add_theme_stylebox_override("panel", _panel_style(Color("173744"), 13))
	add_child(top)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 35)
	top.add_child(row)
	var title := VBoxContainer.new()
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(title)
	_objective = _label("ЗАГРУЗКА ЗАДАНИЯ", 22, Color("f7f4e7"))
	_status = _label("", 17, Color("cfddd8"))
	_objective.autowrap_mode = TextServer.AUTOWRAP_OFF
	_status.autowrap_mode = TextServer.AUTOWRAP_OFF
	title.add_child(_objective)
	title.add_child(_status)
	var round_panel := PanelContainer.new()
	round_panel.anchor_left = 0.73
	round_panel.anchor_right = 1.0
	round_panel.offset_top = 20
	round_panel.offset_right = -24
	round_panel.offset_bottom = 154
	round_panel.add_theme_stylebox_override("panel", _panel_style(Color("173744"), 13))
	add_child(round_panel)
	var round_content := VBoxContainer.new()
	round_content.add_theme_constant_override("separation", 3)
	round_panel.add_child(round_content)
	_score_label = _label("ОЧКИ  0", 21, Color("f3a846"))
	_timer_label = _label("ВРЕМЯ  15:00", 19, Color("f7f4e7"))
	_combo_label = _label("СЕРИЯ  0", 17, Color("8cdbbf"))
	_xp_label = _label("ОПЫТ  +0", 17, Color("cfddd8"))
	round_content.add_child(_score_label)
	round_content.add_child(_timer_label)
	round_content.add_child(_combo_label)
	round_content.add_child(_xp_label)
	_prompt = _label("", 22, Color("173744"))
	_prompt.anchor_left = 0.21
	_prompt.anchor_right = 0.79
	_prompt.anchor_top = 0.84
	_prompt.anchor_bottom = 0.93
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_prompt)
	_panel = PanelContainer.new()
	_panel.anchor_left = 0.26
	_panel.anchor_right = 0.74
	_panel.anchor_top = 0.19
	_panel.anchor_bottom = 0.81
	_panel.visible = false
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_panel.add_theme_stylebox_override("panel", _panel_style(Color("f3efe1"), 16))
	add_child(_panel)
	_panel_content = VBoxContainer.new()
	_panel_content.add_theme_constant_override("separation", 13)
	_panel.add_child(_panel_content)

func update_status(task: Dictionary, completed: int, score: int, time_left: float, nearest: Dictionary, streak: int = 0, target_count: int = 5, mode: String = "career") -> void:
	_objective.text = "%s %d/%d  ·  %s" % ["ПРАКТИКА" if mode == "practice" else "ЗАДАНИЕ", mini(completed + 1, target_count), target_count, task.topic]
	_status.text = "СТАНЦИЯ: %s" % _station_name(task.station)
	update_round_stats(completed, score, time_left, streak, mode)
	if nearest.is_empty():
		_prompt.text = "ИДИ К СТАНЦИИ: %s" % _station_name(task.station)
	elif nearest.id == task.station:
		_prompt.text = "[ E ]  %s" % nearest.name
	else:
		_prompt.text = "%s  ·  ТЕКУЩАЯ ЦЕЛЬ: %s" % [nearest.name, _station_name(task.station)]

func update_round_stats(completed: int, score: int, time_left: float, streak: int, mode: String) -> void:
	_score_label.text = "ОЧКИ  %d" % score
	_timer_label.text = "БЕЗ ТАЙМЕРА" if mode == "practice" else "ВРЕМЯ  %02d:%02d" % [int(time_left) / 60, int(time_left) % 60]
	_combo_label.text = "СЕРИЯ  %d  ·  x%s" % [streak, "2" if streak >= 5 else ("1.5" if streak >= 3 else "1")]
	_xp_label.text = "УЧЕБНЫЙ РЕЖИМ" if mode == "practice" else "ОПЫТ  +%d" % (completed * 50)

func show_task(task: Dictionary, station_id: String) -> void:
	_clear_panel()
	_panel.anchor_top = 0.19
	_panel.anchor_bottom = 0.81
	_panel.visible = true
	var eyebrow := _label("СТАНЦИЯ  /  " + _station_name(station_id), 17, Color("cf7729"))
	_panel_content.add_child(eyebrow)
	_panel_content.add_child(_label(task.prompt, 27, Color("243b43")))
	_panel_content.add_child(_label("ПОДСКАЗКА: " + task.hint, 17, Color("627679")))
	if task.get("interactionType", "") == "formula-builder":
		_show_formula_builder(task)
	elif task.get("interactionType", "") == "oxidation-state":
		_show_short_input()
	elif task.get("correctAnswer") is Dictionary:
		_show_numeric_input(task)
	elif task.get("interactionType", "") in ["equation-completion", "equation-balancing", "virtual-mixing", "ionic-equation", "dissociation"]:
		_show_equation_input()
	else:
		var cards := GridContainer.new()
		cards.columns = 2
		cards.add_theme_constant_override("h_separation", 10)
		cards.add_theme_constant_override("v_separation", 10)
		_panel_content.add_child(cards)
		for option in task.options:
			var button := Button.new()
			button.text = option
			button.custom_minimum_size = Vector2(270, 67)
			button.add_theme_font_size_override("font_size", 20)
			_style_button(button)
			button.pressed.connect(_submit_option.bind(option))
			cards.add_child(button)
	var cancel := Button.new()
	cancel.text = "ЗАКРЫТЬ"
	_style_button(cancel, true)
	cancel.pressed.connect(func() -> void: resume_requested.emit())
	_panel_content.add_child(cancel)
	var focus_target := _panel_content.get_child(3)
	if focus_target is GridContainer and focus_target.get_child_count() > 0:
		focus_target.get_child(0).grab_focus()
	elif focus_target is LineEdit:
		focus_target.grab_focus()
	elif focus_target is Label and _panel_content.get_child_count() > 4 and _panel_content.get_child(4) is LineEdit:
		_panel_content.get_child(4).grab_focus()
	elif focus_target is Label and _panel_content.get_child_count() > 4:
		var tile_grid := _panel_content.get_child(4)
		if tile_grid is GridContainer and tile_grid.get_child_count() > 0:
			tile_grid.get_child(0).grab_focus()
	elif focus_target is Button:
		focus_target.grab_focus()

func _show_formula_builder(task: Dictionary) -> void:
	_formula_buffer = ""
	_formula_tokens.clear()
	_formula_output = _label("_", 34, Color("173744"))
	_formula_output.custom_minimum_size.y = 53
	_panel_content.add_child(_formula_output)
	var tokens := GridContainer.new()
	tokens.columns = 3
	tokens.add_theme_constant_override("h_separation", 9)
	tokens.add_theme_constant_override("v_separation", 9)
	_panel_content.add_child(tokens)
	var token_options: Array = task.get("tokenOptions", task.get("parameters", {}).get("formulaTokens", []))
	for token in token_options:
		var tile := Button.new()
		tile.text = token
		tile.custom_minimum_size = Vector2(170, 54)
		tile.add_theme_font_size_override("font_size", 22)
		_style_button(tile)
		tile.pressed.connect(_append_token.bind(token))
		tokens.add_child(tile)
	var actions := HBoxContainer.new()
	_panel_content.add_child(actions)
	var back := Button.new()
	back.text = "УБРАТЬ"
	_style_button(back, true)
	back.pressed.connect(_remove_token)
	actions.add_child(back)
	var reset := Button.new()
	reset.text = "СБРОС"
	_style_button(reset, true)
	reset.pressed.connect(_reset_formula)
	actions.add_child(reset)
	var submit := Button.new()
	submit.text = "ПРОВЕРИТЬ  →"
	_style_button(submit)
	submit.pressed.connect(func() -> void: answer_submitted.emit(_formula_buffer))
	actions.add_child(submit)

func _show_short_input() -> void:
	var input := LineEdit.new()
	input.placeholder_text = "Введите степень окисления"
	input.custom_minimum_size.y = 55
	input.add_theme_font_size_override("font_size", 25)
	_panel_content.add_child(input)
	var submit := Button.new()
	submit.text = "ПРОВЕРИТЬ  →"
	submit.custom_minimum_size.y = 55
	_style_button(submit)
	submit.pressed.connect(func() -> void: answer_submitted.emit(input.text))
	input.text_submitted.connect(func(_text: String) -> void: answer_submitted.emit(input.text))
	_panel_content.add_child(submit)

func _show_equation_input() -> void:
	var guide := _label("Введи полное уравнение. Используй -> для стрелки и ^ для заряда иона.", 17, Color("627679"))
	_panel_content.add_child(guide)
	var input := LineEdit.new()
	input.placeholder_text = "Реагенты -> продукты"
	input.custom_minimum_size.y = 55
	input.add_theme_font_size_override("font_size", 22)
	input.caret_blink = true
	_panel_content.add_child(input)
	var submit := Button.new()
	submit.text = "ПРОВЕРИТЬ  →"
	submit.custom_minimum_size.y = 55
	_style_button(submit)
	submit.pressed.connect(func() -> void: answer_submitted.emit(input.text))
	input.text_submitted.connect(func(_text: String) -> void: answer_submitted.emit(input.text))
	_panel_content.add_child(submit)

func _show_numeric_input(task: Dictionary) -> void:
	var answer: Dictionary = task.correctAnswer
	var unit := str(answer.get("unit", ""))
	var instruction := "Введи число" if unit.is_empty() else "Введи число · единица: " + unit
	_panel_content.add_child(_label(instruction, 18, Color("627679")))
	var input := LineEdit.new()
	input.placeholder_text = "Твой расчёт"
	input.custom_minimum_size.y = 55
	input.add_theme_font_size_override("font_size", 24)
	input.caret_blink = true
	_panel_content.add_child(input)
	var submit := Button.new()
	submit.text = "ПРОВЕРИТЬ  →"
	submit.custom_minimum_size.y = 55
	_style_button(submit)
	submit.pressed.connect(func() -> void: answer_submitted.emit(input.text))
	input.text_submitted.connect(func(_text: String) -> void: answer_submitted.emit(input.text))
	_panel_content.add_child(submit)

func _submit_option(option: String) -> void:
	answer_submitted.emit(option)

func _append_token(token: String) -> void:
	_formula_tokens.append(token)
	_refresh_formula()

func _remove_token() -> void:
	if _formula_tokens.is_empty():
		return
	_formula_tokens.pop_back()
	_refresh_formula()

func _reset_formula() -> void:
	_formula_tokens.clear()
	_refresh_formula()

func _refresh_formula() -> void:
	_formula_buffer = "".join(_formula_tokens)
	_formula_output.text = _formula_buffer if not _formula_buffer.is_empty() else "_"

func show_wrong_station(task: Dictionary, station: Dictionary) -> void:
	_clear_panel()
	_panel.anchor_top = 0.27
	_panel.anchor_bottom = 0.71
	_panel.visible = true
	_panel_content.add_child(_label("ДРУГАЯ СТАНЦИЯ", 28, Color("c66c47")))
	_panel_content.add_child(_label("Здесь: " + station.name, 21, Color("243b43")))
	_panel_content.add_child(_label("Для текущего задания нужна станция: " + _station_name(task.station), 19, Color("627679")))
	var close := Button.new()
	close.text = "ВЕРНУТЬСЯ НА ПЛОЩАДКУ"
	close.pressed.connect(func() -> void: resume_requested.emit())
	_panel_content.add_child(close)
	close.grab_focus()

func show_feedback(correct: bool, task: Dictionary, awarded: int = 100, streak: int = 0) -> void:
	_clear_panel()
	_panel.anchor_top = 0.24
	_panel.anchor_bottom = 0.70 if not correct and not str(task.get("example", "")).is_empty() else 0.62
	_panel.visible = true
	var title := "ВЕРНО  +%d" % awarded if correct else "РАЗБЕРИ ОШИБКУ"
	_panel_content.add_child(_label(title, 29, Color("2c977b") if correct else Color("c66c47")))
	if correct and streak >= 3:
		_panel_content.add_child(_label("СЕРИЯ %d  ·  МНОЖИТЕЛЬ x%s" % [streak, "2" if streak >= 5 else "1.5"], 18, Color("2c977b")))
	_panel_content.add_child(_label(task.explanation, 21, Color("243b43")))
	_panel_content.add_child(_label("ПРАВИЛО: " + task.rule, 18, Color("627679")))
	if not correct:
		_panel_content.add_child(_label("ОТВЕТ: " + str(task.correctAnswer), 19, Color("243b43")))
		if not str(task.get("example", "")).is_empty():
			_panel_content.add_child(_label("ПРИМЕР: " + str(task.example), 18, Color("627679")))
	var next := Button.new()
	next.text = "СЛЕДУЮЩЕЕ ЗАДАНИЕ  →" if not correct else "ПРОДОЛЖИТЬ  →"
	next.custom_minimum_size.y = 55
	next.pressed.connect(func() -> void: resume_requested.emit())
	_panel_content.add_child(next)
	next.grab_focus()

func show_results(score: int, completed: int, time_left: float, target_count: int = 5, mode: String = "career") -> void:
	_clear_panel()
	_objective.text = "ПРАКТИКА ЗАВЕРШЕНА" if mode == "practice" else "СМЕНА ЗАВЕРШЕНА"
	_status.text = "ИТОГИ ТРЕНИРОВКИ" if mode == "practice" else "ИТОГИ УЧЕБНОЙ СМЕНЫ"
	_prompt.text = ""
	_panel.anchor_top = 0.24
	_panel.anchor_bottom = 0.71
	_panel.visible = true
	_panel_content.add_child(_label("ПРАКТИКА ЗАВЕРШЕНА" if mode == "practice" else "СМЕНА ЗАВЕРШЕНА", 31, Color("cf7729")))
	_panel_content.add_child(_label("Выполнено задач: %d / %d" % [completed, target_count], 23, Color("243b43")))
	_panel_content.add_child(_label("Очки: %d" % score, 23, Color("243b43")))
	if mode == "career":
		var stars := 3 if score >= 600 and completed == 5 else (2 if score >= 400 and completed == 5 else (1 if completed == 5 else 0))
		_panel_content.add_child(_label("ЗВЁЗДЫ: %s" % ("★".repeat(stars) + "☆".repeat(3 - stars)), 25, Color("cf7729")))
		_panel_content.add_child(_label("ОПЫТ: +%d" % (completed * 50), 20, Color("243b43")))
		_panel_content.add_child(_label("Осталось времени: %02d:%02d" % [int(time_left) / 60, int(time_left) % 60], 18, Color("627679")))
	else:
		_panel_content.add_child(_label("Тема пройдена без таймера", 20, Color("627679")))
	var menu := Button.new()
	menu.text = "ГЛАВНОЕ МЕНЮ"
	menu.custom_minimum_size.y = 55
	_style_button(menu)
	menu.pressed.connect(func() -> void: exit_requested.emit())
	_panel_content.add_child(menu)
	menu.grab_focus()

func show_pause() -> void:
	_clear_panel()
	_panel.anchor_top = 0.31
	_panel.anchor_bottom = 0.65
	_panel.visible = true
	_panel_content.add_child(_label("ПАУЗА", 31, Color("243b43")))
	var resume := Button.new()
	resume.text = "ПРОДОЛЖИТЬ"
	resume.custom_minimum_size.y = 55
	resume.pressed.connect(func() -> void: resume_requested.emit())
	_panel_content.add_child(resume)
	var menu := Button.new()
	menu.text = "ГЛАВНОЕ МЕНЮ"
	menu.pressed.connect(func() -> void: exit_requested.emit())
	_panel_content.add_child(menu)
	resume.grab_focus()

func close_panel() -> void:
	_panel.visible = false

func is_panel_open() -> bool:
	return _panel.visible

func _clear_panel() -> void:
	for child in _panel_content.get_children():
		_panel_content.remove_child(child)
		child.queue_free()

func _label(value: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label

func _panel_style(color: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(radius)
	style.set_content_margin_all(19)
	return style

func _style_button(button: Button, secondary: bool = false) -> void:
	var normal := _panel_style(Color("dce8de") if secondary else Color("e8a447"), 9)
	normal.set_content_margin_all(9)
	var hover := _panel_style(Color("c2d8d1") if secondary else Color("f2b95b"), 9)
	hover.set_content_margin_all(9)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	button.add_theme_color_override("font_color", Color("173744"))
	button.add_theme_color_override("font_hover_color", Color("173744"))

func _station_name(station_id: String) -> String:
	match station_id:
		"substance-storage": return "СКЛАД ВЕЩЕСТВ"
		"formula-board": return "ДОСКА ФОРМУЛ"
		"periodic-table-terminal": return "ПЕРИОДИЧЕСКАЯ СИСТЕМА"
		"reaction-bench": return "РЕАКЦИОННЫЙ СТОЛ"
		"mixing-station": return "СМЕСИТЕЛЬНАЯ СТАНЦИЯ"
		"ionic-reaction-station": return "ИОННАЯ ЛАБОРАТОРИЯ"
		"inspection-station": return "КОНТРОЛЬ МАТЕРИАЛОВ"
		"solution-laboratory": return "ЛАБОРАТОРИЯ РАСТВОРОВ"
	return station_id

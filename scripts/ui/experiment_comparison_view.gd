extends VBoxContainer

const OBSERVATION_VISUAL = preload("res://scripts/ui/comparison_observation_view.gd")

signal comparison_completed

var _runs: Array[Dictionary] = []
var _observed: Array[bool] = [false, false]
var _status: Label
var _buttons: HBoxContainer
var _observations: Array[Label] = []
var _mode := "kinetics"
var _visual: Control

func configure(parameters: Dictionary, mode: String = "kinetics", static_motion: bool = false) -> void:
	_mode = mode
	for run in parameters.get("comparisonRuns", []):
		_runs.append(run)
	assert(_runs.size() == 2)
	_build()
	if parameters.has("comparisonVisuals"):
		_visual = OBSERVATION_VISUAL.new()
		_visual.name = "ObservationVisual"
		_visual.configure(parameters.comparisonVisuals, static_motion)
		add_child(_visual)
		move_child(_visual, 2)

func is_complete() -> bool:
	return _observed[0] and _observed[1]

func focus_first() -> void:
	(_buttons.get_child(0) as Button).grab_focus()

func inspect_run(index: int) -> void:
	if index < 0 or index >= _runs.size() or _observed[index]:
		return
	_observed[index] = true
	if _visual != null:
		_visual.reveal(index)
	var button := _buttons.get_child(index) as Button
	button.disabled = true
	_observations[index].text = "%d · %s" % [index + 1, str(_runs[index].observation)]
	_observations[index].show()
	if is_complete():
		_status.text = "ОБА ИОНА ИЗУЧЕНЫ · ВЫБЕРИ ВЫВОД" if _mode == "salt" else ("ОБА УЧАСТКА ОСМОТРЕНЫ · ВЫБЕРИ ВЫВОД" if _mode == "corrosion" else ("ОБА ЭЛЕКТРОДА ИЗУЧЕНЫ · ВЫБЕРИ ВЫВОД" if _mode == "electrode" else ("ОБА СОСТОЯНИЯ ИЗУЧЕНЫ · ВЫБЕРИ ВЫВОД" if _mode == "equilibrium" else "ОБА ПРОГОНА ИЗУЧЕНЫ · ВЫБЕРИ ВЫВОД")))
		comparison_completed.emit()
	else:
		_status.text = "ОДИН ИОН ИЗУЧЕН · ОТКРОЙ ВТОРОЙ" if _mode == "salt" else ("ОДИН УЧАСТОК ОСМОТРЕН · ОТКРОЙ ВТОРОЙ" if _mode == "corrosion" else ("ОДИН ЭЛЕКТРОД ИЗУЧЕН · ОТКРОЙ ВТОРОЙ" if _mode == "electrode" else ("ПЕРВОЕ СОСТОЯНИЕ ИЗУЧЕНО · ОТКРОЙ ВТОРОЕ" if _mode == "equilibrium" else "ПЕРВЫЙ ПРОГОН ИЗУЧЕН · ЗАПУСТИ ВТОРОЙ")))
		(_buttons.get_child(1 - index) as Button).grab_focus()

func _build() -> void:
	add_theme_constant_override("separation", 5)
	_status = Label.new()
	_status.text = "АНАЛИЗ СОЛИ · ИССЛЕДУЙ ОБА ИОНА" if _mode == "salt" else ("ОСМОТР КОНСТРУКЦИИ · СРАВНИ ДВА УЧАСТКА" if _mode == "corrosion" else ("ГАЛЬВАНИЧЕСКИЙ ЭЛЕМЕНТ · ИССЛЕДУЙ ЭЛЕКТРОДЫ" if _mode == "electrode" else ("ВИРТУАЛЬНАЯ СИСТЕМА · СРАВНИ ДВА СОСТОЯНИЯ" if _mode == "equilibrium" else "ВИРТУАЛЬНЫЙ ОПЫТ · СРАВНИ ДВА ПРОГОНА")))
	_status.add_theme_font_size_override("font_size", 16)
	_status.add_theme_color_override("font_color", Color("243b43"))
	add_child(_status)
	_buttons = HBoxContainer.new()
	_buttons.name = "RunButtons"
	_buttons.add_theme_constant_override("separation", 8)
	add_child(_buttons)
	for index in range(_runs.size()):
		var button := Button.new()
		button.text = ("ИССЛЕДОВАТЬ: " if _mode == "salt" or _mode == "electrode" else ("ОСМОТРЕТЬ: " if _mode == "corrosion" else ("ПОКАЗАТЬ: " if _mode == "equilibrium" else "ЗАПУСК: "))) + str(_runs[index].setting)
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size = Vector2(0, 48)
		_style_button(button)
		button.pressed.connect(inspect_run.bind(index))
		_buttons.add_child(button)
	for index in range(_runs.size()):
		var observation := Label.new()
		observation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		observation.add_theme_font_size_override("font_size", 16)
		observation.add_theme_color_override("font_color", Color("243b43"))
		observation.hide()
		_observations.append(observation)
		add_child(observation)

func _style_button(button: Button) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("e8a447")
	normal.set_corner_radius_all(7)
	normal.set_content_margin_all(8)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("f2b95b")
	var disabled := normal.duplicate() as StyleBoxFlat
	disabled.bg_color = Color("b4b3ad")
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("font_color", Color("173744"))
	button.add_theme_color_override("font_focus_color", Color("173744"))
	button.add_theme_color_override("font_hover_color", Color("173744"))
	button.add_theme_color_override("font_disabled_color", Color("575c58"))

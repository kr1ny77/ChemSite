extends Node

const SITE_SCENE: PackedScene = preload("res://scenes/levels/construction_site.tscn")
const MENU_SCENE: PackedScene = preload("res://scenes/ui/main_menu.tscn")

var _current: Node

func _ready() -> void:
	show_menu()

func show_menu() -> void:
	_replace(MENU_SCENE)
	_current.start_requested.connect(start_game)

func start_game() -> void:
	_replace(SITE_SCENE)
	_current.exit_requested.connect(show_menu)
	_current.feedback_given.connect($AudioController.play_feedback)
	_current.station_used.connect($AudioController.play_interact)

func _replace(scene: PackedScene) -> void:
	if is_instance_valid(_current):
		_current.queue_free()
	_current = scene.instantiate()
	add_child(_current)

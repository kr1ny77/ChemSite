extends CharacterBody3D

@export var run_speed: float = 5.2
@export var acceleration: float = 17.0
@export var deceleration: float = 23.0
@export var turn_speed: float = 11.0

@onready var visual: Node3D = $Visual
var controls_enabled: bool = true
var _walk_phase: float = 0.0
var _animation_tree: AnimationTree
var _playback: AnimationNodeStateMachinePlayback
var _current_animation: String = ""
var _reaction_state: String = ""

func _ready() -> void:
	var model_scene := load("res://assets/models/character/chemist.glb") as PackedScene
	if model_scene:
		var model := model_scene.instantiate()
		visual.add_child(model)
		_setup_animation(model)

func _physics_process(delta: float) -> void:
	var input := Vector2.ZERO
	if controls_enabled:
		input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := Vector3(input.x, 0.0, input.y)
	var target := direction * run_speed
	var rate := acceleration if direction.length_squared() > 0.001 else deceleration
	velocity.x = move_toward(velocity.x, target.x, rate * delta)
	velocity.z = move_toward(velocity.z, target.z, rate * delta)
	velocity.y -= 20.0 * delta
	move_and_slide()
	if direction.length_squared() > 0.001:
		var target_yaw := atan2(direction.x, direction.z)
		visual.rotation.y = lerp_angle(visual.rotation.y, target_yaw, minf(1.0, turn_speed * delta))
		_walk_phase += delta * velocity.length() * 2.2
		visual.position.y = sin(_walk_phase) * 0.035
	else:
		visual.position.y = move_toward(visual.position.y, 0.0, delta * 0.3)
	if _reaction_state.is_empty():
		var movement_state := "Idle"
		if direction.length_squared() > 0.001:
			movement_state = "Run" if velocity.length() > 3.5 else "Walk"
		_travel(movement_state)

func play_interact() -> void:
	_reaction_state = "Interact"
	_travel(_reaction_state)

func play_reaction(correct: bool) -> void:
	_reaction_state = "Celebrate" if correct else "Failure"
	_travel(_reaction_state)

func clear_reaction() -> void:
	_reaction_state = ""
	_travel("Idle")

func _setup_animation(model: Node) -> void:
	var players := model.find_children("*", "AnimationPlayer", true, false)
	if players.is_empty():
		push_warning("Chemist GLB has no AnimationPlayer")
		return
	var player := players[0] as AnimationPlayer
	var machine := AnimationNodeStateMachine.new()
	var states := ["Idle", "Walk", "Run", "Turn", "Interact", "PickUp", "UseStation", "Celebrate", "Failure"]
	for state_name in states:
		if not player.has_animation(state_name):
			continue
		var animation := AnimationNodeAnimation.new()
		animation.animation = state_name
		machine.add_node(state_name, animation)
	for from_state in states:
		for to_state in states:
			if from_state == to_state or not machine.has_node(from_state) or not machine.has_node(to_state):
				continue
			var transition := AnimationNodeStateMachineTransition.new()
			transition.xfade_time = 0.12
			machine.add_transition(from_state, to_state, transition)
	_animation_tree = AnimationTree.new()
	visual.add_child(_animation_tree)
	_animation_tree.anim_player = _animation_tree.get_path_to(player)
	_animation_tree.tree_root = machine
	_animation_tree.active = true
	_playback = _animation_tree.get("parameters/playback") as AnimationNodeStateMachinePlayback
	_travel("Idle")

func _travel(state_name: String) -> void:
	if _playback == null or state_name == _current_animation:
		return
	_playback.travel(state_name)
	_current_animation = state_name

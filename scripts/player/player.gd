extends CharacterBody3D

signal footstep

@export var run_speed: float = 5.2
@export var acceleration: float = 14.0
@export var deceleration: float = 19.0
@export var turn_speed: float = 9.0

@onready var visual: Node3D = $Visual
var controls_enabled: bool = true
var reduced_motion := false
var _animation_tree: AnimationTree
var _playback: AnimationNodeStateMachinePlayback
var _current_animation: String = ""
var _reaction_state: String = ""
var _step_distance: float = 0.0

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
	var horizontal := Vector2(velocity.x, velocity.z)
	var desired := Vector2(target.x, target.z)
	var rate := acceleration if direction.length_squared() > 0.001 else deceleration
	horizontal = horizontal.move_toward(desired, rate * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.y
	velocity.y -= 20.0 * delta
	move_and_slide()
	# Collision response supplies the speed that is actually visible on screen.
	horizontal = Vector2(velocity.x, velocity.z)
	if is_on_floor() and controls_enabled and direction.length_squared() > 0.001:
		_step_distance += Vector2(velocity.x, velocity.z).length() * delta
		if _step_distance >= 1.5:
			_step_distance -= 1.5
			footstep.emit()
	else:
		_step_distance = 0.7
	var speed := horizontal.length()
	if speed > 0.08:
		var target_yaw := atan2(horizontal.x, horizontal.y)
		visual.rotation.y = lerp_angle(visual.rotation.y, target_yaw, 1.0 - exp(-turn_speed * delta))
	visual.position.y = 0.0
	if _reaction_state.is_empty():
		var movement_state := "Idle"
		if speed > 0.18:
			movement_state = "Run" if speed > 3.5 else "Walk"
		_travel(movement_state)
		if _animation_tree != null:
			_set_animation_rate("Walk", clampf(speed / 1.25, 0.5, 2.4))
			_set_animation_rate("Run", clampf(speed / 2.6, 0.5, 2.4))

func _set_animation_rate(state: String, rate: float) -> void:
	var parameter := "parameters/%s/TimeScale/scale" % state
	if not is_equal_approx(float(_animation_tree.get(parameter)), rate):
		_animation_tree.set(parameter, rate)

func play_interact() -> void:
	if reduced_motion:
		return
	_reaction_state = "Interact"
	_travel(_reaction_state)

func play_reaction(correct: bool) -> void:
	if reduced_motion:
		_reaction_state = ""
		_travel("Idle")
		return
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
		if state_name in ["Walk", "Run"]:
			var blend := AnimationNodeBlendTree.new()
			blend.add_node("Animation", animation)
			blend.add_node("TimeScale", AnimationNodeTimeScale.new())
			blend.connect_node("TimeScale", 0, "Animation")
			blend.connect_node("output", 0, "TimeScale")
			machine.add_node(state_name, blend)
		else:
			machine.add_node(state_name, animation)
	for from_state in states:
		for to_state in states:
			if from_state == to_state or not machine.has_node(from_state) or not machine.has_node(to_state):
				continue
			var transition := AnimationNodeStateMachineTransition.new()
			transition.xfade_time = 0.2
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

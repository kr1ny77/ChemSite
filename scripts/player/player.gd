extends CharacterBody3D

signal footstep

# The imported bind sole is at -17.899 mm; the capsule lower tip is at +5 mm.
const MODEL_GROUND_OFFSET := 0.022899
const WALK_NOMINAL_SPEED := 1.100972
const RUN_NOMINAL_SPEED := 2.934206

@export var run_speed: float = 5.2
@export var acceleration: float = 14.0
@export var deceleration: float = 19.0
@export var turn_speed: float = 16.0
@export var max_turn_rate: float = TAU * 2.0

@onready var visual: Node3D = $Visual
var controls_enabled: bool = true
var reduced_motion := false
var _animation_tree: AnimationTree
var _playback: AnimationNodeStateMachinePlayback
var _current_animation: String = ""
var _reaction_state: String = ""
var _step_state: String = ""
var _step_phase: float = 0.0
var _clip_lengths: Dictionary = {}
var _yaw_velocity: float = 0.0

func _ready() -> void:
	var model_scene := load("res://assets/models/character/chemist.glb") as PackedScene
	if model_scene:
		var model := model_scene.instantiate()
		model.position.y = MODEL_GROUND_OFFSET
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
	var speed := horizontal.length()
	_update_footstep(speed)
	if speed > 0.08:
		var target_yaw := atan2(horizontal.x, horizontal.y)
		_update_heading(target_yaw, delta)
	else:
		_yaw_velocity = 0.0
	visual.position.y = 0.0
	if _reaction_state.is_empty():
		var movement_state := "Idle"
		if speed > 0.18:
			var run_threshold := 3.25 if _current_animation == "Run" else 3.7
			movement_state = "Run" if speed > run_threshold else "Walk"
		_travel(movement_state)
		if _animation_tree != null:
			_set_animation_rate("Walk", clampf(speed / WALK_NOMINAL_SPEED, 0.5, 3.3))
			_set_animation_rate("Run", clampf(speed / RUN_NOMINAL_SPEED, 0.5, 2.4))

func _update_heading(target_yaw: float, delta: float) -> void:
	# Critically damped angular response starts and settles with gentle motion.
	var error := wrapf(visual.rotation.y - target_yaw, -PI, PI)
	var change := (_yaw_velocity + turn_speed * error) * delta
	var decay := exp(-turn_speed * delta)
	var next_yaw := target_yaw + (error + change) * decay
	var step := clampf(wrapf(next_yaw - visual.rotation.y, -PI, PI), -max_turn_rate * delta, max_turn_rate * delta)
	visual.rotation.y += step
	_yaw_velocity = clampf((_yaw_velocity - turn_speed * change) * decay, -max_turn_rate, max_turn_rate)

func _update_footstep(speed: float) -> void:
	if _playback == null or not controls_enabled or not is_on_floor() or speed <= 0.18:
		_step_state = ""
		return
	var state := str(_playback.get_current_node())
	if state not in ["Walk", "Run"]:
		_step_state = ""
		return
	var phase := fposmod(_playback.get_current_play_position() / float(_clip_lengths[state]), 1.0)
	if state == _step_state:
		for contact in [0.25, 0.75]:
			var crossed: bool = contact > _step_phase and contact <= phase
			if phase < _step_phase:
				crossed = contact > _step_phase or contact <= phase
			if crossed:
				footstep.emit()
	_step_state = state
	_step_phase = phase

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
		_clip_lengths[state_name] = player.get_animation(state_name).length
		if state_name in ["Walk", "Run"]:
			var blend := AnimationNodeBlendTree.new()
			blend.add_node("Animation", animation)
			blend.add_node("TimeScale", AnimationNodeTimeScale.new())
			blend.add_node("TimeSeek", AnimationNodeTimeSeek.new())
			blend.connect_node("TimeSeek", 0, "Animation")
			blend.connect_node("TimeScale", 0, "TimeSeek")
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
			if from_state in ["Walk", "Run"] and to_state in ["Walk", "Run"]:
				transition.reset = false
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
	if _current_animation in ["Walk", "Run"] and state_name in ["Walk", "Run"]:
		# Preserve which boot is supporting, despite different cycle durations.
		var phase := fposmod(_playback.get_current_play_position() / float(_clip_lengths[_current_animation]), 1.0)
		_animation_tree.set("parameters/%s/TimeSeek/seek_request" % state_name, phase * float(_clip_lengths[state_name]))
	_playback.travel(state_name)
	_current_animation = state_name

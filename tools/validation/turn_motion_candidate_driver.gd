extends CharacterBody3D

# Isolated prototype; production input and character resources retain their owners.
var model: Node3D
var tree: AnimationTree
var playback: AnimationNodeStateMachinePlayback
var elapsed := 0.0
var duration := 0.0
var paused := false
var interrupted := false
var requested_total := Vector3.ZERO
var blocked_ticks := 0
var maximum_step := 0.0
var initial_rotation := Quaternion.IDENTITY

func configure(scene: Node3D, action: String) -> void:
	collision_layer = 2
	collision_mask = 1
	floor_snap_length = 0.25
	var collider := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.32
	capsule.height = 1.65
	collider.shape = capsule
	collider.position.y = 0.83
	add_child(collider)
	model = scene
	model.position.y = 0.005
	add_child(model)
	var animations := model.find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer
	var machine := AnimationNodeStateMachine.new()
	for name in ["Idle", "TurnLeftStep", "TurnRightStep"]:
		var node := AnimationNodeAnimation.new()
		node.animation = name
		machine.add_node(name, node)
	for name in ["TurnLeftStep", "TurnRightStep"]:
		var transition := AnimationNodeStateMachineTransition.new()
		transition.xfade_time = 0.08
		machine.add_transition(name, "Idle", transition)
	tree = AnimationTree.new()
	model.add_child(tree)
	tree.anim_player = tree.get_path_to(animations)
	tree.tree_root = machine
	tree.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	tree.root_motion_local = false
	initial_rotation = quaternion
	var clip := animations.get_animation(action)
	duration = clip.length
	for index in range(clip.get_track_count()):
		var path := clip.track_get_path(index)
		if path.get_subname_count() > 0 and path.get_subname(0) == "pelvis":
			tree.root_motion_track = path
			break
	assert(not tree.root_motion_track.is_empty())
	tree.active = true
	playback = tree.get("parameters/playback")
	playback.start(action)
	tree.advance(0.0)

func _physics_process(delta: float) -> void:
	step(delta)

func step(delta: float) -> void:
	if paused:
		velocity = Vector3.ZERO
		return
	if elapsed == 0.0 and not is_on_floor():
		velocity = Vector3(0, velocity.y - 20.0 * delta, 0)
		move_and_slide()
		return
	var remaining := maxf(0.0, duration - elapsed)
	var advance_delta := delta if interrupted else minf(delta, remaining)
	tree.advance(advance_delta)
	var before := global_position
	var motion := Vector3.ZERO
	if not interrupted and remaining > 0.0:
		quaternion = (quaternion * tree.get_root_motion_rotation()).normalized()
		motion = initial_rotation * tree.get_root_motion_position()
		motion.y = 0.0
		requested_total += motion
	elapsed = minf(duration, elapsed + advance_delta)
	velocity.x = motion.x / delta
	velocity.z = motion.z / delta
	velocity.y = 0.0 if is_on_floor() else velocity.y - 20.0 * delta
	move_and_slide()
	var moved := Vector2(global_position.x - before.x, global_position.z - before.z)
	maximum_step = maxf(maximum_step, moved.length())
	if moved.distance_to(Vector2(motion.x, motion.z)) > 0.0001:
		blocked_ticks += 1
		interrupt()

func interrupt() -> void:
	interrupted = true
	velocity = Vector3.ZERO
	playback.travel("Idle")

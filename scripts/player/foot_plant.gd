extends SkeletonModifier3D

# Presentation-only, bounded world-space support. The authored gait owns timing.
const MAX_CORRECTION := 0.065
const RELEASE_SECONDS := 0.065
const MAX_BOOT_TWIST := deg_to_rad(65.0)
var processed_ticks := 0
var corrected_ticks := 0
var maximum_correction := 0.0
var maximum_length_error := 0.0
var maximum_height_error := 0.0
var maximum_boot_twist := 0.0
var player: CharacterBody3D
var _feet: Array[Dictionary] = []

func _ready() -> void:
	var skeleton := get_skeleton()
	for side in ["l", "r"]:
		_feet.append({"hip": skeleton.find_bone("thigh_" + side), "knee": skeleton.find_bone("calf_" + side), "foot": skeleton.find_bone("foot_" + side), "shift": 0.0 if side == "l" else 0.5, "support": false, "anchor": Transform3D.IDENTITY, "offset": Vector3.ZERO, "release": RELEASE_SECONDS})

func _process_modification_with_delta(delta: float) -> void:
	if player == null or _feet.is_empty():
		return
	processed_ticks += 1
	var skeleton := get_skeleton()
	var enabled: bool = player.controls_enabled and player.is_on_floor() and player._animation_tree.active and player._reaction_state.is_empty()
	var state := str(player._playback.get_current_node())
	enabled = enabled and str(player._playback.get_fading_from_node()) != "Idle" and state in ["Walk", "Run"] and Vector2(player.velocity.x, player.velocity.z).length() > 0.18
	if not enabled:
		for foot in _feet:
			foot.support = false
			foot.offset = Vector3.ZERO
			foot.release = RELEASE_SECONDS
		return
	var phase := fposmod(player._playback.get_current_play_position() / float(player._clip_lengths[state]), 1.0)
	var world := skeleton.global_transform
	for foot in _feet:
		var pose := skeleton.get_bone_global_pose(foot.foot)
		var authored := world * pose
		var support_phase := fposmod(phase - 0.25 + float(foot.shift), 1.0)
		var support := support_phase < (0.2 if state == "Run" else 0.5)
		if support:
			if not foot.support:
				foot.anchor = authored
			foot.offset = (foot.anchor.origin - authored.origin).limit_length(MAX_CORRECTION)
			# Keep the authored vertical profile; correct horizontal slide only.
			foot.offset.y = 0.0
			foot.release = 0.0
		elif foot.support:
			foot.release = 0.0
		else:
			foot.release = minf(RELEASE_SECONDS, float(foot.release) + delta)
		foot.support = support
		var weight := 1.0 if support else 1.0 - smoothstep(0.0, RELEASE_SECONDS, float(foot.release))
		if weight <= 0.0 or foot.offset.length_squared() < 0.00000001:
			continue
		corrected_ticks += 1
		maximum_correction = maxf(maximum_correction, foot.offset.length())
		var target := authored
		target.origin += foot.offset * weight
		var angle := authored.basis.get_rotation_quaternion().angle_to(foot.anchor.basis.get_rotation_quaternion())
		target.basis = authored.basis.slerp(foot.anchor.basis, minf(weight, MAX_BOOT_TWIST / maxf(angle, 0.0001)))
		maximum_boot_twist = maxf(maximum_boot_twist, authored.basis.get_rotation_quaternion().angle_to(target.basis.get_rotation_quaternion()))
		# Bound boot twist while preserving the flat authored sole.
		_solve_leg(skeleton, foot, world.affine_inverse() * target)

func _solve_leg(skeleton: Skeleton3D, foot: Dictionary, target: Transform3D) -> void:
	var hip := skeleton.get_bone_global_pose(foot.hip)
	var knee := skeleton.get_bone_global_pose(foot.knee)
	var ankle := skeleton.get_bone_global_pose(foot.foot)
	var upper := knee.origin - hip.origin
	var lower := ankle.origin - knee.origin
	var length_a := upper.length()
	var length_b := lower.length()
	# Keep ankle height while bounding the horizontal target to leg reach.
	var reach := length_a + length_b - 0.0001
	var vertical := target.origin.y - hip.origin.y
	var horizontal := Vector2(target.origin.x - hip.origin.x, target.origin.z - hip.origin.z)
	horizontal = horizontal.limit_length(sqrt(maxf(0.0, reach * reach - vertical * vertical)))
	target.origin.x = hip.origin.x + horizontal.x
	target.origin.z = hip.origin.z + horizontal.y
	var direction := target.origin - hip.origin
	var distance := clampf(direction.length(), absf(length_a - length_b) + 0.0001, length_a + length_b - 0.0001)
	var axis := direction.normalized()
	var pole := upper - axis * upper.dot(axis)
	if pole.length_squared() < 0.0000001:
		pole = Vector3.FORWARD - axis * Vector3.FORWARD.dot(axis)
	pole = pole.normalized()
	var along := (length_a * length_a - length_b * length_b + distance * distance) / (2.0 * distance)
	var bend := sqrt(maxf(0.0, length_a * length_a - along * along))
	var knee_position := hip.origin + axis * along + pole * bend
	var end_position := hip.origin + axis * distance
	hip.basis = Basis(Quaternion(upper.normalized(), (knee_position - hip.origin).normalized())) * hip.basis
	knee.basis = Basis(Quaternion(lower.normalized(), (end_position - knee_position).normalized())) * knee.basis
	knee.origin = knee_position
	target.origin = end_position
	skeleton.set_bone_global_pose(foot.hip, hip)
	skeleton.set_bone_global_pose(foot.knee, knee)
	skeleton.set_bone_global_pose(foot.foot, target)
	maximum_length_error = maxf(maximum_length_error, maxf(absf((knee.origin - hip.origin).length() - length_a), absf((target.origin - knee.origin).length() - length_b)))
	maximum_height_error = maxf(maximum_height_error, absf(target.origin.y - ankle.origin.y))

# Planted stepping turn candidate

Status: isolated physical root-motion prototype verified; production player uses verified 0.1.3 motion.

## Motion contract

Two actions, `TurnLeftStep` and `TurnRightStep`, turn 90° in 0.755208 seconds.
The pelvis remains upright. The first 40% pivots over the left supporting
foot while the right foot steps; 40–80% transfers support to the right foot
while the left foot steps; the last 20% aligns the right foot with the new
heading. Swing clearance is 55 mm. The final posture aligns both boots
with the body. Root yaw and approximately 100 mm root translation are authored.
This is a stepping-turn prototype for future transition work.

The accepted character geometry, materials, rig and nine existing actions
are loaded from the durable source. The authoring scene retains 384 FPS;
changing this value stretches the pre-existing actions during export.

## Reproduction

Run Blender with `--background --factory-startup --python-exit-code 1 --python`
and each source script in order:

1. `tools/blender/author_cartoon_turn.py`
2. `tools/blender/measure_cartoon_turn.py`
3. `tools/blender/render_cartoon_turn.py`

The native candidate gate is
`Godot --headless --path . --script tools/validation/cartoon_turn_candidate_smoke.gd`.
It directly imports the candidate using GLTFDocument and a 384 Hz bake,
without replacing the production asset or AnimationTree.

## Evidence

Output directory: `artifacts/cartoon-turn-candidate/`.

- `cartoon_turn.blend`, `cartoon_turn.glb`: editable source/export candidates.
- `inspection.json`: Blender Agent Studio fresh GLB inspection; 11 actions,
  15 bones, no reported issues.
- `source_checks.json`: authored support ankle drift below 0.00003 mm.
- `exported_sole_checks.json`: actual supporting sole geometry, 233 samples
  per action; maximum drift 0.00173 mm and floor error below 0.00013 mm.
- `native_checks.json`: 233 samples per action in Godot, drift 0.00178 mm
  and floor error below 0.00014 mm.
- `final-evidence/`: six source views and seven critical-phase views from the
  preceding animation revision; retained as geometry evidence.
- `motion/`: all 80 exported action frames from front and side reviewed on
  four chronological sheets. Four 24 FPS MP4 previews generated. Normal-speed
  playback review remains pending.

Initial 30 Hz native bake produced 3.486 mm sampled support drift and failed
the unchanged 1 mm gate. Matching the production 384 Hz bake passes. The
candidate diagnostic includes a bounded timeout and explicit failing exit.

## Physical root-motion prototype

`turn_motion_candidate_driver.gd` runs AnimationTree in the body's physics callback,
extracts pelvis translation/yaw and applies capsule movement through move_and_slide.
The initial world rotation transforms authored translation; root_motion_local=false.
Engine contract: https://docs.godotengine.org/en/stable/classes/class_animationmixer.html.

`turn_motion_candidate_smoke.gd` passes 27 cases at 30/60/120 Hz: both turns
from two initial headings (12), pause/resume, three interruption phases and a
blocking wall (15). Maximum endpoint error is 0.000029802 mm, yaw error 0.000001752 radians,
support-point displacement 0.002132 mm and floor-profile error 1.033482 mm.
Physical floor-profile tolerance is the production grounding gate of 3 mm;
support displacement retains 1 mm. Dense fixed-transform GLB checks retain their
1 mm height/displacement gates. Tests cover a flat floor and isolated capsule.

The first physical test exposed a 45° foot-orientation discontinuity at the
40% support transfer, producing 35.588 mm displacement. The repaired clip eases
swing orientation from its release heading. Export validation now checks every
sole point throughout the cycle against a 3.5 m/s speed gate; measured maxima
are 2.621 and 3.030 m/s. Fresh repaired exports pass dense and physical checks.
`root_motion_contact_failure.json` preserves the preceding failing revision.

`capture_turn_motion_candidate.gd` produced 28 current native Forward+ frames
from two angles, including both sides of release. These and all 80 repaired
exported chronological frames were reviewed. Normal-speed playback remains pending.

## Remaining promotion gates

Review normal-speed playback. Integrate the prototype with production movement
and camera;
measure start/end continuity and transitions from Walk/Run. The in-place
prototype alone does not establish improved moving corner/reversal contact.
Compare fresh paired 30/60/120 Hz controller runs and inspect native gameplay
from two angles, then refresh platform exports before promotion.

## Dedicated-root follow-up

The isolated hierarchy and transition investigation is recorded in
`TURN_LOCOMOTION_TRANSITIONS.md`. It retains this candidate as the pose-preservation
baseline and uses a separate artifact directory. Root extraction passes; gait
transition contact currently fails the production floor tolerance.

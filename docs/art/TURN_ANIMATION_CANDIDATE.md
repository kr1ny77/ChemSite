# Planted stepping turn candidate

Status: authored/exported candidate; production player still uses verified 0.1.3 motion.

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
- `final-evidence/`: six source views and seven critical-phase views reviewed.
- `motion/`: all 80 exported action frames from front and side reviewed on
  four chronological sheets. Four 24 FPS MP4 previews generated. Normal-speed
  playback review remains pending.

Initial 30 Hz native bake produced 3.486 mm sampled support drift and failed
the unchanged 1 mm gate. Matching the production 384 Hz bake passes. The
candidate diagnostic includes a bounded timeout and explicit failing exit.

## Remaining promotion gates

Review full exported chronological frames and normal-speed playback. Integrate
root motion with collision-resolved movement, camera and interruption handling;
measure start/end continuity and transitions from Walk/Run. The in-place
prototype alone does not establish improved moving corner/reversal contact.
Compare fresh paired 30/60/120 Hz controller runs and inspect native gameplay
from two angles, then refresh platform exports before promotion.

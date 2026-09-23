"""Fresh-import the ChemSite character and isolate one exported action for visual QA."""

import sys
from pathlib import Path

import bpy


ROOT = Path(__file__).resolve().parents[2]
action_name = sys.argv[-1]
if action_name not in {"Idle", "Walk", "Run", "Turn", "Interact", "PickUp", "UseStation", "Celebrate", "Failure"}:
    raise ValueError(f"Unsupported review action: {action_name}")

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
bpy.ops.import_scene.gltf(filepath=str(ROOT / "assets/models/character/chemist.glb"))
rig = next(obj for obj in bpy.data.objects if obj.type == "ARMATURE")
action = bpy.data.actions.get(action_name)
if action is None:
    raise RuntimeError(f"Exported action missing: {action_name}")
rig.animation_data_create()
for track in rig.animation_data.nla_tracks:
    track.mute = True
rig.animation_data.action = action
bpy.context.scene.frame_set(int(action.frame_range[0]))

output = ROOT / "artifacts" / "character-action-review"
output.mkdir(parents=True, exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=str(output / f"{action_name.lower()}.blend"))
print("ACTION_REVIEW", action_name, output / f"{action_name.lower()}.blend")

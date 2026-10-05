"""Fresh-import a character GLB and save one animation pose for multiview review.

Usage: blender -b --python tools/blender/pose_character_action.py -- Walk 7
"""

import sys
from pathlib import Path

import bpy

root = Path(__file__).resolve().parents[2]
asset = root / "assets/models/character/chemist.glb"
clip_name, frame_text = sys.argv[sys.argv.index("--") + 1:]
frame = int(frame_text)

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
bpy.ops.import_scene.gltf(filepath=str(asset))
rigs = [obj for obj in bpy.data.objects if obj.type == "ARMATURE"]
assert len(rigs) == 1, f"Expected one imported rig; found {len(rigs)}"
clip = bpy.data.actions.get(clip_name)
assert clip is not None, f"Missing action {clip_name}"
rig = rigs[0]
rig.animation_data_create()
rig.animation_data.action = clip
bpy.context.scene.frame_set(frame)
bpy.context.view_layer.update()
out = root / "artifacts/character-candidate/poses"
out.mkdir(parents=True, exist_ok=True)
path = out / f"{clip_name.lower()}-{frame:02d}.blend"
bpy.ops.wm.save_as_mainfile(filepath=str(path))
print("CHEMSITE_POSE", path)

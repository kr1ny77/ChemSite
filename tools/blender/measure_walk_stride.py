"""Measure steady Walk stance ankle travel after a fresh GLB import.

The virtual root moves at the production clip's nominal speed. This ankle
trajectory gate complements skinned shoe contact validation in Godot.
"""
import bpy
import json
from pathlib import Path

root = Path(__file__).resolve().parents[2]
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
bpy.ops.import_scene.gltf(filepath=str(root / "assets/models/character/chemist.glb"))
rig = next(obj for obj in bpy.data.objects if obj.type == "ARMATURE")
rig.animation_data_create()
clip = bpy.data.actions["Walk"]
rig.animation_data.action = clip
first, last = clip.frame_range
fps = bpy.context.scene.render.fps
speed = 1.100972
report = {"nominal_speed": speed, "clip_duration": (last - first) / fps, "feet": {}}
for bone, start in (("foot_l", 0.25), ("foot_r", 0.75)):
    samples = []
    for index in range(105):
        phase = start + 0.5 * index / 104.0
        frame = first + (last - first) * (phase % 1.0)
        bpy.context.scene.frame_set(int(frame), subframe=frame % 1.0)
        point = rig.matrix_world @ rig.pose.bones[bone].matrix.translation
        time = (last - first) * (phase - start) / fps
        samples.append((phase, point.y - speed * time))
    drift = max(point for _, point in samples) - min(point for _, point in samples)
    report["feet"][bone] = {"drift_range_m": drift, "samples": samples}
    print("WALK_STRIDE", bone, "drift_range_m", round(drift, 6))
    assert drift < 0.004, f"{bone} stance ankle drifts by {drift:.4f} m"
output = root / "artifacts/character-candidate/walk-stride-report.json"
output.write_text(json.dumps(report, indent=2))
print("WALK_STRIDE_VALIDATION_OK", output)

"""Fresh-import Walk/Run and measure both supporting ankle trajectories."""
import bpy
import json
from pathlib import Path

root = Path(__file__).resolve().parents[2]
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
bpy.ops.import_scene.gltf(filepath=str(root / "assets/models/character/chemist.glb"))
rig = next(obj for obj in bpy.data.objects if obj.type == "ARMATURE")
rig.animation_data_create()
report = {}
for name, speed, stance in (("Walk", 1.100972, 0.5), ("Run", 2.934206, 0.35)):
    clip = bpy.data.actions[name]
    rig.animation_data.action = clip
    first, last = clip.frame_range
    duration = (last - first) / bpy.context.scene.render.fps
    report[name] = {"nominal_speed": speed, "clip_duration": duration, "feet": {}}
    for bone, start in (("foot_l", 0.25), ("foot_r", 0.75)):
        samples = []
        for index in range(105):
            phase = start + stance * index / 104.0
            frame = first + (last - first) * (phase % 1.0)
            bpy.context.scene.frame_set(int(frame), subframe=frame % 1.0)
            point = rig.matrix_world @ rig.pose.bones[bone].matrix.translation
            samples.append((phase, point.y - speed * (phase - start) * duration))
        drift = max(point for _, point in samples) - min(point for _, point in samples)
        report[name]["feet"][bone] = {"drift_range_m": drift, "samples": samples}
        print("LOCOMOTION_STRIDE", name, bone, "drift_range_m", round(drift, 6))
        assert drift < 0.004, f"{name}/{bone} stance ankle drifts by {drift:.4f} m"
output = root / "artifacts/character-candidate/walk-stride-report.json"
output.write_text(json.dumps(report, indent=2))
print("LOCOMOTION_STRIDE_VALIDATION_OK", output)

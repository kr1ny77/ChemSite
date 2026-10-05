"""Report boot clearance over imported Walk and Run clips.

Usage: blender -b --python tools/blender/measure_foot_contact.py
"""

from pathlib import Path
import json

import bpy

root = Path(__file__).resolve().parents[2]
bpy.ops.import_scene.gltf(filepath=str(root / "assets/models/character/chemist.glb"))
rig = next(obj for obj in bpy.data.objects if obj.type == "ARMATURE")
shoes = next(obj for obj in bpy.data.objects if obj.type == "MESH" and "shoes06" in obj.name)
rig.animation_data_create()
report = {}
for name in ("Idle", "Walk", "Run"):
    clip = bpy.data.actions[name]
    rig.animation_data.action = clip
    first, last = (int(value) for value in clip.frame_range)
    samples = []
    for tick in range(first * 4, last * 4 + 1):
        frame = tick / 4.0
        bpy.context.scene.frame_set(int(frame), subframe=frame % 1.0)
        depsgraph = bpy.context.evaluated_depsgraph_get()
        evaluated = shoes.evaluated_get(depsgraph)
        mesh = evaluated.to_mesh()
        world = evaluated.matrix_world
        left = min((world @ vertex.co).z for vertex in mesh.vertices if (world @ vertex.co).x < 0)
        right = min((world @ vertex.co).z for vertex in mesh.vertices if (world @ vertex.co).x > 0)
        evaluated.to_mesh_clear()
        samples.append((frame, left, right))
    support = [min(left, right) for _, left, right in samples]
    error = max(abs(height + 0.017899) for height in support)
    report[name] = {"samples": samples, "minimum_sole": min(support),
                    "maximum_sole": max(support), "support_plane_error": error}
    print("FOOT_CONTACT", name, "samples", len(samples),
          "min", round(min(support), 6), "max", round(max(support), 6),
          "support_error", round(error, 6))
    assert min(support) >= -0.019899, f"{name}: shoe penetrates bind sole plane"
    if name in ("Idle", "Walk"):
        assert error < 0.002, f"{name}: supporting shoe floats above sole plane"
output = root / "artifacts/character-candidate/foot-contact-report.json"
output.write_text(json.dumps(report, indent=2))
print("FOOT_CONTACT_VALIDATION_OK", output)

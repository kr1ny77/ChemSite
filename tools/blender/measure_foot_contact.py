"""Report boot clearance over imported Walk and Run clips.

Usage: blender -b --python tools/blender/measure_foot_contact.py
"""

from pathlib import Path

import bpy

root = Path(__file__).resolve().parents[2]
bpy.ops.import_scene.gltf(filepath=str(root / "assets/models/character/chemist.glb"))
rig = next(obj for obj in bpy.data.objects if obj.type == "ARMATURE")
shoes = next(obj for obj in bpy.data.objects if obj.type == "MESH" and "shoes06" in obj.name)
rig.animation_data_create()
for name in ("Idle", "Walk", "Run"):
    clip = bpy.data.actions[name]
    rig.animation_data.action = clip
    first, last = (int(value) for value in clip.frame_range)
    samples = []
    for frame in range(first, last + 1):
        bpy.context.scene.frame_set(frame)
        depsgraph = bpy.context.evaluated_depsgraph_get()
        evaluated = shoes.evaluated_get(depsgraph)
        mesh = evaluated.to_mesh()
        world = evaluated.matrix_world
        left = min((world @ vertex.co).z for vertex in mesh.vertices if (world @ vertex.co).x < 0)
        right = min((world @ vertex.co).z for vertex in mesh.vertices if (world @ vertex.co).x > 0)
        evaluated.to_mesh_clear()
        samples.append((frame, round(left, 3), round(right, 3)))
    print("FOOT_CONTACT", name, samples)

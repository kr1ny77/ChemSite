"""Repair cuff weights in the current authored character; write a review candidate.

Run with Blender --background --factory-startup --python this_file.
The production source and GLB are preserved until candidate validation.
"""
import bpy
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'artifacts/cartoon-sleeve-repair'
OUT.mkdir(parents=True, exist_ok=True)
bpy.ops.wm.open_mainfile(filepath=str(ROOT / 'tools/blender/source/cartoon_chemist.blend'))
body = bpy.data.objects['Continuous workwear']
rig = next(obj for obj in bpy.data.objects if obj.type == 'ARMATURE')

def distance(point, bone):
    segment = bone.tail_local - bone.head_local
    fraction = max(0.0, min(1.0, (point - bone.head_local).dot(segment) / segment.length_squared))
    return (point - bone.head_local - fraction * segment).length

repaired = []
for vertex in body.data.vertices:
    point = body.matrix_world @ vertex.co
    if not (abs(point.x) > .285 and .43 < point.z < .48):
        continue
    old = {body.vertex_groups[g.group].name: g.weight for g in vertex.groups if g.weight > .00001}
    if not any(name.startswith(('pelvis', 'thigh', 'calf')) for name in old):
        continue
    side = 'l' if point.x > 0 else 'r'
    names = ['spine_03', 'upperarm_' + side, 'lowerarm_' + side]
    scores = {name: 1 / (.018 + distance(point, rig.data.bones[name])) ** 4 for name in names}
    total = sum(scores.values())
    for group in body.vertex_groups:
        group.remove([vertex.index])
    for name, score in scores.items():
        body.vertex_groups[name].add([vertex.index], score / total, 'REPLACE')
    repaired.append(vertex.index)
assert len(repaired) in (0, 153), 'Unexpected cuff region; inspect current source before repair'
bpy.context.scene.frame_set(1)
bpy.ops.object.select_all(action='DESELECT')
rig.select_set(True)
for obj in bpy.data.objects:
    if obj.type == 'MESH':
        obj.select_set(True)
bpy.ops.wm.save_as_mainfile(filepath=str(OUT / 'cartoon_chemist.blend'))
bpy.ops.export_scene.gltf(filepath=str(OUT / 'cartoon_chemist.glb'), export_format='GLB',
                         use_selection=True, export_apply=True, export_animation_mode='NLA_TRACKS',
                         export_anim_slide_to_zero=True)
(OUT / 'repair.json').write_text(json.dumps({'repaired_vertices': repaired,
    'scope': 'cuff weights only; existing geometry, materials, rig and actions retained'}, indent=2) + '\n')
print('CARTOON_SLEEVE_WEIGHTS_REPAIRED', len(repaired))

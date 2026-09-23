"""Create a compact palletized cement-and-brick storage assembly."""

from pathlib import Path

import bpy


ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / "assets/models/environment"
SOURCE = ROOT / "tools/blender/source"
OUTPUT.mkdir(parents=True, exist_ok=True)
SOURCE.mkdir(parents=True, exist_ok=True)

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)


def material(name, color, roughness=0.7, metallic=0.0):
    result = bpy.data.materials.new(name)
    result.diffuse_color = (*color, 1.0)
    result.use_nodes = True
    shader = result.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = (*color, 1.0)
    shader.inputs["Roughness"].default_value = roughness
    shader.inputs["Metallic"].default_value = metallic
    return result


timber = material("sealed pallet timber", (0.42, 0.27, 0.13))
timber_edge = material("pallet edge grain", (0.28, 0.18, 0.09))
cement = material("cement paper sacks", (0.73, 0.72, 0.63), 0.88)
cement_label = material("cement label ink", (0.11, 0.34, 0.39))
brick = material("warm construction brick", (0.61, 0.29, 0.18), 0.82)
brick_top = material("sunlit brick face", (0.72, 0.36, 0.22), 0.82)
strap = material("blue retaining strap", (0.08, 0.28, 0.36), 0.42, 0.2)
steel = material("galvanized tie hardware", (0.40, 0.48, 0.48), 0.38, 0.55)


def box(name, location, dimensions, surface, bevel=0.02):
    bpy.ops.mesh.primitive_cube_add(size=1, location=location)
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = dimensions
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(surface)
    if bevel:
        modifier = obj.modifiers.new("rounded edge", "BEVEL")
        modifier.width = min(bevel, min(dimensions) * 0.3)
        modifier.segments = 3
        obj.modifiers.new("weighted normals", "WEIGHTED_NORMAL")
    return obj


def bag(name, location, dimensions):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=20, ring_count=10, location=location)
    obj = bpy.context.object
    obj.name = name
    obj.scale = (dimensions[0] / 2, dimensions[1] / 2, dimensions[2] / 2)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(cement)
    for face in obj.data.polygons:
        face.use_smooth = True
    return obj


def pallet(name, center_x):
    for y in (-0.53, 0.0, 0.53):
        box(name + " runner", (center_x, y, 0.12), (1.48, 0.20, 0.17), timber_edge, 0.025)
    for x in (-0.6, -0.3, 0.0, 0.3, 0.6):
        box(name + " top slat", (center_x + x, 0, 0.24), (0.23, 1.37, 0.09), timber, 0.018)


pallet("cement pallet", -0.95)
pallet("brick pallet", 0.95)

# Three uneven courses of bags give a soft, authored silhouette.
for layer, z in enumerate((0.41, 0.66, 0.91)):
    for x in (-1.35, -0.55):
        for y in (-0.30, 0.30):
            offset = 0.045 if layer == 1 else 0.0
            bag("sealed cement sack", (x + offset, y, z), (0.72, 0.52, 0.24))
            if layer == 2:
                box("printed cement band", (x + offset, y, z + 0.105), (0.35, 0.12, 0.012), cement_label, 0.004)

# Bonded courses of bricks on the second pallet, with visible offset joints.
for layer in range(4):
    for column in range(3):
        for row in range(2):
            x = 0.39 + column * 0.54 + (0.08 if layer % 2 else 0.0)
            y = -0.30 + row * 0.60
            z = 0.34 + layer * 0.21
            box("brick body", (x, y, z), (0.50, 0.53, 0.18), brick, 0.015)
            box("brick top face", (x, y, z + 0.092), (0.43, 0.44, 0.014), brick_top, 0.005)

# Two steel ratchet straps contain the brick load and add a strong color accent.
for x in (0.60, 1.70):
    box("vertical cargo strap", (x, -0.61, 0.72), (0.052, 0.018, 0.84), strap, 0.005)
    box("strap over top", (x, 0, 1.15), (0.052, 1.23, 0.018), strap, 0.005)
    box("ratchet buckle", (x, -0.635, 0.43), (0.16, 0.04, 0.09), steel, 0.008)

for obj in bpy.data.objects:
    if obj.type == "MESH":
        for modifier in list(obj.modifiers):
            bpy.context.view_layer.objects.active = obj
            bpy.ops.object.modifier_apply(modifier=modifier.name)

bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE / "material_cache.blend"))

# Preserve editable pieces in the source file and export one mesh per material.
for surface in (timber, timber_edge, cement, cement_label, brick, brick_top, strap, steel):
    pieces = [
        obj for obj in bpy.data.objects
        if obj.type == "MESH" and obj.data.materials and obj.data.materials[0] == surface
    ]
    bpy.ops.object.select_all(action="DESELECT")
    for piece in pieces:
        piece.select_set(True)
    bpy.context.view_layer.objects.active = pieces[0]
    bpy.ops.object.join()

bpy.ops.export_scene.gltf(filepath=str(OUTPUT / "material_cache.glb"), export_format="GLB", export_apply=True)
print("MATERIAL_CACHE_EXPORT", OUTPUT / "material_cache.glb")

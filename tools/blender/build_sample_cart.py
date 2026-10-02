"""Build the ChemSite sample cart as editable Blender source and a joined GLB."""

from math import pi
from pathlib import Path

import bpy


ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / "assets/models/environment"
SOURCE = ROOT / "tools/blender/source"
OUTPUT.mkdir(parents=True, exist_ok=True)
SOURCE.mkdir(parents=True, exist_ok=True)

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)


def material(name, color, roughness=0.6, metallic=0.0):
    result = bpy.data.materials.new(name)
    result.diffuse_color = (*color, 1.0)
    result.use_nodes = True
    shader = result.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = (*color, 1.0)
    shader.inputs["Roughness"].default_value = roughness
    shader.inputs["Metallic"].default_value = metallic
    return result


navy = material("cart navy powder coat", (0.075, 0.19, 0.23), 0.56, 0.22)
tray = material("cart warm enamel shelf", (0.70, 0.75, 0.68), 0.58, 0.18)
silver = material("cart brushed metal hardware", (0.47, 0.55, 0.54), 0.42, 0.55)
amber = material("cart safety amber", (0.92, 0.55, 0.12), 0.5, 0.12)
rubber = material("cart caster rubber", (0.065, 0.09, 0.09), 0.82)
sample = material("cart sealed specimen jar", (0.70, 0.82, 0.79), 0.42, 0.06)
cyan = material("cart sample identification cyan", (0.12, 0.55, 0.62), 0.48, 0.08)


def box(name, location, dimensions, surface, bevel=0.012):
    bpy.ops.mesh.primitive_cube_add(size=1, location=location)
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = dimensions
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(surface)
    if bevel:
        edge = obj.modifiers.new("soft manufactured edge", "BEVEL")
        edge.width = min(bevel, min(dimensions) * 0.28)
        edge.segments = 2
        obj.modifiers.new("weighted normals", "WEIGHTED_NORMAL")
    return obj


def cylinder(name, location, radius, depth, surface, sides=24, rotation=None):
    bpy.ops.mesh.primitive_cylinder_add(vertices=sides, radius=radius, depth=depth, location=location)
    obj = bpy.context.object
    obj.name = name
    if rotation is not None:
        obj.rotation_euler = rotation
    obj.data.materials.append(surface)
    for face in obj.data.polygons:
        face.use_smooth = len(face.vertices) == 4
    return obj


# Four posts, wheel forks, and cross members support the two removable trays.
for x in (-0.62, 0.62):
    for y in (-0.29, 0.29):
        box("corner frame upright", (x, y, 0.64), (0.055, 0.055, 0.92), navy)
        box("caster fork", (x, y, 0.18), (0.09, 0.095, 0.18), silver)
        cylinder("rubber caster", (x, y, 0.105), 0.105, 0.075, rubber, rotation=(pi / 2, 0, 0))
        cylinder("caster hub", (x, y - 0.045, 0.105), 0.043, 0.013, silver, rotation=(pi / 2, 0, 0))

for z in (0.35, 0.88):
    box("enamel shelf", (0, 0, z), (1.40, 0.76, 0.06), tray, 0.026)
    for x in (-0.68, 0.68):
        box("raised tray side", (x, 0, z + 0.065), (0.035, 0.74, 0.10), navy)
    for y in (-0.36, 0.36):
        box("raised tray end", (0, y, z + 0.065), (1.34, 0.032, 0.10), navy)
    box("amber tray front strip", (0, -0.389, z + 0.035), (1.24, 0.012, 0.035), amber, 0.004)

for z in (0.25, 0.78):
    for y in (-0.29, 0.29):
        box("under-shelf cross brace", (0, y, z), (1.24, 0.048, 0.05), navy)

# A rear push grip and its two supports remain distinct from the shelf rails.
for x in (-0.53, 0.53):
    box("handle upright", (x, 0.39, 1.035), (0.055, 0.055, 0.26), silver)
box("amber rear grip", (0, 0.39, 1.17), (1.18, 0.085, 0.065), amber, 0.025)

# Shallow drawers and individual pulls provide a front-facing work-cart cue.
for x in (-0.33, 0.33):
    box("sealed sample drawer", (x, -0.365, 0.735), (0.57, 0.055, 0.14), navy, 0.018)
    box("drawer pull", (x, -0.405, 0.735), (0.18, 0.025, 0.03), silver, 0.007)

# Three rows of capped samples sit inside a fitted organizer on the upper tray.
box("sample rack base", (-0.28, 0.025, 0.937), (0.66, 0.44, 0.04), navy, 0.012)
for x in (-0.48, -0.28, -0.08):
    for y in (-0.10, 0.12):
        cylinder("sealed small sample", (x, y, 1.045), 0.067, 0.19, sample, sides=20)
        cylinder("cyan sample cap", (x, y, 1.156), 0.073, 0.042, cyan, sides=20)

# Two larger capped jars and a lower transport case break up the repeated grid.
for x in (0.26, 0.48):
    cylinder("sealed aggregate jar", (x, 0.08, 1.035), 0.093, 0.17, sample)
    cylinder("amber jar cap", (x, 0.08, 1.143), 0.10, 0.045, amber)
    box("cyan jar label", (x, -0.019, 1.025), (0.12, 0.012, 0.06), cyan, 0.003)
box("lower specimen case", (0.10, 0.015, 0.445), (0.66, 0.42, 0.14), navy, 0.028)
box("case cyan seal", (0.10, -0.201, 0.455), (0.28, 0.015, 0.045), cyan, 0.004)
box("case handle", (0.10, 0.015, 0.545), (0.24, 0.07, 0.035), silver, 0.008)

bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE / "sample_cart.blend"))

for obj in list(bpy.data.objects):
    if obj.type == "MESH":
        bpy.context.view_layer.objects.active = obj
        for modifier in list(obj.modifiers):
            bpy.ops.object.modifier_apply(modifier=modifier.name)

for surface in (navy, tray, silver, amber, rubber, sample, cyan):
    pieces = [obj for obj in bpy.data.objects if obj.type == "MESH" and obj.data.materials and obj.data.materials[0] == surface]
    bpy.ops.object.select_all(action="DESELECT")
    for piece in pieces:
        piece.select_set(True)
    bpy.context.view_layer.objects.active = pieces[0]
    if len(pieces) > 1:
        bpy.ops.object.join()

bpy.ops.export_scene.gltf(filepath=str(OUTPUT / "sample_cart.glb"), export_format="GLB", export_apply=True)
print("SAMPLE_CART_EXPORT", OUTPUT / "sample_cart.glb")

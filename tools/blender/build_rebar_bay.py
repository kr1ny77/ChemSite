"""Build an editable reinforcement and formwork bay for the left construction pad."""

from pathlib import Path

import bpy
from mathutils import Vector


ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / "assets/models/environment"
SOURCE = ROOT / "tools/blender/source"
OUTPUT.mkdir(parents=True, exist_ok=True)
SOURCE.mkdir(parents=True, exist_ok=True)

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)


def material(name, color, roughness=0.72, metallic=0.0):
    result = bpy.data.materials.new(name)
    result.diffuse_color = (*color, 1.0)
    result.use_nodes = True
    shader = result.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = (*color, 1.0)
    shader.inputs["Roughness"].default_value = roughness
    shader.inputs["Metallic"].default_value = metallic
    return result


concrete = material("warm unfinished concrete", (0.61, 0.63, 0.58), 0.9)
steel = material("dark reinforcing steel", (0.18, 0.23, 0.22), 0.5, 0.55)
rust = material("weathered steel end grain", (0.46, 0.24, 0.14), 0.76, 0.22)
plywood = material("sealed formwork plywood", (0.61, 0.39, 0.19), 0.79)
amber = material("formwork safety marking", (0.93, 0.55, 0.13), 0.62)


def box(name, location, dimensions, surface, bevel=0.014):
    bpy.ops.mesh.primitive_cube_add(size=1, location=location)
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = dimensions
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(surface)
    if bevel:
        edge = obj.modifiers.new("cast edge", "BEVEL")
        edge.width = min(bevel, min(dimensions) * 0.28)
        edge.segments = 2
        obj.modifiers.new("weighted normals", "WEIGHTED_NORMAL")
    return obj


def rod(name, start, end, radius, surface, sides=10):
    a, b = Vector(start), Vector(end)
    midpoint = (a + b) / 2
    direction = b - a
    bpy.ops.mesh.primitive_cylinder_add(vertices=sides, radius=radius, depth=direction.length, location=midpoint)
    obj = bpy.context.object
    obj.name = name
    obj.rotation_euler = direction.to_track_quat("Z", "Y").to_euler()
    obj.data.materials.append(surface)
    return obj


box("cast footing pad", (0, 0, 0.14), (2.35, 1.26, 0.28), concrete, 0.055)
for center_x in (-0.53, 0.53):
    box("column starter block", (center_x, 0, 0.39), (0.76, 0.74, 0.24), concrete, 0.025)
    for x in (center_x - 0.27, center_x + 0.27):
        for y in (-0.27, 0.27):
            rod("vertical reinforcement", (x, y, 0.49), (x, y, 2.38), 0.032, steel)
            rod("rusted steel tip", (x, y, 2.36), (x, y, 2.41), 0.034, rust)
    for height in (0.58, 0.86, 1.14, 1.42, 1.70, 1.98, 2.26):
        left, right = center_x - 0.30, center_x + 0.30
        near, far = -0.30, 0.30
        rod("steel hoop front", (left, near, height), (right, near, height), 0.023, steel)
        rod("steel hoop back", (left, far, height), (right, far, height), 0.023, steel)
        rod("steel hoop left", (left, near, height), (left, far, height), 0.023, steel)
        rod("steel hoop right", (right, near, height), (right, far, height), 0.023, steel)

# Partial removable formwork stays behind the open cage from the gameplay camera.
box("rear form panel", (-0.53, 0.51, 0.99), (0.86, 0.09, 1.42), plywood, 0.024)
box("rear form stiffener", (-0.53, 0.575, 1.37), (0.77, 0.05, 0.08), rust, 0.009)
box("rear form amber tab", (-0.53, 0.58, 1.65), (0.26, 0.018, 0.08), amber, 0.006)
box("stored form panel", (0.66, -0.73, 0.14), (1.02, 0.53, 0.09), plywood, 0.018)
box("stored panel edge", (0.66, -0.74, 0.20), (0.95, 0.04, 0.025), rust, 0.005)

for obj in bpy.data.objects:
    if obj.type == "MESH":
        for modifier in list(obj.modifiers):
            bpy.context.view_layer.objects.active = obj
            bpy.ops.object.modifier_apply(modifier=modifier.name)

bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE / "rebar_bay.blend"))
for surface in (concrete, steel, rust, plywood, amber):
    pieces = [
        obj for obj in bpy.data.objects
        if obj.type == "MESH" and obj.data.materials and obj.data.materials[0] == surface
    ]
    bpy.ops.object.select_all(action="DESELECT")
    for piece in pieces:
        piece.select_set(True)
    bpy.context.view_layer.objects.active = pieces[0]
    if len(pieces) > 1:
        bpy.ops.object.join()

bpy.ops.export_scene.gltf(filepath=str(OUTPUT / "rebar_bay.glb"), export_format="GLB", export_apply=True)
print("REBAR_BAY_EXPORT", OUTPUT / "rebar_bay.glb")

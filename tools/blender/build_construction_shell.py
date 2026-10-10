"""Build the editable concrete shell for ChemSite's unfinished left work bay."""

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


def material(name, color, roughness=0.8, metallic=0.0):
    result = bpy.data.materials.new(name)
    result.diffuse_color = (*color, 1.0)
    result.use_nodes = True
    shader = result.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = (*color, 1.0)
    shader.inputs["Roughness"].default_value = roughness
    shader.inputs["Metallic"].default_value = metallic
    return result


concrete = material("shell warm cast concrete", (0.64, 0.68, 0.63), 0.9)
concrete_edge = material("shell concrete aggregate edge", (0.49, 0.55, 0.52), 0.95)
steel = material("shell dark painted steel", (0.13, 0.24, 0.27), 0.62, 0.0)
rebar = material("shell weathered reinforcement", (0.31, 0.27, 0.23), 0.72, 0.32)
timber = material("shell sealed formwork timber", (0.56, 0.36, 0.19), 0.83)
amber = material("shell safety amber", (0.92, 0.49, 0.12), 0.62, 0.0)


def box(name, location, dimensions, surface, bevel=0.025):
    bpy.ops.mesh.primitive_cube_add(size=1, location=location)
    item = bpy.context.object
    item.name = name
    item.dimensions = dimensions
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    item.data.materials.append(surface)
    if bevel:
        modifier = item.modifiers.new("formed edge", "BEVEL")
        modifier.width = min(bevel, min(dimensions) * 0.3)
        modifier.segments = 2
        item.modifiers.new("weighted normals", "WEIGHTED_NORMAL")
    return item


def rod(name, start, end, radius, surface, sides=12):
    start, end = Vector(start), Vector(end)
    distance = end - start
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=sides,
        radius=radius,
        depth=distance.length,
        location=(start + end) / 2,
    )
    item = bpy.context.object
    item.name = name
    item.rotation_euler = distance.to_track_quat("Z", "Y").to_euler()
    item.data.materials.append(surface)
    return item


# Four posts and the joined upper ring set a readable structural grid.
for x in (-2.42, 2.42):
    for y in (-1.42, 1.42):
        box("column footing", (x, y, 0.10), (0.73, 0.73, 0.20), concrete_edge, 0.048)
        box("cast concrete column", (x, y, 1.38), (0.49, 0.49, 2.57), concrete, 0.045)
        box("column head bearing", (x, y, 2.69), (0.60, 0.60, 0.18), concrete_edge, 0.024)
        for offset_x in (-0.115, 0.115):
            for offset_y in (-0.115, 0.115):
                rod("starter bar", (x + offset_x, y + offset_y, 2.78), (x + offset_x, y + offset_y, 3.23), 0.026, rebar)

for y in (-1.42, 1.42):
    box("longitudinal concrete beam", (0, y, 2.54), (5.22, 0.49, 0.44), concrete, 0.045)
for x in (-2.42, 2.42):
    box("transverse concrete beam", (x, 0, 2.54), (0.49, 3.18, 0.44), concrete, 0.045)

# The completed bay occupies one side; the exposed bay leaves the site legible.
box("cast upper slab rear bay", (-1.03, 0.63, 2.77), (2.80, 1.55, 0.18), concrete, 0.04)
box("slab fascia", (-1.03, 1.46, 2.70), (2.80, 0.10, 0.24), concrete_edge, 0.022)
box("left slab strip", (-2.20, -0.42, 2.77), (0.44, 1.35, 0.18), concrete, 0.025)

# Temporary timber formwork and bracing explain the still-open slab edge.
for x in (0.04, 0.62, 1.20, 1.78):
    box("front beam form board", (x, -1.73, 2.54), (0.52, 0.07, 0.48), timber, 0.013)
    box("form board cleat", (x, -1.79, 2.44), (0.065, 0.09, 0.36), steel, 0.009)
for x in (0.05, 1.96):
    rod("shoring post", (x, -1.76, 0.20), (x, -1.76, 2.29), 0.041, steel)
    box("shoring foot", (x, -1.76, 0.10), (0.29, 0.29, 0.11), steel, 0.014)
    rod("shoring brace", (x, -1.76, 0.95), (x + 0.42, -1.76, 1.73), 0.027, steel)

# A safety rail follows the cast slab edge and remains below the camera sightline.
for x in (-2.27, -1.08, 0.12):
    rod("safety rail post", (x, 1.19, 2.83), (x, 1.19, 3.62), 0.032, steel)
    box("rail post base", (x, 1.19, 2.86), (0.16, 0.17, 0.10), amber, 0.01)
for height in (3.14, 3.58):
    rod("slab edge rail", (-2.27, 1.19, height), (0.12, 1.19, height), 0.029, amber)
box("slab edge toe board", (-1.08, 1.19, 2.91), (2.40, 0.045, 0.13), timber, 0.008)

# Casting joints and construction identifiers add scale without visual noise.
for x in (-1.66, -0.80, 0.06):
    box("slab top casting joint", (x, 0.67, 2.872), (0.018, 1.30, 0.007), concrete_edge, 0.0)
box("bay identifier plate", (-2.43, -1.72, 1.95), (0.41, 0.035, 0.32), steel, 0.018)
for x in (-2.51, -2.40, -2.29):
    box("bay identifier stripe", (x, -1.744, 1.95), (0.055, 0.008, 0.16), amber, 0.005)

for item in bpy.data.objects:
    if item.type != "MESH":
        continue
    for modifier in list(item.modifiers):
        bpy.context.view_layer.objects.active = item
        bpy.ops.object.modifier_apply(modifier=modifier.name)

bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE / "construction_shell.blend"))

for surface in (concrete, concrete_edge, steel, rebar, timber, amber):
    pieces = [
        item for item in bpy.data.objects
        if item.type == "MESH" and item.data.materials and item.data.materials[0] == surface
    ]
    bpy.ops.object.select_all(action="DESELECT")
    for item in pieces:
        item.select_set(True)
    bpy.context.view_layer.objects.active = pieces[0]
    if len(pieces) > 1:
        bpy.ops.object.join()

bpy.ops.export_scene.gltf(
    filepath=str(OUTPUT / "construction_shell.glb"),
    export_format="GLB",
    export_apply=True,
)
print("CONSTRUCTION_SHELL_EXPORT", OUTPUT / "construction_shell.glb")

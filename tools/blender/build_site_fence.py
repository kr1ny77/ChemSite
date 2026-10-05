"""Author a repeatable 3.5 m temporary construction fence panel.

Contract: galvanized tubular frame, welded wire infill, weighted concrete
feet, visible safety marker; about 3.5 x 2.1 m, static GLB, four material
groups. Reference: temporary site panels with 3.5 x 2 m frames and concrete
feet, e.g. https://billigerbauzaun.de/products/bauzaun-100m-3-5x2-0m-konfigurierbar
"""

import math
from pathlib import Path

import bpy
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "assets/models/environment"
SOURCE = ROOT / "tools/blender/source"
OUT.mkdir(parents=True, exist_ok=True)
SOURCE.mkdir(parents=True, exist_ok=True)

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)


def surface(name, color, metallic=0.0, roughness=0.6):
    material = bpy.data.materials.new(name)
    material.diffuse_color = (*color, 1.0)
    material.use_nodes = True
    shader = material.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = (*color, 1.0)
    shader.inputs["Metallic"].default_value = metallic
    shader.inputs["Roughness"].default_value = roughness
    return material


steel = surface("Galvanized steel", (0.34, 0.45, 0.46), 0.65, 0.42)
mesh_steel = surface("Welded wire", (0.50, 0.57, 0.56), 0.48, 0.56)
concrete = surface("Precast concrete foot", (0.48, 0.49, 0.44), 0.0, 0.9)
yellow = surface("Reflective safety yellow", (0.94, 0.61, 0.10), 0.15, 0.43)
ink = surface("Placard dark teal", (0.035, 0.15, 0.18), 0.18, 0.6)


def bar(name, start, end, radius, material, vertices=12):
    point_a, point_b = Vector(start), Vector(end)
    direction = point_b - point_a
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius,
                                        depth=direction.length, location=(point_a + point_b) / 2)
    obj = bpy.context.object
    obj.name = name
    obj.rotation_euler = direction.to_track_quat("Z", "Y").to_euler()
    obj.data.materials.append(material)
    for polygon in obj.data.polygons:
        polygon.use_smooth = True
    return obj


def box(name, center, size, material, bevel=0.0):
    bpy.ops.mesh.primitive_cube_add(size=1, location=center)
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(material)
    if bevel:
        modifier = obj.modifiers.new("Manufactured corner radius", "BEVEL")
        modifier.width = bevel
        modifier.segments = 3
        bpy.context.view_layer.objects.active = obj
        bpy.ops.object.modifier_apply(modifier=modifier.name)
        obj.modifiers.new("Weighted normals", "WEIGHTED_NORMAL")
    return obj


# The panel spans x ±1.75. Its mesh is inset so every rod ends in the frame.
for x in (-1.69, 1.69):
    bar("Frame upright", (x, 0, 0.13), (x, 0, 2.10), 0.027, steel)
    box("Weighted removable foot", (x, 0, 0.09), (0.53, 0.75, 0.18), concrete, 0.025)
    box("Yellow foot keeper", (x, -0.26, 0.185), (0.32, 0.10, 0.035), yellow, 0.009)
for z in (0.24, 1.08, 2.06):
    bar("Frame rail", (-1.69, 0, z), (1.69, 0, z), 0.022, steel)
for index in range(17):
    x = -1.6 + index * 0.2
    bar("Welded vertical", (x, -0.002, 0.27), (x, -0.002, 2.02), 0.0055, mesh_steel, 8)
for index in range(10):
    z = 0.30 + index * 0.19
    bar("Welded horizontal", (-1.61, -0.002, z), (1.61, -0.002, z), 0.0055, mesh_steel, 8)

# A small inset sign and continuous yellow marker stay readable from the game camera.
box("Safety marker stripe", (0, -0.035, 1.10), (3.17, 0.026, 0.07), yellow, 0.008)
box("Site safety placard", (1.11, -0.049, 1.60), (0.56, 0.025, 0.38), ink, 0.008)
box("Placard signal", (1.11, -0.065, 1.63), (0.045, 0.012, 0.18), yellow, 0.004)
box("Placard signal dot", (1.11, -0.066, 1.47), (0.045, 0.012, 0.044), yellow, 0.004)

for material in (steel, mesh_steel, concrete, yellow, ink):
    members = [obj for obj in bpy.data.objects if obj.type == "MESH"
               and obj.data.materials and obj.data.materials[0] == material]
    bpy.ops.object.select_all(action="DESELECT")
    for obj in members:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = members[0]
    if len(members) > 1:
        bpy.ops.object.join()
    members[0].name = material.name

bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE / "site_fence.blend"))
bpy.ops.export_scene.gltf(filepath=str(OUT / "site_fence.glb"), export_format="GLB")
print("SITE_FENCE_EXPORT", OUT / "site_fence.glb")

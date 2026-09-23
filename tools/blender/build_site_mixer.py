"""Build a compact stylized construction mixer as an editable site prop."""

from math import cos, pi, sin
from pathlib import Path

import bpy


ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / "assets/models/environment"
SOURCE = ROOT / "tools/blender/source"
OUTPUT.mkdir(parents=True, exist_ok=True)
SOURCE.mkdir(parents=True, exist_ok=True)

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)


def material(name, color, roughness=0.55, metallic=0.0):
    result = bpy.data.materials.new(name)
    result.diffuse_color = (*color, 1.0)
    result.use_nodes = True
    shader = result.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = (*color, 1.0)
    shader.inputs["Roughness"].default_value = roughness
    shader.inputs["Metallic"].default_value = metallic
    return result


orange = material("mixer drum amber", (0.86, 0.38, 0.08), 0.45, 0.18)
yellow = material("safety rim amber", (0.99, 0.65, 0.13), 0.47, 0.16)
steel = material("painted steel chassis", (0.12, 0.27, 0.29), 0.48, 0.36)
metal = material("galvanized fittings", (0.43, 0.52, 0.50), 0.38, 0.58)
rubber = material("wheel rubber", (0.055, 0.075, 0.075), 0.84)
recess = material("dark drum interior", (0.095, 0.12, 0.11), 0.95)


def box(name, location, dimensions, surface, bevel=0.02):
    bpy.ops.mesh.primitive_cube_add(size=1, location=location)
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = dimensions
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(surface)
    if bevel:
        modifier = obj.modifiers.new("rolled edge", "BEVEL")
        modifier.width = min(bevel, min(dimensions) * 0.28)
        modifier.segments = 2
        obj.modifiers.new("weighted normals", "WEIGHTED_NORMAL")
    return obj


def cylinder(name, location, radius, depth, surface, sides=24, rotation=None):
    bpy.ops.mesh.primitive_cylinder_add(vertices=sides, radius=radius, depth=depth, location=location)
    obj = bpy.context.object
    obj.name = name
    if rotation is not None:
        obj.rotation_euler = rotation
    obj.data.materials.append(surface)
    return obj


# A triangular steel chassis, axle and motor housing keep the drum credible.
for x in (-0.56, 0.56):
    box("longitudinal chassis rail", (x, 0.0, 0.36), (0.10, 1.55, 0.12), steel)
    box("raised drum post", (x, -0.09, 0.81), (0.10, 0.12, 0.92), steel)
    cylinder("wheel tyre", (x * 1.33, 0.38, 0.30), 0.29, 0.15, rubber, rotation=(0, pi / 2, 0))
    cylinder("wheel hub", (x * 1.57, 0.38, 0.30), 0.105, 0.022, metal, rotation=(0, pi / 2, 0))
box("front cross member", (0, -0.68, 0.36), (1.20, 0.10, 0.12), steel)
box("rear cross member", (0, 0.69, 0.36), (1.20, 0.10, 0.12), steel)
box("front landing foot", (0, -0.72, 0.17), (0.24, 0.28, 0.33), steel)
box("motor enclosure", (0.58, 0.19, 1.02), (0.31, 0.48, 0.31), steel, 0.045)
box("motor warning stripe", (0.58, -0.062, 1.07), (0.23, 0.012, 0.05), yellow, 0.005)
cylinder("tilt axle", (0, -0.09, 1.24), 0.10, 1.26, metal, rotation=(0, pi / 2, 0))

# Ring profiles form a flared vessel around a dark inset mouth.
TILT = 0.35
PIVOT = (0.0, -0.12, 1.24)
RINGS = [(-0.48, 0.33), (-0.33, 0.51), (-0.05, 0.65), (0.20, 0.64), (0.53, 0.46)]
SEGMENTS = 32


def drum_point(radius, theta, height):
    x = radius * cos(theta)
    y = radius * sin(theta)
    z = height
    return (PIVOT[0] + x, PIVOT[1] + y * cos(TILT) - z * sin(TILT), PIVOT[2] + y * sin(TILT) + z * cos(TILT))


vertices = []
for height, radius in RINGS:
    for index in range(SEGMENTS):
        vertices.append(drum_point(radius, 2 * pi * index / SEGMENTS, height))
faces = []
for ring in range(len(RINGS) - 1):
    for index in range(SEGMENTS):
        next_index = (index + 1) % SEGMENTS
        faces.append((ring * SEGMENTS + index, ring * SEGMENTS + next_index,
                      (ring + 1) * SEGMENTS + next_index, (ring + 1) * SEGMENTS + index))
faces.append(tuple(reversed(range(SEGMENTS))))
mesh = bpy.data.meshes.new("flared drum mesh")
mesh.from_pydata(vertices, [], faces)
mesh.update()
drum = bpy.data.objects.new("tilted mixing drum", mesh)
bpy.context.collection.objects.link(drum)
drum.data.materials.append(orange)
for face in drum.data.polygons:
    face.use_smooth = True

inner_vertices = []
for height, radius in ((0.54, 0.42), (0.27, 0.34)):
    for index in range(SEGMENTS):
        inner_vertices.append(drum_point(radius, 2 * pi * index / SEGMENTS, height))
inner_faces = []
for index in range(SEGMENTS):
    next_index = (index + 1) % SEGMENTS
    inner_faces.append((index, next_index, SEGMENTS + next_index, SEGMENTS + index))
inner_mesh = bpy.data.meshes.new("dark inner drum wall")
inner_mesh.from_pydata(inner_vertices, [], inner_faces)
inner_mesh.update()
inner_wall = bpy.data.objects.new("recessed drum interior", inner_mesh)
bpy.context.collection.objects.link(inner_wall)
inner_wall.data.materials.append(recess)
mouth_center = drum_point(0, 0, 0.27)
cylinder("shadowed vessel floor", mouth_center, 0.34, 0.014, recess, sides=32, rotation=(TILT, 0, 0))
bpy.ops.mesh.primitive_torus_add(major_segments=32, minor_segments=8, location=drum_point(0, 0, 0.53), rotation=(TILT, 0, 0), major_radius=0.45, minor_radius=0.047)
bpy.context.object.name = "reinforced pouring lip"
bpy.context.object.data.materials.append(yellow)

# Opposed steel side supports and a steering wheel explain the tilt mechanism.
for x in (-0.69, 0.69):
    cylinder("drum pivot housing", (x, -0.10, 1.24), 0.16, 0.09, metal, rotation=(0, pi / 2, 0))
cylinder("tilt handwheel", (-0.82, -0.10, 1.24), 0.27, 0.06, steel, rotation=(0, pi / 2, 0))
cylinder("handwheel grip", (-0.90, -0.10, 1.49), 0.043, 0.12, rubber, rotation=(0, pi / 2, 0))
box("transport handle bar", (0, 0.81, 0.73), (0.78, 0.07, 0.07), metal, 0.012)
for x in (-0.36, 0.36):
    box("transport handle arm", (x, 0.72, 0.55), (0.06, 0.23, 0.37), steel, 0.012)

for obj in bpy.data.objects:
    if obj.type == "MESH":
        for modifier in list(obj.modifiers):
            bpy.context.view_layer.objects.active = obj
            bpy.ops.object.modifier_apply(modifier=modifier.name)

bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE / "site_mixer.blend"))
for surface in (orange, yellow, steel, metal, rubber, recess):
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

bpy.ops.export_scene.gltf(filepath=str(OUTPUT / "site_mixer.glb"), export_format="GLB", export_apply=True)
print("SITE_MIXER_EXPORT", OUTPUT / "site_mixer.glb")

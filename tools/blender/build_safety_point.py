"""Build an editable first-aid and eyewash landmark for the site."""

from pathlib import Path

import bpy


ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / "assets/models/environment"
SOURCE = ROOT / "tools/blender/source"
OUTPUT.mkdir(parents=True, exist_ok=True)
SOURCE.mkdir(parents=True, exist_ok=True)

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)


def material(name, color, roughness=0.65, metallic=0.0):
    result = bpy.data.materials.new(name)
    result.diffuse_color = (*color, 1.0)
    result.use_nodes = True
    shader = result.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = (*color, 1.0)
    shader.inputs["Roughness"].default_value = roughness
    shader.inputs["Metallic"].default_value = metallic
    return result


navy = material("powder-coated navy frame", (0.055, 0.18, 0.22), 0.5, 0.25)
amber = material("safety amber trim", (0.94, 0.54, 0.10), 0.52, 0.12)
green = material("first aid green", (0.08, 0.45, 0.31), 0.65)
cyan = material("eyewash cyan", (0.12, 0.54, 0.60), 0.52)
white = material("cream pictogram and panel", (0.89, 0.90, 0.78), 0.68)
dark = material("rubber and inset surface", (0.045, 0.075, 0.075), 0.8)


def box(name, location, dimensions, surface, bevel=0.015):
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


def cylinder(name, location, radius, depth, surface, sides=16):
    bpy.ops.mesh.primitive_cylinder_add(vertices=sides, radius=radius, depth=depth, location=location)
    obj = bpy.context.object
    obj.name = name
    obj.data.materials.append(surface)
    return obj


# Two braced posts make the sign a credible freestanding site fixture.
for x in (-0.76, 0.76):
    box("post ground shoe", (x, 0.0, 0.08), (0.42, 0.62, 0.16), dark, 0.035)
    box("steel upright", (x, 0.13, 1.05), (0.10, 0.11, 2.0), navy, 0.018)
    box("amber post cap", (x, 0.13, 2.07), (0.16, 0.17, 0.11), amber, 0.014)
box("lower cross brace", (0, 0.13, 0.38), (1.56, 0.08, 0.08), navy)
box("top cross brace", (0, 0.13, 1.99), (1.62, 0.08, 0.10), navy)

# The visible sign face points toward Blender -Y and Godot's camera side.
box("dark sign backer", (0, -0.015, 1.53), (1.72, 0.11, 0.93), navy, 0.045)
box("warm sign inset", (0, -0.078, 1.53), (1.58, 0.022, 0.79), white, 0.018)
box("first aid symbol panel", (-0.41, -0.094, 1.54), (0.73, 0.014, 0.68), green, 0.018)
box("eyewash symbol panel", (0.41, -0.094, 1.54), (0.73, 0.014, 0.68), cyan, 0.018)

# Broad pictograms survive the distant isometric gameplay camera.
box("first aid cross vertical", (-0.41, -0.106, 1.54), (0.105, 0.018, 0.38), white, 0.008)
box("first aid cross horizontal", (-0.41, -0.108, 1.54), (0.38, 0.018, 0.105), white, 0.008)
box("eyewash eye upper", (0.41, -0.107, 1.63), (0.39, 0.018, 0.06), white, 0.008)
box("eyewash eye lower", (0.41, -0.107, 1.49), (0.39, 0.018, 0.06), white, 0.008)
pupil = cylinder("eyewash pupil", (0.41, -0.115, 1.56), 0.075, 0.018, dark)
pupil.rotation_euler.x = 1.57079632679
for x in (0.28, 0.54):
    box("water droplet", (x, -0.11, 1.29), (0.042, 0.018, 0.10), white, 0.006)

# Mounted supply cases give the sign a functional silhouette from the side.
box("first aid case", (-0.42, -0.18, 0.76), (0.53, 0.31, 0.34), green, 0.035)
box("case latch", (-0.42, -0.35, 0.75), (0.09, 0.035, 0.055), white, 0.008)
box("eyewash cabinet", (0.42, -0.18, 0.76), (0.53, 0.31, 0.34), cyan, 0.035)
for x in (0.30, 0.54):
    cylinder("sealed eyewash bottle", (x, -0.36, 0.78), 0.065, 0.21, white)
    cylinder("bottle cap", (x, -0.36, 0.91), 0.073, 0.035, navy)

box("floor safety mat", (0, -0.28, 0.025), (1.85, 0.90, 0.05), dark, 0.02)
for x in (-0.83, -0.51, -0.19, 0.13, 0.45, 0.77):
    box("mat amber edge", (x, -0.70, 0.057), (0.16, 0.07, 0.012), amber, 0.003)

for obj in bpy.data.objects:
    if obj.type == "MESH":
        for modifier in list(obj.modifiers):
            bpy.context.view_layer.objects.active = obj
            bpy.ops.object.modifier_apply(modifier=modifier.name)

bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE / "safety_point.blend"))
for surface in (navy, amber, green, cyan, white, dark):
    pieces = [
        obj for obj in bpy.data.objects
        if obj.type == "MESH" and obj.data.materials and obj.data.materials[0] == surface
    ]
    bpy.ops.object.select_all(action="DESELECT")
    for piece in pieces:
        piece.select_set(True)
    bpy.context.view_layer.objects.active = pieces[0]
    bpy.ops.object.join()

bpy.ops.export_scene.gltf(filepath=str(OUTPUT / "safety_point.glb"), export_format="GLB", export_apply=True)
print("SAFETY_POINT_EXPORT", OUTPUT / "safety_point.glb")

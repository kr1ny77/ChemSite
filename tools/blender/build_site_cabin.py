"""Build the ChemSite site laboratory cabin as an editable Blender hero prop."""

from pathlib import Path

import bpy


ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / "assets/models/environment"
SOURCE = ROOT / "tools/blender/source"
OUTPUT.mkdir(parents=True, exist_ok=True)
SOURCE.mkdir(parents=True, exist_ok=True)

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)


def material(name, color, metallic=0.0, roughness=0.55):
    result = bpy.data.materials.new(name)
    result.diffuse_color = (*color, 1.0)
    result.use_nodes = True
    shader = result.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = (*color, 1.0)
    shader.inputs["Metallic"].default_value = metallic
    shader.inputs["Roughness"].default_value = roughness
    return result


cream = material("warm insulated panels", (0.68, 0.72, 0.68), roughness=0.78)
navy = material("powder coated navy steel", (0.045, 0.16, 0.2), metallic=0.38)
dark = material("graphite rubber and seals", (0.045, 0.07, 0.075), roughness=0.83)
amber = material("construction safety amber", (0.94, 0.53, 0.12), metallic=0.1)
glass = material("cyan laboratory glazing", (0.13, 0.5, 0.55), metallic=0.16, roughness=0.18)
white = material("signage warm white", (0.9, 0.88, 0.75), roughness=0.5)


def box(name, location, dimensions, surface, bevel=0.025):
    bpy.ops.mesh.primitive_cube_add(size=1, location=location)
    item = bpy.context.object
    item.name = name
    item.dimensions = dimensions
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    item.data.materials.append(surface)
    if bevel:
        edge = item.modifiers.new("manufactured edge", "BEVEL")
        edge.width = min(bevel, min(dimensions) * 0.3)
        edge.segments = 3
        item.modifiers.new("weighted surface normals", "WEIGHTED_NORMAL")
    return item


def cylinder(name, location, radius, depth, surface, sides=24):
    bpy.ops.mesh.primitive_cylinder_add(vertices=sides, radius=radius, depth=depth, location=location)
    item = bpy.context.object
    item.name = name
    item.data.materials.append(surface)
    edge = item.modifiers.new("rolled rim", "BEVEL")
    edge.width = 0.012
    edge.segments = 2
    item.modifiers.new("weighted surface normals", "WEIGHTED_NORMAL")
    return item


# The visible front faces Blender -Y, matching the existing station asset orientation.
box("raised steel chassis", (0, 0, 0.16), (3.85, 1.78, 0.26), navy, 0.08)
for x in (-1.43, 1.43):
    for y in (-0.64, 0.64):
        box("foundation skid", (x, y, 0.08), (0.55, 0.26, 0.16), dark, 0.03)
box("insulated cabin body", (0, 0, 1.22), (3.65, 1.57, 1.9), cream, 0.08)
box("roof cap", (0, 0, 2.23), (3.98, 1.9, 0.2), navy, 0.08)
box("amber roof fascia", (0, -0.98, 2.17), (3.75, 0.055, 0.095), amber, 0.012)

# Vertical steel reveals keep the broad wall from reading as one flat box.
for x in (-1.73, -1.08, 0.05, 1.73):
    box("front panel seam", (x, -0.82, 1.24), (0.035, 0.045, 1.75), navy, 0.005)
for x in (-1.72, 1.72):
    box("corner extrusion", (x, 0, 1.26), (0.08, 1.69, 1.91), navy, 0.016)

# Door, handle, step and window are distinct silhouettes from gameplay height.
box("entry frame", (-0.83, -0.84, 1.09), (0.92, 0.10, 1.73), navy, 0.028)
box("entry leaf", (-0.83, -0.905, 1.08), (0.76, 0.035, 1.56), dark, 0.019)
box("door inspection glass", (-0.83, -0.929, 1.56), (0.45, 0.018, 0.38), glass, 0.012)
cylinder("door latch", (-0.53, -0.95, 1.02), 0.045, 0.035, amber)
box("steel entry step", (-0.83, -1.02, 0.24), (1.18, 0.45, 0.2), navy, 0.025)
box("window frame", (0.86, -0.84, 1.4), (1.45, 0.13, 0.83), navy, 0.04)
box("window glazing", (0.86, -0.918, 1.4), (1.24, 0.02, 0.64), glass, 0.008)
box("window mullion", (0.86, -0.94, 1.4), (0.04, 0.025, 0.72), white, 0.005)
box("window sill", (0.86, -0.95, 0.98), (1.57, 0.28, 0.08), navy, 0.015)

# Instrument silhouettes behind the glazing make it read as an active chemistry cabin.
for x, height in ((0.45, 0.32), (0.76, 0.47), (1.12, 0.27)):
    cylinder("sealed analyzer", (x, -0.65, 1.14 + height / 2), 0.09, height, amber if x == 0.76 else white)
    cylinder("analyzer cap", (x, -0.65, 1.16 + height), 0.105, 0.04, dark)

# Side ventilation and a small roof extractor add a functional construction-site story.
for index in range(5):
    box("side ventilation slat", (1.85, -0.47 + index * 0.21, 1.48), (0.035, 0.12, 0.055), dark, 0.005)
box("roof air cabinet", (0.92, 0.33, 2.48), (0.78, 0.65, 0.36), cream, 0.045)
for index in range(4):
    box("air cabinet louver", (0.92, -0.01 + index * 0.13, 2.49), (0.65, 0.025, 0.045), navy, 0.005)
cylinder("amber work beacon", (-1.45, -0.55, 2.43), 0.11, 0.30, amber)
cylinder("beacon pedestal", (-1.45, -0.55, 2.29), 0.16, 0.06, dark)

# Raised symbol on the front: a slim flask made from primitive forms at sign scale.
box("sign plate", (0.82, -0.847, 2.04), (0.95, 0.06, 0.24), navy, 0.015)
box("flask neck symbol", (0.82, -0.891, 2.09), (0.055, 0.018, 0.11), white, 0.005)
box("flask body symbol", (0.82, -0.891, 2.005), (0.20, 0.018, 0.075), glass, 0.008)
for index in range(3):
    box("sign legend bar", (0.39 + index * 0.19, -0.891, 2.02), (0.12, 0.018, 0.025), amber, 0.005)

for obj in bpy.data.objects:
    if obj.type == "MESH":
        for modifier in list(obj.modifiers):
            bpy.context.view_layer.objects.active = obj
            bpy.ops.object.modifier_apply(modifier=modifier.name)

bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE / "site_cabin.blend"))
bpy.ops.export_scene.gltf(filepath=str(OUTPUT / "site_cabin.glb"), export_format="GLB", export_apply=True)
print("SITE_CABIN_EXPORT", OUTPUT / "site_cabin.glb")

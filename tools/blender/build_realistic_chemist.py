"""Build a ChemSite worker candidate with MPFB 2.0.17 and CC0 system assets.

Run with Blender 5.2 after installing the MPFB extension and the selected
MakeHuman system assets documented in character_reference_notes.md.
"""

import bpy
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "artifacts" / "character-candidate"
OUT.mkdir(parents=True, exist_ok=True)

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
bpy.ops.preferences.addon_enable(module="bl_ext.user_default.mpfb")

from bl_ext.user_default.mpfb.services.humanservice import HumanService
from bl_ext.user_default.mpfb.services.assetservice import AssetService
from bl_ext.user_default.mpfb.services.exportservice import ExportService
from bl_ext.user_default.mpfb.services.objectservice import ObjectService
from bl_ext.user_default.mpfb.entities.objectproperties import HumanObjectProperties
from bl_ext.user_default.mpfb.services.targetservice import TargetService


def asset(filename, directory):
    result = AssetService.find_asset_absolute_path(filename, asset_subdir=directory)
    if not result:
        raise FileNotFoundError(f"MPFB asset missing: {directory}/{filename}")
    return result


def material(name, color, roughness=0.55, metallic=0.0):
    result = bpy.data.materials.new(name)
    result.diffuse_color = (*color, 1.0)
    result.use_nodes = True
    bsdf = result.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Metallic"].default_value = metallic
    return result


def weighted_mesh(name, vertices, faces, surface, bone="spine_03"):
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(surface)
    for face in obj.data.polygons:
        face.use_smooth = True
    group = obj.vertex_groups.new(name=bone)
    group.add(list(range(len(vertices))), 1.0, "REPLACE")
    obj.parent = export_rig
    deform = obj.modifiers.new("Armature", "ARMATURE")
    deform.object = export_rig
    return obj


human = HumanService.create_human()
HumanObjectProperties.set_value("gender", 1.0, entity_reference=human)
TargetService.reapply_macro_details(human)
HumanService.set_character_skin(asset("young_caucasian_male.mhmat", "skins"), human, skin_type="GAMEENGINE")
HumanService.add_builtin_rig(human, "game_engine")
for directory, filename, category in [
    ("eyes", "low-poly.mhclo", "Eyes"),
    ("eyebrows", "eyebrow001.mhclo", "Eyebrows"),
    ("clothes", "male_worksuit01.mhclo", "Clothes"),
    ("clothes", "shoes06.mhclo", "Clothes"),
]:
    HumanService.add_mhclo_asset(asset(filename, directory), human, asset_type=category, material_type="GAMEENGINE")

export_rig = ExportService.create_character_copy(human, name_suffix="_export")
export_body = ObjectService.find_object_of_type_amongst_nearest_relatives(export_rig, "Basemesh")
ExportService.bake_modifiers_remove_helpers(
    export_body, bake_masks=True, bake_subdiv=False, remove_helpers=True, also_proxy=True
)

helmet_yellow = material("Hardhat polymer", (0.92, 0.60, 0.10), 0.38)
helmet_dark = material("Hardhat gasket", (0.08, 0.11, 0.12), 0.68)

# Curved hardhat crown with a rolled perimeter and tapered, front-projecting brim.
ring_profile = [(1.618, 0.135), (1.625, 0.151), (1.652, 0.155),
                (1.690, 0.143), (1.728, 0.113), (1.751, 0.065), (1.757, 0.008)]
segments = 32
verts = []
for z, radius in ring_profile:
    for index in range(segments):
        theta = 2.0 * math.pi * index / segments
        verts.append((radius * math.cos(theta), -0.048 + radius * math.sin(theta), z))
faces = []
for ring in range(len(ring_profile) - 1):
    for index in range(segments):
        nxt = (index + 1) % segments
        faces.append((ring * segments + index, ring * segments + nxt,
                      (ring + 1) * segments + nxt, (ring + 1) * segments + index))
weighted_mesh("Hardhat crown", verts, faces, helmet_yellow, "head")

brim_verts = []
for radius_x, radius_y, offset_y, z in [(0.151, 0.152, -0.048, 1.625),
                                        (0.177, 0.195, -0.064, 1.620),
                                        (0.175, 0.194, -0.064, 1.612)]:
    for index in range(segments):
        theta = 2.0 * math.pi * index / segments
        brim_verts.append((radius_x * math.cos(theta), offset_y + radius_y * math.sin(theta), z))
brim_faces = []
for ring in range(2):
    for index in range(segments):
        nxt = (index + 1) % segments
        brim_faces.append((ring * segments + index, ring * segments + nxt,
                           (ring + 1) * segments + nxt, (ring + 1) * segments + index))
weighted_mesh("Hardhat brim", brim_verts, brim_faces, helmet_yellow, "head")

# A slim fit stripe on the cap remains visible from the isometric game camera.
stripe = [(0.0, -0.18, 1.66), (0.0, -0.143, 1.73),
          (0.012, -0.143, 1.73), (0.012, -0.18, 1.66)]
weighted_mesh("Hardhat raised ridge", stripe, [(0, 1, 2, 3)], helmet_dark, "head")

bpy.ops.object.select_all(action="DESELECT")
export_rig.select_set(True)
for child in ObjectService.get_list_of_children(export_rig):
    child.select_set(True)
bpy.context.view_layer.objects.active = export_rig
bpy.ops.file.pack_all()
bpy.ops.wm.save_as_mainfile(filepath=str(OUT / "chemist_candidate.blend"))
bpy.ops.export_scene.gltf(
    filepath=str(OUT / "chemist_candidate.glb"),
    export_format="GLB", use_selection=True, export_animations=False,
)
print("CHEMSITE_CHARACTER_CANDIDATE", OUT / "chemist_candidate.glb")

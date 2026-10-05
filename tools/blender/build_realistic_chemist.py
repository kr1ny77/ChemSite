"""Build a ChemSite worker candidate with MPFB 2.0.17 and CC0 system assets.

Run with Blender 5.2 after installing the MPFB extension and the selected
MakeHuman system assets documented in character_reference_notes.md.
"""

import bpy
import math
import shutil
import sys
from mathutils import Quaternion, Vector
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(Path(__file__).resolve().parent))
from fit_garment_detail import garment_detail
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

# The stock worksuit bitmap has a military camouflage pattern. Assign plain
# workwear fabrics by garment region while retaining the fitted clothing mesh.
suit = next(obj for obj in ObjectService.get_list_of_children(export_rig)
            if "male_worksuit01" in obj.name)
denim = material("Construction workwear navy", (0.026, 0.075, 0.13), 0.86)
suit.data.materials.clear()
suit.data.materials.append(denim)
for polygon in suit.data.polygons:
    polygon.material_index = 0

# Fitted industrial coverall detail: circumferential calf/waist tape and
# shoulder runs copied from the cloth surface with interpolated skin weights.
# Reference observations and the local repair contract are in character_reference_notes.md.
tape_border = material("Safety tape yellow edging", (0.76, 0.65, 0.075), 0.64)
tape = material("Silver reflective cloth", (0.62, 0.68, 0.69), 0.38, 0.3)
stitch = material("Tailoring seam", (0.012, 0.026, 0.035), 0.88)
for label, height in (("Calf", 0.43), ("Waist", 1.055)):
    garment_detail(suit, label + " tape edging", [(2, height - 0.033, height + 0.033)], tape_border, 0.0015)
    garment_detail(suit, label + " reflective tape", [(2, height - 0.020, height + 0.020)], tape, 0.0024)
for side in (-1, 1):
    center = side * 0.105
    for facing in (-1, 1):
        label = ("Left" if side < 0 else "Right") + (" front" if facing < 0 else " back")
        garment_detail(suit, label + " shoulder edging", [(0, center - 0.030, center + 0.030), (2, 1.085, 1.44)], tape_border, 0.0015, facing)
        garment_detail(suit, label + " shoulder reflector", [(0, center - 0.018, center + 0.018), (2, 1.085, 1.44)], tape, 0.0024, facing)
garment_detail(suit, "Concealed front fastening", [(0, -0.005, 0.005), (2, 1.10, 1.40)], stitch, 0.0017, -1)
for side in (-1, 1):
    center = side * 0.047
    garment_detail(suit, ("Left" if side < 0 else "Right") + " pocket flap seam", [(0, center - 0.024, center + 0.024), (2, 1.295, 1.299)], stitch, 0.002, -1)

# Batch the fitted layers by material; shared vertex-group names retain weights.
for detail_material in (tape_border, tape, stitch):
    members = [obj for obj in bpy.data.objects if obj.type == "MESH"
               and obj.data.materials and obj.data.materials[0] == detail_material]
    bpy.ops.object.select_all(action="DESELECT")
    for obj in members:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = members[0]
    bpy.ops.object.join()
    members[0].name = detail_material.name

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


def key_pose(frame, turns):
    """Key anatomical rotations about stable world axes in the bind pose."""
    missing = set(turns) - set(export_rig.pose.bones.keys())
    if missing:
        raise KeyError(f"Missing game-engine bones: {missing}")
    for pose_bone in export_rig.pose.bones:
        name = pose_bone.name
        pitch, yaw, roll = turns.get(name, (0.0, 0.0, 0.0))
        # The source bind pose spreads the upper arms by about 41 degrees.
        # Relax them alongside the torso for idle, locomotion and station use.
        # Explicit celebration abduction keeps its authored raised-arm pose.
        if name in ("upperarm_l", "upperarm_r") and roll == 0.0:
            roll = 0.52 if name.endswith("_l") else -0.52
        rest = pose_bone.bone.matrix_local.to_quaternion()
        rotation = (Quaternion(Vector((0, 0, 1)), yaw)
                    @ Quaternion(Vector((0, 1, 0)), roll)
                    @ Quaternion(Vector((1, 0, 0)), pitch))
        pose_bone.rotation_mode = "QUATERNION"
        pose_bone.rotation_quaternion = rest.inverted() @ rotation @ rest
        pose_bone.keyframe_insert(data_path="rotation_quaternion", frame=frame, group=name)


def action(name, frames, pelvis_drops=None):
    if export_rig.animation_data is None:
        export_rig.animation_data_create()
    clip = bpy.data.actions.new(name)
    export_rig.animation_data.action = clip
    for frame, turns in frames:
        key_pose(frame, turns)
        pelvis = export_rig.pose.bones["pelvis"]
        drop = (pelvis_drops or {}).get(frame, 0.0)
        pelvis.location = pelvis.bone.matrix_local.to_quaternion().inverted() @ Vector((0, 0, -drop))
        pelvis.keyframe_insert(data_path="location", frame=frame, group="pelvis")
    clip.use_fake_user = True
    export_rig.animation_data.action = None
    track = export_rig.animation_data.nla_tracks.new()
    track.name = name
    track.strips.new(name, frames[0][0], clip)
    track.mute = True


def walk_pose(phase, running=False):
    stride = 0.53 if running else 0.36
    arm_swing = 0.34 if running else 0.25
    left = math.sin(phase)
    right = -left
    left_knee = max(0.0, -left) * (0.75 if running else 0.55)
    right_knee = max(0.0, -right) * (0.75 if running else 0.55)
    return {
        "pelvis": (0.025 * math.sin(phase * 2), 0.0, 0.024 * math.sin(phase)),
        "spine_03": (-0.07 if running else -0.025, 0.0, -0.022 * math.sin(phase)),
        "thigh_l": (-stride * left, 0.0, 0.0),
        "thigh_r": (-stride * right, 0.0, 0.0),
        "calf_l": (left_knee, 0.0, 0.0),
        "calf_r": (right_knee, 0.0, 0.0),
        "foot_l": (stride * left - left_knee * 0.8, 0.0, 0.0),
        "foot_r": (stride * right - right_knee * 0.8, 0.0, 0.0),
        "upperarm_l": (arm_swing * left, 0.0, 0.0),
        "upperarm_r": (arm_swing * right, 0.0, 0.0),
        "lowerarm_l": (-0.18 if running else -0.06, 0.0, 0.0),
        "lowerarm_r": (-0.18 if running else -0.06, 0.0, 0.0),
    }


def ground_walk(clip_name):
    """Bake a supporting sole onto the bind sole plane through the full cycle."""
    shoes = next(obj for obj in ObjectService.get_list_of_children(export_rig)
                 if "shoes06" in obj.name)
    clip = bpy.data.actions[clip_name]
    export_rig.animation_data.action = clip
    pelvis = export_rig.pose.bones["pelvis"]
    inverse_rest = pelvis.bone.matrix_local.to_quaternion().inverted()
    # The retained MakeHuman shoe sole is below the skeleton's asset origin.
    # Player's model offset accounts for this plane and its capsule's lower tip.
    target_sole = -0.017899
    samples = []
    first, last = (int(value) for value in clip.frame_range)
    for frame in range(first, last + 1):
        bpy.context.scene.frame_set(frame)
        evaluated = shoes.evaluated_get(bpy.context.evaluated_depsgraph_get())
        mesh = evaluated.to_mesh()
        minimum = min((evaluated.matrix_world @ v.co).z for v in mesh.vertices)
        evaluated.to_mesh_clear()
        correction = inverse_rest @ Vector((0, 0, target_sole - minimum))
        samples.append((frame, pelvis.location.copy() + correction))
    for frame, location in samples:
        pelvis.location = location
        pelvis.keyframe_insert(data_path="location", frame=frame, group="pelvis")
    export_rig.animation_data.action = None


action("Idle", [(1, {"spine_03": (0, 0, 0)}),
                (20, {"spine_03": (-0.012, 0, 0)}),
                (40, {"spine_03": (0, 0, 0)})])
for clip_name, half_cycle in [("Walk", 13), ("Run", 10)]:
    action(clip_name, [(1, walk_pose(0, clip_name == "Run")),
                       (1 + half_cycle // 2, walk_pose(math.pi / 2, clip_name == "Run")),
                       (1 + half_cycle, walk_pose(math.pi, clip_name == "Run")),
                       (1 + half_cycle + half_cycle // 2,
                        walk_pose(3 * math.pi / 2, clip_name == "Run")),
                       (1 + 2 * half_cycle, walk_pose(2 * math.pi, clip_name == "Run"))],
           {1 + half_cycle // 2: 0.035,
            1 + half_cycle + half_cycle // 2: 0.035} if clip_name == "Walk" else {})
ground_walk("Walk")
action("Turn", [(1, {"pelvis": (0, -0.15, 0)}),
                (9, {"pelvis": (0, 0.15, 0), "head": (0, -0.16, 0)}),
                (17, {"pelvis": (0, 0, 0), "head": (0, 0, 0)})])
action("Interact", [(1, {"upperarm_r": (0, 0, 0)}),
                    (10, {"upperarm_r": (-0.6, 0, 0), "lowerarm_r": (-0.45, 0, 0)}),
                    (20, {"upperarm_r": (0, 0, 0), "lowerarm_r": (0, 0, 0)})])
action("PickUp", [(1, {"pelvis": (0, 0, 0)}),
                  (12, {"pelvis": (0.42, 0, 0), "thigh_l": (-0.27, 0, 0),
                        "thigh_r": (-0.27, 0, 0), "upperarm_l": (-0.65, 0, 0),
                        "upperarm_r": (-0.65, 0, 0)}),
                  (26, {"pelvis": (0, 0, 0), "thigh_l": (0, 0, 0),
                        "thigh_r": (0, 0, 0), "upperarm_l": (0, 0, 0),
                        "upperarm_r": (0, 0, 0)})])
action("UseStation", [(1, {"upperarm_r": (-0.45, 0, 0)}),
                      (10, {"upperarm_r": (-0.75, 0, 0), "lowerarm_r": (-0.35, 0, 0)}),
                      (20, {"upperarm_r": (-0.45, 0, 0), "lowerarm_r": (0, 0, 0)})])
action("Celebrate", [(1, {"upperarm_l": (0, 0, 0), "upperarm_r": (0, 0, 0)}),
                     (12, {"upperarm_l": (-0.7, 0, -0.8),
                           "upperarm_r": (-0.7, 0, 0.8), "spine_03": (-0.08, 0, 0)}),
                     (30, {"upperarm_l": (-0.55, 0, -0.7),
                           "upperarm_r": (-0.55, 0, 0.7), "spine_03": (0, 0, 0)})])
action("Failure", [(1, {"head": (0, 0, 0)}),
                   (14, {"head": (0.18, 0, 0), "spine_03": (0.12, 0, 0),
                         "upperarm_l": (0.18, 0, 0), "upperarm_r": (0.18, 0, 0)}),
                   (28, {"head": (0, 0, 0), "spine_03": (0, 0, 0),
                         "upperarm_l": (0, 0, 0), "upperarm_r": (0, 0, 0)})])

bpy.ops.object.select_all(action="DESELECT")
export_rig.select_set(True)
for child in ObjectService.get_list_of_children(export_rig):
    child.select_set(True)
bpy.context.view_layer.objects.active = export_rig
bpy.ops.file.pack_all()
source = ROOT / "tools" / "blender" / "source"
source.mkdir(parents=True, exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=str(source / "realistic_chemist.blend"))
bpy.ops.export_scene.gltf(
    filepath=str(OUT / "chemist_candidate.glb"),
    export_format="GLB", use_selection=True, export_animation_mode="NLA_TRACKS",
)
shutil.copyfile(OUT / "chemist_candidate.glb", ROOT / "assets/models/character/chemist.glb")
print("CHEMSITE_CHARACTER_CANDIDATE", OUT / "chemist_candidate.glb")

import bpy, math
from mathutils import Vector
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'assets/models/character'
OUT.mkdir(parents=True, exist_ok=True)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)

def mat(name, color, roughness=.6, metallic=0):
    m=bpy.data.materials.new(name)
    m.diffuse_color=(*color,1)
    m.use_nodes=True
    bs=m.node_tree.nodes.get('Principled BSDF')
    bs.inputs['Base Color'].default_value=(*color,1)
    bs.inputs['Roughness'].default_value=roughness
    bs.inputs['Metallic'].default_value=metallic
    return m

navy=mat('Workwear · navy',(.065,.17,.22))
orange=mat('Safety vest · ochre',(.94,.39,.075))
yellow=mat('Helmet · warm yellow',(1,.69,.11),.32)
reflect=mat('Reflective tape · warm white',(.9,.92,.79),.45)
skin=mat('Skin · warm',(.67,.42,.29),.72)
boots=mat('Boots · graphite',(.075,.09,.10),.85)
glove=mat('Gloves · teal',(.025,.28,.33),.65)
cyan=mat('Chemistry accent',(.08,.63,.7),.32)
black=mat('Face and trim',(.03,.045,.05),.43)
white=mat('Eye white',(.96,.94,.84),.3)

def uv(name,loc,scale,material,segments=24):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segments,ring_count=12,location=loc)
    o=bpy.context.object;o.name=name;o.scale=scale;o.data.materials.append(material)
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    for p in o.data.polygons:p.use_smooth=True
    return o

def box(name,loc,scale,material,bevel=.06):
    bpy.ops.mesh.primitive_cube_add(size=1,location=loc)
    o=bpy.context.object;o.name=name;o.dimensions=scale
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    o.data.materials.append(material)
    b=o.modifiers.new('Soft manufactured edges','BEVEL');b.width=bevel;b.segments=3
    w=o.modifiers.new('Weighted normals','WEIGHTED_NORMAL');w.keep_sharp=True
    return o

def cyl(name,loc,radius,depth,material,vertices=32):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices,radius=radius,depth=depth,location=loc)
    o=bpy.context.object;o.name=name;o.data.materials.append(material)
    b=o.modifiers.new('Rolled edge','BEVEL');b.width=.025;b.segments=3
    o.modifiers.new('Weighted normals','WEIGHTED_NORMAL')
    return o

# Human-scaled field technician: fitted workwear, smaller head and equipment.
uv('Pelvis', (0,0,.89),(.245,.175,.20),navy)
for side in (-1,1):
    x=side*.145
    uv(f'Trouser {side}',(x,0,.50),(.115,.125,.34),navy)
    uv(f'Boot {side}',(x,-.075,.14),(.14,.185,.135),boots)
    box(f'Boot sole {side}',(x,-.085,.052),(.265,.39,.055),black,.017)
    box(f'Boot toe {side}',(x,-.215,.12),(.25,.12,.08),boots,.028)
uv('Torso', (0,0,1.28),(.305,.205,.39),orange)
box('Vest front seam',(0,-.205,1.26),(.022,.022,.55),navy,.006)
box('Work belt',(0,-.18,.98),(.47,.05,.055),boots,.014)
for side in (-1,1):
    x=side*.19
    box(f'Reflective shoulder {side}',(x,-.177,1.47),(.06,.025,.20),reflect,.009)
    box(f'Reflective hem {side}',(x,-.188,1.08),(.12,.025,.04),reflect,.008)
    box(f'Vest pocket {side}',(x,-.205,1.19),(.105,.025,.115),orange,.012)
    uv(f'Sleeve {side}',(side*.34,0,1.45),(.12,.135,.19),navy)
    uv(f'Arm {side}',(side*.405,0,1.13),(.095,.105,.27),navy)
    uv(f'Glove {side}',(side*.42,-.015,.89),(.095,.105,.115),glove)
    box(f'Glove cuff {side}',(side*.42,0,.97),(.17,.18,.042),black,.012)
uv('Neck',(0,-.01,1.68),(.105,.10,.105),skin)
uv('Head',(0,-.02,1.83),(.205,.18,.235),skin,32)
uv('Nose',(0,-.207,1.80),(.052,.058,.055),skin)
for side in (-1,1):
    uv(f'Ear {side}',(side*.204,-.015,1.81),(.046,.042,.075),skin)
    uv(f'Eye white {side}',(side*.082,-.177,1.86),(.042,.018,.032),white)
    uv(f'Pupil {side}',(side*.082,-.193,1.86),(.021,.012,.023),black)
    box(f'Eyebrow {side}',(side*.082,-.181,1.91),(.073,.012,.013),black,.004)
uv('Smile',(0,-.184,1.71),(.065,.013,.014),black)
uv('Helmet crown',(0,0,2.02),(.248,.235,.115),yellow,32)
cyl('Helmet rim',(0,-.004,1.986),.258,.038,yellow)
uv('Helmet brim',(0,-.16,1.975),(.245,.15,.019),yellow)
box('Helmet ridge',(0,-.02,2.128),(.04,.33,.025),yellow,.006)
box('Helmet cyan decal',(0,-.256,1.997),(.10,.01,.035),cyan,.002)
box('Chemistry pack',(0,.20,1.29),(.32,.12,.38),cyan,.05)
box('Pack lid',(0,.26,1.49),(.31,.11,.06),black,.014)
box('Vest badge',(.15,-.210,1.35),(.07,.018,.09),cyan,.008)
box('Badge symbol',(.15,-.227,1.35),(.018,.012,.055),reflect,.004)

for obj in bpy.data.objects:
    if obj.type=='MESH':
        for mod in list(obj.modifiers):
            bpy.context.view_layer.objects.active=obj
            bpy.ops.object.modifier_apply(modifier=mod.name)

# A compact skeleton drives rigid-weighted stylized parts. This is the first
# animation pass; the mesh and motion remain editable in the saved .blend.
mesh_parts=[o for o in bpy.data.objects if o.type=='MESH']
bpy.ops.object.armature_add(enter_editmode=True,location=(0,0,0))
rig=bpy.context.object;rig.name='ChemistRig'
arm=rig.data;arm.name='ChemistSkeleton'
arm.edit_bones.remove(arm.edit_bones[0])
def bone(name,head,tail,parent=None):
 b=arm.edit_bones.new(name);b.head=head;b.tail=tail
 if parent:b.parent=arm.edit_bones[parent]
 return b
bone('Root',(0,0,.05),(0,0,.93))
bone('Torso',(0,0,.93),(0,0,1.69),'Root')
bone('Head',(0,0,1.69),(0,0,2.04),'Torso')
bone('Arm_L',(-.31,0,1.55),(-.43,0,.88),'Torso')
bone('Arm_R',(.31,0,1.55),(.43,0,.88),'Torso')
bone('Leg_L',(-.145,0,.91),(-.145,0,.16),'Root')
bone('Leg_R',(.145,0,.91),(.145,0,.16),'Root')
bpy.ops.object.mode_set(mode='OBJECT')

def group_for(name):
 if name.startswith(('Helmet','Head','Eye','Pupil','Nose','Ear','Smile','Eyebrow')):return 'Head'
 if name.startswith(('Arm','Sleeve','Glove')):return 'Arm_L' if name.endswith('-1') else 'Arm_R'
 if name.startswith(('Trouser','Boot')):return 'Leg_L' if name.endswith('-1') else 'Leg_R'
 if name.startswith('Pelvis'):return 'Root'
 return 'Torso'

for o in mesh_parts:
 group=o.vertex_groups.new(name=group_for(o.name))
 group.add(list(range(len(o.data.vertices))),1.0,'REPLACE')
 o.parent=rig
 deform=o.modifiers.new('Skeletal deformation','ARMATURE')
 deform.object=rig

poses={
 'Idle':[(1,0,0,0,0),(20,.015,0,0,0),(40,0,0,0,0)],
 'Walk':[(1,0,.34,-.34,.3),(7,0,-.34,.34,-.3),(13,0,.34,-.34,.3)],
 'Run':[(1,0,.55,-.55,.5),(6,0,-.55,.55,-.5),(11,0,.55,-.55,.5)],
 'Turn':[(1,-.1,0,0,0),(9,.12,0,0,0),(17,0,0,0,0)],
 'Interact':[(1,0,0,0,0),(9,0,0,0,-.8),(20,0,0,0,0)],
 'PickUp':[(1,0,0,0,0),(11,.48,.15,.15,-.35),(25,0,0,0,0)],
 'UseStation':[(1,0,0,0,-.65),(10,0,0,0,-1.05),(20,0,0,0,-.65)],
 'Celebrate':[(1,0,0,0,0),(12,0,0,0,-1.6),(30,0,0,0,-1.3)],
 'Failure':[(1,0,0,0,0),(13,.2,0,0,.2),(28,0,0,0,0)],
}
rig.animation_data_create()
for name, keys in poses.items():
 action=bpy.data.actions.new(name)
 rig.animation_data.action=action
 for frame,torso,leg_l,leg_r,arm_r in keys:
  values={'Torso':(torso,0,0),'Leg_L':(leg_l,0,0),'Leg_R':(leg_r,0,0),
          'Arm_L':(-arm_r if name in ('Walk','Run','Celebrate') else 0,0,0),
          'Arm_R':(arm_r,0,0),'Head':(0,0,0)}
  if name == 'Celebrate' and frame > 1:
   # Local Z lifts the rigid shoulder assemblies out into a readable V.
   values['Arm_L'] = (0,0,2.2)
   values['Arm_R'] = (0,0,-2.2)
  for part,angles in values.items():
   pb=rig.pose.bones[part];pb.rotation_mode='XYZ';pb.rotation_euler=angles
   pb.keyframe_insert(data_path='rotation_euler',frame=frame,group=part)
 action.use_fake_user=True
 rig.animation_data.action=None
 track=rig.animation_data.nla_tracks.new();track.name=name
 track.strips.new(name,int(keys[0][0]),action)
 track.mute=True

source=ROOT/'tools/blender/source';source.mkdir(parents=True,exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=str(source/'chemist.blend'))
bpy.ops.export_scene.gltf(filepath=str(OUT/'chemist.glb'),export_format='GLB',use_selection=False,export_apply=True,export_animation_mode='NLA_TRACKS')
print('CHEMIST_EXPORT', OUT/'chemist.glb')

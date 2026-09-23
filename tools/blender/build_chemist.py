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

# The original browser character is the silhouette reference: helmet widest,
# short torso, large gloves/boots, reflective vest, clear face from elevated view.
uv('Pelvis', (0,0,.81),(.29,.21,.23),navy)
for side in (-1,1):
    x=side*.16
    uv(f'Trouser {side}',(x,0,.48),(.14,.145,.31),navy)
    box(f'Boot {side}',(x,-.095,.16),(.30,.39,.24),boots,.07)
    box(f'Boot cap {side}',(x,-.23,.17),(.28,.12,.12),black,.035)
uv('Torso', (0,0,1.12),(.39,.24,.39),orange)
box('Vest front seam',(0,-.242,1.12),(.04,.03,.56),navy,.01)
for side in (-1,1):
    x=side*.24
    box(f'Reflective shoulder {side}',(x,-.22,1.39),(.095,.045,.19),reflect,.016)
    box(f'Reflective hem {side}',(x,-.23,.97),(.14,.045,.07),reflect,.016)
    uv(f'Sleeve {side}',(side*.42,0,1.29),(.16,.16,.19),navy)
    uv(f'Arm {side}',(side*.50,0,1.08),(.13,.13,.24),navy)
    uv(f'Glove {side}',(side*.53,-.015,.86),(.15,.14,.14),glove)
    box(f'Glove cuff {side}',(side*.53,0,.94),(.25,.24,.065),black,.025)
uv('Neck',(0,-.015,1.47),(.15,.14,.14),skin)
uv('Head',(0,-.02,1.68),(.31,.275,.32),skin,32)
uv('Nose',(0,-.31,1.66),(.085,.09,.075),skin)
for side in (-1,1):
    uv(f'Ear {side}',(side*.30,-.02,1.64),(.075,.055,.10),skin)
    uv(f'Eye white {side}',(side*.12,-.265,1.74),(.085,.045,.085),white)
    uv(f'Pupil {side}',(side*.12,-.305,1.73),(.032,.023,.045),black)
    box(f'Eyebrow {side}',(side*.12,-.275,1.84),(.12,.025,.025),black,.01)
uv('Smile',(0,-.293,1.53),(.105,.022,.026),black)
# Hardhat cap has several curved layers so the silhouette reads at gameplay scale.
uv('Helmet crown',(0,0,1.93),(.365,.33,.19),yellow,32)
cyl('Helmet rim',(0,-.004,1.88),.39,.07,yellow)
box('Helmet brim',(0,-.25,1.86),(.67,.33,.045),yellow,.009)
box('Helmet ridge',(0,-.02,2.075),(.07,.47,.04),yellow,.008)
box('Helmet cyan decal',(0,-.445,1.89),(.17,.015,.045),cyan,.002)
# Small backpack and chemistry badge add identity from a 3/4 gameplay camera.
box('Chemistry pack',(0,.23,1.11),(.52,.19,.55),cyan,.10)
box('Pack lid',(0,.33,1.40),(.48,.19,.11),black,.035)
box('Vest badge',(.19,-.252,1.20),(.10,.025,.13),cyan,.012)
box('Badge symbol',(.19,-.27,1.20),(.025,.02,.08),reflect,.006)

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
bone('Root',(0,0,.05),(0,0,.80))
bone('Torso',(0,0,.80),(0,0,1.48),'Root')
bone('Head',(0,0,1.48),(0,0,1.94),'Torso')
bone('Arm_L',(-.38,0,1.40),(-.54,0,.87),'Torso')
bone('Arm_R',(.38,0,1.40),(.54,0,.87),'Torso')
bone('Leg_L',(-.16,0,.76),(-.16,0,.18),'Root')
bone('Leg_R',(.16,0,.76),(.16,0,.18),'Root')
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

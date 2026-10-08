"""Reproducible Level 2 chemistry station set; metres, +Z up in Blender."""
import bpy, math
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parent))
from station_material_profiles import profile_values
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'assets/models/stations'; OUT.mkdir(parents=True,exist_ok=True)
SRC=ROOT/'tools/blender/source'; SRC.mkdir(parents=True,exist_ok=True)

def mat(name,rgb,metal=0,rough=.55):
 metal,rough=profile_values(name,metal,rough)
 m=bpy.data.materials.new(name);m.diffuse_color=(*rgb,1);m.use_nodes=True
 bs=m.node_tree.nodes.get('Principled BSDF');bs.inputs['Base Color'].default_value=(*rgb,1);bs.inputs['Metallic'].default_value=metal;bs.inputs['Roughness'].default_value=rough
 return m
steel=mat('deep teal powder coat',(.06,.20,.25),.38)
dark=mat('charcoal rubber',(.025,.065,.08),.05)
concrete=mat('cast concrete',(.55,.56,.51))
amber=mat('safety amber',(.88,.44,.07),.12)
cyan=mat('cyan instrument',(.04,.52,.61),.14,.3)
white=mat('warm ceramic',(.87,.86,.77))
glass=mat('frosted vessel glass',(.46,.72,.73),.06,.25)
red=mat('reaction coral',(.68,.18,.13))
green=mat('inspection green',(.20,.52,.32))

def reset():bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
def box(name,p,size,m,b=.025):
 bpy.ops.mesh.primitive_cube_add(size=1,location=p);o=bpy.context.object;o.name=name;o.dimensions=size;bpy.ops.object.transform_apply(location=False,rotation=False,scale=True);o.data.materials.append(m)
 if b: q=o.modifiers.new('fabricated bevel','BEVEL');q.width=min(b,min(size)*.3);q.segments=3;o.modifiers.new('weighted normals','WEIGHTED_NORMAL')
 return o
def cyl(name,p,r,d,m,vertices=32):
 bpy.ops.mesh.primitive_cylinder_add(vertices=vertices,radius=r,depth=d,location=p);o=bpy.context.object;o.name=name;o.data.materials.append(m);q=o.modifiers.new('rolled edge','BEVEL');q.width=min(.012,d*.2,r*.2);q.segments=2;o.modifiers.new('weighted normals','WEIGHTED_NORMAL');return o
def rod(name,a,b,r,m):
 a,b=tuple(a),tuple(b);v=__import__('mathutils').Vector(b)-__import__('mathutils').Vector(a);mid=(__import__('mathutils').Vector(a)+__import__('mathutils').Vector(b))/2
 o=cyl(name,mid,r,v.length,m,20);o.rotation_mode='QUATERNION';o.rotation_quaternion=__import__('mathutils').Vector((0,0,1)).rotation_difference(v);return o
def base():
 box('concrete station footing',(0,0,.075),(2.26,1.32,.15),concrete,.06)
 for x in (-.9,.9):
  for y in (-.38,.38):box('anchored steel leg',(x,y,.64),(.11,.11,1.12),steel)
 box('work surface',(0,0,1.21),(2.08,1.15,.12),steel,.05)
 box('front amber safety band',(0,-.586,1.19),(1.96,.018,.045),amber,.008)
def save(name):
 for o in list(bpy.data.objects):
  if o.type=='MESH':
   bpy.context.view_layer.objects.active=o
   for mod in list(o.modifiers):bpy.ops.object.modifier_apply(modifier=mod.name)
 bpy.ops.wm.save_as_mainfile(filepath=str(SRC/f'{name}.blend'))
 bpy.ops.export_scene.gltf(filepath=str(OUT/f'{name}.glb'),export_format='GLB',export_apply=True)
 print('EXPORTED',name,len([o for o in bpy.data.objects if o.type=='MESH']))

# Reaction bench: rear extraction screen, two test vessels and a safe sealed reactor.
reset();base()
box('rear panel frame',(0,.49,1.91),(2.02,.13,1.24),steel,.05)
box('deep chemistry screen',(0,.405,1.92),(1.73,.03,.95),dark,.018)
for x in (-.58,-.20,.18,.56):box('equation display segment',(x,.382,2.04),(.29,.013,.2),cyan if x<0 else amber,.012)
for x in (-.52,.52):
 cyl('sealed reaction vessel',(x,-.18,1.53),.22,.47,glass);cyl('vessel cap',(x,-.18,1.78),.24,.06,steel)
 cyl('base heater ring',(x,-.18,1.29),.26,.045,amber)
box('safety enclosure rail',(0,-.47,1.58),(1.68,.055,.07),white)
for x in (-.8,.8):box('safety enclosure upright',(x,-.47,1.56),(.06,.06,.58),white)
for x in (-.78,.78):cyl('front control',(x,-.42,1.26),.055,.025,red if x<0 else green)
save('reaction_bench')

# Mixing station: supported twin paddle mixer over sample vessels.
reset();base()
box('upper motor beam',(0,.3,2.18),(1.82,.34,.28),steel,.055)
for x in (-.58,.58):
 box('motor housing',(x,.3,2.38),(.36,.35,.28),dark,.045)
 rod('drive shaft',(x,.23,2.20),(x,.23,1.55),.035,white)
 box('paddle blade',(x,.23,1.59),(.34,.055,.09),amber,.012)
 cyl('mixing beaker',(x,.23,1.47),.25,.40,glass)
 cyl('sample pool',(x,.23,1.43),.218,.16,cyan if x<0 else red)
 cyl('vessel foot',(x,.23,1.26),.27,.04,steel)
box('motor status display',(0,-.22,2.20),(.42,.045,.14),cyan)
for x in (-.45,0,.45):cyl('mix control',(x,-.43,1.26),.052,.026,amber)
save('mixing_station')

# Ionic console: ion display, two electrode probes and a vessel with sample.
reset();base()
box('vertical analyser',(0,.42,1.94),(1.85,.24,1.22),steel,.06)
box('dark screen',(0,.285,1.97),(1.57,.03,.96),dark,.018)
for x in (-.53,.53):
 cyl('ion display disc',(x,.26,2.00),.27,.018,cyan if x<0 else amber)
 for y in (-.10,.10):box('ion charge mark',(x+y,.244,2.00),(.055,.012,.18),white,.007)
box('console shelf',(0,-.25,1.38),(1.66,.45,.09),dark,.025)
cyl('sample vessel',(0,-.23,1.62),.20,.36,glass)
cyl('sample solution',(0,-.23,1.56),.17,.11,cyan)
for x in (-.08,.08):rod('electrode',(x,-.23,2.0),(x,-.23,1.54),.027,white)
for x in (-.53,.53):cyl('sample key',(x,-.4,1.45),.07,.028,amber)
save('ionic_reaction_station')

# Inspection station: raised checklist board, staged sample and calibrated meter.
reset();base()
box('inspection clipboard',(0,.43,1.95),(1.66,.16,1.23),steel,.055)
box('paper panel',(0,.335,1.95),(1.37,.027,.95),white,.02)
for i in range(4):
 z=2.23-i*.18
 box('inspection line',(.16,.309,z),(.86,.011,.038),dark,.006)
 box('checked item',(-.48,.307,z),(.13,.012,.13),green if i<3 else amber,.012)
box('sample specimen',(-.48,-.17,1.39),(.54,.38,.24),concrete,.035)
box('sample holder',(-.48,-.17,1.26),(.64,.48,.05),dark,.018)
box('inspection meter',(.49,-.12,1.40),(.52,.41,.30),dark,.04)
box('meter readout',(.49,-.34,1.46),(.36,.014,.12),cyan,.012)
for x in (.34,.5,.66):cyl('meter key',(x,-.34,1.32),.037,.017,amber)
save('inspection_station')

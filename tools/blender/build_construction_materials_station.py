"""Reproducible Level 5 construction materials testing station."""
import bpy
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'assets/models/stations';SRC=ROOT/'tools/blender/source'
OUT.mkdir(parents=True,exist_ok=True);SRC.mkdir(parents=True,exist_ok=True)
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)

def material(name,rgb,metal=0,rough=.55):
 m=bpy.data.materials.new(name);m.diffuse_color=(*rgb,1);m.use_nodes=True
 p=m.node_tree.nodes.get('Principled BSDF');p.inputs['Base Color'].default_value=(*rgb,1);p.inputs['Metallic'].default_value=metal;p.inputs['Roughness'].default_value=rough
 return m
steel=material('deep teal powder coat',(.055,.19,.24),.36)
concrete=material('cast concrete',(.54,.55,.51))
amber=material('safety amber',(.88,.45,.06),.12)
dark=material('charcoal elastomer',(.025,.06,.075))
cyan=material('cyan display',(.045,.52,.61),.13,.3)
white=material('gypsum white',(.84,.82,.72))
limestone=material('limestone cream',(.66,.56,.37))
aggregate=material('aggregate charcoal',(.30,.34,.34))
metal=material('machined platen',(.52,.60,.61),.72,.28)
glass=material('frosted water vessel',(.56,.80,.82),.03,.24)
blue=material('virtual water sample',(.12,.39,.64),.05,.25)

def box(name,p,s,m,b=.025):
 bpy.ops.mesh.primitive_cube_add(size=1,location=p);o=bpy.context.object;o.name=name;o.dimensions=s;bpy.ops.object.transform_apply(location=False,rotation=False,scale=True);o.data.materials.append(m)
 if b:
  q=o.modifiers.new('manufactured bevel','BEVEL');q.width=min(b,min(s)*.2);q.segments=3;o.modifiers.new('weighted normals','WEIGHTED_NORMAL')
 return o

def cyl(name,p,r,d,m,vertices=32):
 bpy.ops.mesh.primitive_cylinder_add(vertices=vertices,radius=r,depth=d,location=p);o=bpy.context.object;o.name=name;o.data.materials.append(m)
 q=o.modifiers.new('rolled edge','BEVEL');q.width=min(.012,r*.18,d*.18);q.segments=2;o.modifiers.new('weighted normals','WEIGHTED_NORMAL');return o

def rod(name,a,b,r,m):
 va,vb=Vector(a),Vector(b);v=vb-va;o=cyl(name,(va+vb)*.5,r,v.length,m,20);o.rotation_mode='QUATERNION';o.rotation_quaternion=Vector((0,0,1)).rotation_difference(v);return o

box('concrete footing',(0,0,.075),(2.65,1.55,.15),concrete,.055)
for x in (-1.07,1.07):
 for y in (-.53,.53):box('steel leg',(x,y,.64),(.12,.12,1.12),steel)
box('chemical resistant worktop',(0,0,1.22),(2.48,1.35,.12),steel,.045)
box('front safety trim',(0,-.681,1.20),(2.36,.025,.06),amber,.004)
# Supported compression frame and legible virtual concrete cube.
box('test machine lower housing',(-.57,.02,1.39),(1.09,.93,.23),dark,.035)
for x in (-1.02,-.12):
 box('compression frame upright',(x,.19,1.88),(.13,.15,.86),steel,.025)
 box('compression frame foot',(x,.19,1.47),(.22,.63,.07),metal,.013)
box('compression frame header',(-.57,.19,2.31),(1.09,.18,.15),steel,.03)
cyl('lower piston',(-.57,.02,1.58),.29,.12,metal)
cyl('lower platen',(-.57,.02,1.66),.35,.045,metal)
box('concrete test cube',(-.57,.02,1.83),(.30,.30,.30),concrete,.012)
# A bright sleeve emphasizes the measurement gap without simulating a procedure.
cyl('upper platen',(-.57,.02,2.02),.31,.045,metal)
cyl('upper piston',(-.57,.02,2.13),.15,.17,metal)
box('instrument readout case',(-.57,.22,2.50),(.86,.16,.34),steel,.025)
box('instrument screen',(-.57,-.31,2.52),(.61,.023,.17),dark,.006)
for i in range(3):box('display bar',(-.77+i*.20,-.327,2.52),(.12,.012,.075),cyan if i<2 else amber,.002)
# Three material swatches support visual recognition of aggregate, gypsum, and limestone.
box('material sample tray',(.68,-.10,1.30),(.92,.87,.055),dark,.015)
for y,m,name in ((-.37,aggregate,'aggregate'),(-.08,white,'gypsum'),(.21,limestone,'limestone')):
 box(name+' specimen',(.66,y,1.40),(.58,.21,.15),m,.017)
 box(name+' label rail',(.66,y-.12,1.34),(.62,.025,.035),amber if name=='aggregate' else cyan,.005)
# Readable water-hardness sample and protected measurement tip.
cyl('sealed water sample',(.91,.44,1.48),.12,.33,glass,24)
cyl('virtual water content',(.91,.44,1.42),.095,.13,blue,24)
cyl('vial cap',(.91,.44,1.67),.12,.042,steel,24)
rod('upright sample probe',(.31,.49,1.33),(.31,.49,1.77),.035,white)
box('probe mount',(.42,.49,1.76),(.25,.07,.065),steel,.01)

for o in list(bpy.data.objects):
 if o.type=='MESH':
  bpy.context.view_layer.objects.active=o
  for mod in list(o.modifiers):bpy.ops.object.modifier_apply(modifier=mod.name)
bpy.ops.wm.save_as_mainfile(filepath=str(SRC/'construction_materials_station.blend'))
bpy.ops.export_scene.gltf(filepath=str(OUT/'construction_materials_station.glb'),export_format='GLB',export_apply=True)
print('EXPORTED construction_materials_station',len([o for o in bpy.data.objects if o.type=='MESH']))

"""Reproducible Level 4 electrochemistry and corrosion station assets."""
import bpy
from pathlib import Path
from mathutils import Vector
import sys
sys.path.insert(0,str(Path(__file__).resolve().parent))
from station_material_profiles import profile_values
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'assets/models/stations'; SRC=ROOT/'tools/blender/source'
OUT.mkdir(parents=True,exist_ok=True);SRC.mkdir(parents=True,exist_ok=True)

def clear():
 bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)

def material(name,rgb,metal=0,rough=.55):
 metal,rough=profile_values(name,metal,rough)
 m=bpy.data.materials.new(name);m.diffuse_color=(*rgb,1);m.use_nodes=True
 p=m.node_tree.nodes.get('Principled BSDF');p.inputs['Base Color'].default_value=(*rgb,1);p.inputs['Metallic'].default_value=metal;p.inputs['Roughness'].default_value=rough
 return m

def box(name,p,s,m,b=.025):
 bpy.ops.mesh.primitive_cube_add(size=1,location=p);o=bpy.context.object;o.name=name;o.dimensions=s;bpy.ops.object.transform_apply(location=False,rotation=False,scale=True);o.data.materials.append(m)
 if b:
  q=o.modifiers.new('fabricated bevel','BEVEL');q.width=min(b,min(s)*.2);q.segments=3;o.modifiers.new('weighted normals','WEIGHTED_NORMAL')
 return o

def cyl(name,p,r,d,m,vertices=32):
 bpy.ops.mesh.primitive_cylinder_add(vertices=vertices,radius=r,depth=d,location=p);o=bpy.context.object;o.name=name;o.data.materials.append(m)
 q=o.modifiers.new('rolled edge','BEVEL');q.width=min(.012,r*.18,d*.18);q.segments=2;o.modifiers.new('weighted normals','WEIGHTED_NORMAL');return o

def rod(name,a,b,r,m):
 va,vb=Vector(a),Vector(b);v=vb-va;o=cyl(name,(va+vb)*.5,r,v.length,m,16);o.rotation_mode='QUATERNION';o.rotation_quaternion=Vector((0,0,1)).rotation_difference(v);return o

def foundation():
 box('concrete footing',(0,0,.075),(2.65,1.55,.15),concrete,.055)
 for x in (-1.07,1.07):
  for y in (-.53,.53):box('steel leg',(x,y,.64),(.12,.12,1.12),steel)
 box('worktop',(0,0,1.22),(2.48,1.35,.12),steel,.045)
 box('safety trim',(0,-.681,1.2),(2.36,.025,.06),amber,.004)

def export(name):
 for o in list(bpy.data.objects):
  if o.type=='MESH':
   bpy.context.view_layer.objects.active=o
   for mod in list(o.modifiers):bpy.ops.object.modifier_apply(modifier=mod.name)
 bpy.ops.wm.save_as_mainfile(filepath=str(SRC/(name+'.blend')))
 bpy.ops.export_scene.gltf(filepath=str(OUT/(name+'.glb')),export_format='GLB',export_apply=True)
 print('EXPORTED',name,len([o for o in bpy.data.objects if o.type=='MESH']))

clear()
steel=material('deep teal powder coat',(.055,.19,.24),.36)
concrete=material('cast concrete',(.54,.55,.51))
amber=material('safety amber',(.88,.45,.06),.12)
dark=material('charcoal display',(.025,.06,.075))
cyan=material('cyan indicator',(.045,.52,.61),.13,.3)
white=material('frosted glass',(.58,.79,.79),.02,.3)
blue=material('blue virtual electrolyte',(.09,.37,.62),.1,.3)
zinc=material('zinc electrode',(.55,.59,.57),.72,.36)
copper=material('copper electrode',(.71,.29,.11),.67,.34)
foundation()
for x,liquid,electrode in ((-.64,cyan,zinc),(.64,blue,copper)):
 cyl('half cell protective tray',(x,-.10,1.30),.43,.08,dark)
 cyl('half cell vessel',(x,-.10,1.54),.34,.48,white)
 cyl('virtual electrolyte',(x,-.10,1.44),.30,.19,liquid)
 box('metal electrode',(x,-.10,1.80),(.095,.18,.64),electrode,.01)
 cyl('electrode terminal',(x,-.10,2.15),.08,.055,amber)
# The arched salt bridge remains visibly separate from the external instrument circuit.
rod('salt bridge left',(-.34,-.10,1.65),(-.34,-.10,2.02),.055,white)
rod('salt bridge top',(-.34,-.10,2.02),(.34,-.10,2.02),.055,white)
rod('salt bridge right',(.34,-.10,2.02),(.34,-.10,1.65),.055,white)
box('meter pedestal',(0,.51,1.59),(.13,.12,.68),steel)
box('voltmeter case',(0,.47,2.04),(.95,.2,.5),steel,.035)
box('voltmeter display',(0,.345,2.07),(.69,.025,.28),dark,.01)
for i in range(4):box('voltmeter scale tick',(-.22+i*.14,.323,2.08),(.07,.012,.11),cyan,.002)
for x,electrode in ((-.64,zinc),(.64,copper)):
 rod('external lead', (x,-.10,2.15),(x,.47,2.35),.025,electrode)
 rod('external lead',(x,.47,2.35),(x*.48,.47,2.32),.025,electrode)
export('electrochemistry_station')

clear()
steel=material('deep teal powder coat',(.055,.19,.24),.36)
concrete=material('cast concrete',(.54,.55,.51))
amber=material('safety amber',(.88,.45,.06),.12)
dark=material('charcoal display',(.025,.06,.075))
cyan=material('cyan indicator',(.045,.52,.61),.13,.3)
white=material('inspection ceramic',(.86,.84,.72))
rebar=material('uncoated steel',(.34,.39,.40),.76,.5)
rust=material('surface corrosion',(.55,.18,.065),.08,.88)
coating=material('protective coating',(.15,.48,.41),.22,.3)
foundation()
box('raised test cradle',(-.12,-.08,1.36),(1.88,.76,.16),dark,.025)
for x in (-.83,.83):box('coupon clamp',(x,-.08,1.56),(.13,.70,.25),steel,.018)
# Parallel coupons make the exposed and coated surfaces legible from the game camera.
for y,finish in ((-.29,rust),(.16,coating)):
 rod('steel reinforcement core',(-.80,y,1.62),(.80,y,1.62),.075,rebar)
 rod('surface comparison',(-.50,y,1.625),(.55,y,1.625),.084,finish)
 for x in (-.62,-.25,.12,.49):
  cyl('reinforcement rib',(x,y,1.625),.093,.045,finish,16).rotation_euler[1]=1.57079632679
box('sample backing',(-.12,.47,1.63),(1.9,.055,.48),concrete,.025)
box('inspection instrument',(0,.51,2.10),(1.10,.17,.49),steel,.035)
box('inspection display',(0,.405,2.13),(.82,.025,.27),dark,.01)
for x in (-.24,-.05,.14,.33):box('indicator glyph',(x,.387,2.13),(.10,.012,.11),amber if x<0 else cyan,.002)
rod('contact probe',(.68,.43,2.08),(.68,.15,1.73),.025,white)
for x in (-.68,.68):cyl('rig anchor',(x,-.49,1.30),.09,.08,amber,20)
export('corrosion_test_rig')

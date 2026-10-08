"""Reproducible stylized solution laboratory for ChemSite Level 3."""
import bpy
from pathlib import Path
from mathutils import Vector
import sys
sys.path.insert(0,str(Path(__file__).resolve().parent))
from station_material_profiles import profile_values
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'assets/models/stations';SRC=ROOT/'tools/blender/source'
OUT.mkdir(parents=True,exist_ok=True);SRC.mkdir(parents=True,exist_ok=True)
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)

def material(name,rgb,metal=0,rough=.55):
 metal,rough=profile_values(name,metal,rough)
 m=bpy.data.materials.new(name);m.diffuse_color=(*rgb,1);m.use_nodes=True
 p=m.node_tree.nodes.get('Principled BSDF');p.inputs['Base Color'].default_value=(*rgb,1);p.inputs['Metallic'].default_value=metal;p.inputs['Roughness'].default_value=rough
 return m
steel=material('deep teal powder coat',(.055,.19,.24),.38)
dark=material('charcoal rubber',(.025,.06,.075))
concrete=material('cast concrete',(.54,.55,.51))
amber=material('safety amber',(.87,.43,.065),.12)
cyan=material('cyan display',(.045,.52,.61),.15,.3)
glass=material('frosted vessel glass',(.47,.74,.75),.03,.23)
white=material('warm ceramic',(.87,.85,.75))
blue=material('dilute blue sample',(.10,.45,.65),.1,.23)
green=material('sample green',(.22,.52,.32))

def box(name,p,s,m,b=.025):
 bpy.ops.mesh.primitive_cube_add(size=1,location=p);o=bpy.context.object;o.name=name;o.dimensions=s;bpy.ops.object.transform_apply(location=False,rotation=False,scale=True);o.data.materials.append(m)
 if b:
  q=o.modifiers.new('fabricated bevel','BEVEL');q.width=min(b,min(s)*.22);q.segments=3;o.modifiers.new('weighted normals','WEIGHTED_NORMAL')
 return o

def cyl(name,p,r,d,m,vertices=32):
 bpy.ops.mesh.primitive_cylinder_add(vertices=vertices,radius=r,depth=d,location=p);o=bpy.context.object;o.name=name;o.data.materials.append(m)
 q=o.modifiers.new('rolled rim','BEVEL');q.width=min(.012,r*.2,d*.2);q.segments=2;o.modifiers.new('weighted normals','WEIGHTED_NORMAL');return o

def rod(name,a,b,r,m):
 va,vb=Vector(a),Vector(b);v=vb-va;o=cyl(name,(va+vb)*.5,r,v.length,m,20);o.rotation_mode='QUATERNION';o.rotation_quaternion=Vector((0,0,1)).rotation_difference(v);return o

# A compact bench: measurement left, concentration glassware right, pH readout above.
box('concrete footing',(0,0,.075),(2.65,1.55,.15),concrete,.06)
for x in (-1.07,1.07):
 for y in (-.53,.53):box('anchored steel leg',(x,y,.64),(.12,.12,1.12),steel)
box('chemical-resistant worktop',(0,0,1.22),(2.48,1.35,.12),steel,.055)
box('amber front safety edge',(0,-.681,1.20),(2.36,.02,.05),amber,.006)
# Analytical balance and translucent draft shield.
box('balance body',(-.69,-.14,1.39),(.87,.73,.22),dark,.045)
box('balance readout',(-.69,-.53,1.40),(.54,.02,.10),cyan,.008)
for x in (-.99,-.39):
 for y in (-.41,.16):box('draft shield upright',(x,y,1.72),(.026,.026,.55),glass,.006)
for x in (-.69,):
 for y in (-.41,.16):box('draft shield rim',(x,y,2.01),(.62,.026,.025),glass,.006)
box('draft shield roof',(-.69,-.125,2.04),(.67,.64,.035),glass,.006)
cyl('weighing pan',(-.69,-.12,1.56),.21,.04,white)
box('small weighing boat',(-.69,-.12,1.61),(.27,.2,.045),white,.012)
# Right-hand volumetric vessel cluster: support tray, long-neck flasks, and calibration marks.
box('vessel tray',(.67,-.13,1.29),(.97,.81,.07),dark,.018)
for x,r,height,color in ((.34,.18,.39,blue),(.93,.21,.44,green)):
 cyl('volumetric vessel body',(x,-.12,1.48),r,height,glass)
 cyl('virtual solution',(x,-.12,1.39),r*.85,.15,color)
 cyl('narrow measuring neck',(x,-.12,1.77),r*.29,.23,glass)
 cyl('stopper',(x,-.12,1.91),r*.35,.05,steel)
 box('calibration mark',(x,-.12-r*.30,1.76),(r*.31,.014,.018),amber,.004)
# Back display with pH color ladder and probe connected to the rightmost vessel.
box('rear instrument mast',(.04,.57,1.78),(.10,.11,1.16),steel,.018)
box('pH meter casing',(.04,.50,2.16),(1.24,.20,.71),steel,.055)
box('pH screen',(.04,.382,2.20),(.93,.025,.46),dark,.018)
for i,c in enumerate((amber,green,cyan)):
 box('pH reference bar',(-.26+i*.24,.36,2.25),(.17,.014,.23),c,.008)
box('pH numeric glyph',(.43,.36,2.25),(.10,.014,.27),white,.008)
rod('supported probe',(.92,.39,2.04),(.92,.39,1.48),.028,white)
box('probe support arm',(.49,.38,2.02),(.87,.055,.055),steel,.014)
for i,x in enumerate((-.30,-.06,.18)):
 cyl('console button',(x,.34,1.81),.046,.025,amber if i==0 else white)
# A labelled sample vial complements the scale without blocking the vessel silhouettes.
cyl('sealed reference vial',(-1.07,.43,1.42),.08,.25,glass,24)
cyl('vial lid',(-1.07,.43,1.57),.085,.035,cyan,24)

for o in list(bpy.data.objects):
 if o.type=='MESH':
  bpy.context.view_layer.objects.active=o
  for mod in list(o.modifiers):bpy.ops.object.modifier_apply(modifier=mod.name)
bpy.ops.wm.save_as_mainfile(filepath=str(SRC/'solution_laboratory.blend'))
bpy.ops.export_scene.gltf(filepath=str(OUT/'solution_laboratory.glb'),export_format='GLB',export_apply=True)
print('EXPORTED solution_laboratory',len([o for o in bpy.data.objects if o.type=='MESH']))

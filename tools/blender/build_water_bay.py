"""Original stylized pipe display with supported tank, hand pump and gauge."""
import bpy, math
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'artifacts/water-bay';OUT.mkdir(parents=True,exist_ok=True)
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
def material(name,color,rough=.65,metal=0):
 m=bpy.data.materials.new(name);m.diffuse_color=(*color,1);m.use_nodes=True
 s=m.node_tree.nodes.get('Principled BSDF');s.inputs['Base Color'].default_value=(*color,1)
 s.inputs['Roughness'].default_value=rough;s.inputs['Metallic'].default_value=metal;return m
teal=material('Water display frame',(.045,.29,.32))
blue=material('Blue storage tank',(.08,.38,.52),.48)
steel=material('Pipe and pump hardware',(.36,.44,.47),.4,.5)
black=material('Rubber feet and hose',(.035,.055,.065),.8)
cream=material('Gauge and schematic',(.90,.89,.73),.78)
orange=material('Safety handle and labels',(.96,.38,.035))
red=material('Pump reservoir',(.65,.12,.055),.55)
def box(name,loc,size,mat,bevel=.012):
 bpy.ops.mesh.primitive_cube_add(size=1,location=loc);o=bpy.context.object;o.name=name;o.dimensions=size
 bpy.ops.object.transform_apply(location=False,rotation=False,scale=True);o.data.materials.append(mat)
 b=o.modifiers.new('Finished edges','BEVEL');b.width=min(bevel,min(size)*.25);b.segments=2
 o.modifiers.new('Surface normals','WEIGHTED_NORMAL');return o
def cylinder(name,loc,r,depth,mat,axis='Z',vertices=24):
 bpy.ops.mesh.primitive_cylinder_add(vertices=(6 if r<.012 else (12 if r<.065 else vertices)),radius=r,depth=depth,location=loc)
 o=bpy.context.object;o.name=name;o.data.materials.append(mat)
 if axis=='Y':o.rotation_euler.x=math.pi/2
 if axis=='X':o.rotation_euler.y=math.pi/2
 for f in o.data.polygons:f.use_smooth=len(f.vertices)==4
 b=o.modifiers.new('Turned edges','BEVEL');b.width=min(.004,r*.15,depth*.15);b.segments=1 if r<.065 else 2
 o.modifiers.new('Surface normals','WEIGHTED_NORMAL');return o
def tube(name,points,r,mat):
 d=bpy.data.curves.new(name,'CURVE');d.dimensions='3D';d.bevel_depth=r;d.bevel_resolution=1 if r<.02 else 2;d.use_fill_caps=True
 s=d.splines.new('POLY');s.points.add(len(points)-1)
 for p,co in zip(s.points,points):p.co=(*co,1)
 o=bpy.data.objects.new(name,d);bpy.context.collection.objects.link(o);d.materials.append(mat)
 bpy.context.view_layer.objects.active=o;o.select_set(True);bpy.ops.object.convert(target='MESH');o.select_set(False);return o
def rod(name,a,b,r,mat):
 a=Vector(a);b=Vector(b);o=cylinder(name,(a+b)/2,r,(b-a).length,mat)
 o.rotation_euler=(b-a).to_track_quat('Z','Y').to_euler();return o
# Braced feet and frame support both the reservoir and the pipe display.
for x in (-.96,.96):
 for y in (-.46,.46):
  box('Rubber frame foot',(x,y,.035),(.19,.19,.07),black)
  box('Frame upright',(x,y,.49),(.075,.075,.91),teal)
 for z in (.14,.90):box('Side crossbar',(x,0,z),(.075,1,.075),teal)
for y in (-.46,.46):box('Longitudinal base brace',(0,y,.14),(2,.075,.075),teal)
box('Grounded equipment deck',(0,0,.20),(2.12,1.12,.055),teal)
for x in (-.08,.89):box('Rear display support',(x,.39,.91),(.05,.05,1.36),teal)
box('Rear display panel',(.40,.40,1.18),(1.06,.035,.76),teal)
box('Schematic panel',(.40,.372,1.18),(.97,.012,.64),cream)
# Fitted tank straps, lid and outlet define a purposeful vessel.
cylinder('Blue tank',(-.64,0,.6375),.265,.82,blue,vertices=32)
for z in (.28,1.00):cylinder('Tank protective rim',(-.64,0,z),.273,.027,teal,vertices=32)
cylinder('Tank lid',(-.64,0,1.061),.27,.026,steel,vertices=32)
box('Tank lid grip',(-.64,0,1.095),(.20,.055,.04),black)
for z in (.43,.85):
 tube('Tank retaining strap',[(-.64+.27*math.cos(2*math.pi*i/48),.27*math.sin(2*math.pi*i/48),z) for i in range(49)],.011,steel)
box('Tank identity plate',(-.64,-.27,.68),(.25,.015,.15),cream)
box('Tank blue symbol',(-.64,-.283,.68),(.11,.008,.072),blue)
cylinder('Tank outlet',(-.40,0,.42),.045,.10,steel,'X')
# Rounded pipe rectangle: one connected contour, with unions and bolted brackets.
points=[]
for cx,cz,start in [(.71,1.29,0),(.12,1.29,90),(.12,.73,180),(.71,.73,270)]:
 for i in range(13):
  a=math.radians(start+i*90/12)
  points.append((cx+.10*math.cos(a),.14,cz+.10*math.sin(a)))
points.append(points[0]);tube('Connected pipe loop',points,.036,blue)
for x in (.02,.81):
 for z in (.90,1.18):
  cylinder('Pipe coupling',(x,.14,z),.051,.075,steel)
  box('Pipe mounting bracket',(x,.265,z),(.12,.23,.033),steel)
  for bx in (x-.042,x+.042):cylinder('Bracket bolt',(bx,.14,z+.024),.009,.012,black)
# Gauge attaches to the top line, facing the viewer; markings remain pictorial.
cylinder('Gauge stem',(.42,.14,1.435),.020,.095,steel)
cylinder('Gauge case',(.42,.105,1.535),.115,.07,steel,'Y',32)
cylinder('Gauge dial',(.42,.064,1.535),.101,.008,cream,'Y',32)
for i in range(9):
 a=math.radians(30+i*30);x=.42+.078*math.cos(a);z=1.535+.078*math.sin(a)
 tick=box('Gauge tick',(x,.057,z),(.014,.004,.004),teal,.001);tick.rotation_euler.y=-a
tube('Gauge pointer',[(.42,.052,1.535),(.383,.052,1.588)],.004,orange)
cylinder('Gauge center',(.42,.050,1.535),.008,.006,black,'Y')
# Open hand-pump reservoir, pivot and long lever on the supported lower deck.
box('Pump reservoir base',(.38,-.23,.245),(.65,.35,.033),red)
for y in (-.395,-.065):box('Pump reservoir wall',(.38,y,.355),(.65,.02,.20),red)
for x in (.065,.695):box('Pump reservoir end',(x,-.23,.355),(.02,.33,.20),red)
box('Pump mounting plate',(.19,-.23,.47),(.23,.31,.028),steel)
cylinder('Pump body',(.19,-.23,.54),.045,.13,steel)
cylinder('Pump plunger',(.19,-.23,.655),.016,.15,steel)
box('Pump pivot support',(.19,-.23,.67),(.065,.065,.14),steel)
cylinder('Pump lever pivot',(.19,-.23,.71),.031,.09,black,'Y')
rod('Pump lever',(.19,-.23,.71),(.60,-.23,.96),.016,steel)
rod('Pump lever grip',(.56,-.23,.935),(.68,-.23,1.008),.027,black)
for x in (.12,.25):cylinder('Pump valve knob',(x,-.23,.49),.025,.028,black)
# Hose connects to the pump manifold and the lower pipe inlet.
hose=[]
for i in range(49):
 t=i/48
 hose.append((.11-.09*t,-.33-.20*math.sin(math.pi*t),.51+.22*t-.16*math.sin(math.pi*t)))
hose.append((.02,.14,.73))
tube('Connected test hose',hose,.016,black)
cylinder('Pipe valve',(.02,.14,.73),.047,.10,steel,'X')
box('Valve handle',(.02,.14,.80),(.12,.022,.018),orange,.005)
box('Reservoir safety plate',(.38,-.41,.35),(.29,.008,.065),cream)
for x in (.28,.38,.48):box('Safety plate mark',(x,-.418,.35),(.025,.006,.025),red,.003)
# Apply portable geometry and retain editable pieces in the source.
for o in list(bpy.data.objects):
 if o.type=='MESH':
  bpy.context.view_layer.objects.active=o
  for m in list(o.modifiers):bpy.ops.object.modifier_apply(modifier=m.name)
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'water_bay.blend'))
for mat in list(bpy.data.materials):
 pieces=[o for o in bpy.data.objects if o.type=='MESH' and o.data.materials[0]==mat]
 if not pieces:continue
 bpy.ops.object.select_all(action='DESELECT')
 for o in pieces:o.select_set(True)
 bpy.context.view_layer.objects.active=pieces[0];bpy.ops.object.join();pieces[0].name=mat.name
bpy.ops.export_scene.gltf(filepath=str(OUT/'water_bay.glb'),export_format='GLB',export_apply=True)
print('WATER_BAY_EXPORT_OK')

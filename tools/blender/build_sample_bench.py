"""Original inspectable sample workbench with split mould and sample display."""
import bpy, math
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'artifacts/sample-bench';OUT.mkdir(parents=True,exist_ok=True)
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
def material(name,color,rough=.65,metal=0):
 m=bpy.data.materials.new(name);m.diffuse_color=(*color,1);m.use_nodes=True
 s=m.node_tree.nodes.get('Principled BSDF');s.inputs['Base Color'].default_value=(*color,1)
 s.inputs['Roughness'].default_value=rough;s.inputs['Metallic'].default_value=metal
 return m
teal=material('Painted sample frame',(.045,.29,.32))
wood=material('Sealed worktop',(.53,.32,.14),.75)
steel=material('Clamp hardware',(.34,.42,.45),.38,.5)
concrete=material('Warm concrete samples',(.60,.62,.57),.88)
rubber=material('Caster rubber',(.045,.065,.07),.8)
cream=material('Observation paper',(.89,.88,.71),.85)
orange=material('Safety markings',(.95,.39,.055))
def box(name,loc,size,mat,bevel=.015):
 bpy.ops.mesh.primitive_cube_add(size=1,location=loc);o=bpy.context.object;o.name=name;o.dimensions=size
 bpy.ops.object.transform_apply(location=False,rotation=False,scale=True);o.data.materials.append(mat)
 b=o.modifiers.new('Finished edges','BEVEL');b.width=min(bevel,min(size)*.25);b.segments=3 if name in ("Worktop","Concrete cube","Stored sample") else 2
 o.modifiers.new('Weighted normals','WEIGHTED_NORMAL');return o
def cylinder(name,loc,r,depth,mat,axis='Z'):
 bpy.ops.mesh.primitive_cylinder_add(vertices=20,radius=r,depth=depth,location=loc)
 o=bpy.context.object;o.name=name;o.data.materials.append(mat)
 if axis=='Y':o.rotation_euler.x=math.pi/2
 for f in o.data.polygons:f.use_smooth=len(f.vertices)==4
 b=o.modifiers.new('Turned edge','BEVEL');b.width=min(.004,r*.15,depth*.15);b.segments=2
 o.modifiers.new('Weighted normals','WEIGHTED_NORMAL');return o
# Grounded casters and braced metal frame support the worktop and sample shelf.
for x in (-.96,.96):
 for y in (-.46,.46):
  cylinder('Grounded caster',(x,y,.08),.08,.065,rubber,'Y')
  box('Caster fork',(x,y,.14),(.12,.085,.12),steel)
  box('Table upright',(x,y,.48),(.085,.085,.65),teal)
for y in (-.46,.46):box('Lower longitudinal brace',(0,y,.27),(2,.075,.075),teal)
for x in (-.96,.96):box('Lower transverse brace',(x,0,.27),(.075,1,.075),teal)
box('Lower sample shelf',(0,0,.32),(1.95,.95,.045),teal)
box('Worktop',(0,0,.84),(2.2,1.25,.085),wood,.022)
for y in (-.61,.61):box('Worktop edge strip',(0,y,.838),(2.18,.025,.055),steel)
# Mould walls meet in two L-shaped halves around a supported base.
mx=-.60;my=-.12;base=.892
box('Mould base',(mx,my,base),(.38,.34,.018),steel)
for x in (-.106,.106):
 box('Mould side',(mx+x,my,1.005),(.025,.23,.21),teal)
 box('Mould side foot',(mx+x,my,.913),(.075,.28,.018),teal)
for y in (-.106,.106):box('Mould end',(mx,my+y,1.005),(.19,.025,.21),teal)
for x in (-.154,.154):
 cylinder('Clamp threaded post',(mx+x,my,.948),.012,.10,steel)
 cylinder('Clamp nut',(mx+x,my,.961),.024,.016,steel)
 box('Clamp tab',(mx+x,my,.936),(.060,.055,.014),steel)
# Two finished cubes on a lipped tray, one split mould half laid on the table.
box('Sample tray',( .53,-.10,.9),(.62,.41,.025),steel)
for y in (-.30,.10):box('Tray lip',(.53,y,.92),(.62,.018,.055),steel)
for x in (.36,.66):
 box('Concrete cube',(x,-.10,1.0075),(.19,.19,.19),concrete,.009)
 box('Sample identity stripe',(x,-.197,1.01),(.09,.008,.024),orange,.002)
box('Detached mould wall',(-.14,.32,.957),(.27,.024,.15),teal)
box('Detached mould flange',(-.14,.30,.901),(.27,.07,.02),teal)
# Log clipboard and meaningful rear chart with an original cube diagram.
box('Observation clipboard',(-.12,-.40,.902),(.31,.26,.026),teal)
box('Log sheet',(-.12,-.40,.918),(.275,.218,.005),cream,.001)
box('Clipboard clip',(-.12,-.29,.927),(.07,.038,.012),steel,.003)
for row in range(4):box('Log row',(-.12,-.34-row*.035,.921),(.21,.004,.002),teal,.0004)
for x in (-.88,.88):box('Chart upright',(x,.49,1.17),(.05,.05,.58),teal)
box('Observation chart',(0,.50,1.43),(1.84,.05,.43),teal)
box('Chart inset',(0,.466,1.43),(1.70,.016,.31),cream)
box('Chart cube icon',(-.60,.452,1.435),(.20,.012,.20),concrete)
for row in range(3):box('Chart observation row',(.20,.452,1.51-row*.074),(.98,.009,.018),teal,.002)
for x in (-.60,-.23,.15,.53):box('Stored sample',(x,0,.4275),(.17,.17,.17),concrete,.008)
# Source retains editable pieces; the exported static assembly batches by material.
for o in list(bpy.data.objects):
 if o.type=='MESH':
  bpy.context.view_layer.objects.active=o
  for mod in list(o.modifiers):bpy.ops.object.modifier_apply(modifier=mod.name)
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'sample_bench.blend'))
for m in list(bpy.data.materials):
 pieces=[o for o in bpy.data.objects if o.type=='MESH' and o.data.materials[0]==m]
 if not pieces:continue
 bpy.ops.object.select_all(action='DESELECT')
 for o in pieces:o.select_set(True)
 bpy.context.view_layer.objects.active=pieces[0];bpy.ops.object.join();pieces[0].name=m.name
bpy.ops.export_scene.gltf(filepath=str(OUT/'sample_bench.glb'),export_format='GLB',export_apply=True)
print('SAMPLE_BENCH_EXPORT_OK')

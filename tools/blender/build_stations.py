import bpy, math
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'assets/models/stations'
OUT.mkdir(parents=True,exist_ok=True)

def material(name,rgb,metal=0,rough=.55):
 m=bpy.data.materials.get(name) or bpy.data.materials.new(name)
 m.diffuse_color=(*rgb,1);m.use_nodes=True
 bs=m.node_tree.nodes.get('Principled BSDF')
 bs.inputs['Base Color'].default_value=(*rgb,1)
 bs.inputs['Metallic'].default_value=metal
 bs.inputs['Roughness'].default_value=rough
 return m
steel=material('blue powder-coated steel',(.075,.21,.27),.5)
dark=material('dark slate',(.025,.075,.095),.25)
concrete=material('concrete',(.53,.56,.52))
amber=material('safety amber',(.88,.43,.07),.1,.4)
cyan=material('chemistry cyan',(.04,.5,.61),.16,.34)
glass=material('laboratory glass',(.53,.79,.77),.1,.19)
white=material('warm white',(.86,.85,.73))
wood=material('sealed plywood',(.38,.25,.14))
red=material('sample red',(.68,.18,.13))
green=material('sample green',(.16,.47,.31))

def reset():
 bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)

def box(name,loc,dim,mat,bevel=.035):
 bpy.ops.mesh.primitive_cube_add(size=1,location=loc)
 o=bpy.context.object;o.name=name;o.dimensions=dim
 bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 o.data.materials.append(mat)
 if bevel:
  mod=o.modifiers.new('rounded fabrication edges','BEVEL');mod.width=min(bevel,min(dim)*.35);mod.segments=3
  o.modifiers.new('weighted normals','WEIGHTED_NORMAL')
 return o

def cyl(name,loc,radius,depth,mat,verts=24):
 bpy.ops.mesh.primitive_cylinder_add(vertices=verts,radius=radius,depth=depth,location=loc)
 o=bpy.context.object;o.name=name;o.data.materials.append(mat)
 mod=o.modifiers.new('rolled rim','BEVEL');mod.width=.015;mod.segments=2
 o.modifiers.new('weighted normals','WEIGHTED_NORMAL')
 return o

def finish(path):
 for o in bpy.data.objects:
  if o.type=='MESH':
   for mod in list(o.modifiers):
    bpy.context.view_layer.objects.active=o;bpy.ops.object.modifier_apply(modifier=mod.name)
 bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'tools/blender/source'/f'{path}.blend'))
 bpy.ops.export_scene.gltf(filepath=str(OUT/f'{path}.glb'),export_format='GLB',export_apply=True)
 print('STATION_EXPORT',path)

# Substance storage: sturdy A-frame, shelves, sealed sample containers.
reset()
box('Storage foundation',(0,0,.08),(2.25,1.30,.16),concrete,.07)
for x in (-.99,.99):
 box('Steel upright',(x,.22,1.12),(.13,.13,2.08),steel)
 box('Anchor foot',(x,.22,.22),(.23,.5,.12),steel)
for y in (-.3,.32):
 box('Plywood shelf',(0,y,1.06),(1.94,.47,.095),wood,.03)
 box('Plywood shelf',(0,y,1.72),(1.94,.47,.095),wood,.03)
for i,x in enumerate((-.68,-.25,.22,.68)):
 color=[amber,cyan,green,red][i]
 for y in (-.29,.32):
  cyl('Sealed sample jar',(x,y,1.27),.14,.32,color)
  cyl('Jar lid',(x,y,1.45),.155,.045,dark)
  box('Sample label',(x,y-.143,1.27),(.17,.012,.07),white,.005)
box('Header panel',(0,-.38,2.07),(1.76,.14,.32),dark,.03)
for i in range(8):box('Amber header marker',(-.75+i*.21,-.458,2.07),(.11,.012,.06),amber,.005)
finish('substance_storage')

# Formula board: a workbench with framed display and tactile formula tiles.
reset()
box('Formula plinth',(0,0,.08),(2.25,1.30,.16),concrete,.07)
for x in (-.88,.88):box('Bench leg',(x,.1,.62),(.17,.7,1.09),steel)
box('Bench top',(0,-.05,1.15),(2.05,1.05,.13),wood,.045)
box('Raised board frame',(0,.37,1.78),(1.88,.18,1.27),steel,.065)
box('Deep display',(0,.26,1.79),(1.63,.05,1.04),dark,.025)
for i,x in enumerate((-.55,-.2,.15,.50)):
 box('Magnetic formula tile',(x,.205,1.94),(.28,.05,.28),white,.025)
 box('Formula glyph',(x,.172,1.94),(.09,.018,.15),cyan if i%2==0 else amber,.008)
for i,x in enumerate((-.53,-.18,.17,.52)):
 box('Formula tray tile',(x,-.39,1.26),(.25,.25,.09),cyan if i%2==0 else amber,.018)
box('Side instrument',(1.1,.13,1.5),(.2,.45,.63),steel,.035)
finish('formula_board')

# Periodic terminal: central instrument body, gridded display, tactile controls.
reset()
box('Terminal foundation',(0,0,.08),(2.25,1.30,.16),concrete,.07)
box('Instrument column',(0,.16,.83),(1.16,.79,1.48),steel,.08)
box('Angled console',(0,-.28,1.34),(1.84,.72,.22),dark,.05)
box('Display frame',(0,.22,1.78),(1.79,.19,1.07),steel,.06)
box('Display face',(0,.115,1.78),(1.59,.025,.88),dark,.015)
for row in range(4):
 for col in range(8):
  x=-.69+col*.195
  z=2.07-row*.19
  color=amber if col in (0,7) else cyan if row%2==0 else green
  box('Periodic element', (x,.092,z),(.142,.014,.142),color,.009)
for i,x in enumerate((-.48,-.16,.16,.48)):
 cyl('Console key',(x,-.62,1.49),.07,.04,amber if i==0 else white)
box('Side sample analyzer',(.95,0,.97),(.22,.55,.77),cyan,.035)
finish('periodic_terminal')

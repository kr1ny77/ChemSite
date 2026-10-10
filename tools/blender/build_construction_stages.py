"""Five earned additions to the accepted, editable ChemSite shell.
Contract: retain the grid and ground routes; upper cutaway teaching section with
bevelled slabs, staggered masonry, fitted window frames and supported seam roof.
All additions are above the inaccessible upper floor. Batch by stage/material.
"""
from pathlib import Path
import bpy
ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'tools/blender/source'
OUTPUT=ROOT/'assets/models/environment/construction_stages.glb'
bpy.ops.wm.open_mainfile(filepath=str(SOURCE/'construction_shell.blend'))

stages=[]
for index in range(6):
 obj=bpy.data.objects.new(f'Stage{index}',None)
 bpy.context.collection.objects.link(obj)
 stages.append(obj)
temporary=[]
for name in ['TemporaryRearRail','TemporaryFormwork']:
 obj=bpy.data.objects.new(name,None);bpy.context.collection.objects.link(obj);obj.parent=stages[0];temporary.append(obj)
for obj in list(bpy.data.objects):
 if obj.type=='MESH':
  owner=stages[0]
  if obj.name.startswith(('safety rail post','rail post base','slab edge rail','slab edge toe board')): owner=temporary[0]
  if obj.name.startswith(('front beam form board','form board cleat','shoring post','shoring foot','shoring brace')): owner=temporary[1]
  obj.parent=owner

concrete=bpy.data.materials['shell warm cast concrete']
edge=bpy.data.materials['shell concrete aggregate edge']
steel=bpy.data.materials['shell dark painted steel']
amber=bpy.data.materials['shell safety amber']

def material(name,color,roughness=.8,metallic=0):
 m=bpy.data.materials.new(name);m.diffuse_color=(*color,1);m.use_nodes=True
 p=m.node_tree.nodes.get('Principled BSDF');p.inputs['Base Color'].default_value=(*color,1)
 p.inputs['Roughness'].default_value=roughness;p.inputs['Metallic'].default_value=metallic
 return m
brick=material('stage warm sand masonry',(.71,.52,.33))
mortar=material('stage recessed mortar',(.49,.47,.39),.92)
frame=material('stage ivory window metal',(.78,.83,.76),.5,0)
glass=material('stage opaque blue window',(.19,.43,.49),.22,0)
roof=material('stage teal standing seam roof',(.13,.32,.34),.55,0)

def box(stage,name,location,dimensions,surface,bevel=.018):
 bpy.ops.mesh.primitive_cube_add(size=1,location=location)
 o=bpy.context.object;o.name=name;o.dimensions=dimensions
 bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 o.data.materials.append(surface);o.parent=stages[stage]
 if bevel:
  b=o.modifiers.new('finished formed edge','BEVEL');b.width=min(bevel,min(dimensions)*.24);b.segments=3
  o.modifiers.new('weighted corner normals','WEIGHTED_NORMAL')
 return o

# Additions meet the existing slab at its authored joints and bear on the ring.
box(1,'right rear slab',(1.30,.525,2.77),(1.80,1.29,.18),concrete,.035)
box(1,'right slab fascia',(1.30,1.46,2.70),(1.8,.10,.24),edge)
for x in (.68,2.20):
 box(1,'new slab rail post',(x,1.19,3.22),(.06,.06,.79),steel,.012)
 box(1,'new rail foot',(x,1.19,2.86),(.16,.17,.10),amber,.01)
for z in (3.14,3.58): box(1,'new slab edge rail',(1.19,1.19,z),(2.14,.055,.055),amber,.012)
box(2,'front slab',(.11,-.66,2.77),(4.18,1.02,.18),concrete,.035)
box(2,'left slab closure',(-2.20,-1.13,2.77),(.44,.08,.18),concrete,.015)
for x in (-1.4,-.4,.6,1.6): box(2,'cast slab expansion joint',(x,-.66,2.872),(.014,.90,.006),edge,0)

# Cut staggered brick courses around an actual window opening, including returns.
def masonry(stage,side):
 lo,hi=(-2.22,.16) if side=='rear' else (-1.10,1.14)
 opening=(-1.56,-.60) if side=='rear' else (-.55,.35)
 for row in range(8):
  z0=2.88+row*.20;z1=z0+.18
  cursor=lo-(.225 if row%2 else 0)
  while cursor<hi:
   left=max(lo,cursor);right=min(hi,cursor+.43)
   segments=[(left,right)]
   if z0<4.08 and z1>3.38:
    segments=[(left,min(right,opening[0])),(max(left,opening[1]),right)]
   for a,b in segments:
    if b-a>.025:
     loc=((a+b)/2,1.33,(z0+z1)/2) if side=='rear' else (-2.31,(a+b)/2,(z0+z1)/2)
     dims=(b-a,.18,.18) if side=='rear' else (.18,b-a,.18)
     box(stage,side+' staggered masonry',loc,dims,brick,.009)
   cursor+=.45
 # Recessed mortar bands share the same void; fitted jambs/sill/lintel frame it.
 for row in range(9):
  z=2.87+row*.20
  bands=[(lo,hi)] if not 3.38<z<4.08 else [(lo,opening[0]),(opening[1],hi)]
  for a,b in bands:
   loc=((a+b)/2,1.33,z) if side=='rear' else (-2.31,(a+b)/2,z)
   dims=(b-a,.15,.02) if side=='rear' else (.15,b-a,.02)
   box(stage,side+' mortar bed',loc,dims,mortar,.003)
 mid=sum(opening)/2;width=opening[1]-opening[0]
 for z,name in [(3.38,'window sill'),(4.08,'window lintel')]:
  loc=(mid,1.33,z) if side=='rear' else (-2.31,mid,z)
  dims=(width+.12,.25,.08) if side=='rear' else (.25,width+.12,.08)
  box(stage,side+' '+name,loc,dims,frame)
 for a in opening:
  loc=(a,1.33,3.73) if side=='rear' else (-2.31,a,3.73)
  dims=(.06,.20,.70) if side=='rear' else (.20,.06,.70)
  box(stage,side+' window jamb',loc,dims,frame,.01)
 loc=(mid,1.33,3.73) if side=='rear' else (-2.31,mid,3.73)
 dims=(width-.08,.055,.61) if side=='rear' else (.055,width-.08,.61)
 box(stage,side+' glazed pane',loc,dims,glass,.008)
 dims=(.035,.08,.61) if side=='rear' else (.08,.035,.61)
 box(stage,side+' window mullion',loc,dims,frame,.006)

masonry(3,'rear');masonry(4,'side')
# Two front bearings support the open inspection cutaway; the masonry bears rear.
for x in (-2.23,.18):
 box(5,'upper front roof column',(x,-1.09,3.67),(.16,.16,1.62),steel,.02)
 box(5,'upper column footing',(x,-1.09,2.92),(.24,.24,.10),edge)
for y in (-1.09,1.33): box(5,'roof bearing beam',(-1.025,y,4.49),(2.68,.16,.18),steel)
box(5,'finished seam roof',(-1.025,.12,4.65),(2.85,2.75,.14),roof,.03)
for x in (-2.25,-1.75,-1.25,-.75,-.25,.20):
 box(5,'standing roof seam',(x,.12,4.736),(.028,2.60,.035),roof,.006)
box(5,'front roof fascia',(-1.025,-1.275,4.62),(2.86,.045,.18),frame,.012)
box(5,'roof rain gutter',(-1.025,1.525,4.58),(2.83,.09,.08),steel,.01)

for obj in list(bpy.data.objects):
 if obj.type=='MESH':
  bpy.context.view_layer.objects.active=obj
  for modifier in list(obj.modifiers): bpy.ops.object.modifier_apply(modifier=modifier.name)
# Editable named parts remain in the source. Export alone batches each stage.
bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE/'construction_stages.blend'))
for parent in stages+temporary:
 for surface in list(bpy.data.materials):
  pieces=[o for o in bpy.data.objects if o.type=='MESH' and o.parent==parent and o.data.materials and o.data.materials[0]==surface]
  if not pieces: continue
  bpy.ops.object.select_all(action='DESELECT')
  for o in pieces: o.select_set(True)
  bpy.context.view_layer.objects.active=pieces[0]
  if len(pieces)>1: bpy.ops.object.join()
  bpy.context.object.name=f'{parent.name} {surface.name}'
bpy.ops.export_scene.gltf(filepath=str(OUTPUT),export_format='GLB',export_apply=True)
print('CONSTRUCTION_STAGES_EXPORT',OUTPUT)

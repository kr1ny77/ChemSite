"""Original rounded construction student; candidate export before art acceptance."""
import bpy
import math
from pathlib import Path
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'artifacts/cartoon-character'
OUT.mkdir(parents=True, exist_ok=True)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)

def material(name, color, roughness=.48):
    m = bpy.data.materials.new(name)
    m.diffuse_color = (*color, 1)
    m.use_nodes = True
    shader = m.node_tree.nodes.get('Principled BSDF')
    shader.inputs['Base Color'].default_value = (*color, 1)
    shader.inputs['Roughness'].default_value = roughness
    return m

skin = material('Warm peach skin', (.72,.39,.21))
navy = material('Deep blue workwear', (.035,.12,.23))
orange = material('Orange safety vest', (.95,.22,.025))
yellow = material('Golden hardhat', (1,.62,.025), .32)
cream = material('Reflective cream', (.95,.94,.72))
dark = material('Soft dark brown', (.065,.028,.012))
bootmat = material('Charcoal boot leather', (.045,.065,.085))
white = material('Eye sparkle', (1,.94,.82), .25)

parts = []
def ellipsoid(name, loc, scale, mat, segments=24, rings=16):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segments, ring_count=rings, location=loc)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(mat)
    for face in obj.data.polygons: face.use_smooth = True
    parts.append(obj)
    return obj

def rounded(name,loc,size,mat,radius):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    obj=bpy.context.object; obj.name=name; obj.dimensions=size
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    obj.data.materials.append(mat)
    bevel=obj.modifiers.new('Rounded silhouette','BEVEL'); bevel.width=radius; bevel.segments=6
    bpy.ops.object.modifier_apply(modifier=bevel.name)
    for face in obj.data.polygons: face.use_smooth=True
    normal=obj.modifiers.new('Surface normals','WEIGHTED_NORMAL')
    bpy.ops.object.modifier_apply(modifier=normal.name)
    parts.append(obj)
    return obj

def curve(name, points, radius, mat):
    data=bpy.data.curves.new(name,'CURVE'); data.dimensions='3D'
    data.bevel_depth=radius; data.bevel_resolution=2
    spline=data.splines.new('POLY'); spline.points.add(len(points)-1)
    for p,co in zip(spline.points,points): p.co=(*co,1)
    obj=bpy.data.objects.new(name,data); bpy.context.collection.objects.link(obj)
    obj.data.materials.append(mat); bpy.context.view_layer.objects.active=obj
    obj.select_set(True); bpy.ops.object.convert(target='MESH'); obj.select_set(False)
    parts.append(obj)
    return obj

# Connected workwear surface: round seat, short legs, sleeves and shoulder transitions.
body_parts=[ellipsoid('Workwear body',(0,0,.65),(.34,.235,.33),navy)]
for side in (-1,1):
    body_parts.append(ellipsoid('Short trouser',(.17*side,0,.30),(.14,.15,.24),navy))
    body_parts.append(ellipsoid('Relaxed sleeve',(.34*side,0,.67),(.135,.15,.24),navy))
bpy.ops.object.select_all(action='DESELECT')
for obj in body_parts: obj.select_set(True)
bpy.context.view_layer.objects.active=body_parts[0]
bpy.ops.object.join(); body=bpy.context.object; body.name='Continuous workwear'
remesh=body.modifiers.new('Continuous garment topology','REMESH'); remesh.mode='VOXEL'; remesh.voxel_size=.017
bpy.ops.object.modifier_apply(modifier=remesh.name)
smooth=body.modifiers.new('Soft garment transitions','SMOOTH'); smooth.factor=.65; smooth.iterations=5
bpy.ops.object.modifier_apply(modifier=smooth.name)
decimate=body.modifiers.new('Runtime garment budget','DECIMATE'); decimate.ratio=.40
bpy.ops.object.modifier_apply(modifier=decimate.name)
for face in body.data.polygons: face.use_smooth=True
parts=[obj for obj in bpy.data.objects if obj.type=='MESH']
# Fitted vest is a shaped open-bottom shell rather than an inflated box.
verts=[]; faces=[]
profiles=[(.43,.305,.222),(.48,.345,.247),(.68,.365,.262),(.82,.312,.224),(.88,.235,.18)]
for z,rx,ry in profiles:
    for i in range(48):
        a=2*math.pi*i/48; verts.append((rx*math.cos(a),ry*math.sin(a),z))
for j in range(len(profiles)-1):
    for i in range(48):
        k=j*48+i; n=j*48+(i+1)%48; faces.append((k,n,n+48,k+48))
mesh=bpy.data.meshes.new('Tailored vest surface');mesh.from_pydata(verts,[],faces);mesh.update()
vest=bpy.data.objects.new('Safety vest',mesh);bpy.context.collection.objects.link(vest);vest.data.materials.append(orange)
bpy.context.view_layer.objects.active=vest
solid=vest.modifiers.new('Cloth thickness','SOLIDIFY');solid.thickness=.012
bpy.ops.object.modifier_apply(modifier=solid.name)
sub=vest.modifiers.new('Rounded cloth','SUBSURF');sub.levels=1
bpy.ops.object.modifier_apply(modifier=sub.name)
for face in vest.data.polygons:face.use_smooth=True
parts.append(vest)
# Wrap reflective band follows the fitted waist.
curve('Reflective waist',[(.339*math.cos(2*math.pi*i/96),.245*math.sin(2*math.pi*i/96),.515) for i in range(97)],.019,cream)
for side in (-1,1):
    curve('Shoulder reflective strip',[(side*.15,-.215,.55),(side*.15,-.232,.68),(side*.15,-.203,.80),(side*.15,-.13,.865)],.016,cream)
    ellipsoid('Hand '+str(side),(side*.405,-.03,.455),(.10,.09,.13),skin)
    ellipsoid('Thumb '+str(side),(side*.35,-.10,.47),(.046,.055,.07),skin)
    rounded('Boot '+str(side),(side*.17,-.045,.09),(.255,.34,.18),bootmat,.078)
    rounded('Sole '+str(side),(side*.17,-.045,.0225),(.26,.345,.045),dark,.02)
ellipsoid('Neck',(0,0,.89),(.11,.10,.10),skin)
rounded('Head',(0,-.025,1.16),(.73,.59,.63),skin,.245)
for side in (-1,1):
    ellipsoid('Ear '+str(side),(side*.36,-.025,1.13),(.07,.07,.10),skin)
    ellipsoid('Eye '+str(side),(side*.13,-.321,1.19),(.047,.024,.062),dark)
    ellipsoid('Eye highlight '+str(side),(side*.13-.01,-.343,1.21),(.012,.009,.015),white,16,12)
    brow=rounded('Eyebrow '+str(side),(side*.135,-.315,1.295),(.12,.035,.039),dark,.012)
    brow.rotation_euler.y=side*.12
ellipsoid('Round nose',(0,-.347,1.15),(.073,.073,.067),skin)
curve('Friendly smile',[(.13*t,-.324-.008*(1-t*t),1.057+.028*t*t) for t in [i/10 for i in range(-10,11)]],.010,dark)
# Fitted hardhat crown with a real dome and curved brim.
verts=[];faces=[]
for j in range(17):
    phi=(j+.15)/16.15*math.pi/2
    for i in range(64):
        theta=2*math.pi*i/64
        verts.append((.405*math.sin(phi)*math.cos(theta),.335*math.sin(phi)*math.sin(theta),1.40+.20*math.cos(phi)))
for j in range(16):
    for i in range(64):
        k=j*64+i;n=j*64+(i+1)%64;faces.append((k,n,n+64,k+64))
mesh=bpy.data.meshes.new('Hardhat dome');mesh.from_pydata(verts,[],faces);mesh.update()
cap=bpy.data.objects.new('Hardhat crown',mesh);bpy.context.collection.objects.link(cap);cap.data.materials.append(yellow)
for face in mesh.polygons:face.use_smooth=True
parts.append(cap)
ellipsoid('Hardhat brim',(0,-.045,1.407),(.445,.40,.026),yellow)
curve('Hardhat ridge',[(0,-.30*math.cos(a),1.40+.205*math.sin(a)) for a in [math.pi*i/32 for i in range(33)]],.016,yellow)
# Tailored details are built against the clothing surface and retain semantic skinning.
cloth_edge=material('Vest seam ochre',(.48,.09,.012),.7)
steel=material('Zipper and fasteners',(.24,.29,.32),.34)
hair=material('Sculpted chestnut hair',(.12,.045,.015),.65)
sole_edge=material('Boot rubber welt',(.09,.10,.11),.8)

def front_surface(x,z,clearance=.012):
    z=max(profiles[0][0],min(profiles[-1][0],z))
    for (z0,rx0,ry0),(z1,rx1,ry1) in zip(profiles,profiles[1:]):
        if z0<=z<=z1:
            t=(z-z0)/(z1-z0);rx=rx0+(rx1-rx0)*t;ry=ry0+(ry1-ry0)*t
            return -ry*math.sqrt(max(0,1-(x/rx)**2))-clearance
    return -.20

def fitted_panel(name,x0,x1,z0,z1,mat):
    vertices=[];faces=[]
    for row in range(5):
        z=z0+(z1-z0)*row/4
        for column in range(7):
            x=x0+(x1-x0)*column/6
            vertices.append((x,front_surface(x,z,.020),z))
    for row in range(4):
        for column in range(6):
            k=row*7+column;faces.append((k,k+7,k+8,k+1))
    mesh=bpy.data.meshes.new(name);mesh.from_pydata(vertices,[],faces);mesh.update()
    obj=bpy.data.objects.new(name,mesh);bpy.context.collection.objects.link(obj);obj.data.materials.append(mat)
    bpy.context.view_layer.objects.active=obj
    solid=obj.modifiers.new('Sewn panel thickness','SOLIDIFY');solid.thickness=.009
    bpy.ops.object.modifier_apply(modifier=solid.name)
    for face in obj.data.polygons:face.use_smooth=True
    parts.append(obj)
    return obj

curve('Vest front fastening',[(0,front_surface(0,z,.022),z) for z in [.53+i*.014 for i in range(23)]],.008,cloth_edge)
for side in (-1,1):
    x=side*.185
    fitted_panel('Vest pocket '+str(side),x-.055,x+.055,.58,.685,orange)
    fitted_panel('Vest pocket flap '+str(side),x-.06,x+.06,.678,.712,cloth_edge)
    curve('Vest pocket stitching '+str(side),[(x-.047,front_surface(x-.047,.595,.030),.595),(x+.047,front_surface(x+.047,.595,.030),.595)],.003,cream)
    rounded('Vest pocket button '+str(side),(x,front_surface(x,.695,.034),.695),(.025,.013,.022),steel,.004)
    curve('Collar '+str(side),[(side*.025,-.182,.89),(side*.08,-.195,.86),(side*.14,-.18,.88)],.019,navy)
    # Shaped toe and heel piping replace the plain smooth boot silhouette.
    curve('Boot welt '+str(side),[(side*.17+.121*math.cos(2*math.pi*i/48),-.045+.158*math.sin(2*math.pi*i/48),.053) for i in range(49)],.006,sole_edge)
    curve('Boot toe seam '+str(side),[(side*.17+.085*t,-.157-.032*(1-t*t),.12+.011*(1-t*t)) for t in [i/8 for i in range(-8,9)]],.004,sole_edge)
    for row in range(3):
        curve('Boot lace '+str(side)+' '+str(row),[(side*.17-.037,-.08-row*.023,.177-row*.006),(side*.17+.037,-.08-row*.023,.177-row*.006)],.004,cream)
    curve('Hand crease '+str(side),[(side*.405+side*.055,-.103,.443),(side*.405+side*.045,-.11,.427)],.003,cloth_edge)
    curve('Ear inner rim '+str(side),[(side*.392,-.074,1.10),(side*.41,-.08,1.14),(side*.394,-.074,1.17)],.007,cloth_edge)
# A fitted hair shell with an intentional uneven hairline and temple points.
vertices=[];faces=[]
for row in range(5):
    for i in range(64):
        a=2*math.pi*i/64
        lower=1.29+.024*math.cos(a*3)-.05*abs(math.cos(a))
        z=lower+(1.414-lower)*row/4
        vertices.append((.359*math.cos(a),-.025+.282*math.sin(a),z))
for row in range(4):
    for i in range(64):
        k=row*64+i;n=row*64+(i+1)%64;faces.append((k,n,n+64,k+64))
mesh=bpy.data.meshes.new('Hairline sculpt');mesh.from_pydata(vertices,[],faces);mesh.update()
obj=bpy.data.objects.new('Head hair shell',mesh);bpy.context.collection.objects.link(obj);obj.data.materials.append(hair)
bpy.context.view_layer.objects.active=obj
solid=obj.modifiers.new('Hair shell thickness','SOLIDIFY');solid.thickness=.012
bpy.ops.object.modifier_apply(modifier=solid.name)
for face in mesh.polygons:face.use_smooth=True
parts.append(obj)
# Three beveled crown ribs and fitted side ventilation grooves mark a construction hardhat.
for side in (-1,1):
    curve('Hardhat reinforcing rib '+str(side),[(side*.135,-.26*math.cos(a),1.40+.184*math.sin(a)) for a in [math.pi*i/24 for i in range(25)]],.010,yellow)
    for i in range(3):
        y=-.065+i*.045
        x=side*.405*math.sqrt(max(0,1-(y/.335)**2))
        rounded('Hardhat vent '+str(side)+' '+str(i),(x,y,1.44),(.012,.025,.010),cloth_edge,.003)
rounded('Hardhat front badge',(0,-.331,1.449),(.11,.014,.052),navy,.004)
curve('Hardhat badge mark',[(0,-.345,1.462),(0,-.345,1.439),(.027,-.345,1.439)],.005,cream)
# Semantic joints retain stable names for native animation integration.
bpy.ops.object.select_all(action='DESELECT')
bpy.ops.object.armature_add(enter_editmode=True)
rig=bpy.context.object;rig.name='CartoonChemistRig'
rig.data.edit_bones.remove(rig.data.edit_bones[0])
def bone(name,head,tail,parent=None):
    b=rig.data.edit_bones.new(name);b.head=head;b.tail=tail
    if parent:b.parent=rig.data.edit_bones[parent]
    return b
bone('pelvis',(0,0,.38),(0,0,.57))
bone('spine_03',(0,0,.57),(0,0,.88),'pelvis')
bone('head',(0,0,.88),(0,0,1.43),'spine_03')
for side,label in ((1,'l'),(-1,'r')):
    bone('thigh_'+label,(side*.17,0,.38),(side*.17,0,.23),'pelvis')
    bone('calf_'+label,(side*.17,0,.23),(side*.17,0,.09),'thigh_'+label)
    bone('foot_'+label,(side*.17,0,.09),(side*.17,-.15,.09),'calf_'+label)
    bone('upperarm_'+label,(side*.32,0,.80),(side*.395,0,.58),'spine_03')
    bone('lowerarm_'+label,(side*.395,0,.58),(side*.405,0,.455),'upperarm_'+label)
    bone('hand_'+label,(side*.405,0,.455),(side*.405,0,.35),'lowerarm_'+label)
bpy.ops.object.mode_set(mode='OBJECT')
def segment_distance(point,b):
    v=b.tail_local-b.head_local
    t=max(0,min(1,(point-b.head_local).dot(v)/v.length_squared))
    return (point-b.head_local-t*v).length
head_prefix=('Head','Ear','Eye','Round nose','Friendly smile','Hardhat')
for obj in parts:
    groups={b.name:obj.vertex_groups.new(name=b.name) for b in rig.data.bones}
    for v in obj.data.vertices:
        co=obj.matrix_world @ v.co
        side='l' if co.x>0 else 'r'
        if obj.name.startswith(head_prefix): weights={'head':1}
        elif obj.name.startswith(('Boot','Sole')):weights={'foot_'+side:1}
        elif obj.name.startswith(('Hand','Thumb')):weights={'hand_'+side:1}
        elif obj.name.startswith(('Safety vest','Reflective','Shoulder')):weights={'spine_03':1}
        else:
            if co.z<.48:
                t=max(0,min(1,(co.z-.30)/.18)); seat=t*t*(3-2*t)
                t=max(0,min(1,(co.z-.15)/.13)); upper=t*t*(3-2*t)
                weights={'pelvis':seat,'thigh_'+side:(1-seat)*upper,'calf_'+side:(1-seat)*(1-upper)}
                for name,value in weights.items():groups[name].add([v.index],value,'REPLACE')
                continue
            elif abs(co.x)>.285 and co.z>.43:
                names=['spine_03','upperarm_'+side,'lowerarm_'+side]
            else:names=['pelvis','spine_03']
            scores={name:1/(.018+segment_distance(co,rig.data.bones[name]))**4 for name in names}
            total=sum(scores.values());weights={name:value/total for name,value in scores.items()}
        for name,value in weights.items():groups[name].add([v.index],value,'REPLACE')
    obj.parent=rig
    mod=obj.modifiers.new('Cartoon skeletal deformation','ARMATURE');mod.object=rig

from mathutils import Quaternion
rig.animation_data_create()
def key(frame,rotations,root_location=(0,0,0)):
    for pb in rig.pose.bones:
        rest=pb.bone.matrix_local.to_quaternion()
        angle=rotations.get(pb.name,0)
        pb.rotation_mode='QUATERNION'
        pb.rotation_quaternion=rest.inverted() @ Quaternion(Vector((1,0,0)),angle) @ rest
        pb.keyframe_insert('rotation_quaternion',frame=frame,group=pb.name)
        pb.location=rest.inverted() @ Vector(root_location) if pb.name=='pelvis' else Vector((0,0,0))
        pb.keyframe_insert('location',frame=frame,group=pb.name)
def finish(clip,last):
    clip.use_fake_user=True
    rig.animation_data.action=None
    track=rig.animation_data.nla_tracks.new();track.name=clip.name
    track.strips.new(clip.name,1,clip);track.mute=True

def leg_angles(y,z):
    # Two-link sagittal IK places the ankle on its explicit stance/swing path.
    a=.15;b=.14;d=math.sqrt(y*y+z*z)
    d=min(a+b-.0001,max(abs(a-b)+.0001,d))
    knee=math.pi-math.acos(max(-1,min(1,(a*a+b*b-d*d)/(2*a*b))))
    hip=math.atan2(y,z)-math.acos(max(-1,min(1,(a*a+d*d-b*b)/(2*a*d))))
    return hip,knee,-hip-knee
bpy.context.scene.render.fps=384
for name,duration in [('Idle',1.5),('Walk',.64),('Run',.48),('Turn',.5),('Interact',.7),('PickUp',.7),('UseStation',.8),('Celebrate',1.0),('Failure',.85)]:
    clip=bpy.data.actions.new(name);rig.animation_data.action=clip
    last=round(duration*384)+1
    for frame in range(1,last+1):
        phase=(frame-1)/(last-1);rot={};offset=(0,0,0)
        if name in ('Walk','Run'):
            running=name=='Run'
            stride=.10 if running else .08
            lift=.065 if running else .055
            support=.20 if running else .50
            ground_distance=.26 if running else .275
            flight=0.0
            if running:
                half=(phase-.25)% .5
                if half>support:
                    flight=.018*math.sin(math.pi*(half-support)/(.5-support))**2
            offset=(0,0,ground_distance-.29+flight)
            for label,shift in [('l',0),('r',.5)]:
                p=(phase-.25+shift)%1
                if p<support:
                    y=-stride+2*stride*p/support
                    z=ground_distance+flight
                else:
                    t=(p-support)/(1-support)
                    # Smooth forward transfer, with a visible toe clearance.
                    y=stride*math.cos(math.pi*t)
                    z=ground_distance+flight-lift*math.sin(math.pi*t)**2
                hip,knee,ankle=leg_angles(y,z)
                rot.update({'thigh_'+label:hip,'calf_'+label:knee,'foot_'+label:ankle})
                rot['upperarm_'+label]=-.36*math.sin(2*math.pi*(phase+shift))
                rot['lowerarm_'+label]=-.18 if running else -.10
            rot['spine_03']=.035*math.sin(2*math.pi*phase)
            rot['head']=-.018*math.sin(2*math.pi*phase)
        elif name in ('Interact','PickUp','UseStation'):
            amount=math.sin(math.pi*phase)**2 if name!='UseStation' else .65+.15*math.sin(2*math.pi*phase)
            rot={'upperarm_r':-.65*amount,'lowerarm_r':-.35*amount}
        elif name=='Celebrate':
            amount=math.sin(math.pi*min(1,phase*1.5)/2)**2
            rot={'upperarm_l':-1.9*amount,'upperarm_r':-1.9*amount,'lowerarm_l':-.2*amount,'lowerarm_r':-.2*amount}
        elif name=='Failure':rot={'head':.08*math.sin(math.pi*phase)**2}
        else:rot={'spine_03':.008*math.sin(2*math.pi*phase)}
        key(frame,rot,offset)
    finish(clip,last)
bpy.context.scene.frame_set(1)
bpy.ops.object.select_all(action='DESELECT')
rig.select_set(True)
for obj in parts:obj.select_set(True)
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'cartoon_chemist.blend'))
bpy.ops.export_scene.gltf(filepath=str(OUT/'cartoon_chemist.glb'),export_format='GLB',use_selection=True,export_apply=True,export_animation_mode='NLA_TRACKS',export_anim_slide_to_zero=True)
print('CHEMSITE_CARTOON_RIG_CANDIDATE',OUT)

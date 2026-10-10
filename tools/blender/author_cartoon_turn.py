"""Author two planted stepping-turn candidates from the accepted character source."""
import bpy, math, json
from pathlib import Path
from mathutils import Vector, Matrix, Quaternion
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'artifacts/cartoon-turn-candidate'
OUT.mkdir(parents=True,exist_ok=True)
bpy.ops.wm.open_mainfile(filepath=str(ROOT/'tools/blender/source/cartoon_chemist.blend'))
rig=next(o for o in bpy.data.objects if o.type=='ARMATURE')
scene=bpy.context.scene
scene.render.fps=384
frames=291
rest={b.name:b.matrix_local.copy() for b in rig.data.bones}
original_actions=[a.name for a in bpy.data.actions]

def eased(t):return t*t*(3-2*t)
def rotation(a):return Matrix.Rotation(a,4,'Z')
def leg(side,target,heading):
    hip=rig.pose.bones['thigh_'+side]
    knee=rig.pose.bones['calf_'+side]
    foot=rig.pose.bones['foot_'+side]
    origin=hip.matrix.translation.copy()
    delta=target-origin
    a=rig.data.bones[hip.name].length;b=rig.data.bones[knee.name].length
    d=delta.length
    assert abs(a-b)<d<=a+b+1e-5, (side,d,a+b)
    axis=delta.normalized()
    pole=Vector((math.sin(heading),-math.cos(heading),0))
    pole=(pole-axis*pole.dot(axis)).normalized()
    along=(a*a-b*b+d*d)/(2*d)
    joint=origin+axis*along+pole*math.sqrt(max(0,a*a-along*along))
    for pb,start,end in [(hip,origin,joint),(knee,joint,target)]:
        direction=(end-start).normalized()
        old=rest[pb.name].to_3x3().col[1].normalized()
        basis=old.rotation_difference(direction).to_matrix().to_4x4()@rest[pb.name]
        basis.translation=start
        pb.matrix=basis
        bpy.context.view_layer.update()
    basis=rotation(heading)@rest[foot.name]
    basis.translation=target
    foot.matrix=basis
    bpy.context.view_layer.update()

checks=[]
for name,sign in [('TurnLeftStep',1),('TurnRightStep',-1)]:
    action=bpy.data.actions.new(name)
    rig.animation_data.action=action
    anchors={'l':Vector((.17,0,.09)),'r':Vector((-.17,0,.09))}
    mid=sign*math.pi/4
    mid_root=anchors['l']-rotation(mid).to_3x3()@Vector((.17,0,.09))
    second_anchor=mid_root+rotation(mid).to_3x3()@anchors['r']
    end_root=second_anchor-rotation(sign*math.pi/2).to_3x3()@anchors['r']
    final_left=end_root+rotation(sign*math.pi/2).to_3x3()@anchors['l']
    previous={};max_support=0.;max_ankle_error=0.
    for frame in range(1,frames+1):
        t=(frame-1)/(frames-1);half=0 if t<.4 else (1 if t<.8 else 2)
        u=t/.4 if half==0 else ((t-.4)/.4 if half==1 else (t-.8)/.2)
        angle=sign*math.pi/4*(half+eased(u)) if half<2 else sign*math.pi/2
        support='r' if half==1 else 'l';swing='l' if half==1 else 'r'
        anchor=anchors['l'] if half==0 else (second_anchor if half==1 else final_left)
        root=anchor-rotation(angle).to_3x3()@anchors[support]
        root.z=-.0002
        for pb in rig.pose.bones:pb.matrix_basis=Matrix.Identity(4)
        pelvis=rotation(angle)@rest['pelvis'];pelvis.translation+=root
        rig.pose.bones['pelvis'].matrix=pelvis
        bpy.context.view_layer.update()
        start=second_anchor if half==2 else anchors[swing]
        end=second_anchor if half==0 else (final_left if half==1 else end_root+rotation(angle).to_3x3()@anchors['r'])
        target=start.lerp(end,eased(u));target.z+=.055*math.sin(math.pi*u)**2
        leg(support,anchor,0 if half==0 else (mid if half==1 else angle))
        leg(swing,target,(angle if half==0 else angle*eased(u)) if half<2 else mid*(1+eased(u)))
        for pb in rig.pose.bones:
            pb.rotation_mode='QUATERNION'
            pb.keyframe_insert('location',frame=frame,group=pb.name)
            pb.keyframe_insert('rotation_quaternion',frame=frame,group=pb.name)
            pb.keyframe_insert('scale',frame=frame,group=pb.name)
        scene.frame_set(frame);bpy.context.view_layer.update()
        actual=rig.pose.bones['foot_'+support].matrix.translation
        max_ankle_error=max(max_ankle_error,(actual-anchor).length)
        if support in previous:max_support=max(max_support,(actual-previous[support]).length)
        previous={support:actual.copy()}
    action.use_fake_user=True
    rig.animation_data.action=None
    track=rig.animation_data.nla_tracks.new();track.name=name
    strip=track.strips.new(name,1,action);track.mute=True
    checks.append({'action':name,'frames':frames,'fps':384,'duration_s':(frames-1)/384,'support_ankle_error_m':max_ankle_error,'support_frame_drift_m':max_support,'root_translation_end':list(end_root)})
rig.animation_data.action=bpy.data.actions['TurnLeftStep'];scene.frame_start=1;scene.frame_end=frames;scene.frame_set(117)
bpy.ops.object.select_all(action='DESELECT')
rig.select_set(True)
for o in bpy.data.objects:
    if o.type=='MESH':o.select_set(True)
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'cartoon_turn.blend'))
rig.animation_data.action=None
bpy.ops.export_scene.gltf(filepath=str(OUT/'cartoon_turn.glb'),export_format='GLB',use_selection=True,export_apply=True,export_animation_mode='NLA_TRACKS',export_anim_slide_to_zero=True)
(OUT/'source_checks.json').write_text(json.dumps({'existing_actions':original_actions,'turns':checks,'scope':'Candidate; root translation/yaw requires native integration and exported sole review.'},indent=2)+'\n')
print('TURN_CANDIDATE_AUTHORED',json.dumps(checks))

"""Compare fresh GLB poses before/after adding the candidate motion root."""
import bpy, json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'artifacts/cartoon-turn-root-candidate'

def inspect(path):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=str(path))
    rig=next(o for o in bpy.data.objects if o.type=='ARMATURE')
    scene=bpy.context.scene;scene.render.fps=384
    meshes={o.name:{'vertices':[tuple(v.co) for v in o.data.vertices],
                    'weights':[[ (o.vertex_groups[g.group].name,g.weight) for g in v.groups] for v in o.data.vertices],
                    'materials':[m.name for m in o.data.materials]} for o in bpy.data.objects if o.type=='MESH'}
    poses={}
    for action in bpy.data.actions:
        rig.animation_data.action=action
        start,end=action.frame_range
        samples=[]
        for n in range(33):
            frame=start+(end-start)*n/32
            scene.frame_set(int(frame),subframe=frame-int(frame));bpy.context.view_layer.update()
            samples.append({b.name:[x for row in (rig.matrix_world@b.matrix) for x in row] for b in rig.pose.bones if b.name!='motion_root'})
        poses[action.name]={'range':[start,end],'samples':samples}
    return meshes,poses

old_meshes,old=inspect(ROOT/'artifacts/cartoon-turn-candidate/cartoon_turn.glb')
new_meshes,new=inspect(OUT/'cartoon_turn.glb')
assert old_meshes.keys()==new_meshes.keys()
vertex_error=0.
for name,before in old_meshes.items():
    after=new_meshes[name]
    assert before['weights']==after['weights'] and before['materials']==after['materials'],name
    assert len(before['vertices'])==len(after['vertices']),name
    vertex_error=max(vertex_error,max(abs(x-y) for a,b in zip(before['vertices'],after['vertices']) for x,y in zip(a,b)))
assert vertex_error<1e-6,vertex_error
assert old.keys()==new.keys(),'Action set changed'
reports=[]
for name,a in old.items():
    b=new[name];assert a['range']==b['range'],(name,a['range'],b['range'])
    error=max(abs(x-y) for before,after in zip(a['samples'],b['samples']) for bone in before for x,y in zip(before[bone],after[bone]))
    assert error<.00001,(name,error)
    reports.append({'action':name,'samples':33,'max_world_bone_matrix_element_error':error,'frame_range':a['range']})
result={'mesh_count':len(old_meshes),'skin_materials_exact':True,'max_vertex_coordinate_error_m':vertex_error,'actions':reports,'scope':'All vertex coordinates within 1e-6; weights/material slots exact; 33 world-bone samples per action within 1e-5. Visual/timing review remains separate.'}
(OUT/'preservation_checks.json').write_text(json.dumps(result,indent=2)+'\n')
print('TURN_MOTION_ROOT_PRESERVED',json.dumps(result))

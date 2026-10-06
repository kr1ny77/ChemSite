"""Fresh-export sole contact and action coverage gate for the cartoon candidate."""
import bpy, json, math
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'artifacts/cartoon-character'
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
bpy.ops.import_scene.gltf(filepath=str(OUT/'cartoon_chemist.glb'))
rig=next(o for o in bpy.data.objects if o.type=='ARMATURE')
soles=[o for o in bpy.data.objects if o.type=='MESH' and o.name.startswith('Sole')]
assert len(soles)==2
sole_sides={o.name:sum((o.matrix_world @ v.co).x for v in o.data.vertices)/len(o.data.vertices) for o in soles}
report={}
for name in ('Idle','Walk','Run','PickUp','Interact','UseStation'):
    clip=next(a for a in bpy.data.actions if a.name==name)
    rig.animation_data.action=clip
    start,end=clip.frame_range
    heights=[];support=[];stance_errors=[]
    for sample in range(193):
        phase=sample/192;f=start+(end-start)*phase
        bpy.context.scene.frame_set(int(f),subframe=f%1)
        values=[]
        for sole in soles:
            obj=sole.evaluated_get(bpy.context.evaluated_depsgraph_get());mesh=obj.to_mesh()
            minimum=min((obj.matrix_world @ v.co).z for v in mesh.vertices)
            obj.to_mesh_clear();values.append(minimum)
        heights.extend(values)
        expected=[]
        for sole in soles:
            # Mesh side is established from the world-space bind centroid.
            shift=0 if sole_sides[sole.name]>0 else .5
            p=(phase-.25+shift)%1
            stance=.20 if name=='Run' else .50
            lift=.065 if name=='Run' else .055
            clearance=0 if p<stance else lift*math.sin(math.pi*(p-stance)/(1-stance))**2
            expected.append(clearance if name in ('Walk','Run') else 0)
        support.append(abs(min(values)-min(expected)))
        stance_errors.extend(abs(value-target) for value,target in zip(values,expected))
    report[name]={'minimum_sole':min(heights),'maximum_support_error':max(support),'maximum_per_foot_profile_error':max(stance_errors),'samples':193,'duration':(end-start)/24}
    assert min(heights)>-.002,(name,'penetration',min(heights))
    assert report[name]['maximum_per_foot_profile_error']<.002,(name,'ground support',report[name])
    if name in ('Walk','Run'):
        duration=(end-start)/24
        stance=.20 if name=='Run' else .50
        stride=.10 if name=='Run' else .08
        speed=2*stride/(stance*duration)
        residuals=[]
        for sole in soles:
            anchor=.25 if sole_sides[sole.name]>0 else .75
            ys=[]
            for sample in range(105):
                phase=anchor+stance*sample/104
                f=start+(end-start)*(phase%1)
                bpy.context.scene.frame_set(int(f),subframe=f%1)
                obj=sole.evaluated_get(bpy.context.evaluated_depsgraph_get());mesh=obj.to_mesh()
                y=sum((obj.matrix_world @ v.co).y for v in mesh.vertices)/len(mesh.vertices)
                obj.to_mesh_clear()
                ys.append(y-speed*(phase-anchor)*duration)
            residuals.append(max(ys)-min(ys))
        report[name]['nominal_speed']=speed
        report[name]['stance_horizontal_residual']=max(residuals)
        assert max(residuals)<.004,(name,'stance drift',residuals)
(OUT/'contact-report.json').write_text(json.dumps(report,indent=2))
print('CHEMSITE_CARTOON_CONTACT_OK',json.dumps(report))

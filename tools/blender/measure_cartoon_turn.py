"""Fresh GLB actual supporting-sole validation for turn candidates."""
import bpy,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'artifacts/cartoon-turn-candidate'
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
bpy.ops.import_scene.gltf(filepath=str(OUT/'cartoon_turn.glb'))
rig=next(o for o in bpy.data.objects if o.type=='ARMATURE')
soles={s:bpy.data.objects['Sole '+('1' if s=='l' else '-1')] for s in ['l','r']}
scene=bpy.context.scene
results=[]
for name in ['TurnLeftStep','TurnRightStep']:
    action=bpy.data.actions[name];rig.animation_data.action=action
    end=action.frame_range[1]
    scene.frame_set(0);bpy.context.view_layer.update()
    indices={}
    for side,obj in soles.items():
        evaluated=obj.evaluated_get(bpy.context.evaluated_depsgraph_get())
        points=[evaluated.matrix_world@v.co for v in evaluated.data.vertices]
        low=min(v.z for v in points)
        indices[side]=[i for i,v in enumerate(points) if v.z<low+.0001]
        assert indices[side]
    previous={};drift=0.;height=0.;count=0
    for n in range(233):
        phase=n/232;f=end*phase;scene.frame_set(int(f),subframe=f-int(f));bpy.context.view_layer.update()
        side='l' if phase<.4 or phase>=.8 else 'r'
        obj=soles[side].evaluated_get(bpy.context.evaluated_depsgraph_get())
        points=[obj.matrix_world@obj.data.vertices[i].co for i in indices[side]]
        height=max(height,max(abs(p.z) for p in points))
        if side in previous:
            drift=max(drift,max((a-b).length for a,b in zip(points,previous[side])))
        previous={side:points};count+=1
    results.append({'action':name,'duration_s':float(end)/scene.render.fps,'support_samples':count,'max_supporting_sole_height_error_m':height,'max_supporting_sole_tick_drift_m':drift})
    assert height<.001 and drift<.001,(name,height,drift)
(OUT/'exported_sole_checks.json').write_text(json.dumps(results,indent=2)+'\n')
print('TURN_EXPORTED_SOLES_OK',json.dumps(results))

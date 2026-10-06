"""Prepare fresh-export pose evidence for belt fit in Run and upright reach."""
import bpy
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'artifacts/cartoon-character'
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
bpy.ops.import_scene.gltf(filepath=str(OUT/'cartoon_chemist.glb'))
rig=next(o for o in bpy.data.objects if o.type=='ARMATURE')
for name,phase in [('Run',.35),('Interact',.5)]:
    action=next(a for a in bpy.data.actions if a.name==name)
    rig.animation_data.action=action
    first,last=action.frame_range
    frame=first+(last-first)*phase
    bpy.context.scene.frame_set(int(frame),subframe=frame%1)
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT/('equipment-'+name.lower()+'.blend')))
print('CHEMSITE_EQUIPMENT_POSES_OK')

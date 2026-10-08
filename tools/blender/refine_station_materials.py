"""Refine durable station .blend sources and export unchanged authored geometry.
Before applying, freeze source/GLB and native matching-camera evidence.
"""
from pathlib import Path
import sys, json
import bpy
sys.path.insert(0,str(Path(__file__).resolve().parent))
from station_material_profiles import profile_values
ROOT=Path(__file__).resolve().parents[2]
reports=[]
(ROOT/'artifacts').mkdir(exist_ok=True)
for asset in sorted((ROOT/'assets/models/stations').glob('*.glb')):
 source=ROOT/'tools/blender/source'/(asset.stem+'.blend')
 bpy.ops.wm.open_mainfile(filepath=str(source))
 used={m for o in bpy.data.objects if o.type=='MESH' for m in o.data.materials if m}
 changed=[]
 for m in used:
  p=m.node_tree.nodes.get('Principled BSDF') if m.use_nodes else None
  if p is None: raise RuntimeError('Missing PBR '+m.name)
  before=(p.inputs['Metallic'].default_value,p.inputs['Roughness'].default_value)
  values=profile_values(m.name,*before)
  p.inputs['Metallic'].default_value,p.inputs['Roughness'].default_value=values
  changed.append({'name':m.name,'before':before,'after':values})
 bpy.ops.wm.save_as_mainfile(filepath=str(source))
 bpy.ops.export_scene.gltf(filepath=str(asset),export_format='GLB',export_apply=True)
 reports.append({'asset':asset.stem,'materials':changed})
(ROOT/'artifacts/station-materials-refinement.json').write_text(json.dumps(reports,indent=2))
print('CHEMSITE_STATION_MATERIAL_REFINEMENT_OK',len(reports))

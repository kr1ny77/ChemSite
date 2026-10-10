"""Refine coatings in editable shell sources; preserve exported geometry bytes."""
from pathlib import Path
import json, struct
import bpy
ROOT=Path(__file__).resolve().parents[2]
PROFILES={
 'shell dark painted steel':(0.0, .62),
 'shell safety amber':(0.0, .62),
 'stage ivory window metal':(0.0, .50),
 'stage opaque blue window':(0.0, .22),
 'stage teal standing seam roof':(0.0, .55),
}
reports=[]
for name in ('construction_shell','construction_stages'):
 source=ROOT/'tools/blender/source'/f'{name}.blend'
 bpy.ops.wm.open_mainfile(filepath=str(source))
 for material in bpy.data.materials:
  if material.name in PROFILES:
   shader=material.node_tree.nodes.get('Principled BSDF')
   assert shader is not None
   shader.inputs['Metallic'].default_value,shader.inputs['Roughness'].default_value=PROFILES[material.name]
 bpy.ops.wm.save_as_mainfile(filepath=str(source))
 asset=ROOT/'assets/models/environment'/f'{name}.glb'
 data=asset.read_bytes();magic,version,length=struct.unpack_from('<III',data)
 assert magic==0x46546c67 and version==2 and length==len(data)
 json_size,kind=struct.unpack_from('<II',data,12);assert kind==0x4e4f534a
 document=json.loads(data[20:20+json_size]);frozen=json.loads(json.dumps(document))
 changed=[]
 for material in document['materials']:
  if material['name'] in PROFILES:
   metal,rough=PROFILES[material['name']]
   pbr=material['pbrMetallicRoughness'];before={k:pbr.get(k) for k in ('metallicFactor','roughnessFactor')}
   pbr['metallicFactor']=metal;pbr['roughnessFactor']=rough
   changed.append({'name':material['name'],'before':before,'after':[metal,rough]})
 # Only material scalar fields change. All geometry/hierarchy/accessors stay exact.
 for key in frozen:
  if key!='materials':assert document[key]==frozen[key]
 encoded=json.dumps(document,separators=(',',':')).encode();encoded+=b' '*((-len(encoded))%4)
 tail=data[20+json_size:]
 updated=struct.pack('<III',magic,version,20+len(encoded)+len(tail))+struct.pack('<II',len(encoded),kind)+encoded+tail
 asset.write_bytes(updated)
 assert asset.read_bytes()[20+len(encoded):]==tail
 reports.append({'asset':name,'materials':changed,'binary_geometry_preserved':True})
(ROOT/'artifacts/shell-materials-refinement.json').write_text(json.dumps(reports,indent=2)+'\n')
print('SHELL_MATERIAL_REFINEMENT_OK',len(reports))

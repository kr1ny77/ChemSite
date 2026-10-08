"""Package selected CC0 Kenney models with their source-specific palette embedded.
Source geometry, accessor data and original buffer-view offsets are preserved.
Run with python3 from any working directory. Local kit licenses remain in docs.
"""
from pathlib import Path
import json, struct, hashlib
ROOT=Path(__file__).resolve().parents[2]
BUILDING={'wall-window-wide-square-detailed','column-wide','stairs-open-short','wall-half'}
DEST=ROOT/'assets/models/construction'
manifest=[]
(ROOT/'artifacts').mkdir(exist_ok=True)
for output in sorted(DEST.glob('*.glb')):
 kit='kenney_building-kit' if output.stem in BUILDING else 'kenney_factory-kit_3.0'
 source=ROOT/'assets-source/kenney'/kit/'Models/GLB format'/output.name
 data=source.read_bytes()
 magic,version,total=struct.unpack_from('<III',data)
 assert magic==0x46546c67 and version==2 and total==len(data)
 n,kind=struct.unpack_from('<II',data,12);assert kind==0x4e4f534a
 doc=json.loads(data[20:20+n]);off=20+n
 bn,kind=struct.unpack_from('<II',data,off);assert kind==0x004e4942
 binary=bytearray(data[off+8:off+8+bn])
 for image in doc.get('images',[]):
  if 'uri' not in image: continue
  image_path=source.parent/image.pop('uri')
  payload=image_path.read_bytes()
  assert payload.startswith(b'\x89PNG\r\n\x1a\n')
  while len(binary)%4:binary.append(0)
  view={'buffer':0,'byteOffset':len(binary),'byteLength':len(payload)}
  image['bufferView']=len(doc.setdefault('bufferViews',[]));doc['bufferViews'].append(view)
  image['mimeType']='image/png';binary.extend(payload)
 doc['buffers'][0]['byteLength']=len(binary)
 while len(binary)%4:binary.append(0)
 encoded=json.dumps(doc,separators=(',',':'),ensure_ascii=False).encode()
 encoded+=b' '*((-len(encoded))%4)
 packed=struct.pack('<III',magic,version,28+len(encoded)+len(binary))+struct.pack('<II',len(encoded),0x4e4f534a)+encoded+struct.pack('<II',len(binary),0x004e4942)+binary
 output.write_bytes(packed)
 manifest.append({'asset':output.name,'kit':kit,'source_sha256':hashlib.sha256(data).hexdigest(),'packaged_sha256':hashlib.sha256(packed).hexdigest()})
(ROOT/'artifacts/construction-asset-packaging.json').write_text(json.dumps(manifest,indent=2))
print('CHEMSITE_CONSTRUCTION_ASSETS_PACKAGED',len(manifest))

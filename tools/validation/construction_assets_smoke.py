"""Independently check packaged palette dependencies and preserved source geometry."""
import json,struct,hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
BUILDING={'wall-window-wide-square-detailed','column-wide','stairs-open-short','wall-half'}
def read(path):
 b=path.read_bytes();n=struct.unpack_from('<I',b,12)[0];j=json.loads(b[20:20+n]);off=20+n;length=struct.unpack_from('<I',b,off)[0]
 return j,b[off+8:off+8+length]
count=0
for path in (ROOT/'assets/models/construction').glob('*.glb'):
 kit='kenney_building-kit' if path.stem in BUILDING else 'kenney_factory-kit_3.0'
 source=ROOT/'assets-source/kenney'/kit/'Models/GLB format'/path.name
 before,old=read(source);after,new=read(path)
 assert new[:len(old)]==old,path
 for section in ['nodes','meshes','accessors','animations','skins','scenes']:
  assert before.get(section)==after.get(section),(path,section)
 for old_view,new_view in zip(before['bufferViews'],after['bufferViews']):assert old_view==new_view,path
 for original,image in zip(before['images'],after['images']):
  assert 'uri' not in image and image['mimeType']=='image/png',path
  view=after['bufferViews'][image['bufferView']];payload=new[view.get('byteOffset',0):view.get('byteOffset',0)+view['byteLength']]
  assert payload==(source.parent/original['uri']).read_bytes(),path
 count+=1
assert count==18,count
for path in (ROOT/'assets/models').rglob('*.glb'):
 doc,_=read(path)
 for image in doc.get('images',[]):
  uri=image.get('uri','')
  assert not uri or uri.startswith('data:') or (path.parent/uri).is_file(),(path,uri)
print('CHEMSITE_CONSTRUCTION_ASSETS_OK',count)

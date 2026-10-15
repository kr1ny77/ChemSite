"""Exercise published task identity preservation under insertion and reordering."""
import json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools/chemistry'))
from course_ids import assign_stable_ids
previous=sum([json.loads(p.read_text()) for p in (ROOT/'data/chemistry/course').glob('level*.json')],[])
registry=json.loads((ROOT/'tools/chemistry/course_id_registry.json').read_text())
registry=assign_stable_ids(previous,previous,registry)
original={task['prompt']:task['id'] for task in previous}
new=json.loads(json.dumps(previous[0]));new['prompt']='Identity insertion negative control'
reordered=[new]+list(reversed(json.loads(json.dumps(previous))))
updated=assign_stable_ids(reordered,previous,registry)
assert all(task['id']==original[task['prompt']] for task in reordered[1:])
assert new['id'] not in original.values()
second=json.loads(json.dumps(new));second['prompt']='Removed IDs remain reserved'
assign_stable_ids([second],[],updated)
assert second['id']!=new['id'] and second['id'] not in original.values()
print(f'STABLE_COURSE_IDS_OK: {len(previous)} preserved, insertion/reorder/reserved-ID controls pass')

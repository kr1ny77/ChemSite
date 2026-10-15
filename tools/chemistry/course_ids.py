"""Persistent authoring identities: additions and reordering preserve published IDs."""
import hashlib,json

def identity(task):
    evidence=task.get('audit')
    payload={'level':task['level'],'moduleId':task['moduleId'],'subtopic':task['subtopic']}
    payload['prompt']=task.get('contentKey', task['prompt'])
    if evidence: payload['evidence']=evidence
    return hashlib.sha256(json.dumps(payload,ensure_ascii=False,sort_keys=True).encode()).hexdigest()

def assign_stable_ids(tasks, previous, registry):
    registry=dict(registry)
    for task in previous:
        key=identity(task)
        if key in registry and registry[key]!=task['id']:
            raise ValueError('Published identity changed ID: '+task['id'])
        registry[key]=task['id']
    used=set(registry.values())
    if len(used)!=len(registry): raise ValueError('Registry reuses a published ID')
    seen=set()
    for task in tasks:
        key=identity(task)
        if key in seen: raise ValueError('Duplicate learning identity: '+task['subtopic'])
        seen.add(key)
        if key not in registry:
            prefix='C'+str(task['level'])+'-'
            number=max([int(value[len(prefix):]) for value in used if value.startswith(prefix)]+[0])+1
            registry[key]=prefix+f'{number:03}'
            used.add(registry[key])
        task['id']=registry[key]
    return registry

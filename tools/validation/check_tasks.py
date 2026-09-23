import json
from pathlib import Path
p=Path(__file__).resolve().parents[2]/'data/chemistry/vertical_slice_tasks.json'
tasks=json.loads(p.read_text())
assert len(tasks)==10
assert len({t['id'] for t in tasks})==len(tasks)
allowed={'substance-storage','formula-board','periodic-table-terminal'}
for task in tasks:
 assert task['reviewStatus']=='verified', task['id']
 assert task['level']==1 and task['points']==100 and 1 <= task['difficulty'] <= 5, task['id']
 assert task['procedural'] is False and task['subtopic'] and task['tags'], task['id']
 assert task['station'] in allowed, task['id']
 assert task['correctAnswer'] in task['options'], task['id']
 assert len(set(task['options']))==len(task['options']), task['id']
 assert all(isinstance(value,str) and value.strip() for value in task['acceptedAnswers']), task['id']
 if task['interactionType']=='formula-builder':
  assert task['tokenOptions'] and all(isinstance(token,str) for token in task['tokenOptions']), task['id']
 for key in ('prompt','explanation','rule','hint'):
  assert task[key].strip(), (task['id'],key)
print('CHEMSITE_TASK_INTEGRITY_OK',len(tasks))

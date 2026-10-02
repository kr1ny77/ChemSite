"""Independent numeric, choice and equilibrium-condition checks for Level 4."""
from __future__ import annotations
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
TASKS={t['id']:t for t in json.loads((ROOT/'data/chemistry/curated_tasks.json').read_text()) if t['level']==4}
DIGITS=str.maketrans('₀₁₂₃₄₅₆₇₈₉⁰¹²³⁴⁵⁶⁷⁸⁹⁺⁻','01234567890123456789+-')
def normalize(value:str)->str:
 return ' '.join(value.translate(DIGITS).replace('^','').casefold().split())
assert len(TASKS)==40
EXPECTED={'L4-127':20-50,'L4-128':-40-(-100)}
for identifier,computed in EXPECTED.items():
 answer=TASKS[identifier]['correctAnswer']
 assert abs(computed-answer['value'])<=answer['absoluteTolerance'],(identifier,computed,answer)
 assert answer.get('unit')=='kJ',identifier
for task in TASKS.values():
 if task['id'] in EXPECTED:continue
 accepted=[task['correctAnswer'],*task.get('acceptedAnswers',[])]
 assert task.get('options') and any(normalize(a) in {normalize(o) for o in task['options']} for a in accepted),task['id']
 assert len(set(task['options']))==len(task['options']),task['id']
for identifier,physical_change in [('L4-141','сжали'),('L4-142','расширили')]:
 prompt=TASKS[identifier]['prompt']
 assert 'постоянной температуре' in prompt and physical_change in prompt,identifier
for task in TASKS.values():
 if task['interactionType'] in {'kinetics-experiment','equilibrium-control','electrochemistry','corrosion-inspection'}:
  runs=task.get('parameters',{}).get('comparisonRuns',[])
  assert len(runs)==2,task['id']
  assert len({run['setting'] for run in runs})==2,task['id']
  assert all(run['observation'].strip() for run in runs),task['id']
assert 'Zn → Zn²⁺ + 2e⁻' in TASKS['L4-149']['prompt']
assert 'Cu²⁺ + 2e⁻ → Cu' in TASKS['L4-150']['prompt']
for identifier in (f'L4-{number}' for number in range(147,153)):
 runs=TASKS[identifier]['parameters']['comparisonRuns']
 assert runs[0]['setting']=='Цинковый электрод' and runs[1]['setting']=='Медный электрод',identifier
 assert 'Zn → Zn²⁺ + 2e⁻' in runs[0]['observation'] and 'Cu²⁺ + 2e⁻ → Cu' in runs[1]['observation'],identifier
 assert 'поступают' in runs[0]['observation'] and 'приходят' in runs[1]['observation'],identifier
for identifier in (f'L4-{number}' for number in range(153,160)):
 runs=TASKS[identifier]['parameters']['comparisonRuns']
 assert len(runs)==2 and all(run['observation'].strip() for run in runs),identifier
print('LEVEL4_AUDIT_OK: 2 Hess calculations, 38 choice tasks, 29 comparisons, equilibrium conditions')

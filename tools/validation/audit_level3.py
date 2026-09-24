"""Independent arithmetic and conservation checks for curated Level 3 tasks."""
from __future__ import annotations

import json
import math
from pathlib import Path
from audit_level2_equations import is_balanced

ROOT = Path(__file__).resolve().parents[2]
TASKS = {task['id']: task for task in json.loads((ROOT/'data/chemistry/curated_tasks.json').read_text()) if task['level'] == 3}
ATOMIC = {'H': 1.008, 'O': 16.00, 'Na': 22.99, 'Ca': 40.08, 'C': 12.01, 'S': 32.06, 'Cl': 35.45}
M = {
 'H2O': 2*ATOMIC['H']+ATOMIC['O'],
 'NaOH': ATOMIC['Na']+ATOMIC['O']+ATOMIC['H'],
 'CaCO3': ATOMIC['Ca']+ATOMIC['C']+3*ATOMIC['O'],
 'H2SO4': 2*ATOMIC['H']+ATOMIC['S']+4*ATOMIC['O'],
 'NaCl': ATOMIC['Na']+ATOMIC['Cl'],
 'CO2': ATOMIC['C']+2*ATOMIC['O'],
}
EXPECTED = {
 'L3-081': M['H2O'], 'L3-082': M['NaOH'], 'L3-083': M['CaCO3'], 'L3-084': M['H2SO4'], 'L3-085': M['NaCl'],
 'L3-086': 18.02/M['H2O'], 'L3-087': 20/M['NaOH'], 'L3-088': 2*M['CO2'], 'L3-089': .25*M['NaCl'], 'L3-090': .1*M['CaCO3'],
 'L3-091': .5/1, 'L3-092': .2/.5, 'L3-093': 2*.25, 'L3-094': .5/1,
 'L3-095': .2*.5*M['NaCl'], 'L3-096': .1*.25*M['NaOH'], 'L3-097': .2*500/1, 'L3-098': 2*50/200,
 'L3-099': 10/(10+90)*100, 'L3-100': 25/200*100,
 'L3-104': -math.log10(1e-4), 'L3-105': -math.log10(1e-2), 'L3-106': 10**(-5), 'L3-108': 10**(5-3),
}
assert len(TASKS) == 40 and len(EXPECTED) == 24
for identifier, expected in EXPECTED.items():
 task = TASKS[identifier]
 answer = task['correctAnswer']
 tolerance = max(answer.get('absoluteTolerance', 0), abs(answer['value'])*answer.get('relativeTolerance', 0))
 assert abs(expected-answer['value']) <= tolerance, (identifier, expected, answer)
 assert answer['value'] > 0 and tolerance >= 0
for identifier in ('L3-109','L3-110','L3-111','L3-112'):
 assert is_balanced(TASKS[identifier]['correctAnswer']), identifier
for task in TASKS.values():
 if task.get('options'):
  accepted = [task['correctAnswer'], *task.get('acceptedAnswers', [])]
  assert any(answer in task['options'] for answer in accepted), task['id']
print('LEVEL3_AUDIT_OK: 24 calculated answers, 4 dissociations, 12 choice tasks')

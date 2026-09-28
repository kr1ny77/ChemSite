"""Independent Level 5 content checks: mass balance, arithmetic, answer controls."""
from __future__ import annotations
import json
from pathlib import Path
from audit_level2_equations import is_balanced

ROOT=Path(__file__).resolve().parents[2]
TASKS={t['id']:t for t in json.loads((ROOT/'data/chemistry/curated_tasks.json').read_text()) if t['level']==5}
DIGITS=str.maketrans('₀₁₂₃₄₅₆₇₈₉⁰¹²³⁴⁵⁶⁷⁸⁹⁺⁻','01234567890123456789+-')
def normalize(value:str)->str:
 return ' '.join(value.translate(DIGITS).replace('^','').casefold().split())

def main()->None:
 assert len(TASKS)==40 and len(set(TASKS))==40
 equations={key:task for key,task in TASKS.items() if task['interactionType']=='equation-completion'}
 assert set(equations)=={'L5-167','L5-168','L5-171'}
 for key,task in equations.items():
  assert 'полное уравнение' in task['prompt'] and is_balanced(task['correctAnswer']),key
 assert TASKS['L5-166']['correctAnswer']=='CaO'
 assert TASKS['L5-169']['correctAnswer']=='CaSO4·2H2O'
 assert TASKS['L5-169']['parameters']['formulaTokens']==['Ca','SO4','·','2H2O']
 assert TASKS['L5-175']['correctAnswer']=='+4'
 assert 2.0+0.5>1.0+1.0 and TASKS['L5-180']['correctAnswer']=='проба A'
 answer=TASKS['L5-196']['correctAnswer']
 assert abs((1.8+1.2)-answer['value'])<=answer['absoluteTolerance'] and answer['unit']=='mmol/L'
 assert 'портландцемент' in TASKS['L5-174']['prompt']
 assert 'вода строительного контура' in TASKS['L5-190']['correctAnswer']
 assert 'обжиг известняка' in TASKS['L5-200']['prompt']
 choices=0
 for key,task in TASKS.items():
  assert task['reviewStatus']=='verified' and len(task['explanation'])>20 and len(task['rule'])>15 and len(task['hint'])>10,key
  if task.get('options'):
   choices+=1
   accepted=[str(task['correctAnswer']),*task.get('acceptedAnswers',[])]
   assert len(set(task['options']))==len(task['options']),key
   assert any(normalize(a)==normalize(o) for a in accepted for o in task['options']),key
 assert choices==34
 print('LEVEL5_AUDIT_OK: 40 tasks, 3 balanced equations, 1 hardness calculation, 34 choices')

if __name__=='__main__':main()

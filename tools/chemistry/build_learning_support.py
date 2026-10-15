"""Regenerate original worked-solution presentation from audited fixed task data.
Run after building/exporting the chemistry bank. Does not alter graded answers.
"""
import json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
steps={}
for task in json.loads((ROOT/'data/chemistry/curated_tasks.json').read_text()):
    audit=task.get('audit',{})
    variables=audit.get('variables'); expression=audit.get('expression')
    if not variables or not expression: continue
    substitute=re.sub(r'\b[A-Za-z_][A-Za-z_0-9]*\b',lambda m:'('+format(variables[m[0]],'.8g')+')' if m[0] in variables else m[0],expression)
    substitute=substitute.replace('**','^').replace('*',' × ').replace('sqrt','√').replace('log10','lg')
    answer=task['correctAnswer']
    result=format(answer['value'],'.8g')+' '+answer.get('unit','')
    steps[task['id']]=[
        'Выберите данные из условия и приведите их к единицам выбранной формулы.',
        'Связь величин: '+task['rule'],
        'Подстановка: '+substitute,
        'Результат: '+result.strip(),
        'Проверьте единицы, знак и приближения, указанные в условии.'
    ]
(ROOT/'data/chemistry/materials/worked_steps.json').write_text(json.dumps(steps,ensure_ascii=False,indent=2)+'\n')
print(f'LEARNING_SUPPORT_OK: {len(steps)} worked calculations')

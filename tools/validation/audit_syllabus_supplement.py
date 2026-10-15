"""Derive supplemental numeric answers from displayed conditions, independent of audit expressions."""
import json, math, re
from collections import Counter
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]

def displayed_answer(task):
    text=task['prompt']; family=task['subtopic']
    if family=='Уравнение Аррениуса':
        Ea=float(re.search(r'Ea=([\d.]+)',text)[1]); R=float(re.search(r'R=([\d.]+)',text)[1])
        t1=float(re.search(r'T1=([\d.]+)',text)[1]); t2=float(re.search(r'T2=([\d.]+)',text)[1])
        assert 'Дж/моль' in text and 'T1=300 К' in text and 'T2=320 К' in text
        # Independently divide two actual rate constants at A=1.
        return math.exp(-Ea/(R*t2))/math.exp(-Ea/(R*t1))
    if family=='Температурный коэффициент':
        gamma=int(re.search(r'γ=(\d+)',text)[1]); delta=int(re.search(r'нагреве на (\d+) К',text)[1])
        result=1
        for _ in range(delta//10): result*=gamma
        return result
    if family=='Повышение температуры кипения':
        b=float(re.search(r'b=([\d.]+)',text)[1]); kb=float(re.search(r'Kb=([\d.]+)',text)[1])
        assert 'неэлектролита' in text and 'i=1' in text and 'неизменном давлении' in text
        return kb*b
    if family=='Газовый объём по стехиометрии':
        mass=float(re.search(r'массой ([\d.]+) г',text)[1]); M=float(re.search(r'M\(CaCO3\)=([\d.]+)',text)[1])
        assert 'CaCO3 → CaO + CO2' in text and 'полностью' in text
        return mass/M*8.314*300/100
    if family=='Идеальный газ':
        n=float(re.search(r'n=([\d.]+)',text)[1]); T=float(re.search(r'T=([\d.]+)',text)[1]); p=float(re.search(r'p=([\d.]+)',text)[1])
        # SI calculation: m³ converted to litres.
        return n*8.314*T/(p*1000)*1000
    raise ValueError(family)

def check(task):
    value=displayed_answer(task)
    assert math.isclose(value,task['correctAnswer']['value'],rel_tol=1e-12), task['id']

def main():
    bank=json.loads((ROOT/'data/chemistry/curated_tasks.json').read_text())
    tasks=[t for t in bank if 'syllabus-supplement' in t.get('tags',[])]
    assert len(tasks)==53
    assert Counter(t['level'] for t in tasks)=={3:32,4:8,5:13}
    numeric=[t for t in tasks if isinstance(t['correctAnswer'],dict)]
    for t in numeric:check(t)
    assert len(numeric)==18
    for t in tasks:
        assert t['sourceRefs'] and t['explanation'] and t['hint'] and t['materialId']
        if t.get('options'):assert len(set(t['options']))==4 and t['correctAnswer'] in t['options']
    from audit_level2_equations import is_balanced,parse_formula
    equations=[t for t in tasks if t['interactionType']=='equation-completion']
    assert len(equations)==3
    for task in equations:
        if task.get('audit',{}).get('polymerMonomer'):
            monomer=task['audit']['polymerMonomer']; repeat=task['audit']['polymerRepeat']
            assert task['correctAnswer']==f'n{monomer} -> {repeat}'
            a,_=parse_formula(monomer.replace('=',''));b,_=parse_formula(repeat[1:-2])
            assert a==b,task['id']
            assert not is_balanced('H2 + O2 -> H2O')
        else:
            assert is_balanced(task['correctAnswer']),task['id']
    for source in numeric:
        mutant=json.loads(json.dumps(source));mutant['correctAnswer']['value']*=1.1
        try:check(mutant)
        except AssertionError:pass
        else:raise AssertionError('Wrong-answer negative control accepted')
    print('SYLLABUS_SUPPLEMENT_AUDIT_OK tasks=53 numeric_from_prompts=18 equations=3 negative_controls=18')
if __name__=='__main__':main()

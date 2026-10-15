"""Validate entire production bank, chemistry invariants and persisted arithmetic evidence."""
import ast, json, math, operator, sys, re
from collections import Counter
from pathlib import Path
from audit_level2_equations import is_balanced, parse_formula
ROOT=Path(__file__).resolve().parents[2]
OPS={ast.Add:operator.add,ast.Sub:operator.sub,ast.Mult:operator.mul,ast.Div:operator.truediv,ast.Pow:operator.pow}
def evaluate(node, variables):
 if isinstance(node,ast.Expression): return evaluate(node.body,variables)
 if isinstance(node,ast.Constant) and type(node.value) in (float,int): return node.value
 if isinstance(node,ast.Name): return variables[node.id]
 if isinstance(node,ast.BinOp): return OPS[type(node.op)](evaluate(node.left,variables),evaluate(node.right,variables))
 if isinstance(node,ast.UnaryOp) and isinstance(node.op,ast.USub): return -evaluate(node.operand,variables)
 if isinstance(node,ast.Call) and isinstance(node.func,ast.Name) and node.func.id in ('sqrt','log10') and len(node.args)==1: return getattr(math,node.func.id)(evaluate(node.args[0],variables))
 raise ValueError(ast.dump(node))
def main():
 production=json.loads((ROOT/'data/chemistry/curated_tasks.json').read_text())
 base=[t for t in production if t['id'].startswith('L')]
 extra=sum([json.loads((ROOT/f'data/chemistry/course/level{l}.json').read_text()) for l in range(1,6)],[])
 tasks=base+extra
 assert production==tasks, "Rebuild the combined production bank"
 assert len(tasks)==1000
 assert len({t['id'] for t in tasks})==1000
 assert len({t['prompt'] for t in extra})==800
 assert set(t['moduleId'] for t in extra)==set(range(1,14))
 assert Counter(t['level'] for t in tasks)=={1:200,2:160,3:240,4:240,5:160}
 allowed={1:{'substance-storage','formula-board','periodic-table-terminal'},2:{'reaction-bench','mixing-station','ionic-reaction-station','inspection-station'},3:{'solution-laboratory','ionic-reaction-station','inspection-station'},4:{'reaction-bench','electrochemistry-station','corrosion-test-rig','inspection-station'},5:{'construction-materials-station','reaction-bench','corrosion-test-rig','inspection-station'}}
 arithmetic=equations=formulas=0
 for t in tasks:
  assert t['station'] in allowed[t['level']],t['id']
  assert t['reviewStatus']=='verified',t['id']
 for t in extra:
  for field in ('prompt','explanation','hint','rule','learningObjective','sourceRefs','tags'): assert t[field],(t['id'],field)
  audit=t.get('audit',{})
  ans=t['correctAnswer']
  if isinstance(ans,dict):
   v=evaluate(ast.parse(audit['expression'],mode='eval'),audit['variables'])
   assert math.isfinite(v) and math.isclose(v,ans['value'],rel_tol=1e-12,abs_tol=1e-20),t['id']
   assert ans['absoluteTolerance']>0 and (v==0 or ans['absoluteTolerance']<abs(v)*.01),t['id']
   arithmetic+=1
  elif t['interactionType']=='formula-builder':
   assert audit['positive']*audit['cationCount']==audit['negative']*audit['anionCount'],t['id']
   assert math.gcd(audit['cationCount'],audit['anionCount'])==1,t['id']
   actual,_=parse_formula(ans); cat,_=parse_formula(audit['cation']); an,_=parse_formula(audit['anion'])
   expected=Counter({e:n*audit['cationCount'] for e,n in cat.items()})
   expected.update({e:n*audit['anionCount'] for e,n in an.items()})
   assert actual==expected,t['id']
   assert ''.join(t['parameters']['formulaTokens'])==ans,t['id']
   formulas+=1
  elif t['interactionType']=='equation-balancing':
   assert is_balanced(ans),t['id']; equations+=1
  elif t['interactionType']=='oxidation-state':
   compound=t['parameters']['compound']
   target=re.search(r'степень окисления ([A-Z][a-z]?) в',t['prompt']).group(1)
   atoms,_=parse_formula(compound)
   known={'H':1,'O':-2,'Na':1,'K':1,'Ca':2,'Mg':2}
   residual=sum(count*known[element] for element,count in atoms.items() if element!=target)
   assert int(ans)*atoms[target]+residual==0,t['id']
  elif t.get('options'):
   assert ans in t['options'] and len(set(t['options']))==len(t['options']),t['id']
   # Independently derive decisions from the actual displayed numbers.
   prompt=t['prompt']; family=t['subtopic']
   if family=='Направление по Q':
    Q=float(re.search(r'Q=([\d.]+)',prompt).group(1)); K=float(re.search(r'K=([\d.]+)',prompt).group(1))
    assert ans==('прямое превращение A в B' if Q<K else 'обратное превращение B в A'),t['id']
   elif family=='Самопроизвольность по данным':
    G=float(re.search(r'ΔG=([-\d.]+)',prompt).group(1))
    assert ans==('прямое' if G<0 else 'обратное'),t['id']
   elif family=='Контроль водоцементного отношения':
    water=float(re.search(r'вода (\d+) кг',prompt).group(1))
    assert ans==('соответствует заданному В/Ц' if water/300<=.5 else 'превышает заданное В/Ц'),t['id']
   elif family=='Инспекция водной пробы':
    calcium=float(re.search(r'Ca²⁺=([\d.]+)',prompt).group(1))
    assert ans==('сумма укладывается в предел' if calcium+.9<=2 else 'сумма превышает предел'),t['id']

 # Negative controls exercise arithmetic and chemistry checks, rather than accepting every record.
 assert not is_balanced('H2 + O2 -> H2O')
 assert evaluate(ast.parse('a/b',mode='eval'),{'a':1,'b':4})==.25
 print(f'COURSE_AUDIT_OK: 1000 tasks, 13 modules; {arithmetic} numeric, {formulas} formula and {equations} equation checks; {len(set(t["subtopic"] for t in extra))} new families')
if __name__=='__main__': main()

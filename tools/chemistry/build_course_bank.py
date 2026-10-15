"""Build 853 reproducible course tasks. Run from any directory with Python 3.
Original authored content; reference links describe principles, not copied exercises.
"""
import json, math, re
from pathlib import Path
from collections import Counter
ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'data/chemistry/course'
TASKS = []
SOURCES = {
 'atoms':'https://openstax.org/books/chemistry-2e/pages/2-3-atomic-structure-and-symbolism',
 'bond':'https://openstax.org/books/chemistry-2e/pages/7-introduction',
 'reactions':'https://openstax.org/books/chemistry-2e/pages/4-3-reaction-stoichiometry',
 'solutions':'https://openstax.org/books/chemistry-2e/pages/3-3-molarity',
 'acid':'https://openstax.org/books/chemistry-2e/pages/14-introduction',
 'physical':'https://openstax.org/books/chemistry-2e/pages/11-introduction',
 'thermo':'https://openstax.org/books/chemistry-2e/pages/16-4-free-energy',
 'kinetics':'https://openstax.org/books/chemistry-2e/pages/12-3-rate-laws',
 'equilibrium':'https://openstax.org/books/chemistry-2e/pages/13-2-equilibrium-constants',
 'electro':'https://openstax.org/books/chemistry-2e/pages/17-introduction',
 'materials':'https://www.usgs.gov/special-topics/water-science-school/science/hardness-water',
}
def n(v): return f'{v:.6g}'
def add(level, module, family, prompt, answer, explanation, rule, interaction='numeric-calculation', station=None, options=None, params=None, evidence=None, source=None, difficulty=3):
    station = station or {1:'periodic-table-terminal',2:'reaction-bench',3:'solution-laboratory',4:'electrochemistry-station',5:'construction-materials-station'}[level]
    topic={1:'Строение атома',2:'Химическая связь',3:'Неорганические соединения',4:'Степени окисления',5:'Химические реакции',6:'Растворы и количество вещества',7:'Электролиты и кислотность',8:'Термодинамика',9:'Химическая кинетика',10:'Химическое равновесие',11:'Окисление и восстановление',12:'Электрохимия',13:'Строительная химия'}[module]
    task=dict(id=f'C{level}-{sum(t["level"]==level for t in TASKS)+1:03}',level=level,moduleId=module,topic=topic,subtopic=family,difficulty=difficulty,station=station,interactionType=interaction,prompt=prompt,correctAnswer=answer,explanation=explanation,rule=rule,hint=rule,points=100,tags=[f'module-{module}',family],procedural=evidence is not None,generatorId=family if evidence else '',reviewStatus='verified',sourceRefs=[SOURCES[source or {1:'atoms',2:'reactions',3:'solutions',4:'thermo',5:'materials'}[level]]],learningObjective=family)
    if options: task['options']=options
    if params: task['parameters']=params
    if evidence: task['audit']=evidence
    TASKS.append(task)
def calc(level,module,family,prompt,value,unit,rule,expression,variables,**kw):
    add(level,module,family,prompt+f' Ответ: {unit}.' if unit else prompt,{'value':value,'absoluteTolerance':max(1e-18,abs(value)*0.001),'unit':unit},f'{rule} Подстановка данных даёт {n(value)} {unit}.',rule,evidence=dict(expression=expression,variables=variables),**kw)
def choice(level,module,family,prompt,correct,wrong,why,**kw):
    opts=[correct,*wrong]; assert len(set(opts))==len(opts)
    add(level,module,family,prompt,correct,why,why,interaction='classification',options=opts,**kw)

# 50 chemically unambiguous salts: formula construction and naming (100 tasks).
cations=[('Na',1,'натрия'),('K',1,'калия'),('Ca',2,'кальция'),('Mg',2,'магния'),('Al',3,'алюминия'),('Zn',2,'цинка'),('Fe',2,'железа(II)'),('Fe',3,'железа(III)'),('Cu',2,'меди(II)'),('NH4',1,'аммония')]
anions=[('Cl',1,'хлорид'),('NO3',1,'нитрат'),('SO4',2,'сульфат'),('CO3',2,'карбонат'),('PO4',3,'фосфат')]
# Al carbonate and Fe(III) carbonate are replaced by stable bromides: hydrolysis complicates those salts.
for cat,z,name in cations:
 for an,q,aname in anions:
    if an=='CO3' and z==3: an,q,aname='Br',1,'бромид'
    a=q//math.gcd(z,q); b=z//math.gcd(z,q)
    def part(s,k): return ('('+s+')' if k>1 and len(re.findall('[A-Z]',s))>1 else s)+(str(k) if k>1 else '')
    formula=part(cat,a)+part(an,b); label=f'{aname} {name}'
    add(1,3,'Формула по зарядам',f'Собери формулу соли из {cat} (заряд +{z}) и {an} (заряд −{q}); используй минимальные индексы.',formula,f'Заряды компенсируются: {a} × {z} = {b} × {q}. Формула: {formula}.','Сумма зарядов в формульной единице равна нулю.',interaction='formula-builder',station='formula-board',params={'formulaTokens':re.findall(r'[A-Z][a-z]?|\d|[()]',formula)},evidence={'cation':cat,'anion':an,'positive':z,'negative':q,'cationCount':a,'anionCount':b},source='bond',difficulty=2)
    if aname in ['карбонат','фосфат'] or (an=='Br') : continue
    choice(1,3,'Название соли',f'На карточке склада указано {formula}. Выбери название.',label,[f'оксид {name}',f'гидроксид {name}',f'сульфид {name}'],f'{an} — {aname}; катион определяет название «{name}».',station='substance-storage',source='bond',difficulty=1)
# Bonding, periodicity, configurations and quantum-state reasoning (20).
concepts=[
(2,'Связь в кристалле','В кристалле NaCl какие частицы образуют решётку?','Na⁺ и Cl⁻',['молекулы NaCl','нейтральные атомы Na и Cl','электроны и протоны'],'Ионный кристалл состоит из катионов и анионов.'),
(2,'Полярность связи','У атомов H и Cl различается электроотрицательность. Какова связь H–Cl?','ковалентная полярная',['ковалентная неполярная','металлическая','водородная внутри молекулы'],'Общая электронная пара смещена к более электроотрицательному Cl.'),
(2,'Общая пара','Какая связь внутри молекулы Cl₂?','ковалентная неполярная',['металлическая','ионная','водородная'],'Одинаковые атомы одинаково притягивают общую электронную пару.'),
(2,'Проводимость металла','Какие носители обеспечивают ток в твёрдой медной проволоке?','подвижные электроны',['подвижные ядра Cu','молекулы Cu₂','гидроксид-ионы'],'В металле есть подвижные делокализованные электроны.'),
(2,'Геометрия и полярность','Связи C=O полярны, молекула CO₂ линейна и симметрична. Каков суммарный диполь?','равен нулю',['равен заряду CO₃²⁻','всегда положителен','равен диполю воды'],'Векторы диполей двух одинаковых связей взаимно компенсируются.'),
(2,'Водородная связь','Какое взаимодействие между молекулами воды связано с H–O и неподелённой парой O соседней молекулы?','водородная связь',['металлическая связь','связь между ядрами','ионная решётка NaCl'],'Водородная связь возникает между донором H–O и электронной парой соседнего O.'),
(2,'Ковалентная сеть','Алмаз твёрдый и имеет высокую температуру сублимации. Какая структура это объясняет?','пространственная ковалентная сеть',['отдельные молекулы C₄','водородные связи','ионная соль C⁴⁺C⁴⁻'],'Ковалентные связи соединяют атомы углерода в протяжённую сеть.'),
(2,'Проводимость расплава','Почему расплав NaCl проводит электрический ток?','ионы могут перемещаться',['ядра превращаются в электроны','соль становится медью','каждый ион теряет ядро'],'В расплаве ионы подвижны и переносят электрический заряд.'),
(2,'Кратность связи','Какая из связей C–C, C=C, C≡C имеет наибольшую кратность?','C≡C',['C–C','C=C','все имеют кратность 1'],'Тройная связь соответствует трём общим электронным парам.'),
(2,'Растворение и частицы','Какие частицы преобладают при растворении сахарозы в воде?','молекулы сахарозы',['ионы Na⁺ и Cl⁻','атомы углерода','электроны вне молекул'],'Сахароза — молекулярный неэлектролит; в воде сохраняет молекулы.'),
(1,'Электронная конфигурация','Основное состояние Na (Z=11): выбери конфигурацию.','1s² 2s² 2p⁶ 3s¹',['1s² 2s² 2p⁵ 3s²','1s² 2s² 2p⁶ 3s²','1s² 2s² 2p⁶'],'В основном состоянии 11 электронов последовательно заполняют 1s, 2s, 2p, 3s.'),
(1,'Конфигурация катиона','Na отдаёт электрон 3s. Какова конфигурация Na⁺?','1s² 2s² 2p⁶',['1s² 2s² 2p⁶ 3s¹','1s² 2s² 2p⁵','1s² 2s²'],'Катион Na⁺ содержит 10 электронов и заполненный второй уровень.'),
(1,'Квантовое число l','Для p-подуровня чему равно орбитальное квантовое число l?','1',['0','2','3'],'s, p, d, f соответствуют l=0, 1, 2, 3.'),
(1,'Вместимость орбитали','Сколько электронов максимально помещается на одной орбитали?','2',['1','6','10'],'Принцип Паули допускает два электрона с противоположными спинами.'),
(1,'Вместимость p-подуровня','На p-подуровне три орбитали. Сколько электронов максимально?','6',['2','3','10'],'Три орбитали по два электрона дают вместимость 6.'),
(1,'Правило Хунда','Как три электрона занимают три вырожденные p-орбитали основного состояния?','по одному с параллельными спинами',['сначала три на одной орбитали','одна пара и пустая орбиталь обязательно','все с одинаковыми четырьмя квантовыми числами'],'Вырожденные орбитали сначала заполняются по одному с параллельными спинами.'),
(1,'Периодический радиус','Сравни нейтральные атомы Na и Cl одного периода. У какого больше типичный атомный радиус?','Na',['Cl','у обоих нулевой','радиус равен атомной массе'],'Вдоль периода рост эффективного заряда ядра обычно уменьшает радиус.'),
(1,'Электроотрицательность','У какого элемента выше электроотрицательность: Na, Mg, S или Cl?','Cl',['Na','Mg','S'],'В пределах периода электроотрицательность в целом растёт к галогенам.'),
(1,'Валентные электроны','Основное состояние Mg: [Ne]3s². Сколько электронов на внешнем уровне?','2',['8','10','12'],'Внешний уровень n=3 содержит два электрона 3s.'),
(1,'Изотопы','Какая пара представляет изотопы одного элемента?','¹²C и ¹⁴C',['¹²C и ¹⁴N','²³Na и ²⁴Mg','¹⁶O и ¹⁹F'],'Изотопы имеют одинаковое Z и разные массовые числа.')]
for mod,f,p,a,w,e in concepts:
 choice(1,mod,f,p,a,w,e,source='bond' if mod==2 else 'atoms',difficulty=2)

# 10 explicitly specified isotopes, four distinct skills each (40).
for symbol,z,A in [('C',6,12),('O',8,18),('Na',11,23),('Mg',12,24),('Al',13,27),('Si',14,28),('S',16,34),('Cl',17,37),('Ca',20,40),('Fe',26,56)]:
 for family,prompt,value,expr,vs in [
 ('Протоны',f'Для изотопа {symbol}-{A} задан атомный номер Z={z}. Сколько протонов в ядре?',z,'Z',{'Z':z}),
 ('Нейтроны',f'Изотоп {symbol}-{A}: массовое число A={A}, Z={z}. Найди число нейтронов.',A-z,'A-Z',{'A':A,'Z':z}),
 ('Электроны иона',f'Атом {symbol} с Z={z} потерял 2 электрона. Сколько электронов у иона?',z-2,'Z-q',{'Z':z,'q':2}),
 ('Массовое число',f'В ядре {symbol} {z} протонов и {A-z} нейтронов. Вычисли массовое число.',A,'Z+N',{'Z':z,'N':A-z})]:
    calc(1,1,family,prompt,value,'',{'Протоны':'p = Z.','Нейтроны':'N = A − Z.','Электроны иона':'Число электронов катиона: Z − q.','Массовое число':'A = p + N.'}[family],expr,vs,difficulty=1)
# 20 oxidation problems with explicit conventional O/H values.
for f,el,count,other,charge in [('Na2SO4','S',1,-2,6),('KNO3','N',1,-2,5),('CaCO3','C',1,-2,4),('KMnO4','Mn',1,-2,7),('K2Cr2O7','Cr',2,-2,6),('Fe2O3','Fe',2,-2,3),('FeO','Fe',1,-2,2),('CuO','Cu',1,-2,2),('Al2O3','Al',2,-2,3),('SiO2','Si',1,-2,4),('SO2','S',1,-2,4),('SO3','S',1,-2,6),('CO2','C',1,-2,4),('N2O5','N',2,-2,5),('P2O5','P',2,-2,5),('HCl','Cl',1,1,-1),('H2S','S',1,1,-2),('NH3','N',1,1,-3),('CH4','C',1,1,-4),('MgO','Mg',1,-2,2)]:
    add(1,4,'Степень окисления',f'Определи степень окисления {el} в {f}. Используй O: −2, H: +1, Na/K: +1, Ca: +2.',str(charge),f'Сумма степеней окисления в {f} равна нулю; для {el} получается {charge:+}.','Сумма степеней окисления нейтральной частицы равна нулю.',interaction='oxidation-state',station='formula-board',source='reactions',params={'compound':f})

# 20 curated balanced equations, six independent reasoning perspectives (120).
reactions=[(['H2','O2'],[2,1],['H2O'],[2]),(['N2','H2'],[1,3],['NH3'],[2]),(['CaO','H2O'],[1,1],['Ca(OH)2'],[1]),(['Ca(OH)2','HCl'],[1,2],['CaCl2','H2O'],[1,2]),(['NaOH','H2SO4'],[2,1],['Na2SO4','H2O'],[1,2]),(['Na2CO3','HCl'],[1,2],['NaCl','H2O','CO2'],[2,1,1]),(['CaCO3','HCl'],[1,2],['CaCl2','H2O','CO2'],[1,1,1]),(['Zn','HCl'],[1,2],['ZnCl2','H2'],[1,1]),(['Mg','O2'],[2,1],['MgO'],[2]),(['Al','O2'],[4,3],['Al2O3'],[2]),(['Fe2O3','CO'],[1,3],['Fe','CO2'],[2,3]),(['CuO','H2'],[1,1],['Cu','H2O'],[1,1]),(['BaCl2','Na2SO4'],[1,1],['BaSO4','NaCl'],[1,2]),(['AgNO3','NaCl'],[1,1],['AgCl','NaNO3'],[1,1]),(['CuSO4','NaOH'],[1,2],['Cu(OH)2','Na2SO4'],[1,1]),(['FeCl3','NaOH'],[1,3],['Fe(OH)3','NaCl'],[1,3]),(['CO2','Ca(OH)2'],[1,1],['CaCO3','H2O'],[1,1]),(['SO3','H2O'],[1,1],['H2SO4'],[1]),(['NaHCO3'],[2],['Na2CO3','CO2','H2O'],[1,1,1]),(['KClO3'],[2],['KCl','O2'],[2,3])]
for idx,(rs,rc,ps,pc) in enumerate(reactions):
    eq=' + '.join((str(c) if c>1 else '')+s for s,c in zip(rs,rc))+' -> '+' + '.join((str(c) if c>1 else '')+s for s,c in zip(ps,pc))
    skeleton=' + '.join(rs)+' → '+' + '.join(ps)
    add(2,5,'Баланс атомов',f'Виртуальная модель: {skeleton}. Запиши полное уравнение с минимальными целыми коэффициентами.',eq,'Число атомов каждого элемента сохраняется. '+eq,'Коэффициенты умножают число атомов всей формулы.',interaction='equation-balancing',evidence={'equation':eq},difficulty=2)
    calc(2,5,'Сумма коэффициентов',f'Для уравнения {eq} найди сумму всех минимальных целых коэффициентов, включая единицы.',sum(rc+pc),'','Сложи коэффициенты обеих частей.','a+b',{'a':sum(rc),'b':sum(pc)},difficulty=2)
    v=idx+2
    calc(2,5,'Расход реагента',f'Модель {eq}. Для получения {v} моль {ps[0]} сколько моль {rs[0]} потребуется при полном превращении?',v*rc[0]/pc[0],'моль','n(реагента)/n(продукта) = отношение коэффициентов.','v*a/b',{'v':v,'a':rc[0],'b':pc[0]})
    calc(2,5,'Выход продукта',f'Модель {eq}. Взято {v} моль {rs[0]}, остальные реагенты в избытке. Найди теоретическое количество {ps[0]}.',v*pc[0]/rc[0],'моль','n(продукта) = n(реагента) × ν(продукта)/ν(реагента).','v*b/a',{'v':v,'a':rc[0],'b':pc[0]})
    calc(2,5,'Практический выход',f'В модели {eq} теоретически получается {v} моль {ps[0]}, практически — {n(v*0.8)} моль. Найди выход в процентах.',80,'%','η = n(практ)/n(теор) × 100%.','p/t*100',{'p':v*.8,'t':v})
    calc(2,5,'Степень превращения',f'В виртуальном процессе {eq} исходно {v} моль {rs[0]}, осталось {n(v*.25)} моль. Какая доля исходного реагента израсходована в процентах?',75,'%','α = (n₀ − n)/n₀ × 100%.','(a-b)/a*100',{'a':v,'b':v*.25})

# Solution tasks: 20 families, 10 data sets each (200).
for k in range(1,11):
    def c(f,p,v,u,r,e,vs,module=6,**kw): calc(3,module,f,p,v,u,r,e,vs,**kw)
    mass=5*k; volume=.25+.05*k; amount=.02*k
    c('Масса и количество',f'Учебная проба NaOH: масса {mass} г, M=40 г/моль. Найди количество вещества.',mass/40,'моль','n = m/M.','m/M',{'m':mass,'M':40})
    c('Молярная концентрация',f'В {n(volume)} л раствора содержится {n(amount)} моль NaCl. Найди молярность.',amount/volume,'моль/л','c = n/V.','n/V',{'n':amount,'V':volume})
    c('Разбавление',f'Объём виртуального раствора {10*k} мл, c₁=2 моль/л. Его объём довели до {100+10*k} мл. Найди c₂.',2*10*k/(100+10*k),'моль/л','c₁V₁ = c₂V₂.','c*V/W',{'c':2,'V':10*k,'W':100+10*k})
    c('Массовая доля',f'В пробе {k+2} г соли и {100+3*k} г воды. Найди массовую долю соли в процентах.',(k+2)/(102+4*k)*100,'%','w = m(вещества)/(m(вещества)+m(воды)) × 100%.','s/(s+w)*100',{'s':k+2,'w':100+3*k})
    c('Смешение растворов',f'Смешаны {20*k} г 5%-го и {100+10*k} г 15%-го раствора одной соли. Найди итоговую массовую долю, %. Потери отсутствуют.',(20*k*.05+(100+10*k)*.15)/(100+30*k)*100,'%','Сумма масс растворённого вещества делится на общую массу.','(a*x+b*y)/(a+b)*100',{'a':20*k,'x':.05,'b':100+10*k,'y':.15})
    c('Растворимость и кристаллизация',f'В {100+10*k} г воды насыщено вещество: растворимость падает с 40 до 20 г на 100 г воды. Найди массу кристаллов; испарение воды отсутствует.',(100+10*k)*.2,'г','m(кристаллов) = m(воды) × (S₁−S₂)/100.','w*(a-b)/100',{'w':100+10*k,'a':40,'b':20},source='physical')
    c('Моляльность',f'Раствор содержит {n(.1*k)} моль мочевины и {200+20*k} г воды. Найди моляльность.',.1*k/((200+20*k)/1000),'моль/кг','b = n/m(растворителя в кг).','n/(m/1000)',{'n':.1*k,'m':200+20*k},source='physical')
    c('Понижение замерзания',f'Идеальный разбавленный водный раствор сахарозы: b={n(.01*k)} моль/кг, Kf=1.86 К·кг/моль, i=1. Найди положительное понижение температуры замерзания.',1.86*.01*k,'К','ΔTf = iKf b.','i*K*b',{'i':1,'K':1.86,'b':.01*k},source='physical')
    c('Осмотическое давление',f'Идеальный раствор молекулярного вещества: c={n(.001*k)} моль/л, T=300 К, R=8.314 кПа·л/(моль·К), i=1. Найди осмотическое давление.',.001*k*300*8.314,'кПа','π = icRT.','i*c*R*T',{'i':1,'c':.001*k,'R':8.314,'T':300},source='physical')
    c('Ионы при диссоциации',f'Идеализируем полную диссоциацию {n(.01*k)} моль CaCl₂. Найди суммарное количество ионов Ca²⁺ и Cl⁻.',.03*k,'моль','CaCl₂ → Ca²⁺ + 2Cl⁻: три моля ионов на моль соли.','n*3',{'n':.01*k},module=7,source='acid')
    ph=1+.2*k
    c('Шкала pH',f'При 25 °C pH={n(ph)}. В концентрационном приближении найди [H₃O⁺].',10**(-ph),'моль/л','[H₃O⁺] ≈ 10^(−pH).','10**(-p)',{'p':ph},module=7,source='acid')
    c('pH и pOH',f'В разбавленном водном растворе при 25 °C pOH={n(ph)}. Найди pH.',14-ph,'','pH + pOH = 14 (25 °C, концентрационное приближение).','14-p',{'p':ph},module=7,source='acid')
    c('Буферный раствор',f'Учебный буфер: pKa=4.76, отношение [A⁻]/[HA]={n(k/2)}. По уравнению Хендерсона–Хассельбаха найди pH; активности заменены концентрациями.',4.76+math.log10(k/2),'','pH ≈ pKa + lg([A⁻]/[HA]).','p+log10(r)',{'p':4.76,'r':k/2},module=7,source='acid',difficulty=4)
    c('Степень диссоциации',f'Из {100+10*k} условных молекул слабого электролита диссоциировало {k+1}. Найди степень диссоциации, %.',(k+1)/(100+10*k)*100,'%','α = N(диссоциировавших)/N(исходных) × 100%.','d/N*100',{'d':k+1,'N':100+10*k},module=7,source='acid')
    c('Произведение растворимости',f'Для модельной соли AB ⇌ A⁺ + B⁻ задано Ksp={n((k*1e-5)**2)}. Найди растворимость в чистой воде; побочные реакции отсутствуют.',k*1e-5,'моль/л','Ksp = s² для соли AB.','sqrt(K)',{'K':(k*1e-5)**2},module=7,source='equilibrium',difficulty=4)
    c('Ионное произведение воды',f'При 25 °C [H₃O⁺]={n(k*1e-5)} моль/л, Kw=1e-14. В концентрационном приближении найди [OH⁻].',1e-14/(k*1e-5),'моль/л','[H₃O⁺][OH⁻] ≈ Kw.','K/h',{'K':1e-14,'h':k*1e-5},module=7,source='acid')
    c('Нейтрализация по данным',f'Виртуальная модель HCl + NaOH → NaCl + H₂O: {10*k} мл HCl нейтрализовано {5*k+10} мл NaOH с c=0.1 моль/л. Найди концентрацию кислоты.',.1*(5*k+10)/(10*k),'моль/л','c(кислоты)V(кислоты) = c(щёлочи)V(щёлочи).','c*b/a',{'c':.1,'b':5*k+10,'a':10*k},module=7,source='acid')
    c('Материальный баланс воды',f'В учебной пробе {100+10*k} г 10%-го раствора выпарено {k} г воды. Найди конечную массовую долю соли, %. Соль остаётся в растворе.',(100+10*k)*.1/(100+9*k)*100,'%','Масса соли сохраняется; масса раствора уменьшается.','m*w/(m-e)*100',{'m':100+10*k,'w':.1,'e':k})
    c('Пересчёт по плотности',f'Раствор: плотность {n(1+.01*k)} г/мл, массовая доля NaCl 5%, M(NaCl)=58.5 г/моль. Найди молярную концентрацию.',(1+.01*k)*1000*.05/58.5,'моль/л','c = 1000ρw/M, ρ в г/мл.','1000*r*w/M',{'r':1+.01*k,'w':.05,'M':58.5})
    choice(3,7,'Осадок по измерениям',f'В виртуальной модели AB: ионное произведение Q={k+1}e-8, Ksp={12-k}e-8. Каков вывод для исходного раствора?', 'образование осадка возможно' if k>=6 else 'раствор ненасыщен', ['равновесие с твёрдой фазой','раствор ненасыщен' if k>=6 else 'образование осадка возможно','данных о Q достаточно только для pH'], 'Q > Ksp: пересыщение и возможность осаждения; Q < Ksp: ненасыщенный раствор.',source='equilibrium',difficulty=4)

# Engineering chemistry: 20 families x 10 sets (200).
for k in range(1,11):
 def c(m,f,p,v,u,r,e,vs,**kw): calc(4,m,f,p,v,u,r,e,vs,**kw)
 c(8,'Калориметрия',f'Учебный образец: m={100+10*k} г, c=0.9 Дж/(г·К), нагрев на {k+5} К. Найди полученное тепло.',(100+10*k)*.9*(k+5),'Дж','q = mcΔT.','m*c*d',{'m':100+10*k,'c':.9,'d':k+5})
 c(8,'Энтальпия на количество',f'Модель реакции: ΔH=−80 кДж на 1 моль превращения. Прореагировало {n(k*.2)} моль. Найди изменение энтальпии системы со знаком.',-80*k*.2,'кДж','ΔH(системы) = nΔH(молярная).','n*h',{'n':k*.2,'h':-80})
 c(8,'Закон Гесса',f'Модель: A→B, ΔH={-20-k} кДж; B→C, ΔH={5+2*k} кДж. Найди ΔH для A→C.',-15+k,'кДж','Энтальпии последовательных стадий складываются.','a+b',{'a':-20-k,'b':5+2*k})
 c(8,'Энергия Гиббса',f'При T={280+10*k} К ΔH=20 кДж/моль, ΔS=80 Дж/(моль·К). Найди ΔG в кДж/моль.',20-(280+10*k)*.08,'кДж/моль','ΔG = ΔH − TΔS; переведи Дж в кДж.','h-T*s/1000',{'h':20,'T':280+10*k,'s':80})
 c(8,'Температурный порог',f'Модель: ΔH={20+2*k} кДж/моль, ΔS=100 Дж/(моль·К), обе величины постоянны. При какой T получается ΔG=0?',(20+2*k)*10,'К','T = ΔH/ΔS при ΔG=0.','h*1000/s',{'h':20+2*k,'s':100})
 c(8,'Энтропия обратимого перехода',f'При T={300+10*k} К система обратимо получила q={600+20*k} Дж. Найди изменение энтропии.',(600+20*k)/(300+10*k),'Дж/К','ΔS = q_rev/T при постоянной температуре.','q/T',{'q':600+20*k,'T':300+10*k})
 c(9,'Средняя скорость',f'Время реакции: {10+k} с. Концентрация A упала с 0.8 до {n(.1+.02*k)} моль/л. Найди среднюю положительную скорость расходования A.',(.8-(.1+.02*k))/(10+k),'моль/(л·с)','v(A) = −Δ[A]/Δt.','(a-b)/t',{'a':.8,'b':.1+.02*k,'t':10+k},source='kinetics')
 c(9,'Закон скорости',f'Модель v=k[A]²: k=0.2 л/(моль·с), [A]={n(.1*k)} моль/л. Найди скорость.',.2*(.1*k)**2,'моль/(л·с)','Подставь концентрацию в заданный закон скорости.','r*a**2',{'r':.2,'a':.1*k},source='kinetics')
 c(9,'Первый порядок',f'Модель первого порядка: k={n(.01*k)} с⁻¹. Найди период полупревращения; используй ln(2)=0.693.',.693/(.01*k),'с','t½ = ln(2)/k.','L/r',{'L':.693,'r':.01*k},source='kinetics')
 c(9,'Температурный коэффициент',f'Учебная модель Вант-Гоффа с γ=2 применима в заданном интервале. Температура выросла на {10*k} °C. Во сколько раз выросла скорость?',2**k,'','v₂/v₁ = γ^(ΔT/10); γ задан для учебного интервала.','g**(d/10)',{'g':2,'d':10*k},source='kinetics')
 c(10,'Константа равновесия',f'A ⇌ B: равновесные [A]={n(.1*k)} и [B]={n(.2+.05*k)} моль/л. Найди Kc=[B]/[A] в идеальном растворе.',(.2+.05*k)/(.1*k),'','Kc = [B]/[A] для A ⇌ B.','b/a',{'b':.2+.05*k,'a':.1*k},source='equilibrium')
 c(10,'Равновесие с квадратом',f'A ⇌ 2B: равновесные [A]=0.5 и [B]={n(.1*k)} моль/л. Найди численное значение Kc=[B]²/[A] при использовании моль/л.',(.1*k)**2/.5,'','Степени концентраций соответствуют коэффициентам.','b**2/a',{'b':.1*k,'a':.5},source='equilibrium')
 choice(4,10,'Направление по Q',f'A ⇌ B: Q={k/2}, K=2.75 при текущей температуре. Как будет меняться система?', 'прямое превращение A в B' if k<=5 else 'обратное превращение B в A',['обратное превращение B в A' if k<=5 else 'прямое превращение A в B','равновесие уже достигнуто','направление задаёт только катализатор'],'Q < K: возрастает доля продуктов; Q > K: возрастает доля реагентов.',source='equilibrium')
 c(12,'ЭДС элемента',f'Стандартные потенциалы модельной пары: катод +{n(.3+.01*k)} В, анод −0.76 В. Найди стандартную ЭДС.',.3+.01*k+.76,'В','E°яч = E°кат − E°ан (оба как потенциалы восстановления).','c-a',{'c':.3+.01*k,'a':-.76},source='electro')
 c(12,'Закон Фарадея',f'Виртуальный электролиз Cu²⁺: заряд {965*k} Кл, M(Cu)=63.5 г/моль, F=96500 Кл/моль, выход по току 100%. Найди массу Cu.',965*k*63.5/(2*96500),'г','m = MQ/(zF), z=2.','M*Q/(z*F)',{'M':63.5,'Q':965*k,'z':2,'F':96500},source='electro')
 c(12,'Время электролиза',f'Виртуальная модель требует заряд Q={1000+100*k} Кл. Ток постоянен: I=2 А. Найди время.',(1000+100*k)/2,'с','Q = It.','Q/I',{'Q':1000+100*k,'I':2},source='electro')
 c(11,'Электронный баланс',f'В модели {n(.1*k)} моль Fe²⁺ превращается в Fe³⁺. Найди количество отданных электронов.',.1*k,'моль','Fe²⁺ → Fe³⁺ + e⁻.','n*z',{'n':.1*k,'z':1},source='electro')
 c(12,'Уравнение Нернста',f'При 298 К для модельного элемента E°=1.1 В, n=2, lg(Q)={k-5}. Используй E=E°−(0.0592/n)lg(Q). Найди E.',1.1-.0592/2*(k-5),'В','Используй заданное уравнение Нернста и десятичный логарифм.','E-b/z*L',{'E':1.1,'b':.0592,'z':2,'L':k-5},source='electro',difficulty=4)
 c(11,'Эквиваленты электронов',f'В кислой среде MnO₄⁻ принимает 5e⁻ и переходит в Mn²⁺. Сколько моль Fe²⁺ → Fe³⁺ отдаст столько же электронов, сколько принимает {n(.01*k)} моль MnO₄⁻?',.05*k,'моль','Один MnO₄⁻ принимает 5e⁻; один Fe²⁺ отдаёт 1e⁻.','n*5',{'n':.01*k},source='electro')
 choice(4,8,'Самопроизвольность по данным',f'При постоянных T и p для указанного состояния ΔG={k-5.5} кДж/моль. Какое направление термодинамически предпочтительно?', 'прямое' if k<=5 else 'обратное',['обратное' if k<=5 else 'прямое','равновесие','направление определяется скоростью перемешивания'],'ΔG < 0 соответствует предпочтительности прямого процесса; ΔG > 0 — обратного.',difficulty=4)

# Construction applications: twelve distinct calculation/inspection families (120).
for k in range(1,11):
 def c(f,p,v,u,r,e,vs): calc(5,13,f,p,v,u,r,e,vs)
 c('Водоцементное отношение',f'Паспорт виртуального замеса: вода {140+5*k} кг, цемент {300+10*k} кг. Вычисли массовое В/Ц.',(140+5*k)/(300+10*k),'','В/Ц = m(воды)/m(цемента).','w/c',{'w':140+5*k,'c':300+10*k})
 c('Поправка на влагу заполнителя',f'Учебный баланс: сухая масса заполнителя {500+10*k} кг, свободная поверхностная влага 2% от сухой массы. Требуется {150+k} кг суммарной свободной воды. Сколько воды учитывается как добавляемая?',150+k-(500+10*k)*.02,'кг','Добавляемая вода = заданная свободная вода − свободная влага заполнителя.','w-m*f',{'w':150+k,'m':500+10*k,'f':.02})
 c('Содержание примеси',f'В {10+k} кг учебного материала определено {2*k} г хлорид-иона. Найди массовую долю Cl⁻ в процентах.',2*k/((10+k)*1000)*100,'%','Приведи массы к одной единице, затем w = m(Cl⁻)/m(образца) ×100%.','a/(m*1000)*100',{'a':2*k,'m':10+k})
 c('Жёсткость по ионам',f'Модель воды: [Ca²⁺]={n(.5+.1*k)} ммоль/л, [Mg²⁺]={n(.2+.05*k)} ммоль/л. Найди сумму концентраций этих ионов.',.7+.15*k,'ммоль/л','Суммарная молярная концентрация = [Ca²⁺] + [Mg²⁺].','a+b',{'a':.5+.1*k,'b':.2+.05*k})
 c('Жёсткость в пересчёте на CaCO3',f'Сумма [Ca²⁺]+[Mg²⁺]={n(.5+.2*k)} ммоль/л. M(CaCO₃)=100 г/моль. Найди эквивалентную концентрацию в мг CaCO₃/л.',(.5+.2*k)*100,'мг/л','Один ммоль двухвалентных ионов соответствует одному ммоль CaCO₃.','c*M',{'c':.5+.2*k,'M':100})
 c('Карбонизация извести',f'Идеальная модель Ca(OH)₂ + CO₂ → CaCO₃ + H₂O. Прореагировало {74*k} г чистого Ca(OH)₂, M=74 г/моль. Найди поглощённую массу CO₂; M(CO₂)=44 г/моль.',44*k,'г','Стехиометрия 1:1; m(CO₂) = m(Ca(OH)₂)/74 ×44.','m/A*B',{'m':74*k,'A':74,'B':44})
 c('Вода в кристаллогидрате',f'Учебная проба CaSO₄·2H₂O массой {172*k} г. M(CaSO₄·2H₂O)=172 г/моль, M(H₂O)=18 г/моль. Найди массу кристаллизационной воды.',36*k,'г','На моль дигидрата приходится два моля воды.','m/M*2*W',{'m':172*k,'M':172,'W':18})
 c('Обжиг в идеальной модели',f'Виртуальная модель CaCO₃ → CaO + CO₂: {100*k} г чистого CaCO₃, полное превращение. M(CaCO₃)=100, M(CaO)=56 г/моль. Найди массу CaO.',56*k,'г','Количество CaCO₃ равно количеству CaO.','m/A*B',{'m':100*k,'A':100,'B':56})
 c('Чистота известняка',f'Учебная проба известняка {200+10*k} г содержит {70+k}% CaCO₃ по массе. Найди массу CaCO₃.',(200+10*k)*(70+k)/100,'г','m(компонента) = m(пробы) × w.','m*w/100',{'m':200+10*k,'w':70+k})
 c('Средняя потеря металла',f'Виртуальная пластина потеряла {n(.5*k)} г за {10+k} суток при площади {100+10*k} см². Найди среднюю массовую потерю на площадь и время.',.5*k/((10+k)*(100+10*k)),'г/(см²·сут)','v = Δm/(SΔt); это средняя скорость для заданного опыта.','m/(S*t)',{'m':.5*k,'S':100+10*k,'t':10+k})
 choice(5,13,'Контроль водоцементного отношения',f'Учебная спецификация задаёт В/Ц ≤ 0.50. В виртуальном паспорте вода {130+5*k} кг, цемент 300 кг. Оцени соответствие только этому критерию.', 'соответствует заданному В/Ц' if k<=4 else 'превышает заданное В/Ц',['превышает заданное В/Ц' if k<=4 else 'соответствует заданному В/Ц','равенство масс воды и цемента','прочность точно равна 50 МПа'],'Сравни отношение массы воды к массе цемента с заданным пределом 0.50. Прочность требует отдельного испытания.')
 choice(5,13,'Инспекция водной пробы',f'Для учебной водной пробы предел суммы [Ca²⁺]+[Mg²⁺] задан 2.0 ммоль/л. Измерено Ca²⁺={n(.2*k)}, Mg²⁺=0.9 ммоль/л. Выбери заключение только по этому критерию.', 'сумма укладывается в предел' if k<=5 else 'сумма превышает предел',['сумма превышает предел' if k<=5 else 'сумма укладывается в предел','сумма всегда равна pH','по этим ионам установлена вся пригодность воды'],'Сложи молярные концентрации двух ионов и сравни с учебным пределом; общий состав воды оценивается отдельно.')

# Replace repetitive numeric variants with forty authored transfer cases.
from course_cases import CASES
replacements={2:'Сумма коэффициентов',3:'Материальный баланс воды',4:'Температурный коэффициент',5:'Средняя потеря металла'}
for level,family in replacements.items():
 targets=[t for t in TASKS if t['level']==level and t['subtopic']==family][:10]
 for task in targets: TASKS.remove(task)
 for module,f,p,a,w,e in CASES[level]:
  choice(level,module,f,p,a,w,e,source='reactions' if level==2 else ('acid' if level==3 and module==7 else 'physical' if level==3 else 'electro' if level==4 and module==12 else 'equilibrium' if level==4 and module==10 else 'thermo' if level==4 else 'materials'))
for level in range(1,6):
 for index,task in enumerate(t for t in TASKS if t['level']==level): task['id']=f'C{level}-{index+1:03}'

# Attach references to the actual principle used by each case.
for task in TASKS:
 family=task['subtopic']
 if family in ('Гидратация цемента','Пористость и уход','Водоцементное отношение','Поправка на влагу заполнителя','Контроль водоцементного отношения','Многофакторная инспекция'):
  task['sourceRefs']=['https://www.cement.org/cement-concrete/applications-of-cement/']
 elif family in ('Карбонизация и арматура','Хлориды и пассивность'):
  task['sourceRefs']=['https://nvlpubs.nist.gov/nistpubs/Legacy/IR/nistir89-4086.pdf']
 elif family=='Сульфатная среда':
  task['sourceRefs']=['https://www.nist.gov/publications/microstructural-origins-cement-paste-degradation-external-sulfate-attack']
 elif family in ('Карбонизация извести','Обжиг в идеальной модели','Вода в кристаллогидрате','Чистота известняка','Содержание примеси'):
  task['sourceRefs']=[SOURCES['reactions']]
 elif family in ('Полимерная архитектура','Термопласт'):
  task['sourceRefs']=['https://openstax.org/books/organic-chemistry/pages/31-7-polymer-structure-and-physical-properties']
 elif family=='Гипс и полугидрат':
  task['sourceRefs']=['https://assemblies-tools.usg.com/content/dam/USG_Marketing_Communications/united_states/product_promotional_materials/finished_assets/usg-gypsum-misconceptions-white-paper-en-IG1847.pdf']
 elif family=='Силикатная структура':
  task['sourceRefs']=['https://openstax.org/books/chemistry-atoms-first-2e/pages/18-3-structure-and-general-properties-of-the-metalloids', 'https://openstax.org/books/chemistry-2e/pages/18-9-occurrence-preparation-and-compounds-of-oxygen']
 elif family=='Буферный раствор' or family=='Буферная пара':
  task['sourceRefs']=['https://openstax.org/books/chemistry-2e/pages/14-6-buffers']
 elif family in ('Моляльность','Понижение замерзания','Осмотическое давление','Осмос через мембрану'):
  task['sourceRefs']=['https://openstax.org/books/chemistry-2e/pages/11-4-colligative-properties']
 elif family in ('Произведение растворимости','Осадок по измерениям','Общий ион'):
  task['sourceRefs']=['https://openstax.org/books/chemistry-2e/pages/15-1-precipitation-and-dissolution']
 elif family=='Газовая модель':
  task['sourceRefs']=['https://openstax.org/books/chemistry-2e/pages/9-2-relating-pressure-volume-amount-and-temperature-the-ideal-gas-law']
 elif task['moduleId']==9:
  task['sourceRefs']=[SOURCES['kinetics']]

# Reuse native station controls; evidence is explicitly a virtual teaching model.
for task in TASKS:
 family=task['subtopic']; audit=task.get('audit',{}); values=audit.get('variables',{})
 if family=='Масса и количество':
  task['interactionType']='virtual-scales'
  task['parameters']={'compound':'NaOH','scaleMode':'mass-to-moles','sampleMass':values['m'],'molarMass':values['M']}
 elif family=='Закон Гесса':
  task['interactionType']='hess-puzzle'; task['station']='reaction-bench'
  task['parameters']={'hessStart':'A','hessEnd':'C','hessEdges':[{'from':'A','to':'B','deltaH':values['a']},{'from':'B','to':'C','deltaH':values['b']}]}
 elif family=='Средняя скорость':
  task['interactionType']='kinetics-experiment'; task['station']='reaction-bench'
  task['parameters']={'comparisonRuns':[{'setting':'Начальное состояние','observation':f"Модель: [A]={n(values['a'])} моль/л, t=0 с."},{'setting':'Конечное состояние','observation':f"Модель: [A]={n(values['b'])} моль/л, t={n(values['t'])} с."}]}
 elif family=='Закон скорости':
  task['interactionType']='kinetics-experiment'; task['station']='reaction-bench'
  task['parameters']={'comparisonRuns':[{'setting':'Закон модели','observation':'v = k[A]², k=0.2 л/(моль·с).'},{'setting':'Состояние пробы','observation':f"Модель: [A]={n(values['a'])} моль/л."}]}
 elif family=='Направление по Q':
  task['interactionType']='equilibrium-control'; task['station']='reaction-bench'
  q=re.search(r'Q=([\d.]+)',task['prompt']).group(1)
  task['parameters']={'comparisonRuns':[{'setting':'Текущее состояние','observation':f'Модель A ⇌ B: Q={q}.'},{'setting':'Равновесный ориентир','observation':'При той же температуре K=2.75.'}]}
 elif family in ('Контроль водоцементного отношения','Инспекция водной пробы'):
  task['interactionType']='construction-mission'; task['station']='inspection-station'
  task['parameters']={'missionSteps':[{'title':'Паспорт виртуальной пробы','readout':task['prompt'].split(' Выбери')[0].split(' Оцени')[0]},{'title':'Критерий заключения','readout':task['rule']}]}

from syllabus_supplement import append_supplement
append_supplement(TASKS,calc,choice,SOURCES,add)

assert Counter(t['level'] for t in TASKS)=={1:160,2:120,3:232,4:208,5:133}
assert len(TASKS)==853
assert len({t['prompt'] for t in TASKS})==853
# Published identities remain stable when future families are inserted/reordered.
from course_ids import assign_stable_ids
registry_path=ROOT/'tools/chemistry/course_id_registry.json'
registry=json.loads(registry_path.read_text()) if registry_path.exists() else {}
previous=[]
for level in range(1,6):
 path=OUT/f'level{level}.json'
 if path.exists(): previous.extend(json.loads(path.read_text()))
registry=assign_stable_ids(TASKS,previous,registry)
registry_path.write_text(json.dumps(registry,indent=2,sort_keys=True)+'\n')
TASKS.sort(key=lambda task:(task['level'],task['id']))
OUT.mkdir(exist_ok=True)
for level in range(1,6):
 (OUT/f'level{level}.json').write_text(json.dumps([t for t in TASKS if t['level']==level],ensure_ascii=False,indent=2)+'\n')
report={'totalAdditional':853,'base':200,'total':1053,'byLevel':dict(Counter(t['level'] for t in TASKS)),'byModule':dict(Counter(t['moduleId'] for t in TASKS)),'families':dict(Counter(t['subtopic'] for t in TASKS)),'sources':SOURCES}
(OUT/'manifest.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print('COURSE_BANK_BUILT',len(TASKS),'tasks;',len(report['families']),'families')

# Rebuild aggregate data without touching game scripts or scenes.
production_path=ROOT/'data/chemistry/curated_tasks.json'
base=[t for t in json.loads(production_path.read_text()) if t['id'].startswith('L')]
assert len(base)==200
production_path.write_text(json.dumps(base+sorted(TASKS,key=lambda t:(t['level'],t['id'])),ensure_ascii=False,indent=2)+'\n')

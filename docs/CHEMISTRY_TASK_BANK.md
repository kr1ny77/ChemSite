# ChemSite Curated Chemistry Task Bank

Total seed tasks: 200.

Distribution:

- Level 1: tasks 001-040
- Level 2: tasks 041-080
- Level 3: tasks 081-120
- Level 4: tasks 121-160
- Level 5: tasks 161-200

These tasks are curated seed content for ChemSite.

The browser prototype converted these seeds into structured TypeScript data under `legacy-web/`. All 200 tasks have been exported to `data/chemistry/curated_tasks.json`. The native game selects all 40 Level 1 tasks; their supported interactions are checked by `tools/validation/level1_content_smoke.gd`. Levels 2–5 remain outside normal selection while their station mechanics and independent chemistry review are completed. `data/chemistry/vertical_slice_tasks.json` is retained as a reference for the first ten-task slice.

## General Rules

- Do not turn every task into a multiple-choice question.
- Prefer interactive mechanics that match the chemistry concept.
- Every task must have a verified correct answer.
- Every task must have a concise educational explanation.
- Every task should have at least one hint.
- Every task must specify topic, subtopic, difficulty, station and interaction type.
- Procedural variants may expand this bank beyond 200 tasks.
- Complex chemistry and construction scenarios should remain curated.
- Deterministic numerical and formula tasks may use generators.
- Tasks marked for review must not enter normal gameplay.
- All chemistry experiments in the game are virtual.

---

# Level 1 - Chemical Storage

Focus:

- chemical formulas
- nomenclature
- ions
- compound classes
- oxidation states
- periodic table
- atomic structure
- bonding

---

## Task 001

**Type:** Substance Card  
**Prompt:** Назови вещество `BaSO4`.  
**Correct answer:** сульфат бария.  
**Concept:** nomenclature, salts.

---

## Task 002

**Type:** Substance Card  
**Prompt:** Назови вещество `BaSO3`.  
**Correct answer:** сульфит бария.  
**Concept:** sulfite vs sulfate.

If the player makes a mistake, explain:

`SO3^2-` = сульфит.  
`SO4^2-` = сульфат.

---

## Task 003

**Type:** Substance Card  
**Prompt:** Назови вещество `NaHCO3`.  
**Correct answer:** гидрокарбонат натрия.

---

## Task 004

**Type:** Substance Card  
**Prompt:** Назови вещество `CaCO3`.  
**Correct answer:** карбонат кальция.

---

## Task 005

**Type:** Substance Card  
**Prompt:** Назови вещество `FeCl3`.  
**Correct answer:** хлорид железа(III).

---

## Task 006

**Type:** Substance Card  
**Prompt:** Назови вещество `CuSO4`.  
**Correct answer:** сульфат меди(II).

---

## Task 007

**Type:** Formula Builder  
**Prompt:** Собери формулу карбоната кальция.  
**Available ions:** `Ca^2+`, `CO3^2-`.  
**Correct answer:** `CaCO3`.

---

## Task 008

**Type:** Formula Builder  
**Prompt:** Собери формулу сульфата алюминия.  
**Available ions:** `Al^3+`, `SO4^2-`.  
**Correct answer:** `Al2(SO4)3`.

---

## Task 009

**Type:** Formula Builder  
**Prompt:** Напиши формулу нитрата железа(III).  
**Correct answer:** `Fe(NO3)3`.

---

## Task 010

**Type:** Formula Builder  
**Prompt:** Напиши формулу гидрокарбоната бария.  
**Correct answer:** `Ba(HCO3)2`.

---

## Task 011

**Type:** Fix the Formula  
**Prompt:** На доске написано `CaCl`. Исправь формулу хлорида кальция.  
**Correct answer:** `CaCl2`.

---

## Task 012

**Type:** Fix the Formula  
**Prompt:** На доске написано `AlSO4`. Исправь формулу сульфата алюминия.  
**Correct answer:** `Al2(SO4)3`.

---

## Task 013

**Type:** Fix the Formula  
**Prompt:** На доске написано `MgOH2`. Исправь формулу гидроксида магния.  
**Correct answer:** `Mg(OH)2`.

---

## Task 014

**Type:** Classification  
**Prompt:** К какому классу относится `H2SO4`?  
**Correct answer:** кислота.

---

## Task 015

**Type:** Classification  
**Prompt:** К какому классу относится `NaOH`?  
**Correct answer:** основание, щёлочь.

---

## Task 016

**Type:** Classification  
**Prompt:** К какому классу относится `Cu(OH)2`?  
**Correct answer:** основание, малорастворимый гидроксид.

---

## Task 017

**Type:** Classification  
**Prompt:** К какому классу относится `Al(OH)3`?  
**Correct answer:** амфотерный гидроксид.

---

## Task 018

**Type:** Classification  
**Prompt:** К какому классу относится `CaO`?  
**Correct answer:** основный оксид.

---

## Task 019

**Type:** Classification  
**Prompt:** К какому классу относится `SO3`?  
**Correct answer:** кислотный оксид.

---

## Task 020

**Type:** Classification  
**Prompt:** К какому классу относится `Al2O3`?  
**Correct answer:** амфотерный оксид.

---

## Task 021

**Type:** Classification  
**Prompt:** К какому классу относится `CO`?  
**Correct answer:** несолеобразующий оксид.

---

## Task 022

**Type:** Ion Identification  
**Prompt:** Выбери сульфат-ион.  
**Correct answer:** `SO4^2-`.

---

## Task 023

**Type:** Ion Identification  
**Prompt:** Выбери сульфит-ион.  
**Correct answer:** `SO3^2-`.

---

## Task 024

**Type:** Ion Identification  
**Prompt:** Выбери нитрат-ион.  
**Correct answer:** `NO3^-`.

---

## Task 025

**Type:** Ion Identification  
**Prompt:** Выбери фосфат-ион.  
**Correct answer:** `PO4^3-`.

---

## Task 026

**Type:** Ion Identification  
**Prompt:** Выбери гидрокарбонат-ион.  
**Correct answer:** `HCO3^-`.

---

## Task 027

**Type:** Oxidation State  
**Prompt:** Определи степень окисления серы в `H2SO4`.  
**Correct answer:** `+6`.

---

## Task 028

**Type:** Oxidation State  
**Prompt:** Определи степень окисления хрома в `K2Cr2O7`.  
**Correct answer:** `+6`.

---

## Task 029

**Type:** Oxidation State  
**Prompt:** Определи степень окисления азота в `NH3`.  
**Correct answer:** `-3`.

---

## Task 030

**Type:** Oxidation State  
**Prompt:** Определи степень окисления марганца в `KMnO4`.  
**Correct answer:** `+7`.

---

## Task 031

**Type:** Oxidation State  
**Prompt:** Определи степень окисления железа в `Fe2O3`.  
**Correct answer:** `+3`.

---

## Task 032

**Type:** Periodic Table  
**Prompt:** Сколько валентных электронов у атома кислорода?  
**Correct answer:** 6.

---

## Task 033

**Type:** Periodic Table  
**Prompt:** Сколько валентных электронов у атома натрия?  
**Correct answer:** 1.

---

## Task 034

**Type:** Electronic Configuration  
**Prompt:** Какому элементу соответствует конфигурация `1s2 2s2 2p6 3s1`?  
**Correct answer:** натрий, `Na`.

---

## Task 035

**Type:** Electronic Configuration  
**Prompt:** Какому элементу соответствует внешний уровень `3s2 3p5`?  
**Correct answer:** хлор, `Cl`.

---

## Task 036

**Type:** Atomic Structure  
**Prompt:** Что характеризует главное квантовое число `n`?  
**Correct answer:** главный энергетический уровень электронной оболочки.

---

## Task 037

**Type:** Chemical Bond  
**Prompt:** Какой тип химической связи преобладает в `NaCl`?  
**Correct answer:** ионная.

---

## Task 038

**Type:** Chemical Bond  
**Prompt:** Какая связь существует между атомами в молекуле `H2`?  
**Correct answer:** ковалентная неполярная.

---

## Task 039

**Type:** Chemical Bond  
**Prompt:** Какой тип связи характерен для металлического железа?  
**Correct answer:** металлическая.

---

## Task 040

**Type:** Sorting Station  
**Prompt:** Разложи вещества по правильным контейнерам: `HCl`, `NaOH`, `CO2`, `K2SO4`.  
**Correct answer:**

- `HCl` — кислота
- `NaOH` — основание, щёлочь
- `CO2` — кислотный оксид
- `K2SO4` — соль

---

# Level 2 - Reaction Zone

Focus:

- reaction equations
- balancing
- precipitation
- gas formation
- neutralization
- ionic equations
- activity series
- redox

---

## Task 041

**Type:** Reaction Completion  
**Prompt:** Закончи реакцию: `CaO + H2O -> ?`  
**Correct answer:** `Ca(OH)2`.

---

## Task 042

**Type:** Reaction Completion  
**Prompt:** Закончи реакцию: `SO3 + H2O -> ?`  
**Correct answer:** `H2SO4`.

---

## Task 043

**Type:** Reaction Completion  
**Prompt:** Закончи реакцию: `NaOH + HCl -> ?`  
**Correct answer:** `NaCl + H2O`.

---

## Task 044

**Type:** Decomposition  
**Prompt:** Закончи реакцию разложения: `CaCO3 -> ?`  
**Correct answer:** `CaO + CO2`.

---

## Task 045

**Type:** Reaction Completion  
**Prompt:** Закончи реакцию: `Zn + 2HCl -> ?`  
**Correct answer:** `ZnCl2 + H2`.

---

## Task 046

**Type:** Equation Balancing  
**Prompt:** Расставь коэффициенты: `Al + O2 -> Al2O3`.  
**Correct answer:** `4Al + 3O2 -> 2Al2O3`.

---

## Task 047

**Type:** Equation Balancing  
**Prompt:** Расставь коэффициенты: `Fe + O2 -> Fe2O3`.  
**Correct answer:** `4Fe + 3O2 -> 2Fe2O3`.

---

## Task 048

**Type:** Equation Balancing  
**Prompt:** Расставь коэффициенты: `H2 + O2 -> H2O`.  
**Correct answer:** `2H2 + O2 -> 2H2O`.

---

## Task 049

**Type:** Equation Balancing  
**Prompt:** Расставь коэффициенты: `Na + H2O -> NaOH + H2`.  
**Correct answer:** `2Na + 2H2O -> 2NaOH + H2`.

---

## Task 050

**Type:** Equation Balancing  
**Prompt:** Расставь коэффициенты: `P + O2 -> P2O5`.  
**Correct answer:** `4P + 5O2 -> 2P2O5`.

---

## Task 051

**Type:** Virtual Mixing  
**Prompt:** Смешай растворы `BaCl2` и `Na2SO4`. Что образуется?  
**Correct answer:** `BaSO4↓ + 2NaCl`.

---

## Task 052

**Type:** Virtual Mixing  
**Prompt:** Смешай `AgNO3` и `NaCl`.  
**Correct answer:** `AgCl↓ + NaNO3`.

---

## Task 053

**Type:** Virtual Mixing  
**Prompt:** Закончи реакцию: `CuSO4 + 2NaOH -> ?`  
**Correct answer:** `Cu(OH)2↓ + Na2SO4`.

---

## Task 054

**Type:** Virtual Mixing  
**Prompt:** Закончи реакцию: `FeCl3 + 3NaOH -> ?`  
**Correct answer:** `Fe(OH)3↓ + 3NaCl`.

---

## Task 055

**Type:** Gas Formation  
**Prompt:** Закончи реакцию: `Na2CO3 + 2HCl -> ?`  
**Correct answer:** `2NaCl + H2O + CO2↑`.

---

## Task 056

**Type:** Gas Identification  
**Prompt:** Какой газ выделяется при взаимодействии карбонатов с сильной кислотой?  
**Correct answer:** `CO2`.

---

## Task 057

**Type:** Precipitate Builder  
**Prompt:** Выбери два растворимых вещества, которые при смешивании дадут осадок `BaSO4`.  
**Correct answer:** растворимый источник `Ba^2+` и растворимый источник `SO4^2-`.

Example:

`BaCl2 + Na2SO4`.

---

## Task 058

**Type:** Precipitate Builder  
**Prompt:** Выбери растворы, которые при смешивании образуют `AgCl`.  
**Correct answer:** растворимый источник `Ag+` и источник `Cl-`.

Example:

`AgNO3 + NaCl`.

---

## Task 059

**Type:** Solubility Decision  
**Prompt:** Выпадает ли `NaCl` в осадок при обычных реакциях обмена в разбавленных водных растворах?  
**Correct answer:** нет, `NaCl` хорошо растворим в воде.

---

## Task 060

**Type:** Solubility Decision  
**Prompt:** Как характеризуется растворимость `CaCO3` в воде?  
**Correct answer:** малорастворимое / практически нерастворимое вещество.

---

## Task 061

**Type:** Net Ionic Equation  
**Prompt:** Напиши сокращённое ионное уравнение нейтрализации сильной кислоты сильной щёлочью.  
**Correct answer:** `H+ + OH- -> H2O`.

---

## Task 062

**Type:** Net Ionic Equation  
**Prompt:** Напиши сокращённое ионное уравнение образования `BaSO4`.  
**Correct answer:** `Ba^2+ + SO4^2- -> BaSO4↓`.

---

## Task 063

**Type:** Net Ionic Equation  
**Prompt:** Напиши сокращённое ионное уравнение образования `AgCl`.  
**Correct answer:** `Ag+ + Cl- -> AgCl↓`.

---

## Task 064

**Type:** Net Ionic Equation  
**Prompt:** Напиши сокращённое ионное уравнение образования `Cu(OH)2`.  
**Correct answer:** `Cu^2+ + 2OH- -> Cu(OH)2↓`.

---

## Task 065

**Type:** Spectator Ion Puzzle  
**Prompt:** Какие ионы являются ионами-наблюдателями при реакции `HCl + NaOH -> NaCl + H2O`?  
**Correct answer:** `Na+` и `Cl-`.

---

## Task 066

**Type:** Activity Series  
**Prompt:** Будет ли цинк реагировать с раствором `CuSO4`?  
**Correct answer:** да.  
**Equation:** `Zn + CuSO4 -> ZnSO4 + Cu`.

---

## Task 067

**Type:** Activity Series  
**Prompt:** Будет ли медь вытеснять цинк из раствора `ZnSO4`?  
**Correct answer:** нет.

---

## Task 068

**Type:** Activity Series  
**Prompt:** Закончи реакцию `Fe + CuSO4`.  
**Correct answer:** `FeSO4 + Cu`.

---

## Task 069

**Type:** Activity Series  
**Prompt:** Будет ли медь выделять водород из разбавленной `HCl`?  
**Correct answer:** нет.

---

## Task 070

**Type:** Activity Series  
**Prompt:** Будет ли магний реагировать с `HCl`?  
**Correct answer:** да, с выделением `H2`.

---

## Task 071

**Type:** Redox  
**Prompt:** Что происходит в переходе `Fe0 -> Fe^2+`?  
**Correct answer:** окисление, отдача двух электронов.

---

## Task 072

**Type:** Redox  
**Prompt:** Что происходит в переходе `Cu^2+ -> Cu0`?  
**Correct answer:** восстановление, принятие двух электронов.

---

## Task 073

**Type:** Redox  
**Prompt:** В реакции `Zn + Cu^2+ -> Zn^2+ + Cu` кто является восстановителем?  
**Correct answer:** `Zn`.

---

## Task 074

**Type:** Redox  
**Prompt:** В реакции `Zn + Cu^2+ -> Zn^2+ + Cu` кто является окислителем?  
**Correct answer:** `Cu^2+`.

---

## Task 075

**Type:** Electron Balance  
**Prompt:** Сколько электронов отдаёт атом алюминия при переходе `Al0 -> Al^3+`?  
**Correct answer:** 3 электрона.

---

## Task 076

**Type:** Reaction Classification  
**Prompt:** Определи тип реакции: `CaCO3 -> CaO + CO2`.  
**Correct answer:** реакция разложения.

---

## Task 077

**Type:** Reaction Classification  
**Prompt:** Определи тип реакции: `Zn + CuSO4 -> ZnSO4 + Cu`.  
**Correct answer:** реакция замещения.

---

## Task 078

**Type:** Reaction Classification  
**Prompt:** Определи тип реакции: `HCl + NaOH -> NaCl + H2O`.  
**Correct answer:** реакция обмена, нейтрализация.

---

## Task 079

**Type:** Reaction Classification  
**Prompt:** Определи тип реакции: `2H2 + O2 -> 2H2O`.  
**Correct answer:** реакция соединения.

---

## Task 080

**Type:** Multi-Station Mission  
**Prompt:** Получи в трёх виртуальных реакциях:

1. осадок
2. газ
3. воду

**Correct answer:** игра должна принимать несколько заранее проверенных вариантов.

Example:

- `AgNO3 + NaCl -> AgCl↓ + NaNO3`
- `Na2CO3 + 2HCl -> 2NaCl + H2O + CO2↑`
- `HCl + NaOH -> NaCl + H2O`

---

# Level 3 - Solution Laboratory

Focus:

- molar mass
- moles
- mass
- molarity
- mass fraction
- dilution
- pH
- electrolytes
- dissociation
- hydrolysis

---

## Task 081

**Type:** Molar Mass  
**Prompt:** Рассчитай молярную массу `H2O`.  
**Correct answer:** approximately `18.02 g/mol`.

---

## Task 082

**Type:** Molar Mass  
**Prompt:** Рассчитай молярную массу `NaOH`.  
**Correct answer:** approximately `40.00 g/mol`.

---

## Task 083

**Type:** Molar Mass  
**Prompt:** Рассчитай молярную массу `CaCO3`.  
**Correct answer:** approximately `100.09 g/mol`.

---

## Task 084

**Type:** Molar Mass  
**Prompt:** Рассчитай молярную массу `H2SO4`.  
**Correct answer:** approximately `98.08 g/mol`.

---

## Task 085

**Type:** Molar Mass  
**Prompt:** Рассчитай молярную массу `NaCl`.  
**Correct answer:** approximately `58.44 g/mol`.

---

## Task 086

**Type:** Mole Calculation  
**Prompt:** Сколько вещества содержится в `18.02 g H2O`?  
**Correct answer:** approximately `1 mol`.

---

## Task 087

**Type:** Mole Calculation  
**Prompt:** Сколько вещества содержится в `20 g NaOH`?  
**Correct answer:** `0.5 mol`.

---

## Task 088

**Type:** Mass Calculation  
**Prompt:** Найди массу `2 mol CO2`.  
**Correct answer:** approximately `88.02 g`.

---

## Task 089

**Type:** Mass Calculation  
**Prompt:** Найди массу `0.25 mol NaCl`.  
**Correct answer:** approximately `14.61 g`.

---

## Task 090

**Type:** Mass Calculation  
**Prompt:** Найди массу `0.10 mol CaCO3`.  
**Correct answer:** approximately `10.01 g`.

---

## Task 091

**Type:** Molarity  
**Prompt:** `0.5 mol` вещества находится в `1 L` раствора. Найди молярную концентрацию.  
**Correct answer:** `0.5 mol/L`.

---

## Task 092

**Type:** Molarity  
**Prompt:** `0.2 mol` вещества находится в `500 mL` раствора. Найди концентрацию.  
**Correct answer:** `0.4 mol/L`.

---

## Task 093

**Type:** Amount Calculation  
**Prompt:** Раствор имеет концентрацию `2 mol/L` и объём `0.25 L`. Сколько вещества содержится в растворе?  
**Correct answer:** `0.5 mol`.

---

## Task 094

**Type:** Volume Calculation  
**Prompt:** Какой объём `1 mol/L` раствора содержит `0.5 mol` вещества?  
**Correct answer:** `0.5 L`.

---

## Task 095

**Type:** Solution Preparation  
**Prompt:** Нужно виртуально приготовить `500 mL` раствора `NaCl` концентрацией `0.20 mol/L`. Какую массу `NaCl` нужно взять?  
**Correct answer:** approximately `5.84 g`.

Calculation:

`n = C × V = 0.20 × 0.500 = 0.100 mol`

`m = n × M = 0.100 × 58.44 = 5.844 g`

---

## Task 096

**Type:** Solution Preparation  
**Prompt:** Нужно приготовить `250 mL` раствора `NaOH` концентрацией `0.10 mol/L`. Какую массу `NaOH` нужно взять?  
**Correct answer:** `1.00 g`.

---

## Task 097

**Type:** Dilution  
**Prompt:** Есть раствор `1.0 mol/L`. Какой объём нужно взять, чтобы получить `500 mL` раствора `0.20 mol/L`?  
**Correct answer:** `100 mL`.

Use:

`C1V1 = C2V2`.

---

## Task 098

**Type:** Dilution  
**Prompt:** Взяли `50 mL` раствора концентрацией `2 mol/L` и довели объём до `200 mL`. Найди новую концентрацию.  
**Correct answer:** `0.5 mol/L`.

---

## Task 099

**Type:** Mass Fraction  
**Prompt:** `10 g` соли растворили в `90 g` воды. Найди массовую долю соли.  
**Correct answer:** `10%`.

Total solution mass:

`100 g`.

---

## Task 100

**Type:** Mass Fraction  
**Prompt:** В `200 g` раствора содержится `25 g` вещества. Найди массовую долю.  
**Correct answer:** `12.5%`.

---

## Task 101

**Type:** pH Terminal  
**Prompt:** Раствор имеет `pH = 3`. Какая среда?  
**Correct answer:** кислая.

---

## Task 102

**Type:** pH Terminal  
**Prompt:** Раствор имеет `pH = 7` при стандартных учебных условиях. Какая среда?  
**Correct answer:** нейтральная.

---

## Task 103

**Type:** pH Terminal  
**Prompt:** Раствор имеет `pH = 11`. Какая среда?  
**Correct answer:** щелочная.

---

## Task 104

**Type:** pH Calculation  
**Prompt:** `[H+] = 10^-4 mol/L`. Найди pH.  
**Correct answer:** `4`.

---

## Task 105

**Type:** pH Calculation  
**Prompt:** `[H+] = 10^-2 mol/L`. Найди pH.  
**Correct answer:** `2`.

---

## Task 106

**Type:** Hydrogen Ion Concentration  
**Prompt:** `pH = 5`. Найди `[H+]`.  
**Correct answer:** `10^-5 mol/L`.

---

## Task 107

**Type:** pH Comparison  
**Prompt:** Какой раствор более кислый: `pH 2` или `pH 4`?  
**Correct answer:** `pH 2`.

---

## Task 108

**Type:** pH Comparison  
**Prompt:** Во сколько раз концентрация `H+` при `pH 3` выше, чем при `pH 5`?  
**Correct answer:** в 100 раз.

---

## Task 109

**Type:** Dissociation  
**Prompt:** Напиши диссоциацию `NaCl`.  
**Correct answer:** `Na+ + Cl-`.

---

## Task 110

**Type:** Dissociation  
**Prompt:** Напиши диссоциацию `CaCl2`.  
**Correct answer:** `Ca^2+ + 2Cl-`.

---

## Task 111

**Type:** Dissociation  
**Prompt:** Напиши диссоциацию `Na2SO4`.  
**Correct answer:** `2Na+ + SO4^2-`.

---

## Task 112

**Type:** Dissociation  
**Prompt:** Напиши диссоциацию `AlCl3`.  
**Correct answer:** `Al^3+ + 3Cl-`.

---

## Task 113

**Type:** Electrolyte Classification  
**Prompt:** К какому типу электролитов относится `HCl` в водном растворе?  
**Correct answer:** сильный электролит.

---

## Task 114

**Type:** Electrolyte Classification  
**Prompt:** К какому типу электролитов относится `NaOH` в водном растворе?  
**Correct answer:** сильный электролит.

---

## Task 115

**Type:** Electrolyte Classification  
**Prompt:** К какому типу электролитов относится уксусная кислота?  
**Correct answer:** слабый электролит.

---

## Task 116

**Type:** Electrolyte Classification  
**Prompt:** Выбери неэлектролит среди типичных солей, кислот, щелочей и сахарозы.  
**Correct answer:** сахароза.

---

## Task 117

**Type:** Hydrolysis  
**Prompt:** Происходит ли значимый гидролиз `NaCl` в базовой учебной модели?  
**Correct answer:** практически нет.

Explanation:

`NaCl` образован сильной кислотой и сильным основанием.

---

## Task 118

**Type:** Hydrolysis  
**Prompt:** Какая среда характерна для водного раствора `Na2CO3`?  
**Correct answer:** щелочная.

---

## Task 119

**Type:** Hydrolysis  
**Prompt:** Какая среда характерна для раствора `NH4Cl`?  
**Correct answer:** кислая.

---

## Task 120

**Type:** Laboratory Mission  
**Prompt:** Определи неизвестный раствор по совокупности данных:

- pH
- присутствующие ионы
- результат осадочной реакции

**Correct answer:** зависит от конкретного сгенерированного сценария.

The game must use only verified scenario templates.

---

# Level 4 - Engineering Chemistry

Focus:

- thermochemistry
- Hess law
- kinetics
- equilibrium
- Le Chatelier principle
- electrochemistry
- corrosion

---

## Task 121

**Type:** Thermochemistry  
**Prompt:** Реакция выделяет тепло. Как она называется?  
**Correct answer:** экзотермическая.

---

## Task 122

**Type:** Thermochemistry  
**Prompt:** Реакционная система поглощает тепло. Как называется процесс?  
**Correct answer:** эндотермический.

---

## Task 123

**Type:** Thermochemistry  
**Prompt:** Какой знак имеет `ΔH` экзотермической реакции?  
**Correct answer:** `ΔH < 0`.

---

## Task 124

**Type:** Thermochemistry  
**Prompt:** Какой знак имеет `ΔH` эндотермической реакции?  
**Correct answer:** `ΔH > 0`.

---

## Task 125

**Type:** Concept Card  
**Prompt:** Что характеризует изменение энтальпии реакции `ΔH`?  
**Correct answer:** изменение энтальпии системы; при постоянном давлении оно соответствует тепловому эффекту процесса.

---

## Task 126

**Type:** Hess Law  
**Prompt:** Зависит ли тепловой эффект реакции от пути, по которому система перешла из начального состояния в конечное?  
**Correct answer:** нет.

---

## Task 127

**Type:** Hess Puzzle  
**Prompt:**

`A -> B = +20 kJ`

`B -> C = -50 kJ`

Найди:

`A -> C`.

**Correct answer:** `-30 kJ`.

---

## Task 128

**Type:** Hess Puzzle  
**Prompt:**

`A -> B = -100 kJ`

`A -> C = -40 kJ`

Найди:

`B -> C`.

**Correct answer:** `+60 kJ`.

---

## Task 129

**Type:** Energy Diagram  
**Prompt:** На энергетической диаграмме продукты расположены ниже реагентов. Какой характер имеет реакция?  
**Correct answer:** экзотермический.

---

## Task 130

**Type:** Energy Diagram  
**Prompt:** На энергетической диаграмме продукты расположены выше реагентов.  
**Correct answer:** эндотермический процесс.

---

## Task 131

**Type:** Kinetics Experiment  
**Prompt:** Что быстрее реагирует с одной и той же кислотой: порошок `CaCO3` или крупный кусок той же массы?  
**Correct answer:** порошок.

---

## Task 132

**Type:** Kinetics Explanation  
**Prompt:** Почему порошок обычно реагирует быстрее крупного куска того же вещества?  
**Correct answer:** из-за большей площади поверхности контакта.

---

## Task 133

**Type:** Reaction Rate  
**Prompt:** Как повышение температуры обычно влияет на скорость химической реакции?  
**Correct answer:** увеличивает скорость большинства реакций.

---

## Task 134

**Type:** Reaction Rate  
**Prompt:** Как увеличение концентрации реагента обычно влияет на скорость реакции при прочих равных условиях?  
**Correct answer:** увеличивает её.

---

## Task 135

**Type:** Catalyst  
**Prompt:** Как катализатор влияет на энергию активации?  
**Correct answer:** предоставляет путь с меньшей энергией активации.

---

## Task 136

**Type:** Catalyst  
**Prompt:** Изменяет ли катализатор положение химического равновесия?  
**Correct answer:** нет.

---

## Task 137

**Type:** Catalyst  
**Prompt:** Как катализатор влияет на прямую и обратную реакции в обратимой системе?  
**Correct answer:** ускоряет обе реакции и позволяет быстрее достичь равновесия.

---

## Task 138

**Type:** Kinetics Experiment  
**Prompt:** Для заданной модельной реакции выбери фактор, который увеличит скорость:

- повышение температуры
- увеличение концентрации
- увеличение площади поверхности
- добавление подходящего катализатора

**Correct answer:** зависит от проверенного сценария.

---

## Task 139

**Type:** Equilibrium  
**Prompt:** Что означает динамическое химическое равновесие?  
**Correct answer:** скорости прямой и обратной реакций равны, поэтому макроскопический состав системы остаётся постоянным.

---

## Task 140

**Type:** Le Chatelier  
**Prompt:** Что происходит с равновесием, если увеличить концентрацию одного из реагентов?  
**Correct answer:** равновесие смещается в сторону расходования добавленного реагента.

---

## Task 141

**Type:** Equilibrium Control  
**Prompt:** Для реакции `N2 + 3H2 ⇌ 2NH3` увеличили давление. Куда сместится равновесие?  
**Correct answer:** вправо, в сторону меньшего количества молей газа.

---

## Task 142

**Type:** Equilibrium Control  
**Prompt:** Для реакции `N2 + 3H2 ⇌ 2NH3` уменьшили давление.  
**Correct answer:** равновесие сместится влево.

---

## Task 143

**Type:** Equilibrium Control  
**Prompt:** Реакция `N2 + 3H2 ⇌ 2NH3 + Q` экзотермическая. Что произойдёт при повышении температуры?  
**Correct answer:** равновесие сместится влево.

---

## Task 144

**Type:** Equilibrium Control  
**Prompt:** Для той же экзотермической реакции понизили температуру.  
**Correct answer:** равновесие сместится вправо.

---

## Task 145

**Type:** Equilibrium Control  
**Prompt:** Из системы `N2 + 3H2 ⇌ 2NH3` постоянно удаляют `NH3`. Куда смещается равновесие?  
**Correct answer:** вправо.

---

## Task 146

**Type:** Equilibrium Control  
**Prompt:** Что произойдёт с положением равновесия после добавления катализатора?  
**Correct answer:** положение не изменится; равновесие установится быстрее.

---

## Task 147

**Type:** Electrochemistry  
**Prompt:** На каком электроде происходит окисление?  
**Correct answer:** на аноде.

---

## Task 148

**Type:** Electrochemistry  
**Prompt:** На каком электроде происходит восстановление?  
**Correct answer:** на катоде.

---

## Task 149

**Type:** Electrode Process  
**Prompt:** Определи процесс: `Zn -> Zn^2+ + 2e-`.  
**Correct answer:** окисление.

---

## Task 150

**Type:** Electrode Process  
**Prompt:** Определи процесс: `Cu^2+ + 2e- -> Cu`.  
**Correct answer:** восстановление.

---

## Task 151

**Type:** Galvanic Cell  
**Prompt:** В гальваническом элементе `Zn/Cu` какой металл окисляется?  
**Correct answer:** цинк.

---

## Task 152

**Type:** Galvanic Cell  
**Prompt:** В элементе `Zn/Cu` в каком направлении движутся электроны по внешней цепи?  
**Correct answer:** от цинка к медному электроду.

---

## Task 153

**Type:** Corrosion Inspection  
**Prompt:** Стальная конструкция контактирует с водой и кислородом. Какой процесс может происходить?  
**Correct answer:** электрохимическая коррозия стали.

---

## Task 154

**Type:** Corrosion Inspection  
**Prompt:** Как выглядит анодный процесс железа при коррозии?  
**Correct answer:** `Fe -> Fe^2+ + 2e-`.

---

## Task 155

**Type:** Corrosion Protection  
**Prompt:** Как работает барьерное защитное покрытие металла?  
**Correct answer:** уменьшает контакт металла с агрессивной средой.

---

## Task 156

**Type:** Corrosion Protection  
**Prompt:** В чём принцип протекторной защиты?  
**Correct answer:** электрически соединённый более активный металл преимущественно окисляется, защищая основной металл.

---

## Task 157

**Type:** Corrosion Protection  
**Prompt:** Что такое пассивация металла?  
**Correct answer:** образование защитной поверхностной плёнки, снижающей скорость дальнейшей коррозии.

---

## Task 158

**Type:** Corrosion Environment  
**Prompt:** Какая из сред обычно наиболее благоприятна для электрохимической коррозии стали:

1. сухой воздух
2. влажная среда
3. влажная среда с растворённым электролитом

**Correct answer:** влажная среда с растворённым электролитом.

---

## Task 159

**Type:** Engineering Diagnosis  
**Prompt:** Два разных металла электрически контактируют во влажной среде. Какой дополнительный риск следует учитывать?  
**Correct answer:** образование гальванической пары и усиление коррозии менее благородного металла.

---

## Task 160

**Type:** Multi-Stage Engineering Mission  
**Prompt:** На строительной площадке обнаружена коррозия металлической балки.

Player must:

1. inspect the environment
2. identify oxidation
3. identify the anodic process
4. determine the likely corrosion mechanism
5. choose an appropriate protection principle

**Correct answer:** depends on the verified scenario parameters.

---

# Level 5 - Construction Chemist

Focus:

- cement
- concrete
- lime
- gypsum
- silicates
- construction water
- reinforcement corrosion
- carbonation
- aggressive environments
- construction materials

---

## Task 161

**Type:** Construction Material  
**Prompt:** Какое минеральное вяжущее является основой обычного цементного бетона?  
**Correct answer:** цемент.

---

## Task 162

**Type:** Construction Material  
**Prompt:** Назови основные компоненты обычного бетона.  
**Correct answer:**

- цемент
- вода
- мелкий заполнитель
- крупный заполнитель

Допускаются специальные добавки.

---

## Task 163

**Type:** Construction Chemistry  
**Prompt:** Как называется общий процесс взаимодействия цементных минералов с водой?  
**Correct answer:** гидратация.

---

## Task 164

**Type:** Construction Chemistry  
**Prompt:** Почему цементный материал постепенно твердеет после смешивания с водой?  
**Correct answer:** вследствие химических и физико-химических процессов гидратации цементных минералов и образования продуктов твердения.

---

## Task 165

**Type:** Concrete Mission  
**Prompt:** Как чрезмерное увеличение водоцементного отношения обычно влияет на затвердевший бетон?  
**Correct answer:** обычно увеличивает пористость и снижает прочность.

---

## Task 166

**Type:** Construction Material  
**Prompt:** Напиши формулу оксида кальция, используемого в известковом цикле.  
**Correct answer:** `CaO`.

---

## Task 167

**Type:** Reaction Bench  
**Prompt:** Закончи реакцию гашения извести: `CaO + H2O -> ?`  
**Correct answer:** `Ca(OH)2`.

---

## Task 168

**Type:** Reaction Bench  
**Prompt:** Закончи реакцию: `Ca(OH)2 + CO2 -> ?`  
**Correct answer:** `CaCO3 + H2O`.

---

## Task 169

**Type:** Construction Material  
**Prompt:** Какова формула природного двуводного гипса?  
**Correct answer:** `CaSO4·2H2O`.

---

## Task 170

**Type:** Construction Material  
**Prompt:** Какое соединение является основным компонентом известняка?  
**Correct answer:** `CaCO3`.

---

## Task 171

**Type:** Construction Reaction  
**Prompt:** Закончи реакцию обжига известняка: `CaCO3 -> ?`  
**Correct answer:** `CaO + CO2`.

---

## Task 172

**Type:** Sequence Puzzle  
**Prompt:** Расставь стадии известкового цикла в правильном порядке.  
**Correct answer:**

`CaCO3 -> CaO -> Ca(OH)2 -> CaCO3`.

---

## Task 173

**Type:** Furnace Mission  
**Prompt:** Какой тип химической реакции происходит при обжиге `CaCO3`?  
**Correct answer:** термическое разложение.

---

## Task 174

**Type:** Material Sorting  
**Prompt:** Сопоставь цемент, гипс и известь с соответствующими категориями строительных минеральных вяжущих и их игровыми образцами.  
**Correct answer:** определяется проверенной базой строительных материалов игры.

---

## Task 175

**Type:** Oxidation State  
**Prompt:** Определи степень окисления кремния в `SiO2`.  
**Correct answer:** `+4`.

---

## Task 176

**Type:** Water Chemistry  
**Prompt:** Какие соли преимущественно вызывают временную жёсткость воды?  
**Correct answer:** гидрокарбонаты кальция и магния.

---

## Task 177

**Type:** Water Chemistry  
**Prompt:** Какие соли могут участвовать в формировании постоянной жёсткости воды?  
**Correct answer:** например, сульфаты и хлориды кальция и магния.

---

## Task 178

**Type:** Ion Selection  
**Prompt:** Какие два катиона являются основными ионами жёсткости воды?  
**Correct answer:** `Ca^2+` и `Mg^2+`.

---

## Task 179

**Type:** Water Chemistry  
**Prompt:** Какое соединение часто является важным компонентом карбонатной накипи?  
**Correct answer:** `CaCO3`.

---

## Task 180

**Type:** Laboratory Mission  
**Prompt:** Даны две виртуальные пробы воды с различным содержанием `Ca^2+` и `Mg^2+`. Определи, какая вода жёстче.  
**Correct answer:** проба с большей суммарной концентрацией ионов жёсткости с учётом используемой единицы измерения.

---

## Task 181

**Type:** Reinforcement Chemistry  
**Prompt:** Почему высокая щёлочность нормального цементного бетона может защищать стальную арматуру?  
**Correct answer:** щёлочная среда способствует образованию и сохранению пассивного защитного состояния стали.

---

## Task 182

**Type:** Carbonation  
**Prompt:** Какой газ участвует в карбонизации бетона?  
**Correct answer:** `CO2`.

---

## Task 183

**Type:** Carbonation  
**Prompt:** Как карбонизация обычно влияет на pH цементного бетона?  
**Correct answer:** снижает pH.

---

## Task 184

**Type:** Reinforcement Corrosion  
**Prompt:** Чем опасно продвижение фронта карбонизации к арматуре?  
**Correct answer:** снижение щёлочности может нарушить пассивное состояние стали и повысить риск коррозии.

---

## Task 185

**Type:** Chloride Attack  
**Prompt:** Почему хлорид-ионы представляют опасность для железобетона?  
**Correct answer:** достаточное содержание хлоридов у поверхности арматуры может нарушать пассивное состояние стали и способствовать локальной коррозии.

---

## Task 186

**Type:** Construction Inspection  
**Prompt:** На поверхности железобетонной конструкции обнаружены трещины и ржавые пятна. Что необходимо проверить?  
**Correct answer:** состояние арматуры и возможную коррозию; окончательный вывод должен основываться на дополнительных данных миссии.

---

## Task 187

**Type:** pH Construction Mission  
**Prompt:** Вблизи арматуры измерен значительно более низкий pH, чем в исходном щёлочном бетоне. Какой риск возрастает?  
**Correct answer:** риск потери пассивации и последующей коррозии стали.

---

## Task 188

**Type:** Chloride Inspection  
**Prompt:** Около арматуры обнаружено повышенное содержание `Cl-`. Какой риск это создаёт?  
**Correct answer:** увеличивает вероятность нарушения пассивного состояния и локальной коррозии арматуры.

---

## Task 189

**Type:** Protection Decision  
**Prompt:** Какой общий принцип помогает уменьшить проникновение воды и агрессивных веществ в бетон?  
**Correct answer:** уменьшение проницаемости и/или применение подходящей защитной системы согласно условиям сценария.

---

## Task 190

**Type:** Construction Diagnosis  
**Prompt:** По результатам виртуального обследования определи основной источник проблемы:

- материал
- вода
- арматура
- внешняя химическая среда

**Correct answer:** определяется параметрами конкретного проверенного сценария.

---

## Task 191

**Type:** Aggressive Environment  
**Prompt:** Как кислая среда может влиять на цементный камень?  
**Correct answer:** может вступать в химические реакции с компонентами цементного камня и приводить к его постепенному разрушению.

---

## Task 192

**Type:** Sulfate Environment  
**Prompt:** Почему сульфатсодержащие среды важны для строительной химии?  
**Correct answer:** некоторые сульфатные воздействия способны вызывать химические превращения, образование расширяющихся продуктов и повреждение цементных материалов.

---

## Task 193

**Type:** Marine Environment Mission  
**Prompt:** Что необходимо контролировать при эксплуатации железобетона в солесодержащей или морской среде?  
**Correct answer:**

- проникновение агрессивных ионов
- состояние защитного слоя бетона
- состояние арматуры
- признаки коррозии и разрушения

---

## Task 194

**Type:** Porosity  
**Prompt:** Как высокая пористость обычно влияет на проникновение воды и растворённых веществ в бетон?  
**Correct answer:** облегчает их проникновение.

---

## Task 195

**Type:** Polymer Materials  
**Prompt:** Для чего применяются полимерные материалы и полимерные добавки в строительстве?  
**Correct answer:** для изменения требуемых свойств материалов, например адгезии, водостойкости, деформативности, герметичности или защитных характеристик; конкретный эффект зависит от материала.

---

## Task 196

**Type:** Multi-Stage Mission - Foundation

**Prompt:** Проведи химическую оценку воды, используемой в строительном сценарии.

Steps:

1. take virtual water sample
2. determine `Ca^2+`
3. determine `Mg^2+`
4. evaluate hardness
5. answer related chemistry question

**Correct answer:** determined from verified scenario parameters.

---

## Task 197

**Type:** Multi-Stage Mission - Reinforcement

**Prompt:** Исследуй состояние железобетонного элемента.

Steps:

1. inspect concrete
2. measure virtual pH
3. analyze chlorides
4. determine corrosion risk
5. identify relevant corrosion mechanism
6. choose a suitable protection principle

**Correct answer:** determined from verified scenario parameters.

---

## Task 198

**Type:** Multi-Stage Mission - Concrete Mix

**Prompt:** Сравни два виртуальных состава бетона с разным водоцементным отношением.

Player must:

1. compare water/cement ratios
2. predict relative porosity
3. predict likely strength trend
4. choose the composition better suited to the mission requirement

**Correct answer:** depends on verified mix parameters.

---

## Task 199

**Type:** Multi-Stage Mission - Materials Laboratory

**Prompt:** Определи три неизвестных строительных вещества:

- `CaO`
- `Ca(OH)2`
- `CaCO3`

Use:

- formulas
- names
- virtual reactions
- construction context

**Correct answers:**

- `CaO` — оксид кальция
- `Ca(OH)2` — гидроксид кальция
- `CaCO3` — карбонат кальция

---

## Task 200

**Type:** Final Mission - Construction Inspection

**Prompt:** Пройди пять станций подряд.

Stage 1:
formula or nomenclature task.

Stage 2:
reaction/equation task.

Stage 3:
solution calculation.

Stage 4:
corrosion/electrochemistry problem.

Stage 5:
construction chemistry problem.

The game should select tasks dynamically from previous levels.

Question selection should prioritize topics where the player previously made mistakes.

**Correct answer:** each stage uses a verified task from the existing chemistry bank.

**Success condition:** complete all five stages.

---

# Procedural Variant Rules

The 200 tasks above are seed tasks.

The final game should support significantly more unique task instances by creating deterministic variants.

Target:

- minimum 500 distinct playable variants
- desirable target 1000+

## Good candidates for procedural generation

- molar mass
- mole to mass conversion
- mass to mole conversion
- molarity
- dilution
- mass fraction
- simple pH tasks
- oxidation states
- formula construction
- ion matching
- nomenclature using a curated compound database

## Keep Curated

Prefer manually verified content for:

- complex chemical reactions
- net ionic equations
- complicated redox reactions
- equilibrium scenarios
- corrosion mechanisms
- concrete chemistry
- construction-material scenarios

---

# Anti-Repetition Rules

During one game round:

- never show an identical task twice
- avoid repeatedly using the same substance
- avoid more than two consecutive tasks from the same topic
- alternate stations
- alternate interaction types
- prioritize variety

If the player answers incorrectly, schedule another task involving the same concept after approximately 2-5 other tasks.

Use a different compound or context.

Example:

Player incorrectly identifies:

`BaSO3`

Do not immediately repeat `BaSO3`.

Later use:

- `Na2SO3`
- `CaSO3`
- `BaSO4`
- `Al2(SO4)3`

The purpose is to test the concept rather than memorization of one answer.

---

# Level 1 Round Rules

Default Level 1:

- 5 tasks
- 15-minute maximum
- finish immediately when all 5 tasks are completed

Prefer five different task types.

Example:

1. substance naming
2. formula builder
3. oxidation state
4. compound classification
5. periodic table

---

# Learning Feedback

Every incorrect answer should show:

1. correct answer
2. short explanation
3. relevant rule
4. one small example

Example:

**Incorrect.**

`BaSO3` is barium sulfite.

`SO3^2-` = sulfite.  
`SO4^2-` = sulfate.

Example:

`Na2SO4` is sodium sulfate.

Keep feedback concise so that gameplay remains fast.

---

# Chemistry Review Rule

If a chemistry task is ambiguous, uncertain or depends on missing conditions:

- do not guess
- mark it as `review-required`
- add it to `CHEMISTRY_REVIEW.md`
- exclude it from production gameplay until verified

All normal gameplay tasks should have:

`reviewStatus: verified`

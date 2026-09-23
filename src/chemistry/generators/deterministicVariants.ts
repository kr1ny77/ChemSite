import type { TaskDefinition } from '../types'

const atomicMasses: Readonly<Record<string, number>> = {
  H: 1.008,
  C: 12.011,
  N: 14.007,
  O: 15.999,
  Na: 22.99,
  Mg: 24.305,
  Al: 26.982,
  P: 30.974,
  S: 32.06,
  Cl: 35.45,
  K: 39.098,
  Ca: 40.078,
  Fe: 55.845,
  Cu: 63.546,
  Ba: 137.327,
}

function readNumber(formula: string, cursor: { value: number }) {
  let digits = ''
  while (/\d/.test(formula[cursor.value] ?? '')) {
    digits += formula[cursor.value]
    cursor.value += 1
  }
  return digits ? Number(digits) : 1
}

function parseFormulaGroup(formula: string, cursor: { value: number }): number {
  let total = 0
  while (cursor.value < formula.length && formula[cursor.value] !== ')') {
    if (formula[cursor.value] === '(') {
      cursor.value += 1
      const groupMass = parseFormulaGroup(formula, cursor)
      cursor.value += 1
      total += groupMass * readNumber(formula, cursor)
      continue
    }
    const symbolMatch = formula.slice(cursor.value).match(/^[A-Z][a-z]?/)
    if (!symbolMatch || atomicMasses[symbolMatch[0]] === undefined) {
      throw new Error(`Unsupported formula token at ${formula.slice(cursor.value)}`)
    }
    cursor.value += symbolMatch[0].length
    total += atomicMasses[symbolMatch[0]] * readNumber(formula, cursor)
  }
  return total
}

export function calculateMolarMass(formula: string) {
  return parseFormulaGroup(formula, { value: 0 })
}

const compounds = [
  ['H2O', 'воды'], ['CO2', 'углекислого газа'], ['NaCl', 'хлорида натрия'], ['NaOH', 'гидроксида натрия'],
  ['CaCO3', 'карбоната кальция'], ['H2SO4', 'серной кислоты'], ['KOH', 'гидроксида калия'], ['MgO', 'оксида магния'],
  ['CaO', 'оксида кальция'], ['Al2O3', 'оксида алюминия'], ['Fe2O3', 'оксида железа(III)'], ['CuSO4', 'сульфата меди(II)'],
  ['Na2CO3', 'карбоната натрия'], ['KCl', 'хлорида калия'], ['NH3', 'аммиака'], ['O2', 'кислорода'],
  ['HCl', 'хлороводорода'], ['HNO3', 'азотной кислоты'], ['Ca(OH)2', 'гидроксида кальция'], ['MgCl2', 'хлорида магния'],
] as const

const formulaPairs = [
  ['NaCl', 'хлорида натрия', 'Na⁺ и Cl⁻'], ['K2SO4', 'сульфата калия', 'K⁺ и SO₄²⁻'],
  ['CaCO3', 'карбоната кальция', 'Ca²⁺ и CO₃²⁻'], ['Mg(OH)2', 'гидроксида магния', 'Mg²⁺ и OH⁻'],
  ['Al2(SO4)3', 'сульфата алюминия', 'Al³⁺ и SO₄²⁻'], ['Fe(NO3)3', 'нитрата железа(III)', 'Fe³⁺ и NO₃⁻'],
  ['CuCl2', 'хлорида меди(II)', 'Cu²⁺ и Cl⁻'], ['Ba(HCO3)2', 'гидрокарбоната бария', 'Ba²⁺ и HCO₃⁻'],
  ['Na2CO3', 'карбоната натрия', 'Na⁺ и CO₃²⁻'], ['KNO3', 'нитрата калия', 'K⁺ и NO₃⁻'],
  ['Ca3(PO4)2', 'фосфата кальция', 'Ca²⁺ и PO₄³⁻'], ['MgCl2', 'хлорида магния', 'Mg²⁺ и Cl⁻'],
  ['Al(OH)3', 'гидроксида алюминия', 'Al³⁺ и OH⁻'], ['FeSO4', 'сульфата железа(II)', 'Fe²⁺ и SO₄²⁻'],
  ['Cu(NO3)2', 'нитрата меди(II)', 'Cu²⁺ и NO₃⁻'], ['BaSO4', 'сульфата бария', 'Ba²⁺ и SO₄²⁻'],
  ['NaHCO3', 'гидрокарбоната натрия', 'Na⁺ и HCO₃⁻'], ['K3PO4', 'фосфата калия', 'K⁺ и PO₄³⁻'],
  ['CaCl2', 'хлорида кальция', 'Ca²⁺ и Cl⁻'], ['MgSO4', 'сульфата магния', 'Mg²⁺ и SO₄²⁻'],
] as const

const oxidationVariants = [
  ['S', 'H2SO4', '+6'], ['N', 'NH3', '-3'], ['Fe', 'Fe2O3', '+3'], ['C', 'CO2', '+4'], ['Cl', 'HCl', '-1'],
  ['P', 'K3PO4', '+5'], ['Cu', 'CuO', '+2'], ['Al', 'Al2O3', '+3'], ['Ca', 'CaCO3', '+2'], ['N', 'HNO3', '+5'],
] as const

function baseTask(
  id: string,
  definition: Omit<TaskDefinition, 'id' | 'points' | 'procedural' | 'reviewStatus'>,
): TaskDefinition {
  return { ...definition, id, points: definition.level === 1 ? 100 : 140, procedural: true, reviewStatus: 'verified' }
}

const formulaVariants = formulaPairs.flatMap(([formula, name, ions], pairIndex) => [
  baseTask(`GV-L1-F-${String(pairIndex + 1).padStart(3, '0')}-A`, {
    level: 1, topic: 'Неорганические соединения', subtopic: 'Составление формул', difficulty: 2,
    station: 'formula-board', interactionType: 'formula-builder', prompt: `На формульной доске собери формулу ${name}.`, correctAnswer: formula,
    explanation: `Формула ${formula} получается из электронейтрального соотношения ионов ${ions}.`,
    rule: 'Сумма зарядов ионов в формульной единице равна нулю.', example: `${ions} → ${formula}.`,
    hint: `Уравняй заряды ионов ${ions}.`, tags: ['generated', 'formula', formula], parameters: { compound: formula },
  }),
  baseTask(`GV-L1-F-${String(pairIndex + 1).padStart(3, '0')}-B`, {
    level: 1, topic: 'Неорганические соединения', subtopic: 'Ионные формулы', difficulty: 2,
    station: 'formula-board', interactionType: 'formula-builder', prompt: `Какая электронейтральная формула соответствует ионам ${ions}?`, correctAnswer: formula,
    explanation: `Минимальное целочисленное соотношение ${ions} даёт формулу ${formula}.`,
    rule: 'Индексы выбирают по наименьшему общему кратному модулей зарядов.', example: `Проверка заряда приводит к ${formula}.`,
    hint: 'Найди минимальные индексы, при которых общий заряд равен нулю.', tags: ['generated', 'ions', formula], parameters: { compound: formula },
  }),
])

const oxidationStateVariants = oxidationVariants.flatMap(([element, formula, answer], index) => [
  baseTask(`GV-L1-OX-${String(index + 1).padStart(3, '0')}-A`, {
    level: 1, topic: 'Степени окисления', subtopic: 'Расчёт степени окисления', difficulty: 2,
    station: 'formula-board', interactionType: 'oxidation-state', prompt: `Определи степень окисления ${element} в ${formula}.`, correctAnswer: answer,
    explanation: `Степень окисления ${element} в ${formula} равна ${answer} по условию электронейтральности соединения.`,
    rule: 'Сумма степеней окисления атомов нейтрального вещества равна нулю.', example: `Для ${formula} баланс даёт ${element}${answer}.`,
    hint: 'Используй известные степени окисления остальных элементов.', tags: ['generated', 'oxidation-state', element], parameters: { compound: formula },
  }),
  baseTask(`GV-L1-OX-${String(index + 1).padStart(3, '0')}-B`, {
    level: 1, topic: 'Степени окисления', subtopic: 'Проверка баланса', difficulty: 2,
    station: 'formula-board', interactionType: 'oxidation-state', prompt: `Какое значение ${element} восстанавливает баланс степеней окисления в ${formula}?`, correctAnswer: answer,
    explanation: `Алгебраическая сумма всех степеней окисления в ${formula} равна нулю, поэтому для ${element} получается ${answer}.`,
    rule: 'Учитывай число атомов каждого элемента по индексам.', example: `${element} имеет значение ${answer}.`,
    hint: 'Составь уравнение для суммы степеней окисления.', tags: ['generated', 'oxidation-state', 'balance', element], parameters: { compound: formula },
  }),
])

export const generatedLevel1Tasks: readonly TaskDefinition[] = [
  ...formulaVariants,
  ...oxidationStateVariants,
]

const molarMassTasks = compounds.map(([formula, name], index) => {
  const value = Number(calculateMolarMass(formula).toFixed(2))
  return baseTask(`GV-L3-MM-${String(index + 1).padStart(3, '0')}`, {
    level: 3, topic: 'Количество вещества', subtopic: 'Молярная масса', difficulty: 2,
    station: 'solution-laboratory', interactionType: 'numeric-calculation', prompt: `Контрольный расчёт: найди молярную массу ${formula} в g/mol.`,
    correctAnswer: { value, absoluteTolerance: 0.15, unit: 'g/mol' },
    explanation: `Сумма атомных масс в формуле ${formula} даёт ${value} g/mol.`,
    rule: 'Молярная масса равна сумме атомных масс с учётом индексов.', example: `Рассчитано для ${name}.`,
    hint: 'Умножь атомные массы на соответствующие индексы.', tags: ['generated', 'molar-mass', formula], parameters: { compound: formula },
  })
})

const moleFactors = [0.25, 0.5, 1.5, 2]
const moleTasks = compounds.flatMap(([formula, name], compoundIndex) => {
  const molarMass = calculateMolarMass(formula)
  return moleFactors.map((moles, factorIndex) => {
    const mass = Number((molarMass * moles).toFixed(2))
    return baseTask(`GV-L3-MOLE-${String(compoundIndex + 1).padStart(2, '0')}-${factorIndex + 1}`, {
      level: 3, topic: 'Количество вещества', subtopic: 'Масса в моли', difficulty: 2,
      station: 'solution-laboratory', interactionType: 'virtual-scales', prompt: `Сколько mol ${name} содержится в ${mass} g ${formula}?`,
      correctAnswer: { value: moles, absoluteTolerance: 0.02, unit: 'mol' },
      explanation: `n = m/M = ${mass}/${molarMass.toFixed(2)} ≈ ${moles} mol.`,
      rule: 'Количество вещества n = m/M.', example: `Расчёт использует M(${formula}) = ${molarMass.toFixed(2)} g/mol.`,
      hint: 'Раздели массу образца на молярную массу.', tags: ['generated', 'moles', formula], parameters: { compound: formula },
    })
  })
})

const massTasks = compounds.slice(0, 10).flatMap(([formula, name], compoundIndex) => [0.2, 1.25].map((moles, variantIndex) => {
  const value = Number((calculateMolarMass(formula) * moles).toFixed(2))
  return baseTask(`GV-L3-MASS-${String(compoundIndex + 1).padStart(2, '0')}-${variantIndex + 1}`, {
    level: 3, topic: 'Количество вещества', subtopic: 'Моли в массу', difficulty: 2,
    station: 'solution-laboratory', interactionType: 'virtual-scales', prompt: `Найди массу ${moles} mol ${name} в граммах.`,
    correctAnswer: { value, absoluteTolerance: 0.15, unit: 'g' },
    explanation: `m = nM = ${moles}·${calculateMolarMass(formula).toFixed(2)} = ${value} g.`,
    rule: 'Массу рассчитывают по формуле m = nM.', example: `Использована формула ${formula}.`,
    hint: 'Умножь количество вещества на молярную массу.', tags: ['generated', 'mass', formula], parameters: { compound: formula },
  })
}))

const amounts = [0.05, 0.1, 0.2, 0.4, 0.5, 0.75, 1, 1.2, 1.5, 2]
const volumes = [0.25, 0.5, 1, 2, 2.5]
const molarityTasks = amounts.flatMap((amount, amountIndex) => volumes.map((volume, volumeIndex) => {
  const value = Number((amount / volume).toFixed(3))
  return baseTask(`GV-L3-C-${String(amountIndex + 1).padStart(2, '0')}-${volumeIndex + 1}`, {
    level: 3, topic: 'Растворы', subtopic: 'Молярная концентрация', difficulty: 2,
    station: 'solution-laboratory', interactionType: 'numeric-calculation', prompt: `${amount} mol вещества находится в ${volume} L раствора. Найди C.`,
    correctAnswer: { value, absoluteTolerance: 0.01, unit: 'mol/L' },
    explanation: `C = n/V = ${amount}/${volume} = ${value} mol/L.`,
    rule: 'Молярная концентрация C = n/V.', example: 'Объём подставляют в литрах.',
    hint: 'Раздели количество вещества на объём раствора.', tags: ['generated', 'molarity', 'solution'],
  })
}))

const stockConcentrations = [1, 2, 2.5, 4, 5]
const targetConcentrations = [0.1, 0.2]
const targetVolumes = [100, 200, 250, 500, 1000]
const dilutionTasks = stockConcentrations.flatMap((stock, stockIndex) => targetConcentrations.flatMap((target, targetIndex) =>
  targetVolumes.map((volume, volumeIndex) => {
    const value = Number((target * volume / stock).toFixed(2))
    return baseTask(`GV-L3-DIL-${stockIndex + 1}-${targetIndex + 1}-${volumeIndex + 1}`, {
      level: 3, topic: 'Растворы', subtopic: 'Разбавление', difficulty: 2,
      station: 'solution-laboratory', interactionType: 'solution-preparation',
      prompt: `Из раствора ${stock} mol/L получи ${volume} mL раствора ${target} mol/L. Какой объём исходного раствора взять?`,
      correctAnswer: { value, absoluteTolerance: 0.5, unit: 'mL' },
      explanation: `V₁ = C₂V₂/C₁ = ${target}·${volume}/${stock} = ${value} mL.`,
      rule: 'При разбавлении C₁V₁ = C₂V₂.', example: 'Количество растворённого вещества сохраняется.',
      hint: 'Вырази V₁ из уравнения разбавления.', tags: ['generated', 'dilution', 'solution'],
    })
  }),
))

const soluteMasses = [5, 10, 15, 20, 25, 30, 40, 50]
const solutionMasses = [100, 200, 250, 500, 1000]
const massFractionTasks = soluteMasses.flatMap((solute, soluteIndex) => solutionMasses.map((solution, solutionIndex) => {
  const value = Number((solute / solution * 100).toFixed(2))
  return baseTask(`GV-L3-W-${String(soluteIndex + 1).padStart(2, '0')}-${solutionIndex + 1}`, {
    level: 3, topic: 'Растворы', subtopic: 'Массовая доля', difficulty: 2,
    station: 'solution-laboratory', interactionType: 'numeric-calculation', prompt: `Тренировочная проба: в ${solution} g раствора содержится ${solute} g вещества. Найди массовую долю в процентах.`,
    correctAnswer: { value, absoluteTolerance: 0.1, unit: '%' },
    explanation: `Расчёт массовой доли: w = ${solute}/${solution}·100% = ${value}%.`,
    rule: 'w = m(вещества)/m(раствора)·100%.', example: 'Массы должны быть выражены в одинаковых единицах.',
    hint: 'Раздели массу вещества на массу всего раствора.', tags: ['generated', 'mass-fraction', 'solution'],
  })
}))

export const generatedLevel3Tasks: readonly TaskDefinition[] = [
  ...molarMassTasks,
  ...moleTasks,
  ...massTasks,
  ...molarityTasks,
  ...dilutionTasks,
  ...massFractionTasks,
]

export const deterministicVariantCount = generatedLevel1Tasks.length + generatedLevel3Tasks.length

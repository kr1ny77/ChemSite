import type { TaskDefinition } from '../types'

export type PracticeTopic = {
  id: string
  name: string
  description: string
  terms: string[]
  icon: string
}

export const PRACTICE_TOPICS: readonly PracticeTopic[] = [
  { id: 'formulas', name: 'Формулы и названия', description: 'Ионы, формулы, классы и номенклатура', terms: ['формул', 'номенклатур', 'неорганическ', 'ионные формулы'], icon: 'ƒx' },
  { id: 'oxidation', name: 'Степени окисления', description: 'Баланс зарядов и электронные переходы', terms: ['степени окисления', 'redox', 'oxidation-state'], icon: '±' },
  { id: 'reactions', name: 'Реакции', description: 'Уравнения, осадки, газы и ионные процессы', terms: ['реакц', 'осад', 'ионн', 'redox'], icon: '⇌' },
  { id: 'solutions', name: 'Растворы и pH', description: 'Концентрации, разбавление и кислотность', terms: ['раствор', 'кислотност', 'pH', 'molarity', 'dilution'], icon: 'mL' },
  { id: 'thermochemistry', name: 'Термохимия', description: 'Энтальпия, диаграммы и закон Гесса', terms: ['термохим', 'enthalpy', 'hess'], icon: 'ΔH' },
  { id: 'equilibrium', name: 'Кинетика и равновесие', description: 'Скорость, катализ и принцип Ле Шателье', terms: ['кинетик', 'равновес', 'equilibrium', 'catalyst'], icon: 'k' },
  { id: 'electrochemistry', name: 'Электрохимия', description: 'Электроды, элементы и перенос электронов', terms: ['электрохим', 'galvanic', 'electrode'], icon: 'e⁻' },
  { id: 'corrosion', name: 'Коррозия', description: 'Диагностика среды и принципы защиты', terms: ['корроз', 'corrosion', 'reinforcement'], icon: 'Fe' },
  { id: 'materials', name: 'Строительные материалы', description: 'Цемент, бетон, известь, гипс и вода', terms: ['строительн', 'бетон', 'цемент', 'извест', 'гипс', 'water', 'construction'], icon: 'MPa' },
] as const

export function filterPracticeTasks(bank: readonly TaskDefinition[], topicId: string) {
  const topic = PRACTICE_TOPICS.find((candidate) => candidate.id === topicId)
  if (!topic) return []
  return bank.filter((task) => {
    const haystack = `${task.topic} ${task.subtopic} ${task.tags.join(' ')}`.toLocaleLowerCase('ru')
    return topic.terms.some((term) => haystack.includes(term.toLocaleLowerCase('ru')))
  })
}

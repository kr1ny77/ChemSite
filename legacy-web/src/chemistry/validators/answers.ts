import type { TaskDefinition } from '../types'

const subscriptMap: Record<string, string> = {
  '₀': '0', '₁': '1', '₂': '2', '₃': '3', '₄': '4',
  '₅': '5', '₆': '6', '₇': '7', '₈': '8', '₉': '9',
}

const superscriptMap: Record<string, string> = {
  '⁰': '0', '¹': '1', '²': '2', '³': '3', '⁴': '4',
  '⁵': '5', '⁶': '6', '⁷': '7', '⁸': '8', '⁹': '9',
  '⁺': '+', '⁻': '-',
}

export function normalizeTextAnswer(value: string) {
  return value
    .normalize('NFKC')
    .toLocaleLowerCase('ru')
    .replaceAll('ё', 'е')
    .replace(/−/g, '-')
    .trim()
    .replace(/[.,;:!?]+$/g, '')
    .replace(/\s+/g, ' ')
}

export function normalizeChemicalFormula(value: string) {
  return [...value]
    .map((character) => subscriptMap[character] ?? superscriptMap[character] ?? character)
    .join('')
    .replace(/[·•]/g, '·')
    .replace(/\s+/g, '')
    .replace(/\^/g, '')
    .replace(/−/g, '-')
    .trim()
}

function splitEquationSide(side: string) {
  const compact = normalizeChemicalFormula(side)
  const species: string[] = []
  let current = ''
  for (let index = 0; index < compact.length; index += 1) {
    const character = compact[index]
    if (character !== '+') {
      current += character
      continue
    }
    if (compact[index + 1] === '+') {
      current += '+'
      species.push(current)
      current = ''
      index += 1
      continue
    }
    if (index === compact.length - 1) {
      current += '+'
      continue
    }
    species.push(current)
    current = ''
  }
  if (current) species.push(current)
  return species.filter(Boolean).sort().join('+')
}

export function normalizeChemicalEquation(value: string) {
  const normalizedArrow = value
    .replace(/⇌|↔|<=>/g, '<->')
    .replace(/→|=>|=/g, '->')
    .replace(/[↓↑]/g, '')
  const arrow = normalizedArrow.includes('<->') ? '<->' : '->'
  const sides = normalizedArrow.split(arrow)
  if (sides.length !== 2) return normalizeChemicalFormula(normalizedArrow)
  return `${splitEquationSide(sides[0])}${arrow}${splitEquationSide(sides[1])}`
}

function parseNumericAnswer(value: string) {
  const compact = value.trim().replace(',', '.').replace(/×/g, '*')
  const powerMatch = compact.match(/^([+-]?\d+(?:\.\d+)?)\s*\*?\s*10\^?([+-]?\d+)/i)
  if (powerMatch) return Number(powerMatch[1]) * 10 ** Number(powerMatch[2])
  const numeric = compact.match(/[+-]?\d+(?:\.\d+)?(?:e[+-]?\d+)?/i)
  return numeric ? Number(numeric[0]) : Number.NaN
}

function normalizeOxidationState(value: string) {
  const compact = value.replace(/\s+/g, '').replace(/[()]/g, '').toUpperCase()
  const trailingSign = compact.match(/^(\d+)([+-])$/)
  if (trailingSign) return `${trailingSign[2]}${trailingSign[1]}`
  return compact
}

function usesFormulaValidation(task: TaskDefinition) {
  return task.interactionType === 'formula-builder' || task.interactionType === 'ion-builder'
}

function usesEquationValidation(task: TaskDefinition) {
  return [
    'equation-completion',
    'equation-balancing',
    'ionic-equation',
    'dissociation',
    'virtual-mixing',
  ].includes(task.interactionType)
}

export function normalizeTaskAnswer(task: TaskDefinition, answer: string) {
  if (usesFormulaValidation(task)) return normalizeChemicalFormula(answer)
  if (usesEquationValidation(task)) return normalizeChemicalEquation(answer)
  if (task.interactionType === 'oxidation-state') return normalizeOxidationState(answer)
  return normalizeTextAnswer(answer)
}

export function validateTaskAnswer(task: TaskDefinition, answer: string) {
  const submitted = normalizeTaskAnswer(task, answer)
  if (typeof task.correctAnswer !== 'string') {
    const value = parseNumericAnswer(answer)
    const absoluteError = Math.abs(value - task.correctAnswer.value)
    const absoluteTolerance = task.correctAnswer.absoluteTolerance ?? 0
    const relativeTolerance = task.correctAnswer.relativeTolerance ?? 0
    const relativeLimit = Math.abs(task.correctAnswer.value) * relativeTolerance
    return {
      correct: Number.isFinite(value) && absoluteError <= Math.max(absoluteTolerance, relativeLimit),
      normalizedAnswer: Number.isFinite(value) ? String(value) : submitted,
    }
  }
  const accepted = [task.correctAnswer, ...(task.acceptedAnswers ?? [])]
    .map((candidate) => normalizeTaskAnswer(task, candidate))
  return {
    correct: accepted.includes(submitted),
    normalizedAnswer: submitted,
  }
}

export function formatCorrectAnswer(task: TaskDefinition) {
  if (typeof task.correctAnswer === 'string') return task.correctAnswer
  return `${task.correctAnswer.value}${task.correctAnswer.unit ? ` ${task.correctAnswer.unit}` : ''}`
}

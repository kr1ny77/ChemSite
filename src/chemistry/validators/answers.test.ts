import { describe, expect, it } from 'vitest'
import { level1Tasks } from '../tasks/level1'
import { normalizeChemicalEquation, normalizeChemicalFormula, normalizeTextAnswer, validateTaskAnswer } from './answers'

describe('chemistry answer validators', () => {
  it('normalizes Russian text without losing meaning', () => {
    expect(normalizeTextAnswer('  Сульфат   Бария. ')).toBe('сульфат бария')
  })

  it('normalizes formula subscripts and charge notation', () => {
    expect(normalizeChemicalFormula(' SO₄²⁻ ')).toBe('SO42-')
    expect(normalizeChemicalFormula('SO4^2-')).toBe('SO42-')
  })

  it('validates formula and oxidation-state variants', () => {
    expect(validateTaskAnswer(level1Tasks[7], 'Al₂(SO₄)₃').correct).toBe(true)
    expect(validateTaskAnswer(level1Tasks[26], '6+').correct).toBe(true)
    expect(validateTaskAnswer(level1Tasks[28], '-III').correct).toBe(true)
  })

  it('rejects a chemically different ion', () => {
    expect(validateTaskAnswer(level1Tasks[21], 'SO₃²⁻').correct).toBe(false)
  })

  it('accepts equivalent equation ordering and arrow notation', () => {
    expect(normalizeChemicalEquation('O2 + 2H2 => 2H2O')).toBe(
      normalizeChemicalEquation('2H2 + O2 -> 2H2O'),
    )
    expect(normalizeChemicalEquation('SO4^2- + Ba^2+ -> BaSO4↓')).toBe(
      normalizeChemicalEquation('Ba^2+ + SO4^2- -> BaSO4'),
    )
  })

  it('validates numeric answers with absolute tolerance and units', () => {
    const numericTask = {
      ...level1Tasks[0],
      interactionType: 'numeric-calculation' as const,
      correctAnswer: { value: 100.09, absoluteTolerance: 0.2, unit: 'g/mol' },
    }
    expect(validateTaskAnswer(numericTask, '100,1 g/mol').correct).toBe(true)
    expect(validateTaskAnswer(numericTask, '99.5').correct).toBe(false)
  })
})

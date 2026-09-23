import { describe, expect, it } from 'vitest'
import { validateTaskAnswer } from '../validators/answers'
import { level3Tasks } from './level3'

describe('Level 3 task bank', () => {
  it('contains 40 unique verified solution tasks with feedback', () => {
    expect(level3Tasks).toHaveLength(40)
    expect(new Set(level3Tasks.map((task) => task.id)).size).toBe(40)
    for (const task of level3Tasks) {
      expect(task.reviewStatus).toBe('verified')
      expect(task.explanation.length).toBeGreaterThan(20)
      expect(task.hint.length).toBeGreaterThan(10)
    }
  })

  it('validates molar-mass, dilution, pH and dissociation answers', () => {
    expect(validateTaskAnswer(level3Tasks[2], '100,1 g/mol').correct).toBe(true)
    expect(validateTaskAnswer(level3Tasks[16], '100 mL').correct).toBe(true)
    expect(validateTaskAnswer(level3Tasks[25], '1×10^-5 mol/L').correct).toBe(true)
    expect(validateTaskAnswer(level3Tasks[29], '2Cl- + Ca^2+ <- CaCl2').correct).toBe(false)
    expect(validateTaskAnswer(level3Tasks[29], 'CaCl2 -> 2Cl- + Ca^2+').correct).toBe(true)
  })
})

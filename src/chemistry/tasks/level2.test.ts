import { describe, expect, it } from 'vitest'
import { validateTaskAnswer } from '../validators/answers'
import { level2Tasks } from './level2'

describe('Level 2 task bank', () => {
  it('contains 40 unique verified reaction tasks with feedback', () => {
    expect(level2Tasks).toHaveLength(40)
    expect(new Set(level2Tasks.map((task) => task.id)).size).toBe(40)
    for (const task of level2Tasks) {
      expect(task.reviewStatus).toBe('verified')
      expect(task.explanation.length).toBeGreaterThan(20)
      expect(task.hint.length).toBeGreaterThan(10)
    }
  })

  it('validates balanced and ionic equation variants structurally', () => {
    expect(validateTaskAnswer(level2Tasks[7], 'O2 + 2H2 => 2H2O').correct).toBe(true)
    expect(validateTaskAnswer(level2Tasks[21], 'SO4^2- + Ba^2+ -> BaSO4↓').correct).toBe(true)
  })
})

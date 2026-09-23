import { describe, expect, it } from 'vitest'
import { validateTaskAnswer } from '../validators/answers'
import {
  calculateMolarMass,
  deterministicVariantCount,
  generatedLevel1Tasks,
  generatedLevel3Tasks,
} from './deterministicVariants'

describe('deterministic chemistry variants', () => {
  const tasks = [...generatedLevel1Tasks, ...generatedLevel3Tasks]

  it('creates 320 unique verified playable variants', () => {
    expect(deterministicVariantCount).toBe(320)
    expect(tasks).toHaveLength(320)
    expect(new Set(tasks.map((task) => task.id)).size).toBe(320)
    expect(tasks.every((task) => task.procedural && task.reviewStatus === 'verified')).toBe(true)
  })

  it('calculates molar masses including parenthesized groups', () => {
    expect(calculateMolarMass('H2O')).toBeCloseTo(18.015, 3)
    expect(calculateMolarMass('CaCO3')).toBeCloseTo(100.086, 3)
    expect(calculateMolarMass('Ca(OH)2')).toBeCloseTo(74.092, 3)
  })

  it('accepts every generated canonical answer', () => {
    for (const task of tasks) {
      const answer = typeof task.correctAnswer === 'string' ? task.correctAnswer : String(task.correctAnswer.value)
      expect(validateTaskAnswer(task, answer).correct, task.id).toBe(true)
    }
  })
})

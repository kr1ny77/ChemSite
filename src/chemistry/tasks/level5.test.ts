import { describe, expect, it } from 'vitest'
import { validateTaskAnswer } from '../validators/answers'
import { level5Tasks } from './level5'

describe('Level 5 task bank', () => {
  it('contains 40 unique verified construction chemistry tasks', () => {
    expect(level5Tasks).toHaveLength(40)
    expect(new Set(level5Tasks.map((task) => task.id)).size).toBe(40)
    for (const task of level5Tasks) {
      expect(task.reviewStatus).toBe('verified')
      expect(task.explanation.length).toBeGreaterThan(20)
      expect(task.hint.length).toBeGreaterThan(10)
      expect(task.tags.length).toBeGreaterThan(1)
    }
  })

  it('validates lime, gypsum, water-hardness and reinforcement answers', () => {
    expect(validateTaskAnswer(level5Tasks[5], 'CaO').correct).toBe(true)
    expect(validateTaskAnswer(level5Tasks[8], 'CaSO₄·2H₂O').correct).toBe(true)
    expect(validateTaskAnswer(level5Tasks[17], 'Mg²⁺ и Ca²⁺').correct).toBe(true)
    expect(validateTaskAnswer(level5Tasks[35], '3.0 mmol/L').correct).toBe(true)
    expect(validateTaskAnswer(level5Tasks[36], 'высокий риск депассивации и электрохимической коррозии арматуры').correct).toBe(true)
  })

  it('provides staged data for construction missions', () => {
    const missions = level5Tasks.filter((task) => task.interactionType === 'construction-mission')
    expect(missions.length).toBeGreaterThanOrEqual(8)
    expect(missions.every((task) => (task.parameters?.missionSteps?.length ?? 0) >= 3)).toBe(true)
  })
})

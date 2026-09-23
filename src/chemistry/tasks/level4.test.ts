import { describe, expect, it } from 'vitest'
import { validateTaskAnswer } from '../validators/answers'
import { level4Tasks } from './level4'

describe('Level 4 task bank', () => {
  it('contains 40 unique verified engineering chemistry tasks with complete feedback', () => {
    expect(level4Tasks).toHaveLength(40)
    expect(new Set(level4Tasks.map((task) => task.id)).size).toBe(40)
    for (const task of level4Tasks) {
      expect(task.reviewStatus).toBe('verified')
      expect(task.explanation.length).toBeGreaterThan(20)
      expect(task.hint.length).toBeGreaterThan(10)
      expect(task.tags.length).toBeGreaterThan(1)
    }
  })

  it('validates Hess calculations, equilibrium, electrochemistry and corrosion', () => {
    expect(validateTaskAnswer(level4Tasks[6], '-30 kJ').correct).toBe(true)
    expect(validateTaskAnswer(level4Tasks[7], '+60').correct).toBe(true)
    expect(validateTaskAnswer(level4Tasks[20], 'вправо, к NH₃').correct).toBe(true)
    expect(validateTaskAnswer(level4Tasks[31], 'от Zn к Cu').correct).toBe(true)
    expect(validateTaskAnswer(level4Tasks[33], 'Fe → Fe²⁺ + 2e⁻').correct).toBe(true)
  })

  it('covers every Level 4 specialist mechanic and station', () => {
    const interactions = new Set(level4Tasks.map((task) => task.interactionType))
    expect(interactions.has('hess-puzzle')).toBe(true)
    expect(interactions.has('kinetics-experiment')).toBe(true)
    expect(interactions.has('equilibrium-control')).toBe(true)
    expect(interactions.has('electrochemistry')).toBe(true)
    expect(interactions.has('corrosion-inspection')).toBe(true)
    expect(interactions.has('construction-mission')).toBe(true)
    expect(level4Tasks.some((task) => task.station === 'electrochemistry-station')).toBe(true)
    expect(level4Tasks.some((task) => task.station === 'corrosion-test-rig')).toBe(true)
  })
})

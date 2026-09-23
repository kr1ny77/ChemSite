import { describe, expect, it } from 'vitest'
import { generatedLevel1Tasks, generatedLevel3Tasks } from './generators/deterministicVariants'
import { level1Tasks } from './tasks/level1'
import { level2Tasks } from './tasks/level2'
import { level3Tasks } from './tasks/level3'
import { level4Tasks } from './tasks/level4'
import { level5Tasks } from './tasks/level5'
import { validateTaskAnswer } from './validators/answers'

const curated = [...level1Tasks, ...level2Tasks, ...level3Tasks, ...level4Tasks, ...level5Tasks]
const playable = [...curated, ...generatedLevel1Tasks, ...generatedLevel3Tasks]

describe('complete chemistry content integrity', () => {
  it('contains 200 curated seeds and 520 distinct playable instances', () => {
    expect(curated).toHaveLength(200)
    expect(playable).toHaveLength(520)
    expect(new Set(playable.map((task) => task.id)).size).toBe(520)
    expect(new Set(playable.map((task) => task.prompt)).size).toBe(520)
  })

  it('accepts every canonical answer and exposes a valid choice where options are shown', () => {
    for (const task of playable) {
      const canonical = typeof task.correctAnswer === 'string' ? task.correctAnswer : String(task.correctAnswer.value)
      expect(validateTaskAnswer(task, canonical).correct, `canonical ${task.id}`).toBe(true)
      if (task.options) {
        expect(task.options.some((option) => validateTaskAnswer(task, option).correct), `options ${task.id}`).toBe(true)
      }
    }
  })

  it('keeps explanations, hints, tags and production review status complete', () => {
    for (const task of playable) {
      expect(task.reviewStatus, task.id).toBe('verified')
      expect(task.explanation.length, task.id).toBeGreaterThan(20)
      expect(task.hint.length, task.id).toBeGreaterThan(10)
      expect(task.tags.length, task.id).toBeGreaterThan(1)
      expect(task.points, task.id).toBeGreaterThan(0)
    }
  })
})

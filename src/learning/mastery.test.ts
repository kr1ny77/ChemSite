import { describe, expect, it } from 'vitest'
import { level1Tasks } from '../chemistry/tasks/level1'
import { calculateStars, getWeakTopics, updateMastery, updateReviewQueue } from './mastery'

describe('adaptive learning model', () => {
  const task = level1Tasks[0]

  it('raises mastery after success and lowers it after a mistake', () => {
    const success = updateMastery(undefined, task, true, 100)
    const mistake = updateMastery(success, task, false, 200)
    expect(success.mastery).toBeGreaterThan(0.5)
    expect(mistake.mastery).toBeLessThan(success.mastery)
    expect(mistake.mistakeWeight).toBeGreaterThan(0)
  })

  it('schedules delayed review and expands intervals after successful repetitions', () => {
    const scheduled = updateReviewQueue([], task, false, 4)
    expect(scheduled[0].dueAfterTask).toBe(7)
    const firstReview = updateReviewQueue(scheduled, task, true, 7)
    expect(firstReview[0]).toMatchObject({ repetitions: 1, interval: 6, dueAfterTask: 13 })
    const secondReview = updateReviewQueue(firstReview, task, true, 13)
    expect(secondReview[0].interval).toBe(12)
    const completed = updateReviewQueue(secondReview, task, true, 25)
    expect(completed).toHaveLength(0)
  })

  it('orders weak topics and converts round accuracy to stars', () => {
    const weak = updateMastery(undefined, task, false)
    const strong = { ...updateMastery(undefined, { ...task, topic: 'Strong' }, true), mastery: 0.9 }
    expect(getWeakTopics({ weak, strong })[0]).toBe(task.topic)
    expect(calculateStars(5, 5)).toBe(3)
    expect(calculateStars(4, 5)).toBe(2)
    expect(calculateStars(3, 5)).toBe(1)
  })
})

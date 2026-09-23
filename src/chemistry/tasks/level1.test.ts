import { describe, expect, it } from 'vitest'
import { findRemediationTask, selectRoundTasks } from '../selection/selectRoundTasks'
import { level1Tasks } from './level1'

describe('Level 1 task bank', () => {
  it('contains 40 unique verified seed tasks with feedback', () => {
    expect(level1Tasks).toHaveLength(40)
    expect(new Set(level1Tasks.map((task) => task.id)).size).toBe(40)
    for (const task of level1Tasks) {
      expect(task.reviewStatus).toBe('verified')
      expect(task.explanation.length).toBeGreaterThan(20)
      expect(task.hint.length).toBeGreaterThan(10)
      expect(task.level).toBe(1)
    }
  })

  it('selects five unique tasks with varied interaction types', () => {
    const round = selectRoundTasks(level1Tasks, 5, 20260922)
    expect(round).toHaveLength(5)
    expect(new Set(round.map((task) => task.id)).size).toBe(5)
    expect(new Set(round.map((task) => task.interactionType)).size).toBeGreaterThanOrEqual(4)
  })

  it('produces deterministic selection for a supplied seed', () => {
    const first = selectRoundTasks(level1Tasks, 5, 42).map((task) => task.id)
    const second = selectRoundTasks(level1Tasks, 5, 42).map((task) => task.id)
    expect(first).toEqual(second)
  })

  it('finds a related task with a different compound for remediation', () => {
    const source = level1Tasks[1]
    const remediation = findRemediationTask(level1Tasks, source, new Set())
    expect(remediation?.topic).toBe(source.topic)
    expect(remediation?.parameters?.compound).not.toBe(source.parameters?.compound)
  })
})

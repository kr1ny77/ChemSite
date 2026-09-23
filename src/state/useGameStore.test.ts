import { beforeEach, describe, expect, it } from 'vitest'
import { defaultLearningProgress } from '../learning/mastery'
import { useGameStore } from './useGameStore'

describe('game store', () => {
  beforeEach(() => {
    useGameStore.setState({
      mode: 'playing',
      gameplayMode: 'career',
      practiceTopic: null,
      practiceTimed: true,
      nearbyStationId: null,
      activeStationId: null,
      hasMoved: false,
      currentLevel: 1,
      roundTasks: [],
      currentTaskIndex: 0,
      results: [],
      score: 0,
      combo: 0,
      timeRemaining: 900,
      roundStatus: 'idle',
      hintUsed: false,
      answerFeedback: null,
      mistakeHistory: [],
      learningProgress: defaultLearningProgress(),
    })
  })

  it('opens only the nearby station', () => {
    useGameStore.getState().interact()
    expect(useGameStore.getState().mode).toBe('playing')

    useGameStore.getState().setNearbyStation('formula-board')
    useGameStore.getState().interact()
    expect(useGameStore.getState()).toMatchObject({
      mode: 'station',
      activeStationId: 'formula-board',
    })
  })

  it('toggles pause from the playable state', () => {
    useGameStore.getState().togglePause()
    expect(useGameStore.getState().mode).toBe('paused')
    useGameStore.getState().togglePause()
    expect(useGameStore.getState().mode).toBe('playing')
  })

  it('scores a correct Level 1 answer and advances after feedback', () => {
    useGameStore.getState().startLevelOneRound(4)
    expect(useGameStore.getState().roundTasks[0].id).toBe('L1-009')
    useGameStore.getState().submitAnswer('Fe(NO3)3')
    expect(useGameStore.getState().answerFeedback?.correct).toBe(true)
    expect(useGameStore.getState().score).toBeGreaterThanOrEqual(100)
    useGameStore.getState().continueAfterFeedback()
    expect(useGameStore.getState().currentTaskIndex).toBe(1)
  })

  it('ends the round immediately after five submitted tasks', () => {
    useGameStore.getState().startLevelOneRound(4)
    for (let index = 0; index < 5; index += 1) {
      const state = useGameStore.getState()
      const answer = state.roundTasks[state.currentTaskIndex].correctAnswer
      state.submitAnswer(typeof answer === 'string' ? answer : String(answer.value))
      state.continueAfterFeedback()
    }
    expect(useGameStore.getState()).toMatchObject({
      mode: 'results',
      roundStatus: 'complete',
      currentTaskIndex: 4,
    })
    expect(useGameStore.getState().results).toHaveLength(5)
  })

  it('freezes the level timer while paused', () => {
    useGameStore.getState().startLevelOneRound(4)
    useGameStore.getState().togglePause()
    useGameStore.getState().tickRound()
    expect(useGameStore.getState().timeRemaining).toBe(900)
  })

  it('starts verified five-task rounds for Levels 2 through 5', () => {
    useGameStore.getState().startRound(2, 41)
    expect(useGameStore.getState().roundTasks).toHaveLength(5)
    expect(useGameStore.getState().roundTasks.every((task) => task.level === 2)).toBe(true)
    useGameStore.getState().startRound(3, 81)
    expect(useGameStore.getState().roundTasks.every((task) => task.level === 3)).toBe(true)
    useGameStore.getState().startRound(4, 121)
    expect(useGameStore.getState().roundTasks).toHaveLength(5)
    expect(useGameStore.getState().roundTasks.every((task) => task.level === 4)).toBe(true)
    useGameStore.getState().startRound(5, 161)
    expect(useGameStore.getState().roundTasks).toHaveLength(5)
    expect(useGameStore.getState().roundTasks.every((task) => task.level === 5)).toBe(true)
  })

  it('updates XP, mastery, reviews, stars and unlocked level', () => {
    useGameStore.getState().startLevelOneRound(4)
    const first = useGameStore.getState().roundTasks[0]
    useGameStore.getState().submitAnswer('заведомо неверно')
    expect(useGameStore.getState().learningProgress.mastery[first.topic].incorrect).toBe(1)
    expect(useGameStore.getState().learningProgress.reviewQueue).toHaveLength(1)
    useGameStore.getState().continueAfterFeedback()

    while (useGameStore.getState().roundStatus !== 'complete') {
      const state = useGameStore.getState()
      const answer = state.roundTasks[state.currentTaskIndex].correctAnswer
      state.submitAnswer(typeof answer === 'string' ? answer : String(answer.value))
      if (useGameStore.getState().roundStatus !== 'complete') state.continueAfterFeedback()
    }

    expect(useGameStore.getState().learningProgress.xp).toBeGreaterThan(0)
    expect(useGameStore.getState().learningProgress.stars[1]).toBe(2)
    expect(useGameStore.getState().learningProgress.unlockedLevel).toBe(2)
  })

  it('starts untimed topic practice without changing career unlocks', () => {
    useGameStore.getState().startPractice('corrosion', false, 22)
    const state = useGameStore.getState()
    expect(state.gameplayMode).toBe('practice')
    expect(state.practiceTimed).toBe(false)
    expect(state.roundTasks).toHaveLength(5)
    expect(state.roundTasks.every((task) => {
      const content = `${task.topic} ${task.tags.join(' ')}`.toLocaleLowerCase('ru')
      return content.includes('корроз') || content.includes('corrosion') || content.includes('reinforcement')
    })).toBe(true)
    state.tickRound()
    expect(useGameStore.getState().timeRemaining).toBe(0)
    expect(useGameStore.getState().learningProgress.unlockedLevel).toBe(1)
  })
})

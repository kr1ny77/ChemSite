import { create } from 'zustand'
import type { GameMode, Vec3 } from '../game/types'
import type { ChemistryLevel, TaskDefinition, TaskResult } from '../chemistry/types'
import { level1Tasks } from '../chemistry/tasks/level1'
import { level2Tasks } from '../chemistry/tasks/level2'
import { level3Tasks } from '../chemistry/tasks/level3'
import { level4Tasks } from '../chemistry/tasks/level4'
import { level5Tasks } from '../chemistry/tasks/level5'
import { generatedLevel1Tasks, generatedLevel3Tasks } from '../chemistry/generators/deterministicVariants'
import { findRemediationTask, selectRoundTasks } from '../chemistry/selection/selectRoundTasks'
import { validateTaskAnswer } from '../chemistry/validators/answers'
import {
  calculateStars,
  getWeakTopics,
  updateMastery,
  updateReviewQueue,
  type LearningProgress,
  type LearningSettings,
} from '../learning/mastery'
import { loadProgress, saveProgress } from '../persistence/progress'
import { filterPracticeTasks } from '../chemistry/practice/topics'

type AnswerFeedback = {
  correct: boolean
  submittedAnswer: string
  scoreAwarded: number
}

type MistakeRecord = {
  taskId: string
  tags: string[]
  compound?: string
}

const persistedSave = loadProgress()
const initialLearningProgress: LearningProgress = {
  unlockedLevel: persistedSave.unlockedLevel,
  xp: persistedSave.xp,
  stars: persistedSave.stars,
  highScores: persistedSave.highScores,
  mastery: persistedSave.mastery,
  reviewQueue: persistedSave.reviewQueue,
  completedTaskCount: persistedSave.completedTaskCount,
  tutorialComplete: persistedSave.tutorialComplete,
  settings: persistedSave.settings,
}

const taskBanks: Partial<Record<ChemistryLevel, readonly TaskDefinition[]>> = {
  1: level1Tasks,
  2: level2Tasks,
  3: level3Tasks,
  4: level4Tasks,
  5: level5Tasks,
}

const variantBanks: Partial<Record<ChemistryLevel, readonly TaskDefinition[]>> = {
  1: generatedLevel1Tasks,
  3: generatedLevel3Tasks,
}

function getPlayableBank(level: ChemistryLevel) {
  return [...(taskBanks[level] ?? level1Tasks), ...(variantBanks[level] ?? [])]
}

const allPlayableTasks = ([1, 2, 3, 4, 5] as const).flatMap((level) => getPlayableBank(level))

type GameState = {
  mode: GameMode
  gameplayMode: 'career' | 'practice'
  practiceTopic: string | null
  practiceTimed: boolean
  playerPosition: Vec3
  nearbyStationId: string | null
  activeStationId: string | null
  hasMoved: boolean
  sceneReady: boolean
  currentLevel: ChemistryLevel
  roundTasks: TaskDefinition[]
  currentTaskIndex: number
  results: TaskResult[]
  score: number
  combo: number
  timeRemaining: number
  roundStatus: 'idle' | 'active' | 'complete' | 'expired'
  hintUsed: boolean
  answerFeedback: AnswerFeedback | null
  taskStartedAt: number
  mistakeHistory: MistakeRecord[]
  learningProgress: LearningProgress
  setPlayerPosition: (position: Vec3) => void
  setNearbyStation: (stationId: string | null) => void
  setHasMoved: () => void
  setSceneReady: () => void
  startRound: (level: ChemistryLevel, seed?: number) => void
  startLevelOneRound: (seed?: number) => void
  startPractice: (topicId: string, timed: boolean, seed?: number) => void
  submitAnswer: (answer: string) => void
  revealHint: () => void
  continueAfterFeedback: () => void
  tickRound: () => void
  interact: () => void
  closeStation: () => void
  togglePause: () => void
  updateSettings: (settings: Partial<LearningSettings>) => void
  openCareerSelect: () => void
  openPracticeSelect: () => void
  goToMenu: () => void
  restartCurrentRound: () => void
}

function scheduleProgressSave(get: () => GameState) {
  queueMicrotask(() => {
    const state = get()
    saveProgress(state.learningProgress, state.mistakeHistory)
  })
}

export const useGameStore = create<GameState>((set, get) => ({
  mode: 'menu',
  gameplayMode: 'career',
  practiceTopic: null,
  practiceTimed: true,
  playerPosition: [0, 0.95, 0],
  nearbyStationId: null,
  activeStationId: null,
  hasMoved: false,
  sceneReady: false,
  currentLevel: 1,
  roundTasks: [],
  currentTaskIndex: 0,
  results: [],
  score: 0,
  combo: 0,
  timeRemaining: 15 * 60,
  roundStatus: 'idle',
  hintUsed: false,
  answerFeedback: null,
  taskStartedAt: Date.now(),
  mistakeHistory: persistedSave.mistakeHistory,
  learningProgress: initialLearningProgress,
  setPlayerPosition: (position) => set({ playerPosition: position }),
  setNearbyStation: (nearbyStationId) => set({ nearbyStationId }),
  setHasMoved: () => {
    if (!get().hasMoved) set({ hasMoved: true })
  },
  setSceneReady: () => {
    if (!get().sceneReady) set({ sceneReady: true })
  },
  startRound: (level, seed = Date.now()) => {
    const state = get()
    const curatedBank = taskBanks[level] ?? level1Tasks
    const variantBank = variantBanks[level] ?? []
    const bank = getPlayableBank(level)
    const weakTopics = getWeakTopics(state.learningProgress.mastery)
    const dueReviews = state.learningProgress.reviewQueue.filter(
      (item) => item.dueAfterTask <= state.learningProgress.completedTaskCount,
    )
    const roundTasks = selectRoundTasks(curatedBank, 5, seed, { preferredTopics: weakTopics })
    if (variantBank.length > 0) {
      const generatedTask = selectRoundTasks(variantBank, 1, seed + 97, { preferredTopics: weakTopics })[0]
      if (generatedTask) roundTasks[3] = generatedTask
    }
    const dueReview = dueReviews.find((item) => bank.some((task) => task.topic === item.topic))
    if (dueReview) {
      const remediation = bank
        .filter((task) =>
          task.reviewStatus === 'verified' &&
          task.id !== dueReview.sourceTaskId &&
          task.subtopic === dueReview.subtopic &&
          (!dueReview.compound || task.parameters?.compound !== dueReview.compound) &&
          !roundTasks.some((selected) => selected.id === task.id),
        )
        .sort((left, right) => left.id.localeCompare(right.id))[0]
      if (remediation) roundTasks[2] = remediation
    } else {
      const latestMistake = state.mistakeHistory.at(-1)
      if (latestMistake) {
        const source = bank.find((task) => task.id === latestMistake.taskId)
        const remediation = source && findRemediationTask(
          bank,
          source,
          new Set(roundTasks.map((task) => task.id)),
        )
        if (remediation) roundTasks[2] = remediation
      }
    }
    set({
      mode: 'playing',
      gameplayMode: 'career',
      practiceTopic: null,
      practiceTimed: true,
      currentLevel: level,
      activeStationId: null,
      roundTasks,
      currentTaskIndex: 0,
      results: [],
      score: 0,
      combo: 0,
      timeRemaining: 15 * 60,
      roundStatus: 'active',
      hintUsed: false,
      answerFeedback: null,
      taskStartedAt: Date.now(),
    })
  },
  startLevelOneRound: (seed = Date.now()) => get().startRound(1, seed),
  startPractice: (topicId, timed, seed = Date.now()) => {
    const state = get()
    const practiceBank = filterPracticeTasks(allPlayableTasks, topicId)
    const bank = practiceBank.length >= 5 ? practiceBank : allPlayableTasks
    const weakTopics = getWeakTopics(state.learningProgress.mastery)
    const roundTasks = selectRoundTasks(bank, 5, seed, { preferredTopics: weakTopics })
    set({
      mode: 'playing',
      gameplayMode: 'practice',
      practiceTopic: topicId,
      practiceTimed: timed,
      currentLevel: roundTasks[0]?.level ?? 1,
      activeStationId: null,
      roundTasks,
      currentTaskIndex: 0,
      results: [],
      score: 0,
      combo: 0,
      timeRemaining: timed ? 15 * 60 : 0,
      roundStatus: 'active',
      hintUsed: false,
      answerFeedback: null,
      taskStartedAt: Date.now(),
    })
  },
  submitAnswer: (submittedAnswer) => {
    const state = get()
    const task = state.roundTasks[state.currentTaskIndex]
    if (!task || state.answerFeedback || state.roundStatus !== 'active') return

    const validation = validateTaskAnswer(task, submittedAnswer)
    const nextCombo = validation.correct ? state.combo + 1 : 0
    const multiplier = nextCombo >= 5 ? 2 : nextCombo >= 3 ? 1.5 : 1
    const elapsed = Math.max(0, Math.round((Date.now() - state.taskStartedAt) / 1000))
    const timeBonus = validation.correct ? Math.max(0, 30 - elapsed) : 0
    const basePoints = Math.max(0, task.points - (state.hintUsed ? 20 : 0))
    const scoreAwarded = validation.correct ? Math.round(basePoints * multiplier + timeBonus) : 0
    const result: TaskResult = {
      taskId: task.id,
      correct: validation.correct,
      submittedAnswer,
      normalizedAnswer: validation.normalizedAnswer,
      timeSpentSeconds: elapsed,
      hintUsed: state.hintUsed,
      scoreAwarded,
      topic: task.topic,
      subtopic: task.subtopic,
      tags: task.tags,
    }
    const results = [...state.results, result]
    const roundTasks = [...state.roundTasks]
    if (!validation.correct && state.currentTaskIndex + 3 < roundTasks.length) {
      const bank = getPlayableBank(state.currentLevel)
      const remediation = findRemediationTask(
        bank,
        task,
        new Set(roundTasks.map((candidate) => candidate.id)),
      )
      if (remediation) roundTasks[state.currentTaskIndex + 3] = remediation
    }
    const completedTaskCount = state.learningProgress.completedTaskCount + 1
    const mastery = {
      ...state.learningProgress.mastery,
      [task.topic]: updateMastery(state.learningProgress.mastery[task.topic], task, validation.correct),
    }
    const reviewQueue = updateReviewQueue(
      state.learningProgress.reviewQueue,
      task,
      validation.correct,
      completedTaskCount,
    )
    const roundComplete = results.length >= state.roundTasks.length
    const correctAnswers = results.filter((entry) => entry.correct).length
    const earnedStars = roundComplete ? calculateStars(correctAnswers, results.length) : 0
    const existingStars = state.learningProgress.stars[state.currentLevel] ?? 0
    const existingHighScore = state.learningProgress.highScores[state.currentLevel] ?? 0
    const learningProgress: LearningProgress = {
      ...state.learningProgress,
      xp: state.learningProgress.xp + (validation.correct ? Math.max(5, Math.round(scoreAwarded / 10)) : 1),
      completedTaskCount,
      mastery,
      reviewQueue,
      stars: roundComplete && state.gameplayMode === 'career'
        ? { ...state.learningProgress.stars, [state.currentLevel]: Math.max(existingStars, earnedStars) }
        : state.learningProgress.stars,
      highScores: roundComplete && state.gameplayMode === 'career'
        ? { ...state.learningProgress.highScores, [state.currentLevel]: Math.max(existingHighScore, state.score + scoreAwarded) }
        : state.learningProgress.highScores,
      unlockedLevel: roundComplete && state.gameplayMode === 'career' && earnedStars >= 1
        ? Math.min(5, Math.max(state.learningProgress.unlockedLevel, state.currentLevel + 1)) as ChemistryLevel
        : state.learningProgress.unlockedLevel,
    }
    set({
      results,
      roundTasks,
      score: state.score + scoreAwarded,
      combo: nextCombo,
      mistakeHistory: validation.correct ? state.mistakeHistory : [
        ...state.mistakeHistory,
        { taskId: task.id, tags: task.tags, compound: task.parameters?.compound },
      ],
      answerFeedback: { correct: validation.correct, submittedAnswer, scoreAwarded },
      roundStatus: roundComplete ? 'complete' : 'active',
      learningProgress,
    })
    scheduleProgressSave(get)
  },
  revealHint: () => set({ hintUsed: true }),
  continueAfterFeedback: () => {
    const state = get()
    if (!state.answerFeedback) return
    if (state.roundStatus === 'complete') {
      set({ mode: 'results', activeStationId: null, answerFeedback: null })
      return
    }
    set({
      mode: 'playing',
      activeStationId: null,
      currentTaskIndex: state.currentTaskIndex + 1,
      hintUsed: false,
      answerFeedback: null,
      taskStartedAt: Date.now(),
    })
  },
  tickRound: () => {
    const state = get()
    if (state.roundStatus !== 'active' || state.mode === 'paused' || (state.gameplayMode === 'practice' && !state.practiceTimed)) return
    const nextTime = Math.max(0, state.timeRemaining - 1)
    set({
      timeRemaining: nextTime,
      ...(nextTime === 0 ? { roundStatus: 'expired' as const, mode: 'results' as const, activeStationId: null } : {}),
    })
  },
  interact: () => {
    const { mode, nearbyStationId } = get()
    if (mode === 'playing' && nearbyStationId) {
      set({ mode: 'station', activeStationId: nearbyStationId })
    }
  },
  closeStation: () => set({ mode: 'playing', activeStationId: null }),
  togglePause: () => {
    const { mode } = get()
    if (mode === 'station' || mode === 'results') return
    set({ mode: mode === 'paused' ? 'playing' : 'paused' })
  },
  updateSettings: (settings) => {
    const state = get()
    set({
      learningProgress: {
        ...state.learningProgress,
        settings: { ...state.learningProgress.settings, ...settings },
      },
    })
    scheduleProgressSave(get)
  },
  openCareerSelect: () => set({ mode: 'career-select', activeStationId: null }),
  openPracticeSelect: () => set({ mode: 'practice-select', activeStationId: null }),
  goToMenu: () => set({ mode: 'menu', activeStationId: null, nearbyStationId: null }),
  restartCurrentRound: () => {
    const state = get()
    if (state.gameplayMode === 'practice' && state.practiceTopic) {
      state.startPractice(state.practiceTopic, state.practiceTimed)
    } else {
      state.startRound(state.currentLevel)
    }
  },
}))

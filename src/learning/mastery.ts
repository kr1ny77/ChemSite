import type { TaskDefinition } from '../chemistry/types'

export type TopicMastery = {
  topic: string
  attempts: number
  correct: number
  incorrect: number
  mastery: number
  lastAttemptAt?: number
  consecutiveCorrect: number
  mistakeWeight: number
}

export type ReviewItem = {
  id: string
  sourceTaskId: string
  topic: string
  subtopic: string
  tags: string[]
  compound?: string
  dueAfterTask: number
  interval: number
  repetitions: number
}

export type LearningSettings = {
  soundVolume: number
  effectsVolume: number
  musicVolume: number
  cameraZoom: number
  highQualityGraphics: boolean
  reducedMotion: boolean
  cameraEffects: boolean
}

export type LearningProgress = {
  unlockedLevel: 1 | 2 | 3 | 4 | 5
  xp: number
  stars: Partial<Record<1 | 2 | 3 | 4 | 5, number>>
  highScores: Partial<Record<1 | 2 | 3 | 4 | 5, number>>
  mastery: Record<string, TopicMastery>
  reviewQueue: ReviewItem[]
  completedTaskCount: number
  tutorialComplete: boolean
  settings: LearningSettings
}

export const defaultLearningProgress = (): LearningProgress => ({
  unlockedLevel: 1,
  xp: 0,
  stars: {},
  highScores: {},
  mastery: {},
  reviewQueue: [],
  completedTaskCount: 0,
  tutorialComplete: false,
  settings: {
    soundVolume: 0.7,
    effectsVolume: 0.8,
    musicVolume: 0.35,
    cameraZoom: 1,
    highQualityGraphics: true,
    reducedMotion: false,
    cameraEffects: true,
  },
})

export function updateMastery(
  current: TopicMastery | undefined,
  task: TaskDefinition,
  correct: boolean,
  attemptedAt = Date.now(),
): TopicMastery {
  const previous = current ?? {
    topic: task.topic,
    attempts: 0,
    correct: 0,
    incorrect: 0,
    mastery: 0.5,
    consecutiveCorrect: 0,
    mistakeWeight: 0,
  }
  const consecutiveCorrect = correct ? previous.consecutiveCorrect + 1 : 0
  const gain = 0.1 * (1 - previous.mastery) + Math.min(0.04, consecutiveCorrect * 0.008)
  const mastery = correct
    ? Math.min(1, previous.mastery + gain)
    : Math.max(0, previous.mastery - 0.18)

  return {
    ...previous,
    attempts: previous.attempts + 1,
    correct: previous.correct + (correct ? 1 : 0),
    incorrect: previous.incorrect + (correct ? 0 : 1),
    mastery: Number(mastery.toFixed(4)),
    lastAttemptAt: attemptedAt,
    consecutiveCorrect,
    mistakeWeight: correct
      ? Math.max(0, Number((previous.mistakeWeight * 0.72 - 0.04).toFixed(4)))
      : Math.min(1, Number((previous.mistakeWeight + 0.3).toFixed(4))),
  }
}

export function updateReviewQueue(
  queue: readonly ReviewItem[],
  task: TaskDefinition,
  correct: boolean,
  completedTaskCount: number,
) {
  const matching = queue.find((item) => item.topic === task.topic && item.subtopic === task.subtopic)
  const remaining = queue.filter((item) => item !== matching)

  if (!correct) {
    const interval = 3
    return [
      ...remaining,
      {
        id: `${task.topic}:${task.subtopic}`,
        sourceTaskId: task.id,
        topic: task.topic,
        subtopic: task.subtopic,
        tags: [...task.tags],
        compound: task.parameters?.compound,
        dueAfterTask: completedTaskCount + interval,
        interval,
        repetitions: 0,
      },
    ]
  }

  if (!matching) return [...queue]
  const repetitions = matching.repetitions + 1
  if (repetitions >= 3) return remaining
  const interval = Math.min(24, matching.interval * 2)
  return [
    ...remaining,
    { ...matching, repetitions, interval, dueAfterTask: completedTaskCount + interval },
  ]
}

export function getWeakTopics(mastery: Record<string, TopicMastery>) {
  return Object.values(mastery)
    .sort((left, right) =>
      (left.mastery - left.mistakeWeight * 0.35) - (right.mastery - right.mistakeWeight * 0.35) ||
      left.topic.localeCompare(right.topic),
    )
    .map((entry) => entry.topic)
}

export function calculateStars(correctAnswers: number, totalTasks: number) {
  if (totalTasks <= 0) return 0
  const ratio = correctAnswers / totalTasks
  if (ratio >= 1) return 3
  if (ratio >= 0.8) return 2
  if (ratio >= 0.6) return 1
  return 0
}

import { defaultLearningProgress, type LearningProgress } from '../learning/mastery'

export const SAVE_VERSION = 1
export const SAVE_KEY = 'chemsite-progress'

type PersistedSave = LearningProgress & {
  saveVersion: number
  mistakeHistory: Array<{ taskId: string; tags: string[]; compound?: string }>
}

type StorageLike = Pick<Storage, 'getItem' | 'setItem'>

export function createDefaultSave(): PersistedSave {
  return { saveVersion: SAVE_VERSION, ...defaultLearningProgress(), mistakeHistory: [] }
}

function browserStorage(): StorageLike | undefined {
  try {
    return typeof window === 'undefined' ? undefined : window.localStorage
  } catch {
    return undefined
  }
}

export function loadProgress(storage: StorageLike | undefined = browserStorage()): PersistedSave {
  const fallback = createDefaultSave()
  if (!storage) return fallback
  try {
    const raw = storage.getItem(SAVE_KEY)
    if (!raw) return fallback
    const parsed = JSON.parse(raw) as Partial<PersistedSave>
    if (parsed.saveVersion !== SAVE_VERSION) return fallback
    return {
      ...fallback,
      ...parsed,
      settings: { ...fallback.settings, ...parsed.settings },
      mastery: parsed.mastery ?? {},
      reviewQueue: Array.isArray(parsed.reviewQueue) ? parsed.reviewQueue : [],
      mistakeHistory: Array.isArray(parsed.mistakeHistory) ? parsed.mistakeHistory : [],
    }
  } catch {
    return fallback
  }
}

export function saveProgress(
  progress: LearningProgress,
  mistakeHistory: PersistedSave['mistakeHistory'],
  storage: StorageLike | undefined = browserStorage(),
) {
  if (!storage) return false
  try {
    storage.setItem(SAVE_KEY, JSON.stringify({ saveVersion: SAVE_VERSION, ...progress, mistakeHistory }))
    return true
  } catch {
    return false
  }
}

import { describe, expect, it } from 'vitest'
import { createDefaultSave, loadProgress, SAVE_KEY, saveProgress } from './progress'

function memoryStorage(initial?: string) {
  const values = new Map<string, string>()
  if (initial) values.set(SAVE_KEY, initial)
  return {
    getItem: (key: string) => values.get(key) ?? null,
    setItem: (key: string, value: string) => values.set(key, value),
  }
}

describe('versioned progress persistence', () => {
  it('round-trips learning progress and settings', () => {
    const storage = memoryStorage()
    const progress = createDefaultSave()
    progress.xp = 420
    progress.unlockedLevel = 3
    progress.settings.soundVolume = 0.35
    expect(saveProgress(progress, [{ taskId: 'L1-001', tags: ['salt'] }], storage)).toBe(true)
    expect(loadProgress(storage)).toMatchObject({
      saveVersion: 1,
      xp: 420,
      unlockedLevel: 3,
      settings: { soundVolume: 0.35 },
      mistakeHistory: [{ taskId: 'L1-001', tags: ['salt'] }],
    })
  })

  it('uses defaults for corrupt and unsupported saves', () => {
    expect(loadProgress(memoryStorage('{bad json'))).toMatchObject({ saveVersion: 1, xp: 0, unlockedLevel: 1 })
    expect(loadProgress(memoryStorage('{"saveVersion":99,"xp":900}'))).toMatchObject({ saveVersion: 1, xp: 0 })
  })
})

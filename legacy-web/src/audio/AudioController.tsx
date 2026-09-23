import { useEffect, useRef } from 'react'
import { useGameStore } from '../state/useGameStore'
import { audioManager } from './audioManager'
import { MusicController } from './MusicController'

export function AudioController() {
  const feedback = useGameStore((state) => state.answerFeedback)
  const activeStationId = useGameStore((state) => state.activeStationId)
  const mode = useGameStore((state) => state.mode)
  const settings = useGameStore((state) => state.learningProgress.settings)
  const previousStation = useRef<string | null>(null)
  const previousMode = useRef(mode)
  const previousFeedback = useRef(feedback)

  useEffect(() => {
    audioManager.setVolumes(settings.soundVolume, settings.effectsVolume)
    document.documentElement.dataset.reducedMotion = settings.reducedMotion ? 'true' : 'false'
  }, [settings.effectsVolume, settings.reducedMotion, settings.soundVolume])

  useEffect(() => {
    const unlock = () => audioManager.unlock()
    window.addEventListener('pointerdown', unlock, { once: true })
    window.addEventListener('keydown', unlock, { once: true })
    return () => {
      window.removeEventListener('pointerdown', unlock)
      window.removeEventListener('keydown', unlock)
    }
  }, [])

  useEffect(() => {
    if (activeStationId && activeStationId !== previousStation.current) audioManager.play('interact')
    previousStation.current = activeStationId
  }, [activeStationId])

  useEffect(() => {
    if (feedback && feedback !== previousFeedback.current) audioManager.play(feedback.correct ? 'success' : 'failure')
    previousFeedback.current = feedback
  }, [feedback])

  useEffect(() => {
    if (mode !== previousMode.current) {
      if (mode === 'paused') audioManager.play('pause')
      if (mode === 'results') audioManager.play('complete')
    }
    previousMode.current = mode
  }, [mode])

  return <MusicController />
}

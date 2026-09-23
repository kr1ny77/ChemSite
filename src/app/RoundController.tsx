import { useEffect } from 'react'
import { useGameStore } from '../state/useGameStore'

export function RoundController() {
  useEffect(() => {
    const timer = window.setInterval(() => useGameStore.getState().tickRound(), 1_000)
    return () => window.clearInterval(timer)
  }, [])

  return null
}

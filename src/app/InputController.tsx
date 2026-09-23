import { useEffect } from 'react'
import { inputManager } from '../game/input/inputManager'
import { useGameStore } from '../state/useGameStore'

const movementCodes = new Set([
  'KeyW',
  'KeyA',
  'KeyS',
  'KeyD',
  'ArrowUp',
  'ArrowDown',
  'ArrowLeft',
  'ArrowRight',
])

export function InputController() {
  useEffect(() => {
    const onKeyDown = (event: KeyboardEvent) => {
      if (movementCodes.has(event.code)) {
        event.preventDefault()
        inputManager.press(event.code)
      }
      if (event.repeat) return
      if (event.code === 'KeyE') useGameStore.getState().interact()
      if (event.code === 'Enter') {
        const state = useGameStore.getState()
        if (state.mode === 'station' && state.answerFeedback) state.continueAfterFeedback()
      }
      if (event.code === 'Escape') {
        const state = useGameStore.getState()
        if (state.mode === 'station') state.closeStation()
        else if (state.mode === 'career-select' || state.mode === 'practice-select') state.goToMenu()
        else if (state.mode === 'menu' || state.mode === 'results') return
        else state.togglePause()
      }
    }

    const onKeyUp = (event: KeyboardEvent) => inputManager.release(event.code)
    const reset = () => inputManager.reset()

    window.addEventListener('keydown', onKeyDown)
    window.addEventListener('keyup', onKeyUp)
    window.addEventListener('blur', reset)
    return () => {
      window.removeEventListener('keydown', onKeyDown)
      window.removeEventListener('keyup', onKeyUp)
      window.removeEventListener('blur', reset)
      inputManager.reset()
    }
  }, [])

  return null
}

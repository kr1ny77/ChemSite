import { afterEach, describe, expect, it } from 'vitest'
import { inputManager } from './inputManager'

describe('inputManager', () => {
  afterEach(() => inputManager.reset())

  it('maps WASD and arrow keys to normalized movement', () => {
    inputManager.press('KeyW')
    inputManager.press('KeyD')

    const movement = inputManager.movement()
    expect(movement.x).toBeCloseTo(Math.SQRT1_2)
    expect(movement.z).toBeCloseTo(-Math.SQRT1_2)
    expect(movement.moving).toBe(true)
  })

  it('clears movement state when input is reset', () => {
    inputManager.press('ArrowLeft')
    inputManager.reset()
    expect(inputManager.movement()).toEqual({ x: 0, z: 0, moving: false })
  })
})

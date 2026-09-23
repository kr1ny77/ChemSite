export type InputAction = 'up' | 'down' | 'left' | 'right'

const actionKeys: Record<InputAction, readonly string[]> = {
  up: ['KeyW', 'ArrowUp'],
  down: ['KeyS', 'ArrowDown'],
  left: ['KeyA', 'ArrowLeft'],
  right: ['KeyD', 'ArrowRight'],
}

class InputManager {
  private pressed = new Set<string>()

  press(code: string) {
    this.pressed.add(code)
  }

  release(code: string) {
    this.pressed.delete(code)
  }

  reset() {
    this.pressed.clear()
  }

  isActive(action: InputAction) {
    return actionKeys[action].some((code) => this.pressed.has(code))
  }

  movement() {
    const x = Number(this.isActive('right')) - Number(this.isActive('left'))
    const z = Number(this.isActive('down')) - Number(this.isActive('up'))
    const length = Math.hypot(x, z) || 1
    return { x: x / length, z: z / length, moving: x !== 0 || z !== 0 }
  }
}

export const inputManager = new InputManager()

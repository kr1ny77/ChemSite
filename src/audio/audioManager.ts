export type SoundCue = 'interact' | 'success' | 'failure' | 'scan' | 'pause' | 'complete'

type AudioWindow = Window & typeof globalThis & {
  webkitAudioContext?: typeof AudioContext
}

class AudioManager {
  private context: AudioContext | null = null
  private master: GainNode | null = null
  private soundVolume = 0.7
  private effectsVolume = 0.8

  unlock() {
    if (typeof window === 'undefined') return
    const Context = window.AudioContext ?? (window as AudioWindow).webkitAudioContext
    if (!Context) return
    if (!this.context) {
      this.context = new Context()
      this.master = this.context.createGain()
      this.master.connect(this.context.destination)
      this.updateGain()
    }
    if (this.context.state === 'suspended') void this.context.resume()
  }

  setVolumes(soundVolume: number, effectsVolume: number) {
    this.soundVolume = Math.max(0, Math.min(1, soundVolume))
    this.effectsVolume = Math.max(0, Math.min(1, effectsVolume))
    this.updateGain()
  }

  play(cue: SoundCue) {
    this.unlock()
    if (!this.context || !this.master || this.soundVolume <= 0 || this.effectsVolume <= 0) return
    const now = this.context.currentTime
    if (cue === 'interact') this.sequence([[420, 0, 0.055], [620, 0.055, 0.07]], 'square', 0.045)
    if (cue === 'success') this.sequence([[440, 0, 0.09], [554, 0.08, 0.09], [659, 0.16, 0.15]], 'triangle', 0.075)
    if (cue === 'failure') this.sequence([[240, 0, 0.12], [180, 0.1, 0.18]], 'sawtooth', 0.045)
    if (cue === 'scan') this.sweep(520, 980, now, 0.18, 'sine', 0.05)
    if (cue === 'pause') this.sequence([[330, 0, 0.05]], 'square', 0.035)
    if (cue === 'complete') this.sequence([[392, 0, 0.12], [523, 0.1, 0.12], [659, 0.2, 0.12], [784, 0.3, 0.24]], 'triangle', 0.07)
  }

  private updateGain() {
    if (!this.context || !this.master) return
    this.master.gain.setTargetAtTime(this.soundVolume * this.effectsVolume, this.context.currentTime, 0.01)
  }

  private sequence(notes: Array<[number, number, number]>, type: OscillatorType, level: number) {
    if (!this.context || !this.master) return
    const start = this.context.currentTime
    notes.forEach(([frequency, delay, duration]) => this.tone(frequency, start + delay, duration, type, level))
  }

  private tone(frequency: number, start: number, duration: number, type: OscillatorType, level: number) {
    if (!this.context || !this.master) return
    const oscillator = this.context.createOscillator()
    const gain = this.context.createGain()
    oscillator.type = type
    oscillator.frequency.setValueAtTime(frequency, start)
    gain.gain.setValueAtTime(0.0001, start)
    gain.gain.exponentialRampToValueAtTime(level, start + 0.012)
    gain.gain.exponentialRampToValueAtTime(0.0001, start + duration)
    oscillator.connect(gain)
    gain.connect(this.master)
    oscillator.start(start)
    oscillator.stop(start + duration + 0.02)
  }

  private sweep(from: number, to: number, start: number, duration: number, type: OscillatorType, level: number) {
    if (!this.context || !this.master) return
    const oscillator = this.context.createOscillator()
    const gain = this.context.createGain()
    oscillator.type = type
    oscillator.frequency.setValueAtTime(from, start)
    oscillator.frequency.exponentialRampToValueAtTime(to, start + duration)
    gain.gain.setValueAtTime(0.0001, start)
    gain.gain.exponentialRampToValueAtTime(level, start + 0.025)
    gain.gain.exponentialRampToValueAtTime(0.0001, start + duration)
    oscillator.connect(gain)
    gain.connect(this.master)
    oscillator.start(start)
    oscillator.stop(start + duration + 0.02)
  }
}

export const audioManager = new AudioManager()

// Original ChemSite compositions. Deterministic offline synthesis, no sampled recordings.
import { mkdirSync, mkdtempSync, writeFileSync, unlinkSync, rmdirSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { join } from 'node:path'
import { execFileSync } from 'node:child_process'

const rate = 22050
const arrangements = [
  { bpm: 72, chords: [[48, 52, 55, 59], [45, 48, 52, 55], [50, 53, 57, 60], [43, 47, 50, 57]] },
  { bpm: 68, chords: [[53, 57, 60, 64], [52, 55, 59, 62], [50, 53, 57, 60], [48, 52, 55, 59]] },
  { bpm: 76, chords: [[46, 50, 53, 57], [43, 46, 50, 53], [48, 51, 55, 58], [53, 57, 60, 63]] },
  { bpm: 70, chords: [[51, 55, 58, 62], [48, 51, 55, 58], [44, 48, 51, 55], [46, 50, 53, 60]] },
]
mkdirSync('public/assets/audio', { recursive: true })
const temporary = mkdtempSync(join(tmpdir(), 'chemsite-music-'))
for (const [track, arrangement] of arrangements.entries()) {
  const beat = 60 / arrangement.bpm
  const duration = 32 * 4 * beat + 3
  const samples = new Float32Array(Math.ceil(duration * rate))
  let seed = track + 100
  const random = () => { seed = (seed * 1664525 + 1013904223) >>> 0; return seed / 4294967296 * 2 - 1 }
  const note = (midi, start, length, volume, bass = false) => {
    const frequency = 440 * 2 ** ((midi - 69) / 12)
    const offset = Math.floor(start * rate)
    for (let i = 0; i < length * rate && offset + i < samples.length; i++) {
      const t = i / rate
      const attack = Math.min(1, t / 0.025)
      const envelope = attack * Math.exp(-t * (bass ? 2.5 : 1.3)) * Math.min(1, (length - t) / 0.2)
      const phase = 2 * Math.PI * frequency * t
      samples[offset + i] += volume * envelope * (Math.sin(phase + (bass ? 0 : 0.5) * Math.sin(phase * 2) * Math.exp(-t * 3)) + 0.14 * Math.sin(phase * 2))
    }
  }
  for (let bar = 0; bar < 32; bar++) {
    const chord = arrangement.chords[Math.floor(bar / 2) % 4]
    for (const pulse of [0, 1.65, 3]) chord.forEach((midi, voice) => note(midi + 12, (bar * 4 + pulse) * beat + voice * 0.018, 2.8, 0.055))
    for (const pulse of [0, 2.5]) note(chord[0] - 12, (bar * 4 + pulse) * beat, 1.5, 0.16, true)
    if (bar % 4 !== 3) for (let i = 0; i < 3; i++) note(chord[(bar + i) % 4] + 24, (bar * 4 + i + 0.5) * beat, 1.5, 0.024)
    for (let step = 0; step < 8; step++) {
      const offset = Math.floor((bar * 4 + step / 2 + (step % 2 ? 0.07 : 0)) * beat * rate)
      for (let i = 0; i < rate * 0.22; i++) {
        const t = i / rate
        const hat = random() * Math.exp(-t * 90) * 0.018
        const kick = step % 4 === 0 ? Math.sin(2 * Math.PI * (48 * t + 1.3 * (1 - Math.exp(-t * 35)))) * Math.exp(-t * 22) * 0.16 : 0
        const snare = step % 4 === 2 ? random() * Math.exp(-t * 32) * 0.035 : 0
        samples[offset + i] += hat + kick + snare
      }
    }
  }
  const wav = Buffer.alloc(44 + samples.length * 4)
  wav.write('RIFF'); wav.writeUInt32LE(wav.length - 8, 4); wav.write('WAVEfmt ', 8); wav.writeUInt32LE(16, 16)
  wav.writeUInt16LE(1, 20); wav.writeUInt16LE(2, 22); wav.writeUInt32LE(rate, 24); wav.writeUInt32LE(rate * 4, 28); wav.writeUInt16LE(4, 32); wav.writeUInt16LE(16, 34); wav.write('data', 36); wav.writeUInt32LE(wav.length - 44, 40)
  for (let i = 0; i < samples.length; i++) {
    const fade = Math.min(1, i / rate / 2, (samples.length - i) / rate / 3)
    for (let channel = 0; channel < 2; channel++) {
      const delayed = samples[Math.max(0, i - Math.floor(rate * (channel ? 0.37 : 0.29)))] * 0.19
      wav.writeInt16LE(Math.round(Math.tanh((samples[i] + delayed) * 1.3) * fade * 26000), 44 + i * 4 + channel * 2)
    }
  }
  const file = join(temporary, 'track.wav')
  writeFileSync(file, wav)
  execFileSync('ffmpeg', ['-y', '-loglevel', 'error', '-i', file, '-codec:a', 'libmp3lame', '-b:a', '96k', `public/assets/audio/lofi-${track + 1}.mp3`])
  unlinkSync(file)
  console.log(`Rendered original track ${track + 1}: ${duration.toFixed(1)}s`)
}
rmdirSync(temporary)

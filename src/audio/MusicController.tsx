import { useEffect, useRef, useState } from 'react'
import { useGameStore } from '../state/useGameStore'

const tracks = ['Утренний бетон', 'Тёплый чертёж', 'Тихая смена', 'Огни лаборатории']

export function MusicController() {
  const audio = useRef<HTMLAudioElement>(null)
  const activated = useRef(false)
  const [track, setTrack] = useState(0)
  const settings = useGameStore((s) => s.learningProgress.settings)
  useEffect(() => {
    const element = audio.current
    if (!element) return
    element.volume = Math.max(0, Math.min(1, settings.soundVolume * settings.musicVolume))
    const play = () => {
      activated.current = true
      if (!document.hidden && element.volume > 0) void element.play().catch(() => { /* Retry on the next user gesture. */ })
    }
    const visibility = () => { if (document.hidden) element.pause(); else if (activated.current) play() }
    if (element.volume === 0) element.pause()
    else if (activated.current) play()
    window.addEventListener('pointerdown', play)
    window.addEventListener('keydown', play)
    document.addEventListener('visibilitychange', visibility)
    return () => {
      window.removeEventListener('pointerdown', play)
      window.removeEventListener('keydown', play)
      document.removeEventListener('visibilitychange', visibility)
    }
  }, [settings.soundVolume, settings.musicVolume, track])
  return <audio ref={audio} data-testid="background-music" aria-label={tracks[track]} preload="none" src={`/assets/audio/lofi-${track + 1}.mp3`} onEnded={() => setTrack((track + 1) % tracks.length)} />
}

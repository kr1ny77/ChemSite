import { useGameStore } from '../state/useGameStore'
import type { ChemistryLevel } from '../chemistry/types'
import { STATIONS } from '../game/config/stations'

declare global {
  interface Window {
    __CHEMSITE_DEBUG__?: {
      getSnapshot: () => ReturnType<typeof useGameStore.getState>
      startRound: (level: ChemistryLevel, seed?: number) => void
      openTask: (index: number) => void
      teleportPlayer?: (position: [number, number, number]) => void
      focusCamera?: (position: [number, number, number] | null, zoom?: number) => void
      scenePoint?: (name: string) => number[] | null
    }
  }
}

export function installDebugBridge() {
  if (!import.meta.env.DEV) return
  window.__CHEMSITE_DEBUG__ = {
    getSnapshot: () => useGameStore.getState(),
    startRound: (level, seed) => useGameStore.getState().startRound(level, seed),
    openTask: (index) => {
      const state = useGameStore.getState()
      const task = state.roundTasks[index]
      const station = STATIONS.find((candidate) => candidate.stationType === task?.station)
      if (!task || !station) return
      useGameStore.setState({
        currentTaskIndex: index,
        nearbyStationId: station.id,
        activeStationId: station.id,
        mode: 'station',
        answerFeedback: null,
        hintUsed: false,
        taskStartedAt: Date.now(),
      })
    },
  }
}

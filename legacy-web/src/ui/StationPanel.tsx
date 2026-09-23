import type { CSSProperties } from 'react'
import { getStation } from '../game/config/stations'
import { useGameStore } from '../state/useGameStore'
import { TaskSolver } from './TaskSolver'

export function StationPanel() {
  const activeStationId = useGameStore((state) => state.activeStationId)
  const tasks = useGameStore((state) => state.roundTasks)
  const currentTaskIndex = useGameStore((state) => state.currentTaskIndex)
  const station = getStation(activeStationId)
  const task = tasks[currentTaskIndex]
  if (!station) return null

  const isTargetStation = task?.station === station.stationType

  return (
    <div className="modal-layer" role="dialog" aria-modal="true" aria-labelledby="station-title">
      <section className="station-panel" style={{ '--station-accent': station.accent } as CSSProperties}>
        <div className="station-panel__stripe" />
        <span className="station-panel__icon" aria-hidden="true">{station.icon}</span>
        {isTargetStation && task ? (
          <TaskSolver task={task} />
        ) : (
          <>
            <span className="eyebrow">ДРУГАЯ ЗОНА РАБОТ</span>
            <h2 id="station-title">{station.name}</h2>
            <p>{station.description}</p>
            <div className="station-panel__readout station-panel__readout--warning">
              <span>МАРШРУТ</span>
              <strong>ТЕКУЩЕЕ ЗАДАНИЕ РЕШАЕТСЯ НА ДРУГОЙ СТАНЦИИ</strong>
            </div>
            <button type="button" className="primary-button" onClick={() => useGameStore.getState().closeStation()}>
              Вернуться на площадку <span>Esc</span>
            </button>
          </>
        )}
      </section>
    </div>
  )
}

import { getStation, STATIONS } from '../game/config/stations'
import { useGameStore } from '../state/useGameStore'

export function Hud() {
  const mode = useGameStore((state) => state.mode)
  const nearbyStationId = useGameStore((state) => state.nearbyStationId)
  const hasMoved = useGameStore((state) => state.hasMoved)
  const roundTasks = useGameStore((state) => state.roundTasks)
  const currentTaskIndex = useGameStore((state) => state.currentTaskIndex)
  const score = useGameStore((state) => state.score)
  const combo = useGameStore((state) => state.combo)
  const timeRemaining = useGameStore((state) => state.timeRemaining)
  const currentLevel = useGameStore((state) => state.currentLevel)
  const gameplayMode = useGameStore((state) => state.gameplayMode)
  const practiceTimed = useGameStore((state) => state.practiceTimed)
  const station = getStation(nearbyStationId)
  const currentTask = roundTasks[currentTaskIndex]
  const targetStation = STATIONS.find((candidate) => candidate.stationType === currentTask?.station)
  const minutes = Math.floor(timeRemaining / 60)
  const seconds = String(timeRemaining % 60).padStart(2, '0')

  if (!['playing', 'paused', 'station'].includes(mode)) return null

  return (
    <div className="hud" aria-live="polite">
      <section className="objective-chip" aria-label="Текущая цель">
        <div className="objective-chip__header">
          <span className="work-order-id">{gameplayMode === 'practice' ? 'DRILL' : `CS–0${currentLevel}`}</span>
          <span className="eyebrow">{gameplayMode === 'practice' ? 'ПРАКТИКА' : `УРОВЕНЬ ${currentLevel}`} · ЗАДАНИЕ {Math.min(currentTaskIndex + 1, 5)}/5</span>
          <span className="task-pips" aria-hidden="true">
            {Array.from({ length: 5 }, (_, index) => (
              <i key={index} className={index <= currentTaskIndex ? 'task-pip task-pip--active' : 'task-pip'} />
            ))}
          </span>
        </div>
        <strong>{currentTask?.prompt ?? 'Подготовка смены…'}</strong>
        <span className="objective-progress">
          {targetStation ? `Маршрут: ${targetStation.name}` : 'Терминалы подключаются'}
        </span>
      </section>

      <section className="site-status" aria-label="Статус площадки">
        <span className="status-light" />
        <div className="site-status__timer">
          <small>ДО КОНЦА СМЕНЫ</small>
          <span>{gameplayMode === 'practice' && !practiceTimed ? '∞' : `${minutes}:${seconds}`}</span>
        </div>
        <div className="site-status__score">
          <small>ОЧКИ</small>
          <span>{score}</span>
          <strong>{combo >= 2 ? `СЕРИЯ ×${combo}` : 'СМЕНА АКТИВНА'}</strong>
        </div>
      </section>

      {mode === 'playing' && station && (
        <div className="interaction-prompt">
          <span className="keycap">E</span>
          <div>
            <span>РАБОЧИЙ ПОСТ ДОСТУПЕН</span>
            <strong>{station.name}</strong>
          </div>
        </div>
      )}

      {mode === 'playing' && !station && !hasMoved && (
        <div className="controls-hint">
          <span><b>WASD</b> / стрелки — движение</span>
          <i />
          <span><b>E</b> — станция</span>
          <i />
          <span><b>Esc</b> — пауза</span>
        </div>
      )}

      {mode === 'playing' && (
        <button
          className="pause-button"
          type="button"
          aria-label="Открыть меню паузы"
          onClick={() => useGameStore.getState().togglePause()}
        >
          <span />
          <span />
        </button>
      )}
    </div>
  )
}

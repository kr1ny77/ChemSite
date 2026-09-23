import { useGameStore } from '../state/useGameStore'

export function CameraControls() {
  const mode = useGameStore((s) => s.mode)
  const zoom = useGameStore((s) => s.learningProgress.settings.cameraZoom)
  if (mode !== 'playing') return null
  const change = (value: number) => useGameStore.getState().updateSettings({ cameraZoom: Math.max(0.8, Math.min(2.8, value)) })
  return <div className="camera-controls" aria-label="Масштаб камеры">
    <button className="secondary-button" aria-label="Отдалить камеру" onClick={() => change(zoom - 0.2)}>−</button>
    <button className="secondary-button" title="Сбросить масштаб. Колесо мыши — приближение" onClick={() => change(1)}>{Math.round(zoom * 100)}%</button>
    <button className="secondary-button" aria-label="Приблизить камеру" onClick={() => change(zoom + 0.2)}>+</button>
  </div>
}

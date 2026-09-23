import { useGameStore } from '../state/useGameStore'

export function PauseMenu() {
  const paused = useGameStore((state) => state.mode === 'paused')
  const progress = useGameStore((state) => state.learningProgress)
  if (!paused) return null

  return (
    <div className="modal-layer modal-layer--dark" role="dialog" aria-modal="true" aria-labelledby="pause-title">
      <section className="pause-panel">
        <span className="eyebrow">СМЕНА ПРИОСТАНОВЛЕНА</span>
        <h2 id="pause-title">Пауза</h2>
        <div className="control-grid">
          <span><b>WASD</b><small>Движение</small></span>
          <span><b>E</b><small>Станция</small></span>
          <span><b>Space</b><small>Действие</small></span>
          <span><b>Q</b><small>Отмена</small></span>
        </div>
        <div className="pause-progress">
          <span><small>КАРЬЕРА</small><b>Уровень {progress.unlockedLevel}/5</b></span>
          <span><small>ОПЫТ</small><b>{progress.xp} XP</b></span>
          <span><small>ПОВТОРЕНИЯ</small><b>{progress.reviewQueue.length}</b></span>
        </div>
        <div className="settings-grid" aria-label="Настройки игры">
          <button type="button" className="setting-toggle" onClick={() => useGameStore.getState().updateSettings({ highQualityGraphics: !progress.settings.highQualityGraphics })}>
            Качество графики <span>{progress.settings.highQualityGraphics ? 'ВЫСОКОЕ' : 'ЛЁГКОЕ'}</span>
          </button>
          <label>
            <span>Lo-fi музыка <b>{Math.round(progress.settings.musicVolume * 100)}%</b></span>
            <input aria-label="Громкость музыки" type="range" min="0" max="1" step="0.05" value={progress.settings.musicVolume} onChange={(event) => useGameStore.getState().updateSettings({ musicVolume: Number(event.target.value) })} />
          </label>
          <label>
            <span>Общая громкость <b>{Math.round(progress.settings.soundVolume * 100)}%</b></span>
            <input
              type="range"
              min="0"
              max="1"
              step="0.05"
              value={progress.settings.soundVolume}
              onChange={(event) => useGameStore.getState().updateSettings({ soundVolume: Number(event.target.value) })}
            />
          </label>
          <label>
            <span>Эффекты <b>{Math.round(progress.settings.effectsVolume * 100)}%</b></span>
            <input
              type="range"
              min="0"
              max="1"
              step="0.05"
              value={progress.settings.effectsVolume}
              onChange={(event) => useGameStore.getState().updateSettings({ effectsVolume: Number(event.target.value) })}
            />
          </label>
          <button
            type="button"
            className={progress.settings.reducedMotion ? 'setting-toggle setting-toggle--active' : 'setting-toggle'}
            onClick={() => useGameStore.getState().updateSettings({ reducedMotion: !progress.settings.reducedMotion })}
          >
            Сниженная анимация <span>{progress.settings.reducedMotion ? 'ВКЛ' : 'ВЫКЛ'}</span>
          </button>
          <button
            type="button"
            className={progress.settings.cameraEffects ? 'setting-toggle setting-toggle--active' : 'setting-toggle'}
            onClick={() => useGameStore.getState().updateSettings({ cameraEffects: !progress.settings.cameraEffects })}
          >
            Экранные эффекты <span>{progress.settings.cameraEffects ? 'ВКЛ' : 'ВЫКЛ'}</span>
          </button>
        </div>
        <div className="pause-actions">
          <button type="button" className="primary-button" onClick={() => useGameStore.getState().togglePause()}>
            Продолжить <span>Esc</span>
          </button>
          <button type="button" className="secondary-button" onClick={() => useGameStore.getState().restartCurrentRound()}>
            Начать смену заново
          </button>
          <button type="button" className="secondary-button" onClick={() => useGameStore.getState().goToMenu()}>
            Главное меню
          </button>
        </div>
      </section>
    </div>
  )
}

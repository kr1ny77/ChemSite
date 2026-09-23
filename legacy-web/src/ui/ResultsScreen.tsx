import { useGameStore } from '../state/useGameStore'

export function ResultsScreen() {
  const mode = useGameStore((state) => state.mode)
  const status = useGameStore((state) => state.roundStatus)
  const score = useGameStore((state) => state.score)
  const results = useGameStore((state) => state.results)
  const currentLevel = useGameStore((state) => state.currentLevel)
  const gameplayMode = useGameStore((state) => state.gameplayMode)
  const practiceTopic = useGameStore((state) => state.practiceTopic)
  const practiceTimed = useGameStore((state) => state.practiceTimed)
  const learningProgress = useGameStore((state) => state.learningProgress)
  if (mode !== 'results') return null

  const correct = results.filter((result) => result.correct).length
  const stars = correct === 5 ? 3 : correct >= 4 ? 2 : correct >= 3 ? 1 : 0
  const resultTopics = new Set(results.map((result) => result.topic))
  const mastery = Object.values(learningProgress.mastery)
    .filter((entry) => resultTopics.has(entry.topic))
    .sort((left, right) => left.mastery - right.mastery)
    .slice(0, 3)

  return (
    <div className="modal-layer modal-layer--results" role="dialog" aria-modal="true" aria-labelledby="results-title">
      <section className="results-panel">
        <span className="eyebrow">{gameplayMode === 'practice' ? 'ТРЕНИРОВКА ЗАВЕРШЕНА' : 'СМЕНА ЗАВЕРШЕНА'}</span>
        <h2 id="results-title">{status === 'expired' ? 'Время вышло' : gameplayMode === 'practice' ? 'Тема отработана' : 'Участок принят'}</h2>
        <div className="stars" aria-label={`${stars} из 3 звёзд`}>
          {[0, 1, 2].map((star) => <span key={star} className={star < stars ? 'star star--earned' : 'star'}>★</span>)}
        </div>
        <div className="results-stats">
          <div><strong>{score}</strong><span>ОЧКОВ</span></div>
          <div><strong>{correct}/{results.length || 5}</strong><span>ВЕРНО</span></div>
          <div><strong>{currentLevel}</strong><span>УРОВЕНЬ</span></div>
        </div>
        <div className="career-progress">
          <div className="career-progress__summary">
            <span><small>ОПЫТ</small><b>{learningProgress.xp} XP</b></span>
            <span><small>РЕКОРД УРОВНЯ</small><b>{learningProgress.highScores[currentLevel] ?? score}</b></span>
            <span><small>ОТКРЫТО</small><b>{learningProgress.unlockedLevel}/5</b></span>
          </div>
          {mastery.length > 0 && (
            <div className="mastery-list" aria-label="Освоение тем">
              {mastery.map((entry) => (
                <div key={entry.topic}>
                  <span>{entry.topic}</span>
                  <i><b style={{ width: `${Math.round(entry.mastery * 100)}%` }} /></i>
                  <strong>{Math.round(entry.mastery * 100)}%</strong>
                </div>
              ))}
            </div>
          )}
        </div>
        <div className="results-actions">
          <button
            type="button"
            className="primary-button"
            onClick={() => {
              if (gameplayMode === 'practice' && practiceTopic) useGameStore.getState().startPractice(practiceTopic, practiceTimed)
              else useGameStore.getState().startRound(currentLevel < 5 ? (currentLevel + 1) as 2 | 3 | 4 | 5 : currentLevel)
            }}
          >
            {gameplayMode === 'practice' ? 'Повторить тренировку' : currentLevel < 5 ? `Перейти на уровень ${currentLevel + 1}` : 'Новая смена'}
            <span>5 заданий</span>
          </button>
          <button type="button" className="secondary-button" onClick={() => useGameStore.getState().goToMenu()}>
            Главное меню
          </button>
        </div>
      </section>
    </div>
  )
}

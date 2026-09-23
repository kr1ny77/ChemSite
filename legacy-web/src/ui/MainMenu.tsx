import { useState } from 'react'
import { PRACTICE_TOPICS } from '../chemistry/practice/topics'
import type { ChemistryLevel } from '../chemistry/types'
import { useGameStore } from '../state/useGameStore'

const levels = [
  { level: 1, title: 'Химический склад', topics: 'Формулы · ионы · классификация', code: 'CS–01' },
  { level: 2, title: 'Зона реакций', topics: 'Уравнения · осадки · ОВР', code: 'CS–02' },
  { level: 3, title: 'Лаборатория растворов', topics: 'Моли · концентрации · pH', code: 'CS–03' },
  { level: 4, title: 'Инженерная химия', topics: 'ΔH · кинетика · электрохимия', code: 'CS–04' },
  { level: 5, title: 'Строительный химик', topics: 'Бетон · вода · коррозия', code: 'CS–05' },
] as const

export function MainMenu() {
  const mode = useGameStore((state) => state.mode)
  const progress = useGameStore((state) => state.learningProgress)
  const [practiceTopic, setPracticeTopic] = useState(PRACTICE_TOPICS[0].id)
  const [timed, setTimed] = useState(false)

  if (mode === 'menu') {
    const earnedStars = Object.values(progress.stars).reduce((sum, stars) => sum + (stars ?? 0), 0)
    return (
      <div className="menu-layer">
        <section className="main-menu-panel">
          <div className="menu-brand"><span>CS</span><div><small>СТРОИТЕЛЬНАЯ ХИМИЯ</small><h1>CHEM<strong>SITE</strong></h1></div></div>
          <p>Исследуй химию прямо на строительной площадке: двигайся между рабочими постами, выполняй расчёты и принимай инженерные решения.</p>
          <div className="menu-progress">
            <span><small>КАРЬЕРА</small><b>{progress.unlockedLevel}/5</b></span>
            <span><small>ОПЫТ</small><b>{progress.xp} XP</b></span>
            <span><small>ЗВЁЗДЫ</small><b>{earnedStars}/15</b></span>
          </div>
          <div className="menu-actions">
            <button type="button" className="menu-action menu-action--career" onClick={() => useGameStore.getState().openCareerSelect()}>
              <span>01</span><div><b>Карьерный режим</b><small>Пять уровней строительной химии</small></div><i>→</i>
            </button>
            <button type="button" className="menu-action" onClick={() => useGameStore.getState().openPracticeSelect()}>
              <span>02</span><div><b>Практика</b><small>Выбор темы и свободный таймер</small></div><i>→</i>
            </button>
          </div>
          <div className="menu-controls"><b>WASD</b> движение <i /> <b>E</b> взаимодействие <i /> <b>Esc</b> пауза</div>
        </section>
      </div>
    )
  }

  if (mode === 'career-select') {
    return (
      <div className="menu-layer menu-layer--wide">
        <section className="mode-panel">
          <header className="mode-panel__header">
            <div><span className="eyebrow">КАРЬЕРНЫЙ РЕЖИМ</span><h2>Выбери рабочий участок</h2></div>
            <button type="button" className="icon-button" onClick={() => useGameStore.getState().goToMenu()}>← <span>Назад</span></button>
          </header>
          <div className="level-grid">
            {levels.map((entry) => {
              const unlocked = entry.level <= progress.unlockedLevel
              const stars = progress.stars[entry.level] ?? 0
              return (
                <article key={entry.level} className={unlocked ? 'level-card' : 'level-card level-card--locked'}>
                  <span className="level-card__code">{entry.code}</span>
                  <div className="level-card__number">0{entry.level}</div>
                  <h3>{entry.title}</h3>
                  <p>{entry.topics}</p>
                  <div className="level-card__stars" aria-label={`${stars} звёзд`}>{[0, 1, 2].map((star) => <span key={star} className={star < stars ? 'earned' : ''}>★</span>)}</div>
                  <button type="button" disabled={!unlocked} onClick={() => useGameStore.getState().startRound(entry.level as ChemistryLevel, import.meta.env.DEV ? 4 : undefined)}>
                    {unlocked ? 'Начать уровень' : 'Требуется предыдущий уровень'}
                  </button>
                </article>
              )
            })}
          </div>
        </section>
      </div>
    )
  }

  if (mode === 'practice-select') {
    const selected = PRACTICE_TOPICS.find((topic) => topic.id === practiceTopic) ?? PRACTICE_TOPICS[0]
    return (
      <div className="menu-layer menu-layer--wide">
        <section className="mode-panel practice-panel">
          <header className="mode-panel__header">
            <div><span className="eyebrow">ПРАКТИКА</span><h2>Настрой тренировку</h2></div>
            <button type="button" className="icon-button" onClick={() => useGameStore.getState().goToMenu()}>← <span>Назад</span></button>
          </header>
          <div className="practice-layout">
            <div className="practice-topics">
              {PRACTICE_TOPICS.map((topic) => (
                <button key={topic.id} type="button" className={topic.id === practiceTopic ? 'practice-topic practice-topic--selected' : 'practice-topic'} onClick={() => setPracticeTopic(topic.id)}>
                  <span>{topic.icon}</span><div><b>{topic.name}</b><small>{topic.description}</small></div>
                </button>
              ))}
            </div>
            <aside className="practice-config">
              <span className="practice-config__icon">{selected.icon}</span>
              <small>ВЫБРАННАЯ ТЕМА</small>
              <h3>{selected.name}</h3>
              <p>{selected.description}</p>
              <button type="button" className={timed ? 'timer-toggle timer-toggle--active' : 'timer-toggle'} onClick={() => setTimed((value) => !value)}>
                <span>Таймер 15 минут</span><b>{timed ? 'ВКЛ' : 'СВОБОДНО'}</b>
              </button>
              <button type="button" className="primary-button" onClick={() => useGameStore.getState().startPractice(practiceTopic, timed)}>
                Начать тренировку <span>5 заданий</span>
              </button>
            </aside>
          </div>
        </section>
      </div>
    )
  }

  return null
}

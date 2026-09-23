import { type FormEvent, useEffect, useState } from 'react'
import type { TaskDefinition } from '../chemistry/types'
import { formatCorrectAnswer } from '../chemistry/validators/answers'
import { useGameStore } from '../state/useGameStore'
import { EngineeringInstrument } from './EngineeringInstrument'
import { MissionSequence } from './MissionSequence'

const interactionLabels: Partial<Record<TaskDefinition['interactionType'], string>> = {
  'multiple-choice': 'ВЫБОР ПРИНЦИПА',
  'substance-card': 'КАРТОЧКА ВЕЩЕСТВА',
  'formula-builder': 'СБОРКА ФОРМУЛЫ',
  'ion-builder': 'ВЫБОР ИОНА',
  classification: 'КЛАССИФИКАЦИЯ',
  'oxidation-state': 'СТЕПЕНЬ ОКИСЛЕНИЯ',
  'periodic-table': 'ПЕРИОДИЧЕСКАЯ СИСТЕМА',
  sorting: 'СОРТИРОВКА ВЕЩЕСТВ',
  'equation-completion': 'РЕАКЦИОННАЯ ДОСКА',
  'equation-balancing': 'БАЛАНСИРОВКА',
  'virtual-mixing': 'ВИРТУАЛЬНОЕ СМЕШИВАНИЕ',
  'precipitate-prediction': 'ПРОГНОЗ ОСАДКА',
  'gas-identification': 'ГАЗОАНАЛИЗАТОР',
  'ionic-equation': 'ИОННЫЙ РЕАКТОР',
  'activity-series': 'РЯД АКТИВНОСТИ',
  redox: 'ЭЛЕКТРОННЫЙ БАЛАНС',
  'virtual-scales': 'ВИРТУАЛЬНЫЕ ВЕСЫ',
  'numeric-calculation': 'РАСЧЁТНЫЙ ТЕРМИНАЛ',
  'solution-preparation': 'ПРИГОТОВЛЕНИЕ РАСТВОРА',
  'pH-terminal': 'pH-ТЕРМИНАЛ',
  dissociation: 'ИОННЫЙ РЕАКТОР',
  hydrolysis: 'ГИДРОЛИЗ',
  'hess-puzzle': 'ЭНЕРГЕТИЧЕСКИЙ МАРШРУТ',
  'kinetics-experiment': 'КИНЕТИЧЕСКИЙ СТЕНД',
  'equilibrium-control': 'КОНТУР РАВНОВЕСИЯ',
  electrochemistry: 'ГАЛЬВАНИЧЕСКИЙ ПОСТ',
  'corrosion-inspection': 'СКАНЕР КОРРОЗИИ',
  'construction-material': 'ЛАБОРАТОРИЯ МАТЕРИАЛОВ',
  'construction-mission': 'ИНЖЕНЕРНАЯ МИССИЯ',
}

export function TaskSolver({ task }: { task: TaskDefinition }) {
  const [answer, setAnswer] = useState('')
  const [missionStep, setMissionStep] = useState(0)
  const feedback = useGameStore((state) => state.answerFeedback)
  const hintUsed = useGameStore((state) => state.hintUsed)
  const isEquation = ['equation-completion', 'equation-balancing', 'virtual-mixing', 'ionic-equation', 'dissociation'].includes(task.interactionType)
  const isEngineering = [
    'hess-puzzle', 'kinetics-experiment', 'equilibrium-control', 'electrochemistry',
    'corrosion-inspection', 'construction-material', 'construction-mission',
  ].includes(task.interactionType)
  const isInstrument = typeof task.correctAnswer !== 'string' && !isEngineering

  useEffect(() => {
    setAnswer('')
    setMissionStep(0)
  }, [task.id])

  const missionSteps = task.parameters?.missionSteps ?? []
  const missionComplete = missionSteps.length === 0 || missionStep >= missionSteps.length - 1

  const submit = (event: FormEvent) => {
    event.preventDefault()
    if (answer.trim()) useGameStore.getState().submitAnswer(answer)
  }

  if (feedback) {
    return (
      <div className={feedback.correct ? 'task-feedback task-feedback--correct' : 'task-feedback task-feedback--incorrect'}>
        <span className="task-feedback__status">{feedback.correct ? 'ВЕРНО' : 'РАЗБЕРЁМ ОШИБКУ'}</span>
        <h3>{feedback.correct ? `+${feedback.scoreAwarded} очков` : `Правильный ответ: ${formatCorrectAnswer(task)}`}</h3>
        <p>{task.explanation}</p>
        {task.rule && <div className="learning-note"><b>Правило</b>{task.rule}</div>}
        {task.example && <div className="learning-note"><b>Пример</b>{task.example}</div>}
        <button type="button" className="primary-button" onClick={() => useGameStore.getState().continueAfterFeedback()}>
          {useGameStore.getState().roundStatus === 'complete' ? 'Открыть результаты' : 'Следующее задание'}
          <span>Enter</span>
        </button>
      </div>
    )
  }

  return (
    <form className="task-solver" onSubmit={submit}>
      <span className="eyebrow">{interactionLabels[task.interactionType] ?? 'ХИМИЧЕСКАЯ ЗАДАЧА'} · {task.id}</span>
      <h2 id="station-title">{task.prompt}</h2>

      <EngineeringInstrument interactionType={task.interactionType} />

      {missionSteps.length > 0 && (
        <MissionSequence
          steps={missionSteps}
          activeStep={missionStep}
          onAdvance={() => setMissionStep((current) => Math.min(current + 1, missionSteps.length - 1))}
        />
      )}

      {task.interactionType === 'virtual-mixing' && (
        <div className="mixing-visual" aria-hidden="true">
          <span className="beaker beaker--blue" />
          <span className="mixing-arrow">+</span>
          <span className="beaker beaker--amber" />
          <span className="mixing-arrow">→</span>
          <span className="reaction-vessel">?</span>
        </div>
      )}

      {isInstrument && (
        <div className="instrument-readout" aria-hidden="true">
          <span>{task.interactionType === 'virtual-scales' ? '⚖' : task.interactionType === 'pH-terminal' ? 'pH' : '∑'}</span>
          <div><small>ИЗМЕРИТЕЛЬНЫЙ КАНАЛ</small><strong>ГОТОВ К ВВОДУ</strong></div>
        </div>
      )}

      {missionComplete && (task.options ? (
        <div className={task.interactionType === 'sorting' ? 'answer-grid answer-grid--wide' : 'answer-grid'}>
          {task.options.map((option, index) => (
            <button
              key={option}
              type="button"
              className={answer === option ? 'answer-option answer-option--selected' : 'answer-option'}
              onClick={() => setAnswer(option)}
            >
              <span>{String.fromCharCode(65 + index)}</span>
              {option}
            </button>
          ))}
        </div>
      ) : (
        <>
          <label className="answer-input">
            <span>{task.interactionType === 'formula-builder' ? 'Формула' : isEquation ? 'Уравнение' : 'Ответ'}</span>
            <input
              autoFocus
              value={answer}
              onChange={(event) => setAnswer(event.target.value)}
              placeholder={task.interactionType === 'formula-builder' ? 'Например: CaCO3' : isEquation ? 'Реагенты → продукты' : 'Введите значение'}
              inputMode={typeof task.correctAnswer !== 'string' ? 'decimal' : 'text'}
              autoComplete="off"
              spellCheck={false}
            />
          </label>
          {task.parameters?.formulaTokens && (
            <div className="formula-tokens" aria-label="Доступные элементы формулы">
              {task.parameters.formulaTokens.map((token, index) => (
                <button key={`${token}-${index}`} type="button" onClick={() => setAnswer((current) => current + token)}>
                  {token}
                </button>
              ))}
              <button type="button" className="formula-tokens__clear" onClick={() => setAnswer('')}>Сброс</button>
            </div>
          )}
        </>
      ))}

      {missionComplete && (hintUsed ? (
        <div className="hint-card"><b>Подсказка</b>{task.hint}</div>
      ) : (
        <button type="button" className="hint-button" onClick={() => useGameStore.getState().revealHint()}>
          Показать подсказку <span>−20 очков</span>
        </button>
      ))}

      {missionComplete && (
        <button type="submit" className="primary-button" disabled={!answer.trim()}>
          Проверить ответ <span>Enter</span>
        </button>
      )}
    </form>
  )
}

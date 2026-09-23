import type { TaskDefinition } from '../chemistry/types'
import { audioManager } from '../audio/audioManager'

type MissionStep = NonNullable<NonNullable<TaskDefinition['parameters']>['missionSteps']>[number]

export function MissionSequence({
  steps,
  activeStep,
  onAdvance,
}: {
  steps: MissionStep[]
  activeStep: number
  onAdvance: () => void
}) {
  const complete = activeStep >= steps.length - 1

  return (
    <div className="mission-sequence" aria-label="Этапы инженерной миссии">
      <div className="mission-sequence__track">
        {steps.map((step, index) => (
          <div
            key={`${step.title}-${index}`}
            className={index < activeStep ? 'mission-step mission-step--done' : index === activeStep ? 'mission-step mission-step--active' : 'mission-step'}
          >
            <span>{index < activeStep ? '✓' : index + 1}</span>
            <div><b>{step.title}</b><small>{index <= activeStep ? step.readout : 'Ожидает проверки'}</small></div>
          </div>
        ))}
      </div>
      {!complete && (
        <button type="button" className="mission-advance" onClick={() => { audioManager.play('scan'); onAdvance() }}>
          Выполнить этап <span>{activeStep + 2}/{steps.length}</span>
        </button>
      )}
      {complete && <div className="mission-ready"><span>✓</span> Данные собраны — вынеси инженерное решение</div>}
    </div>
  )
}

import type { InteractionType } from '../chemistry/types'

const supportedInteractions: readonly InteractionType[] = [
  'hess-puzzle',
  'kinetics-experiment',
  'equilibrium-control',
  'electrochemistry',
  'corrosion-inspection',
  'construction-material',
  'construction-mission',
]

function isEngineeringInteraction(interactionType: InteractionType) {
  return supportedInteractions.includes(interactionType)
}

export function EngineeringInstrument({ interactionType }: { interactionType: InteractionType }) {
  if (!isEngineeringInteraction(interactionType)) return null

  if (interactionType === 'hess-puzzle') {
    return (
      <div className="engineering-instrument energy-route" aria-hidden="true">
        <span className="energy-node">A</span><i /><span className="energy-node energy-node--high">B</span><i /><span className="energy-node">C</span>
        <b>Σ ΔH</b>
      </div>
    )
  }

  if (interactionType === 'kinetics-experiment') {
    return (
      <div className="engineering-instrument kinetics-rig" aria-hidden="true">
        <div className="particle-field particle-field--slow"><i /><i /><i /><i /></div>
        <span>ФАКТОР</span>
        <div className="particle-field particle-field--fast"><i /><i /><i /><i /><i /><i /><i /></div>
      </div>
    )
  }

  if (interactionType === 'equilibrium-control') {
    return (
      <div className="engineering-instrument equilibrium-rig" aria-hidden="true">
        <div className="equilibrium-side"><i /><i /><i /><i /></div>
        <strong>⇌</strong>
        <div className="equilibrium-side equilibrium-side--product"><i /><i /></div>
        <span className="pressure-gauge">P</span>
      </div>
    )
  }

  if (interactionType === 'electrochemistry') {
    return (
      <div className="engineering-instrument electro-cell" aria-hidden="true">
        <div className="electrode electrode--anode"><b>Zn</b><small>АНОД</small></div>
        <div className="electron-wire"><i>e⁻</i><i>e⁻</i><span>→</span></div>
        <div className="electrode electrode--cathode"><b>Cu</b><small>КАТОД</small></div>
      </div>
    )
  }

  if (interactionType === 'corrosion-inspection') {
    return (
      <div className="engineering-instrument corrosion-scan" aria-hidden="true">
        <div className="steel-sample"><i /><i /><i /></div>
        <div className="scan-line" />
        <span>Fe</span><b>СКАН ПОВЕРХНОСТИ</b>
      </div>
    )
  }

  return (
    <div className="engineering-instrument materials-rig" aria-hidden="true">
      <span className="sample sample--aggregate" />
      <span className="sample sample--binder" />
      <span className="sample sample--water">H₂O</span>
      <strong>→</strong>
      <span className="sample sample--concrete">MPa</span>
    </div>
  )
}

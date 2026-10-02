import type { StationType } from '../game/types'

export type ChemistryLevel = 1 | 2 | 3 | 4 | 5
export type Difficulty = 1 | 2 | 3 | 4 | 5

export type InteractionType =
  | 'multiple-choice'
  | 'substance-card'
  | 'formula-builder'
  | 'ion-builder'
  | 'classification'
  | 'oxidation-state'
  | 'periodic-table'
  | 'sorting'
  | 'equation-completion'
  | 'equation-balancing'
  | 'virtual-mixing'
  | 'precipitate-prediction'
  | 'gas-identification'
  | 'ionic-equation'
  | 'activity-series'
  | 'redox'
  | 'virtual-scales'
  | 'numeric-calculation'
  | 'solution-preparation'
  | 'pH-terminal'
  | 'dissociation'
  | 'hydrolysis'
  | 'hess-puzzle'
  | 'kinetics-experiment'
  | 'equilibrium-control'
  | 'electrochemistry'
  | 'corrosion-inspection'
  | 'construction-material'
  | 'construction-mission'

export type NumericAnswerConfig = {
  value: number
  absoluteTolerance?: number
  relativeTolerance?: number
  unit?: string
}

export type TaskDefinition = {
  id: string
  level: ChemistryLevel
  topic: string
  subtopic: string
  difficulty: Difficulty
  station: StationType
  interactionType: InteractionType
  prompt: string
  correctAnswer: string | NumericAnswerConfig
  acceptedAnswers?: string[]
  options?: string[]
  parameters?: {
    formulaTokens?: string[]
    compound?: string
    mixingReagents?: string[]
    mixingOptions?: string[]
    mixingObservation?: string
    scaleMode?: 'mass-to-moles' | 'moles-to-mass'
    sampleMass?: number
    sampleMoles?: number
    molarMass?: number
    hessStart?: string
    hessEnd?: string
    hessEdges?: { from: string; to: string; deltaH: number }[]
    comparisonRuns?: { setting: string; observation: string }[]
    phSamples?: { label: string; value: number }[]
    ionizationSamples?: { label: string; observation: string }[]
    dissociationIons?: { cation: { label: string; count: number; charge: number }; anion: { label: string; count: number; charge: number } }
    solutionMode?: 'mass' | 'dilution'
    targetVolumeMl?: number
    targetConcentration?: number
    stockConcentration?: number
    solutionVolumeChoicesL?: number[]
    missionSteps?: {
      title: string
      readout: string
    }[]
  }
  explanation: string
  rule?: string
  example?: string
  hint: string
  points: number
  timeLimit?: number
  tags: string[]
  constructionContext?: string
  procedural: boolean
  generatorId?: string
  reviewStatus: 'verified' | 'review-required'
}

export type TaskResult = {
  taskId: string
  correct: boolean
  submittedAnswer: string
  normalizedAnswer: string
  timeSpentSeconds: number
  hintUsed: boolean
  scoreAwarded: number
  topic: string
  subtopic: string
  tags: string[]
}

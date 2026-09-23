export type Vec3 = readonly [number, number, number]

export type StationType =
  | 'periodic-table-terminal'
  | 'substance-storage'
  | 'formula-board'
  | 'reaction-bench'
  | 'mixing-station'
  | 'solution-laboratory'
  | 'ionic-reaction-station'
  | 'electrochemistry-station'
  | 'corrosion-test-rig'
  | 'construction-materials-station'
  | 'inspection-station'

export type StationDefinition = {
  id: string
  name: string
  shortName: string
  description: string
  stationType: StationType
  position: Vec3
  accent: string
  icon: string
  interactionRadius: number
}

export type GameMode = 'menu' | 'career-select' | 'practice-select' | 'playing' | 'paused' | 'station' | 'results'

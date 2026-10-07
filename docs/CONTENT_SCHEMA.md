# Chemistry Content Schema

The production Godot runtime stores verified tasks as JSON in `data/chemistry/`. The TypeScript definition below documents the preserved source schema used to export all 200 native tasks.

All chemistry content must be stored as structured data.

Chemistry questions belong in structured data, separate from native scenes and UI scripts.

The same task system should support:

- curated questions
- procedurally generated variants
- adaptive difficulty
- spaced repetition
- different station types
- different interaction types
- Career Mode
- Practice Mode

---

## TaskDefinition

Use a structure similar to:

```ts
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

export type TaskDefinition = {
  id: string

  level: ChemistryLevel

  topic: string
  subtopic: string

  difficulty: Difficulty

  station: StationType
  interactionType: InteractionType

  prompt: string

  parameters?: {
    formulaTokens?: string[]
    compound?: string
    missionSteps?: { title: string; readout: string }[]
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
  }

  correctAnswer: unknown

  acceptedAnswers?: unknown[]

  explanation: string

  rule?: string

  example?: string

  hint?: string

  points: number

  timeLimit?: number

  tags: string[]

  constructionContext?: string

  procedural?: boolean

  generatorId?: string

  reviewStatus?: 'verified' | 'review-required'
}
```

---

## Example task

```ts
const task: TaskDefinition = {
  id: 'L1-NOM-001',

  level: 1,

  topic: 'Inorganic nomenclature',
  subtopic: 'Salts',

  difficulty: 1,

  station: 'substance-storage',
  interactionType: 'substance-card',

  prompt: 'Назови вещество BaSO4',

  correctAnswer: 'сульфат бария',

  acceptedAnswers: [
    'сульфат бария',
    'barium sulfate'
  ],

  explanation:
    'BaSO4 состоит из катиона Ba2+ и сульфат-иона SO4^2-.',

  rule:
    'SO4^2- называется сульфатом, а SO3^2- — сульфитом.',

  example:
    'Na2SO4 — сульфат натрия.',

  hint:
    'Обрати внимание на ион SO4^2-.',

  points: 100,

  tags: [
    'salt',
    'sulfate',
    'nomenclature',
    'barium'
  ],

  procedural: false,

  reviewStatus: 'verified'
}
```

---

## GeneratedTask

Procedurally generated tasks should use a separate runtime structure.

```ts
export type GeneratedTask = TaskDefinition & {
  sourceTemplateId: string

  generatedSeed?: string | number

  generatedAt?: number
}
```

This allows the game to distinguish between:

- manually curated questions
- generated variants

---

## Task result

Each completed task should produce a result.

```ts
export type TaskResult = {
  taskId: string

  correct: boolean

  submittedAnswer: unknown

  normalizedAnswer?: unknown

  timeSpentSeconds: number

  hintUsed: boolean

  scoreAwarded: number

  topic: string

  subtopic: string

  tags: string[]
}
```

---

## Answer normalization

Answers must not rely only on exact string equality.

Create specialized validators.

Suggested validators:

```ts
normalizeTextAnswer()
normalizeChemicalFormula()
validateFormula()
validateNumber()
validateEquation()
validateIon()
validateNomenclature()
validateMultipleChoice()
validateOxidationState()
```

---

## Text normalization

For text answers:

- trim spaces
- ignore accidental repeated spaces
- optionally ignore case
- support explicitly allowed synonyms

Example:

```text
Сульфат бария
сульфат бария
```

should be treated as equivalent when appropriate.

---

## Chemical formula normalization

Chemical formulas require stricter handling.

Examples:

```text
H2SO4
h2so4
```

may be accepted after case normalization only when the parser can safely reconstruct chemical symbols.

The validator must preserve:

- element symbols
- indices
- brackets
- coefficients
- ionic charges

Do not blindly lowercase formulas before comparison.

---

## Numeric answers

Numeric tasks must support tolerance.

Example:

```ts
correctAnswer: 100.086
```

Valid answers may include:

```text
100.09
100.1
100
```

depending on the configured tolerance.

Suggested structure:

```ts
type NumericAnswerConfig = {
  value: number
  absoluteTolerance?: number
  relativeTolerance?: number
  unit?: string
}
```

Example:

```ts
correctAnswer: {
  value: 100.09,
  absoluteTolerance: 0.2,
  unit: 'g/mol'
}
```

---

## Equation validation

Chemical equations should be validated structurally where possible.

Example:

```text
2H2 + O2 -> 2H2O
```

Equivalent spacing should be accepted.

The validator should verify:

- compounds
- products
- stoichiometric coefficients
- atom balance

For reactions where order does not matter:

```text
NaCl + H2O
H2O + NaCl
```

may be treated as equivalent.

---

## Ionic equations

Net ionic equations should support proper ion and charge parsing.

Example:

```text
Ba2+ + SO4^2- -> BaSO4
```

The validator should verify:

- ionic species
- charges
- coefficients
- product
- charge balance
- atom balance

---

## Question selection

The task manager should choose tasks using these rules.

During one round:

- never show the exact same task twice
- avoid repeating the same chemical compound unnecessarily
- alternate interaction types
- alternate stations when possible
- avoid more than two consecutive tasks from the same topic
- prioritize weak topics
- respect level difficulty

---

## Level 1 selection

Default Level 1 round:

```text
5 tasks
15 minute maximum
```

The round ends immediately after all 5 tasks are completed.

Selection should prioritize variety.

Example:

```text
Task 1:
substance naming

Task 2:
formula builder

Task 3:
oxidation state

Task 4:
classification

Task 5:
periodic table
```

Avoid five questions of the same type.

---

## Spaced repetition

When a player answers incorrectly:

1. record the topic
2. record the subtopic
3. record relevant tags
4. reduce mastery score
5. schedule a related task later
6. use a different substance or situation

The similar task should normally appear after approximately:

```text
2-5 other tasks
```

Example:

Wrong task:

```text
BaSO3
```

The player confuses sulfite and sulfate.

Later tasks may use:

```text
Na2SO3
CaSO3
Al2(SO4)3
```

Do not immediately repeat the exact same question.

---

## Mastery model

Track mastery separately for concepts.

Suggested structure:

```ts
export type TopicMastery = {
  topic: string

  attempts: number

  correct: number

  incorrect: number

  mastery: number

  lastAttemptAt?: number

  consecutiveCorrect: number

  mistakeWeight: number
}
```

`mastery` can be stored as:

```text
0 to 1
```

or:

```text
0 to 100
```

Use one format consistently.

---

## Difficulty adaptation

The game should adapt task selection.

If mastery is high:

- reduce very easy tasks
- introduce harder variants

If mastery is low:

- increase related tasks
- keep explanations available
- avoid sudden large difficulty jumps

Difficulty changes should feel gradual.

---

## Procedural generation

Procedural generation is allowed only when the answer can be calculated deterministically.

Recommended generated categories:

### Molar mass

Generate from a curated compound list.

Example:

```text
Calculate the molar mass of CaCO3.
```

The answer is computed from atomic masses.

### Mole / mass conversion

Example:

```text
How many moles are in 20 g NaOH?
```

### Molarity

Example:

```text
0.5 mol in 2 L
```

### Dilution

Use:

```text
C1V1 = C2V2
```

### Oxidation states

Use compounds where the oxidation-state solution is unambiguous.

### Formula building

Generate using curated cations and anions.

Example:

```text
Al3+
SO4^2-
```

Result:

```text
Al2(SO4)3
```

### Ion matching

Use a curated ion database.

---

## Procedural generation restrictions

Do not procedurally invent:

- unknown reactions
- complicated redox chemistry
- ambiguous nomenclature
- construction chemistry conclusions
- corrosion mechanisms
- equilibrium scenarios without verified data

These should use curated tasks.

---

## Generator interface

Use a generator architecture similar to:

```ts
export interface TaskGenerator {
  id: string

  generate(
    difficulty: Difficulty,
    seed?: number
  ): GeneratedTask

  validate(task: GeneratedTask): boolean
}
```

Possible generators:

```text
molarMassGenerator
moleMassGenerator
molarityGenerator
dilutionGenerator
oxidationStateGenerator
formulaBuilderGenerator
ionMatchingGenerator
```

---

## Chemistry databases

Keep reusable chemistry data separate.

Suggested files:

```text
src/chemistry/data/elements.ts
src/chemistry/data/ions.ts
src/chemistry/data/compounds.ts
src/chemistry/data/reactions.ts
src/chemistry/data/atomicMasses.ts
```

Example ion:

```ts
{
  id: 'sulfate',
  formula: 'SO4',
  charge: -2,
  names: {
    ru: 'сульфат',
    en: 'sulfate'
  }
}
```

---

## Task bank organization

Suggested structure:

```text
src/chemistry/tasks/
  level1/
  level2/
  level3/
  level4/
  level5/
```

Or:

```text
src/chemistry/tasks/level1.ts
src/chemistry/tasks/level2.ts
src/chemistry/tasks/level3.ts
src/chemistry/tasks/level4.ts
src/chemistry/tasks/level5.ts
```

Do not create one huge React file containing all 200 tasks.

---

## Explanations

Every task must provide educational feedback.

Incorrect-answer feedback should preferably contain:

1. correct answer
2. short explanation
3. relevant rule
4. one small example

Example:

```text
Неверно.

BaSO3 — сульфит бария.

SO3^2- = сульфит
SO4^2- = сульфат

Пример:
Na2SO4 — сульфат натрия.
```

Keep explanations concise.

---

## Hints

Hints should help without directly revealing the full answer whenever possible.

Example:

Question:

```text
Name BaSO4.
```

Hint:

```text
Look at the name of the SO4^2- ion.
```

Using a hint may slightly reduce awarded points.

---

## Construction context

Some tasks should connect chemistry to construction.

Example:

```ts
constructionContext:
  'A reinforced concrete element is exposed to moisture and chlorides.'
```

This context may be shown before a multi-stage mission.

---

## Multi-stage missions

Construction missions may consist of several linked steps.

Example:

```text
Step 1:
inspect concrete

Step 2:
measure virtual pH

Step 3:
identify relevant chemical process

Step 4:
answer corrosion question

Step 5:
choose protection principle
```

Use a mission structure such as:

```ts
export type MissionStep = {
  id: string
  taskId: string
  required: boolean
}

export type ChemistryMission = {
  id: string

  level: ChemistryLevel

  title: string

  description: string

  steps: MissionStep[]

  points: number

  tags: string[]
}
```

---

## Review system

Every curated task should have:

```ts
reviewStatus: 'verified'
```

If correctness is uncertain:

```ts
reviewStatus: 'review-required'
```

Tasks marked:

```text
review-required
```

must not enter normal gameplay.

Add them to:

```text
CHEMISTRY_REVIEW.md
```

---

## Automated tests

Write tests for:

- formula normalization
- numerical tolerance
- molar mass
- mole/mass conversion
- molarity
- dilution
- oxidation states
- ion matching
- nomenclature
- equation balancing
- ionic equations
- task selection
- anti-repetition
- spaced repetition
- mastery updates
- score calculation

---

## Optional site observations

`data/chemistry/site_inspections.json` contains optional, unscored site observations. Each entry has a stable `id`, a visible `name`, a three-number world `position`, and a short `text`. The world loader converts positions to `Vector3`; the HUD displays the text without treating it as a chemistry answer. Scientific claims receive a source check in `docs/CHEMISTRY_REVIEW.md`.

## Core rule

Chemistry content is data.

Game mechanics interpret that data.

Godot Control scenes render the result.

These systems must remain separate.

## Curated mixing visual

The five Level 2 virtual-mixing tasks optionally contain `parameters.mixingVisual`: `kind` is `precipitate` or `gas`, and `color` is a reviewed six-digit RGB value for the schematic observation. This metadata accompanies the existing `mixingObservation`; answer validation stays deterministic and independent. The illustration appears after the required pair is selected. Animation is schematic, has no measured rate/quantity, settles after 1.2 seconds, and is static with reduced motion.

## Curated comparison visuals

Nine Level 4 tasks optionally contain two ordered `parameters.comparisonVisuals`
entries corresponding to `comparisonRuns`. Supported `kind` values are
`metal-oxidation`, `metal-reduction`, `intact-coating`, `damaged-coating`,
`bare-surface`, `passive-film`, `dry-surface` and `electrolyte-film`. Electrode
entries provide a curated `caption` (the balanced half-equation already in the
readout) and six-digit RGB `color`. Renderers consume these values independently
of answer validation. Each diagram appears only after its probe is inspected;
its partner remains unrevealed. Motion is illustrative, eases over 1.2 seconds
and then stops. Reduced motion presents the final state immediately. Film
thickness, metal dimensions and particle counts carry no measured quantities.

# ChemSite Architecture

## System overview

Input
↓
Player Controller
↓
Game Simulation
├── Player State
├── Station System
├── Task Manager
├── Chemistry Engine
├── Score System
├── Adaptive Learning
├── Progression
└── Persistence
↓
localStorage

Rendering reads simulation state.

UI reads simulation and chemistry state.

## Suggested source structure

src/
app/
components/
game/
player/
world/
stations/
camera/
physics/
interactions/
chemistry/
tasks/
generators/
validators/
explanations/
data/
learning/
mastery/
repetition/
adaptiveDifficulty/
state/
ui/
hud/
menus/
taskCards/
results/
audio/
persistence/
assets/
tests/

## Game state

Keep game state independent from Three.js objects.

Suggested state:

- currentLevel
- levelTimer
- score
- combo
- activeTask
- completedTasks
- playerPosition
- playerHeldItem
- stationStates
- pauseState

## Chemistry state

Separate chemistry state:

- currentQuestion
- submittedAnswer
- answerResult
- explanation
- hintUsed
- weakTopics
- topicMastery

## Task lifecycle

queued
→ active
→ station selected
→ solving
→ submitted
→ evaluated
→ feedback
→ completed

## Stations

Create a reusable Station interface.

Example conceptual fields:

id
type
position
interactionRadius
acceptedTaskTypes
interactionState

Every station should support:

- idle
- nearby
- active
- success
- failure

## Physics

Use Rapier.

Player:

- dynamic or kinematic controller appropriate for arcade movement
- stable ground contact
- no unwanted rotation

World collisions:

- counters
- walls
- machinery
- props requiring collision

Use simple collision proxies rather than complex visual meshes.

## Rendering

Use React Three Fiber.

Use Drei where useful.

Production 3D assets:
GLB / GLTF.

## Persistence

Use localStorage.

Store:

- unlockedLevel
- stars
- XP
- mastery
- mistake history
- high scores
- settings
- tutorial completion

Version persisted data.

Example:

saveVersion: 1

Provide migration logic later if schema changes.

## Chemistry validation

Never validate complex chemistry by plain string equality alone.

Use specialized validators:

- normalizedFormulaValidator
- numericToleranceValidator
- equationCoefficientValidator
- multipleChoiceValidator
- nomenclatureValidator
- ionValidator

## Generated questions

Procedural generators may be used for deterministic tasks:

- molar mass
- mole/mass conversion
- molarity
- dilution
- simple oxidation states
- formula building
- ion matching

Complex chemistry should use curated datasets.

## Performance

Target:

- approximately 60 FPS
- low draw calls
- instancing where appropriate
- optimized GLB assets
- simple collision meshes
- restrained postprocessing

## Testing

Use unit tests for chemistry logic.

Use game-playtest / browser verification for gameplay.

Test:

- controls
- collisions
- station interactions
- question validation
- score
- timers
- save/load
- progression
- restart
- level selection
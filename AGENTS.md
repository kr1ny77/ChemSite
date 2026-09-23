# ChemSite Agent Instructions

ChemSite is a single-player 3D educational chemistry game set on a stylized construction site.

The player controls one cartoon construction chemistry student and moves around an isometric 3D level completing chemistry tasks at interactive stations.

## Primary goal

Build a genuinely playable educational game that makes first-year university chemistry for Civil Engineering / Construction students engaging.

Target curriculum:
- 08.03.01 Construction / Civil Engineering
- first-year university chemistry
- UGNTU where applicable
- MGSU curriculum as fallback/reference

## Core stack

The production game uses Godot 4.x, Forward+, GDScript, native scenes and Control UI, and GLB assets. The previous React, TypeScript, Vite and Three.js game is preserved in `legacy-web/` as a reference and content source.

The game is desktop-first.

Target approximately 60 FPS on a normal student laptop.

## Available game skills

Use `studio-router` to select relevant Godot, Blender, art, UI, QA, and release skills. Browser skills apply only to `legacy-web/`.

## Single-player only

ChemSite contains exactly one controllable player.

Do not implement:

- multiplayer
- online networking
- local co-op
- split screen
- synchronization
- replication
- server-authoritative gameplay

## Required files to read before working

At the beginning of every run read:

1. AGENTS.md
2. docs/GAME_DESIGN.md
3. docs/ARCHITECTURE.md
4. docs/CHEMISTRY_CURRICULUM.md
5. docs/CONTENT_SCHEMA.md
6. TODO.md
7. PROGRESS.md
8. docs/CHEMISTRY_REVIEW.md when chemistry content is involved

Inspect the repository and git diff before modifying existing work.

## Autonomous continuation protocol

If the previous run ended because of:

- usage limit
- timeout
- crash
- application restart
- interrupted session

continue automatically.

Procedure:

1. Read TODO.md.
2. Read PROGRESS.md.
3. Inspect the repository.
4. Inspect current git diff.
5. Verify the latest completed checkpoint.
6. Find the first unfinished task.
7. Continue from that task.

Do not ask the user what to do next when TODO.md already defines the next action.

Do not repeat completed phases.

## Development rules

Gameplay first.

Art second.

Keep these systems separate:

- game simulation
- rendering
- input
- chemistry logic
- question content
- UI
- persistence
- audio

Do not put chemistry questions directly inside Godot scenes or UI scripts.

Do not create giant monolithic components.

Prefer reusable systems.

## Verification rules

After meaningful changes run the relevant checks.

At minimum where applicable:

- Godot editor import and parse
- native runtime smoke test
- relevant tests and visual playtest
- export verification for release work

Fix errors before advancing to the next phase.

When a playable feature changes, visually verify it.

## Progress tracking

After every meaningful completed task:

1. update TODO.md
2. update PROGRESS.md
3. record tests performed
4. record any unresolved issue

PROGRESS.md must always state:

- current phase
- completed work
- current work
- next task
- last verification
- known issues

## Chemistry accuracy

Chemistry correctness has priority over content quantity.

For every chemistry task:

- correct answer must be deterministic
- explanation must be scientifically correct
- accepted answer variants should be explicit

If an answer is ambiguous or uncertain:

1. do not guess
2. add the task to docs/CHEMISTRY_REVIEW.md
3. exclude it from production question selection until reviewed

Runtime question generation must use deterministic logic or a verified curated dataset.

Do not ask an LLM at runtime to invent chemistry answers.

## Safety

All experiments are virtual.

Do not add practical instructions for dangerous chemical preparation or hazardous laboratory procedures.

## Stop conditions

Continue working through TODO.md unless:

- all planned work is complete
- a genuinely irreversible product decision requires the user
- credentials are required
- external permissions are missing
- continuing risks damaging user work

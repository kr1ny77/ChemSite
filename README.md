# ChemSite

ChemSite is a single-player 3D educational chemistry game for first-year Civil Engineering / Construction students.

The game combines chemistry learning with a fast interactive construction-site environment.

The player controls a stylized construction chemistry student using the keyboard and runs between interactive stations to solve chemistry tasks.

## Core concept

Instead of answering a static quiz, the player physically moves around a construction site.

Examples:

- run to the Formula Board to construct CaCO3
- use the Reaction Bench to finish an equation
- use virtual scales to prepare a solution
- inspect reinforced concrete for corrosion
- use a pH analyzer
- diagnose construction-material chemistry problems

## Controls

WASD / Arrow Keys:
move

E:
interact

Space:
station action

Q:
drop / cancel

Enter:
confirm text answers

Esc:
pause

## Game modes

### Career

Five progressive chemistry levels.

### Practice

Train specific topics without strict progression.

Examples:

- nomenclature
- salts
- oxidation states
- reactions
- ionic equations
- solutions
- pH
- redox
- equilibrium
- corrosion
- construction chemistry

## Technology

- React
- TypeScript
- Vite
- Three.js
- React Three Fiber
- Drei
- Rapier Physics
- Zustand
- localStorage

## Run locally

Requires Node.js 20.19 or newer.

### macOS: one-click launch

Double-click `START_CHEMSITE.command`. The launcher installs dependencies when needed, starts the game and opens `http://localhost:5173`.

The first macOS launch may require Control-clicking the file and choosing **Open**.

### Terminal

```bash
npm install
npm start
```

Open `http://localhost:5173` in a WebGL-capable desktop browser.

Keep the terminal window open while playing. Press `Ctrl+C` to stop the local server.

For development with LAN access, use `npm run dev`. To serve a production build locally, use:

```bash
npm run build
npm run preview
```

## Verification

```bash
npm run typecheck
npm run lint
npm run test
npm run build
npm run test:e2e
```

Run all non-browser checks with `npm run check`.

The Playwright suite uses local Chrome's default graphics path and verifies movement, solid prop collisions, station interaction, chemistry submission, pause/resume, complete rendered frames and narrow-viewport layout. Set `CHEMSITE_SOFTWARE_WEBGL=1` to run the gameplay suite through SwiftShader for compatibility diagnostics; software rendering is substantially slower than hardware graphics.

## Current playable content

- Level 1: 40 chemical formula, nomenclature, ion, classification, oxidation-state, periodic-table and bonding seeds
- Level 2: 40 reaction, balancing, precipitation, ionic-equation, activity-series and redox seeds
- Level 3: 40 molar-mass, solution, dilution, pH, dissociation and hydrolysis seeds
- Level 4: 40 thermochemistry, Hess-law, kinetics, equilibrium, electrochemistry and corrosion seeds
- Level 5: 40 cement, concrete, lime, gypsum, construction-water, reinforcement and materials-inspection seeds
- 320 deterministic calculated variants for 520 distinct playable task instances
- Five varied tasks per round with a 15-minute limit, score, combos, hints, feedback and results
- Career Mode with five progressive levels, XP, stars and high scores
- Practice Mode with nine topic tracks and an optional timer
- Adaptive weak-topic selection, topic mastery and expanding-interval spaced repetition
- Versioned localStorage persistence and accessible sound, motion and screen-effect settings

## Development documents

Read:

- GAME_DESIGN.md
- ARCHITECTURE.md
- CHEMISTRY_CURRICULUM.md
- CHEMISTRY_TASK_BANK.md
- CONTENT_SCHEMA.md
- TODO.md
- PROGRESS.md
### Camera and music

High-quality graphics are enabled by default: 1.5–2× render density, SMAA edge smoothing with screen effects, and 4096px sun shadows. Switch **Пауза → Качество графики → ЛЁГКОЕ** for a lower GPU load. Use in-game camera zoom for close inspection.

Use the mouse wheel over the scene or the bottom-right − / + buttons to zoom from 80% to 280%. Click the percentage to reset. Zooming in smoothly centers the engineer. Settings persist locally.

Four original, locally stored lo-fi tracks cycle automatically after your first click or keypress. Adjust **Lo-fi музыка** in the pause menu; set it to 0% to mute music independently of effects. Music pauses when the browser tab is hidden.

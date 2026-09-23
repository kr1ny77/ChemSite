# ChemSite Progress

## CURRENT PHASE

Hammer grip, detailed neighborhood and high-resolution rendering — final verification

## COMPLETED

- Original smooth engineer with detailed face, rounded helmet, reflective vest, gloves, boots, equipment, blinking, gait and answer feedback
- Three ambient workers outside the playable perimeter: carrying supplies, hammering at a bench and inspecting a clipboard
- Crane arm rotates at its authored pivot with a coordinated hanging hoist; machinery pauses and respects reduced-motion settings
- Foreground boxes separated from conveyor geometry
- Persistent 80–280% zoom through wheel and readable HUD buttons; fixed isometric angle with smooth close-up player tracking
- Four original offline-synthesized lo-fi MP3 arrangements (7m22s total), cyclic playback, independent volume and hidden-tab suspension
- Playwright regression for wheel/button zoom, all four playlist transitions, playback activation, muting and persistence

- PBR concrete and steel surface maps from supplied CC0 assets, browser-optimized with a reproducible conversion script
- Local environment reflections, corrected ACES postprocessing, restrained fog and multisample edge smoothing
- Rounded steel countertops, smoother helmet, cabin ribs, facade windows, curbs, drainage, paving and safety markings
- Corrected oversized bevel radii that raised floor meshes above their physics surface and concealed markings
- Imported static prop bounds now supply collision proxies; cabin and rotated station collision volumes match the visible objects
- Fixed 60 Hz physics step and regression tests for rotated-station sliding, cabin, column and stockpile impacts
- React 19, TypeScript, Vite, React Three Fiber, Drei, Rapier and Zustand application scaffold
- Explicit keyboard action mapping for WASD and arrow movement
- Responsive single-player Rapier controller with continuous collision detection
- Fixed isometric orthographic camera with subtle player tracking and a widened miniature-diorama composition
- Production construction-site diorama with four authored work zones, raised terrain, walkways, roads, skyline, crane, machinery, lab cabin, scaffolding, materials and collision proxies
- Eleven chemistry stations with concept-specific silhouettes, equipment, color signals and animated operating details
- Original cartoon construction chemistry student with PPE, chemistry backpack, idle motion, articulated run cycle and answer reactions
- Optimized CC0 industrial and construction asset libraries packaged as two validated multi-scene GLBs
- Cohesive concrete, steel, timber, safety-yellow, glass and chemistry-cyan material language
- ACES tone mapping, warm/cool site lighting, restrained ambient occlusion and bloom, shadow tuning, dust, bubbles and station effects
- Station proximity, contextual interaction prompt, station modal and input-safe pause menu
- Low-chrome responsive work-order HUD, interaction prompts, station panels and menus with reduced-motion support
- Development-only state bridge and Playwright browser-test harness
- Phase 1 unit and end-to-end checks
- Structured chemistry schema and deterministic text, formula, ion and oxidation-state validation
- All 40 verified Level 1 seed tasks with explanations, rules, examples, hints and interaction metadata
- Deterministic five-task selection with anti-duplication and interaction/station variety
- Mistake history with delayed same-concept remediation using a different compound
- Fifteen-minute round timer, score, time bonus, hint penalty, combo multiplier and immediate five-task completion
- Formula construction, card selection, classification, ion selection and written-answer task surfaces
- Correct/incorrect educational feedback and three-star Level 1 results screen
- Structural equation normalization with order-independent species comparison and ionic-charge handling
- Numeric answer validation with absolute/relative tolerance, decimal-comma and scientific-notation support
- All 40 verified Level 2 reaction seeds and all 40 verified Level 3 solution seeds
- Playable Level 2 and Level 3 five-task rounds reached through the results progression flow
- Reaction board, virtual mixing, ionic reactor, virtual scale, solution preparation and pH instrument treatments
- Eighth world station for ionic-equation and dissociation work
- All 40 verified Level 4 engineering-chemistry seeds and all 40 verified Level 5 construction-chemistry seeds
- Complete structured bank of 200 curated chemistry tasks across five playable levels
- Hess-law route, kinetic-particle rig, equilibrium control, galvanic-cell and corrosion-scan interaction treatments
- Sequential construction missions that reveal inspection, measurement and analysis stages before the final engineering decision
- Five-level progression through the results flow and specialist electrochemistry, corrosion and materials stations
- Visual production audit, asset selection record and asset-license manifest
- Two screenshot-driven visual review passes covering composition, scale, density, station readability, clipping and playfield clarity
- Versioned localStorage save data for XP, unlocks, stars, high scores, mastery, reviews and accessibility settings
- Topic mastery updates, weak-topic prioritization and expanding-interval spaced repetition
- 320 deterministic generated variants for a total of 520 playable chemistry task instances
- Synthesized Web Audio cues for station interaction, inspection, success, error, pause and round completion
- Persistent master/effects volume, reduced-motion and screen-effects controls
- Main menu, five-level Career Mode selector and nine-topic Practice Mode with optional timer
- Career/practice-specific HUD and results flows with restart and main-menu navigation
- Complete automated chemistry-integrity audit across 200 curated seeds and 320 deterministic variants
- Production dependency splitting into application, R3F, Three.js and Rapier cache chunks without circular chunk warnings
- Full five-level browser smoke test plus menu, persistence, accessibility, collision and responsive-layout coverage
- Stable `npm start` localhost entry point on port 5173 with strict port checking
- Executable macOS `START_CHEMSITE.command` launcher with first-run dependency installation and automatic browser opening
- Node.js version contract, production preview command and combined local verification command
- Time-bounded software-WebGL cadence test that remains meaningful under headless-browser throttling
- Clean dependency audit after updating Vitest and removing the unused vulnerable asset helper
- Fixed screen-covering station labels: orthographic zoom multiplied `distanceFactor=14` into a 476× CSS scale; labels now use constant screen-space size
- Bounded station-label z-index and isolated the world layer below HUD and modal layers
- Added default-Chrome regression coverage of full composed screenshots, label bounds, repeated frames, pause and resize

## CURRENT WORK

- New hammer grip and restrained strike animation, optimized neighborhood GLB, wind animation and high-quality renderer implemented; running final browser verification

## NEXT TASK

1. Finish close-up hammer/scene inspection and quality-preset regression, then checkpoint the graphics pass.

## LAST VERIFIED

2026-09-23:

- Character/environment/music pass: `npm run check` passed (41 unit tests, typecheck, lint, production build)
- Eight Chrome browser tests passed, covering solid props, movement, station interactions, all five levels, zoom and music
- Reviewed `artifacts/playtest/polish-character-zoom.png` and `polish-site.png`; corrected low-contrast zoom controls and crane orientation after the first screenshot pass
- Local MP3 decoding checked with FFmpeg; first track peak −9.7 dBFS, with headroom and soft start/end fades
- Localhost HTTP 200 confirmed; no gameplay console errors in browser regressions

- `npm run check`: typecheck, lint, 41 unit tests and production build passed
- `npm run test:e2e`: all 7 tests passed in 33.5 seconds using ordinary Chrome graphics
- Four prop collision cases passed, including sliding along a rotated station without entering its volume
- Full composed screenshots reviewed at 1280×800 and 1440×900; floor markings, material detail, UI and station labels remain visible
- Hardware-path frame-cadence assertions passed with stricter 50 ms average / 100 ms p95 limits
- Texture provenance, 1.63 MiB texture budget and conversion procedure recorded in ASSET_LICENSES.md and ASSET_SELECTION.md
- `npm install`: dependency audit reports zero vulnerabilities

2026-09-22:

- Rendering fix: `npm run check` passed (41 unit tests, typecheck, lint, production build)
- Rendering fix: all 6 Playwright tests passed in 1.2 minutes, including default GPU Chrome and software-WebGL gameplay
- Visually inspected `artifacts/playtest/stable-02-play-2.png` and `stable-03-pause.png`; labels, scene and overlays are visible together
- Earlier canvas-only screenshots missed the oversized HTML labels; the new regression checks the composed page and label bounds
- `npm run typecheck` — passed
- `npm run lint` — passed
- `npm run test` — 41 tests passed across 12 test files
- `npm run build` — passed; application code is 276.62 kB before gzip and engine dependencies are split into stable cache chunks
- Playwright desktop flow — boot, movement, formula-station proximity, correct formula submission, feedback, task advance, pause/resume and perimeter collision passed
- Playwright 390 × 844 viewport sanity — passed
- Direct WebGL canvas frames inspected across two art-review passes; scene composition, player silhouette, material consistency, lighting, station readability and central navigation space are intact
- Browser console — no application errors after adding the project favicon
- Level 4 specialist interaction flow and Level 5 staged mission flow — passed in Playwright
- Career menu, Practice Mode, untimed practice and persistent accessibility settings — passed in Playwright
- Playwright full-game suite — 5 tests passed, including one validated station task from every chemistry level
- SwiftShader render-cadence guard — passed without long frame stalls; hardware WebGL remains the production target
- Complete 520-task canonical-answer and visible-option audit — passed
- Localhost startup — `HTTP 200` from `http://localhost:5173`
- `npm start` — stable Vite server on `127.0.0.1:5173`
- macOS one-click launcher — executable and documented
- `npm run check` — typecheck, lint, 41 unit tests and production build passed
- Playwright full-game suite after launcher changes — 5 tests passed in 1.3 minutes
- `npm audit` — 0 vulnerabilities across production and development dependencies

## KNOWN ISSUES

- Rapier remains the largest production cache chunk at 2.24 MB before gzip (830 kB gzip); it is isolated from application updates.
- The in-app browser test surface lacks WebGL; play and visual verification use local Chrome.
- The full graphics preset is expensive under forced CPU SwiftShader and can exceed browser-test timeouts. The primary suite now exercises normal Chrome graphics; optional compatibility diagnostics use `CHEMSITE_SOFTWARE_WEBGL=1`.

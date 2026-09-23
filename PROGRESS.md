# ChemSite progress

## Current phase

Phases 3, 7 and 8 — environment, UI, visual and audio quality pass for the first native vertical slice.

## Completed work

- Inspected 270 project-local skills, the installed Blender Agent Studio MCP tools, the repository, existing curriculum and task bank, Git remote, Godot, Blender and Git LFS.
- Preserved the browser application, its tests, asset bundle and 200 curated task seeds in `legacy-web/`; moved the design and chemistry reference documents to `docs/`.
- Built a Godot 4.7 Forward+ root project with native menu, level, player, HUD, deterministic task data, scoring, results and versioned best-score/XP save.
- Selected 18 CC0 Kenney GLBs for the site. Authored an original rigged construction chemist and three chemistry stations using reproducible Blender scripts; exported GLBs and kept the `.blend` sources.
- Imported nine player actions with seven skeleton bones and wired locomotion, interaction and answer reactions to AnimationTree.
- Added ten verified Level 1 chemistry tasks, a five-task timed round, station routing, answer feedback, formula token assembly and periodic/card selections.
- Added an audio bus, a licensed legacy music track and generated interaction/correct/incorrect cues.
- Added a small color-coded answer particle burst; rendered the effect above the player and verified that its emitter frees itself after playback.
- Added a native audio settings panel with live music/effects bus control, persistent versioned values, keyboard focus and Escape navigation; captured it at 1440×900.
- Added a complete five-task round smoke test that checks station interactions, results and saved progress using an isolated test save.
- Configured a universal macOS release preset and built `builds/macos/ChemSite.app`. Launched its arm64 release binary outside the editor and captured its menu.
- Captured and visually reviewed the menu, site, station panel, formula builder and exported release menu under `artifacts/`.

## Current work

Improve the site composition, lighting, visual feedback and UI so the native slice meets the intended indie-game quality bar. Perform a complete exported-app round playtest.

## Next task

Add authored environment clusters and reliable collision proxies around the construction and storage areas; capture the rendered site and fix framing and readability issues.

## Last verification

2026-09-23: Godot headless import passed; scene, gameplay, complete-round, audio, settings and save smoke scripts passed; Python task-integrity check passed all ten tasks. Character import inspection found seven bones and all nine required actions. The universal macOS release app launched and rendered its menu outside the editor. Answer feedback and settings screens were captured and reviewed. `git diff --check` passed.

## Known issues

- The site still has sparse areas, flat material treatment and oversized edge machinery. Its current screenshot is an initial art pass.
- Station animations, chemistry-specific VFX, footstep/machinery ambience and accessibility controls remain pending. Answer feedback and audio settings are present.
- Character animation transitions work in the controller, but close-up deformation and timing need visual review.
- The macOS release is unsigned and unnotarized; a complete five-task playtest in the exported app remains open. Windows export is pending.
- Advanced mastery, weak-topic scheduling, combo/stars, Career/Practice modes and the remaining 190 curated tasks await later phases.

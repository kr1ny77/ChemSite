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
- Added an audio bus, a project-authored legacy music track and generated interaction/correct/incorrect cues.
- Added a small color-coded answer particle burst; rendered the effect above the player and verified that its emitter frees itself after playback.
- Added a native audio settings panel with live music/effects bus control, persistent versioned values, keyboard focus and Escape navigation; captured it at 1440×900.
- Split the gameplay HUD into a mission panel and a compact score/timer panel; reviewed the updated site capture at 1440×900.
- Compared the source Kenney GLB appearance in Godot, found that many props import white, and differentiated crane, steelwork, machinery and concrete with controlled runtime material families. Reviewed the new site capture.
- Added simple collision proxies for the storage frame, pipe rack, stairs, safety marker and machinery dressing. A physics smoke test confirms the perimeter and storage frame block movement.
- Authored a beveled, six-material site laboratory cabin in Blender with door, glazing, analyzer silhouettes, roof equipment and safety trim. Imported it as a rear landmark with a box collision proxy. Blender Agent Studio geometry inspection passed, and its six-view contact sheet and Godot site capture were reviewed.
- Authored cement-sack and strapped-brick pallets in Blender. Exported eight material-grouped meshes with an editable `.blend` source; added a collision proxy and reviewed the six-view contact sheet and updated site capture. Walked from spawn to all three stations in a physics route smoke test.
- Authored a freestanding first-aid and eyewash safety point in Blender beside the laboratory cabin. Six material-grouped meshes, front pictograms, lower supply cases and a collision proxy passed multi-angle, import, geometry and route review.
- Replaced two abstract off-perimeter machinery props with an original tilted-drum mixer inside the right boundary. Kept editable Blender source, a six-view review, and a simple frame-and-drum collision proxy.
- Replaced the left pad's unused stairs with an original paired rebar and formwork bay. Adjusted its position after the first camera capture hid the cages behind columns; both cages now read from the gameplay camera and leave the central route open.
- Added a complete five-task round smoke test that checks station interactions, results and saved progress using an isolated test save.
- Configured a universal macOS release preset and built `builds/macos/ChemSite.app`. Launched its arm64 release binary outside the editor and captured its menu.
- Captured and visually reviewed the menu, site, station panel, formula builder and exported release menu under `artifacts/`.

## Current work

Improve the site composition, lighting, visual feedback and UI so the native slice meets the intended indie-game quality bar. Perform a complete exported-app round playtest.

## Next task

Review character and station silhouettes from multiple camera angles, then improve station material polish and chemistry feedback.

## Last verification

2026-09-24: Godot import, complete-round, collision and all-three-station walking-route smoke scripts passed with the rebar bay in place. Blender Agent Studio inspection found five meshes, five materials, 3,456 triangles, zero degenerate faces, zero zero-length edges and a passing hard gate. The six-view contact sheet and 1440×900 Godot site capture were reviewed. The earlier mixer, safety point and material cache also passed geometry inspection. The macOS release export was refreshed and its app binary launched headless with the rebar bay in place.

## Known issues

- The laboratory cabin, material cache, safety point, mixer and rebar bay improve the site silhouette; the unfinished-building shell still needs a more coherent upper structure and material polish.
- Station animations, chemistry-specific VFX, footstep/machinery ambience and accessibility controls remain pending. Answer feedback and audio settings are present.
- Character animation transitions work in the controller, but close-up deformation and timing need visual review.
- The macOS release is unsigned and unnotarized; a complete five-task playtest in the exported app remains open. Windows export is pending.
- Advanced mastery, weak-topic scheduling, combo/stars, Career/Practice modes and the remaining 190 curated tasks await later phases.

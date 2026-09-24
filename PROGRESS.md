# ChemSite progress

## Current phase

Phases 3, 7 and 8 — environment, UI, visual and audio quality pass for the first native vertical slice.

## Completed work

- Inspected 270 project-local skills, the installed Blender Agent Studio MCP tools, the repository, existing curriculum and task bank, Git remote, Godot, Blender and Git LFS.
- Preserved the browser application, its tests, asset bundle and 200 curated task seeds in `legacy-web/`; moved the design and chemistry reference documents to `docs/`.
- Built a Godot 4.7 Forward+ root project with native menu, level, player, HUD, deterministic task data, scoring, results and versioned best-score/XP save.
- Selected 18 CC0 Kenney GLBs for the site. Authored an original rigged construction chemist and three chemistry stations using reproducible Blender scripts; exported GLBs and kept the `.blend` sources.
- Imported nine player actions with seven skeleton bones and wired locomotion, interaction and answer reactions to AnimationTree.
- Added all 40 curated Level 1 chemistry tasks to normal selection and exported all 200 structured tasks to native JSON. A schema check and Level 1 interaction smoke validate task shape, correct-answer acceptance, formula tiles and option choices. Formula and oxidation-state inputs now cover the Level 1 interaction set.
- Reviewed the oxidation-state panel at 1440×900 and replaced its answer-revealing placeholder with a neutral entry prompt.
- Launched the refreshed macOS app directly, entered Career through its visible menu, and reviewed the live construction-site render and HUD at 1440×900.
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
- Replaced the left pad's flat modular wall and columns with an original Blender concrete-frame shell. The partial slab, four supported posts, exposed rebar, shoring, formwork and safety rail were reviewed from six views and at gameplay zoom. The rebar bay remains visible beside it.
- Reviewed the exported character and all three stations from six angles. Fresh-imported the character's Run, Interact, Celebrate and Failure actions for key-frame review, found crossed arms in Celebrate, changed it to a raised-arm V, and verified the revised reaction in a Godot close-up capture.
- Reviewed Walk, Turn, PickUp and UseStation key poses as well. Moved the substance-storage station from behind the left building wall into the open rear lane, verified its first-task visibility at gameplay zoom, and revalidated the walking route, interaction, full round and collisions.
- Captured eight sustained locomotion frames in Godot and reviewed boot support and swing at gameplay zoom. Added a brief cyan/amber answer pulse at the active chemistry station; captured its appearance at 1440×900 and verified automatic cleanup.
- Added streak scoring (x1.5 after three correct, x2 after five), round XP and 1–3 star results. Migrated version-1 saves into version 2 while preserving scores and XP; recorded best stars. Reviewed the results screen at 1440×900 and fixed stale HUD data after the fifth answer.
- Added Career and topic-specific Practice entry flows. Practice offers the three verified Level 1 topics, disables the timer, ends after that topic's unique questions and leaves career progress untouched. Reviewed both menu states at 1440×900.
- Added original paired footstep cues driven by actual distance traveled on the floor, plus a spatial looping mixer sound routed through SFX. Both are reproducibly generated from the audio source script.
- Added a packaged-app QA entry path that exercises station panels, five answers, combo scoring, result state and isolated save data. The refreshed macOS release app passes this black-box runtime smoke with clean shutdown.
- Added a visual packaged-app QA path that saves all five task panels, five feedback screens and results from the release binary. Its answers now flow through HUD tile/option controls and their signals. The capture exposed two issues: the fifth task's explanation was replaced immediately by results, and feedback showed stale score/streak data. Both were corrected and the final screens re-reviewed at 1440×900.
- Added shared, restrained emission to the authored station glyphs, periodic tiles, storage markers and analyzer. The three work lights now vary subtly over time. Reviewed the rendered site at 1440×900 and rechecked all station walking routes.
- Added deterministic task ordering that prioritizes weak topics and alternates stations. Career now records per-topic mastery and mistakes in a version-3 save, advances after an incorrect answer, and schedules a different related verified task two questions later when available. Reviewed the incorrect-answer panel at 1440×900.
- Added a complete five-task round smoke test that checks station interactions, results and saved progress using an isolated test save.
- Configured a universal macOS release preset and built `builds/macos/ChemSite.app`. Launched its arm64 release binary outside the editor and captured its menu.
- Captured and visually reviewed the menu, site, station panel, formula builder and exported release menu under `artifacts/`.

## Current work

Complete visual QA for the expanded 40-task Level 1 bank and continue site, feedback and UI polish. Perform a complete exported-app round playtest.

## Next task

Complete a human-driven five-task round in the exported app and listen to the audio mix on target speakers. Implement distinct station mechanics for Levels 2–5 and independently review their chemistry content.

## Last verification

2026-09-24: The new shell exported from Blender 5.2.2 and fresh-import inspection passed with six materials, 5,132 triangles, no invalid vertices and no degenerate faces. A six-view contact sheet and 1440×900 Godot site render were reviewed. Godot editor import/parse, station routes, collision, Career and Practice smokes passed. The refreshed macOS app passed both headless and rendered five-task QA rounds, with each answer submitted through HUD controls. All five task and feedback screenshots and results were captured; final feedback and results were reviewed at full resolution. The rendered run exited cleanly after allowing effect resources to finish.

## Known issues

- The authored shell provides a coherent upper frame and safety-rail silhouette. Its surfaces and the surrounding modular props still need material refinement and richer environmental dressing.
- Station animations, chemistry-specific VFX and accessibility controls remain pending. Footstep/machinery audio has structural and level checks; a listening mix review remains pending.
- All nine action key poses have visual evidence, the revised celebration pose reads in Godot, and sustained locomotion has a contact sheet. Minor in-place foot slide may benefit from later animation polish.
- The macOS release is unsigned and unnotarized; its automated five-task round and full visual capture pass. A human-driven round in the exported app and Windows export remain pending.
- Level 1 mastery and weak-topic scheduling now work. All 200 source tasks are structured in native JSON; only 40 Level 1 tasks enter gameplay. Level progression, later-level mechanics and independent scientific review of the broader bank remain pending.

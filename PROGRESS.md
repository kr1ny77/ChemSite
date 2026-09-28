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
- Reviewed the Level 2 answer bank and explanations, checked 20 molecular and ionic equations for element and charge conservation, and placed L2-050 in the chemistry review queue for phosphorus oxide notation. Re-exporting the preserved TypeScript bank reapplies the review status through a native override file.
- Added full-equation input for Level 2 completion, balancing, virtual mixing and ionic tasks. Chemistry validation now accepts display arrows and Unicode subscript/charge glyphs while retaining exact element case and the curated answer set. A Godot content smoke opens every one of the 39 verified Level 2 panels, accepts each curated answer and excludes L2-050.
- Rendered the Level 2 equation panel at 1440×900. The first capture exposed an answer-revealing placeholder; the final capture uses a neutral reactant/product prompt and a localized station name.
- Authored four distinct Level 2 GLB stations in Blender with editable sources: reaction bench, twin-vessel mixer, ionic console and inspection desk. Blender Agent Studio fresh imports passed geometry inspection with 5,088–6,336 triangles and no issues; six-view sheets and the 1440×900 site render were reviewed. Godot physical walking routes reach all four stations.
- Added Level 2 career entry after a completed five-task Level 1 round. Version-4 saves retain earlier progress and unlock Level 2 for prior saves with earned stars. A complete five-task Level 2 smoke visits four stations, accepts verified answers, reaches results and saves progress.
- Refreshed the macOS and Windows release exports with the Level 2 route. The packaged macOS app and Windows PCK each pass the Level 2 five-task round through HUD answer controls. The Windows binary remains to be executed on a Windows host.
- Audited all 40 Level 3 tasks: independently recomputed 24 numeric results, checked four dissociation equations for atom/charge conservation, and checked 12 choice tasks. Clarified the dilute-solution approximation in pH prompts and rules in the preserved TypeScript source, then re-exported the 200-task native bank. Added numeric and dissociation HUD controls and visually reviewed a 1440×900 numeric panel; fixed its station label.
- Authored a Blender solution laboratory with shielded balance, volumetric vessels and pH display; kept editable source and GLB. Fresh Blender Agent Studio inspection passed with 10,628 triangles and no geometry issues, and six-view plus Godot gameplay-camera renders were reviewed.
- Connected all 40 Level 3 tasks to a career round across the solution, ionic and inspection stations. Completing Level 2 unlocks Level 3. Physical walking routes, a five-task HUD round, the refreshed macOS app, a rendered packaged round and the Windows PCK all passed. Saved 1440×900 Level 3 site, numeric task and result screenshots under `docs/screenshots/`.
- Reviewed all 40 Level 4 tasks against textbook thermochemistry, kinetics, equilibrium, electrochemistry and corrosion references. Independently recalculated two Hess answers and checked 38 accepted choices. Tightened two pressure-shift prompts to specify constant-temperature compression/expansion. A Godot content smoke opens every Level 4 task and validates its correct option or numeric answer.
- A 1440×900 visual pass exposed long Level 4 options expanding the HUD grid beyond the screen. Choice cards now wrap inside fixed columns, adjust height and font size for longer text, and give dense panels more vertical room. The repaired L4-125 and L4-160 panels were recaptured and reviewed.
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
- Configured a Windows Desktop x86_64 release preset. The official Godot 4.7.2 Windows template produced `builds/windows/ChemSite.exe` and `ChemSite.pck`; the PE header identifies a 64-bit Windows GUI program. The PCK completed the packaged five-task round under the matching Godot runtime on macOS.
- Added a data-driven Level 2 virtual mixing control: learners select a reagent pair and see the curated observation before entering an equation. Added a staged Level 5 mission readout that unlocks the answer after the inspection steps. All five mixing tasks and nine staged mission tasks passed interaction gates and answer checks; 1440×900 before/after panels were visually reviewed and preserved in `docs/screenshots/`.
- Added a Level 3 virtual scale panel for five curated mass/mole tasks. A preparation action reveals the given measurement and molar mass; the learner selects the applicable equation before numeric entry. The Level 3 content smoke rejects the wrong formula and checks the locked input; source, macOS app and Windows PCK five-task scale rounds passed. Both 1440×900 control states were visually reviewed.
- Added a Level 4 Hess route puzzle for both numeric calculations. Learners chain directed enthalpy steps; reversing a step flips its ΔH sign. Route completion unlocks the numeric entry. Content checks cover a backtrack/reset, the required signs, locked input and both accepted answers. Source, macOS app and Windows PCK focused five-task rounds passed, and both 1440×900 states were reviewed.
- Added a Windows GitHub Actions workflow that downloads official Godot 4.7.2 editor/templates, exports the native EXE, runs five career rounds plus the Level 5 mission round on Windows, and uploads the paired EXE/PCK artifact. Run 36444307931 passed all steps on a Windows runner.
- Captured and visually reviewed the menu, site, station panel, formula builder and exported release menu under `artifacts/`.

## Current work

Levels 1–5 are playable career rounds. The Level 2 mixing and Level 5 inspection controls now provide contextual station interactions. All affected task controls and packaged Level 5 mission rounds passed automated QA. Human playtesting, accessibility, performance and release QA remain open.

## Next task

Extend contextual station interactions to Level 4 kinetics/equilibrium and the remaining Level 3 task families. Then run a human-driven exported-app/audio playtest, profile the site on a normal student laptop, complete visible Windows QA, resolve L2-050 with the target curriculum, complete subject-matter review, and publish the GitHub prerelease.

## Last verification

2026-09-28: Godot 4.7.2 import/parse, TypeScript typecheck, Level 4 audit, all 40 Level 4 HUD submissions and both Hess path/sign checks passed. A focused source round and refreshed macOS app/Windows PCK rounds passed; both panel states were reviewed at 1440×900. Windows Actions run 36446518724 passed the native EXE five-level suite plus the Level 3 scale, Level 4 Hess and Level 5 mission rounds, then uploaded the paired build.

## Known issues

- The authored shell provides a coherent upper frame and safety-rail silhouette. Its surfaces and the surrounding modular props still need material refinement and richer environmental dressing.
- Station animations, chemistry-specific VFX and accessibility controls remain pending. Footstep/machinery audio has structural and level checks; a listening mix review remains pending.
- All nine action key poses have visual evidence, the revised celebration pose reads in Godot, and sustained locomotion has a contact sheet. Minor in-place foot slide may benefit from later animation polish.
- The macOS release is unsigned and unnotarized; its automated five-task round and full visual capture pass. A human-driven round in the exported app remains pending. The Windows x86_64 EXE passed automated rounds on GitHub Actions; visible input, audio and save behavior on Windows remains to be reviewed.
- Level 1 mastery and weak-topic scheduling now work. All 200 source tasks are structured in native JSON; 199 are marked verified and L2-050 is excluded pending notation review. Levels 1–5 enter gameplay through separate career rounds. All five levels still need human playtesting and contextual interaction polish.

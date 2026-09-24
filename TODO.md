# ChemSite native production plan

## Completed checkpoints

- [x] Phase 0: inspect the repository, local skills and tools; preserve the browser runtime and all 200 curated tasks in `legacy-web/`; establish Godot as the root project
- [x] Phase 1: create the Godot 4.7 Forward+ project, main menu, native scenes and selected CC0 GLB imports
- [x] Phase 2: implement CharacterBody3D movement, collision, camera follow and station proximity
- [x] Phase 4 foundation: build the original rigged player in Blender, export nine skeletal actions and drive locomotion and reactions through AnimationTree
- [x] Phase 5 foundation: build three distinct Blender-authored stations and implement card, periodic selection and formula assembly interactions
- [x] Phase 6 slice: port ten verified Level 1 tasks to native JSON; validate their answers and run a five-task round
- [x] Phase 12 data port: export all 200 curated tasks into native JSON, validate schema and answers structurally, and enable all 40 Level 1 tasks with formula tiles, oxidation input and eight practice topics
- [x] Phase 3 shell landmark: replace the left pad's flat modular wall and columns with a Blender-authored open concrete frame, partial slab, shoring and safety rails; verify six views, game camera, collisions and station routes
- [x] Phase 11 exported visual round: capture five task panels, five feedback states and results from the macOS release binary; submit answers through actual HUD controls and preserve the final explanation before results
- [x] Phase 9 foundation: persist best score, stars, XP, completed rounds, topic mastery and mistakes in a versioned Godot save
- [x] Phase 10: configure and launch a universal macOS release app from the official Godot 4.7.2 export template
- [x] Phase 15 export foundation: add a Windows Desktop x86_64 release preset, produce a PE32+ build with a separate PCK, and run the packaged data through the isolated round smoke
- [x] Phase 12 Level 2 audit pass: review all 40 reaction tasks, verify conservation in 20 authored equations, and quarantine one phosphorus oxide notation issue from native selection
- [x] Phase 13 Level 2 input foundation: add full-equation entry for reaction, mixing and ionic tasks; normalize formula subscripts, ion charge glyphs and arrows; validate every selectable Level 2 task and panel in Godot

## Current phase — Phase 3/7/8: vertical-slice quality pass

- [ ] Author denser chemistry clusters with coherent landmarks, paths and collision proxies; the Blender laboratory cabin, material cache, safety point, mixer, rebar bay and concrete-frame shell define the construction site
- [ ] Refine station and character materials, scale, readability, rig deformation and animation timing from multiple camera angles; authored station accents now emit softly, all nine character actions and sustained locomotion have visual reviews, and the storage rack is visible from the game camera
- [ ] Add chemistry VFX and restrained environment motion; answer feedback pulses at the active station, work lights breathe subtly, and footsteps/spatial mixer ambience play during movement and exploration
- [ ] Complete production HUD hierarchy, formula typography and accessibility; Career and topic-specific Practice modes, score, XP, combo, stars, audio settings and keyboard focus are in place
- [ ] Complete a human-driven five-task playtest in the exported app and resolve gameplay and visual QA findings; packaged macOS runs now capture and verify all five HUD interaction states and results

## Later phases

- [ ] Phase 9: complete adaptive mastery and expanded progression data for Levels 2–5; Level 1 now records mastery and schedules a related task two questions after a mistake
- [ ] Phase 11: full visual, gameplay, chemistry and accessibility QA
- [ ] Phase 12 review: independently review the remaining Level 3–5 answers and explanations, resolve L2-050 with the target curriculum, and keep later levels out of production selection until their station mechanics pass gameplay QA
- [ ] Phase 13: Levels 2–5 and their station mechanics; Level 2 input and content validation are ready, with station assets, placement, round selection and visual QA still required
- [ ] Phase 14: measure and optimize for a student laptop at approximately 60 FPS
- [ ] Phase 15: run the Windows x86_64 executable on a Windows host, verify input/audio/save/visuals and complete the five-task black-box test
- [ ] Phase 16: source push and GitHub prerelease after the vertical slice meets its quality gate

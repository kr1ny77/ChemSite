# Construction student character — current art direction

## Human direction, 2026-10-05

The supplied four Overcooked images establish the requested cartoon treatment.
Build an original construction student: oversized rounded head, compact pear-shaped
body, short legs, soft mitt-like hands, expressive simple eyes and eyebrows,
yellow fitted hardhat, orange reflective work vest, navy workwear and compact boots.
Use smooth modeled surfaces and a warm, saturated material palette. Keep the face
and construction silhouette readable in the actual isometric game camera.

The supplied images are visual references only. Create original geometry,
materials and animation. Reference images live in `references/overcooked-style/`.

## Proportion and movement contract

Initial proportion targets are authoring assumptions, subject to multiview review:
head including hardhat about 40% of total height; torso about 35%; legs and boots
about 25%. Shoulder width approximately head width. Preserve rounded waist,
sleeve transitions and garment continuity through locomotion and reaching.

Movement uses quick alternating steps, restrained body bounce, relaxed arms,
responsive acceleration and eased heading. Check the full cycle at gameplay scale
for skating, hesitant cadence and jitter. Interaction remains upright; omit
squat and crouching poses. Preserve the nine existing action names for engine
compatibility; PickUp becomes a short upright reach if retained.

## Acceptance evidence

- Blender front, back, profile and three-quarter silhouettes plus face/hands/boots.
- Full-cycle Walk and Run videos and upright interaction/reach deformation.
- Fresh GLB import with valid materials, rig and action names.
- Native Godot camera capture, controls, collisions and exported runtime checks.

Status: detailed cartoon GLB integrated into the production player. Native
grounding, phase transfer, footsteps, turns, collisions and packaged macOS round
checks pass. Source Walk/turn movies and a packaged task capture were reviewed.
Final controller playtesting, Windows build verification and broader site polish
continue.
The earlier MPFB human and its contact measurements are historical production
work. The shipped model now follows this cartoon contract.

## Equipment refinement, 2026-10-06

Original stylized equipment follows the existing compact body: a fitted leather
waist belt, tapered open pouch with gussets/flap/rivets/stitching, a short secured
mallet and a yellow tape-measure case. Equipment stays behind the sleeves, follows
the pelvis rigidly, and keeps the 1.620 m body/helmet silhouette and sole geometry.
The back receives a garment seam and fitted reflective shoulder strips. Material
budget increases from twelve to thirteen; target stays below 45,000 triangles.
Review front/back/profile neutral, Run and upright reach plus native game camera.

## Tailored trousers, 2026-10-06

Added tapered reinforcement panels at the knees and outer trouser seams following the garment surface. Seven-row panels preserve their shape across the knee bend; the initial coarse grid pinched during Run and was refined before integration. Fresh GLB: 44,424 triangles, thirteen materials, fifteen bones and nine actions; zero inspection issues. Neutral, Run and upright reach multiviews were opened, plus the native Forward+ front capture. Foot contact and phase-transfer gates retain their previous tolerances. Final 151-frame controller-turn and 241-frame Walk movies at 60 FPS complete successfully; chronological sheets were opened. Human movement acceptance and tight-turn planted-foot polish remain open.

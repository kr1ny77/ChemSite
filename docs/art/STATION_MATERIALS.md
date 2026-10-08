# Station material refinement — 2026-10-08

Scope: eleven accepted authored chemistry stations. Preserve names, hierarchy,
scale, colors, mesh topology, transforms, UVs and gameplay collision footprints.
Shared Blender profile definitions distinguish dielectric powder coat, rubber,
ceramics, opaque stylized vessels and mineral samples from bare metallic platens,
zinc, copper and steel. Each source builder consumes the same profile helper.
Editable sources are refined by tools/blender/refine_station_materials.py.

Frozen baseline: artifacts/station-materials-frozen, with eleven source files and
GLBs, material inventory and twenty-two matching native camera captures.
Critic ledger: approved shapes/contacts/palette pass in the fixed views; coating
and bare-metal distinction requires refinement. First revised metal rendering
failed readability because the environment supplied no sky reflections. A static
128-pixel procedural radiance sky resolves that defect while the existing direct
sun, ambient color and background remain configured independently.
Final review: eleven matching before/after sheets, two angles each, opened in
Forward+. Platens and electrodes retain readable highlights; mineral samples use
roughness .84–.93, rubber .88, powder coat .62. Bare metals use metallic 1;
coatings and nonmetals use 0. Vessels retain opaque stylized presentation.
Three representative fresh Blender inspections pass without reported issues:
materials station 7,684, electrochemistry 7,364, corrosion rig 6,112 triangles.
All eleven GLB binary geometry chunks and nodes/meshes/accessors/buffer views/
animations/skins/scenes match their frozen baseline byte-for-byte or structurally.
Compatibility material captures also pass the metal readability check; its
brighter lighting remains a separate platform presentation limitation.

M4 native 1440×900 final-stage profile: exploration median 142 FPS, p90 frame
7.42 ms, 815 draw calls, 71.5 MB static memory; task median 144 FPS, p90 7.47 ms,
898 draws, 72 MB. This is local hardware evidence. Student-laptop verification
remains open.

Related QA findings: the Windows thermal archive showed a clipped scale disclaimer.
The shorter complete caption passes all 72 comparison size/motion/reveal cases,
and its 1028×642 native screenshot was inspected. The 82bf816 Windows native and
visual runs pass; both 191-image archives have verified digests/dimensions.
Sixteen fb0d62c round sheets and three full-size thermal diagrams were inspected.
The 82bf816 result panels were inspected; their absent rewards exposed a release
serialization defect: PackedStringArray captions became empty in the PCK. Typed
Array[String] preserves all six captions. Source five-level rounds and packaged
Level 5/Level 1 reward panels now pass explicit label/stage/save-hash gates.

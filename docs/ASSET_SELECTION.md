# Native asset selection

The Godot vertical slice starts from the CC0 Kenney Factory Kit 3.0 and Building Kit 1.0 used by the browser prototype. The selected 18 GLBs total about 353 kB before Git LFS storage. Blender sources generate the human player and station GLBs.

| Source pack/file | Native destination | Purpose | Planned treatment |
| --- | --- | --- | --- |
| Kenney Factory Kit: `crane`, `machine`, `hopper-high-round`, `pipe-large-long`, `catwalk-straight` | `assets/models/construction/` | Site landmarks and machinery | Scale, material, collision and composition review |
| Kenney Factory Kit: `screen-wide`, `scanner-high`, `lever-double` | `assets/models/construction/` | Chemistry station foundation | Rebuild distinctive station assemblies in Blender |
| Kenney Factory Kit: `cone`, `warning-orange`, `box-large`, `box-small` | `assets/models/construction/` | Safety and storage dressing | Batch or instance repeated props |
| Kenney Factory Kit: `structure-yellow-tall`, `structure-yellow-medium` | `assets/models/construction/` | Structural accents | Integrate with modular build area |
| Kenney Building Kit: `column-wide`, `wall-half`, `stairs-open-short`, `wall-window-wide-square-detailed` | `assets/models/construction/` | Unfinished shell | Material and collision proxy pass |
| MakeHuman CC0 assets and project-authored `tools/blender/build_realistic_chemist.py` | `assets/models/character/chemist.glb` | Human player and nine actions | 53-bone rig, multiview and locomotion review complete; clothing detail and foot contact polish remain |
| Project-authored `tools/blender/build_stations.py` | `assets/models/stations/` | Storage, formula board and periodic terminal | Six-view silhouette review complete; material, lighting and VFX refinement remains |
| Project-authored `tools/blender/build_site_cabin.py` | `assets/models/environment/site_cabin.glb` | Rear laboratory landmark and active-site story | Final sign treatment and lighting review |
| Project-authored `tools/blender/build_material_cache.py` | `assets/models/environment/material_cache.glb` | Palletized cement and brick storage | Eight material-grouped meshes; route and collision review complete |
| Project-authored `tools/blender/build_safety_point.py` | `assets/models/environment/safety_point.glb` | Freestanding first-aid and eyewash landmark | Six material-grouped meshes; pictogram and collision review complete |
| Project-authored `tools/blender/build_site_mixer.py` | `assets/models/environment/site_mixer.glb` | Right-side construction machinery landmark | Six material-grouped meshes; drum, frame and collision review complete |
| Project-authored `tools/blender/build_rebar_bay.py` | `assets/models/environment/rebar_bay.glb` | Left build-pad reinforcement and formwork | Five material-grouped meshes; cage silhouette and collision review complete |
| Project-authored `tools/blender/build_site_fence.py` | `assets/models/environment/site_fence.glb` | Repeatable temporary construction boundary | Five material-grouped meshes; fresh-import, four-view, route and four-side collision review complete |

The browser's merged GLB libraries remain in `legacy-web/public/assets/models/` for reference. The source packs remain under `assets-source/` and are excluded from Godot import with `.gdignore`.

Standardized six-view reviews are saved at `docs/screenshots/site-cabin-contact-sheet.png`, `docs/screenshots/material-cache-contact-sheet.png`, `docs/screenshots/safety-point-contact-sheet.png`, `docs/screenshots/site-mixer-contact-sheet.png` and `docs/screenshots/rebar-bay-contact-sheet.png`.
The fence asset and enclosed yard are shown at `docs/screenshots/site-fence-contact-sheet.png` and `docs/screenshots/site-fenced-yard.png`.

The human worker's updated four-view review is saved at `docs/screenshots/chemist-human-contact-sheet.png`; its isometric locomotion capture is `docs/screenshots/chemist-human-gameplay.png`. Earlier character and station reviews remain at `docs/screenshots/chemist-contact-sheet.png`, `docs/screenshots/chemist-celebrate-frames.png`, `docs/screenshots/chemist-celebrate-godot.png`, `docs/screenshots/substance-storage-contact-sheet.png`, `docs/screenshots/formula-board-contact-sheet.png` and `docs/screenshots/periodic-terminal-contact-sheet.png`.

Additional action contact sheets cover Walk, Turn, PickUp and UseStation under `docs/screenshots/chemist-*-frames.png`.

The fitted coverall detail pass is reviewed in `docs/screenshots/chemist-workwear-contact-sheet.png`, `chemist-workwear-walk.png` and `chemist-workwear-gameplay.png`. Reflective layers follow garment geometry and share its bone weights; 11 final meshes keep the tape batched by material.

## Earned shell expansion — construction_stages

Original ChemSite Blender asset extends the accepted construction_shell source.
Contract: preserve the six-column concrete grid and ground station approaches;
add bevelled slab sections, staggered warm masonry, recessed mortar, fitted ivory
window jambs/sills/mullions, opaque blue glazing and a supported teal seam roof.
Upper teaching section stays open on its front/east side for gameplay readability.
Editable source: tools/blender/source/construction_stages.blend; rebuild script:
tools/blender/build_construction_stages.py. Six named stage roots and two temporary
subgroups provide deterministic rendering. Export batches by owning stage/material.
Inspection: 32,440 triangles, 28 mesh objects, eleven materials, UVs on every mesh;
zero invalid vertices, degenerate faces, missing material faces or reported issues.
GLB split-normal boundary counts represent export seams, not a watertight claim.
Six Blender asset views and twelve native stage/yard views captured; native close
contact sheet inspected with actual retired formwork/rail visibility. Native reward,
collision, saved progress and final-stage Level 5 routes pass. Broader performance
on a representative student laptop remains a release gate.

# Native asset selection

The Godot vertical slice starts from the CC0 Kenney Factory Kit 3.0 and Building Kit 1.0 used by the browser prototype. The selected 18 GLBs total about 353 kB before Git LFS storage. Blender sources generate the original rigged player and three station GLBs.

| Source pack/file | Native destination | Purpose | Planned treatment |
| --- | --- | --- | --- |
| Kenney Factory Kit: `crane`, `machine`, `hopper-high-round`, `pipe-large-long`, `catwalk-straight` | `assets/models/construction/` | Site landmarks and machinery | Scale, material, collision and composition review |
| Kenney Factory Kit: `screen-wide`, `scanner-high`, `lever-double` | `assets/models/construction/` | Chemistry station foundation | Rebuild distinctive station assemblies in Blender |
| Kenney Factory Kit: `cone`, `warning-orange`, `box-large`, `box-small` | `assets/models/construction/` | Safety and storage dressing | Batch or instance repeated props |
| Kenney Factory Kit: `structure-yellow-tall`, `structure-yellow-medium` | `assets/models/construction/` | Structural accents | Integrate with modular build area |
| Kenney Building Kit: `column-wide`, `wall-half`, `stairs-open-short`, `wall-window-wide-square-detailed` | `assets/models/construction/` | Unfinished shell | Material and collision proxy pass |
| Project-authored `tools/blender/build_chemist.py` | `assets/models/character/chemist.glb` | Rigged player and nine actions | Multiview deformation and timing review |
| Project-authored `tools/blender/build_stations.py` | `assets/models/stations/` | Storage, formula board and periodic terminal | Material, lighting and VFX refinement |
| Project-authored `tools/blender/build_site_cabin.py` | `assets/models/environment/site_cabin.glb` | Rear laboratory landmark and active-site story | Final sign treatment and lighting review |

The browser's merged GLB libraries remain in `legacy-web/public/assets/models/` for reference. The source packs remain under `assets-source/` and are excluded from Godot import with `.gdignore`.

The site cabin's standardized six-view review is saved at `docs/screenshots/site-cabin-contact-sheet.png`.

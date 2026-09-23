# ChemSite Asset Licenses

## Runtime external assets

| Asset | Source and author | License | Original location | Project path | Modifications |
| --- | --- | --- | --- | --- | --- |
| Factory machinery, crane, pipes, catwalk, barriers, consoles, and safety props | Factory Kit 3.0, Kenney | CC0 1.0 | `assets-source/kenney/kenney_factory-kit_3.0/Models/GLB format/` | `public/assets/models/industrial-kit.glb` | Selected scenes merged; shared data deduplicated; unreferenced data pruned |
| Structural walls, columns, stair, pipe detail, and barricade | Building Kit 1.0, Kenney | CC0 1.0 | `assets-source/kenney/kenney_building-kit/Models/GLB format/` | `public/assets/models/industrial-kit.glb` | Selected scenes merged with the factory subset; shared data deduplicated; unreferenced data pruned |
| Pallet, timber, bricks, iron bars, barrels, and textile stacks | KayKit Resource Bits 1.0 Free, Kay Lousberg | CC0 1.0 | `assets-source/KayKit/KayKit_ResourceBits_1.0_FREE/Assets/gltf/` | `public/assets/models/site-materials.glb` | Selected scenes packaged as one GLB; shared data deduplicated; unreferenced data pruned; atlas resized to 512 px |

Local license evidence:

- `assets-source/kenney/kenney_factory-kit_3.0/License.txt`
- `assets-source/kenney/kenney_building-kit/License.txt`
- `assets-source/KayKit/KayKit_ResourceBits_1.0_FREE/License.txt`

Original ChemSite procedural geometry, materials, UI, animation, and effects are project-authored.

The original neighborhood model (`public/assets/models/neighborhood.glb`) is generated from project-authored geometry by `scripts/build-neighborhood.mjs`; its buildings, trees and planters contain no external model assets. Facade micro-normal/roughness maps reuse the documented CC0 concrete surface.

## Surface upgrade — 2026-09-23

- `concrete_wall_009` and `metal_plate`: supplied Poly Haven source textures in `assets-source/Poly Haven/`.
- License: CC0, verified against https://polyhaven.com/license on 2026-09-22.
- Runtime maps: `public/assets/textures/`; 1024px WebP base colors and 512px linear PNG normal/roughness maps, approximately 1.63 MiB total.
- Rebuild: `node scripts/prepare-surfaces.mjs`. EXR data maps are converted without applying an sRGB transfer curve; OpenGL normal orientation is retained.
- Paving maps and geometry details are original project-authored work.
# Original ChemSite music

Four original instrumental arrangements are synthesized by `scripts/render-lofi.mjs`: Утренний бетон (72 BPM), Тёплый чертёж (68 BPM), Тихая смена (76 BPM), Огни лаборатории (70 BPM). No third-party recordings or samples are used. Local MP3 files total approximately 5.1 MB and 7 minutes 22 seconds; regenerate with `node scripts/render-lofi.mjs` (FFmpeg required).

# ChemSite Asset Selection

## Detailed neighborhood — 2026-09-23

`scripts/build-neighborhood.mjs` authors six beveled facades, window frames, sills, parapets, roof equipment, six tree planters and shrubs. Geometry is batched into eleven materials, welded, deduplicated, pruned and Meshopt-compressed to `public/assets/models/neighborhood.glb` (approximately 1.3 MiB). Drei uses its bundled Meshopt decoder. Decorative geometry stays outside the playable perimeter; established player collision proxies are unchanged. Flags and subtle foliage wind are runtime visual animation, respecting pause and reduced motion.

High quality uses 1.5–2× pixel density, SMAA postprocessing and 4096px sun shadows; the lightweight preset uses 1–1.35× and 2048px shadows. SMAA replaced four-sample MSAA after an isolated 1440×900 Chrome comparison improved average frame cadence from 35.6 ms to 28.1 ms on this host. The lightweight preset remains available for smoother rendering on slower GPUs.

The runtime art direction uses one dark-steel/orange Kenney industrial family, one neutral Kenney structural family, and one warm KayKit material-storage family. All selected source packs include local CC0 license files.

| Source pack | Source files | Usage | Runtime destination | Production treatment |
| --- | --- | --- | --- | --- |
| Kenney Factory Kit 3.0 | `crane`, `crane-lift`, `structure-yellow-tall`, `structure-yellow-medium`, `machine`, `hopper-high-round`, `pipe-large-long`, `pipe-large-bend`, `pipe-large-valve`, `pipe-glass-large-long`, `pipe-glass-large-bend`, `conveyor-long`, `catwalk-straight`, `catwalk-stairs`, `warning-traffic`, `cone`, `screen-wide`, `scanner-high`, `lever-double`, `box-large`, `box-small` GLBs | Crane landmark, machinery yard, pipes, catwalk, safety dressing, and instrument silhouettes | `public/assets/models/industrial-kit.glb` | Merge into a multi-scene GLB; deduplicate shared buffers, materials, and atlas; prune unused data; preserve authored material atlas |
| Kenney Building Kit 1.0 | `column-wide`, `wall-half`, `wall-window-wide-square-detailed`, `stairs-open-short`, `detail-pipe`, `barricade-window-b`, `floor-corner-round` GLBs | Unfinished shell, columns, temporary wall fragments, and background structure | `public/assets/models/industrial-kit.glb` | Merge with the industrial set; deduplicate and prune; preserve neutral structural material |
| KayKit Resource Bits 1.0 Free | `Pallet_Wood`, `Wood_Planks_Stack_Large`, `Stone_Bricks_Stack_Large`, `Iron_Bars_Stack_Large`, `Fuel_A_Barrels`, `Textiles_Stack_Large` glTF scenes | Material-storage cluster, rebar, timber, masonry, drums, and bagged material | `public/assets/models/site-materials.glb` | Package as GLB; deduplicate and prune; resize the shared atlas to 512 px; keep original stylized color blocking |

The surface upgrade uses the supplied Poly Haven concrete and steel maps, alongside the original atlas textures and deterministic paving maps.

## Material and collision pass

- Concrete receives shared base-color, normal and roughness maps; steel worktops receive micro-normal and roughness maps with environment reflections.
- Material instances are cloned from the GLB cache and reused within each asset, so surface adjustments preserve shared source materials.
- Imported static props receive bounds-based cuboid collision proxies in their local transforms; station proxies share the visible station rotation. The animated crane hook is visual-only outside the playable perimeter.
- Laboratory cabin collisions match its body. Thin floor slabs use bevel radii below half their thickness; the main floor collider matches the visible top surface.
- A generated room environment supplies local reflections without external HDR downloads. ACES output tone mapping follows the postprocessing chain; two-sample anti-aliasing softens edges.
- Camera composition and restrained HUD remain intact. Added drainage grates, expansion joints, safety markings, curb stones, cabin ribs and windowed background buildings clarify scale.

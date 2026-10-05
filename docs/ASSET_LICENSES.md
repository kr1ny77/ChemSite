# Native asset licenses

| Asset | Author and source | License | Original path | Native destination | Modification |
| --- | --- | --- | --- | --- | --- |
| Selected machinery, station bases and props | Kenney, Factory Kit 3.0 | CC0 1.0 | `assets-source/kenney/kenney_factory-kit_3.0/Models/GLB format/` | `assets/models/construction/` | Selected GLBs copied; runtime material overrides |
| Selected structural models | Kenney, Building Kit 1.0 | CC0 1.0 | `assets-source/kenney/kenney_building-kit/Models/GLB format/` | `assets/models/construction/` | Selected GLBs copied; runtime material overrides |
| Construction chemist | MakeHuman Community system assets plus ChemSite authored hardhat and animation | MakeHuman graphical assets CC0; original authored additions | `tools/blender/build_realistic_chemist.py`; `tools/blender/source/realistic_chemist.blend` | `assets/models/character/chemist.glb` | Blender 5.2.2 export; asset provenance and SHA-256 in `tools/blender/character_reference_notes.md` |
| Three chemistry stations | ChemSite project-authored Blender script | Original project assets | `tools/blender/build_stations.py` | `assets/models/stations/` | Blender 5.2.2 export |
| Site laboratory cabin | ChemSite project-authored Blender script | Original project asset | `tools/blender/build_site_cabin.py` | `assets/models/environment/site_cabin.glb` | Blender 5.2.2 export |
| Cement and brick material cache | ChemSite project-authored Blender script | Original project asset | `tools/blender/build_material_cache.py` | `assets/models/environment/material_cache.glb` | Blender 5.2.2 export |
| First-aid and eyewash safety point | ChemSite project-authored Blender script | Original project asset | `tools/blender/build_safety_point.py` | `assets/models/environment/safety_point.glb` | Blender 5.2.2 export |
| Portable site mixer | ChemSite project-authored Blender script | Original project asset | `tools/blender/build_site_mixer.py` | `assets/models/environment/site_mixer.glb` | Blender 5.2.2 export |
| Rebar and formwork bay | ChemSite project-authored Blender script | Original project asset | `tools/blender/build_rebar_bay.py` | `assets/models/environment/rebar_bay.glb` | Blender 5.2.2 export |
| Temporary construction fence | ChemSite project-authored Blender script | Original project asset | `tools/blender/build_site_fence.py` | `assets/models/environment/site_fence.glb` | Blender 5.2.2 export; visual dimensions informed by temporary panel reference linked in script |
| Menu illustration | ChemSite project-authored SVG | Original project asset | `assets/ui/menu_illustration.svg` | `assets/ui/menu_illustration.svg` | Native Godot UI |
| Music track | ChemSite browser prototype source | Existing project asset | `legacy-web/public/assets/audio/lofi-1.mp3` | `assets/audio/lofi-1.mp3` | Copied for native use |
| Interaction and answer cues | ChemSite project-authored synthesis | Original project assets | `tools/audio/render_cues.py` | `assets/audio/*.wav` | Generated WAV files |

Local license files: `assets-source/kenney/kenney_factory-kit_3.0/License.txt` and `assets-source/kenney/kenney_building-kit/License.txt`. The browser asset manifest remains in `legacy-web/` documentation history and Git history.

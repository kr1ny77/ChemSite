# Character sleeve deformation review — 2026-10-10

## Finding and repair

Fresh-import Blender Celebrate at normalized phase 0.8 showed long blue fabric
wedges from raised cuffs to the waist. A source weight audit found 153 vertices
in the lower cuff region (`abs(x) > .285`, `.43 < z < .48`) assigned to pelvis,
thigh or calf groups. The generic height-based trouser branch ran before sleeve
classification. Sleeve classification now runs first. The existing authored
source was repaired in place through a separately reviewed candidate; geometry,
materials, skeleton and action data were preserved.

`tools/blender/repair_cartoon_sleeve_weights.py` writes a candidate from the
current source. `tools/blender/build_cartoon_chemist.py` contains the corrected
classification for full regeneration. Hand-level bones and stylized mitt hands
remain the character contract; individual finger controls are outside this rig.

## Evidence inspected

Blender Agent Studio fresh-import inspection and standardized neutral six-view
render of the original production GLB, followed by front/profile/perspective
Run (0.65), Interact (0.5) and Celebrate (0.8) before and after repair.
The repaired Celebrate views show the cuff following the arm and the long
waist-connected wedges removed. Run and upright reach preserve their silhouette.
Final native Forward+ front/profile captures of all three actions were opened
in `docs/screenshots/sleeve-deformation-repaired.jpg`; rendered size is 1027×642.

Detailed inspection/render artifacts: `artifacts/cartoon-final-validation/`
and `artifacts/cartoon-sleeve-repair/`. Initial pose previews with a default
Blender cube were rejected; the `*-final` original views and repaired
`*-review` views use clean imports.

## Technical verification

Fresh original/repaired exports have identical inspection totals and action
records: 44,424 triangles, 86 weighted meshes, 13 materials, 15 bones, nine
named actions. Both have zero invalid/isolated vertices, zero degenerate faces,
zero-length/wire edges and missing material faces. Open edges reflect layered
surfaces and export splits; these metrics provide structural evidence.

Godot editor import/parse, native deformation capture, sole grounding/stance,
Walk/Run phase transitions, contact timing and locomotion contact diagnostics
passed. Sole errors remain below 0.2 mm; steady Walk/Run drift remains below
0.9 mm. Full-cycle cloth review, human movement feel and revised packaged
macOS/Windows verification remain open. The previous b583a3e patch archives
are superseded by this character repair before publication.

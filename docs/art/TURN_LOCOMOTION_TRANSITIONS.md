# Turn / locomotion transition investigation

Status: dedicated motion root verified in an isolated prototype; transition
contact fails acceptance. Production player and released 0.1.3 remain at their
verified source.

## Rig contract

`author_cartoon_turn.py -- --dedicated-root` creates the separate output directory
`artifacts/cartoon-turn-root-candidate/`. A non-deforming `motion_root` sits above
pelvis. Horizontal displacement and yaw belong to this bone; pelvis retains
vertical gait motion. Original actions explicitly key identity motion-root channels.
The root bone points along Blender Z, giving an identity rest orientation in Godot.
A first Blender-Y-axis candidate passed offline pose preservation but rotated the
native capsule about an incorrect axis: support drift 37.101 mm and height error
380.886 mm. The physical gate rejected it; the axis was repaired in durable source.

Fresh original/candidate GLB comparison checks every vertex coordinate, skin
weight and material slot, plus 33 world-bone poses for all 11 actions. Vertex
coordinates, skin weights and slots match exactly in the retained export; maximum
world-bone matrix element difference is 4.58396971e-06. Action frame ranges match.
BAS independently inspects source and GLB: 44,424 triangles, 16 bones,
13 materials, 11 actions, zero reported issues.

## Native prototype

The existing capsule/root-motion gate supports `--dedicated-root` and passes all
27 cases at 30/60/120 Hz: two headings, both turns, wall, pause/resume and three
interruption phases. New turn-only frames from two cameras (28) were opened.

The driver adds looped Walk/Run states, TimeSeek before TimeScale and an 80 ms
crossfade. Gaits use their production nominal speeds/cadences. The turn root is
extracted; handoff freezes accumulated heading/position and begins constant-speed
capsule travel. This diagnostic intentionally isolates animation blending from
production velocity smoothing, input, camera and foot planting.

## Transition audit

`turn_locomotion_transition_audit.gd` covers both turns, four release phases
(20%, 55%, 90%, 100%), Walk/Run and 30/60/120 Hz: 48 cases. It checks physical
travel, frozen heading and destination state; it records sole-point heights and
speed through 0.4 seconds after handoff. The selected point is the lowest bind-pose
vertex per sole. Penetration is a lower bound; whole-foot review remains required.

| Candidate | Cases over 3 mm penetration | Maximum measured penetration |
| --- | ---: | ---: |
| Default gait entry, production loop modes | 24 / 48 | 13.728 mm |
| Contact-phase matching experiment | 32 / 48 | 20.270 mm |

The optional `--match-contact-phase` experiment seeks phase 0.25/0.75 according to
the turn's support foot. It worsens the contact evidence and is disabled by default.
The preceding nonlooping diagnostic is preserved as `unmatched_phase_transition_audit.json`;
the production-loop control reproduces its peak. Neither contact result qualifies
for production. The native run handoff (20 frames) and rejected matched Walk
handoff (20 frames) were opened; floor penetration stays a numerical defect even
where small screen scale makes it hard to judge visually.

## Next validation

Measure all sole vertices and tag peak time/fading state to locate deformation
inside the blend. Repair contact while retaining leg lengths, gait vertical motion
and responsive controls. Compare production corner/reversal results at all three
physics rates, review continuous motion and native gameplay, then refresh exports.
The source/asset hashes, raw cases and explicit scopes are recorded in
`docs/release/turn-locomotion-transition-audit.json`.

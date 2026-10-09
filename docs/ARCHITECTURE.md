# Native ChemSite architecture

Godot 4.7 Forward+ is the production runtime. `Main` owns scene transitions; the active `ConstructionSite` owns the round, player, station proximity, task state, and HUD. `Player` is a CharacterBody3D with semantic InputMap actions. `GameHud` is a Control scene that emits answer, resume and exit signals. The native bank loads 40 verified tasks per level from `data/chemistry/curated_tasks.json`. Level 5 routes material, formula and oxidation tasks to its Blender-authored specimen tester, equation tasks to the reaction bench, and corrosion/inspection tasks to their established stations. Levels 2–4 use their own station sets and reuse compatible props. The original TypeScript bank remains in `legacy-web/src/chemistry/tasks/` and can be re-exported with `tools/chemistry/export_legacy_tasks.mjs`.

Optional site observations load through `scripts/world/site_inspections.gd` from `data/chemistry/site_inspections.json`. `ConstructionSite` selects the nearest interaction point; `GameHud` displays an unscored observation panel. This path does not alter task selection, chemistry validation or save data.

Career selects verified tasks deterministically through `task_scheduler.gd`, favoring weaker topics while alternating stations. A wrong answer records a mistake, advances to a different task, and moves a related verified task two questions later when possible. Completing five tasks in a career level unlocks the next level, through Level 5. Older saves with earned stars migrate to the Level 2 unlock. Practice filters the selected level (1–5) by topic, runs without a timer and leaves career progress unchanged. `save_data.gd` stores versioned best score, stars, XP, completed rounds, level-scoped topic mastery, mistakes, per-level best score/stars/XP/round counts and unlocked level in `user://progress.json`, migrating version-1 through version-4 saves. Legacy global records remain intact; per-level records begin with each subsequent career round. The packaged app has isolated five-task QA entry paths for Levels 1–5, with rendered Windows captures for all five levels. Chemistry validation, station behavior, audio and progression remain separate systems as content scales.

The browser architecture that preceded this migration is preserved by Git history and `legacy-web/`.

Player geometry uses a 5 mm cartoon-model offset to align the imported bind sole with the capsule lower tip. The foundation physical plane is y=0; visual path overlays sit 1–3 mm above it. Walk vertical support is baked in Blender; `tools/validation/player_grounding_smoke.gd` evaluates imported skinned shoe vertices against a physics floor ray.

Walk and Run retain normalized gait phase when switching via a TimeSeek inside each state, before TimeScale. Footstep signals cross quarter/three-quarter contact phases from the active AnimationTree state and are suppressed when stationary, airborne or controls are disabled. Animation timing belongs to Player; the signal keeps audio playback in the existing audio system. Native transition and footstep gates cover phase transport and contact event timing.

Player heading uses a critically damped angular response after collision resolution. A 720°/s limit bounds per-frame rotation; angular velocity resets when movement settles. `turn_response_smoke.gd` checks reversal, corner response and fixed-target settling at three frame rates.

## Player visibility through construction frames

`CameraRig/PlayerVisibility` owns render-only obstruction feedback. Tall static
construction-shell, cabin, rebar and station meshes join `player_camera_occluder` during
world assembly. Nine orthographic camera segments sample the player's torso and
head width against each mesh's local bounds, retaining rotated/scaled mesh space.
Intersecting parts ease to 82% transparency; clear parts restore full opacity.
Reduced motion switches directly. Physics, station selection, chemistry and
player materials retain their independent ownership.

The production Forward+ renderer supports GeometryInstance3D transparency.
Compatibility CI tests the logic/property transitions; its graphical renderer
ignores this property. Physical Windows Forward+ visual acceptance remains open.
Engine contract: https://docs.godotengine.org/en/stable/classes/class_geometryinstance3d.html#class-geometryinstance3d-property-transparency.

## Movement response and station navigation

Player horizontal velocity uses an exact critically damped response with separate
acceleration/braking frequencies (18/24 s⁻¹). The velocity derivative carries between
physics frames; collision-blocked components reset to prevent retained spring energy.
Settled release snaps below 0.01 m/s to zero. Animation and footsteps continue to
follow collision-resolved speed and phase; yaw has the existing bounded response.

`StationWayfinder` owns navigation rendering separately from chemistry and physics.
ConstructionSite supplies the current curated task's station and active controls
state. One unshaded ground outline and a projected native Control arrow mark the
target. Its CanvasLayer stays behind the modal HUD; the arrow ignores mouse input.
Panels/pause/results hide both visuals. Reduced motion retains a static arrow.
The target refreshes when the task advances and covers all five career levels.
Targets outside the usable world viewport use a rotated screen-edge arrow whose
heading follows the projected station position. Visible targets retain the
downward marker. The edge inset reserves space for the top HUD and bottom
interaction prompt, including rotated corners. Reduced motion keeps edge
indicators static. The wayfinder gate covers 2,000 camera/target/motion cases.

### pH measurement feedback

`ph_terminal_view.gd` reveals measured sample cards after the existing read action.
`ph_scale_view.gd` draws a native Control scale and places its marker directly from
the curated reading. Its brief highlight settles after 0.35 seconds; reduced motion
uses a static marker. The card retains the exact numeric reading as primary evidence.
The illustrative 0–14 scale clamps marker placement only; task values and validation
remain unchanged. `ph_scale_smoke.gd` covers all four pH tasks at three window sizes
in normal and reduced-motion modes.

### Desktop focus and pause

ConstructionSite listens to Window.focus_exited after HUD initialization. During
active exploration it opens the existing pause UI, disables player controls and
hides the target pointer. Existing task, feedback and result panels retain their
state. The timer stays frozen while controls are disabled; the player clears
horizontal velocity and its acceleration derivative at the next physics tick.
Window focus return leaves the pause visible until the player resumes.
The engine signal contract is documented at
https://docs.godotengine.org/en/stable/classes/class_window.html#class-window-signal-focus-exited.

### Native answer field theme

`assets/ui/hud_theme.tres` supplies the HUD's Onest font, shared light LineEdit
normal/read-only surfaces, dark text/placeholder/caret, selection colors and a
three-pixel keyboard focus outline for inputs and all inherited Buttons.
GameHud retains local semantic button backgrounds and input font sizes. Answer
parsing, observation gates and keyboard event handling remain in their existing
systems. Native 1027×642 captures cover empty/entered inputs and locked numeric
entry; the 200-task/400-feedback layout gate passes at 1028×642.

### Comparison observation diagrams

`ComparisonObservationView` renders curated visual metadata after each
`ExperimentComparisonView` probe is inspected. Observation state gates the two
halves separately; answer unlocking still requires both existing text readouts.
A finite eased process updates visible diagrams for 1.2 seconds, then disables
processing. Reduced motion skips the animation. All chemistry captions and
visual kinds come from the task bank; UI rendering owns geometry and timing.
QA captures explicitly redraw through main-thread `RenderingServer.force_draw`
before reading the viewport. This avoids an unbounded post-draw signal wait in
static reduced-motion scenes. Exported visual QA now captures settled observation
states before submission, preserving task/feedback/result evidence.

### Authored environment motion

`SiteMixerMotion` drives the imported `DrumRotate` AnimationPlayer clip. The GLB
contains a fixed tilted axis parent and a local rotor; source material batches
retain that ownership. Collision remains in the world’s fixed proxy. The world
supplies active exploration state, pausing animation and spatial machinery audio
during panels, pause and results. Reduced motion keeps the initial rotor pose.
An explicit `_ready` gate on comparison diagrams also preserves their inactive
process state when Godot enables overridden callbacks during tree entry.

## Earned construction rendering

`construction_progress.gd` derives stages zero through five from consecutive
career level records with earned stars. The version-five save format is retained;
legacy global stars apply only to an empty level-record map. The static Resource
`data/progression/construction_stages.tres` holds model path and stage captions.
`construction_stage_view.gd` controls GLB Stage0–Stage5 groups and retires temporary
formwork/rails. The world reloads the stage only after successful career save.
Practice displays the current stage and preserves its saved records. Results show
the newly earned stage. Future geometry remains hidden and skipped by visibility
queries; added walls/roof occupy the inaccessible upper floor.

Construction titles use typed Array[String]. The native release PCK converted the
previous PackedStringArray property to an empty array. Packaged round checks now
validate six nonempty titles, initial/earned stages, visible reward text and the
unchanged normal-user save hash. QA supplies its save path before scene tree
entry and seeds consecutive prior levels through the existing save service.

Player AnimationTree uses the physics callback to match controller displacement.
`docs/LOCOMOTION_CONTACT_QA.md` records actual skinned-sole diagnostics and the
remaining reversal-contact issue.

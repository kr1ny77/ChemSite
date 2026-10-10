# Locomotion contact QA

## Physics clock repair — 2026-10-08

The production AnimationTree now processes during physics ticks, matching
CharacterBody3D displacement and collision resolution. Previously its default
idle clock could advance a different interval between two physics samples.
This change retains authored assets, controller response and phase transport.
Godot API contract: https://docs.godotengine.org/en/4.4/classes/class_animationmixer.html#enum-animationmixer-animationcallbackmodeprocess.

`tools/validation/measure_locomotion_contact.gd` samples actual imported skinned
sole vertices while the controller and AnimationTree run. Four sequences cover
straight Run, a 90-degree corner, a 180-degree reversal, and Walk start/stop.
The steady window precedes the direction change after startup crossfades settle.
Consecutive physics ticks are required; skipped pairs are counted separately.
The gate requires both soles, at least five steady support samples (three at
30 Hz, where a Run contact lasts only 1–2 ticks), and less than 1 mm motion per
tick in every sequence. Corner/reversal drift is reported separately and
remains a production issue, rather than inheriting the steady-travel gate.

Run with `-- --physics-hz=30`, `60` or `120`. `-- --idle-animation` reproduces the
old clock for comparison without changing the production controller. JSON reports
are written to `artifacts/locomotion-contact-{physics,idle}-{hz}.json`.
All twelve physics-clock scenarios pass at 30/60/120 Hz. The 60 Hz idle baseline
showed about 14.6 mm steady Run displacement per sample. Physics-clock samples
remain below 1 mm, with most steady values below 0.1 mm.

The 60 Hz reversal still reaches approximately 113 mm per support sample during
the turn/transition window; the corner reaches approximately 55 mm. A directional
contact/transition refinement and complete human movement acceptance remain open.

Native Forward+ turn captures were reviewed chronologically. The capture harness
now disconnects focus-loss pause only for automated capture, and requires enabled
controls each frame. Desktop focus-loss behavior retains its separate QA gate.
This corrected an earlier capture that silently paused midway through its route.
Editor import/parse, Walk/Run phase transfer, footstep timing and heading response
checks, clean macOS export and packaged five-task round pass. Windows CI now includes the actual moving-sole diagnostic at 60 Hz.


## Reversal transition repair — 2026-10-08

Walk/Run blends now last 80 ms. Phase transfer reads the actual playback state's
clip duration, including a request made during an unfinished preceding blend.
Two new pending-state cases pass; the previous controller fails this regression.
The existing eight transfer cases and contact-aligned footstep gate pass.

The moving-sole harness now uses equal three-second sequences at each physics
frequency and a 0.4–1.2 second steady window. Both soles must be represented.
A separate 60 Hz reversal gate rejects peak support displacement of 95 mm or more.
This catches the former 113 mm regression while full directional planting remains
an open quality requirement. Baseline/candidate JSON comparisons are saved in
`artifacts/reversal-transition-comparison.json`.

| Physics frequency | Baseline reversal peak per tick | Candidate peak per tick |
| --- | ---: | ---: |
| 30 Hz | 261.6 mm | 219.9 mm |
| 60 Hz | 113.2 mm | 85.9 mm |
| 120 Hz | 64.9 mm | 49.2 mm |

Corner support drift is unchanged. Higher turn-contact quality needs a bounded
plant/release treatment with knee and boot deformation review; the short legs
and fast running support interval make unrestricted world-space locking unsuitable.
All twelve steady scenarios pass. Dense native reversal poses (every two frames)
and a full 150-frame turn recording were captured; twenty chronological reversal
poses were reviewed. Fresh import/export and a packaged macOS keyboard round with
five walking station approaches pass. Human movement acceptance remains open.


## Bounded foot planting — 2026-10-08

A physics SkeletonModifier3D corrects horizontal ankle displacement during the
existing authored support interval. Correction is bounded to 65 mm, boot rotation
to 65 degrees, and release blends over 65 ms. The analytic two-bone solve preserves
leg lengths and authored ankle height. Idle crossfades skip correction. Controls,
reactions, airborne movement and inactive AnimationTree release the support.
Release tests first establish a measured active lock above 5 mm.

The diagnostic now caches skinned vertices on Skeleton3D.skeleton_updated, after
all modifiers. It independently checks final evaluated leg lengths. The prior
out-of-callback bone query observes authored poses and cannot validate this pass.
Same-harness disabled-modifier comparisons are in
`artifacts/foot-plant-comparison.json`.

| Physics frequency | Corner before / after | Reversal before / after |
| --- | ---: | ---: |
| 30 Hz | 138.92 / 88.97 mm | 219.91 / 130.31 mm |
| 60 Hz | 54.57 / 32.09 mm | 85.89 / 61.84 mm |
| 120 Hz | 30.38 / 12.89 mm | 49.21 / 21.68 mm |

Values are peak support displacement per physics tick within the turn window;
comparisons apply within each frequency. All twelve steady cases retain the
1 mm/tick gate. Final evaluated length error stays below 0.1 mm. Four active-lock
release cases pass at all three frequencies. Grounding, phase transitions,
footstep timing and focus-pause regressions pass.

Reviewed eighteen chronological main-camera turn poses and eighteen unobscured
side poses. The isolated side capture hides tall yard props for joint inspection.
Evidence: `artifacts/foot-plant-final.mp4`, `foot-plant-review.png`,
`foot-plant-review-side-clear.png`. Native torso remains upright. The initial side
capture was occluded and superseded. Bounded correction retains residual turn
displacement; human movement acceptance remains open.

Clean macOS release export and packaged keyboard round pass: five station routes,
five tasks, 700 points. `KEYBOARD_FOOT_PLANT_OK corrected_ticks=359` confirms the
exported modifier ran and retained all correction, rotation and pose bounds.


## Upright actions and Windows confirmation — 2026-10-08

`capture_upright_actions.gd` captures Interact, PickUp and UseStation in front and
side views, with the tall props hidden and level camera tracking disabled for
inspection. A persistent process callback accepts each physics tick once and
forces a draw before saving; this avoids repeated same-tick coroutine resumes
and stale rendered poses. The six sequences cover 82/82/87 distinct ticks per
view at 60 Hz, including Idle before each action. All pass. Reviewed thirty
chronological poses in `artifacts/upright-actions-review-verified.png`; the
62 PNG sequence is in `artifacts/upright-action-frames-final/`. Upright torso,
stable planted boots and arm gestures are visible. The movie writer recorded
only six main-loop frames despite forced rendering, so its AVI is excluded from
full-duration evidence. Earlier incomplete captures are superseded.

Windows d6a658d native run 37779353465 and visual run 37779353513 succeeded.
Native job 113318216853 confirms all five keyboard rounds and active correction
bounds (387/364/384/372/347 corrections), plus the moving-sole gate. Current
Windows screenshot archive review and physical Windows acceptance remain open.


## Complete current-character gait integration — 2026-10-08

`capture_complete_gaits.gd` drives input through the actual controller and reads
AnimationTree playback phase at distinct physics ticks. Each gait/view must
complete two wraps and capture at least ten of twelve phase bins; all four cases
captured twelve. Walk/Run take 97/49 ticks in the three-quarter view and 103/49 in
the frontal view, including warmup. The camera follows the character; tall props
are hidden for silhouette inspection. All 48 PNG poses in
`artifacts/complete-gait-frames-final/` were reviewed in even/odd phase sheets
`artifacts/complete-gait-review-{0,1}.png`. Upright body carriage, support/swing,
boots and arm counter-swing remain readable. This completes the native integration
review together with the upright station-action pass. Human movement feel and
exported manual acceptance remain separate open requirements.

## Heading response experiment — 2026-10-09

Re-ran the current 60 Hz final-skinned-sole baseline: corner peak 32.09 mm,
reversal 61.84 mm, straight steady 0.071 mm/tick; active-lock release and
leg/ankle bounds pass. Tested angular spring response 22 instead of 16
with the unchanged 720°/s cap. Angular settling passed, but the final sole
contact gate rejected the corner before completing the matrix. Faster
heading response is rejected and the production value 16 is restored.
Evidence: /tmp/chemsite-turn-baseline.log, /tmp/chemsite-turn-baseline.json,
/tmp/chemsite-turn-candidate.log and /tmp/chemsite-turn-response-candidate.log.
This experiment establishes that angular responsiveness alone does not
satisfy tight-turn contact. Next investigation: support anchor/release
behavior with final evaluated sole trajectories and chronological native
turn captures. Exported manual movement acceptance remains open.

## Cross-frequency turn experiments — 2026-10-09

Reducing the boot twist bound to 35° failed the 60 Hz reversal displacement
gate and was reverted. Lowering maximum body turn speed from 720°/s to
540°/s passed heading settling and all current contact gates, but the
frequency matrix exposed regressions; that candidate was also reverted.

| Frequency | Baseline reversal peak | 540°/s candidate |
| --- | ---: | ---: |
| 30 Hz | 130.31 mm | 147.22 mm |
| 60 Hz | 61.84 mm | 44.62 mm |
| 120 Hz | 21.68 mm | 39.45 mm |

Corner peaks were unchanged (88.97/32.09/12.89 mm). All twelve steady cases
and active-lock release/leg-height/length bounds passed. Thirteen
chronological isolated side views of the 540°/s candidate were reviewed;
upright carriage remained readable. Single-frequency improvement is
insufficient for promotion. Production retains response 16, 720°/s,
65° boot bound. Next work requires a support-anchor treatment or authored
directional gait, evaluated at all three frequencies. Human acceptance
remains open. Logs: /tmp/chemsite-turn-twist35.log,
/tmp/chemsite-turn-rate540.log, /tmp/chemsite-turn540-{30,120}.log.

## Sole-centre and reach diagnosis — 2026-10-09

A candidate derived the bottom centre of each rigid sole through its skin
bind pose and compensated the ankle target for bounded boot rotation.
Final-skin tests at 30/60/120 Hz retained corner peaks 88.965/32.090/12.889
mm and reversal peaks 130.307/61.904/21.678 mm. This negligible change
does not establish a quality improvement; the candidate was reverted.
Original gait, controller and planting behavior remain in production.

Added two diagnostic counters to the existing modifier: reach-clamped
solves and maximum horizontal target loss. The 60 Hz full evaluated-pose
gate passes unchanged: straight/start-stop have zero clamped solves;
corner has three with maximum loss 11.43 mm; reversal has two with maximum
loss 22.22 mm. Leg length/ankle height, active release and original drift
gates pass. These counters observe the existing reach projection and
change no pose. Next step: correlate clamped solves with support/contact
phase before choosing an authored directional gait or release treatment.
Evidence: /tmp/chemsite-sole-centre-{30,60,120}.log and
/tmp/chemsite-reach-diagnostic.log.

## Gait-bound support anchor repair — 2026-10-09

Per-sample support phase, correction length and reach loss showed that the
largest 60 Hz reversal jump occurred at the 65 mm correction bound with
zero reach loss. Earlier reach-clamp counts alone did not identify that
peak's cause. A 90 mm candidate failed the 60 Hz corner gate and was
reverted. The useful repair resets support ownership when AnimationTree
changes Walk/Run, recapturing each foot in its new gait interval. Disabled
controls/reactions/airborne/Idle still clear ownership. Bounds remain
65 mm correction, 65° rotation and 65 ms release.

| Frequency | Prior reversal peak | Repaired reversal peak |
| --- | ---: | ---: |
| 30 Hz | 130.31 mm | 66.38 mm |
| 60 Hz | 61.84 mm | 40.35 mm |
| 120 Hz | 21.68 mm | 21.68 mm |

Corner and steady cases remain unchanged. Final length/height, twelve
release cases, phase/pending-transition and contact audio gates pass.
The 60 Hz reversal regression bound is tightened to 50 mm, rejecting the
recorded former 61.84 mm case. Thirteen chronological isolated native
side poses were reviewed; upright carriage and boot deformation remain
readable. Clean export and five-task packaged macOS keyboard round pass.
Human movement acceptance and residual turn displacement remain open.
Evidence: docs/screenshots/gait-anchor-reset-review.jpg;
/tmp/chemsite-gait-anchor-reset.log, /tmp/chemsite-anchor-reset-{30,120}.log,
/tmp/chemsite-anchor-reset-{transitions,steps,package}.log.

## Boot-twist bound diagnosis — 2026-10-10

A temporary 90° boot limit tested whether the 65° rotation bound caused the
remaining 60 Hz turn displacement. The measured maximum actual twist was
59.19°; corner/reversal peaks remained 32.090/40.354 mm, matching the repaired
production results. All contact/release/length/height gates passed. The limit
was inactive in this scenario and the candidate produced no improvement; source
was restored to 65°. Evidence: artifacts/twist90-contact-physics-60.json and
/tmp/chemsite-twist90-contact.log. The largest displacement still requires
correction-bound/support-release diagnosis. User accepted general controls in
the exported five-task macOS round; this focused residual remains tracked.

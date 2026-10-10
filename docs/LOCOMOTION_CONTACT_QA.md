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

## Unbounded support request diagnosis — 2026-10-10

Added a read-only requested-offset value before the existing 65 mm clamp.
The 60 Hz diagnostic retains turn peaks exactly (difference <0.0001 mm). At
the corner peak the anchor requests 103.05 mm correction, with 65 mm applied
and zero reach loss; at reversal it requests 119.81 mm, with 64.99 mm applied
and zero reach loss. Support phases are 0.15159 and 0.12513 respectively. This
locates the peak before leg-reach projection: the body/gait sweep exceeds the
bounded support correction. Further work should address authored directional
contact/body pivot or support transfer while preserving existing leg-length,
height and cross-frequency gates. A larger boot-twist limit does not affect it.
Evidence: artifacts/turn-requested-offset-peaks.json and
/tmp/chemsite-requested-offset-contact.log.

## Slower heading candidate — 2026-10-10

Response 13 tested gentler angular acceleration against production response 16.
At 60 Hz corner peak increased from 32.090 to 35.332 mm; reversal decreased
only from 40.354 to 39.706 mm. The candidate passed existing numeric limits
but degraded corner contact while slowing response. Restored response 16;
cross-frequency/visual promotion gates were skipped after this rejection.
Evidence: artifacts/response13-contact-60.json and
/tmp/chemsite-response13-contact60.log.

## 120 mm correction candidate rejected — 2026-10-10

Raw support-offset requests at 60 Hz reach 103/120 mm, motivating a bounded
120 mm candidate. The existing unchanged corner gate rejected it: peak
displacement increases from 32.090 to 54.766 mm and maximum reach loss becomes
55.802 mm. Maximum requested correction applied was 120 mm. Straight steady
motion remains 0.071 mm/tick. Both production modifier and validator were
restored byte-for-byte. No release assets changed. This identifies leg reach
as the limit of this correction-only approach; the next candidate must modify
authored support transfer/body turn timing. Failed candidate output:
`/tmp/chemsite-correction120-measured.log`.

## Directional gait baseline — 2026-10-10

The fresh production 60 Hz gate passes: corner/reversal peaks remain
32.090403/40.354334 mm. Added read-only `velocity_yaw` and `heading_error`
fields to the validator, preserving the same evaluated poses and thresholds.
At those peaks, velocity leads body heading by 46.600° and 90.632°.
The current sagittal ankle trajectory is aligned with the body while
translation follows this substantially different direction. This supports
a directional-gait candidate: steer stance/swing trajectories toward local
travel direction while retaining body turn damping, authored contact phase,
vertical profiles and existing correction/reach bounds. Counter-steering
should settle to zero during straight travel. Validate all three physics
frequencies, straight negative control, release, two views and normal-speed
turn recording before promotion. Diagnostic: artifacts/turn-direction-baseline.json.

## Directional ankle steering candidates — 2026-10-10

Two presentation-only candidates rotate ankle trajectories about each hip toward
velocity, damped at 24 s⁻¹. Support phases, heights, leg lengths, body/controller
and 65 mm correction bound retain production values. 60° steering at 60 Hz
changes corner/reversal to 26.890/43.777 mm, with 28.848/27.572 mm reach loss;
rejected for reversal regression. The moderated 30° candidate passes all
existing contact/release/length/height gates at three frequencies:

| Hz | Scenario | Fresh baseline mm | 30° candidate mm |
| --- | --- | --- | --- |
| 30 | corner | 88.965 | 50.194 |
| 30 | reversal | 66.380 | 46.486 |
| 60 | corner | 32.090 | 30.048 |
| 60 | reversal | 40.354 | 39.205 |
| 120 | corner | 18.207 | 0.001 |
| 120 | reversal | 27.181 | 34.840 |

The 120 Hz reversal regression rejects promotion despite broad corner gains.
Straight steady motion and start/stop remain unchanged. Production modifier
restored byte-for-byte; published assets unchanged. Fresh 30/120 baselines
and candidate files are in artifacts/directional-gait-*.json; comparison is
artifacts/directional-gait-comparison.json. No visual promotion gate claimed.
Next candidate should steer during swing/transfer and preserve support ownership;
a continuously steered planted leg introduces phase-sensitive reach loss.

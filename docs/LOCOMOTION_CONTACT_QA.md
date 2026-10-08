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

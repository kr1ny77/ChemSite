# Station feedback QA

## Answer-particle fade repair — 2026-10-08

The existing short correct/incorrect burst used a lifetime alpha gradient with
an opaque draw material and disabled vertex color. Enabled vertex color and
alpha transparency, with a white base albedo so the authored gradient supplies
the tint once. Particle count, velocity, lifetime, station pulse and reduced-motion
selection remain as authored.

Godot documents the material requirement in the
[particle process properties](https://github.com/godotengine/godot-docs/blob/master/tutorials/3d/particles/process_material_properties.rst).

Acceptance: both outcome colors appear, progressively fade, and free their nodes;
the opaque previous material provides a comparison. Native Forward+ test
`capture_answer_burst.gd` captures 0.1/0.3/0.5/0.6/1.5 seconds on distinct physics
ticks and rejects surviving effect nodes at 1.5 seconds. Candidate and
`--opaque-baseline` captures both complete. Ten images reviewed in
`artifacts/answer-burst-fade-comparison.png`; the JSON stores image measurements.
Maximum RGB difference from the background drops from 573 to 253 in the candidate
between 0.1 and 0.6 seconds; opaque comparison stays approximately 479 to 478.
Both final images contain only background. These are image diagnostics, with
random particle trajectories; they describe rendered fade rather than brightness
calibration or identical particle paths.

Remaining scope: broader chemistry-specific feedback coverage and human mix,
movement and accessibility acceptance. Existing data-driven precipitate/gas,
electrode/surface and thermal diagrams retain their separate QA evidence.

Clean macOS release export and packaged keyboard round pass: five walking station
approaches, five tasks, 700 points and active bounded planting (380 corrections).

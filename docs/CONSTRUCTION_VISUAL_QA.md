# Construction stage visual review

2026-10-09, Godot 4.7.2 Forward+, Apple M4, native 1440×900.

## Scope and evidence

Twelve current captures cover six earned construction stages, each from the
normal yard camera and a fixed close camera. All twelve views were inspected
in the contact sheet; Stage 5 close was also inspected at full size.
`docs/screenshots/construction-stages-review.jpg` retains the reviewed matrix.
The capture tool freezes player/camera motion, hides HUD and navigation,
and resets/disables player-occlusion transparency for static geometry inspection.
Desktop focus loss is excluded from this capture; gameplay focus/pause has its
separate gate. Close views establish asset detail; yard views establish composition.

| Stage | Visible construction change | Yard and close review |
| --- | --- | --- |
| 0 | Concrete frame, temporary formwork, rebar | Clear frame silhouette and central passage |
| 1 | Partial upper slab and guardrail | Added slab remains legible against support frame |
| 2 | Completed upper slab; temporary formwork removed | Continuous floor and retained rebar visible |
| 3 | First masonry wall/window; rear temporary rail removed | Wall distinguishes earned progress |
| 4 | Second masonry wall/window | Corner and window trim remain distinct |
| 5 | Teal roof and supporting posts | Walls retained below roof; open foreground preserves view |

Central player silhouette, gray travel lane and yellow station pads remain
separated in the six yard views. Rebar, crane, cabin and mixer retain distinct
silhouettes. No missing stage geometry or visible coplanar flicker was found in
these static captures. This evidence covers the captured Level 1 composition;
contextual Levels 2–5 gameplay, movement behind structures and physical Windows
Forward+ acceptance remain separate open work.

## Verification

- `capture_construction_stages.gd`: CHEMSITE_CONSTRUCTION_CAPTURE_OK.
- `construction_progress_smoke.gd`: CHEMSITE_CONSTRUCTION_PROGRESS_OK.
  Covers contiguous career unlocks, six visible stage groups, temporary parts,
  persistence and practice-mode preservation of career construction progress.
- Current progression test save is isolated and removed after the test.

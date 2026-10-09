# Station context and player visibility

2026-10-09. Godot 4.7.2, native Forward+ on Apple M4, 1028×642.

## Coverage

`capture_level_station_context.gd` captures all 18 level/station bindings
(3/4/3/4/4 across Levels 1–5). Camera follow positions match exploration;
player placement uses endpoints exercised by existing traversal gates. Each
capture selects a real curated task for the station, checks nearest-station
selection, displays the matching prompt and opens/closes its existing task UI.
This is contextual visual evidence; actual movement is covered by the route
gates, and chemistry correctness by the separate task/interaction gates.

Five retained contact sheets in `docs/screenshots/station-context-level-*.jpg`
were reviewed after the fix. Station silhouettes, yellow pads, target arrows
and interaction prompts remain visible in all 18 captured contexts.

## Finding and repair

Inspection station approach at (-4.1, 0.04, 0) on Levels 2/4/5 places the
player behind the inspection monitor/table as well as the construction frame.
Existing building transparency revealed the frame interior while station
geometry continued to obscure the head. Station mesh instances now join the
existing player-camera occluder group. Only intersecting mesh parts fade;
clear parts restore full opacity, using the same normal/reduced-motion policy.
Physics and station activation remain unchanged.

Retained native before/after: `inspection-occlusion-before.png` and
`inspection-occlusion-after.png` in `docs/screenshots/`. The head is visible
through the faded monitor after the change. Residual frame/rebar overlap at
this approach still reduces whole-body contrast; human contextual readability
acceptance remains open.

## Verification

- LEVEL_STATION_CONTEXT_CAPTURE_OK captures=18.
- PLAYER_VISIBILITY_SMOKE_OK: original beam fade/restore and player-material
  protection pass; Levels 2/4/5 add 24 contextual station fades and restoration.
- Negative control with station registration removed exits 1 on Level 2:
  inspection station fails to reveal player.
- Clean editor import and macOS release export pass; packaged keyboard round
  completes five tasks for 700 points with bounded foot planting.
- Physical Windows Forward+ acceptance remains open: hosted Compatibility
  rendering ignores geometry-instance transparency.

## Layered occlusion refinement

The native inspection approach revealed cumulative tint from several faded
objects. A lower-body ray probe found zero additional missed objects; broadening
the ray bundle would not address this case. Existing intersecting parts now fade
to 94% transparency (6% residual opacity), retaining the same 12 s⁻¹ response,
clear-object restoration and reduced-motion behavior. Native full-size before/
after density captures were inspected and retained as
`inspection-density-before.png` / `inspection-density-after.png`.
The helmet, face and orange vest have less obstruction tint in the candidate.
All 18 contexts were recaptured; the existing three-level station fade/restore
and original building/player-material checks pass. Whole-body visibility around
unfaded adjacent rebar still needs human acceptance.

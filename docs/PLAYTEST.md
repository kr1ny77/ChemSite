# Exported keyboard playtest

Launch the exported macOS game with a persistent isolated test profile:

```sh
open -n builds/macos/ChemSite.app --args -- --qa-playtest
```

On Windows, launch `ChemSite.exe -- --qa-playtest`. Close other ChemSite windows
before selecting the QA window. The menu and career use
`user://qa_playtest_progress.json` and `user://qa_playtest_settings.json`.
The standard progress/settings files retain their existing contents. The test
profile keeps its own progression between sessions.

## Acceptance path

1. Start Level 1 using keyboard focus and confirm the required-station arrow.
2. Walk to each station with WASD/arrows, turn and release movement; inspect stop
   response, foot contact and obstruction fading. Open with E.
3. Complete five tasks using keyboard controls, including formula assembly.
4. Pause/resume with Escape; verify the clock and stationary player while paused.
   Switch away during exploration: the pause should open automatically, preserve
   the clock and require an explicit resume after returning. Switch away inside
   a task panel and verify the existing input remains intact.
5. Return to the menu, restart the app and verify the test score/unlock persisted.
6. Repeat Levels 2–5, test measurement/observation controls and reduced motion.
7. Listen to footsteps, interaction, success/error and mixer distance changes.

## 2026-10-06 evidence

Godot import/parse and macOS export succeeded. A source isolation gate traversed
menu → career → answer persistence → menu and checked both standard file hashes;
`MANUAL_PLAYTEST_ISOLATION_OK` passed with clean shutdown. Native CUA displayed
a zero-record test profile and keyboard activation entered Level 1. Subsequent
CUA observations had a partial frame, a capture failure and unavailable-window
response; movement/pause acceptance remains open. Standard user file hashes match
the recorded preflight hashes. This partial session does not satisfy the full
human five-task acceptance gate.

The focus-pause gate passed headless and native Forward+ with a reviewed
1028×642 screenshot. It covers moving-player stop, frozen timer, focused resume
button, explicit resumption and preservation of task/results states. Locomotion
phase transfer, transition, footsteps and acceleration response regressions pass.

## Keyboard event regression — 2026-10-06

The packaged `--qa-keyboard-round` route sends raw `InputEventKey` events through
`Input.parse_input_event()`. It starts Career from menu focus, holds physical
WASD keys through each collision-tested route, opens stations with E, traverses
answer/formula controls with Tab and activates them with Space. Escape opens
pause; Space resumes. Five correct submissions produce 700 points, three stars
and the Level 2 unlock in a dedicated `qa-keyboard-progress.json` file. The menu
return also uses Space. The standard progress hash is checked before/after.

The source headless round and native Forward+ graphical round passed. All eleven
1027×642 native screenshots were reviewed (five tasks, five feedback panels,
results). Initial failures identified test-side canonical/display ion spelling
and the new focus-loss pause. Answer selection now uses the production validator;
the graphical scenario explicitly resumes focus pauses through its focused button.
Final native shutdown is clean. This verifies the engine's keyboard event path;
physical hardware and the complete human/audio acceptance path remain open.

```sh
builds/macos/ChemSite.app/Contents/MacOS/ChemSite --headless -- --qa-keyboard-round
```

Windows CI runs the same packaged route with a 150-second process bound and checks
its success marker, exit status and script errors. The engine's internal bound
is 120 seconds. Native captures are stored in `user://qa-keyboard-level1-round/`; reviewed
source evidence is copied to `artifacts/keyboard-round/`.

2026-10-07: The release macOS repeat passed with five completed tasks, 700 points
and three stars. Final verbose log has no script/resource errors or leak warnings.
All packaged QA conditions use explicit branches; release builds elide assertions.
The initial assertion-based packaged result is excluded from acceptance evidence.

## Five-level keyboard extension — 2026-10-07

`--qa-keyboard-level=N` selects a dedicated level-scoped QA save and seeds only
that isolated file to unlock its menu button. All five default career rounds are
covered with collision-based walking and raw keyboard events. Higher-level
preparations include reagent pairs, mission readouts, virtual scale formulas,
solution conversion, pH readings, ion scans, salt/electrode/corrosion comparisons
and dissociation ion counts. Numeric/equation answers use actual LineEdit key
input and Enter. The default Level 4 round does not cover the Hess route control;
its separate focused round remains part of the existing suite.

Levels 2–5 passed source/headless and the current macOS release binary with scores
840/980/1120/1260, three stars, saved unlocks and unchanged standard progress.
Native Levels 2–3 passed. A first Level 4 native run crashed with signal 11 during
an AppKit termination notification; Levels 4–5 graphical acceptance remains open
pending a separate repeat. Windows CI retains its per-level stdout/stderr/engine
logs even on failure. Human hardware/audio acceptance remains open.

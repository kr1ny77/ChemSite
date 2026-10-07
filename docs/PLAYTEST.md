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
Native Levels 2–3 passed at 1027×642. Levels 4–5 passed in the exported app
launched through LaunchServices at 1440×900. All 44 new screenshots were reviewed.
Two direct editor-executable Level 4 attempts crashed with signal 11 in an AppKit
termination notification; the packaged application repeats completed cleanly.
This direct editor-launch issue remains recorded separately from release evidence.

Windows run 37620885338 at fc9a5a1 completed successfully. The 19,843-byte retained
log archive matched SHA-256 39a66ab28bae9aa094702aecb3c6b093820c52fefba09d786b2c82dde160de3d.
All five stdout logs contain the exact expected scores and completion markers.
Their stderr logs identified a relative engine-log path error: the packaged app
resolves its log path beneath its executable directory. CI now passes an absolute
path and rejects engine ERROR lines as well as script errors. Clean CI verification
of this repair follows push. The earlier single-round job required its missing
engine log and therefore failed the logging gate; the retained stdout in the new
five-round job proves gameplay completion. Human hardware/audio acceptance remains open.

### Clean Windows repeat — 2026-10-07

Run 37621970913 at 62f0391 passed the Windows EXE suite, including all five raw
keyboard rounds, source locomotion/visibility/station gates and focused career
interactions. Exact scores are 700/840/980/1120/1260 with five completed tasks in
each level. The retained 34,479-byte diagnostic ZIP matches SHA-256
e3032a5307aaba480b8f22176b8b358affdc029f332b00a9b35607e31938f606.
Both engine and stdout logs contain each completion marker. All keyboard stderr
logs and engine logs are free of ERROR/SCRIPT ERROR lines. The absolute log path
repair is verified. The Windows EXE/PCK artifact is 46,493,991 bytes.

The shared light input Theme passed native 1028×642 layout validation for all 200
task panels and 400 correct/wrong feedback panels. Seven 1027×642 native captures
show empty/entered oxidation, full equation, numeric and locked solution controls.
Fresh macOS export and its keyboard Level 3 round passed with 980 points and a
clean verbose shutdown. Windows graphical run 37621971072 remains live at the
last observation; image review of its changed answer fields follows completion.

2026-10-07: Static capture requests now use main-thread explicit redraw instead
of an unbounded frame-post-draw wait. A reduced-motion movie stall was reproduced
and its partial file excluded. Final capture completes with 337 encoded frames,
and the previously crashing direct source Level 4 keyboard run completes cleanly
with five tasks and 1120 points. The exported surface/corrosion visual rounds
capture three/one settled observations before answers, and retain all eleven
original task/feedback/result states. Exact folder totals (14/12) confirm old
observation images are cleared before reusing the focused QA directory. Physical
human input/audio acceptance remains open.

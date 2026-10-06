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

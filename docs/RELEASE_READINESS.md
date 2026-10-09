# ChemSite v0.1.0 prerelease readiness

Updated 2026-10-09. This ledger distinguishes automated evidence from remaining
acceptance work. The full production objective remains active.

## Native implementation and evidence

| Requirement | Current evidence | Remaining acceptance |
| --- | --- | --- |
| Godot desktop game; one player | Native scenes, CharacterBody3D, Forward+; packaged rounds | Physical Windows desktop |
| Cartoon construction character and upright interactions | Original Blender rig/GLB; complete gait/action captures, contact gates in LOCOMOTION_CONTACT_QA.md | Human acceleration, reversal and tight-turn feel; residual bounded drift |
| Readable enclosed construction site, landmarks and navigation | Authored shell/fence/props, eight inspections, all-level station routes, target arrow/ground outline | Human scene composition/readability and contextual Level 2–5 playtest |
| Five career levels and chemistry mechanics | 200 verified curated tasks; five-level source/package/Windows rounds; focused station gates | Target-course instructor review and contextual human chemistry QA |
| Adaptive learning and persistence | Version-five migration, level-scoped mastery, scheduling and isolated package saves | Physical Windows save/relaunch acceptance |
| Practice | All 44 level/topic bindings; five timer-free package rounds; unchanged career file hashes | Human topic browsing |
| HUD, menus and accessibility | 200 task/400 feedback layout matrix, 7,089 HUD and 170 menu contrast/state checks; keyboard rounds; reduced motion | Human readability; slider focus visibility; full accessibility acceptance |
| Chemistry feedback and environment motion | Curated mixing/comparison/thermal views, finite/reduced-motion gates, mixer loop, repaired particle fade | Broader VFX coverage/readability audit |
| Audio | Original music reproducibility, four soft sole contacts, contact timing, native playback/settings gates | Headphone/laptop-speaker mix acceptance, physical Windows audio |
| Performance | M4 source profiles documented in PERFORMANCE_BASELINE.md | Approximately 60 FPS on representative student laptop |
| macOS build | Universal release export; practice and keyboard career package tests | Human exported five-task round; unsigned/unnotarized distribution |
| Windows build | GitHub native/graphical workflows; previous bc8ab7b both green | Updated commit workflows; physical desktop input/audio/save |
| Source and documentation | Main pushed, current screenshots/README, asset provenance | Final release revision and download links |
| Download archives and checksums | Packaging tool validates notices, log markers, CRC and SHA-256; preserves app permissions | Generate/inspect both archives from verified same-revision builds |
| GitHub prerelease | Explicitly authorized after playable native QA in original brief section 48 | Tag, upload both archives/checksums, inspect published assets |

The latest practice addition and audio revision require updated Windows runs.
A green workflow for an earlier revision supports that revision only.

## Distribution notices

`docs/release/notices/manifest.json` records source and SHA-256 for Godot 4.7.2
MIT/third-party notices, Onest OFL and both Kenney CC0 licenses. Preserve these
original notice bytes, including original line endings. The packaging tool checks
all notice hashes before writing the archive. Original ChemSite assets retain
their project authorship; this notice bundle assigns no new project license.

## Package procedure

Run the existing release export and packaged QA before packaging. Example:

```sh
python3 tools/release/package_release.py --platform macOS \
  --build builds/macos/ChemSite.app \
  --verification-log /tmp/chemsite-final-career-package.log \
  --verification-log /tmp/chemsite-final-practice-package.log
```

For Windows, supply a directory containing the verified paired `ChemSite.exe`
and `ChemSite.pck`, plus logs with all five keyboard-round markers and the
five-level practice marker. Compare the CI artifact revision to BUILD_INFO.json.
Log-marker checks support the recorded automated scope; manual acceptance remains
listed above. Inspect archive contents and run the extracted macOS application
before upload. Retain published SHA-256 values for download verification.

## Prerelease scope and recovery

The original brief permits a prerelease while broader testing remains open.
Publish only after current-revision native/graphical checks pass and both download
archives are verified. Describe the remaining acceptance items in release notes.
Keep the prior tagged source and archive checksums for rollback; fixes receive a
new version/tag and fresh platform verification.

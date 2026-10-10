# ChemSite prerelease readiness

Updated 2026-10-10. This ledger distinguishes automated evidence from remaining
acceptance work. The full production objective remains active.

## Native implementation and evidence

| Requirement | Current evidence | Remaining acceptance |
| --- | --- | --- |
| Godot desktop game; one player | Native scenes, CharacterBody3D, Forward+; packaged rounds | Physical Windows desktop |
| Cartoon construction character and upright interactions | Original Blender rig/GLB; complete gait/action captures, contact gates in LOCOMOTION_CONTACT_QA.md | Human acceleration, reversal and tight-turn feel; residual bounded drift |
| Readable enclosed construction site, landmarks and navigation | Authored shell/fence/props, eight inspections, all-level station routes, 2,000 target-pointer cases, six-stage native composition review (CONSTRUCTION_VISUAL_QA.md) | Human scene composition/readability and contextual Level 2–5 playtest |
| Five career levels and chemistry mechanics | 200 verified curated tasks; five-level source/package/Windows rounds; focused station gates | Target-course instructor review and contextual human chemistry QA |
| Adaptive learning and persistence | Version-five migration, level-scoped mastery, scheduling and isolated package saves | Physical Windows save/relaunch acceptance |
| Practice | All 44 level/topic bindings; five timer-free package rounds; unchanged career file hashes | Human topic browsing |
| HUD, menus and accessibility | 200 task/400 feedback layout matrix, 7,089 HUD and 172 menu contrast/state checks; keyboard rounds; reduced motion | Human readability and full accessibility acceptance |
| Chemistry feedback and environment motion | All 32 comparison and five mixing diagrams, 192 reveal/layout/motion checks, native state reviews, finite/reduced motion, mixer loop, repaired particle fade | Human VFX readability/acceptance |
| Audio | Original music reproducibility, four brushed-sole contacts, timing/playback/settings gates; user accepted footstep comfort | Headphone/laptop-speaker mix acceptance, physical Windows audio |
| Performance | M4 source profiles documented in PERFORMANCE_BASELINE.md | Approximately 60 FPS on representative student laptop |
| macOS build | Universal release export; practice/keyboard career tests; user accepted exported five-task round (“все хорошо”, 2026-10-10) | Unsigned/unnotarized distribution; broader all-level/device QA |
| Windows build | Published c0d23b2 0.1.2 native 38067866167 and graphical 38067867808 passed | Physical desktop input/audio/save |
| Source and documentation | Main pushed; v0.1.0 ac41d28, v0.1.1 1de892f and v0.1.2 c0d23b2 tags, current screenshots/README and asset provenance | Broader acceptance tracked below |
| Download archives and checksums | Both archives generated and extracted; CRC, file hashes and permissions verified; GitHub asset digests match | Physical Windows acceptance |
| GitHub prerelease | Published v0.1.0, v0.1.1 and v0.1.2 with platform archives/checksums; public tags/downloads verified | Broader production acceptance |

Historical v0.1.0 practice/audio revision passed Windows native and graphical runs.
All 191 captures decode at 1028×642; sixteen contact sheets and three full-size
panels were reviewed after artifact digest verification. The macOS extracted app
passed five career levels and five-level practice.

Published prerelease: https://github.com/kr1ny77/ChemSite/releases/tag/v0.1.0.
Release source revision: ac41d28bb0a60011297175e3cc3c203384204918.

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

## 0.1.1 published patch — 2026-10-10

Current game source is 1de892ffd1ed78ff5faa8a0f53cf181856437df6. The patch includes
quiet brushed footsteps (human comfort accepted), all 32 comparison diagrams,
gait-bound support anchors, modal navigation cleanup and corrected lower-cuff
skinning. Blender and native critical-pose reviews plus 72 sampled cycle views
confirm removal of waist-connected sleeve wedges. Complete movement, device,
accessibility and instructor acceptance remains tracked above.

Fresh universal macOS export contains version 0.1.1 and passed keyboard career
and five-level/44-topic practice. Archive CRC, fourteen file hashes, extracted
app equality and executable mode passed. Windows native 38064301998 passed
embedded file/product 0.1.1.0, all five keyboard rounds and practice; native
artifact digest/CRC checked. Graphical 38064301853 and its image review completed: 212 images decoded, 176 exact card interiors and 36 differing full captures reviewed. Candidate evidence is recorded separately in
`docs/release/v0.1.1-sleeve-candidate.json`.

Earlier b583a3e draft assets are superseded by the sleeve repair. Current packages
are published from builds/release/v0.1.1-sleeve. All four asset digests/sizes,
source tag and public checksum downloads are verified in
`docs/release/v0.1.1-verification.json`. Published
0.1.0 archives retain their original bytes and checksums.

## 0.1.2 verified publication — 2026-10-10

Source c0d23b2bb0392fbb2869d86420a0ac9943e47128; release 409065092.
Embedded macOS 0.1.2 and Windows 0.1.2.0. Fresh native/extracted macOS
practice and keyboard checks, Windows five keyboard levels and 44-topic practice
pass. Windows graphical run 38067867808: 254-entry CRC, 212 decoded PNGs,
181 exact card interiors and 31 differing captures reviewed across four sheets.
Public tag, four asset sizes/digests and both public checksum downloads verified
in docs/release/v0.1.2-verification.json. Published earlier archives preserved.
User owns target-computer performance and physical Windows checks; results pending.

## 0.1.3 verified publication — 2026-10-10

Source fea5dda2c6540ee7467e885e7b294b73e713f093; native Windows
38070150831 and graphical 38070150875 succeeded. 212 PNGs decoded,
72 exact card interiors and 140 differing captures reviewed on 16 sheets;
long mission and equilibrium panels inspected at full size. Optional hints
and randomized choices preserve layout and correct answer submission.
Public release 409081352, tag, four asset sizes/digests and two checksum
downloads verified in docs/release/v0.1.3-verification.json.
Broader human, device, accessibility and course acceptance remain open.

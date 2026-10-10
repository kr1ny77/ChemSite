# ChemSite audio QA

## Current brushed footsteps (2026-10-10)

Four original 90 ms sole-brush clips use a 20 ms rounded attack, 40 ms tail
fade, three cascaded 620–680 Hz low-pass stages and 180 Hz bass suppression.
Runtime playback gain is −32 dB through SFX, with the existing small pitch
variation and animation-contact timing. All PCM endpoints are silent.

| Clip | RMS dBFS | Peak dBFS |
| --- | ---: | ---: |
| `step_a.wav` | -45.81 | -31.20 |
| `step_b.wav` | -44.58 | -32.96 |
| `step_c.wav` | -45.88 | -32.78 |
| `step_d.wav` | -43.66 | -29.65 |

Native Forward+ audio playback and Walk/Run contact timing pass. The current
versioned macOS app passed keyboard gameplay and all-level practice. The
preview `artifacts/soft-footsteps-brush-preview.wav` is amplified for timbre
review; game playback is quieter. On 2026-10-10 the user explicitly rated the
current walking sound “Комфортный”. Walking-sound comfort is accepted. The
output device was unspecified; headphone/laptop-speaker full-mix and physical
Windows listening checks remain open. Earlier measurements below describe
historical revisions.

## Quiet sole refinement (2026-10-08)

Follow-up walking-sound feedback: four contacts now last 100 ms, with
340–394 Hz cascaded low-pass filtering, a 20 ms rounded attack and 40 ms
tail fade. Runtime step gain is −22 dB (4 dB below the previous version).
Source peaks: −28.10 to −24.54 dBFS; RMS: −41.72 to −39.45 dBFS.
Both PCM endpoints are zero. Existing contact timing and SFX settings apply.
Import/parse, contact timing, native Forward+ audio playback and refreshed
macOS release export pass.
Preview: `artifacts/quiet-footsteps-preview.wav`, sixteen contacts at default
SFX volume and runtime gain. Human headphone/speaker acceptance remains open.

## Padded footstep refinement (2026-10-08)

Replaced the remaining pitched body with a dry filtered-noise sole contact.
Four deterministic variations use 460–535 Hz cascaded low-pass filtering,
65 Hz low-frequency removal, a 12 ms rounded attack and 35 ms tail fade.
Duration is 120 ms; both PCM endpoints are zero. Player gain is now −18 dB.
Source peaks range from −22.81 to −20.53 dBFS; RMS from −37.80 to −36.00 dBFS.
Existing SFX settings and animation contact timing apply.

Editor import/parse, footstep timing, native Forward+ audio smoke, macOS export
and packaged five-task Level 1 round pass.
`artifacts/padded-footsteps-preview.wav` contains sixteen contacts at runtime gain.
Headphone/speaker listening acceptance remains open.

## Earlier footstep revision (2026-10-07)

Human feedback identified the walking sound as unpleasant. Replaced the two sharp synthetic contacts with four original rounded boot contacts. The generator uses two cascaded low-pass stages (700–865 Hz), an 8 ms smooth attack and a 25 ms tail fade. Removed the click layer. Clips last 160 ms and start/end at zero PCM amplitude. Runtime gain is −14 dB with a small eight-step pitch pattern (0.985–1.015), routed through the existing SFX slider. Animation contact timing is preserved.

| Clip | Mean | Peak |
| --- | ---: | ---: |
| `step_a.wav` | −33.6 dBFS | −16.8 dBFS |
| `step_b.wav` | −33.5 dBFS | −16.1 dBFS |
| `step_c.wav` | −32.1 dBFS | −14.3 dBFS |
| `step_d.wav` | −31.8 dBFS | −14.8 dBFS |

Measurements are decoded PCM RMS/peak. Source and native Forward+ audio smokes, Godot import/parse, fresh macOS export and its five-task keyboard round pass. Footstep timing smoke passes: walking triggers playback; stationary/disabled movement emits zero contacts. `artifacts/soft-footsteps-preview.wav` demonstrates sustained cadence at the default SFX slider and runtime gain. Headphone/speaker listening acceptance remains open.

## Objective source check (2026-10-02)

The seven shipped audio clips were decoded with FFmpeg `volumedetect`. Peaks are below digital full scale. These are source-file measurements; an exported-game listening pass on headphones and laptop speakers remains the release gate for balance and spatial placement.

| Clip | Duration | Mean | Peak | Runtime path |
| --- | ---: | ---: | ---: | --- |
| `lofi-1.mp3` | 109.67 s | −24.0 dBFS | −9.7 dBFS | Music bus, −8 dB player gain, loop |
| `correct.wav` | 0.42 s | −27.9 dBFS | −16.9 dBFS | SFX bus, −4 dB player gain |
| `incorrect.wav` | 0.36 s | −28.8 dBFS | −17.8 dBFS | SFX bus, −4 dB player gain |
| `interact.wav` | 0.22 s | −30.6 dBFS | −20.3 dBFS | SFX bus, −4 dB player gain |
| `step_a.wav` | 0.18 s | −26.8 dBFS | −9.9 dBFS | SFX bus, −12 dB player gain |
| `step_b.wav` | 0.18 s | −26.9 dBFS | −10.2 dBFS | SFX bus, −12 dB player gain |
| `machinery_loop.wav` | 4.00 s | −24.8 dBFS | −18.3 dBFS | SFX bus, −10 dB player gain plus 3D attenuation |

The default saved sliders set Music to 0.7 (about −3.10 dB) and SFX to 0.8 (about −1.94 dB). The default music source peak therefore reaches about −20.8 dBFS before the Master bus; a correct-answer cue reaches about −22.8 dBFS. The game uses the Music and SFX buses separately, and both sliders persist in `user://settings.json`.

## Exported-app listening pass

Use the macOS app and a physical Windows installation. Listen with the default settings, then at low volume and with Music or SFX muted. Complete one round while walking near and away from the mixer. Record:

- Music versus answer and interaction cue audibility; level transitions and restart behavior.
- Footstep cadence and variation during sustained movement; clipping or harsh transients.
- Mixer ambience distance, left/right placement and loop seam.
- Headphone and laptop-speaker balance; whether volume sliders and mute states match their labels.

Capture tester device, operating system, output device, settings, timestamp, and any repeatable issue. The objective source check supports this listening pass; it does not replace it.

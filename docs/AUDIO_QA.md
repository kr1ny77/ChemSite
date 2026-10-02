# ChemSite audio QA

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

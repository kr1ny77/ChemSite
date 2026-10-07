# ChemSite audio QA

## Footstep revision (2026-10-07)

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

# Performance baseline

Target: approximately 60 FPS at 1440×900 on a normal student laptop. A 60 FPS frame has 16.67 ms of wall time.

On 2026-09-29, `tools/validation/profile_site.gd` sampled 360 rendered frames after 120 warmup frames in each of two states: site exploration and a visible task panel. This was a source-project run on macOS 26.6.2, Apple M4, 16 GB RAM, Godot 4.7.2 Forward+ with Metal. The script records frame intervals, reported FPS, draw calls, node count and Godot static memory. The test did not include walking or sustained effects.

| State | 1440×900 with VSync | Uncapped frame p90 / p99 | Median draw calls | Nodes | Static memory |
| --- | --- | --- | ---: | ---: | ---: |
| Exploration | 60 FPS reported; frame p90 17.52 ms | 9.04 / 11.07 ms | 537 | 346 | 63.6 MB |
| Task panel | 60 FPS reported; frame p90 17.51 ms | 9.32 / 13.49 ms | 568 | 355 | 64.1 MB |

The uncapped sample shows rendering headroom on this M4. The VSync frame interval includes display scheduling, so its p90 is slightly above the 16.67 ms budget even while the engine reports 60 FPS. Godot's process-time monitor was inconsistent with the measured wall intervals in the uncapped run and is excluded from the gate assessment.

Remaining Phase 14 gate: capture the same states, a movement route and answer effects on a representative student laptop with a discrete or integrated Windows GPU; inspect frame-time spikes and memory there before optimizing. The current hardware baseline does not establish the target laptop result.

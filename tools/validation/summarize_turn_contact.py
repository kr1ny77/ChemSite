"""Summarize measured support phases without changing locomotion acceptance gates."""
import hashlib
import json
from pathlib import Path

root = Path(__file__).resolve().parents[2]
rows = []
for hz in (30, 60, 120):
    source = root / f'artifacts/locomotion-contact-physics-{hz}.json'
    reports = json.loads(source.read_text())
    for report in reports:
        if report['scenario'] not in ('corner_run', 'reverse_run'):
            continue
        samples = [s for s in report['samples'] if 1.25 <= s['time_s'] <= 1.8]
        peak = max(samples, key=lambda s: s['drift_m'])
        saturated = [s for s in samples if s['requested_offset_m'] > 0.0651]
        reach_limited = [s for s in samples if s['reach_loss_m'] > 0.0001]
        rows.append({
            'physics_hz': hz,
            'scenario': report['scenario'],
            'source': str(source.relative_to(root)),
            'source_sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
            'turn_peak': peak,
            'first_correction_saturation': saturated[0] if saturated else None,
            'first_reach_limit': reach_limited[0] if reach_limited else None,
            'saturated_samples': len(saturated),
            'reach_limited_samples': len(reach_limited),
            'steady_maximum_m': report['steady_maximum_m'],
            'skipped_pairs': report['skipped_pairs'],
        })
output = root / 'docs/release/turn-contact-phase-audit.json'
output.write_text(json.dumps(rows, indent=2) + '\n')
for row in rows:
    peak = row['turn_peak']
    first = row['first_correction_saturation']
    print(row['physics_hz'], row['scenario'],
          'peak_mm=', round(peak['drift_m'] * 1000, 3),
          'peak_phase=', round(peak['support_phase'], 4),
          'peak_reach_loss_mm=', round(peak['reach_loss_m'] * 1000, 3),
          'first_saturation_frame=', first['frame'] if first else None)

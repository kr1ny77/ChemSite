"""Validate the preserved 200-task chemistry export before native selection."""
import json
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
TASKS = json.loads((ROOT / "data/chemistry/curated_tasks.json").read_text())


def normalize(value: str) -> str:
    digits = str.maketrans("₀₁₂₃₄₅₆₇₈₉⁰¹²³⁴⁵⁶⁷⁸⁹⁺⁻", "01234567890123456789+-")
    return " ".join(value.translate(digits).replace("^", "").lower().split())


errors = []
ids = set()
for task in TASKS:
    identifier = task.get("id", "")
    if identifier in ids:
        errors.append(f"{identifier}: duplicate ID")
    ids.add(identifier)
    for field in ("id", "topic", "subtopic", "station", "interactionType", "prompt", "explanation", "hint"):
        if not isinstance(task.get(field), str) or not task[field].strip():
            errors.append(f"{identifier}: missing {field}")
    if task.get("reviewStatus") not in {"verified", "review-required"}:
        errors.append(f"{identifier}: invalid review status")
    if task.get("reviewStatus") == "review-required" and not task.get("reviewReason"):
        errors.append(f"{identifier}: review reason missing")
    answer = task.get("correctAnswer")
    if isinstance(answer, dict):
        if not isinstance(answer.get("value"), (float, int)) or answer.get("absoluteTolerance", 0) < 0:
            errors.append(f"{identifier}: invalid numeric answer")
    elif not isinstance(answer, str) or not answer.strip():
        errors.append(f"{identifier}: missing deterministic answer")
    options = task.get("options", [])
    if options and isinstance(answer, str):
        accepted = [answer, *task.get("acceptedAnswers", [])]
        if not any(normalize(option) in {normalize(value) for value in accepted} for option in options):
            errors.append(f"{identifier}: options omit accepted answer")

counts = Counter(task.get("level") for task in TASKS)
if len(TASKS) != 200 or counts != {level: 40 for level in range(1, 6)}:
    errors.append(f"Unexpected task distribution: {counts}")

if errors:
    raise SystemExit("\n".join(errors))
verified = sum(task.get("reviewStatus") == "verified" for task in TASKS)
review_required = len(TASKS) - verified
print(f"CURATED_TASKS_OK: 200 seeds, {verified} verified, {review_required} in review; 40 per level")

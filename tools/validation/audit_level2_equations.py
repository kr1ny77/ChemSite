"""Check atom and electric-charge conservation in curated Level 2 answers."""

from __future__ import annotations

import json
import re
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
TASKS = ROOT / "data/chemistry/curated_tasks.json"
ELEMENT = re.compile(r"[A-Z][a-z]?")
CHARGE = re.compile(r"(?:\^(\d+))?([+-])$")


def parse_formula(formula: str) -> tuple[Counter[str], int]:
    formula = formula.strip()
    charge = 0
    suffix = CHARGE.search(formula)
    if suffix:
        charge = int(suffix.group(1) or 1) * (1 if suffix.group(2) == "+" else -1)
        formula = formula[: suffix.start()]
    stack: list[Counter[str]] = [Counter()]
    position = 0
    while position < len(formula):
        symbol = formula[position]
        if symbol == "(":
            stack.append(Counter())
            position += 1
            continue
        if symbol == ")":
            if len(stack) == 1:
                raise ValueError(f"Unmatched close bracket in {formula}")
            group = stack.pop()
            position += 1
            amount, position = read_number(formula, position)
            for element, count in group.items():
                stack[-1][element] += amount * count
            continue
        match = ELEMENT.match(formula, position)
        if match is None:
            raise ValueError(f"Invalid formula token at {formula[position:]} in {formula}")
        position = match.end()
        amount, position = read_number(formula, position)
        stack[-1][match.group()] += amount
    if len(stack) != 1 or not stack[0]:
        raise ValueError(f"Incomplete formula: {formula}")
    return stack[0], charge


def read_number(formula: str, position: int) -> tuple[int, int]:
    end = position
    while end < len(formula) and formula[end].isdigit():
        end += 1
    amount = int(formula[position:end]) if end > position else 1
    if amount < 1:
        raise ValueError(f"Invalid subscript in {formula}")
    return amount, end


def parse_side(side: str) -> tuple[Counter[str], int]:
    elements: Counter[str] = Counter()
    total_charge = 0
    for part in side.split(" + "):
        part = part.strip()
        match = re.match(r"^(\d+)(?=[A-Z])", part)
        coefficient = int(match.group(1)) if match else 1
        formula = part[match.end() :] if match else part
        atoms, charge = parse_formula(formula)
        for symbol, count in atoms.items():
            elements[symbol] += coefficient * count
        total_charge += coefficient * charge
    return elements, total_charge


def is_balanced(equation: str) -> bool:
    left, right = equation.split(" -> ", 1)
    return parse_side(left) == parse_side(right)


def main() -> None:
    assert is_balanced("2H2 + O2 -> 2H2O")
    assert not is_balanced("H2 + O2 -> H2O")
    assert is_balanced("Ba^2+ + SO4^2- -> BaSO4")
    assert not is_balanced("Cu^2+ + OH- -> Cu(OH)2")
    tasks = json.loads(TASKS.read_text())
    equations = [
        task for task in tasks
        if task["level"] == 2
        and isinstance(task["correctAnswer"], str)
        and " -> " in task["correctAnswer"]
    ]
    for task in equations:
        answer = task["correctAnswer"]
        if not is_balanced(answer):
            raise AssertionError(f"Unbalanced answer {task['id']}: {answer}")
    print(f"LEVEL2_EQUATIONS_OK: {len(equations)} answers conserve elements and charge")


if __name__ == "__main__":
    main()

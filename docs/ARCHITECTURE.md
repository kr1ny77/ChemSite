# Native ChemSite architecture

Godot 4.7 Forward+ is the production runtime. `Main` owns scene transitions; the active `ConstructionSite` owns the round, player, station proximity, task state, and HUD. `Player` is a CharacterBody3D with semantic InputMap actions. `GameHud` is a Control scene that emits answer, resume and exit signals. The ten representative tasks live in `data/chemistry/vertical_slice_tasks.json`; the 200 curated source tasks remain in `legacy-web/src/chemistry/tasks/`.

Career currently uses deterministic ordered tasks and a five-task completion target. Practice filters the verified bank by topic, runs without a timer and does not alter career progress. `save_data.gd` stores versioned best score, stars, XP and completed rounds in `user://progress.json`, migrating version-1 saves. The macOS package includes an isolated `--qa-round` entry path for installed-runtime verification. Production work will separate task selection, chemistry validation, adaptive learning, station behavior, audio, and progression into focused systems before adding content scale.

The browser architecture that preceded this migration is preserved by Git history and `legacy-web/`.

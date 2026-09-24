# Native ChemSite architecture

Godot 4.7 Forward+ is the production runtime. `Main` owns scene transitions; the active `ConstructionSite` owns the round, player, station proximity, task state, and HUD. `Player` is a CharacterBody3D with semantic InputMap actions. `GameHud` is a Control scene that emits answer, resume and exit signals. The ten representative tasks live in `data/chemistry/vertical_slice_tasks.json`; the 200 curated source tasks remain in `legacy-web/src/chemistry/tasks/`.

Career selects verified tasks deterministically through `task_scheduler.gd`, favoring weaker topics while alternating stations. A wrong answer records a mistake, advances to a different task, and moves a related verified task two questions later when possible. Practice filters the bank by topic, runs without a timer and leaves career progress unchanged. `save_data.gd` stores versioned best score, stars, XP, completed rounds, topic mastery and mistakes in `user://progress.json`, migrating version-1 and version-2 saves. The macOS package includes an isolated `--qa-round` entry path for installed-runtime verification. Chemistry validation, station behavior, audio and progression remain separate systems as content scales.

The browser architecture that preceded this migration is preserved by Git history and `legacy-web/`.

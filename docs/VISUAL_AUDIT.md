# ChemSite Visual Audit

Baseline: 2026-09-22 desktop Playwright run at 1024 × 640, plus a 390 × 844 layout check. Movement, perimeter collision, station proximity, chemistry submission, pause/resume, and console checks passed.

## Strong foundation

- The fixed isometric view exposes the whole gameplay area and keeps movement readable.
- The player has a clear safety-yellow/orange silhouette.
- HUD placement protects the center of the playfield and responsive layout stays inside the narrow viewport.
- Warm key light, soft fill, and cast shadows already provide a useful lighting base.

## Production gaps

- The level reads as one flat slab with stations distributed around its perimeter; it lacks authored zones, foreground/background depth, landmarks, and environmental storytelling.
- Eight stations share the same dark box, colored lid, diamond marker, and ring. Their mechanics are recognizable through labels rather than silhouettes.
- Large areas are visually empty. Concrete frame, crane, mixer, scaffold, pipes, sacks, and cones remain isolated primitive studies instead of coherent prop clusters.
- Materials rely on flat colors with limited surface variation. Concrete, steel, wood, plastic, glass, and liquids need distinct reusable material families.
- The procedural character communicates the role, while its capsule limbs, static pose, minimal stride motion, and blocky helmet still read as prototype geometry.
- World labels and top HUD use a polished layout, yet the translucent panels and broad rounded treatment feel closer to a web overlay than a construction work-order interface.
- Environmental animation, chemistry activity, success/failure world feedback, emissive equipment, and ambient motion are sparse.
- Camera composition crops several boundary props and shows pale void beyond the slab; the visible world needs a dressed diorama apron and distant site context.

## Art-pass priorities

1. Build a layered construction-site diorama with clustered storage, laboratory, active-build, and machinery zones.
2. Give every chemistry station a unique functional silhouette and restrained animated equipment.
3. Upgrade the student character, movement animation, material system, lighting, ground treatment, and environmental depth.
4. Integrate a coherent CC0 prop subset, then redesign the HUD as compact site paperwork and instrument readouts.
5. Validate two screenshot review passes against readability, grounding, visual density, console health, and performance.

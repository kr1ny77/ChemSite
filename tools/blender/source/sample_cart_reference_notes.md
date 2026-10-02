# Site sample cart reference and contract

Purpose: a stationary, game-ready sample cart in the rear-left chemistry work area. It strengthens the connection between the site laboratory cabin and the first task station while leaving the rear walking lane clear.

Visual references inspected on 2026-10-02:

- [VEVOR two-tier laboratory service cart](https://www.vevor.com/lab-cart-c_11050/vevor-lab-serving-cart-2-layers-stainless-steel-utility-rolling-cart-medical-cart-with-two-drawers-dental-utility-cart-with-lockable-wheels-and-a-bucket-for-laboratory-hospital-dental-use-p_010434157532), three-quarter product view. The cart has four tubular corner supports, two tray levels, raised perimeter lips, four small caster wheels, a rear grip, and shallow front drawers. The upper tray is the dominant readable mass; open space separates the lower shelf from it.
- ChemSite's existing `site_cabin.glb`, `safety_point.glb`, and `substance_storage.glb` provide the in-project color, edge softness, and equipment scale reference.

Modeling contract: footprint about 1.45 × 0.78 m, height about 1.15 m. The four casters carry the frame; two braced shelves carry capped sample jars and a lower sealed case. Amber marks the grip and tray rim, navy the frame, warm metal the trays, cyan the sample identifiers. Use bevels and smooth cylindrical silhouettes, keep the opening between shelves visible, retain editable Blender source, export GLB, and review front, side, rear, top, and game-camera views. The prop remains stationary and uses a simple rectangular collision proxy in Godot. The product photo informs structure only; no photo or texture is redistributed.

Review questions: Are the shelves visibly supported, do the wheels touch ground, do the sample containers stay inside the raised lip, and does the silhouette remain distinct from the task stations at normal camera distance?

# Level 4 station asset contract

The two original stations are designed for the fixed isometric site camera. Both use the existing 2.65 × 1.55 m concrete footing, teal steel bench and amber trim. They are reproducibly authored by `build_level4_stations.py`; editable `.blend` sources and game-ready GLBs are paired by name. Godot supplies simple box collision proxies.

The electrochemistry station groups two distinct half-cells, zinc- and copper-colored electrodes, an arched salt bridge, external leads and a central meter. Their spatial relationship follows the [Daniell cell educational diagram](https://www.mdpi.com/2076-3417/11/2/762/xml). It is a classroom visualization, without procedural lab instructions. The corrosion rig compares two supported steel reinforcement coupons with distinct exposed/corroded and coated surfaces, plus a compact inspection readout. Its paired layout makes the construction application readable at site scale.

Materials and geometry are authored locally; reference imagery is not redistributed. Blender Agent Studio fresh-import inspections passed both GLBs with zero reported geometry issues. Six-view sheets are in ignored `artifacts/electrochemistry_station_views/` and `artifacts/corrosion_test_rig_views/`; both were visually inspected. Godot 4.7.2 imported both and rendered them in the Level 4 site at 1440 × 900.

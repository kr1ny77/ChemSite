# Construction site lighting and material hierarchy

## 2026-10-06 pass

The isometric player and task stations are primary landmarks. Orange/yellow safety
surfaces distinguish interactions and work equipment; teal station bodies separate
from warm neutral ground. The central and rear pedestrian lanes use blue-gray
`9daeb7`, work zones use muted sand `c7b8a0`, and existing cream lane markings
trace the routes. Traversal geometry and station locations retain their contracts.

Sun color is warm-neutral `(1, .95, .86)`. Ambient light uses cool `b7cbe4` at
energy `.38`; Filmic tonemapping and the existing SSAO/contact shadows remain.
This reduces the global yellow cast while preserving a cheerful cartoon palette.
One shadow-casting sun and localized existing task lights keep the lighting cost
bounded. Geometry, textured resources and light counts are unchanged in this pass.

Review evidence: 1440×900 and 1028×642 Level 5 views, four perimeter positions in
standard and reduced-motion settings, source import and macOS package checks.
The palette is reviewed in native Forward+; Windows Compatibility screenshots
provide UI evidence and physical Windows Forward+ review remains open.

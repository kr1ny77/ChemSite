# UI accessibility QA

## Text and active button contrast — 2026-10-08

Target: at least 4.5:1 for tested text, including large labels. This is a
conservative design threshold derived from
[W3C contrast guidance](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html).
This pass covers native HUD Labels and enabled Button text in normal, hover and
pressed states; it is a bounded readability audit, with human accessibility and
other controls assessed separately.

The runtime audit evaluates the actual theme color and closest opaque panel
background for each visible Label. Buttons use their actual state material and
font colors. Relative luminance uses linearized sRGB. The harness inherits the
200-task unread/expanded, 400 correct/wrong, career/practice results and pause
layout matrix. Initial label audit fails on four colors. Expanded button audit
also exposes missing pressed colors in pH, ionization, dissociation, Hess and
comparison controls, plus mission hover/pressed styling.

| Text role | Previous ratio on #f3efe1 | Current ratio |
| --- | ---: | ---: |
| Orange headings | 2.89 | 5.25 |
| Secondary guidance | 4.16 | 5.25 |
| Correct answer / streak | 3.14 | 5.17 |
| Error / wrong station | 3.24 | 5.07 |

Four previously unstyled HUD actions now use the common button theme and 23 px
text: wrong-station return, answer continuation and the two pause actions. The
pause menu action also has a 55 px minimum height. Existing focus borders remain
visible. Chemical meaning is conveyed by labels as well as outcome colors.

Final native Forward+ audit at 1028x642 passes 7,089 checks: 2,841 labels and 4,248
active button states. All 200 task and 400 feedback layout gates pass. Five native
screens in `artifacts/hud-text-contrast/` were reviewed: equation input, correct
feedback, incorrect feedback, results and pause. Standalone HUD capture retains
placeholder exploration headings; production round verifies live HUD separately.
The initial headless 64x64 audit is color-only evidence. Native-size verification
supersedes its layout coverage. The Windows graphical workflow now runs this audit.

Remaining requirements: human readability/focus review, menu/settings and every
additional control family, representative laptop display, exported human-driven
round and physical Windows input/audio/save acceptance. This audit provides no
claim of complete accessibility conformance.

Clean macOS release export and packaged five-station keyboard round pass: five
tasks, 700 points and active bounded planting (340 corrections).


## Menu, settings and practice theme — 2026-10-08

Main-menu controls now share a native menu theme: a gold primary career action,
blue-gray secondary buttons, explicit normal/hover/pressed/disabled colors and
3 px focus borders. Primary focus uses dark ink on gold; secondary focus uses
gold on blue-gray. The Onest font remains shared with gameplay. Existing control
minimum heights, routing and saved setting values remain in place.

`menu_accessibility_smoke.gd` uses isolated progress/settings paths and validates
57 visible-label/button-state color checks across menu, settings and practice.
Enabled button text exceeds 4.5:1; focus borders exceed 3:1 against every active
button fill. Disabled button text is also checked for readability. Raw key events
open settings and practice, adjust and persist music volume, toggle/persist reduced
motion, close with Escape and restore focus to the respective entry button.
Failures propagate to a nonzero exit without reaching the success marker.

Native Forward+ run at 1028x642 passes. Three current screenshots in
`artifacts/menu-accessibility/` were reviewed (actual macOS drawable 1027x642).
The Windows graphical workflow now includes this menu gate. Sliders' physical
focus visibility and human accessibility acceptance remain open alongside the
other requirements above.

Clean macOS export and packaged keyboard career round pass with the new menu:
five station approaches, five tasks/700 points and return to the menu.

## Five-level practice menu — 2026-10-09

The expanded 44-topic menu passes 170 native label/button-state contrast checks.
Long topic labels wrap within a vertical-only scroll container. Focus follows
keyboard selection, including the final Level 5 topic; first/last views reviewed
at 1028×642. Settings volume/motion persistence and Escape focus restoration pass.

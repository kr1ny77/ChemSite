# Chemistry Review Queue

This file contains chemistry content that requires manual verification.

Tasks listed here must not enter the production question pool until resolved.

## Review format

### TASK-ID

Question:

Proposed answer:

Reason for review:

Possible ambiguity:

Resolution:

Status:
OPEN / VERIFIED / REJECTED

---

## Current queue

### L2-050

Question: Balance `P + O₂ → P₂O₅`.

Proposed answer: `4P + 5O₂ → 2P₂O₅`.

Reason for review: P₂O₅ is a common empirical formula, while the molecular form of phosphorus(V) oxide is P₄O₁₀. The equation is atom-balanced but the notation choice should match the target first-year course.

Possible ambiguity: `P₄ + 5O₂ → P₄O₁₀` represents molecular species; the current answer uses conventional empirical notation.

Resolution: Pending curriculum review. The task is excluded from native verified selection through `data/chemistry/review_overrides.json`.

Status: OPEN

## Level 2 audit

The 40 Level 2 prompts, answers, explanations, rules and examples received a content pass on 2026-09-24. Twenty authored molecular and ionic answers passed automated element and charge conservation. Reaction categories, precipitation, acid-base behavior and redox roles were cross-checked against [OpenStax Chemistry 2e §4.2](https://openstax.org/books/chemistry-2e/pages/4-2-classifying-chemical-reactions) and the balancing approach against [§4.1](https://openstax.org/books/chemistry-2e/pages/4-1-writing-and-balancing-chemical-equations). This audit does not replace a course-specific subject-matter review.

## Level 3 audit

The 40 Level 3 prompts, answers, explanations, rules and examples received a content pass on 2026-09-24. An independent arithmetic check recomputes 24 numeric answers from displayed quantities and atomic masses. Four dissociation answers conserve atoms and electric charge; the remaining 12 tasks present a valid answer among their choices. Molarity, dilution and mass fraction were cross-checked against [OpenStax Chemistry 2e §3.3](https://openstax.org/books/chemistry-2e/pages/3-3-molarity) and [§3.4](https://openstax.org/books/chemistry-2e/pages/3-4-other-units-for-solution-concentrations). The electrolyte and salt-hydrolysis cases were checked against [§11.2](https://openstax.org/books/chemistry-2e/pages/11-2-electrolytes) and [§14.4](https://openstax.org/books/chemistry-2e/pages/14-4-hydrolysis-of-salts). The pH tasks use the introductory concentration approximation described in [§14.2](https://openstax.org/books/chemistry-2e/pages/14-2-ph-and-poh); their prompts and rules now say so explicitly. This pass found no additional task requiring quarantine. A course-specific subject-matter review remains a release gate.

The Level 3 solution setup added on 2026-09-29 uses task-specific volumes, concentrations and molar masses. Independent validation checks the three displayed volume conversions and recomputes both mass answers with m = CVM and the dilution answer with C₁V₁ = C₂V₂. These relationships follow [OpenStax Chemistry 2e §3.3](https://openstax.org/books/chemistry-2e/pages/3-3-molarity). No new ambiguity was found.

The virtual pH terminal added on 2026-09-30 moves four already curated pH values from prompts into meter readouts. Independent validation checks that single readings of 3, 7 and 11 correspond to acidic, neutral (at 25 °C), and alkaline classifications, and that sample A at pH 2 is more acidic than sample B at pH 4. The comparison requires both readings and uses sample labels in its answer cards, preserving the informational role of the meter. The introductory teaching model remains unchanged.

The virtual ionization scan added on 2026-09-30 uses qualitative particle descriptions for the already reviewed HCl, NaOH, acetic acid, sucrose and NaCl classifications. HCl, NaOH and soluble NaCl appear predominantly as ions; acetic acid has a small ionized fraction; sucrose stays molecular. The four-sample comparison requires every observation before selection. These are teaching-model particle readouts, with no invented measured conductivity or concentration values. The Level 3 audit checks the sample list and expected answer relationships.

## Level 4 audit

The 40 Level 4 prompts, answers, explanations, rules and examples received a content pass on 2026-09-24. Two Hess calculations were recomputed independently; 38 choice tasks contain an accepted answer. The equilibrium pressure questions now specify compression or expansion at constant temperature, which fixes the physical change that determines the shift. Enthalpy and Hess's law were cross-checked against [OpenStax Chemistry 2e §5.3](https://openstax.org/books/chemistry-2e/pages/5-3-enthalpy); equilibrium and catalysts against [§13.3](https://openstax.org/books/chemistry-2e/pages/13-3-shifting-equilibria-le-chateliers-principle); galvanic roles and corrosion against [§17.3](https://openstax.org/books/chemistry-2e/pages/17-3-electrode-and-cell-potentials) and [§17.6](https://openstax.org/books/chemistry-2e/pages/17-6-corrosion). No additional task was quarantined in this pass. Course-specific subject-matter review remains a release gate.

The six virtual kinetics comparisons were checked against [OpenStax Chemistry 2e §12.2](https://openstax.org/books/chemistry-2e/pages/12-2-factors-affecting-reaction-rates) for surface area, temperature and concentration trends, and [§12.7](https://openstax.org/books/chemistry-2e/pages/12-7-catalysis) for the lower-barrier catalytic path. Their readouts are qualitative model observations and contain no measured rate constants.

The ten virtual equilibrium comparisons were checked against [OpenStax Chemistry 2e §13.1](https://openstax.org/books/chemistry-2e/pages/13-1-chemical-equilibria) for equal forward/reverse rates at dynamic equilibrium and [§13.3](https://openstax.org/books/chemistry-2e/pages/13-3-shifting-equilibria-le-chateliers-principle) for concentration, volume, temperature and catalyst effects. The pressure cases explicitly keep temperature constant; catalyst cases preserve the final equilibrium composition. Readouts are qualitative model states without invented concentration measurements.

The six electrochemistry comparisons added on 2026-09-30 use the curated Zn/Cu galvanic cell as a shared virtual model. The Zn half-reaction produces electrons for the external circuit; the Cu half-reaction consumes them. The Level 4 audit checks that both equations and flow descriptions are present for each task. These readouts align with the existing [OpenStax §17.3](https://openstax.org/books/chemistry-2e/pages/17-3-electrode-and-cell-potentials) review and contain no invented cell voltage or current measurements.

## Level 5 audit

The 40 Level 5 prompts, answers, explanations, rules and examples received a content pass on 2026-09-28. Three lime-cycle equations conserve atoms; the hardness arithmetic independently gives 2.5 versus 2.0 mmol/L for L5-180 and 3.0 mmol/L for L5-196. The three equation prompts and accepted answers now consistently require full equations. L5-174 specifies Portland cement, L5-190 identifies the sampled water circuit, and L5-200 separates the lime reaction from the corrosion findings. All 34 choice tasks contain a validated answer; two formula controls, one oxidation input and one numeric input passed native HUD checks. The longest final inspection prompt and answer cards were visually reviewed at 1440 × 900.

Reference checks: [American Cement Association, Applications of Cement](https://www.cement.org/cement-concrete/applications-of-cement/) for concrete constituents and hydration; [FHWA, Water-Cementitious Materials Ratio](https://www.fhwa.dot.gov/publications/research/infrastructure/pavements/pccp/04150/chapt9.cfm) for strength and permeability trends; [OpenStax Chemistry, §18.9](https://openstax.org/books/chemistry/pages/18-9-occurrence-preparation-and-compounds-of-oxygen) for the calcium carbonate/lime reactions; [USGS, Hardness of Water](https://www.usgs.gov/water-science-school/science/hardness-water) for calcium and magnesium; [NIST, Service Life of Concrete](https://nvlpubs.nist.gov/nistpubs/Legacy/IR/nistir89-4086.pdf) for steel passivity, carbonation and chloride risk; and [NIST, External Sulfate Attack](https://www.nist.gov/publications/microstructural-origins-cement-paste-degradation-external-sulfate-attack) for expansive damage. No new Level 5 task required quarantine in this pass. A target-course subject-matter review remains a release gate.

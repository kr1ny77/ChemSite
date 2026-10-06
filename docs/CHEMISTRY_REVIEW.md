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

Question: Balance the molecular equation `P₄ + O₂ → P₄O₁₀`.

Verified answer: `P₄ + 5O₂ → P₄O₁₀`.

Reason for review: The original prompt used P₂O₅, a common empirical formula, without specifying the intended formula convention.

Possible ambiguity: The original `4P + 5O₂ → 2P₂O₅` is atom-balanced in empirical notation, while `P₄ + 5O₂ → P₄O₁₀` uses molecular formulas.

Resolution: The production prompt now explicitly asks for the molecular equation. [PubChem](https://pubchem.ncbi.nlm.nih.gov/compound/Phosphorus-Pentoxide) identifies P₄O₁₀ as the molecular formula and P₂O₅ as the commonly used empirical formula. [OpenStax Chemistry 2e, Chapter 18 summary](https://openstax.org/books/chemistry-2e/pages/18-summary) uses P₄O₁₀ for phosphorus(V) oxide. Four P and ten O atoms appear on each side of the revised answer. The review override was removed and the task returned to the verified production pool. Target-course instructor review remains a separate curriculum gate.

Status: VERIFIED (2026-10-02)

## Level 2 audit

The 40 Level 2 prompts, answers, explanations, rules and examples received a content pass on 2026-09-24. Twenty authored molecular and ionic answers passed automated element and charge conservation. Reaction categories, precipitation, acid-base behavior and redox roles were cross-checked against [OpenStax Chemistry 2e §4.2](https://openstax.org/books/chemistry-2e/pages/4-2-classifying-chemical-reactions) and the balancing approach against [§4.1](https://openstax.org/books/chemistry-2e/pages/4-1-writing-and-balancing-chemical-equations). This audit does not replace a course-specific subject-matter review.

## Level 3 audit

The 40 Level 3 prompts, answers, explanations, rules and examples received a content pass on 2026-09-24. An independent arithmetic check recomputes 24 numeric answers from displayed quantities and atomic masses. Four dissociation answers conserve atoms and electric charge; the remaining 12 tasks present a valid answer among their choices. Molarity, dilution and mass fraction were cross-checked against [OpenStax Chemistry 2e §3.3](https://openstax.org/books/chemistry-2e/pages/3-3-molarity) and [§3.4](https://openstax.org/books/chemistry-2e/pages/3-4-other-units-for-solution-concentrations). The electrolyte and salt-hydrolysis cases were checked against [§11.2](https://openstax.org/books/chemistry-2e/pages/11-2-electrolytes) and [§14.4](https://openstax.org/books/chemistry-2e/pages/14-4-hydrolysis-of-salts). The pH tasks use the introductory concentration approximation described in [§14.2](https://openstax.org/books/chemistry-2e/pages/14-2-ph-and-poh); their prompts and rules now say so explicitly. This pass found no additional task requiring quarantine. A course-specific subject-matter review remains a release gate.

The Level 3 solution setup added on 2026-09-29 uses task-specific volumes, concentrations and molar masses. Independent validation checks the three displayed volume conversions and recomputes both mass answers with m = CVM and the dilution answer with C₁V₁ = C₂V₂. These relationships follow [OpenStax Chemistry 2e §3.3](https://openstax.org/books/chemistry-2e/pages/3-3-molarity). No new ambiguity was found.

The virtual pH terminal added on 2026-09-30 moves four already curated pH values from prompts into meter readouts. Independent validation checks that single readings of 3, 7 and 11 correspond to acidic, neutral (at 25 °C), and alkaline classifications, and that sample A at pH 2 is more acidic than sample B at pH 4. The comparison requires both readings and uses sample labels in its answer cards, preserving the informational role of the meter. The introductory teaching model remains unchanged.

The virtual ionization scan added on 2026-09-30 uses qualitative particle descriptions for the already reviewed HCl, NaOH, acetic acid, sucrose and NaCl classifications. HCl, NaOH and soluble NaCl appear predominantly as ions; acetic acid has a small ionized fraction; sucrose stays molecular. The four-sample comparison requires every observation before selection. These are teaching-model particle readouts, with no invented measured conductivity or concentration values. The Level 3 audit checks the sample list and expected answer relationships.

The hydrolysis comparisons added on 2026-10-02 expose the origin of each ion for NaCl, Na₂CO₃ and NH₄Cl. The readouts follow their previously reviewed explanations: Na⁺ and Cl⁻ contribute negligible hydrolysis in this introductory model, CO₃²⁻ yields OH⁻, and NH₄⁺ yields H₃O⁺. The Level 3 audit checks all three ion pairs and expected answers. Course-specific subject-matter review remains open.

The Level 3 final solution mission now separates its previously reviewed evidence into three sequential readouts: approximate neutral pH, detected Na⁺/Cl⁻, and absence of a precipitate in the specified control probes. The answer remains deterministic from the detected ion pair. The content audit checks the three-step record and expected answer; no new chemical measurement was introduced.

The four dissociation boards added on 2026-10-02 use the reviewed NaCl, CaCl₂, Na₂SO₄ and AlCl₃ equations. Each board stores the positive and negative ion charges and their counts per formula unit. The Level 3 audit independently checks all four tuples and verifies that the total ionic charge is zero. Full equation entry remains the graded answer after the board is balanced.

## Level 4 audit

The 40 Level 4 prompts, answers, explanations, rules and examples received a content pass on 2026-09-24. Two Hess calculations were recomputed independently; 38 choice tasks contain an accepted answer. The equilibrium pressure questions now specify compression or expansion at constant temperature, which fixes the physical change that determines the shift. Enthalpy and Hess's law were cross-checked against [OpenStax Chemistry 2e §5.3](https://openstax.org/books/chemistry-2e/pages/5-3-enthalpy); equilibrium and catalysts against [§13.3](https://openstax.org/books/chemistry-2e/pages/13-3-shifting-equilibria-le-chateliers-principle); galvanic roles and corrosion against [§17.3](https://openstax.org/books/chemistry-2e/pages/17-3-electrode-and-cell-potentials) and [§17.6](https://openstax.org/books/chemistry-2e/pages/17-6-corrosion). No additional task was quarantined in this pass. Course-specific subject-matter review remains a release gate.

The six virtual kinetics comparisons were checked against [OpenStax Chemistry 2e §12.2](https://openstax.org/books/chemistry-2e/pages/12-2-factors-affecting-reaction-rates) for surface area, temperature and concentration trends, and [§12.7](https://openstax.org/books/chemistry-2e/pages/12-7-catalysis) for the lower-barrier catalytic path. Their readouts are qualitative model observations and contain no measured rate constants.

The ten virtual equilibrium comparisons were checked against [OpenStax Chemistry 2e §13.1](https://openstax.org/books/chemistry-2e/pages/13-1-chemical-equilibria) for equal forward/reverse rates at dynamic equilibrium and [§13.3](https://openstax.org/books/chemistry-2e/pages/13-3-shifting-equilibria-le-chateliers-principle) for concentration, volume, temperature and catalyst effects. The pressure cases explicitly keep temperature constant; catalyst cases preserve the final equilibrium composition. Readouts are qualitative model states without invented concentration measurements.

The six electrochemistry comparisons added on 2026-09-30 use the curated Zn/Cu galvanic cell as a shared virtual model. The Zn half-reaction produces electrons for the external circuit; the Cu half-reaction consumes them. The Level 4 audit checks that both equations and flow descriptions are present for each task. These readouts align with the existing [OpenStax §17.3](https://openstax.org/books/chemistry-2e/pages/17-3-electrode-and-cell-potentials) review and contain no invented cell voltage or current measurements.

The seven corrosion inspections added on 2026-10-02 compare qualitative conditions already covered by each reviewed explanation: moisture and oxygen, anodic iron oxidation, coating integrity, sacrificial protection, passivation, electrolyte exposure and dissimilar-metal contact. Both readouts must be opened before an answer. The observations contain no invented corrosion rates or measured potentials; the existing [OpenStax §17.6](https://openstax.org/books/chemistry-2e/pages/17-6-corrosion) review remains the chemistry reference. Course-specific subject-matter review remains open.

## Level 5 audit

The 40 Level 5 prompts, answers, explanations, rules and examples received a content pass on 2026-09-28. Three lime-cycle equations conserve atoms; the hardness arithmetic independently gives 2.5 versus 2.0 mmol/L for L5-180 and 3.0 mmol/L for L5-196. The three equation prompts and accepted answers now consistently require full equations. L5-174 specifies Portland cement, L5-190 identifies the sampled water circuit, and L5-200 separates the lime reaction from the corrosion findings. All 34 choice tasks contain a validated answer; two formula controls, one oxidation input and one numeric input passed native HUD checks. The longest final inspection prompt and answer cards were visually reviewed at 1440 × 900.

Reference checks: [American Cement Association, Applications of Cement](https://www.cement.org/cement-concrete/applications-of-cement/) for concrete constituents and hydration; [FHWA, Water-Cementitious Materials Ratio](https://www.fhwa.dot.gov/publications/research/infrastructure/pavements/pccp/04150/chapt9.cfm) for strength and permeability trends; [OpenStax Chemistry, §18.9](https://openstax.org/books/chemistry/pages/18-9-occurrence-preparation-and-compounds-of-oxygen) for the calcium carbonate/lime reactions; [USGS, Hardness of Water](https://www.usgs.gov/water-science-school/science/hardness-water) for calcium and magnesium; [NIST, Service Life of Concrete](https://nvlpubs.nist.gov/nistpubs/Legacy/IR/nistir89-4086.pdf) for steel passivity, carbonation and chloride risk; and [NIST, External Sulfate Attack](https://www.nist.gov/publications/microstructural-origins-cement-paste-degradation-external-sulfate-attack) for expansive damage. No new Level 5 task required quarantine in this pass. A target-course subject-matter review remains a release gate.

## Construction-site observations

Eight optional site descriptions are curated in `data/chemistry/site_inspections.json`. The concrete-frame description states the constituents of concrete and hydraulic cement hydration; the mixer description states that proportioning and mixing affect material properties. Both claims agree with the [American Concrete Institute definition of concrete and hydraulic cement](https://www.concrete.org/frequentlyaskedquestions.aspx?faqid=640) and the [American Cement Association overview of cement applications](https://www.cement.org/cement-concrete/applications-of-cement/). The remaining descriptions identify in-game props and the virtual nature of the experience. These observations do not generate or score chemistry answers. A target-course instructor review remains open.

2026-10-06: The added sample-workbench note names the visible moulds, cubes and logbook and directs virtual results to educational stations. It adds no chemical claim or practical procedure. Source and packaged inspection gates cover all seven notes.

2026-10-06: The pipe-display note identifies the modeled tank, pipe brackets, manual pump and gauge. It describes virtual inspection only, with no physical pressure values or practical operating procedure. All eight notes are covered by the source and packaged inspection gates.

2026-10-06: Added schematic visual metadata to L2-051–055: white BaSO₄/AgCl, blue Cu(OH)₂, brown Fe(OH)₃ precipitates and CO₂ bubbles, matching the existing curated observations. Geometry, quantity and timing are explicitly illustrative. The text remains authoritative; no new chemical answer or practical procedure is introduced. Source-bank/native JSON regeneration and all five observation controls are verified. Target-course instructor review remains open.

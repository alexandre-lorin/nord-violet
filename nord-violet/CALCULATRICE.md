# Scientific Calculator A — 7 October 2026

## Native integration — 8 October 2026 (priority)

User validation: Toubi confirms “the calc is perfect, everything works”. No longer consider it as a model to be chosen or awaiting overall validation.

Calculator built into Quickshell with Calculator.qml, type registered in qmldir and IPC `calculator`. No browser or terminal required. Centered floating window 880×720, panel folding to 430 px, scrolling content to not exceed height. The `calc` command and the XF86Calculator keys on the RK and laptop show/hide this window. `calc 'W(1)'` opens and then calculates the expression. Enter calculates, Esc clears, Super+Q closes the window; closing via hide retaining the memory of this instance. Calculator Nord Violet launcher input added. qalc remains installed and directly usable.

Identical HTML/Qt engine, shared by symlink CalculatorEngine.js to the nord-violet package engine. JS API made Qt compatible without changing calculations (exported declaration, hasOwnProperty, regex replacement). The symlink is absolute for this /home/toubi installation; adapt if the repository is moved.

Validation: qmllint, desktop-file-validate, sh -n, configerrors and diff --check without error; 101 Node digital tests and 50 Python tests pass. Eight calculations/domains verified in the real Qt engine (W0, W−1, Gamma, PGCD, combinatorial, trig, factorial, division by zero). Evaluation from the IPC interface, masking and reopening with retained result verified. Really floating window 880×720 and captured render. Transient errors during first load fixed; last successful reload Quickshell. Physical verification of the calculator keys and assessment of the rendering by Toubi still awaited.

The mockup sections below remain history.

Direction A terminal chosen by Toubi. Enriched model: `maquettes/calculatrice-a-scientifique.html`. Not yet integrated into Quickshell; qalc and its shortcuts preserved.

## Present features

- Foldable scientific panel, free input and buttons inserted at the cursor, Enter calculate / Escape delete.
- Trigonometry, inverses and atan2 in RAD/DEG; hyperbolic and inverse (independent of the angular unit).
- Roots, right-associative powers, exponential, logarithms, expm1/log1p; pi/e/tau/phi constants.
- W/w0 for main Lambert W; wm1 for the real branch −1. W accepts x ≥ −1/e; wm1 accepts −1/e ≤ x < 0. Point −1/e treated explicitly, local expansion near the branching point, bisection in logarithmic domain elsewhere, series for W0 near zero. Bounded iterations; explicit failure if insufficient convergence.
- Gamma by Lanczos approximation and reflection, rejected poles. Gamma overflow also rejected inside the reflection so as not to return a false zero.
- Integer factorial 0…170, nCr/nPr, modulo, rounding, min/max/hypot, PGCD/PPCM with control of representable integers.
- Variables a,b,c,h,n,r,t,x,y,z and x0…x99 by assignment `x = 12`. years and memory preserved without display rounding. Reusable log, 40 calculations in memory / 6 lines displayed; history with angular unit.

Engine without eval or Function, expression length limited to 500 characters, unknown names and invalid domains rejected. Double real precision, not arbitrary precision or symbolic calculation. 14 figures displayed are not a universal guarantee of accuracy. Very small/large values ​​and singularities remain subject to Float64 limits.

## Validation

21 historical tests + 80 scientific/domain/integer tests pass. Numerical references for W and Gamma, Lambert W identities on two branches and ranges up to 1e300, power conventions, trigonometric inverses and angle conversion. Two values ​​also compared to installed qalc: W(1), Gamma(0.5).

JS scripts of the pages analyzed with vm.Script; complete rendering in Firefox headless controlled, including button generation. No added packages or library downloads. No simulation of unimplemented functions.

Mathematical sources: [NIST DLMF Lambert W](https://dlmf.nist.gov/4.13), [NIST DLMF Gamma / reflection](https://dlmf.nist.gov/5.5).

## To come after validation

Native integration and replacement of calculator shortcuts. Complex numbers, equation solver, derivatives and numerical integrals are not present in this version; do not announce them as functional. User validation expected on density, scientific panel and log.

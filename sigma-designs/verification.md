# Verification craft & gotchas

Beauty claims need measurements. Every Sigma Designs delivery includes
objective proof, captured by scripted browser probes (Playwright-style).

## Proving the look

- **Motion proof**: two screenshots of the SAME element seconds apart — the
  bright rim segment must have MOVED. One screenshot proves nothing about
  "self-animating".
- **Reference match**: side-by-side crop vs the reference image (or the hero
  element when porting its language to a smaller one). Judge color language,
  not pixels.
- **Entrance proof**: catch the mid-entrance frame (half-emerged through the
  mask, mid-stagger pop) — the money shot that proves birth-from-within.
- **Coupling proof**: dispatch synthetic pointer moves, screenshot element +
  follower displaced together (with the follower lagging).
- **Story walk**: scripted scroll through every beat at multiple viewport
  heights — pin-resolution bugs scale with viewport height and hide at small
  windows.
- **Frame-by-frame study**: when matching a reference VIDEO, extract frames
  (ffmpeg ~6fps, crops + contact sheets) and quantify periods/counts before
  building — brief-by-image beats brief-by-words.
- FPS: sample rAF deltas 4s per position (avg, p95, frames >33ms), and run
  layer-isolation toggles (hide canvas / kill DOM filters / dpr 1 vs 2) to
  localize cost before optimizing anything.

## Gotcha table (each cost a real debugging session)

| Gotcha | Rule |
|---|---|
| Vite HMR does NOT recompile R3F shader template strings | fresh page load per shader iteration |
| Headless Chrome defaults to SwiftShader (software GL, reports ~1fps garbage) | launch with `--use-gl=angle --use-angle=metal` (macOS) |
| Playwright refuses to click elements with infinite CSS animations ("not stable") | dispatch synthetic `.click()` / events via `evaluate` |
| Synthetic `.click()` on some full-screen overlay buttons silently fails | use role-based locator clicks for gates |
| `document.fonts.ready` resolves before lazy webfont fetches | `document.fonts.load('<weight> 1em Face')` the exact faces |
| three.js auto-injects `instanceMatrix` for ShaderMaterial on InstancedMesh | don't redeclare it |
| `THREE.Color[]` works directly as a `vec3[]` uniform | no manual flattening |
| Gating instance uploads on "active" leaves stale matrices when scrubbed past | one zeroing upload on the live→dormant edge |
| First-visit shader compile spikes (100–700ms) at first effect activation | `gl.compileAsync(scene, camera)` post-intro (traverses invisible objects) |
| DOM `filter`/`backdrop-filter` composite at FULL devicePixelRatio | the canvas dpr cap doesn't protect you; tier-gate DOM blurs |
| A resident `filter`/`translate` on an ancestor re-anchors `position:fixed` descendants | apply such properties transiently and exclude scenes that own fixed elements |
| ScrollTrigger 'center center' on a grid-centered inner element resolves late, scaling with viewport height | pin the SECTION; single trigger drives pin + tweens |
| Parallel agents in one working tree fight over git checkouts | isolate concurrent agents in worktrees; harvest + merge |
| Background-probe agents may end before probes return | poll-wait for probe output before reporting; orchestrator harvests otherwise |
| `background` shorthand on an element using layered `background-image` silently wipes the layers | set longhand properties only |

## Taste verdicts already adjudicated (don't relitigate)

- Wobble >10% = "blobby hearts". Two nested rim layers = "2 bubbles in 1".
- Overlapping rim lights without compression = "white bright mixture".
- Discrete lattice/dot fields = "retro disco" — use continuous glass light.
- Pale additive discs = ugly; everything circular must be a living bubble.
- A static rainbow border or whole-edge hue-rotate cursor = mood ring, fail.

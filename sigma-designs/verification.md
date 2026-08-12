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
- **Capture VIDEO, not screenshots, for anything that moves.** `page.screenshot()`
  composites beyond the viewport and mis-registers a `position: fixed` canvas
  mid-scroll — it invents black bands and "broken layout" that a real viewer
  never sees. On-screen frame capture (`Page.startScreencast`, or a recorded
  `.webm`) shows the truth. Cost of learning this: a full session spent
  debugging a rendering bug that did not exist.
- **A live debug HUD beats instrumentation after the fact.** Put the rails
  behind `?hud=1` — phase, playhead, camera z, nav state — and publish key
  values on `window` (`window.__progress`). Then a human can confirm a fix by
  looking, and an agent can assert on real numbers instead of pixels.
- **Hook the GL layer to prove initialization order.** Wrapping `getContext`
  and the draw calls, then reading `getUniform` across throttled cold reloads,
  is how you prove a first-frame race — no amount of screenshotting shows which
  frame painted which uniform.
- **Pure rails are the only part tests can really hold.** Every pose, envelope,
  entrance fraction, quantizer decision and playhead mapping is a pure function
  of (state, time): unit-test those exhaustively, and treat the render layer as
  verified only by eye. 400+ passing tests still shipped a washed-out climax and
  a white-out read — see the process rules below.

## What to unit-test when "it looks right" is the requirement

Tests cannot see a canvas, but they can hold far more than fresh agents assume.
Assert PROPERTIES, never rendered values:

| pattern | example assertion |
|---|---|
| **Monotonicity & no overshoot** | "eases to the resting value, monotonic, never exceeds it" |
| **Continuity at a seam** | "starts AT the captured value — no jump on the first frame of the new phase" |
| **Ordering between beats** | "alpha reaches full BEFORE the rise completes"; "the old element exits fully before the new one's entrance threshold" |
| **Reversibility of pure rails** | "scrubbing back to p returns the identical value" — proves the rail is pure in p |
| **Architecture invariants** | "does NOT write the playhead during the other phase" — an ADR encoded as a test |
| **Idempotency & re-entry guards** | "a second call while in flight is a no-op"; "blocks re-entry within the transition duration" |
| **Degenerate input** | "never returns 0/NaN"; "clamps out-of-range phases"; "mismatched lengths give a clean bounded result" |
| **The design language itself** | "nine stops in ramp order"; "every derived colour family stays ON the ring" — the palette is testable |

**Test the DEAD case to lock in a bug class.** The most valuable test in a
migration asserts the failure directly: *"the held playhead never produces a
non-zero merge value, so merge-only effects are dead."* That test is why the
frozen-scrubber class cannot silently return.

**Name regression tests after the defect, and encode its magnitude**: "the OLD
behaviour returned 1 here", "is ~2.65× smaller than the previous half-width".
A regression test that only asserts the fixed value teaches the next reader
nothing about what went wrong.

**Your unit tests will happily agree with your bug.** A pure rail and its tests
are written from the same mental model, so a wrong ASSUMPTION passes green. Two
real examples, both caught only on live hardware: a gate ceiling defined as
"the first gate above the scroll" (a fast lerp overshoots hundreds of px in one
frame, so nothing is above it and a flick sails to the end of the document),
and a release latch armed at the first quiet gap (a mid-gesture hiccup unlocks
it and the rest of the blast passes through). Both had passing tests. Pure-rail
coverage proves your model is self-consistent — never that it matches reality.

### Choosing an input instrument (they are not interchangeable)

| instrument | proves | structurally BLIND to |
|---|---|---|
| synthetic `WheelEvent` via `dispatchEvent` | quantizer/state logic | anything about native scrolling — untrusted events never run default actions, so a missing `preventDefault` is invisible |
| real CDP wheel (`Input.dispatchMouseEvent`) | native-scroll leakage, freeze primitives | cadence — a driver round-trip injects ≥500ms between events, which any idle-gap rule reads as deliberate pauses |
| in-page burst at a fixed ~16ms interval | cadence-sensitive rules (idle gaps, re-arm, release windows) | native default-action behaviour, same as synthetic |

Pick by what you are testing. A freeze bug needs real wheels; a "did the blast
release the gate" bug needs a controlled burst. One project needed both
instruments to verify two consecutive fixes to the same file.

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
| `page.screenshot()` mis-registers a fixed canvas during scroll (invents black bands) | verify motion with screencast/video frames, never scroll screenshots |
| Trackpad momentum tails flip the delta sign; synthetic wheel events are monotonic | inertia bugs are LIVE-HARDWARE-ONLY — a headless suite cannot reproduce them, so budget a real-device pass |
| A smooth-scroll hook returning `false` never `preventDefault`s, so the browser scrolls the document natively underneath | the library's real `stop()` is the only freeze; gate keyboard separately (keys emit no wheel event) |
| A measuring harness's own reload/scripting produces states the app never reaches | reproduce a suspected bug WITHOUT the harness before believing it |
| A material constructed with non-zero uniforms paints one frame before the first frame-loop write | seed uniforms at their true initial values; let frame 1 re-derive them |
| No inline background on the HTML shell → browser-white first paint before CSS arrives | inline `html,body{background:#08070d}` in the document head |
| A dev server running inside a git worktree does not HMR edits made in that worktree | restart, or run the server from the primary tree |
| Feeding an easing library raw wall clock lets a stalled frame consume the whole tween | clamp the fed clock (`Σ min(Δt, 33ms)`) — see navigation-rails.md Law 4 |
| Read-time mutation of shared transition state makes callers disagree within one frame | pure reads; one explicit settle per frame |
| Detecting a quality tier inside an effect is too late — the canvas dpr prop is read at first render | decide the tier at module load, before any component mounts |
| A minimum-size hit target turns a scale-0 element into a live click zone at the wrong place | arm projected targets only past an entrance threshold, and project the element's ACTUAL visual edge (a naive `scale·0.5` ran 2.65× oversized) |
| Projecting a point behind the camera yields valid-looking pixel coordinates | require `ndc.z < 1` and `abs(x), abs(y) ≤ 1` before trusting a projection |
| `getBoundingClientRect`/`offsetWidth` inside a frame callback forces a layout flush every frame | cache the dimension on first non-zero read; content is static after mount |
| Reading `performance.now()` many times per frame gives one frame several timestamps | read ONCE per frame and thread it to every consumer |
| GSAP's default `overwrite: false` accumulates concurrent tweens on a re-fired target | `killTweensOf` first, and kill the stored tween on unmount or it retains the detached element |
| A `return` inside a callback that already queued the next `requestAnimationFrame` at the top still spins forever | schedule the next frame at the END, behind a `stopped` flag |
| Private-browsing `localStorage` throws on WRITE, not just read | try/catch both sides |
| React-three-fiber's `applyProps` shallow-clones every `{value}` uniform holder, so per-frame writes to `.value` never reach the GPU | rebind `material.uniforms` to your live object via a ref callback — without it every tuned number in your shader is inert |
| Canvas texture bloom sampling coarse mips reads past [0,1] and smears at the edge | pad the raster (~26 CSS px/side) and set ClampToEdge on BOTH axes |
| A hand-synced CSS fallback beside a shader palette forks silently | derive canvas/DOM colors from the same `:root` custom properties at runtime |
| Async raster regeneration races itself on resize | monotonic generation counter aborts stale results; dispose replaced textures; start on a transparent 2×2 placeholder so nothing flashes |

## Process rules

- **Separate the OBJECTIVE pass from the FEEL pass.** Machine-verifiable defects
  (double pulses, un-bridged seams, wrong framing, dead effects) get fixed now;
  pacing, weight and warmth wait for the person whose taste owns the piece.
  Shipping a "fix" to a feel question you were not asked to answer is a
  regression even when the diff is correct. Say which bucket each change is in.
- **Gate by re-deriving truth, never by trusting a report.** Before merging work
  you did not do, run the typecheck, the suite and the production build
  YOURSELF, and read the diff for the invariants that matter. An agent reporting
  "all green" is a claim, not evidence.
- **Byte-freeze what an author owns.** Some files carry the emotional payload,
  not just behaviour. Record their hash, re-verify it as a merge gate, and
  revert even behaviourally-inert edits to them. "It's an improvement" is not a
  license to touch a frozen file — defer it for explicit sign-off.
- **Isolated worktree per writing agent, commit after every task.** Concurrent
  agents in one tree fight over checkouts, and a stalled agent loses everything
  uncommitted.
- **A visual pass before merge is mandatory**, and it must happen in a real
  browser at real speed. Green tests have shipped: a washed-out climax, a
  white-out on a camera arrival, and a dead invitation animation.

### Auditing at scale (the method, not the findings)

Parallel readers over N disjoint domains → an INDEPENDENT adversarial verifier
that re-reads each cited line and votes `confirmed` / `likely` / `rejected` /
`intentional` → only confirmed + likely survive. On a real 15-domain run that
filtered 120 raw findings to 101: **~16% of raw agent findings were wrong or
by-design.** Never apply a review's output without the verify pass.

Then partition fixes into FILE-DISJOINT clusters with one controller owning the
single authoritative gate, and record dismissed findings in an appendix so the
next audit does not re-flag them.

Corollary for anyone reading an agent's report: a cited `file:line` is checkable
and a summary is not. Demand the citation, then spot-check the ones that would
change what you build.

## Taste verdicts already adjudicated (don't relitigate)

- Wobble >10% = "blobby hearts". Two nested rim layers = "2 bubbles in 1".
- Overlapping rim lights without compression = "white bright mixture".
- Discrete lattice/dot fields = "retro disco" — use continuous glass light.
- Pale additive discs = ugly; everything circular must be a living bubble.
- A static rainbow border or whole-edge hue-rotate cursor = mood ring, fail.

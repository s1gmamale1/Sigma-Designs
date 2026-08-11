# Motion language & choreography architecture

## Easings

- ALL arrivals: emphasized-decelerate `cubic-bezier(0.05, 0.7, 0.1, 1)`.
  In JS, solve the bezier (5 Newton iterations on x) — don't approximate.
- Exits/accelerations: `cubic-bezier(0.3, 0, 0.8, 0.15)`.
- NEVER overshoot/bounce curves (`1.28`-style y values are a fresh-agent
  tell). Landing = a cosine settle of a ≤2% overshoot: arriving, not bouncing.
- **SINGLE EASE.** Rails return RAW LINEAR fractions; exactly ONE consumer
  eases. `emphDecel(emphDecel(t))` front-loads twice — an element that measures
  perfectly smooth still arrives ~0.56 ahead of the camera it should track.
  If the pose eases, the rail feeding it returns `(now−start)/duration` clamped.
- Apple owns the surface, Google (M3 Expressive) owns the motion.

## Envelope shapes (the difference between alive and mechanical)

- **Pulse/flare**: asymmetric gaussian — rise σ ≈ 0.13s, decay σ ≈ 0.30s.
  Symmetric sines/cosines read as breathing machinery; sharp-rise/soft-decay
  reads as a living flare.
- **Event-synced periodic envelopes**: re-anchor the phase so a peak lands
  ~1.2s after the user's event, and CROSSFADE old→new phase over ~0.35s — a
  hard phase switch pops mid-cycle.
- **Multi-element entrance**: stagger ramps (`sin²` of the per-item ramp gives
  each item a flash at its own moment). Two grounded recipes — 3D objects
  cascading into place: 1.6s each, 0.12s between starts. DOM text condensing
  per letter: a 1.3s entrance with 45% of it spent as stagger spread, each
  letter eased individually off a LINEAR shared rail. Derive per-letter order
  from a deterministic hash sort, not `Math.random()`, or the scatter differs
  on every load and cannot be reviewed.
- Periods across the system: 2–6s, incommensurate, mixed directions. One
  global tempo = mechanical.

## Architecture: rails and shared refs

One canvas, one scroll, one protagonist element that NEVER unmounts.

- **Shared mutable refs, never per-frame React state**: `progress` (scroll
  scrub 0..1), `pointer` (lerped), window publishers. Visuals AND audio read
  the same refs in their frame loops — sync by construction.
- **Choreography = pure functions of the rail**: `paramsAt(progress)` returns
  every story parameter; a time rail `phase(nowSec)` for non-scroll beats
  (intros) that flips to a frozen identity when done so scroll choreography
  is untouched after. Pure functions ⇒ unit-testable beats.
- Keep beats modular: never couple a new effect exclusively to the scroll
  library — drive it from the shared refs so click/time/gesture rails can
  reuse it. The rail that drives a story WILL change; effects coupled to the
  library instead of the ref all die at once when it does.
- **Choosing the rail: entrances are TIME-based, journeys stay scrubbed.**
  Ceremonies, entrances, births, merges and cutscenes run on wall clock
  (`performance.now()/1000`) so they feel identical at any input speed and a
  fast gesture cannot snap them. Only the reader's journey through the story is
  scrubbed. Rails outside the render loop must use wall clock, not the
  renderer's clock — its origin is canvas mount, not page load.
- Who writes the playhead, how input is quantized, and how to switch rails
  without a seam: see navigation-rails.md. Do not free-scrub a story you want
  read — see Law 3 there.

## Scroll pins (the trap that bit twice)

GSAP ScrollTrigger `start: 'center center'` on a grid-centered INNER element
resolves offset from its live visual center, error scales with viewport
height (−244px @800h → −568px @1440h): the element drifts past center, then
"teleports" when the pin engages. **Pin the full-height SECTION, and drive
any scrubbed tween from that same single trigger** (no second 'center
center' to resolve differently). Publish the pin's real progress span from
`onRefresh` (`self.start/maxScroll`) into a shared ref so camera moves and
DOM dissolves stay aligned at any viewport.

## Entrance grammar

Things are BORN INSIDE the world, they don't arrive from offscreen:
- Bubbles condense (scale-bloom + rim flash), never fade in as discs.
- Text rises from within the vessel through a silhouette mask.
- Background lights bloom from black, gated by the intro rail.
- A held-breath gate (dimmed scene, one small living element) → user gesture
  → melt the veil SLOWLY (~1.5s, fading a backdrop-filter overlay melts its
  blur with it) → one breath → flash → expand (emph-decel, ≤2% overshoot
  cosine-settled) → text → world wakes (~1.4s window).

## Performance discipline

- Allocation-free frame paths: reuse snapshot objects (swap pairs), integrate
  angles instead of deriving from absolute time, scratch Color/Vector pools,
  index loops instead of `[1,2,3,4].forEach` in a hot path.
- **Clamp every accumulated clock**: `acc += Math.min(delta, 0.1)` for
  rotations, `Σ min(Δt, 33ms)` for any tween you drive by hand. Raw wall clock
  makes a stalled frame or a returning background tab TELEPORT the animation
  (full derivation in navigation-rails.md, Law 4).
- Gate GPU instance uploads when dormant + one zeroing upload on the
  live→dormant edge (else stale matrices ghost).
- Pre-compile all scene materials right after the intro gate
  (`gl.compileAsync(scene, camera)` — traverses invisible objects too):
  first-scroll shader-compile spikes (100–700ms) are the #1 perceived jank.
- Cap canvas dpr ([1, 1.75]); remember DOM filters don't obey that cap.
- A quality watchdog must shed REAL load (dpr → [1, 1.25], drop DOM blur
  layers, cheap billboards instead of spheres), not decorative counts — and add
  a `?tier=` URL override for testing.
- Tier decision is PURE and boot-time only (`deviceMemory ≤ 4` → lite; coarse
  pointer + ≤6GB + dpr ≥ 2.5 → lite), evaluated at module load so the first
  render already sees it. No runtime thrash, and lite never auto-promotes.
- Runtime watchdog: learn the display's baseline frame time over ~60 samples
  (clamped 4–50ms), then demote after 90 frames slower than 1.8× baseline
  (`slow++` on a slow frame, `slow -= 2` on a fast one, so a single hitch never
  demotes). Unregister the ticker once demoted.
- Shedding load must be REAL: drop the DOM filter layer entirely (it ignores the
  canvas dpr cap, so scaling it does nothing), halve text-raster scale, branch
  off the expensive shader terms, swap meshes for billboards. When you do reduce
  a count, keep the buffer allocated at the HIGH count and lower `mesh.count`,
  so a mid-session tier flip needs no reallocation.
- **Reduced motion substitutes a whole PATH, not a setting**: a CSS fallback
  element instead of the canvas, the ceremony skipped so downstream gates fire
  from frame 0, and effects whose only consumer is unmounted never registered at
  all. Re-key those effects on the preference so an OS-level flip tears them
  down. Subscribe with `useSyncExternalStore` over a MODULE-HOISTED media query
  with stable `subscribe`/`getSnapshot` — a fresh closure per render
  re-subscribes the listener every render.
- **Two error boundaries, because they catch different things.** A React
  boundary catches render throws — give it a dependency-free, inline-styled
  fallback, since it cannot rely on the failed tree's CSS. WebGL context loss is
  an EVENT, not a throw, so no boundary ever sees it: `preventDefault()` to
  allow restoration, wait a short grace period, then swap to the fallback.
- Perpetual poll loop vs event-driven teardown: keep the perpetual loop only if
  its settled path does ZERO DOM writes and ZERO allocations. Adopt teardown
  only when you can enumerate EVERY re-activation signal — a re-arm that misses
  one leaves the effect dead forever, which is worse than a cheap idle loop.

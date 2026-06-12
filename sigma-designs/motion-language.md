# Motion language & choreography architecture

## Easings

- ALL arrivals: emphasized-decelerate `cubic-bezier(0.05, 0.7, 0.1, 1)`.
  In JS, solve the bezier (5 Newton iterations on x) — don't approximate.
- Exits/accelerations: `cubic-bezier(0.3, 0, 0.8, 0.15)`.
- NEVER overshoot/bounce curves (`1.28`-style y values are a fresh-agent
  tell). Landing = a cosine settle of a ≤2% overshoot: arriving, not bouncing.
- Apple owns the surface, Google (M3 Expressive) owns the motion.

## Envelope shapes (the difference between alive and mechanical)

- **Pulse/flare**: asymmetric gaussian — rise σ ≈ 0.13s, decay σ ≈ 0.30s.
  Symmetric sines/cosines read as breathing machinery; sharp-rise/soft-decay
  reads as a living flare.
- **Event-synced periodic envelopes**: re-anchor the phase so a peak lands
  ~1.2s after the user's event, and CROSSFADE old→new phase over ~0.35s — a
  hard phase switch pops mid-cycle.
- **Multi-element entrance**: stagger ramps (`sin²` of the per-item ramp
  gives each item a flash at its own moment); spread entries across ~1.2s,
  each item ~0.9s emphasized-decelerate from its own direction.
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
  reuse it.
- Scroll feel: smooth scrub (Lenis-style lerp ~0.05, wheel ×0.55) with
  velocity clamp. NO scroll-snap — snapping breaks cinematic scrub.

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
  angles instead of deriving from absolute time, scratch Color/Vector pools.
- Gate GPU instance uploads when dormant + one zeroing upload on the
  live→dormant edge (else stale matrices ghost).
- Pre-compile all scene materials right after the intro gate
  (`gl.compileAsync(scene, camera)` — traverses invisible objects too):
  first-scroll shader-compile spikes (100–700ms) are the #1 perceived jank.
- Cap canvas dpr ([1, 1.75]); remember DOM filters don't obey that cap.
- A quality watchdog must shed REAL load (dpr → 1.25, drop DOM blur layers),
  not decorative counts — and add a `?tier=` URL override for testing.

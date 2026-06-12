# The Living Orb — full recipe

A glassy soap-bubble sphere that self-animates. Three.js/GLSL reference; the
numbers port to any renderer.

## 1. Silhouette (never a perfect circle)

Vertex displacement: 4 summed low-frequency sin lobes along the normal,
**total amplitude ≤10% of radius** (more reads as "blobby hearts" — verified
failure at ±19%). Periods 2.2–5s, incommensurate, so the morph never loops
visibly. Recompute normals by finite difference (displace 2 tangent
neighbors, cross product) — smoothness beats exactness.

```glsl
float lobe(vec3 p, float t) {
  return 0.030*sin(1.7*p.y + t*2.86) + 0.026*sin(2.3*p.x - t*1.95)
       + 0.022*sin(2.9*p.z + t*1.51) + 0.018*sin(1.3*(p.x+p.y) - t*1.26);
} // ≈ ±9.6% total; t in seconds
```

Geometry: sphere 128×128 at hero scale (64×64 fine on weaker tiers),
DoubleSide if a camera ever dives through.

## 2. The four rim lights (the signature)

Four independent hotspots sliding along the silhouette edge. Each has its own
angular speed (mixed directions!), pulse period, width, hue, and whiteness.
Integrate angles in JS per frame (`angle += ω·dt`) and pass as a vec4 uniform
— do NOT derive from absolute time, so speed changes never snap.

| param | values | meaning |
|---|---|---|
| ω (rad/s) | 0.52, −0.69, 0.83, −0.47 | slide speeds — slow, mixed direction |
| pulse period (s) | 2.8, 3.8, 3.2, 4.6 | intensity breathing, offset phases (0, 2.1, 4.0, 1.2) |
| width σ | 0.16 + 0.55·I | width breathes WITH intensity I |
| hue (ramp t) | 0.444, 0.0, 0.333, 0.556 | rose, amber, coral, violet on the 9-stop ramp |
| white at peak | 0.55, 0.20, 0.12, 0.08 | only ONE light goes white-hot, capped |
| hue drift (cycles/s) | 0.011, −0.008, 0.009, −0.012 | barely-perceptible color wander |

Per fragment: rim factor = fresnel-ish edge mask; for each light, gaussian in
angular distance `exp(-Δθ²/2σ²)` × pulse intensity × palette(hue). Then the
two anti-blowout rules: compress overlaps `hot /= 1 + 0.85·max(Σ−1, 0)` and
cap whiteness. Story moments may slow ω (×0.2) and converge all four toward
one point — "the lights become one" (merge/union beats).

## 3. Interior

Near-black glass `vec3(0.014, 0.012, 0.022)` (linear ≈ `#040306`–`#06050a` in
hex — NOT rgb(14,12,22), a common misconversion) — blue-violet cast, never #000.
A DIM aurora drifts inside (4 gaussian color blobs, amplitude ~0.42, same
palette) — visible at a glance, never competing with the rim. Add 1/255
hash dither to kill banding. One sheen band, no second shell layer (two
nested rims read as "2 bubbles in 1" — verified author rejection).

## 4. Presence lights (optional story element)

Soft colored glows inside (e.g. azure `#67a7ff` / coral `#ff646a` as paired accents):
gaussian-profile sprites, peak alpha ≈0.74, falloff like
`pow(dot(n,v), k)` softened — they must read as LIGHT, not pale discs
(hard-edged additive circles are a verified failure).

## 5. Eruption flares (idle drama)

Periodic brightness flares on the rim: period ~2.8s, **asymmetric gaussian**
(rise σ 0.13s, decay σ 0.30s). At peak: hotspot intensity ×1.9 + slight halo
widening. To sync a flare to a user event, RE-ANCHOR the phase so a peak
lands ~1.2s after the event and crossfade old→new phase over 0.35s (hard
switches pop mid-flare). After a "settling" story beat, hard-zero the flares
— strain → peace contrast.

## 6. Mini-bubbles (background field / accents)

Same language at thumbnail scale: irregular wobbling silhouette, thin
iridescent rim with 1–2 drifting glints, soft outward halo, near-transparent
interior, per-instance hue from the palette. Pop-in = scale-bloom on
emphasized-decelerate + brief rim flash (`sin²` of the stagger ramp) — NEVER
an opacity-fade of a solid disc. Instanced mesh; gate the GPU matrix upload
when dormant, and push ONE zeroing upload on the live→dormant edge or stale
mid-pop matrices ghost on screen after scroll jumps.

## 7. The cursor as a chip of the bubble

Normal arrow SVG (~21–24px, macOS proportions), TIP-anchored to the pointer
coordinate. Interior: glass gradient `#0b0916 → #050409`. Edge: palette
gradient stroke (1.5–2px) whose gradientTransform ROTATES (SMIL/CSS) at one
of the rim omegas (0.5 rad/s ⇒ 12.57s/rev) + slow stop-color drift — a
highlight that travels the outline. Hover: halo bloom + crossfade to an
always-running 2× twin gradient (SMIL can't retime `dur` without snapping).
Velocity tilt ±8° pivoting at the TIP. Hide only under
`(pointer:fine) and (prefers-reduced-motion: no-preference)`.

# The Living Orb — full recipe

A glassy soap-bubble sphere that self-animates. Three.js/GLSL reference; the
numbers port to any renderer.

## 1. Silhouette (never a perfect circle)

Vertex displacement: 4 summed low-frequency sin lobes along the normal,
**total amplitude ≤10% of radius** (more reads as "blobby hearts" — verified
failure at ±19%). Periods 2.2–5s, incommensurate, so the morph never loops
visibly. Recompute normals by finite difference (displace 2 tangent
neighbors, cross product) — smoothness beats exactness.

Each lobe must mix TWO axes and carry its own phase offset — single-axis lobes
(`sin(1.7*p.y + …)`) produce visible bilateral symmetry that reads as a
breathing balloon rather than a bubble.

```glsl
float bubbleDisp(vec3 p, float t) {           // p = normalize(position)
  return 0.032 * sin(1.7 * p.x + 1.1 * p.y + t * 1.45)
       + 0.026 * sin(2.3 * p.y - 1.5 * p.z - t * 1.90 + 2.1)
       + 0.021 * sin(2.0 * p.z + 1.3 * p.x + t * 2.40 + 4.4)
       + 0.013 * sin(2.8 * (p.x + p.y + p.z) - t * 2.85 + 1.0);
}                                              // Σ = 0.092 → ±9.2% of radius
```

Time coefficients 1.45–2.85 rad/s (periods ≈2.2–4.3s), incommensurate, mixed
directions — a visibly different lumpy shape every fraction of a second.

Normals by finite difference: displace two tangent neighbours at ε = 0.12,
cross the deltas, and **flip the result if `dot(n, p) < 0`** — without the sign
guard, patches of the surface light inside-out.

```glsl
vec3 t1 = normalize(abs(p.y) < 0.99 ? cross(p, vec3(0,1,0)) : cross(p, vec3(1,0,0)));
vec3 t2 = cross(p, t1);
// Pa/Pb = displaced neighbours; nrm = normalize(cross(Pa-P, Pb-P))
```

**Publish the deformation phase to the fragment stage** (`vWob = clamp(d0/0.092,
-1, 1)`) and let it modulate rim thickness. Shape and light then read as ONE
event — the bubble is brightest where it is being stretched — instead of two
unrelated animations sharing a mesh.

Geometry: sphere 128×128 at hero scale, 40×40 for thumbnail copies, DoubleSide
if a camera ever dives through. Do NOT reach for a lower segment count as a
quality lever — the segments are not the cost. Swap the MESH TYPE instead
(instanced billboard quads) and keep the sphere resolution fixed.

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

Per fragment: `f = 1 − |dot(n,v)|` (fresnel-ish edge mask); for each light,
gaussian in wrapped angular distance `exp(-Δθ²/2σ²)` × intensity × palette(hue).
Wrap the delta with `d = atan(sin(d), cos(d))` or a light crossing the ±π seam
blinks out.

Whiteness enters as `mix(c, vec3(1.0), white[i] · I²)` — the I² keeps a light
saturated through its mid-range and lets only its true peak go hot.

Two bands, not one:

```glsl
float wobT = 0.5 + 0.5 * vWob;                             // deformation phase
float band = smoothstep(mix(0.72, 0.30, lit) - 0.05*wobT, 0.85, f);
float edge = pow(f, 8.0 - 3.0 * uEruption);                // thin persistent rim
vec3 rim = baseCol * edge * 0.60          // the silhouette NEVER vanishes
         + (baseCol * 0.18 + hotCol * 2.1) * band          // lit arcs: thick + bright
         + hotCol * edge * 1.5;                            // grazing edge takes the hot hue
```

`band` gives ~1–2% of radius everywhere, swelling to ~8–12% where an arc is
bright: thick-when-bright, razor-thin-when-dim. `edge` is the always-present
hairline — drop it and the orb loses its outline whenever the lights are dim.

Anti-blowout rules, both required: compress overlaps
`hotCol /= 1 + 0.85·max(Σ−1, 0)` (crossing arcs must BLEND hue, not clip white),
and cap per-light whiteness (only one light peaks white, at 0.55).

Under the dim rim, keep a faint two-sample base flow so even an unlit edge
carries colour: `mix(palette(a01 + t·0.045), palette(0.33 − a01·0.5 + t·0.018),
0.22)`, biased toward a warm target as a narrative warms (`mix(base, warm,
0.38·warmth)`).

Story moments may slow ω (×0.2) and converge all four toward one point — "the
lights become one" (merge/union beats).

## 3. Interior

Near-black glass `vec3(0.014, 0.012, 0.022)` — blue-violet cast, never #000.
These are authored sRGB floats with no linearization: multiply by 255 to read
them (`≈ #040306`). The common misconversion is `rgb(14, 12, 22)`, which is
four times too bright.

A DIM aurora drifts inside: 4 gaussian blobs, amplitude 0.42, centres on slow
**Lissajous paths** (`sin(t·0.21+i·2.1)`, `cos(t·0.17+i·1.3)`, `sin(t·0.13+i·4.2)`,
scaled 0.58) so they wander without ever looping visibly. The whole field
breathes its falloff — `exp(-d²·(3.3/breath))`, `breath = 1 + 0.07·sin(t·0.9)`.
Visible at a glance, never competing with the rim.

Four finishing moves, each load-bearing:

```glsl
aur *= (0.7 + 0.6*vnoise(vPos*2.6 + vec3(0, t*0.1, t*0.14))) * interior * uGlow;
float lum = dot(aur, vec3(0.299, 0.587, 0.114));
aur = max(mix(vec3(lum), aur, 1.45), 0.0);          // saturation push — hue must
                                                     // read at low luminance
vec3 body = GLASS + aur;
body += sheenCol * 0.10 * smoothstep(0.12, 0.72, f) * uGlow;  // light wrapping inside
body = 1.0 - exp(-body * 1.5);                       // SOFT TONE-MAP, not clamp
body += (hash(vec3(gl_FragCoord.xy, t)) - 0.5) / 255.0;       // dither vs banding
```

The tone-map is what keeps bright moments from turning into white plastic —
clamping instead produces flat blown regions. Saturation-lift BEFORE it (1.45
here; 1.35 for recoloured text plates) or the interior reads muddy grey.

One sheen band, no second shell layer (two nested rims read as "2 bubbles in 1"
— verified author rejection).

## 3b. Living shimmer (whole-sphere glitter)

A directional band sweeps the sphere and carries fine glitter in the rim's own
palette — the rim language washing across the whole surface, dim and patient:

```glsl
float wproj = dot(normalize(vPos.xy), uShimmer.xy) * 0.5 + 0.5;
float wband = exp(-pow(wproj - uShimmer.z, 2.0) / (2.0 * 0.045)) * uShimmer.w;
float grain = vnoise(vPos * 52.0 + vec3(0, 0, t * 0.55));    // 3D value noise
float sparkle = pow(grain, 5.0) * (0.7 + 0.3*sin(t*3.0 + grain*18.0));
col *= 1.0 + 0.18 * wband;
col += wband * sparkle * palette(a01 + uDrift) * 0.85;
```

Use smooth 3D value noise, **never square hash cells** — a per-pixel hash reads
as digital noise/dirt, not glitter. Gate `sparkle` off entirely on a lite tier
(`pow(grain,5)` is the expensive part); the band alone still carries the sweep.

## 4. Presence lights (optional story element)

Soft colored glows inside (e.g. azure `#67a7ff` / coral `#ff646a` as paired
accents): gaussian-profile sprites, peak alpha ≈0.74.

```glsl
float d = abs(dot(n, v));
float e = 1.0 - d;
float core = 0.62 * exp(-7.0 * e * e) + 0.12 * d * d;   // tight core + faint wide breath
```

**Do NOT use `pow(dot(n,v), k)`** — that is the verified failure. `pow(d, 1.6)`
holds ~60% alpha across most of the silhouette and reads as a solid pale DISC
at the screen edge. The exponential form falls off well before the rim; the
small `0.12·d²` term is the faint bleed that keeps it from looking cut out.
They must read as LIGHT, not discs.

## 5. Eruption flares (idle drama)

Periodic brightness flares on the rim: period ~2.8s, **asymmetric gaussian**
(rise σ 0.13s, decay σ 0.30s). At peak: hotspot intensity ×1.9 + slight halo
widening. To sync a flare to a user event, RE-ANCHOR the phase so a peak
lands ~1.2s after the event and crossfade old→new phase over 0.35s (hard
switches pop mid-flare). After a "settling" story beat, hard-zero the flares
— strain → peace contrast.

## 6. Mini-bubbles (in-scene accents, thumbnail copies)

Same language at thumbnail scale: irregular wobbling silhouette, thin
iridescent rim with 1–2 drifting glints, soft outward halo, near-transparent
interior, per-instance hue from the palette. Pop-in = scale-bloom on
emphasized-decelerate + brief rim flash (`sin²` of the stagger ramp) — NEVER
an opacity-fade of a solid disc.

Dormancy differs by tier, and conflating them is a bug:
- **Cheap tier — instanced billboards.** Gate the GPU matrix upload when
  dormant, and push ONE zeroing upload on the live→dormant edge or stale
  mid-pop matrices ghost on screen after a jump. Getting that drain frame out
  requires holding "was live last frame" in the liveness predicate, so the
  zeroing upload reaches the GPU BEFORE `visible = false`.
- **Hero tier — individual meshes running the hero material.** Dormancy is just
  `mesh.visible`. Keep them MOUNTED so the shader warm-up compile reaches them.

Promote accent bubbles to **mini versions of the hero orb** (same VERT/FRAG,
one tint each) rather than plain discs — one shader, and they inherit every
behaviour above for free.

## 6b. An orbiting set (necklace / satellites)

A ring of elements around the hero needs three things fresh agents miss:

- **Ellipse, not circle.** A viewport is wider than tall, so a circular orbit at
  a radius clear of the hero's halo pushes the top/bottom members off-screen.
  Squash vertically (`ORBIT_R` across, ×0.6 up/down) and rotate the whole ring
  slowly (0.12 rad/s).
- **One birth envelope, driven by wall clock.** The pose function that grows a
  member from the core (radius 0→orbit, scale 0→full, `sin²` flash) is the SAME
  one used for its entrance; it only needs a 0→1 input. Feed it
  `birthFraction(now, birthAt)` over 1.6s with a 0.12s per-member cascade
  stagger, in place of a static 1. Feed it RAW LINEAR — the pose owns the ease.
- **Birth ONCE, then latch.** A permanent `appeared[]` flag per member. Without
  it, settled members re-animate whenever the camera returns, and one member's
  entrance disturbs its neighbours. Members that arrived by some other glide
  must be latched too — that glide WAS their entrance.

**Interaction must wait for the entrance.** A member born at the core sits at
scale ≈ 0 under a minimum-size hit target, so an invisible ~18px click zone
covers the hero for the whole birth — clicking it snaps the in-flight element
to centre. Arm hit targets only once the birth is essentially settled
(`birthF ≥ 0.65`). Project hit targets from the SAME radius function the mesh
renders with, so the clickable edge always matches the drawn edge.

## 7. The cursor as a chip of the bubble

Normal arrow SVG (~21px tall in a 20×25 viewBox, macOS proportions),
TIP-anchored: put the tip at `(1.5, 1.5)` inside the viewBox and offset the
element by `-TIP`, so the pointer coordinate and the drawn tip coincide exactly.

| part | recipe |
|---|---|
| interior | linear gradient `#0b0916 → #050409` (the orb's glass, lifted at the tip — never flat #000) |
| edge | 3-stop palette ramp stroke, `stroke-width: 1.7`, `stroke-linejoin: round` |
| ramp rotation | `animateTransform` rotate 0→360 over **12.57s** (= 0.5 rad/s, one of the rim omegas) about the arrow centroid |
| hue drift | each stop cycles 3 palette colours over **45s** — the dominant colour breathes |
| traveling highlight | a second path stroked with a near-white gradient whose stops sit at 0.55/0.8/1.0 (transparent → 0.95 → transparent), same rotation |
| hover | halo opacity → 0.55; crossfade to an always-running 2× twin (6.28s) — SMIL cannot retime `dur` without snapping |
| tilt | `clamp(vx · 0.9, ±8°)`, `transform-origin: 0 0` so it pivots at the TIP |

Follow with a lerp of 0.35 per frame (the same `vx` feeds the tilt, so the lean
IS the velocity), hover state lerped at 0.18. Probe hover with
`document.elementFromPoint(...).closest('a, button, [role="button"]')` every
8th frame (~8×/s) — it catches content scrolling under a stationary pointer,
which `mouseenter` never fires for, and it skips the cursor itself as long as
the cursor layer is `pointer-events: none`.

Keep it invisible until the pointer actually MOVES (an unmoved cursor drawn at
a guessed centre is a phantom).

Render nothing at all under reduced motion or a coarse pointer — returning null
also stops the SMIL animations, which otherwise keep running while hidden.
Subscribe to `(pointer: fine)` with `useSyncExternalStore` rather than reading
it once at mount: a `useState` lazy initializer is frozen, so plugging in a
mouse mid-session never brings the cursor back.

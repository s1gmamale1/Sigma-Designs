# Atmosphere — palette, backgrounds, glass, in-bubble text

## The palette (the only colors)

9-stop ramp, warm→cool. Sample it as a closed ring for rims/gradients;
fresh agents invent cool purples (`#b48eff`-family) — that is NOT this
language. This ramp leans WARM (amber/coral/rose carry it).

```
#ff9a0f  #e9922b  #ff8578  #ff646a  #ef638a  #bc82f3  #8186c7  #67a7ff  #98aeea
amber    burnt    salmon   coral    rose     violet   peri     azure    light-peri
```

Accent pair: azure `#67a7ff` · coral `#ff646a` (dual presence lights) ·
warmth-bias target `#ff7a8c` (pull rims/aurora toward it as a narrative warms).

**One shared ring drift, added to EVERY palette lookup** — shell, text plates,
accents and background alike (`drift = (now % 16) / 16`; ~16s per turn, retuned
down from 45s as "too long to notice"). Per-element drift rides on top of it.

This is a ring ROTATION, not the whole-edge hue-rotate the law of the rim
forbids: every element's hue moves together and their relative spacing is
preserved, so the palette breathes while the colour RELATIONSHIPS hold. A mood
ring is one element cycling through hues on its own. Note that a DOM element
animating its own stops (a cursor gradient, say) is on a separate clock and
will visibly diverge — either share the constant or accept the divergence
knowingly.

Sample the ring with `smoothstep` between stops, not linear interpolation, in
every consumer — CPU and GPU — or the CPU-sampled colours drift from the
shader-sampled ones.

## The background field

4 large soft gaussian blooms over a near-black base, blanketing the frame.
Exact shipped values — centers `(0.22a, 0.86) (0.99a, 0.55) (0.78a, 0.02)
(0.01a, 0.30)` where `a` = aspect, **σ = 0.58 / 0.54 / 0.56 / 0.58**,
amplitudes `[0.88, 0.66, 0.78, 0.51]`, drifting on incommensurate periods
70 / 55 / 90 / 62 s.

A narrow-σ variant (~0.3) keeps the corners velvet-dark for a more mysterious
"blooms on velvet" read — but note the wide version is what survived author
review; the narrow one drew "background still pitch black, no gradient".

- **Aspect-correct BOTH the sample point and every centre** (`uv.x·aspect`, and
  the centres too) or the blooms go elliptical and slide on resize.
- Centres travel a Lissajous, not a circle: `c += 0.08·vec2(sin(ωt + i·1.7),
  cos(0.7·ωt + i·1.7))` — the y term at 0.7× the x frequency.
- Two independent noises, both needed: a WARP of the sample point BEFORE the
  blooms (`uv += (noise2oct(uv·1.6 + 0.02t) − 0.5)·0.18`) and a cloud GAIN
  modulation after (`×(0.85 + 0.30·noise)`).
- A dim vertical floor wash (`0.16 · mix(coolA, coolB, uv.y)`) so NO pixel is
  pure black.
- Warmth crossfade (cool set → warm set) as the story warms; pointer parallax
  `uv += pointer * 0.03`; ALWAYS dither (`(hash(px)-0.5)/255`).
- Soft-clip blooms `aur /= 1 + 0.8·aur` so text stays brightest.

**Order of operations is load-bearing**: blooms → cloud gain → intro gate →
soft-clip → floor wash → base → dither → **visibility gate LAST**. Multiplying
the master visibility AFTER the dither is what makes a black frame exactly 0;
gate before dither and a "pure black" screen keeps ±1/255 of noise.

Draw the field as a full-screen quad at `gl_Position.z = 0.9999` with
depthTest/depthWrite off and a negative renderOrder — far-background by
construction, immune to any camera dolly.

**Colour parity with the rim:** re-sample the background bloom colours from the
SAME palette ring, at the same shared drift phase, into pre-allocated scratch
colours each frame. Background and rim then cannot drift apart.

## Glass rules

- Liquid glass needs a multi-hue living backdrop behind it or it collapses
  to gray. Never put glass on flat color.
- Glass fills: `rgba(18,18,22,0.62)` + 1px `rgba(255,255,255,0.12)` border +
  `backdrop-filter: blur(18px) saturate(160%)` — but know the cost: DOM
  backdrop-filters composite at FULL devicePixelRatio (uncapped, unlike a
  dpr-capped canvas). Budget them; shed them on a lite tier.
- **That recipe is for incidental chrome, not primary controls.** Over a living
  orb, 0.62 alpha with an 18px blur lets the lit background through and the
  control reads as a *blurry button*. Primary actions want near-opacity and
  almost no blur: `rgba(20,20,27,0.9)` + `blur(3px) saturate(125%)`. Legibility
  beats the glass effect wherever a user must click.
- CSS easings tokens: emphasized-decelerate `cubic-bezier(0.05,0.7,0.1,1)`,
  emphasized-accelerate `cubic-bezier(0.3,0,0.8,0.15)`, standard
  `cubic-bezier(0.2,0,0,1)`. No overshoot/bounce curves — arrive, don't bounce.

## Text inside a bubble (the in-orb treatment)

Text that must feel INSIDE glass cannot be filtered DOM — render it in-scene:

1. Rasterize the copy (canvas2D → texture) at min(dpr, 1.75). Await
   `document.fonts.load()` for the EXACT faces first — `fonts.ready` alone
   races lazily-loaded webfonts. Debounce resize regeneration (~300ms).
2. Plate parented INSIDE the bubble's transform — inherits every drift/
   scale/story movement for free. Add catch-up lag as FRAMERATE-INDEPENDENT
   exponential smoothing — `k = 1 − exp(−rate·min(dt, 0.1))` at rate ≈ 7/s
   (≈0.11 per 60fps frame), never a fixed per-frame lerp constant — plus a
   faint echo of the wobble: floats in the liquid, not painted on it.
3. Shader: fisheye that **magnifies the CENTRE and is identity at the rim**
   (`ns = n · mix(1 − fish, 1, r²)`, fish ≈ 0.3; drop to ~0.1 for a long calm
   sentence). Not the reverse — distorting toward the shell bows the text the
   wrong way. Plus a slight chromatic split, subtle rim-palette tint pickup
   applied only near the shell (`weight = tintAmt · smoothstep(0.42, 1, r²)`,
   tintAmt ≈ 0.22 on a recoloured hero plate, ~0.55 on ordinary copy), and a
   silhouette mask — discard past r 0.88 AND fade with
   `smoothstep(0.88, 0.82, r)`, since a hard cut alone leaves a visible edge.
   "Text never appears outside the glass" enforced by construction, not
   animation discipline.
4. Entrances rise from the bubble's FLOOR (local y ≈ −0.7 → rest) on
   emphasized-decelerate, emerging through the mask clip.
5. Keep the real DOM text in layout but veiled (`opacity:0`, never
   `display:none`) — scroll geometry, pins, and screen readers intact.
   Reduced-motion: skip the plates, show the DOM text.

### A living word — rotating RGB fill + glowing edge (like the shell)

To make a hero word carry the SAME living light as the orb — a rotating RGB
gradient with glowing edges — the color must live in the SHADER, not the
raster. A baked canvas gradient is frozen; it cannot rotate.

1. **Rasterize the glyphs as a plain WHITE coverage mask** — no baked color.
   Bump this plate's raster scale ~1.6× (the fisheye magnifies the center;
   an under-res mask turns to jaggies). The shader recolors it live.
2. **Rotating fill:** sample the shared 9-stop palette as a closed ring by the
   texel's conic angle about the word center, `palette(atan2(uv−0.5)/2π +
   t·spin)`. Calm spin 0.07 rev/s (a full turn every ~14s; never strobe).
   **Saturation-lift the ramp** (`mix(luma, c, 1.35)`) — flat ramp values read
   muddy; the word must look like EMITTED light (the shell does this to its
   interior aurora).
3. **Glowing edge = a MIP-chain bloom, never a hand-rolled ring of taps.** A
   few coverage taps over a wide radius step into chunky colored petals (reads
   as "low-poly / blurry pixels", NOT a glow). Instead blend a few coarse,
   pre-filtered mip levels of the mask — hardware trilinear is smooth by
   construction: `bloom = Σ texture(mask, uv, bias_k·{2,3.5,5})·{.42,.34,.24}`;
   `halo = max(bloom − 0.5·core, 0)`. Generate the full mip chain explicitly
   on the plate texture (NPOT is fine on WebGL2). Breathe the halo on a
   rim-light cadence (~4.6s) and let the edge hue LEAD the fill by +0.08 on the
   ramp — same colour family, one step ahead, so the edge reads as emission
   rather than an outline.
4. **Kill the chromatic split on THIS plate.** The generic in-orb refraction
   (step 3 above) samples the white mask at offsets → ghosted/doubled glyph
   edges (more "pixelated" artifact). A recolored mask owns its own look; set
   its chroma to 0. Likewise keep its glass rim-tint pickup LOW (~0.2) so the
   rotating RGB stays vivid instead of being dulled toward the shell hue.
5. **Reuse the shell's own wobble frequencies** for the plate's liquid echo
   (the same 1.45 / 1.90 rad/s time coefficients the silhouette uses). Invented
   frequencies desynchronise the text from the glass it floats in.
6. A **mip-bias uniform** (0..~4) is the cheapest focus-in / dissolve you have:
   ramp it down as the plate arrives and up as it leaves. Blur by mip bias, not
   by a blur kernel — it costs nothing and matches the bloom's filtering.

## Script accents

A script face (e.g. Parisienne) for emotional spans only, inked with a
linear palette gradient (`background-clip: text`). Script faces carry a much
smaller x-height per em than sans, so they must be sized **UP** to read as the
same size — 1.35× the sans px, with `line-height: 1` and a little
`padding-right` (~0.08em) for overflowing terminal strokes. Inline-mark spans
in copy (`{{…}}`) and parse, so authors write plain text.

Build the gradient PER WORD, not per line — a short diagonal spanning that
word (`x → x + wordWidth`, `baseline − 0.55·px → baseline + 0.15·px`), or long
lines wash out to a single flat hue.

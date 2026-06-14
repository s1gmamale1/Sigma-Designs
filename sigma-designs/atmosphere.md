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

## Two background modes (pick per mood, both live)

1. **Blooms on velvet** (mystery): base `#08070d`, 4 LARGE soft gaussian
   blooms anchored around the focal element (σ 0.27–0.30 viewport-ish),
   amplitudes ~0.5–0.9, drifting on slow incommensurate periods (55–90s).
   Corners stay velvet-dark. Color = spilled light, never a wash.
2. **Full gradient atmosphere** (Siri/marketing): same 4 lobes but σ ~2×
   wider, centers pushed outward so they blanket the frame; add a dim
   vertical floor wash (`0.16 · mix(coolA, coolB, uv.y)`) so NO pixel is
   pure black; 2-octave value-noise cloud modulation (`×(0.85+0.30·noise)`)
   for glassy flow.

Both: warmth crossfade (cool set → warm set) as the story warms; pointer
parallax `uv += pointer * 0.03`; ALWAYS dither (`(hash(px)-0.5)/255`).
Soft-clip blooms `aur /= 1 + 0.8·aur` so text stays brightest.

## Glass rules

- Liquid glass needs a multi-hue living backdrop behind it or it collapses
  to gray. Never put glass on flat color.
- Glass fills: `rgba(18,18,22,0.62)` + 1px `rgba(255,255,255,0.12)` border +
  `backdrop-filter: blur(18px) saturate(160%)` — but know the cost: DOM
  backdrop-filters composite at FULL devicePixelRatio (uncapped, unlike a
  dpr-capped canvas). Budget them; shed them on a lite tier.
- CSS easings tokens: emphasized-decelerate `cubic-bezier(0.05,0.7,0.1,1)`,
  emphasized-accelerate `cubic-bezier(0.3,0,0.8,0.15)`, standard
  `cubic-bezier(0.2,0,0,1)`. No overshoot/bounce curves — arrive, don't bounce.

## Text inside a bubble (the in-orb treatment)

Text that must feel INSIDE glass cannot be filtered DOM — render it in-scene:

1. Rasterize the copy (canvas2D → texture) at min(dpr, 1.75). Await
   `document.fonts.load()` for the EXACT faces first — `fonts.ready` alone
   races lazily-loaded webfonts. Debounce resize regeneration (~300ms).
2. Plate parented INSIDE the bubble's transform — inherits every drift/
   scale/story movement for free. Add ~0.9 lerp catch-up lag + a faint echo
   of the wobble: floats in the liquid, not painted on it.
3. Shader: barrel/fisheye UV distortion strengthening toward the shell,
   slight chromatic split, subtle rim-palette tint pickup, and a HARD
   silhouette mask (discard outside the bubble disc) — "text never appears
   outside the glass" enforced by construction, not animation discipline.
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
   t·spin)`. Calm spin ≈ 0.05–0.07 rev/s (full turn ~14–20s; never strobe).
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
   rim-light cadence (~4.6s) and let the edge hue lead the fill slightly.
4. **Kill the chromatic split on THIS plate.** The generic in-orb refraction
   (step 3 above) samples the white mask at offsets → ghosted/doubled glyph
   edges (more "pixelated" artifact). A recolored mask owns its own look; set
   its chroma to 0. Likewise keep its glass rim-tint pickup LOW (~0.2) so the
   rotating RGB stays vivid instead of being dulled toward the shell hue.

## Script accents

A script face (e.g. Parisienne) for emotional spans only, inked with a
linear palette gradient (`background-clip: text`). Script renders far wider
per em than sans — size to ~0.7× the sans equivalent. Inline-mark spans in
copy (`{{…}}`) and parse, so authors write plain text.

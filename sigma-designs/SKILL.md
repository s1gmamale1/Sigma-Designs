---
name: sigma-designs
description: Use when building or styling anything in the Apple Intelligence / Image Playground aesthetic — living gradient orbs or soap bubbles, glowing RGB rim lights, Siri-style aurora or blooms-on-velvet backgrounds, cinematic scroll-driven storytelling, glassy synthesized UI sounds, in-bubble text, gradient-edge cursors — or when the user says "Sigma Designs", "like the bubble you made", or asks for that living-glass look.
---

# Sigma Designs

The distilled design system from a production Apple-Intelligence-styled WebGL
experience. Not a description of that site — a set of
proven recipes with exact numbers that produce the look on any project.

## Core principle

**Everything is alive, nothing is neon.** Every visible element self-animates
on multi-second periods (never strobes), color exists as *light spilled on
darkness* (never flat fills), and motion follows emphasized-decelerate
(arrive, don't bounce). Apple owns the surface, Google owns the motion.

## The law of the rim

The signature "AI glow" edge is **3–4 independent colored lights that slide,
pulse, and breathe along the edge** — NEVER one traveling highlight, NEVER a
static rainbow border, NEVER whole-edge hue rotation (reads as a mood ring).
This applies at every scale: hero orb, micro-bubbles, even the cursor.

## Reference files

| File | Read when |
|---|---|
| orb-recipe.md | Building any living orb/bubble — silhouette wobble, the 4 rim lights, interior glass, eruption flares, mini/cursor variants |
| atmosphere.md | Backgrounds, palette hexes, blooms-on-velvet vs full-gradient atmosphere, glass rules, in-bubble text |
| motion-language.md | Easings, time-rails vs scroll-rails, shared-refs architecture, envelope shapes, entrance grammar, ScrollTrigger pin trap |
| sfx-palette.md | Synthesized UI sounds — glassy voice recipes, envelope-driven feeds, mix law |
| verification.md | Proving the look/sound objectively — motion-proof screenshots, RMS tables, cue-log probes + the gotcha table |

## Quick reference

- Palette ramp (9 stops, warm→cool): `#ff9a0f #e9922b #ff8578 #ff646a #ef638a #bc82f3 #8186c7 #67a7ff #98aeea`
- Silhouette wobble: ≤10% radius, 4 summed sin lobes, periods 2.2–5s
- Rim lights: ω = [0.52, −0.69, 0.83, −0.47] rad/s (mixed directions), pulse periods 2.8–4.6s
- Easing: emphasized-decelerate `cubic-bezier(0.05, 0.7, 0.1, 1)` for all arrivals
- Flare/pulse envelope: asymmetric gaussian — sharp rise (σ≈0.13s), soft decay (σ≈0.30s)
- Velvet floor: `#08070d`; always dither (`hash(px)/255`) or gradients band

## Common mistakes

| Mistake | Fix |
|---|---|
| One highlight orbiting the edge | 3–4 independent lights, mixed directions/speeds |
| Perfect circles | Organic wobble ≤10%, finite-difference normals |
| Bright saturated background | Color as light ON black velvet; corners stay dark |
| Symmetric pulse envelopes | Sharp attack, soft decay (solar flare, not sine) |
| Overlapping lights blow to white | Compress: `hot /= 1 + 0.85·max(sum−1, 0)`; cap white ≤0.55 |
| Text/effects "stuck onto" the bubble | Parent INTO its transform + slight liquid lag; mask by silhouette |
| In-bubble word glow is blocky/"low-poly pixels" | Bloom from the MIP chain (coarse trilinear taps), never a few coverage taps over a wide radius (they step into petals) — see atmosphere.md |
| In-bubble word is frozen/muddy/ghosted | Color in-SHADER not the raster (white mask + rotating palette conic, sat-lifted); kill chroma split on that plate |

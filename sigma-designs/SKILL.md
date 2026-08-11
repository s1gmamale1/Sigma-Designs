---
name: sigma-designs
description: Use when building or styling anything in the Apple Intelligence / Image Playground aesthetic — living gradient orbs or soap bubbles, glowing RGB rim lights, Siri-style aurora or blooms-on-velvet backgrounds, cinematic scroll- or click-driven storytelling, scroll-snapped story beats, glassy synthesized UI sounds, in-bubble text, gradient-edge cursors — or when a WebGL story transition teleports, snaps, or dies after a navigation change — or when the user says "Sigma Designs", "like the bubble you made", or asks for that living-glass look.
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
| orb-recipe.md | Building any living orb/bubble — silhouette wobble, the 4 rim lights, interior glass, shimmer, eruption flares, orbiting sets, cursor |
| atmosphere.md | Backgrounds, palette hexes, blooms-on-velvet vs full-gradient atmosphere, glass rules, in-bubble text |
| motion-language.md | Easings, single-ease rule, time-rails vs scroll-rails, shared-refs architecture, envelope shapes, entrance grammar, perf/tier discipline |
| navigation-rails.md | Driving the story position — who writes the playhead, quantized scroll, phase handoffs, jank-clamped clocks, reviving a held playhead |
| sfx-palette.md | Synthesized UI sounds — glassy voice recipes, envelope-driven feeds, mix law |
| verification.md | Proving the look/sound objectively — video capture, debug HUD, RMS tables, the gotcha table, process rules |

## Quick reference

- Palette ramp (9 stops, warm→cool): `#ff9a0f #e9922b #ff8578 #ff646a #ef638a #bc82f3 #8186c7 #67a7ff #98aeea`
- Silhouette wobble: Σ0.092 (±9.2% radius), 4 cross-axis sin lobes with phase offsets, periods 2.2–4.3s
- Rim lights: ω = [0.52, −0.69, 0.83, −0.47] rad/s (mixed directions), pulse periods 2.8–4.6s
- Easing: emphasized-decelerate `cubic-bezier(0.05, 0.7, 0.1, 1)` for all arrivals — applied EXACTLY ONCE
- Flare/pulse envelope: asymmetric gaussian — sharp rise (σ≈0.13s), soft decay (σ≈0.30s)
- Velvet floor: `#08070d`; always dither (`hash(px)/255`) or gradients band
- Tone-map interiors (`1 − exp(−c·1.5)`); never clamp to white
- Feed hand-driven tweens a clamped clock: `Σ min(Δt, 33ms)`
- Transitions/cutscenes: 1.6s; post-landing dwell 2s; camera dolly-only, fixed fov

## Common mistakes

| Mistake | Fix |
|---|---|
| One highlight orbiting the edge | 3–4 independent lights, mixed directions/speeds |
| Perfect circles | Organic wobble ≤10%, finite-difference normals |
| Bright saturated background | Color as light ON black velvet; corners stay dark |
| Symmetric pulse envelopes | Sharp attack, soft decay (solar flare, not sine) |
| Overlapping lights blow to white | Compress: `hot /= 1 + 0.85·max(sum−1, 0)`; cap white ≤0.55 |
| Text/effects "stuck onto" the bubble | Parent INTO its transform + slight liquid lag; mask by silhouette |
| Inner glows read as flat pale discs | `pow(dot(n,v), k)` is the failure mode — use `0.62·exp(−7e²) + 0.12d²` (e = 1−\|dot(n,v)\|) |
| Per-frame uniform writes have no visible effect | R3F cloned your `{value}` holder — rebind `material.uniforms` to the live object |
| In-bubble word glow is blocky/"low-poly pixels" | Bloom from the MIP chain (coarse trilinear taps), never a few coverage taps over a wide radius (they step into petals) — see atmosphere.md |
| In-bubble word is frozen/muddy/ghosted | Color in-SHADER not the raster (white mask + rotating palette conic, sat-lifted); kill chroma split on that plate |
| Transition "teleports" or snaps after a stutter | The tween ate a stalled frame's whole gap — clamp the clock you feed it, don't reach for lag smoothing |
| Effects die after switching from scroll to click/step navigation | The playhead is HELD — map each frozen effect to its representative position (navigation-rails.md Law 5), don't retune it |
| A visible step at a mode/phase change | An un-bridged continuous channel — capture and ease EVERY one across the seam |
| Motion measures smooth but arrives ahead of the camera | Double-ease — rails return raw linear, one consumer eases |
| Elements pop in at full size when a camera returns | Give them the birth envelope with a wall-clock input, and latch it so it plays once |
| A fast gesture blows through the whole story | Quantize the INPUT (charge + dwell + re-arm), never the render layer |

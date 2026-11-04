---
name: sparkle-express-design
description: Use when designing, building, extending or reviewing the Sparkle Express (sparkleexpressllc.com) software-studio website, or any page that must look, read and move like it — graph-paper canvas, heavy grotesk headlines with an outlined word, handwritten Kalam kickers with a yellow marker underline, a sketch-to-reality drag slider, one violet action on navy ink. Also when a studio page drifts into a generic look, or its copy is about to invent clients, case studies or stats. Part of the sigma-designs family.
---

# Sparkle Express — Studio Design

The design language of the Sparkle Express studio site ("From idea. To
reality."), distilled so a new page reads as the same studio. Exact values
live in the reference files; this page is the map.

## Core principles

1. **The scribble becomes the product.** Every page tells the same story:
   hand-made (graph paper, Kalam handwriting, a hand-drawn wireframe) turning
   into precise (heavy Schibsted Grotesk, real screens). Show both halves.
2. **Graph paper is the canvas.** Paper `#f3f4f8` with a 40 px grid of
   `#dcdfea` lines behind the hero and sketch areas; plain paper elsewhere.
3. **Type carries the voice.** Huge, tightly tracked Schibsted Grotesk
   headlines, one word or line drawn as an outline that fills with ink; a
   Kalam kicker in violet, tilted −1.5°, underlined by a yellow marker stroke.
4. **One action colour.** Violet `#5a3ee6` for the primary action and links;
   navy night `#1b1640` for the dark card or panel; highlight yellow `#ffd43b`
   as a marker stroke, a sparkle, kicker and link text on dark sections, the
   text selection, the slider focus ring and the progress gradient — never a
   fill or a button.
5. **Show, then let them drag.** The signature piece is the sketch-to-reality
   slider: the hand-drawn SVG wireframe and the finished render on one frame,
   compared by dragging or with the keyboard.
6. **An honest studio.** No invented clients, case studies, logos,
   testimonials or stats. The portfolio is what exists (Akademiya AI, linked
   out). Generated photos are labelled as concept imagery. The brief builder
   drafts an email; it never sends or stores anything.
7. **Static and self-hosted.** A Python generator writes plain HTML; fonts and
   images ship locally; no npm, no external fonts, no hotlinks.

## Quick reference

| Token | Value | Use |
|---|---|---|
| `--paper` | `#f3f4f8` | Page background |
| `--ink` / `--ink-2` | `#17142b` / `#4a4760` | Headlines / body |
| `--pencil` | `#767a90` | Captions, sketch strokes |
| `--line` | `#dcdfea` | Grid lines, borders |
| `--violet` / `--violet-deep` | `#5a3ee6` / `#4026c4` | Action, links, kickers / hover |
| `--lilac` | `#e7e2ff` | Soft violet tint |
| `--highlight` | `#ffd43b` | Marker underline, sparkles |
| `--night` | `#1b1640` | Dark card, dark panel (`--night-2` `#26205a` is declared but unused today) |
| Radii | media 28 · card 18 · control 12 px | |
| Container | 1240 px | |
| Fonts | `Schibsted Grotesk` 400–900 (+ italic), `Kalam` 400/700, self-hosted woff2 | Body 18 px / 1.6 |

## Signature CSS (motion.css, site.css)

```css
/* The outlined line (site.css): paper fill under a 4px ink stroke. */
.display-title .muted,.hero-idea { color: var(--paper); -webkit-text-stroke: 4px var(--ink); paint-order: stroke fill; }
/* Word spans must be inline-block or translateY does nothing (motion.css). */
.w > span { display: inline-block; }
/* Each word rises out of a mask, 55ms apart; outlined words then ink in (motion.css). */
.motion .split-words .w > span { transform: translateY(105%); transition: transform .9s cubic-bezier(.2,.8,.2,1); transition-delay: calc(var(--w,0) * 55ms); }
.motion .split-words.is-in .w > span { transform: none; }
/* Failsafe: show the headline words after 4s if the observer never fires. */
.motion .split-words:not(.is-in) .w > span { animation: reveal-failsafe 0s 4s forwards; }
/* The failsafe keyframes: snap to visible (motion.css). */
@keyframes reveal-failsafe { to { opacity: 1; transform: none; } }
.display-title .muted .w > span { transition: transform .9s cubic-bezier(.2,.8,.2,1), color .9s ease;
  transition-delay: calc(var(--w,0) * 55ms), calc(.75s + var(--w,0) * 120ms); }
.display-title.is-in .muted .w > span { color: var(--ink); }
/* Marquee: outlined grotesk words, Kalam words in violet, yellow four-point sparks between. */
.mq-item:not(.mq-hand) { color: var(--paper); -webkit-text-stroke: 2px var(--ink); paint-order: stroke fill; }
.mq-spark { flex: none; width: clamp(20px, 2.4vw, 34px); aspect-ratio: 1; background: var(--highlight);
  clip-path: polygon(50% 0, 62% 38%, 100% 50%, 62% 62%, 50% 100%, 38% 62%, 0 50%, 38% 38%); }
```

## Kickers

A Kalam line above a section title: short, sentence case, no full stop
("Who does what", "Before we start"); a question keeps its "?" ("Who is
Sparkle Express?"). Only the hero note is a full sentence with a full stop
("Every great product starts as a scribble."). On dark sections the kicker
turns highlight yellow.

## A Work or portfolio page

Show only work that exists: the studio's own products with the status the
company states (Akademiya AI: developed, linked out to akademiya.ai) and
client work the client has approved for publication. No metrics without a
source. Until there is more, one honest block plus a clearly labelled "next
project" sketch slot is the page. Portfolio filters are mentioned in the
source README but are not built; build them only when asked and when there is
enough work to filter.

## Adding a page

- The nav holds four links (Who we are, Build with us, How we build, Our
  products ↗) and the dark "Bring an idea" button; at ≤ 880 px it collapses
  into the menu. Add a fifth link only when the owner adds the page; otherwise
  link it from the footer or the company page.
- New routes are generated: register the page in the `data` list of
  `build_corporate_pages()` in `content/corporate.py` with its copy (nav and
  footer live in `build_content.py`, which runs the build), then rebuild.
- In a throwaway single-file prototype, copy the woff2 files next to it (or
  point at `/assets/fonts/`) rather than falling back to system fonts, and if
  no real render exists, label the slider's "reality" side as a placeholder.
  Ship only real renders, labelled concept imagery.

## Reference files

| File | Read when |
|---|---|
| visual-system.md | Colours, grid, fonts, type scale, outline headlines, kickers, buttons, cards, marquee, header/footer, layout |
| pages-and-copy.md | Building or editing a page: site map, section order, content model, voice, truth rules, the brief |
| motion-and-interactions.md | Any motion (view transitions, reveals, ink-fill, scroll-read, marquee, tucking header) or interaction (slider, tabs, process rail, brief builder, mobile nav) |
| build-and-verify.md | Generating, previewing, deploying and verifying a page |

## Common mistakes

| Mistake | Fix |
|---|---|
| Warm cream + a serif (Fraunces/Playfair) + monospace labels | Paper `#f3f4f8`, Schibsted Grotesk, Kalam for the human voice |
| A stats strip or "trusted by" logos in the hero | No numbers or logos without real, approved work |
| Made-up clients and case studies | Only real products (Akademiya AI); a new case study needs real, approved work |
| A "Show shipped" button swapping two images | The drag/keyboard sketch-to-reality slider |
| Yellow as a button or a fill | Yellow is never a fill or a button; it marks, sparkles, tints text on dark sections and rings focus |
| Google Fonts or CDN links | Self-hosted woff2 from `/assets/fonts/` |
| Editing generated HTML in `dist/` | Copy lives in `content/*.py`; rebuild with `python3 build_content.py` |
| Photos passed off as the team or clients | Label them concept imagery; they are generated placeholders |

## Source of truth

The site's source (`build_content.py`, `content/`, `dist/site.css`,
`dist/site.js`, `dist/motion.{css,js}`) lives in the owner's local
sparkle-express-source repo and is served at sparkleexpressllc.com. When this
skill and the code disagree, the code wins; update the skill.

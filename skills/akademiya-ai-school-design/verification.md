# Verification

A page is done when it is proven in a browser, not when it compiles. Tests
prove contracts; screenshots and measured numbers prove the look.

## The gate (Frontend repo, every change)

```bash
npx tsc -p tsconfig.app.json --noEmit        # root tsconfig checks nothing
npx eslint --max-warnings 0 src/marketing
npx vitest run src/marketing src/pages/landing
VITE_API_BASE_URL=https://api.example.test/api/v1 npm run build   # 48 pages + 404s
```

Static guards that run in the suite: truth patterns over every page × language
(text, alt/aria/title, head meta); hydration of every page with no recoverable
errors; the reviewed-image manifest (no orphan, no unreviewed image); every
product capture sits in a `[data-tilt]` figure; server HTML carries no
`data-reveal-state`, no tilt state, no `--mk-*` pose variables.

## Browser matrix (Playwright, Chrome, against the built site)

Run every page × uz/ru/en × 1440×900 and 390×844, and record numbers:

| Check | Pass |
|---|---|
| Console errors and warnings, page errors | 0 |
| `scrollWidth − innerWidth` at load and at every scroll step | 0 |
| `[data-reveal]` armed in the first screen | 0 |
| Armed blocks left after scrolling to the bottom | 0 |
| Lenis on (`html.lenis`) normal / off under `reducedMotion: 'reduce'` | yes / yes |
| Reduced motion: armed blocks, tilt vars, running animations | 0 |
| Carousel advances on its own (~6 s); a vertical swipe does not pause it; a sideways swipe does | yes |
| Red button steps through every section to the last, then hides | yes |
| Nav: light glass over sky/paper, dark over velvet and the footer; pill on scroll; jiggle on hover | yes |
| Tilt: `--mk-ry` ≤ 8° away from a figure, ≥ 11° at a figure's edge on hover; loop idle after the mouse stops | yes |
| 3D phone ready with a GPU; no chunk request with `--disable-webgl*` or a software renderer | yes |
| Capture `img` alt exposed in the accessibility tree after the 3D swap | yes |

Read numbers from the DOM (computed styles, rects, attributes, request log);
look at screenshots yourself for anything visual. A 3D-projected bounding box
is not an in-plane distance; check overlaps in the pixels.

## Pixel parity (matching a reference)

1. Screenshot reference and target at the same viewport and DPR 2.
2. Measure each element's rect and computed font (CDP
   `CSS.getPlatformFontsForNode` gives the face actually rendered).
3. Compare crops of shared elements; iterate until rects match within 1 px and
   colours within ±2/255 (antialiased corners excepted). Write the property
   table old → new before changing code.

## Review loop

Build in parallel lanes with disjoint files (no git writes, no builds inside
lanes), integrate and gate, then run a fresh reviewer (give it the diff and the
owner's ask, not your conclusions) and a read-only browser-check agent in
parallel. Fix lanes take both reports; re-review and re-check until the
reviewer approves (every axis ≥ 85) and the browser matrix is clean.

## Done means

- Gate green, browser matrix numbers recorded, screenshots looked at.
- uz/ru flagged for a native read if they are new.
- Nothing merged or deployed without the owner's go.

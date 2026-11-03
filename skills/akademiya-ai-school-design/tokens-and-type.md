# Tokens and type

Source: `src/marketing/styles/` (site.css imports the rest). Everything below is copied from the CSS; the file is named per block.

## 1. Colour tokens (home.css, on `.mk-site`)

| Token | Value | Role |
|---|---|---|
| `--mk-velvet` | `#140d17` | dark canvas; footer bg; turn gradient start; pilot band bg |
| `--mk-velvet-2` | `#1d1322` | turn gradient 2nd stop (18%) |
| `--mk-mist` | `#b3adbd` | body text on velvet (details, subs, leads); pains title |
| `--mk-white` | `#f7f4fa` | text on velvet; ghost button text |
| `--mk-red` | `#ec031d` | primary button bg, nav CTA, hero dots, active-language tint |
| `--mk-red-ink` | `#d0021a` | red as TEXT on light (hero lead, turn intro, cure "answers", links, FAQ +); button hover bg |
| `--mk-violet` | `#6a3df0` | defined; used only inside the violet bloom as `rgba(106,61,240,…)` |
| `--mk-ink` | `#151922` | headings and text on paper |
| `--mk-ink-2` | `#4b5160` | body text on paper |
| `--mk-paper` | `#fbfcff` | light canvas (cures, people, steps, FAQ, inner pages) |
| `--mk-line-dark` | `rgba(247,244,250,.14)` | hairlines and card borders on velvet |
| `--mk-ease` | `cubic-bezier(.16, 1, .3, 1)` | card fades, dot pip; same curve as `--mk-spring` (motion.css) |

Literal colours used beside the tokens:

| Value | Where |
|---|---|
| `#ffffff` | headings on velvet (`.mk-velvet :is(h1,h2,h3)`), button text, focus ring on velvet |
| `#ff5a6e` | red on velvet: card number `.mk-familiar__n`, page-hero kicker, turn intro start colour |
| `#e4e8f2` | hairline on paper (people top border, steps/FAQ/info dividers) |
| `#e9e2ee` | turn gradient 3rd stop (58%) |
| `#ca0e23` | nav CTA hover bg (chrome.css) |
| `#c9c1d3` | footer text; `#ffffff` footer titles and hover |
| `#ff4055` | footer brand ".ai"; nav ".ai" is `#e6031d` |
| `#241828` / `#170f1b` | familiar card gradient (160deg) |
| `#f3eef7` | legal summary bg; `#fff4f5` / `#8a0011` demo banner bg / text |
| `#d9dde8` | demo tab border |
| `#5a43e8` | tutor-card button bg |

## 2. Where each is used

| Surface | Background | Text |
|---|---|---|
| Home hero (sky) | `--mk-paper` + sky photo | ink, red-ink lead (hero.css) |
| "Sound familiar?" canvas, inner-page header, pilot band, 404, footer | velvet + blooms | white / mist |
| Turn "Let's fix this." | gradient velvet → velvet-2 18% → `#e9e2ee` 58% → paper 100% (home.css) | ink / red-ink |
| Cures, people, steps, FAQ, info, demo | paper | ink / ink-2 |

- Order on Home: light sky → dark velvet → gradient turn → paper → velvet pilot → paper demo form.
- Section theme drives the nav glass: mark dark sections `data-nav-theme="dark"`; sky hero is `data-nav-theme="light"`.

## 3. Blooms (home.css, familiar.css)

```css
.mk-bloom { position:absolute; z-index:0; width:min(72vw,980px); aspect-ratio:1; border-radius:50%; pointer-events:none }
.mk-bloom--red    { top:-28%; left:-18%;  background:radial-gradient(closest-side, rgba(236,3,29,.5),  rgba(236,3,29,.12) 55%, transparent) }
.mk-bloom--violet { right:-24%; top:34%;  background:radial-gradient(closest-side, rgba(106,61,240,.42), rgba(106,61,240,.1) 55%, transparent) }
.mk-bloom--centre { top:50%; left:50%; translate:-50% -50% }   /* red bloom centred, pilot band */
.mk-home-canvas > .mk-bloom--violet { top:auto; bottom:0 }     /* Home: violet sits on the canvas foot */
```

- Host `.mk-velvet`: `position:relative; overflow:clip; background:var(--mk-velvet); color:var(--mk-white)`.
- Blooms are `<span aria-hidden>` as first children; content sits at `z-index:1`.
- Pairs: red + violet on page headers and Home canvas; red `--centre` alone on pilot bands.

## 4. Fonts

| Use | Family | Source |
|---|---|---|
| All page text | Poppins 300 400 500 600 700 800 | Google Fonts link in `marketing.html` |
| Cyrillic (`lang="ru"`) | Montserrat 400 500 600 700 800 | same link; `:lang(ru) .landing-root { font-family:"Poppins","Montserrat",sans-serif }` (site-layer.css) |
| Nav bar only | `-apple-system, BlinkMacSystemFont, "SF Pro Display", "SF Pro Text", "mk-nav-inter", system-ui, sans-serif`, base `400 15px/1.5` | chrome.css |
| Mobile sheet | `"Poppins", sans-serif` | chrome.css |

- `<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&family=Montserrat:wght@400;500;600;700;800&display=swap">` with preconnect to googleapis and gstatic (crossorigin).
- `mk-nav-inter` = Inter v20 woff2 from fonts.gstatic.com, private name so only the bar uses it. Weights loaded: 400 and 700 only, each in 4 subsets (Latin and Latin-ext shown first; 8 `@font-face` total, `font-display:swap`, `unicode-range` per subset). Link weight 650 renders the 700 cut. Apple devices render San Francisco and download nothing.
- Wordmark weight is 400 (not bold); lead lines use 300.

## 5. Type scale (size / weight / line-height / tracking)

| Element (class) | clamp / size | wt | lh | ls | file |
|---|---|---|---|---|---|
| Hero wordmark `.mk-hero__wordmark` | `min(clamp(3rem,6.4vw,6.4rem),12svh)`; ≤640px `clamp(2.5rem,12vw,3.4rem)` | 400 | .82 | -.075em | hero.css |
| Hero definition | `clamp(1rem,1.5vw,1.3rem)`; ≤640 `clamp(.95rem,4vw,1.1rem)`, max 30ch | 300 | 1.35 | -.015em | hero.css |
| Hero red lead | `clamp(1.15rem,2vw,1.65rem)`; ≤640 `clamp(1.1rem,5vw,1.4rem)` | 300 | 1.2 | -.025em | hero.css |
| "Sound familiar?" `.mk-familiar__title` | `clamp(3rem,7vw,6.4rem)` | 800 | .95 | -.05em | familiar.css |
| Familiar sub | `clamp(1rem,1.4vw,1.15rem)`, mist | — | — | — | familiar.css |
| Card line `.mk-familiar__line` | `clamp(1.65rem,3.3vw,3rem)`, max 20ch | 700 | 1.08 | -.03em | familiar.css |
| Card detail | 1.0625rem, mist, max 44ch | — | 1.6 | — | familiar.css |
| Card number | .95rem, `#ff5a6e` | 700 | — | — | familiar.css |
| Pains title (inner pages) | `clamp(1.05rem,1.5vw,1.25rem)`, mist | 500 | — | 0 | home.css |
| Pain row title `.mk-pain__title` | `clamp(1.55rem,3.4vw,2.75rem)` | 700 | 1.12 | -.03em | home.css |
| Turn line `.mk-turn__line` | `clamp(2.4rem,6.4vw,5.6rem)`, max 14ch | 800 | 1 | -.045em | home.css |
| Turn intro (red) | `clamp(1.2rem,2.2vw,1.75rem)` | 600 | 1.25 | -.02em | home.css |
| Cure title `.mk-cure__title` | `clamp(1.9rem,3.4vw,2.85rem)`, max 18ch | 800 | 1.04 | -.04em | home.css |
| Cure body | 1.125rem, ink-2, max 46ch | — | 1.6 | — | home.css |
| Cure "answers" | 1rem, red-ink | 600 | — | — | home.css |
| People title | `clamp(1.8rem,3.4vw,2.6rem)` | 800 | — | -.035em | home.css |
| Person h3 / p | 1.375rem 700 (-.02em) / 1.0625rem ink-2 lh 1.6 | | | | home.css |
| Pilot title `.mk-pilot__title` | `clamp(2.3rem,5.6vw,4.8rem)`, max 16ch | 800 | 1.02 | -.045em | home.css |
| Pilot body / price | 1.125rem mist lh 1.6 max 46ch / 1.25rem white 600 | | | | home.css |
| Page-hero title (velvet h1) | `clamp(2.4rem,5.8vw,5rem)`, max 17ch | 800 | 1.02 | -.045em | pages.css |
| Page-hero kicker / lead | 1rem 600 `#ff5a6e` / `clamp(1.05rem,1.6vw,1.25rem)` mist lh 1.6 max 46ch | | | | pages.css |
| Section title `.mk-section-title` | `clamp(1.7rem,3.2vw,2.5rem)` | 800 | 1.1 | -.035em | pages.css |
| Section lead | 1.0625rem ink-2 max 52ch lh 1.6 | | | | pages.css |
| Step h3 / FAQ summary | 1.15rem 700 / 1.125rem 600 | | | | pages.css |
| Tutor card title / body | 1.125rem 700 / .95rem ink-2 lh 1.5 | | | | home.css |

## 6. Shell, spacing, radii

| Item | Value | file |
|---|---|---|
| `.mk-shell` | `width:min(1200px, calc(100% - 2rem)); margin-inline:auto; position:relative; z-index:1` | home.css |
| Familiar gutter `--mk-gutter` | `max(1rem, calc((100% - 1200px) / 2))` | familiar.css |
| Pains / familiar section padding | `clamp(2rem,5vw,4rem) 0 clamp(5rem,10vw,8rem)` / `clamp(4.5rem,10vw,8rem) 0 clamp(4rem,9vw,7rem)` | home.css, familiar.css |
| Cure row | padding `clamp(3rem,7vw,6rem) 0`; gap 2.5rem; ≥960px cols 5fr/7fr, gap 4.5rem (flip: 7fr/5fr, copy `order:2`) | home.css |
| People / steps / FAQ padding | `clamp(4rem,8vw,6.5rem)` / `clamp(4rem,8vw,6rem)` | home.css, pages.css |
| Pilot padding | `clamp(5rem,11vw,9rem) 0` | home.css |
| Page-hero padding | `calc(var(--ak-nav-h,78px) + clamp(4rem,11vh,7rem)) 0 clamp(3.5rem,8vh,6rem)` (`--short`: bottom `clamp(3rem,7vh,5rem)`) | pages.css |
| Anchor offset | `scroll-margin-top: 6.125rem` on `#landing-main section, [id]` | motion.css |

Radii: pill buttons 999px; familiar card 28px; capture image and panel plane 18px; tutor card 20px; phone body 46px, screen 36px, island 999px; nav bar 18px, nav panel 14px, panel links 8px, nav CTA 12px, lang box 8px (inner 6px); nav menu button 10px; legal summary 16px; demo banner 12px.

## 7. Shadows and glass

| Item | Value | file |
|---|---|---|
| Tutor card | `0 2px 6px rgba(21,25,34,.08), 0 30px 60px -20px rgba(36,18,60,.4)`; `rotate:-2deg` | home.css |
| Capture image contact shadow | `0 2px 6px rgba(21,25,34,.08)` | tilt.css |
| Tilt shadow layer `.mk-tilt-shadow` | bg `rgba(36,18,60,.4)`, `filter:blur(30px)`, opacity .8 (1 on hover), inset `6% 5% 0` | tilt.css |
| Phone rim | `inset 0 0 0 1.5px rgba(255,255,255,.12)`; body gradient `145deg #2a2530 → #0e0b11`, padding 11px, screen bg `#f4f6f8` | home.css, tilt.css |
| Familiar controls | pill bg `rgba(247,244,250,.1)`, `backdrop-filter:blur(18px)`, min-height 3.25rem | familiar.css |
| Sky wash | `opacity:.62` (≤640: .4), `mix-blend-mode:multiply`, radial mask `ellipse 54% 50% at 50% 46%, #000 0%, rgba(0,0,0,.55) 45%, transparent 74%` | motion.css |

### Nav glass (chrome.css, `.mk-nav` variables)

| Variable | Dark (default) | Light (`.is-light`) |
|---|---|---|
| glass bg | `rgba(17,19,26,.52)` | `rgba(255,255,255,.52)` |
| border | `rgba(255,255,255,.14)` | `rgba(255,255,255,.75)` |
| shadow | `0 16px 44px rgba(0,0,0,.5), 0 2px 8px rgba(0,0,0,.32)` | `0 14px 40px rgba(190,40,40,.1), 0 2px 6px rgba(31,41,76,.05)` |
| backdrop | `blur(18px) saturate(150%) brightness(.92)` | `blur(18px) saturate(160%)` |
| aurora alpha `--mk-nav-aur` | .24 | .5 |
| ink / link text | `#fff` / `rgba(255,255,255,.66)` | `#1d1d1f` / `#5e687d` |
| lang box line / bg / text | `rgba(255,255,255,.16)` / `.08` / `.62` | `#e4e8f2` / `#fff` / `#69748a` (+ shadow `0 4px 18px rgba(31,41,76,.04)`) |
| current lang | `#fff` on `rgba(236,3,29,.85)` over `.1` | `#ec031d` on `rgba(236,3,29,.1)` |
| CTA shadow | `0 6px 18px rgba(236,3,29,.35)` | none |
| chip bg / text | `rgba(255,255,255,.14)` / `#a1a1a6` | `rgba(29,29,31,.06)` / `#6e6e73` |
| burger | `#f5f5f7` | `#1d1d1f` |
| dropdown panel bg | `rgba(17,19,26,.86)` | `rgba(255,255,255,.86)` |
| hover tint | `rgba(255,255,255,.08)` | `rgba(29,29,31,.04)` |

- Aurora (`.mk-nav__bar::before`): three radial gradients (`rgb(255 154 15)` at 10% 0, `rgb(239 99 138)` at 52% 130%, `rgb(103 167 255)` at 92% -10%) at alpha `.1/.1/.12 × --mk-nav-aur`, `background-size:180% 180%`, drift `mk-nav-aur 46s ease-in-out infinite alternate` (motion allowed only).
- Rim (`::after`): `0 4px 4px rgba(0,0,0,.05), 0 0 12px rgba(0,0,0,.05), inset 2px 2px 2px rgba(255,255,255,.35), inset -2px -2px 2px rgba(255,255,255,.35)`.
- `prefers-reduced-transparency`: dark glass becomes `rgba(18,20,26,.97)`, no blur.
- Bar box: `position:fixed; top:12px; width:min(1180px, calc(100% - 24px)); height:66px; padding:0 24px; gap:18px; border:1px solid; radius 18px`.

## 8. Buttons (home.css)

| Class | Spec |
|---|---|
| `.mk-btn` | inline-flex centred, `min-height:3rem; padding:.85rem 1.5rem; border-radius:999px; font:600 1rem/1.2; transition bg/color/border .2s` |
| `.mk-btn--primary` | bg `--mk-red`, text `#fff`; hover bg `--mk-red-ink` |
| `.mk-btn--ghost` | `1px solid rgba(247,244,250,.38)`, text `--mk-white`; hover border `--mk-white` (used on velvet, 404 links) |
| `.mk-nav__cta` (nav) | `padding:9px 16px; radius:12px; bg #ec031d; ls -.224px`; hover `#ca0e23` + `translateY(-1px)`; ≤640: `8px 12px`, 12px |
| `.mk-pilot__title + .mk-btn` | `margin-top:2rem` |
| Demo tab | `min-height:2.75rem; padding:.55rem 1.2rem; 1px #d9dde8; pill`; selected = ink bg, white text |

## 9. Focus rings

| Where | Ring |
|---|---|
| `.mk-btn` | `3px solid #fff`, offset 3px (velvet-first) |
| Familiar track / dots / toggle | `2px solid #fff`, offset -2px (track, radius 30px) / 2px (controls) |
| Nav (all) | `2px solid var(--mk-nav-ink)`, offset 2px, radius 8px |
| Nav sheet | `3px solid #ec031d`, offset 3px |
| FAQ summary, demo tab | `2px solid --mk-red-ink`, offset 4px / 2px |
| Round red cue button | `3px solid --mk-ink`, offset 3px, plus `0 0 0 6px #fff` (motion.css) |

## 10. Contrast (computed WCAG 2.x relative-luminance ratios)

AA needs 4.5:1 for normal text, 3:1 for large text (24px, or 18.66px bold).

| Pair | Ratio | AA normal text |
|---|---|---|
| white-ish `#f7f4fa` on velvet | 17.53 | pass |
| mist `#b3adbd` on velvet | 8.76 | pass |
| footer `#c9c1d3` on velvet | 10.96 | pass |
| `#ff5a6e` on velvet | 6.31 | pass |
| ink on paper | 17.14 | pass |
| ink-2 on paper | 7.74 | pass |
| red-ink `#d0021a` on paper | 5.52 | pass |
| white on `#d0021a` | 5.67 | pass |
| white on `#ec031d` | 4.57 | pass (barely) |
| `#ec031d` as text on paper | 4.45 | FAIL (large text only) |

- Rule: red TEXT on light = `--mk-red-ink` (`#d0021a`); red FILL = `--mk-red`; red text on velvet = `#ff5a6e`. Small red text on light never uses `#ec031d`: it is for fills, large text and the nav's active-language pill.
- Known sub-4.5 spot: the nav's active-language pill (red tint) is carried unchanged from the old site; do not copy the pattern elsewhere.
- Reduced motion: every reveal, sky drift, cloud bank, tilt entrance and nav aurora is switched off; content rests visible.

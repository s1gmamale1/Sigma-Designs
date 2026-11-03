# Sparkle Express visual system

Source root: `sparkle-express-source/` (Tuff House). `site.css` = `dist/site.css`, `motion.css` = `dist/motion.css`. Idea: "sketch to ship". Kalam (handwritten) = the idea; Schibsted Grotesk = the reality. Outlined type = still an idea, solid type = built (site.css L1-3).

## 1. Tokens (site.css `:root`)

| Token | Value | Role |
|---|---|---|
| `--paper` | `#f3f4f8` | page bg, outline-text fill, theme-color meta |
| `--white` | `#fff` | cards, `.section--soft` bg, inputs |
| `--ink` | `#17142b` | body text, outline stroke, dark nav button |
| `--ink-2` | `#4a4760` | secondary text (leads, card copy) |
| `--pencil` | `#767a90` | captions, notes, `.muted` |
| `--line` | `#dcdfea` | borders, grid lines, dividers |
| `--violet` | `#5a3ee6` | primary accent: buttons, links, kickers, focus |
| `--violet-deep` | `#4026c4` | primary button hover |
| `--lilac` | `#e7e2ff` | `.legal-summary` bg |
| `--highlight` | `#ffd43b` | marker yellow: underline, sparks, `::selection`, dark-section accents |
| `--night` | `#1b1640` | dark sections, footer, dark cards |
| `--night-2` | `#26205a` | declared, unused in CSS |
| `--sans` | `"Schibsted Grotesk",ui-sans-serif,system-ui,sans-serif` | |
| `--hand` | `Kalam,"Comic Sans MS",cursive` | |
| `--container` | `1240px` | max content width |
| `--r-media` / `--r-card` / `--r-control` | `28px` / `18px` / `12px` | radii |
| `--grid` | see section 2 | graph-paper bg |

Other literal colours: dark-section body text `#d6d1f5`; dark muted `#a49fd0`; footer link `#e6e2ff`; sketch ink `#2d2858`; sketch bg `#f7f8fc`; stage dark `#0c0a18`; pills `#ddf5e5`/`#13693a` (developed), `#fff1bf`/`#735300` (progress); ruled brief lines `#c9cfe6`.

## 2. Graph-paper grid (site.css `--grid`)
```css
--grid: linear-gradient(var(--line) 1px,transparent 1px) 0 0/40px 40px,
        linear-gradient(90deg,var(--line) 1px,transparent 1px) 0 0/40px 40px;
background: var(--grid); background-color: var(--paper);   /* .home-hero */
```
- Light: `.home-hero` (paper), `.wf-people` (`background-color:var(--white)`).
- Dark: `.cta-section` uses `#ffffff0d` 1px lines at 40px over `var(--night)`.

## 3. Fonts (site.css L5-8; files in `dist/assets/fonts/`)
| Family | File | Weight / style |
|---|---|---|
| Schibsted Grotesk | `schibsted-grotesk.woff2` | variable `400 900`, normal |
| Schibsted Grotesk | `schibsted-grotesk-italic.woff2` | `400 900`, italic |
| Kalam | `kalam-400.woff2` | 400 |
| Kalam | `kalam-700.woff2` | 700 |
- All `font-display:swap`, URLs root-absolute `/assets/fonts/...`. Licences: `OFL-kalam.txt`, `OFL-schibstedgrotesk.txt`. No external font hosts.
- `build_content.py` preloads `schibsted-grotesk.woff2` and `kalam-400.woff2` (`as=font type=font/woff2 crossorigin`).
- Grotesk: headlines (800), body, UI. Kalam: kickers (`.eyebrow`), hero note, `.path-number`, `.wf-people h3`, `.wf-outcome strong`, `.step-output strong`, `.footer-note`, `.meter-label`, `.mq-hand`, sketch labels, `.tag-idea`.

## 4. Type scale (site.css)
| Element | Rule |
|---|---|
| body | `18px/1.6`, `<=640px`: `17px`; antialiased, `optimizeLegibility` |
| h1,h2,h3 base | `line-height:1.05; letter-spacing:-.035em; weight 800; text-wrap:balance` |
| h3 base | `24px/1.2; -.02em; 750` |
| `.home-hero h1` | `clamp(48px,9.6vw,150px)`, lh `.92`, ls `-.055em`; each `<span>` is `display:block; white-space:nowrap` |
| `.display-title` (page h1) | `clamp(48px,7.4vw,112px)`, lh `.98`, ls `-.045em` |
| `.section-title` | `clamp(36px,4.6vw,64px)`, lh `1.02`, ls `-.04em` |
| `.section-lead` | `clamp(19px,1.6vw,22px)/1.5`, `--ink-2`, max `680px`, mt `22px` |
| `.hero-lead` | `20px/1.5`, `--ink-2` |
| `.eyebrow` (kicker) | Kalam `21px/1.3`, `--violet`, mb `14px`, `rotate(-1.5deg)` origin left bottom (centre origin inside `.center`) |
| `.hero-note` | `24px` |
| `.body-copy` / `.prose` | `--ink-2`; max `62ch` / `66ch` |
| `.note` | `15px/1.55`, `--pencil`, mt `24px` |
| `.path-card h3` | `clamp(26px,2.6vw,34px)`, ls `-.03em` |
| `.process-step h3` | `clamp(26px,2.8vw,36px)` |
| `.service-row h3` | `clamp(24px,2.4vw,30px)` |
| `.build-card h3` / p | `22px` / `16.5px` |
| `.mq-item` | `clamp(36px,5.4vw,80px)`, 800, ls `-.045em` |
| `.footer-mail` | `clamp(28px,5.4vw,76px)`, 800, ls `-.045em` |

## 5. Outline / ink headline (site.css L~60, motion.css)
```css
.display-title .muted,.hero-idea{color:var(--paper);-webkit-text-stroke:4px var(--ink);paint-order:stroke fill}
.hero-idea{-webkit-text-stroke-width:clamp(3px,.44vw,6px)}
.section--soft .display-title .muted{color:var(--white)}   /* fill matches the section bg */
.mq-item:not(.mq-hand){color:var(--paper);-webkit-text-stroke:2px var(--ink);paint-order:stroke fill}
.process-step h3{color:var(--paper);-webkit-text-stroke:1.5px var(--ink);paint-order:stroke fill}
.process-step.is-active h3{color:var(--ink)}
```
- Fill = surface colour, stroke = `--ink`, `paint-order:stroke fill` hides overlapping glyph contours.
- Pattern: line 1 solid, line 2 `<span class="muted">` outlined ("Your idea.<br><span class="muted">Built together.</span>"). Home: `<span class="hero-idea">From idea.</span><span class="hero-reality">To reality.</span>`.
- Motion: with `.is-in`, `.display-title .muted .w>span` transitions `color` to `--ink` (inks in) with delay `calc(.75s + var(--w)*120ms)` (motion.css).

## 6. Handwritten kicker + yellow marker (motion.css `.eyebrow.doodle`)
- `motion.js` adds `.doodle` to every `.eyebrow`; on `.is-in` the background SVG grows from `0%` to `100% 9px`.
- Underline: inline SVG data URI, viewBox `0 0 200 10`, path `M2 6C40 2 70 9 110 5S170 3 198 6`, stroke `%23ffd43b` (=`#ffd43b`), width `4`, round caps; `padding-bottom:9px`; `no-repeat 0 100%`.
- Static marker version (hero note, site.css): `background:linear-gradient(transparent 58%,color-mix(in srgb,var(--highlight) 70%,transparent) 58%); padding-inline:4px`.
- Dark sections recolour kickers to `--highlight` (`.cta-section`, `.photo-story-copy`, `.path-card--dark .path-number`).

## 7. Buttons (site.css "Controls")
Base `.button`: inline-flex centred, gap `10px`, `min-height:50px`, padding `12px 22px`, radius `--r-control`, `1.5px solid transparent`, `16px/1.3`, weight 650; hover `translateY(-2px)`, active `0`; transition `.2s`.
| Variant | Style |
|---|---|
| `.primary` | bg `--violet`, white; hover `--violet-deep` |
| `.secondary` | bg `--white`, border `--line`, `--ink`; hover border `--ink` |
| `.ghost` | border `#ffffff4d`, white (on dark) |
| `.text` | padding-inline `4px`, `--violet`, underline `1.5px`, offset `5px` |
| `.nav-contact` (dark) | padding `9px 16px`, bg `--ink`, white, 650; hover bg `--violet` |
- `.button-row`: flex wrap, centred, gap `14px`, mt `36px`; `.left` = start aligned. `.text-link`: violet, 650, underline `1.5px` at 35% opacity, offset `6px`.
- `.pill`: `5px 12px`, radius 999, `13px/700`, 7px dot via `::before`.
- `spark-burst` (site.js): 14px `--highlight` four-point star on button press.

## 8. Cards
| Class | Style |
|---|---|
| `.path-card` (light) | padding `clamp(28px,4vw,48px)`, radius `18px`, bg white, `1px solid --line`; hover border `--violet`, `translateY(-3px)` |
| `.path-card--dark` | bg/border `--night`, white; p `#d6d1f5`; number + link `--highlight` |
| `.feature-card` | padding `clamp(26px,3vw,36px)`, radius 18, white, `1px --line`; inside `.section--soft` bg `--paper`, border transparent |
| `.build-card` | padding `30px 26px 32px`, bg `--paper`, hover white + border violet + `translateY(-6px) rotate(-.4deg)`; doodle icon 64px, stroke violet 2.6 |
| `.wf-lane` | padding `clamp(24px,3vw,36px)`, radius 18, min-h `200px`; `.wf-people` = grid on white + `1px --line`, Kalam 700 `30px` violet title; `.wf-agents` = `--night`, white, title preceded by a 16px yellow four-point star |
| `.principles/.values-grid article` | `padding-top:24px; border-top:2px solid var(--ink)`, no box |
| `.service-row` | grid `1.2fr 1fr`, gap `24px 64px`, padding-block `36px`, `border-top:1px solid --line`; list bullets = 10px violet star |
| `.step-output` | padding `18px 22px`, radius 14, bg paper, `1px --line`, Kalam label |
| `.contact-card` | padding `clamp(26px,3vw,40px)`, radius 18, white, `1px --line` |
| `.brief-panel` | padding `clamp(24px,4vw,44px)`, radius 28, bg paper |
Star clip-path (reuse everywhere): `polygon(50% 0,62% 38%,100% 50%,62% 62%,50% 100%,38% 62%,0 50%,38% 38%)`.

## 9. Marquee (motion.css; markup in `corporate.py` HOME)
`.marquee` (overflow hidden, padding-block `clamp(28px,4vw,48px)`, `border-block:1px solid --line`, bg paper) > `.marquee-track` (flex, gap `clamp(24px,3vw,44px)`, `width:max-content`). Items alternate outline `.mq-item` and `.mq-item.mq-hand` (Kalam 700, violet), separated by `.mq-spark` (yellow star, `clamp(20px,2.4vw,34px)`). Home items: Web platforms, SaaS products, Mobile experiences, AI workflows, Custom software, Internal tools. Marked `aria-hidden`. `motion.js` clones children and scrolls by `translateX`, speed `0.6 + boost`, boost reacts to scroll velocity (max 18, decays `*.92`).

## 10. Sketch-to-reality frame (site.css; helper `idea_stage()` in `content/corporate.py`; SVG in `content/sketch.py`)
- `.stage-frame`: `aspect-ratio:var(--ratio,1672/941)`, radius `28px` (`18px` at `<=640`), bg `#0c0a18`, shadow `0 1px 0 var(--line),0 40px 80px -40px #1b164066`, `cursor:ew-resize`.
- Photo is the base `<img>`; `.sketch-layer` (inline SVG viewBox `0 0 1672 941`) clipped by `clip-path:inset(0 calc(100% - var(--split)) 0 0)`; default `--split:52%`.
- Handle: 2px white line + 54px white circle (42px at `<=880`) with chevrons; a hidden `input.stage-range` (0-100) drives `--split`, keyboard focus ring = `3px --highlight`.
- Tags: `.tag-idea` Kalam 22px violet on `#f7f8fc`, `1.5px` violet border, radius 10, `rotate(-2deg)`; `.tag-reality` pill `13px/700` white on `#17142b99`, blur 8px.
- Sketch ink: stroke `#2d2858` width 3, rough filter (feTurbulence 0.035, displacement 5), grid pattern 40px `#dde0ec`. Notes Kalam 34px violet; yellow marker blob `--highlight` at 55%.
- Load: `.is-drawing` strokes draw (`sk-draw` 1.5s, per-group `--d` 0/.45/.9s), notes fade at 1.9s.
- Caption below: `14px --pencil`; always say "Concept imagery".

## 11. Header, footer, layout
- Header `.site-header`: sticky top, z 50, bg `color-mix(in srgb,var(--paper) 86%,transparent)`, `backdrop-filter:saturate(1.4) blur(14px)`; inner height `70px`, width `min(1240px,100% - 80px)`; border appears (`--line`) with `.is-scrolled`; hides (`.is-tucked`, `translateY(-100%)`) scrolling down past 240px (motion).
- Brand: 4-point `spark` SVG (22px, violet; rotates 90deg + scale 1.1 on hover) + lowercase "sparkle express", 19px/800, ls `-.03em`.
- Nav: gap `30px`, `15.5px/550`, `--ink-2`; current page = `--ink` + `2px --violet` bottom border. Items: Who we are, Build with us, How we build, Our products (external, arrow), then dark "Bring an idea" button.
- Footer `.site-footer`: bg `--night`, padding-top `clamp(64px,8vw,104px)`. Intro: Kalam `24px` yellow note, huge mailbox link, `#a49fd0` tagline; hover underline turns yellow, letters wave (motion). Links: 4-col grid, gap `32px`, h2 `15px/700 #a49fd0`, links `15.5px #e6e2ff` hover yellow. Bottom bar: brand (yellow spark), copyright, back to top, `border-top:1px solid #ffffff1f`.
- Shell: `.container{width:min(1240px,calc(100% - 80px));margin-inline:auto}`; `.section{padding-block:clamp(72px,10vw,128px)}`; alternate `.section` (paper) with `.section--soft` (white). `.split` = `5fr 7fr`, gap `clamp(32px,6vw,96px)`. `.grid-2` 2 cols, `.grid-3` 3 cols, gap `20px`. `.build-grid` 4 cols gap `16px`. `.heading-row` flex space-between, mb `48px`. `.section-heading` max `820px`, mb `48px`. `.narrow` `760px`.
- Anchor: `html{scroll-padding-top:96px}`.

## 12. Breakpoints (site.css bottom)
| Max width | Changes |
|---|---|
| 1100px | `.build-grid` 2 cols; `.hero-head` 1 col; `.grid-3` 2 cols; footer links 2 cols; `.photo-story` 1 col (image max-h 520px) |
| 880px | container/header width `100% - 48px`; hamburger shown (`.nav-toggle` 44px), nav becomes dropdown under the 70px bar; split/two-paths/faq/contact/company/service-row/legal go 1 col; `.wf-panel` 1 col; stage handle shrinks |
| 640px | container `100% - 32px`; body 17px; `.grid-2/.grid-3/.build-grid/.values-grid/.field-grid` 1 col; footer links 2 cols gap 24; process rail padding-left `64px`, index 40px; `.wide-photo img` aspect `4/3` |
Reduced motion: all animation/transition durations `.01ms`; `html.motion` class is only added when motion is allowed. Print hides header, footer, brief panel.

## 13. Focus + selection
- `:focus-visible{outline:3px solid var(--violet);outline-offset:4px;border-radius:4px}`; `.skip-link` fixed, dark, drops to `top:12px` on focus.
- Form fields: focus = violet border + `0 0 0 4px color-mix(in srgb,var(--violet) 18%,transparent)`; inputs `13px 15px`, `1.5px --line`, radius 12.
- `::selection` bg `--highlight`, text `--ink`.
- Header stays visible while `:focus-within`.

## 14. Misc components
- Photos: `.wide-photo img` aspect `21/9`, radius 28, cover; `.image-frame img` radius 28; `.photo-story` = 2-col `--night` block, image min-h `420px`, copy padding `clamp(40px,7vw,104px)`.
- Process rail: `.process-timeline` padding-left `96px`, gap `56px`; 2px line `--line` with violet fill `calc(var(--progress)*(100% - 56px))`; index circle 56px, white, `2px --line` -> violet when `.is-active`.
- FAQ: `<details>`, `summary` 19px/700, padding `22px 0`, plus icon rotates 135deg open.
- Workflow tabs: pill track radius 16, white, active indicator `--ink` slides (`.45s cubic-bezier(.2,.8,.2,1)`).
- Easing used everywhere: `cubic-bezier(.2,.8,.2,1)`; reveals rise `36px`, stagger `calc(var(--i)*90ms)`; failsafe shows content after 4s.
- Cross-page transition: `@view-transition{navigation:auto}` (motion.css).
- Scroll progress bar: 3px, gradient violet -> highlight (motion.css).

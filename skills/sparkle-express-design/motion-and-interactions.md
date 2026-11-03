# Motion and interactions (Sparkle Express)

Source: `dist/motion.css` (MC), `dist/motion.js` (MJ), `dist/site.js` (SJ), `dist/site.css` (SC), `content/sketch.py`, `content/corporate.py`. All values below are copied from those files. No framework, no library.

## 1. Gate and fallbacks

| Item | Rule | File |
|---|---|---|
| `html.motion` class | Added by an inline `<head>` script unless `matchMedia('(prefers-reduced-motion: reduce)')` matches | `build_content.py` render() |
| Opt-in scope | Reveals, word splits, doodles, unclip, scroll-read colour, doodle icons, hero line-up are all `.motion ...` selectors | MC |
| No JS | `html.motion` never set, so every `.motion` rule is off: content is visible, static. Mobile nav is the one JS-required piece (button hidden above 880px) | MC/SC |
| Reduced motion | No `.motion`; `@view-transition{navigation:none}`; SC global rule sets animation and transition duration `.01ms !important`, delay 0, `scroll-behavior:auto`; sketch intro skipped; sparkBurst skipped; smooth scrolls become `auto` | MC, SC l.390 |
| Failsafe | Every hidden initial state has a `0s` animation with a 4s delay that forces the visible end state (`reveal-failsafe`, `media-failsafe`, doodle-icon `sk-draw 0s 4s`). Keep this pattern for any new hidden-until-JS state | MC |
| Still on under reduced motion | Scroll progress bar, header tucking, `.is-scrolled` hairline, process rail fill, tabs, footer email letter split. Only `.motion`-gated and animated pieces turn off | MJ, SJ |

## 2. Cross-document View Transitions (MC)

- `@view-transition{navigation:auto}`; `.site-header{view-transition-name:site-header}` keeps the header out of the root snapshot.
- Old page: `vt-out .32s cubic-bezier(.4,0,1,1) both` to `opacity:0; translateY(-28px) scale(.985); blur(3px)`.
- New page: `vt-in .62s cubic-bezier(.16,.84,.24,1) both` from `clip-path:inset(100% 0 0 0 round 32px 32px 0 0); translateY(60px)` to `inset(0 0 0 0 round 0)` (sheet wipes up).
- Unsupported browsers navigate normally. Needs same-origin pages and no JS.

## 3. Reveals and word splits

| Effect | Trigger | Values |
|---|---|---|
| `.reveal` block rise | IntersectionObserver adds `.is-in` once, then unobserves | start `opacity:0; translateY(36px)`; opacity `.8s`, transform `.9s`, both `cubic-bezier(.2,.8,.2,1)`; delay `calc(var(--i) * 90ms)` |
| Stagger `--i` | MJ: index among siblings that also have `.reveal`, capped `Math.min(i,5)` | max delay 450ms |
| Split words | MJ `splitWords()` on `.display-title, .section-title`; text nodes only, recurses into `.muted`/`.hero-idea`, skips `<br>`; wraps each word `<span class=w --w=n><span>word</span></span>`; adds `.split-words` | `.w` is `inline-block; overflow:hidden; vertical-align:top; padding:0 .08em .08em; margin:0 -.08em -.08em`; inner `translateY(105%)` to none, `.9s cubic-bezier(.2,.8,.2,1)`, delay `calc(var(--w) * 55ms)` |
| Ink fill | `.display-title .muted` words start outlined, then colour to `var(--ink)` | colour transition `.9s ease`, delay `calc(.75s + var(--w) * 120ms)` (transform delay stays `--w * 55ms`) |
| Outline type (static) | `.display-title .muted, .hero-idea`: `color:var(--paper); -webkit-text-stroke:4px var(--ink); paint-order:stroke fill`; hero-idea stroke `clamp(3px,.44vw,6px)` | SC l.56, l.115 |
| Doodle underline | MJ adds `.doodle` to every `.eyebrow`; yellow `#ffd43b` SVG wave as background, `background-size 0% to 100% 9px`, `.9s cubic-bezier(.6,.1,.3,1)`, delay `.35s`, `padding-bottom:9px` | MC |
| Media unclip | MJ adds `.reveal-media` to `.image-frame, .wide-photo, .photo-story-image` | start `clip-path:inset(8% 6% 8% 6% round var(--r-media))`, img `scale(1.12)`; end `inset(0)` + `scale(none)`; clip `1.1s`, img `1.4s`, both `cubic-bezier(.2,.8,.2,1)`. `.photo-story-image` instead starts `inset(0 18% 0 0)`, radius 0 |
| Doodle icons | `.build-card.is-in .doodle-icon *` draw with `sk-draw 1.2s cubic-bezier(.6,.1,.3,1)`, delay `calc(.25s + var(--i) * 120ms)`; hover replays `icon-redraw 1s`. Paths carry `pathLength="1"`, `stroke-dasharray:1` | SC l.205-209 |
| Hero headline | CSS only, no IO: each `h1>span` runs `line-up 1s cubic-bezier(.2,.8,.2,1) backwards`; 2nd span delay `.14s`; from `clip-path:inset(0 0 100% 0); translateY(.35em)` to `inset(0 0 -20% 0)`. Hero h1 is NOT split into words (outlined glyphs render cleanly per line) | MC |

Observer config (MJ): `threshold:.12`, `rootMargin:'0px 0px -6% 0px'`; targets `.reveal, .split-words, .doodle, .reveal-media`; observing starts after two `requestAnimationFrame`s so above-the-fold items still animate. Needs `IntersectionObserver`: without it, with `html.motion` set, `.reveal` blocks stay hidden until the 4s CSS failsafe (`.motion .reveal:not(.is-in)` in motion.css) shows them.

## 4. Scroll-driven pieces

| Piece | How | Values |
|---|---|---|
| Scroll progress bar | MJ appends `div.scroll-progress[aria-hidden]` to body; sets `--scroll` = scrollY / (scrollHeight - innerHeight), 4 decimals | fixed top, `height:3px`, `z-index:60`, `linear-gradient(90deg,var(--violet),var(--highlight))`, `transform:scaleX(var(--scroll))`, origin `0 50%`, `pointer-events:none` |
| Tucking header | MJ onScroll: if `|delta|>4` toggle `.is-tucked` = `delta>0 && y>240 && !header.contains(activeElement)`; skipped while mobile nav `aria-expanded="true"` | `transform:translateY(-100%)`, `.45s cubic-bezier(.2,.8,.2,1)`; `.site-header:focus-within{transform:none}` |
| Header hairline | SJ `.is-scrolled` when `scrollY>8` | border-colour transition `.25s` |
| Parallax | CSS scroll timeline, only inside `@supports (animation-timeline:view())` | `.wide-photo img, .photo-story-image img`: `animation:drift linear both; animation-timeline:view(); animation-range:entry 0% exit 100%`; `drift` moves `object-position` `50% 0%` to `50% 100%` (needs images taller than frame via object-fit cover) |
| Scroll-read text | Any element with `data-scroll-read`: MJ splits text into `span.read-word`; reading line = `innerHeight * .62`; `progress = clamp((line - box.top) / (box.height + innerHeight * .15), 0, 1)`; first `round(progress * wordCount)` words get `.is-read` | unread `color-mix(in srgb,var(--ink-2) 28%,transparent)`, read `var(--ink)`, `transition:color .25s`; only styled under `.motion` |
| Process rail | SJ on `.process-timeline`: `--progress` = clamp((innerHeight*.55 - box.top)/box.height, 0, 1) (3 dp); step gets `.is-active` when its top < `innerHeight*.55` | rail fill `height:calc(var(--progress) * (100% - 56px))`, `transition:height .15s linear`; dot turns violet `.3s`; step `h3` outline to solid ink `.7s ease` (`-webkit-text-stroke:1.5px`) |
| Scroll handler | One passive listener, throttled with `requestAnimationFrame` flag | MJ, SJ |

## 5. Marquee (MC, MJ)

- Markup: `.marquee[aria-hidden] > .marquee-track` of `.mq-item` and `.mq-spark`; alternate items use `.mq-hand`. JS clones the children once (seamless loop at `scrollWidth/2`).
- Loop (rAF, only under `.motion`): `offset = (offset + (0.6 + boost) * direction + half) % half`; `translateX(-offset px)`; `boost *= .92` per frame. Scroll adds `boost = min(18, boost + |delta| * .12)`; `direction = delta>0 ? 1 : -1`.
- Look: item `font-size:clamp(36px,5.4vw,80px); weight 800; letter-spacing:-.045em`; outlined (`-webkit-text-stroke:2px var(--ink)`, fill paper); `.mq-hand` Kalam 700, violet; spark = 4-point star `clip-path:polygon(50% 0,62% 38%,100% 50%,62% 62%,50% 100%,38% 62%,0 50%,38% 38%)`, `clamp(20px,2.4vw,34px)`, highlight yellow; gap `clamp(24px,3vw,44px)`; band has `border-block:1px solid var(--line)`.
- Reduced motion: track is static (cloned but not moved).

## 6. Hero sketch-to-reality slider

Markup (`idea_stage()` in corporate.py): `figure.idea-stage[style=--split:52%;--ratio:W/H] > .stage-frame > img + .sketch-layer(svg) + span.stage-tag.tag-idea + span.stage-tag.tag-reality + .stage-handle(aria-hidden) + label.sr-only + input.stage-range[type=range min=0 max=100 value=52 step=1]` then `figcaption`. Hero uses `fetchpriority="high"`, others `loading="lazy"`. Tags and handle are `aria-hidden`; the range input is the only control for assistive tech.

| Part | Value (SC l.118-150) |
|---|---|
| Frame | `aspect-ratio:var(--ratio,1672/941)`, `border-radius:var(--r-media)` (28px; 18px at <=640px), `overflow:hidden`, bg `#0c0a18`, `touch-action:pan-y`, `cursor:ew-resize`, `user-select:none` |
| Sketch layer | `position:absolute; inset:0; clip-path:inset(0 calc(100% - var(--split)) 0 0)` (sketch shows left of the split; real image underneath) |
| Handle | 2px white line at `left:var(--split)`; 54px white circle (42px at <=880px) with two chevrons; hover `scale(1.08)` `.2s`; `:has(.stage-range:focus-visible)` gives 3px highlight outline |
| Range input | `opacity:0; pointer-events:none`, full size, so it is focusable but not clickable; pointer events are handled on the frame |
| Tags | `.tag-idea` Kalam 22px violet on `#f7f8fc`, rotated -2deg, left 18px; `.tag-reality` white 13px/700 on `#17142b99` pill with blur, right 18px; top 18px (10px mobile) |

Behaviour (SJ `initStage`):
- `setSplit(v)` writes `--split` as `v.toFixed(2)%` and `range.value = round(v)`.
- Input event on range: stop intro, set split from range (keyboard: arrows/Home/End/PgUp/PgDn are native range behaviour, step 1).
- Pointer: `pointerdown` captures the pointer and sets split from `(clientX - left) / width * 100` clamped 0-100; `pointermove` updates only while captured; `dragstart` is prevented. Vertical page scroll stays native (`touch-action:pan-y`).
- Any user input calls `takeOver()`: intro cancelled, `.is-revealing` added.
- Intro (skipped under reduced motion): add `.is-drawing .is-paused`, `setSplit(100)` (all sketch, handle and reality tag hidden). Hero plays on load; other stages wait for an IntersectionObserver at `threshold:.35`. `play()`: remove `.is-paused` (strokes draw), after `2500ms` add `.is-revealing`, then animate split 100 to 52 over `1300ms` with ease-in-out cubic `t<.5 ? 4t^3 : 1 - (-2t+2)^3/2`.
- Draw CSS: `.is-drawing .sk-ink :is(path,rect,circle){stroke-dasharray:1; stroke-dashoffset:1; animation:sk-draw 1.5s cubic-bezier(.6,.1,.3,1) var(--d,0s) forwards}`; notes fade `sk-fade .6s ease 1.9s`; `.is-paused` pauses both. Group delays `--d`: `0s`, `.45s`, `.9s`.

Sketch SVG (`content/sketch.py`, one string `SKETCH`): `viewBox="0 0 1672 941"`, `aria-hidden`, `focusable=false`. Same size as the photo so it overlays 1:1.
- `<defs>`: pattern `sk-grid` 40x40 with `M40 0H0V40`, stroke `#dde0ec` 1.5; filter `sk-rough` = `feTurbulence fractalNoise baseFrequency=0.035 numOctaves=2 seed=7` + `feDisplacementMap scale=5` (the wobble that makes lines look hand-drawn).
- Background: full rect `#f7f8fc`, then grid rect.
- `g.sk-ink` (filter `sk-rough`, `fill:none`, round caps and joins; CSS stroke `#2d2858`, width 3): three groups = tablet-style screen (left), laptop with chart, donut, list, cards, keyboard (centre), phone (right). EVERY path, rect and circle has `pathLength="1"` so the dash draw works for any length.
- `g.sk-notes` (Kalam 34px, fill violet): yellow marker blob `.sk-mark` (`color-mix(highlight 55%, transparent)`) around the donut, violet hand arrows `.sk-arrow` (3px), notes "a home for the big idea?", "admin view", "phones too!" (`text-anchor:end`), and small "show progress" (27px).
- To adapt: keep the viewBox equal to the photo's ratio, keep `pathLength="1"` on all strokes, group by `--d` delay, keep text in Kalam.

## 7. Workflow tabs (SJ, SC l.173-195)

- Markup: `.workflow-track > .wf-tabs[role=tablist][aria-label] > button.wf-tab[role=tab][id=wf-tab-N][aria-controls=wf-panel-N][aria-selected] + span.wf-indicator[aria-hidden]`; panels `div.wf-panel[role=tabpanel][id][aria-labelledby][tabindex=0]` with `.wf-lane.wf-people` (grid paper), `.wf-lane.wf-agents` (night bg, spark bullet) and `p.wf-outcome`. Markup marks tab 1 selected (enumerate starts at 1, `aria-selected = i==1`); JS sets `tabIndex 0` on the first tab only and `hidden` on the other panels. Without JS all panels stay stacked and visible.
- Roving tabindex; ArrowLeft/ArrowRight wrap, Home/End jump; `preventDefault` stops page scroll; selection follows focus; click selects.
- Indicator: `width` and `translateX` set from `offsetWidth/offsetLeft`, transition `.45s cubic-bezier(.2,.8,.2,1)`; recalculated on resize and `document.fonts.ready`. Selected tab text turns `#fff` over the dark `var(--ink)` pill.
- Panel enter: remove/re-add `.is-entering` with a forced reflow; `wf-in .4s cubic-bezier(.2,.8,.2,1)` (from `opacity:0; translateY(10px)`). Selected tab `scrollIntoView({block,inline:'nearest', behavior: smooth|auto})`.
- Pre-JS state: `.wf-tabs:not(.is-ready)` hides the indicator and paints the selected tab dark itself.

## 8. Brief builder (SJ, `CONTACT`/`BRIEF` in corporate.py)

- Fields (all in `fieldset.brief-fields[disabled]` until JS finishes): project name (`#project-name`, required, max 100), type select (Custom software, SaaS product, Education platform, Mobile experience, Workflow or integration, Something else), stage select (`idea`, `scope`, `existing`; `?stage=` query preselects), description (`#project-description`, required, min 20, max 4000), context (optional, max 2000). `<noscript>` message replaces the tool without JS.
- Meter: `score = (name>=2 chars) + min(1, descLen/60) * 2 + (context ? 1 : 0)`, `fill = score/4` -> `--fill`; label `rough sketch` (<.35), `taking shape` (>=.35), `ready to build` (>=.75). Bar: 6px dashed track, violet fill, width transition `.5s cubic-bezier(.2,.8,.2,1)`, label Kalam 20px violet.
- Submit: `preventDefault`; custom validity (name <2 chars, description <20 chars); on success fill read-only `#brief-output` with `PROJECT BRIEF`, title, type, stage text, description, optional context, and a footer saying it is a local draft; reveal `#brief-result`; `role=status aria-live=polite` message; focus `#brief-result-title` (`tabindex=-1`, `preventScroll`), then smooth scroll.
- Mailto: `mailto:<studio mailbox>?subject=Project brief: <title>&body=<brief>`; built by code points; shrinks by 10% steps until the URL <= 1900 chars, appending a "[Brief shortened...]" notice; fallback is subject only. Any form `input` event resets link, hides result, clears validity.
- Copy: `navigator.clipboard.writeText`; on failure selects the textarea and tells the user to copy by keyboard. Download: Blob `text/plain;charset=utf-8`, file `sparkle-project-brief.txt`, URL revoked after 1000ms. The copy, fallback-select and download statuses say "Nothing has been sent"; the create status ("Your brief is ready. Email it …, copy it, or save it to your device.") does not.
- Never submits, stores, or fetches: no `fetch`, no storage, no analytics.
- `sparkBurst(target)`: 9 `.spark-burst` stars at the target centre, angle `2PI*i/9 + rand*.4`, distance `46 + rand*40`px, scale `.6 + rand*.7`, rotate 120deg, `650 + rand*250`ms, `cubic-bezier(.2,.8,.2,1)`; removed on finish; skipped under reduced motion.

## 9. Mobile navigation (SJ, SC l.358-364)

- Button `.nav-toggle[aria-controls=primary-nav][aria-expanded][aria-label]`, 44px, two bars morph to an X (`translateY(+-4px) rotate(+-45deg)`, `.25s`). Label flips `Open navigation` / `Close navigation`.
- Shown at <=880px; `.nav-links` becomes an absolute drop panel (`top:70px`, paper bg, 18px links) toggled by `.is-open`. Above 880px the nav is plain links with no JS.
- Closes on link click, `Escape` (focus returns to the button), and any click outside `.site-header`. The tuck logic never hides the header while the menu is open.
- Skip link `a.skip-link` to `#main` is the first element; `:focus-visible` is a 3px violet outline, offset 4px.

## 10. Footer email wave (MC, MJ)

MJ splits `.footer-mail` text into `span.ch[--c=i]` (runs even without `.motion`; the link keeps its `aria-label`). Hover: each letter `translateY(-.12em)`, odd letters `.05em`, `.35s cubic-bezier(.2,.8,.2,1)`, delay `calc(var(--c) * 14ms)`.

## 11. Gotchas

- Hidden-until-reveal states need the 4s failsafe animation or a stalled script leaves blank blocks.
- Do not split-word the hero h1: the outlined `-webkit-text-stroke` glyphs clip badly; animate whole line spans instead.
- `.reveal-media` end state is `clip-path:inset(0)` (no radius) so captions below the image are never cut.
- `.w` padding and negative margins stop descenders being clipped by `overflow:hidden`.
- `splitWords` skips `<br>`; keep `<br>` in titles and never put markup that must stay interactive inside a split title.
- Stagger index caps at 5; do not rely on later siblings waiting longer.
- The progress bar, tucked header, and process rail run under reduced motion; only transitions are shortened by the global rule.
- Marquee is `aria-hidden`; real information must not live in it.
- Slider range input is `opacity:0` but must stay focusable; do not use `display:none` or `visibility:hidden`.
- The brief form's `?stage=` value is only applied if it is `idea`, `scope`, or `existing`.
- Portfolio filters: the README lists them, but no filter markup or code exists in `site.js` or `corporate.py` (UNVERIFIED as a feature). Do not document or build them from this source.
- Motion was read from source only; no live browser run was done for this file.

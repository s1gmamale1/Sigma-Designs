# Motion system (marketing site)

Source: `src/marketing/` of the Akademiya Frontend repo (its main/dev branch). Paths below are relative to it. Contracts are pinned by `siteMotion.test.tsx`, `familiarBeats.test.tsx`, `marketingNav.test.tsx`.

## 0. Principles

- Motion only where it means something: arrival (reveal), place (nav, sky), state (carousel fill), press feedback.
- Reduced motion = a calm, fully visible page. Nothing hidden, no transforms, no timers that start themselves.
- Server HTML and no-JS never hide content. Hiding is armed by a hook after hydration (`data-reveal-state="armed"`), never by default CSS.
- CSS scroll timelines are wrapped in `@supports (animation-timeline: view())` AND `@media (prefers-reduced-motion: no-preference)`. Without them everything rests in its final state.
- One entrance per visual. Never nest reveals; never reveal the first screen.
- Spring ease token: `--mk-spring: cubic-bezier(.16, 1, .3, 1)` (on `.mk-site`, `styles/motion.css`).

## 1. Lenis (`useSiteMotion.ts` `useSmoothScroll`)

| Item | Value |
|---|---|
| Options | `{ lerp: 0.05, autoRaf: true, anchors: true, allowNestedScroll: true }` |
| Starts when | hydrated, not reduced motion, `ResizeObserver` exists. Else returns `null` |
| Anchors | `#landing-main section, #landing-main [id] { scroll-margin-top: 6.125rem }` (78px nav + 20px air); Lenis subtracts scroll-margin itself, so no JS offset |
| Mobile sheet | a `MutationObserver` on `<html class>` calls `stop()` while `mk-sheet-open` is set, `start()` otherwise |
| Teardown | disconnect observer, `destroy()`, state back to null |
| CSS | `html.lenis, html.lenis body { height:auto }`; `.lenis-stopped { overflow: clip }`; `[data-lenis-prevent] { overscroll-behavior: contain }`; `.lenis-smooth iframe { pointer-events: none }` (`motion.css`) |

## 2. Reveal (`useReveal`, `motion.css`)

Markup: `data-reveal="rise"` (the block) or `data-reveal="stagger"` (its children, in order).

| Item | Value |
|---|---|
| Arm | only nodes with `getBoundingClientRect().top > innerHeight * 0.92` at hydration. Sets `data-reveal-state="armed"` |
| Fire | `IntersectionObserver` `{ threshold: 0.1, rootMargin: '0px 0px -8% 0px' }`; on `isIntersecting` set `data-reveal-state="in"` and `unobserve` |
| Skipped | reduced motion, no IO, no hydration. Cleanup deletes the state attr |
| rise armed | `opacity 0; translateY(42px) scale(.965); blur(14px)` |
| rise transition | `opacity/transform/filter 1050ms var(--mk-spring)` (set on `[data-reveal="rise"][data-reveal-state]`, so armed -> in animates) |
| stagger armed | children `opacity: 0` |
| stagger in | child `animation: mk-rise-in .95s var(--mk-spring) backwards`; keyframe from `opacity 0; translateY(28px) scale(.92); blur(12px)` |
| stagger delays (nth-child) | 1: .06s, 2: .16s, 3: .26s, 4: .36s, 5: .46s, 6: .56s, 7+: .66s |
| Reduced motion | `[data-reveal][data-reveal-state]` and `> *` forced `opacity 1; transform none; filter none; transition none; animation none` |

Rules: never nest `data-reveal` inside `data-reveal`. A figure that spins in (`data-tilt`) gets its box exempt: `.mk-site [data-reveal="stagger"][data-reveal-state] > .mk-cure__visual:has([data-tilt]) { animation:none; opacity:1 }` (`tilt.css`).

Static-page fallback (`site-layer.css`): where `animation-timeline: view()` exists, legacy `.ak-rise` / `.ak-stagger > *` reveal by `view()` timeline (`entry 0% entry 55%` / `entry 0% entry 70%`, from `opacity 0; translateY(36px) scale(.97)`), so first-viewport content is visible before the bundle loads. Cross-document page transition: `@view-transition { navigation: auto }`, old `.3s cubic-bezier(.4,0,1,1)` to `opacity 0; translateY(-8px)`, new `.6s cubic-bezier(.16,1,.3,1)` from `opacity 0; translateY(12px)`; off under reduced motion.

## 3. Hero scroll timelines and cloud drift (`styles/hero.css`)

Host `.mk-hero--sky { view-timeline: --mk-hero block; min-height: 100svh; overflow: clip }`. Sky photo is cut into 3 same-box 3:2 images (bare gradient, left bank, right bank, each bank as its own alpha image) so `object-fit: cover; object-position: center top` lands them on the same pixels.

| Layer | Animation | Range | End value |
|---|---|---|---|
| `.mk-hero__sky` (mask `linear-gradient(to bottom, #000 12%, transparent 74%)`) | `mk-sky-drift linear both` | `exit 0% exit 100%` | `translateY(30%)` (slower than page; top edge never shows) |
| `.mk-hero__cloud-layer--left/right` | `mk-clouds-part-left/right linear both` | `exit 0% exit 75%` | `translateX(-36%/36%)`, `opacity` 1 until 53% of the range (= 40% of the way) then 0 |
| `.mk-hero--sky .mk-shell` (heading) | `mk-hero-lift linear both` | `exit 0% exit 70%` | `translateY(-150px)` |

Each bank has its own layer so the scroll drift (layer) composes with the load drift (image).

Load drift (no-preference only): `.mk-hero__clouds--left { animation: mk-clouds-left 6s cubic-bezier(.2,.55,.3,1) .1s both }`, right likewise. Keyframes: `from opacity 0; translateX(-12%)` (right: `+12%`), `25% opacity 1`, `to none`.

Also: two red dot grids `radial-gradient(rgba(236,3,29,.18) 1.4px, transparent 1.5px)`, size 19px, boxes 150x96px; right grid hidden at <=640px.

## 4. Sky washes (`SkyWash.tsx`, `motion.css`)

- Host needs class `mk-has-sky` (`position: relative; overflow-x: clip`); every host child except the wash gets `position: relative; z-index: 1`.
- `.mk-sky-wash`: `position:absolute; top:0; z-index:0; width:72%; height:min(100%,56rem); opacity:.62; mix-blend-mode:multiply; pointer-events:none; view-timeline: --mk-wash block`. Mask `radial-gradient(ellipse 54% 50% at 50% 46%, #000 0%, rgba(0,0,0,.55) 45%, transparent 74%)`. Sides: `--right { right:0 }`, `--left { left:0 }`. `--flow { top:auto }` starts where it stands (after an element).
- `img`: `width/height 100%; object-fit: cover; transform: scale(1.08)`; `loading=lazy decoding=async`, 1536x1024, `alt=""`, wrapper `aria-hidden`.
- Animation (supports + no-preference only): `mk-sky-wash linear both; animation-timeline: --mk-wash; animation-range: cover 0% cover 100%`.
  Keyframes: `0% opacity 0; translateY(90px) scale(1.16)` / `22% opacity 1` / `60% opacity 1` / `100% opacity 0; translateY(-90px) scale(1.02)`.
- <=640px: `width:120%; opacity:.4`; right `-10%`, left `-10%`.
- Four assets: `/landing/img/sky-deco-1..4.webp`.

## 5. Round red next-section button (`components/NextSection.tsx`, `motion.css`)

Client-only, mounted once live. Class `ak-cue`, bottom centre, `aria-label` from copy, 22px chevron.

| Behaviour | Contract |
|---|---|
| Sections | top-level `<section>`s of `#landing-main` (not nested: `!parentElement.closest('#landing-main section')`) |
| `isAhead(s)` | `rect.top - scrollMarginTop > 10`. A section resting at its scroll-margin is already current. This is what stops the button sticking on a margin-rested section |
| Advance | next section where `isAhead`. Lenis: `scrollTo(next, { duration: 1.1, easing: t => 1 - (1-t)**4 })`; else `scrollIntoView({ behavior: reduce ? 'auto' : 'smooth', block: 'start' })` |
| Hide while moving | on scroll set `moving`, clear after `IDLE_MS = 650`; renders `data-moving` => `opacity:0; pointer-events:none`. Stays MOUNTED so keyboard focus survives |
| Focus | keyboard focus (`:focus-visible`, true if unsupported) keeps it visible while moving; mouse-click focus does not. Enter/Space sets focused |
| End | `atFoot` = `scrollY >= scrollHeight - innerHeight - 2` OR last section not `isAhead`. Then returns null. If it held focus, focus moves to the last section (`tabIndex=-1`, `preventScroll`) first |
| Park | any `[data-cue-park]` with `isIntersecting && ratio >= 0.25` (threshold .25) sets `data-mk-cue-park` on `<html>` => `left:auto; right:1.25rem; transform:none` |
| Entry | `animation: mk-cue-in .35s ease both` (no-preference only) |
| Focus ring | `outline: 3px solid var(--mk-ink,#151922); outline-offset: 3px; box-shadow: 0 0 0 6px #fff` |

## 6. "Sound familiar?" carousel (`components/FamiliarBeats.tsx`, `styles/familiar.css`)

Static HTML = a plain scrollable list (crawlers, no-JS, first client render). Dots/timer exist after hydration (`useHydrated`). Section: `id=familiar data-nav-theme="dark" data-cue-park`; head `data-reveal="rise"`, track `<ol tabIndex=0 data-reveal="stagger">`.

| Item | Value |
|---|---|
| Slide time | `SLIDE_MS = 6000`; also `--mk-slide-ms` for the fill |
| Runs when | `live && playing && onScreen && pageShown && !ended` |
| On screen | IO `threshold .35`, gate `isIntersecting && ratio >= .35` (no IO => on) |
| Page visibility | `visibilitychange` -> `pageShown = !document.hidden` |
| Pause keeps time | timer cleanup stores `left = max(0, left - elapsed)`; resume continues the same card |
| Last card | at end sets `ended`; toggle becomes Replay -> `goTo(0)`, intent `play` |
| Intent | `'auto' \| 'play' \| 'pause'`. playing = `play` or (`auto` and not reduced). Reduced motion waits for Play |
| Advance | `track.scrollTo({ left: card.offsetLeft - cards[0].offsetLeft, behavior: reduce ? 'auto' : 'smooth' })` |
| Steering window | own slide: `STEER_MS = 900`, extended `STEER_TAIL_MS = 200` after each scroll event so a long replay glide stays ours |
| Visitor input | `pointerdown`, `keydown`, `touchstart`, `wheel` on the track stamp `lastInput`; a track scroll within `INPUT_MS = 1000` of it => takeover (clears steering, intent `pause`), even inside a steering window |
| Keyboard focus | `focusin` with `:focus-visible` => takeover; pointer focus does not |
| No input behind a scroll | snap settle, resize, rotation: only syncs the active dot (nearest card; at scroll end = last) |
| pointerdown alone | does NOT pause (a vertical page swipe can start on a card) |
| Scroll off last | `next !== last` clears `ended` |
| Cards | live: `opacity .55`, active `1`; detail + number `opacity 0` unless active. Armed reveal: `.mk-site .mk-familiar__track[data-reveal-state="armed"] > .mk-familiar__card { opacity: 0 }` (specificity beats `is-active`, no blink) |
| Track | `grid-auto-columns: min(calc(100% - 3rem), 50rem)`; `scroll-snap-type: x mandatory`; gutter `max(1rem, (100% - 1200px)/2)`; scrollbar hidden when live |
| Dots | pill `min-height 3.25rem`, glass `rgba(247,244,250,.1)` blur 18px. Dot hit area `min-width 1.5rem` (24px) x `2.25rem`; pip .5rem; active pip `2.75rem` wide with fill `mk-dot-fill var(--mk-slide-ms) linear both`, `animation-play-state: paused` until `.is-running` |
| Coarse pointer | dot `2.75rem` (44px) square, toggle 2.75rem, controls wrap. At <=340px: pill padding 0, active pip `2rem` so 7 x 44 = 308px fits 320px |
| Toggle | 3.25rem round; icons pause / play / replay (18px) |
| Reduced motion | card/detail/pip transitions off |
| Ended | `.is-ended` fill: `animation:none; transform:none` (full bar) |

The clock is JS (a `setTimeout`), never a CSS animation: the fill only shows it.

## 7. Nav motion (`components/MarketingNav.tsx`, `styles/chrome.css`, `pages/landing/useNavPress.ts`)

| Item | Value |
|---|---|
| Bar | fixed, `top:12px`, `width:min(1180px,calc(100% - 24px))`, bar `height:66px; padding:0 24px; radius 18px` |
| Pill mode query | `(hover: hover) and (pointer: fine) and (min-width: 1081px) and (prefers-reduced-motion: no-preference)` => `is-min` once `scrollY > 90` and no dropdown/sheet open |
| Elsewhere (touch, narrow, reduced) | `is-tucked`: `translateY(calc(-100% - 1.25rem))`, transition `transform .45s cubic-bezier(.2,.8,.2,1)`. Set when moving down, `|dy| > 6` and `y > 240`; shown on the way up. `:focus-within` cancels the tuck |
| Pill width | `--mk-nav-min` = brand `offsetWidth + 2*offsetLeft`, re-measured on resize and `document.fonts.ready`; floor `max(200px, var(--mk-nav-min))` |
| Gulp | `.is-min:not(:hover):not(:focus-within) .mk-nav__bar`: `max-width` to the pill, `transition-delay .38s`, `animation: mk-nav-gulp .95s cubic-bezier(.45,.05,.2,1) .38s both`. Width transition `.6s cubic-bezier(.34,1.56,.64,1)`, `transform-origin: 26px 50%` |
| `mk-nav-gulp` | 0 `scale(1,1)`; 40% `(1.02,.8)`; 62% `(.985,1.1)`; 80% `(1.006,.955)`; 100% `(1,1)` |
| Hover/focus jelly | `animation: mk-nav-jelly .8s cubic-bezier(.3,.7,.4,1)`; 0 `(1,1)`; 32% `(1.014,.88)`; 56% `(.99,1.07)`; 76% `(1.005,.965)`; 100% `(1,1)` |
| Pill hit area | `.is-min { pointer-events:none }`, bar `pointer-events:auto; overflow:hidden` (only the pill catches the pointer) |
| Controls out | `opacity 0; translateY(-9px) scale(.72); pointer-events:none`, delay `--mk-out` right to left: items 1-5 = .42/.36/.30/.24/.18s, langs .12s, sign-in .06s, CTA 0s |
| Controls in | transition `opacity .3s ease var(--mk-in)`, `transform .42s cubic-bezier(.34,1.56,.64,1) var(--mk-in)`; `--mk-in` left to right: .14/.19/.24/.29/.34s, langs .39s, sign-in .44s, CTA .49s |
| Glass | dark by default; `.is-light` swaps the tokens (`--mk-nav-glass` dark `rgba(17,19,26,.52)`, light `rgba(255,255,255,.52)`; blur 18px, saturate 150/160%). Transitions `.45s ease` on bg/border/shadow/color. Aurora drift `mk-nav-aur 46s ease-in-out infinite alternate` (no-preference) |
| Light/dark switch | IO over every `[data-nav-theme="dark"]` with `rootMargin: '0px 0px -92% 0px'` (the top 8% band under the bar); `dark = any intersecting`. Initial: Home light (sky), other pages dark. Open sheet forces `.is-light` |
| Reduced transparency | `.mk-nav:not(.is-light)` glass `rgba(18,20,26,.97)`, blur none |
| Sheet | toggles `html.mk-sheet-open` (locks scroll; Lenis stops). Escape closes and refocuses the trigger |

Press (`useNavPress('.mk-nav__bar')`, Web Animations API, id `ak-nav-press`; WAAPI beats the CSS gulp/jelly without restarting them): left button/touch or Enter/Space on any `a, button`; skipped under reduced motion.

| Constant | Value |
|---|---|
| Squeeze | `SQUEEZE_MS 150`, ease `cubic-bezier(.2,.7,.3,1)`; charge to `CHARGE_MS 1400` |
| Control | tap `(.94,.86)`, full `(.88,.72)`, gain 1.1, sideways .45 |
| Glass (`transform-origin 50% 50%`) | tap `(1.012,.9)`, full `(1.03,.8)`, gain .9, sideways -.12 |
| Release | damped cosine, `DAMPING 3.4`, 12 samples/wobble; wobbles `1.5 + 4*charge`; duration `520 + 480*charge` ms. A tap shorter than 150ms waits until 150ms before bouncing. Starts from the current computed transform (re-press mid-bounce is continuous) |

## 8. Gotchas

| Bug | Cause | Fix / rule |
|---|---|---|
| Red button stuck on a section | stepping compared raw `top`; a section resting at `scroll-margin-top` never counted as reached | `isAhead` subtracts the section's `scrollMarginTop`; end = last section not ahead, or foot of page (short last section never reaches the top) |
| Button lost keyboard focus | unmounted while moving | hide with `data-moving` (opacity), keep mounted; on end, move focus to last section first |
| Mouse click kept button visible | click also focuses in some browsers | keep-up only on `:focus-visible` / Enter / Space |
| Carousel paused by a vertical swipe | `pointerdown` alone treated as takeover | takeover only when a track SCROLL follows own input within 1000ms |
| Carousel paused by snap settle / resize | any scroll event = takeover | scroll with no recent input only syncs the dot |
| Replay glide ended its own steering | fixed 900ms window shorter than a replay across the row | extend steering 200ms after every scroll event while it moves |
| Visitor swipe ignored after auto-advance | steering window swallowed it | input within 1000ms wins inside a steering window |
| Carousel never started / never stopped | `isIntersecting` alone is true at 1px | gate on `intersectionRatio >= .35` (cue park: `>= .25`) |
| Card opacity snapped when armed | `.is-active` (1) vs armed reveal (0) fought | armed selector with higher specificity, later in file |
| A CSS animation used as a clock races under reduced motion | the bundled landing CSS forces `.landing-root * { animation-duration: 0.01ms !important }` under reduced motion, so an `animationend`-driven timer would fire instantly | timers live in JS (setTimeout with remaining time on pause); CSS only draws the fill |
| Dots under 44px on touch | 24px desktop hit area | `@media (pointer: coarse)` 44px; 320px layout re-checked (7 x 44 = 308) |
| Content hidden for no-JS / first screen | reveal hid by default | arm only after hydration and only below 92% of the viewport |
| Hero sky top edge showing | sky moved with the page | sky drifts `translateY(30%)` over the exit so it is slower than the page |
| Pill bites into logo on spring overshoot | max-width spring overshoot | `min-width: max(200px, var(--mk-nav-min))` floor |
| Press replay restarted hover jelly | swapped CSS animation-name | press uses WAAPI, not classes |
| Lenis keeps scrolling behind the sheet | scroll lock is CSS only | stop Lenis on `html.mk-sheet-open` via MutationObserver |

# Page anatomy

Source: `src/marketing/` (pages/HomePage.tsx, components/*, styles/*). Tokens and type are in `tokens-and-type.md`.

## 1. Frame (MarketingLayout.tsx)

```html
<div class="mk-site landing-root landing-conversion landing-story landing-pitch landing-v5" data-page="home">
  <a class="skip-link" href="#landing-main">…</a>
  <MarketingNav/>  <main id="landing-main">{page}</main>
  <NextSection/> (client only)  <MarketingFooter/>
</div>
```

- `mk-site` holds the `--mk-*` tokens. Body class `landing-body`. Page transitions: `@view-transition { navigation:auto }` (site-layer.css).
- Hooks mounted: Lenis smooth scroll, `useReveal`, `useTilt`, `usePhone3d`.
- Round red cue button (`.ak-cue`, `NextSection`): bottom centre, steps to the next top-level `<section>` of `<main>`; fades out while the page moves (`data-moving`); gone at the last section. `data-cue-park` on a block (the familiar section) parks it right (`left:auto; right:1.25rem`) while that block is on screen.

## 2. Light vs dark and why

| Section | Theme | Why |
|---|---|---|
| Sky hero | light (`data-nav-theme="light"`) | opening is a clear sky over paper, name in ink |
| "Sound familiar?" | dark velvet (inside `.mk-velvet.mk-home-canvas`) | the school's bad week, shown in the dark so the turn reads as relief |
| Turn "Let's fix this." | dark → paper gradient ("lights on") | text flips white → ink on scroll |
| Cures, people | paper, sky washes | the answers, in daylight, beside real captures |
| Pilot band | dark (`data-nav-theme="dark"`) | closes with the offer on velvet |
| Demo contact form | light (landing component `DemoContact`) | form on paper |
| Footer | dark (`data-nav-theme="dark"`) | |
| Inner-page header | dark | every page except Home opens on velvet |

- Nav starts dark on non-home pages (`useState(page !== 'home')`), light on Home; an IntersectionObserver (`rootMargin: 0 0 -92% 0`, top 8% of screen) flips it when any `[data-nav-theme="dark"]` is under the bar.

## 3. Home section order (HomePage.tsx)

1. Sky hero `section.mk-hero.mk-hero--sky`
2. Dark canvas `div.mk-velvet.mk-dark.mk-home-canvas` containing `FamiliarBeats`
3. `section.mk-cures.mk-has-sky#cures` = turn + cure rows
4. `section.mk-people.mk-has-sky`
5. `section.mk-velvet.mk-pilot#pilot`
6. `DemoContact` form (`#demo-contact`)

### 3.1 Sky hero (hero.css)

```html
<section class="mk-hero mk-hero--sky" data-nav-theme="light" aria-labelledby="mk-hero-title">
  <div class="mk-hero__sky" aria-hidden>
    <img src="/landing/img/hero-sky-base-1.webp" width=1536 height=1024 fetchpriority=high>
    <span class="mk-hero__cloud-layer mk-hero__cloud-layer--left"><img class="mk-hero__clouds mk-hero__clouds--left" src=".../hero-clouds-left-1.webp" 1152x768></span>
    <span class="mk-hero__cloud-layer mk-hero__cloud-layer--right">… hero-clouds-right-1.webp</span>
  </div>
  <span class="mk-hero__dots mk-hero__dots--left"/> <span class="mk-hero__dots mk-hero__dots--right"/>
  <div class="mk-shell">
    <h1 id="mk-hero-title" class="mk-hero__brand"><span class="mk-hero__wordmark">akademiya.ai</span> <span class="mk-hero__definition">…</span></h1>
    <p class="mk-hero__lead">…</p>
  </div>
</section>
```

| Item | Spec |
|---|---|
| Box | grid, `align-content:center; min-height:100svh; padding:var(--ak-nav-h,78px) 0 clamp(5rem,12svh,8rem); overflow:clip; bg paper; text-align:center` |
| Sky layer | `absolute inset:0; z-index:0`; mask `linear-gradient(to bottom,#000 12%,transparent 74%)`; images `object-fit:cover; object-position:center top` (all three are 3:2 so they align) |
| Clouds on load | left `translateX(-12%)` → 0, right `+12%` → 0; opacity 0 → 1 by 25%; `6s cubic-bezier(.2,.55,.3,1) .1s both` |
| Dots | `150×96px`; `radial-gradient(rgba(236,3,29,.18) 1.4px, transparent 1.5px)`, size `19px 19px`; left `bottom:20%; left:7%`; right `top:46%; right:9%` (hidden ≤640px); z-index 1 |
| Shell | `z-index:2` |
| Gap definition | `margin-top: clamp(1.15rem,2.6svh,1.6rem)`; lead `margin: clamp(.9rem,2svh,1.35rem) auto 0` |
| Scroll (only with `animation-timeline: view()` and motion allowed) | section `view-timeline: --mk-hero block`; sky drifts `translateY(30%)` over `exit 0–100%`; cloud layers part `translateX(∓36%)` and fade (opacity 1 at 53%) over `exit 0–75%`; shell lifts `translateY(-150px)` over `exit 0–70%` |

- The h1 holds name + definition (one heading); the lead is a `<p>`.

### 3.2 "Sound familiar?" canvas (familiar.css, home.css)

```html
<div class="mk-velvet mk-dark mk-home-canvas">
  <span class="mk-bloom mk-bloom--red"/> <span class="mk-bloom mk-bloom--violet"/>   <!-- violet at bottom:0 -->
  <section class="mk-familiar [is-live is-running is-ended]" data-cue-park aria-labelledby="mk-familiar-title">
    <div class="mk-familiar__head" data-reveal="rise"><h2 class="mk-familiar__title"/><p class="mk-familiar__sub"/></div>
    <ol class="mk-familiar__track" data-reveal="stagger" tabindex=0>
      <li class="mk-familiar__card [is-active]"><span class="mk-familiar__n">01</span><p class="mk-familiar__line"/><p class="mk-familiar__detail"/></li> × 7
    </ol>
    <div class="mk-familiar__controls"><div class="mk-familiar__dots"><button class="mk-familiar__dot [is-active]"><span class="mk-familiar__pip"><span class="mk-familiar__fill"/></span></button> × 7</div><button class="mk-familiar__toggle"/></div>
  </section>
</div>
```

| Item | Spec |
|---|---|
| Copy | title "Sound familiar?", sub "A normal week at most schools.", 7 cards (home.ts `pains`) |
| Track | grid, `grid-auto-flow:column; grid-auto-columns:min(calc(100% - 3rem),50rem); gap:clamp(1rem,2vw,1.5rem); margin-top:clamp(2rem,4vw,3rem); padding-inline:var(--mk-gutter)`; `overflow-x:auto; scroll-snap-type:x mandatory`; first card aligns to the 1200px column, next peeks in |
| Card | `min-height:clamp(19rem,50svh,29rem); padding:clamp(1.5rem,3vw,2.75rem); border:1px solid var(--mk-line-dark); radius 28px`; bg `radial-gradient(110% 80% at 0% 0%, rgba(236,3,29,.13), transparent 60%), linear-gradient(160deg,#241828,#170f1b)`; `scroll-snap-align:start`; line is pushed to the bottom (`margin:auto 0 0; padding-top:2rem`) |
| Live state | inactive card opacity .55, active 1 (`.6s var(--mk-ease)`); detail and number show only on the active card (`.4s`); armed-for-reveal cards start at opacity 0 |
| Timer | `SLIDE_MS = 6000` per card, runs only while ≥35% on screen, tab visible, not paused; reduced motion waits for Play |
| Dots pill | bg `rgba(247,244,250,.1)`, `blur(18px)`, height 3.25rem; pip `.5rem` circle, `rgba(247,244,250,.42)`; active pip `width:2.75rem` (2rem at ≤340px coarse) with a white fill animating `scaleX(0→1)` over `--mk-slide-ms`; toggle 3.25rem round (pause / play / replay) |
| Touch (`pointer:coarse`) | dots and toggle at least 2.75rem (44px); controls wrap |
| Static HTML | the same `<ol>` as a plain scrollable row (no JS, crawlers); `is-live` adds the dots and the timer |

### 3.3 Turn + cures (home.css, motion.css)

```html
<section class="mk-cures mk-has-sky" id="cures" aria-labelledby="mk-turn-title">
  <div class="mk-turn"><h2 id="mk-turn-title" class="mk-turn__line">Let’s fix this.</h2><p class="mk-turn__intro">Introducing Akademiya AI for Schools!</p></div>
  <SkyWash sky={3} side="right" flow/>
  <div class="mk-shell">
    <article class="mk-cure [mk-cure--flip on odd index]" data-reveal="stagger">
      <div class="mk-cure__copy"><p class="mk-cure__answers"/><h3 class="mk-cure__title"/><p class="mk-cure__body"/></div>
      <div class="mk-cure__visual"><PanelShot|PhoneShot/></div>
    </article> × 4
  </div>
</section>
```

| Item | Spec |
|---|---|
| `.mk-cures` | bg paper, color ink, `padding-bottom: clamp(3rem,7vw,6rem)` |
| `.mk-turn` | grid, `place-items:end center; min-height:clamp(20rem,58vh,36rem); padding:4rem 1rem clamp(2rem,6vh,4rem); gap:clamp(.75rem,1.6vw,1.25rem); text-align:center`; bg `linear-gradient(to bottom, #140d17 0%, #1d1322 18%, #e9e2ee 58%, #fbfcff 100%)` |
| Lights-on (view timeline) | `::before` velvet overlay fades opacity 1 → 0; line colour `#fff` → ink; intro `#ff5a6e` → red-ink; all `animation-range: entry 10% cover 55%`. At rest (no timelines / reduced motion) line is ink on the light end |
| Cure rows | 4 rows, answers a pain each: director (panel), parents (phone), teachers (panel), honesty (phone + tutor card). Even index copy-left, odd index flipped |
| Panel capture | `figure.mk-panel[data-tilt="panel"]`, `perspective:1800px`, img radius 18px, plane `rotateY(-9deg)` (flip `+9deg`) `rotateX(4deg)`; hover lift 36px |
| Phone capture | `figure.mk-phone[data-tilt="phone"]`, `width:min(300px,72vw)`; body `rotateY(10deg) rotateX(3deg)`, hover lift 28px; screen has a 38px status-bar band; island `top:22px; width:30%; height:22px; bg #050407`; optional WebGL phone replaces the CSS drawing when `data-phone3d="ready"` |
| Tutor card | `.mk-tutor-card`: white, radius 20px, `rotate:-2deg`, button `#5a43e8` radius 12px; positioned by tilt.css `.mk-phone__overlay` |
| Spin-in | `--mk-spin-y: -55deg` (flip and phone `55deg`) on entry |

### 3.4 Sky wash (SkyWash.tsx, motion.css)

- Markup: `<div class="mk-sky-wash mk-sky-wash--{left|right}[ mk-sky-wash--flow]" aria-hidden><img src="/landing/img/sky-deco-{1..4}.webp" 1536x1024 loading=lazy></div>`.
- Host needs `.mk-has-sky` (`position:relative; overflow-x:clip`); all other children get `position:relative; z-index:1`.
- Box: `top:0; width:72%; height:min(100%,56rem)`; `--flow` sets `top:auto` (starts where it stands, after the turn). ≤640px: `width:120%; opacity:.4`, side offset `-10%`.
- Scroll: `view-timeline: --mk-wash`; img `mk-sky-wash` keyframes: 0% `opacity 0, translateY(90px) scale(1.16)`; 22% to 60% opacity 1; 100% `opacity 0, translateY(-90px) scale(1.02)`; `animation-range: cover 0% cover 100%`. Img rests at `scale(1.08)`.
- Placement: Home cures sky 3 right (flow), people sky 4 left; story rows sky 3 right; FAQ sky 1 left; demo panel sky 2 right, tutor sky 3 left; pricing sky 1 right.

### 3.5 People (home.css)

```html
<section class="mk-people mk-has-sky"><SkyWash sky={4} side="left"/>
  <div class="mk-shell"><h2 class="mk-people__title" data-reveal="rise"/>
    <ul class="mk-people__list" data-reveal="stagger"><li class="mk-person"><h3/><p/><a href="/{lang}/{teachers|students|parents}">For …</a></li> × 3</ul></div></section>
```

- `padding:clamp(4rem,8vw,6.5rem) 0; border-top:1px solid #e4e8f2; bg paper`. List grid gap 2.5rem; 3 columns from 860px. Link: red-ink, 600, underlined, `text-underline-offset:.2em`.

### 3.6 Pilot band (PilotBand.tsx, home.css)

```html
<section class="mk-velvet mk-pilot" id="pilot" data-nav-theme="dark" aria-labelledby="mk-pilot-title">
  <span class="mk-bloom mk-bloom--red mk-bloom--centre"/>
  <div class="mk-shell" data-reveal="stagger"><h2 class="mk-pilot__title"/><p class="mk-pilot__body"/><p class="mk-pilot__price"/><a class="mk-btn mk-btn--primary"/></div>
</section>
```

- `text-align:center`; shell is a grid with `justify-items:center`. Copy: "Try it in one grade first." / free 6-week pilot / "After that, $20 per student per month." / "Book a demo". The component is shared by every story page and links to the contact page; Home's links to `#demo-contact`.
- Variant: title straight to button (demo page closing band, `copy.after`), no body or price.

### 3.7 Demo contact form

- `DemoContact` (landing component) closes Home after the pilot band with a Telegram link (`Message us on Telegram` / uz / ru variants). Not restyled by marketing CSS; it sits on the landing paper styles.

## 4. Inner pages

### 4.1 Page header (pages.css, InfoPages.tsx `PageHeader`)

```html
<div class="mk-velvet mk-dark"><bloom red/><bloom violet/>
  <section class="mk-page-hero [mk-page-hero--short]" data-nav-theme="dark" aria-labelledby="mk-page-title">
    <div class="mk-shell"><p class="mk-page-hero__kicker"/><h1 id="mk-page-title" class="mk-page-hero__title"/><p class="mk-page-hero__lead"/></div></section></div>
```

- Left-aligned, one `<h1>` per page. Padding and type are in `tokens-and-type.md`.

### 4.2 Story pages (StoryPageView.tsx: Platform, AI, four audience pages)

| Order | Block | Notes |
|---|---|---|
| 1 | Velvet header (hero) | optional `.mk-pains.mk-pains--page` list in the same velvet wrapper: `.mk-pains__title`, `ul.mk-pains__list`, `li.mk-pain` (grid 7fr/4fr from 900px, `padding:1.75rem 0`, top border `--mk-line-dark`, last also bottom) |
| 2 | `section.mk-cures.mk-cures--page.mk-has-sky` | rows `.mk-cure` as on Home; row without a capture is `.mk-cure--text` (top border `#e4e8f2`, 5fr/7fr, title in column 2 at `clamp(1.6rem,2.6vw,2.2rem)` max 26ch) |
| 3 | optional `section.mk-steps` | `h2.mk-section-title`, `ol.mk-steps__list` (auto-fit `minmax(10.5rem,1fr)` from 900px, gap `1.5rem 2rem`), `li.mk-step`: numbered 2.25rem ink circle (CSS counter), h3, p |
| 4 | optional `section.mk-faq.mk-has-sky` | sky 1 left; 4fr/7fr grid from 900px, gap 3rem; `details.mk-faq__item` with `summary` + `p`; marker `+` / `−` in red-ink at the right |
| 5 | `PilotBand` | velvet |

### 4.3 Info and sales pages (InfoPages.tsx, pages.css)

- Always `PageHeader` (short) then `div.mk-paper.mk-has-sky` blocks of `.mk-shell` sections.
- Pricing: header, `.mk-paper.mk-has-sky.mk-pricing` with the landing `Offer`, then steps and FAQ.
- Contact: `.mk-contact` with `DemoContact`, then `.mk-channels` (`dl.mk-channels__list`, 3 columns from 760px, gap `1.25rem 3rem`, `dd` 1.2rem 600) and a note.
- About: `.mk-prose` (lead `clamp(1.15rem,1.8vw,1.4rem)` max 60ch), `.mk-beliefs` / `.mk-facts` (2 columns from 860px, h 1.25rem 700), `.mk-team` (name 1.6rem 800, role red-ink 600).
- Company / Security: `.mk-info` (`dl.mk-info__list`, rows with `#e4e8f2` rules, 3fr/8fr from 760px) or `.mk-facts--grid` (3 columns from 1100px), and `.mk-link-list` of policies.
- Legal (privacy, terms): `.mk-legal` grid `15rem 1fr` from 960px, sticky aside at `top:6.5rem`, content max 70ch lh 1.7, summary card `#f3eef7`.
- 404: velvet `.mk-404` (`min-height:80svh`), `kicker "404"`, links as `.mk-btn.mk-btn--ghost`.
- All inner paper blocks reveal with `data-reveal="rise"` (titles) or `"stagger"` (lists).

### 4.4 Demo page (DemoPage.tsx)

1. `PageHeader` (velvet).
2. `div.mk-paper.mk-has-sky.mk-demo` (sky 2 right): `p.mk-demo__banner[role=note]` (`#fff4f5` bg, `#8a0011` text, radius 12px), `div.mk-demo__tabs[role=tablist]` with 4 `button.mk-demo__tab[role=tab]` (school, teacher, parent, student; arrow / Home / End move focus, Enter or Space selects), `div.mk-demo__panel[role=tabpanel]` (`min-height:28rem`, `ProductDemo` mounted after hydration).
3. `section.mk-paper.mk-has-sky.mk-demo-tutor` (sky 3 left, top border `#e4e8f2`): section title, lead, `AiTutorDemo`.
4. Closing velvet band `section.mk-velvet.mk-pilot[data-nav-theme=dark]` with title and one primary button to Contact.

### 4.5 Reveal system (motion.css, site-layer.css)

| Attribute | Behaviour |
|---|---|
| `data-reveal="rise"` | armed: `opacity:0; translateY(42px) scale(.965); blur(14px)`; transition 1050ms on `--mk-spring` |
| `data-reveal="stagger"` | children armed at opacity 0, then `mk-rise-in .95s` from `translateY(28px) scale(.92) blur(12px)`; delays .06 / .16 / .26 / .36 / .46 / .56 / .66s (child 7+) |
| `.ak-rise` / `.ak-stagger` (landing classes) | with scroll timelines: `ak-mk-rise` (`translateY(36px) scale(.97)` → none) over `entry 0% 55%` (children `entry 0% 70%`) |
| Reduced motion | all of the above forced visible, no animation |

## 5. Navigation (MarketingNav.tsx, chrome.css; glass values in tokens-and-type.md section 7)

```html
<header class="mk-nav [is-light][is-min][is-tucked][is-sheet-open]">
  <div class="mk-nav__bar">
    <a class="mk-nav__brand"><LandingLogo class="mk-nav__logo ak-logo"/><span>akademiya<span class="mk-nav__tld">.ai</span></span></a>
    <nav class="mk-nav__main"><ul class="mk-nav__list">
      <li class="mk-nav__item"><button class="mk-nav__trigger" aria-expanded><span class="mk-nav__caret"/></button><ul class="mk-nav__panel" hidden>…</ul></li> × 3  (Platform, Who it’s for, Company)
      <li class="mk-nav__item"><a class="mk-nav__link">Pricing</a></li> <li …>Contact</li></ul></nav>
    <div class="mk-nav__tools"><ul class="mk-nav__langs">UZ RU EN</ul><span class="mk-nav__chip"/><a class="mk-nav__signin" href="/login"/><a class="mk-btn mk-btn--primary mk-nav__cta"/><button class="mk-nav__menu"><span class="mk-nav__burger"/></button></div>
  </div>
  <div class="mk-nav__sheet" hidden>…</div>
</header>
```

| Item | Spec |
|---|---|
| Groups (en) | Platform: Overview, AI, Live demo. Who it's for: Directors, Teachers, Students, Parents. Company: About us, Company information, Security. Then Pricing, Contact |
| Brand | logo 20×20, gap 9px, 18px 700 (16px ≤640), `.ai` in `#e6031d`; `ak-logo` gives the living-orb hover (×1.14) |
| Links / triggers | 13px / 19.5px, 650, ls -.12px, gap 26px between items; hover and current → ink; caret = 5px rotated border box, flips to 225deg when open |
| Dropdown panel | absolute, `top:calc(100% + 32px); left:-12px; min-width:13.5rem; padding:6px; radius 14px`; links `padding:8px 12px; radius 8px`; current page = red pill (`--mk-nav-on-bg`) |
| Language group | `padding:2px; gap:2px; radius 8px`; links `5px 9px`, 12px 700, radius 6px; real links to the same page in each language, `aria-current="true"` on current |
| Sign in | link style, hidden ≤1080px |
| Book a demo | `.mk-nav__cta` (see tokens file) |
| Compact ≤1080px | hides `.mk-nav__main`, wide lang group and sign-in; shows `.mk-nav__chip` (language echo: 11px 700, `4px 7px`, pill) and the menu button (44×36, radius 10, bars 18×2 at ±6px); tools gap 12px |
| ≤900px | bar `gap:12px; padding-inline:16px` |
| ≤640px | `top:8px; width:calc(100% - 16px)`; bar `gap:8px; padding-inline:10px`; brand 16px; CTA `8px 12px` 12px |
| Sheet | `position:fixed; inset:0; background:#fbfcff`; padding `5rem 1.5rem 2rem`; Poppins 24px 650 links `#1d1d1f`, current `#e6031d`; group titles .9rem 700 `#6e6e73`; lang pills `min-height:2.75rem`, radius 999px, active white with `0 1px 3px rgba(29,29,31,.12)`; bar stays on top (z-index 1) and shows light glass while open; `html.mk-sheet-open { overflow:hidden }`; Escape closes and returns focus |
| Logo pill (mouse only: `(hover:hover) and (pointer:fine) and (min-width:1081px)` and motion allowed) | after `scrollY > 90` the bar gulps to a `max(200px, measured)` pill (`transform-origin:26px 50%`, `mk-nav-gulp .95s`), items pop out right to left (`--mk-out` .42s → 0s) and return left to right (`--mk-in` .14s → .49s); hover or focus-within jiggles it open (`mk-nav-jelly .8s`) |
| Tuck (touch, ≤1080px, or reduced motion) | hides (`translateY(calc(-100% - 1.25rem))`) when scrolling down past 240px, returns on scroll up (>6px delta); `:focus-within` cancels it |
| Press | `useNavPress('.mk-nav__bar')` squeezes control and glass on press |
| Pixel targets (1440×900) | bar x130 y12 1180×66; brand x155 138.2×27; lang group x956.8 114.7×34; sign-in x1097.4 42.5×19.5; CTA x1165.9 119.1×40.5. Phone (390): brand 158.9, CTA 95.3×34 at x223.8, menu 44×36 at x327 |

## 6. Footer (MarketingFooter.tsx, chrome.css)

```html
<footer class="mk-footer" data-nav-theme="dark">
  <div class="mk-shell mk-footer__grid">
    <div class="mk-footer__brand"><a class="mk-nav__brand"/><p/></div>
    <div class="mk-footer__col"><p class="mk-footer__title"/><ul/></div> × 4  (Platform, Who it’s for, Company+Pricing+Contact, Contact: email, Telegram, city)
  </div>
  <div class="mk-shell mk-footer__base"><p>© 2026 akademiya.ai. …</p><ul class="mk-footer__legal"/><ul class="mk-footer__langs"/></div>
</footer>
```

- `padding:4.5rem 0 2rem; bg #140d17; color #c9c1d3`; links inherit, hover white + underline (`offset .2em`).
- Grid gap 2.5rem; from 900px `minmax(0,1.6fr) repeat(4, minmax(0,1fr))`.
- Titles .95rem 600 white; column lists gap .55rem, .95rem text; brand blurb max 34ch .95rem lh 1.6.
- Base row: flex wrap gap `1rem 2rem`, `margin-top:3.5rem; padding-top:1.5rem; border-top:1px solid rgba(247,244,250,.12)`, .875rem; language list right (`margin-left:auto`) with full names (O‘zbekcha, Русский, English); current is white 600.
- The footer repeats the whole sitemap so every page is reachable from any page.

# Sparkle Express pages, content model, copy rules

Source root: `sparkle-express-source/` (Tuff House). `corporate.py` = `content/corporate.py`; `legal.py` = `content/legal.py`.

## 1. Site map (`build_content.py`, `corporate.py` `build_corporate_pages`)
| Route | Title (nav label) | Purpose |
|---|---|---|
| `/` | Sparkle Express (logo) | pitch: "From idea. To reality.", sketch-to-reality hero, two paths, workflow, what we build |
| `/about/` | Who we are | company philosophy, values, own products, entity, imagery disclosure |
| `/services/` | Build with us | custom software offer, service list, starting points, FAQ |
| `/approach/` | How we build | five-stage process, human part, what to prepare |
| `/contact/` | Bring an idea (dark nav button) | brief builder + company contact + FAQ |
| `/company/` | Company information | legal facts (footer link, nav state = About) |
| `/terms/` | Terms of service | website terms (footer) |
| `/privacy/` | Privacy policy | website privacy (footer) |
| `/404.html` | not found | "This page is still a sketch" / "Nothing built here yet." |
- "Our products" nav item leaves the site: `https://akademiya.ai/`, `target=_blank rel="noopener noreferrer"`, arrow `↗` only on external links.
- Also generated: `sitemap.xml`, `robots.txt`. `ORIGIN = https://sparkleexpressllc.com`; `INDEXABLE = True` (False = `noindex` + `Disallow: /`); 404 is noindex, no canonical.
- Nav array `NAV` in `build_content.py`: about, services, approach. Active key per page in the `data` list.

## 2. Page shell (`build_content.py` `render()`)
`<body class="page-home|light-page" id="top">` = skip link + `header(active)` + `<main id="main">` + `FOOTER`. `<head>`: charset, viewport, `theme-color #f3f4f8`, title, description, robots, canonical, og:title/description/type/url/image (`/assets/images/hero-devices.webp`), twitter `summary_large_image`, svg favicon, font preloads, inline script adding `html.motion` unless reduced motion, `/site.css`, `/motion.css`, deferred `/site.js` + `/motion.js`, Organization JSON-LD. Asset URLs get `?v=<sha256[:10]>` cache stamps.

## 3. Section order and skeletons
Common helpers (`corporate.py`): `button(text,href,kind)`, `picture(name,alt)`, `idea_stage(...)`, `cta(eyebrow,title,description)`, `arrow(external)`. Every block: `<section class="section [section--soft]"><div class="container ...">`; motion hooks `reveal` on blocks; `data-scroll-read` on one lead paragraph (home).

### Home `/`
1. `section.home-hero` > `.hero-head` { `p.eyebrow.hero-note` "Every great product starts as a scribble."; `h1` two block spans `.hero-idea` / `.hero-reality`; `.hero-side` { `.hero-lead`, `.button-row.left` primary "Bring an idea" + secondary "See what we build" } } then `idea_stage('hero', hero-devices.webp, ..., SKETCH, caption)` (priority image).
2. `section.intro-section#who-we-are`: `.section-heading` (kicker, title "A software company.<br>An open mind.", lead with `data-scroll-read`) + `.two-paths` of `a.path-card` (own products, external) and `a.path-card.path-card--dark` (built with you).
3. `.marquee` (6 capability words, see visual-system 9).
4. `section.photo-story`: `.photo-story-image` + `.photo-story-copy` ("Human creativity.<br>AI in motion.") + `.image-note` "Illustrative studio photography."
5. `section.workflow` > `.workflow-track`: `.wf-tabs[role=tablist]` + `.wf-panels` with `.wf-people`, `.wf-agents`, `.wf-outcome` ("You leave with"). Title "People steer.<br>Agents carry."
6. `section.section--soft` `.build-grid` of 4 `a.build-card.reveal` (doodle SVG, h3, p). Title "Your idea,<br>in working software."
7. `section--soft` principles: `.grid-3.principles` of 3 `article`.
8. `cta()`.

### Services `/services/`
`section.page-hero.container` (kicker "Custom software development", `h1.display-title` "Your idea.<br><span class="muted">Built together.</span>", lead, `.button-row.left` primary + text) > `figure.wide-photo.container` > `.split` prose section > `section--soft` `.service-list` of `article.service-row` (h3 + p | `ul`) > "Meet the project where it is" `.grid-3` of `a.feature-card` (kicker "I have an idea" / "I'm ready to build" / "I have a product", links `/contact/?stage=idea|scope|existing`) > `section--soft` `.split` "Clear from the start" > `.faq-layout` with `<details>` > `cta()`.

### Approach `/approach/`
`.page-hero` (h1 "Human creativity.<br><span class="muted">AI in motion.</span>") > `section--soft` `.process-intro` + `.process-timeline` of 5 `article.process-step.reveal` (`.process-index` 01-05, kicker = stage name, h3, p, `.step-output` with Kalam `strong` label) > `.split.align-center` (`figure.image-frame` + "Creativity gives technology direction.") > `section--soft` `.grid-3` of `.feature-card` (The people / The priorities / The constraints) > `cta('Put the first thoughts on paper', ...)`.

### About `/about/`
`.page-hero` (h1 "Ideas into reality.<br><span class="muted">From the first spark.</span>") > `figure.wide-photo` > `section#philosophy` `.grid-3` feature-cards (company / ambition / way of working) > `section--soft` `.values-grid` (4 `article`, 2 cols) > `.split.align-center` own products (links out to akademiya.ai) + `image-frame` > `section--soft` `.split` "Sparkle Express LLC." with link `/company/` > `section#imagery.image-disclosure` (see truth rules) > `cta()`.

### Contact `/contact/`
`.page-hero` (h1 "An idea is<br><span class="muted">enough to begin.</span>") > `section--soft` `.contact-layout` { `aside.contact-intro` with 3-step `ol.brief-steps` + note; `.brief-panel` (form + result) } > `section#company-contact` `.grid-2` of `.contact-card` (company mail + postal address; Akademiya link-out) > `section--soft` `.faq-layout` (4 questions).

### Company `/company/`
`.page-hero` (h1 "Sparkle Express LLC.") > `section--soft` `.company-layout` { `.company-statement` ("Ideas.<br>Products.<br>Possibilities."), `dl.company-facts` rows `200px 1fr` } > `.grid-3` of `.feature-card` (products, services, website policies).

### Terms / Privacy (`legal.py` `_body`)
`.container` > `header.legal-hero` (kicker "Company & legal", `h1.display-title`, lead) > `.legal-layout` (`240px 1fr`): `aside.legal-aside` (sticky `top:100px`, "On this page" anchors) + `.legal-content` (`.legal-summary` lilac box, then `section[aria-labelledby]` with `h2#id`). `UPDATED = "26 October 2026"`. Website terms cover the corporate site only; products and client work use their own agreements.

### 404
`section.page-hero.container.not-found`: kicker "This page is still a sketch", `h1.display-title` "Nothing built<br>here yet.", lead, buttons "Go to the homepage" + text "Bring an idea".

## 4. Content model (what to edit where)
| Change | Edit | Then |
|---|---|---|
| Page copy, sections, home/services/approach/about/contact/company | `content/corporate.py` (HTML in Python f-strings; `HOME`, `SERVICES`, `APPROACH`, `ABOUT`, `CONTACT`, `COMPANY`; lists `BUILDS`, `WORKFLOW`) | `python3 build_content.py` |
| Terms / Privacy | `content/legal.py` | rebuild |
| Header, nav, footer, meta, origin, `INDEXABLE`, 404 | `build_content.py` | rebuild |
| New page | add a tuple `(route, title, description, BODY, active, theme)` to `data` in `build_corporate_pages()`; add to `NAV`/footer if needed | rebuild (sitemap auto) |
| Hero sketch drawing | `content/sketch.py` (`SKETCH` SVG string) | rebuild |
| CSS / JS / images | edit directly in `dist/` (`site.css`, `motion.css`, `site.js`, `motion.js`, `assets/`) | refresh |
- Generator rewrites only `dist/*/index.html`, `404.html`, `sitemap.xml`, `robots.txt`; hand edits to those HTML files are lost on next build.
- No npm, no third-party Python packages. Preview: `python3 -m http.server 8000 --bind 127.0.0.1 --directory dist` (needs a server: asset paths are root-absolute).
- Page `<title>` pattern: "<Topic> — Sparkle Express"; description is one sentence.
- Deploy: serve `dist/` as the domain root (static; example nginx in `README.md`).

## 5. Voice and copy rules
- Core message: "From idea. To reality." Footer line: "Human creativity. AI in motion. From idea to reality."
- Kicker (`.eyebrow`) style: a short handwritten note, sentence case, no period needed or a plain statement. Examples from source: "Every great product starts as a scribble.", "Who is Sparkle Express?", "What we build", "Who does what", "Your idea belongs in the conversation", "A good place to start", "Got a scribble worth building?", "This page is still a sketch".
- Headline pattern: two short lines joined by `<br>`; second line often the outlined `muted` half. Plain words, full stops, parallel pairs ("People steer. Agents carry.", "A software company. An open mind.").
- Describe the company as a software development company; services = custom software, SaaS platforms, web apps, mobile, AI-supported workflows, any industry.
- Framing: "Human creativity sets the direction. AI agents help bring it to life." People direct, decide, review; agents carry work forward (agentic workflow).
- Two ways we build: (1) our own products; (2) products for clients (agreed scope, deliverables, commercial terms, ownership).
- Five-stage process, in order: Understand, Shape, Build, Review & prepare, Learn & improve. Each has a People line, an AI-agents line, and an outcome ("You leave with ...").
- Values: Curiosity, Creativity, Consideration (every idea gets a hearing), Purpose, Human judgment.
- Tone: warm, direct, concrete; second person ("your idea"); no hype numbers, no superlatives, no jargon; contractions allowed (curly apostrophes `’`).
- CTAs: "Bring an idea", "See what we build", "Plan your project", "Explore our approach", "Start your project", "Create my brief".
- Contact CTAs go to `/contact/`; external product link opens in a new tab with an arrow.

## 6. Truth rules (found in source)
- Photos (`hero-devices`, `studio-collaboration`, `learning`) are AI-generated placeholders. They do not show staff, customers, offices, or partners. Disclose: captions say "Illustrative ..." / "Concept imagery", and `/about/#imagery` carries the full "About the imagery" statement; footer links to it. Alt text describes the scene, never names fictional people as staff or customers. Device screens are conceptual, no logos or invented numbers (`docs/image-prompts.md`).
- No fake clients, logos, testimonials, case studies, metrics, or reviews anywhere.
- Akademiya AI is linked out (own website, terms, privacy, support), not featured as a case study. The portfolio line in `COMPANY_OVERVIEW.md` is the only status claim: "Developed".
- The brief builder never sends or stores data: no backend, runs in the browser.
- Do not promise outcomes, prices, timelines, or ownership terms; the source defers them to "the project contract".
- Company facts as stated: legal name Sparkle Express LLC; Limited Liability Company registered in Wyoming, United States; year started 2025; D-U-N-S 141161269; mailing address 30 N Gould St Ste R, Sheridan, Wyoming, United States; activities: custom software development, SaaS products and services; footer "© 2026 Sparkle Express LLC, Sheridan, Wyoming".
- All assets local: no hotlinked fonts or images.

## 7. Contact and brief behaviour (`corporate.py` `BRIEF`; `site.js` L190-280)
- Form `#brief-form`, `fieldset.brief-fields` starts `disabled`; JS enables it after handlers are installed. `<noscript>` shows a `.legal-summary` note.
- Fields: working project name (required, max 100), "What are you building?" select (Custom software, SaaS product, Education platform, Mobile experience, Workflow or integration, Something else), "Where are you today?" select, idea textarea (min 20, max 4000, rows 5), optional context (max 2000, rows 3). Ink meter label "rough sketch" fills as the form completes.
- Submit "Create my brief" builds a text draft shown in `textarea.brief-output` (ruled-paper look: 32px line grid), result block `#brief-result` with focus moved to its heading.
- Three outputs: (1) `a#email-brief` "Email this brief" = `mailto:<studio mailbox>?subject=...&body=...`, whole URL kept under 1900 characters by trimming the body on code points; falls back to subject-only then bare mailto; (2) `#copy-brief` copies via `navigator.clipboard.writeText`, status "Copied to clipboard. Nothing has been sent."; (3) `#download-brief` "Save as text" downloads a Blob as `sparkle-project-brief.txt` (`text/plain;charset=utf-8`).
- Status text lives in `p#brief-status[role=status][aria-live=polite]`.
- Notes in source: the button label names a team member; the studio mailbox appears in the footer, contact card, and mailto. When reusing elsewhere, say "the studio mailbox" and take the address from `EMAIL` in `corporate.py`.
- `?stage=` query on `/contact/` links preselects the stage (services starting-point cards).

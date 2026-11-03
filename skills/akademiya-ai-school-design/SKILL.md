---
name: akademiya-ai-school-design
description: Use when designing, building, extending or reviewing the Akademiya AI (akademiya.ai) school website, or any page, landing, section, deck screen or product line that must look, read and move like it — a B2B school platform sold to school directors, with a clear-sky hero, dark "Sound familiar?" pains, a "Let's fix this" turn, real 3D phones and tilting screenshots, and the old-site glass nav. Also when copy for it risks overclaiming, or a new Akademiya page drifts into a generic SaaS look. Part of the sigma-designs family.
---

# Akademiya AI — School Design

The design system, story and rules of the Akademiya AI school website
(uz / ru / en), distilled so a new page or a new product line reads as the
same brand. Exact values live in the reference files; this page is the map.

## Core principles

1. **Pain first, product second.** The director recognises their own week
   before seeing a feature: a short, concrete hook per pain ("Your teachers
   are still checking notebooks at 10 pm."), then each pain meets one Built
   answer with a real screen.
2. **Talk to the buyer.** The reader is the school's director or owner. Speak
   about what they own: catching a falling class early, parents' trust,
   teachers' evenings, honest homework. Teacher and student features serve
   that story; they never lead it.
3. **Truth over polish.** Only Built capabilities. No invented stats, quotes,
   logos or outcomes; no "[DATA]" slots waiting for numbers. Not-built items
   never appear, not even as "coming soon". See copy-and-truth.md.
4. **One arc, light → dark → light.** A clear sky opens (the name and what it
   is), the page drops into dark velvet for "a normal week", the turn brightens
   to paper where the product answers, then the offer and the form.
5. **The real product, on real devices.** Real captures from in-house fixtures
   on 3D phones and tilted panels. Never browser frames, CSS-drawn mock
   screens, fake charts or stock photos.
6. **Alive, then calm.** One motion per moment (clouds part, blocks rise,
   devices lean to the mouse, the pains carousel plays on a timer). The server
   HTML hides nothing; reduced motion gets a still, complete page.
7. **Uzbek first.** Every string in uz, ru, en; uz is primary. Poppins for
   Latin, Montserrat for Cyrillic.

## Page arc (Home)

| # | Section | Surface | Job |
|---|---|---|---|
| 1 | Sky hero: `akademiya.ai` + product line + one red line | sky over paper | Name and what it is, in one second |
| 2 | "Sound familiar?" — 7 hooks, timer carousel | velvet + blooms | The director recognises the week |
| 3 | Turn: "Let's fix this." + "Introducing Akademiya AI for Schools!" | velvet → paper | Lights on |
| 4 | Cures: pain recalled → Built answer → real capture | paper + sky wash | Proof by product |
| 5 | People: teachers, students, parents | paper | Who else wins |
| 6 | Pilot band: free 6-week pilot in one grade, then the price | velvet | The low-risk offer |
| 7 | Demo form | paper | The one action |

Inner pages: velvet page header → paper rows (copy + capture) → steps → FAQ → pilot band.

## Quick reference

- Tokens: velvet `#140d17`, velvet-2 `#1d1322`, red `#ec031d`, red-ink `#d0021a`, violet `#6a3df0`, ink `#151922`, paper `#fbfcff`, mist `#b3adbd`; ease `cubic-bezier(.16,1,.3,1)`.
- Dark surfaces carry `data-nav-theme="dark"`; the nav switches to dark glass over them.
- Reveal: `data-reveal="rise"` (block) or `"stagger"` (children); armed only below the fold after hydration; never nested.
- Captures: `PanelShot` / `PhoneShot`; phones render as a lazy three.js model, falling back to the CSS phone.
- One action, the demo: "Book a demo" / "Demoga yozilish" / "Записаться на демо" — repeated in the nav, the pilot band and the form, never joined by a second action ("Learn more", "See the product").
- New blocks reveal with `data-reveal`; the `.ak-rise` scroll-timeline reveal exists only for reused old-landing components.

## A new product line or a new page

Carry over unchanged: tokens, type, the glass nav, the light → dark → light
arc, the motion system, the product-visual rules and the truth discipline.
Change only the buyer, the pains (written as that buyer's scenes), the Built
list and the offer. The owner decisions in copy-and-truth.md (price, pilot)
are the school product's; a new line ships no price, pilot or capability
claim until the owner gives its own Built list and offer.

## Assets

Ship the real ones, from the Frontend repo: `public/landing/img/hero-sky-base-1.webp`,
`hero-clouds-left-1.webp`, `hero-clouds-right-1.webp` (the hero sky, three layers
of one photo), `sky-deco-1…4.webp` (sky washes), the logo
`src/pages/landing/LandingLogo.tsx` (inline SVG), and product captures from
`public/landing/product/derived/`. A CSS stand-in for the sky is fine in a
throwaway prototype only, and never for the product screens.

## Reference files

| File | Read when |
|---|---|
| tokens-and-type.md | Colours, fonts, type scale, glass, buttons, spacing |
| page-anatomy.md | Building or reordering a section or page; nav and footer structure |
| motion-system.md | Any animation: Lenis, reveals, sky, carousel, red button, nav pill, contracts and gotchas |
| product-visuals.md | Showing the product: panels, phones, tilt, 3D phone, overlays |
| copy-and-truth.md | Writing or reviewing any line of copy, prices, claims, names, translations |
| verification.md | Before calling a page done: gate, browser matrix, pixel parity, review loop |

## Common mistakes

| Mistake | Fix |
|---|---|
| Warm cream + serif + one indigo accent ("premium SaaS") | Red/ink/velvet/paper tokens, Poppins/Montserrat |
| Opening with features or "AI-powered LMS" | Name + one product line, then the pains |
| Pains as a grid of icon cards | One hook per beat, carousel on a timer, on velvet |
| Stat counters, "[PILOT DATA]" placeholders, animated bar charts | No numbers without proof; show the real screen |
| Screenshots in browser chrome or drawn with CSS | Real capture in a tilted panel or a 3D phone |
| Scroll-jacked carousel or pinned scroll beats | Timer carousel; the page scroll never drives it |
| Hiding content until JS runs | Only below-the-fold blocks are armed, after hydration |
| Telegram, SMS, payments, self sign-up as features | Not built; Telegram only as a contact channel |
| English-only or machine-translated copy shipped | uz/ru/en in the content file; native read before merge |

## Source of truth

The live implementation is the Akademiya Frontend repo, `src/marketing/`
(content/, components/, pages/, styles/, phone3d/, useSiteMotion.ts,
useTilt.ts) with truth guards in `src/pages/landing/truthPatterns.ts` and the
design contract in `DESIGN.md`. When this skill and the code disagree, the
code wins; update the skill.

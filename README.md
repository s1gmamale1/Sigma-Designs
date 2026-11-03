# Sigma Designs 🫧

A family of [Claude Code](https://claude.com/claude-code) skills, each encoding
a complete design language distilled from a real project (living glass: a shipped WebGL experience; the school language: the built, not yet deployed, Akademiya marketing site; the studio language: the live sparkleexpressllc.com build) and tested with
skill-TDD (baseline agents miss the language; agents with the skill reproduce
it).

| Skill | Language |
|---|---|
| `sigma-designs` | The hub: routes to the right language |
| `sigma-designs-living-glass` | Apple Intelligence / Image Playground living glass (below) |
| `akademiya-ai-school-design` | The Akademiya AI school website: clear-sky hero, dark "Sound familiar?" pains, the "Let's fix this" turn, real 3D phones and tilting screenshots, the glass nav, pain-first and truth-first school copy in uz/ru/en |
| `sparkle-express-design` | The Sparkle Express studio site (live at sparkleexpressllc.com): graph-paper canvas, heavy grotesk headlines with an outlined word, Kalam handwritten kickers with a yellow marker, the sketch-to-reality drag slider, one violet action on navy, honest studio copy |

## Living glass

**What it teaches an agent to build:**

- 🫧 **Living orbs & soap bubbles** — organic wobbling silhouettes (never
  perfect circles), four independent sliding/pulsing rim lights (never one
  traveling highlight), glassy near-black interiors, sun-eruption flares
- 🌌 **Atmospheres** — the 9-stop warm palette, blooms-on-velvet and
  full-gradient modes, liquid-glass rules, mandatory dither
- 🎬 **Motion & choreography** — emphasized-decelerate everything (overshoot
  banned), applied exactly once; time-rails vs scroll-rails on shared refs,
  asymmetric flare envelopes, entrance grammar ("born inside the world"), the
  ScrollTrigger pin trap
- 🚂 **Navigation rails** — who owns the story position, quantizing scroll into
  beats you cannot rush, bridging every channel across a phase handoff,
  jank-clamped animation clocks, and reviving the effects that die the day you
  switch from scrolling to clicking
- 🔊 **Synthesized UI sound** — glassy WebAudio voice recipes, continuous
  envelope-driven feeds (sound rides the same curves as the light), the mix law
- ✅ **Verification craft** — video capture over screenshots, live debug HUDs,
  RMS tables, cue-log probes, and a gotcha table where every entry cost a real
  debugging session

## Install (Claude Code and Codex)

```bash
git clone https://github.com/s1gmamale1/Sigma-Designs.git
cd Sigma-Designs && ./install.sh   # symlinks every skill into ~/.claude/skills and ~/.agents/skills
```

Re-runnable; update later with `git pull`. Per skill and target it does this:

- symlink already pointing at this repo: left as is (`ok (linked)`)
- symlink pointing elsewhere or dangling: replaced (`relinked (was -> <old>)`)
- an old copied `sigma-designs` folder (pre-family: `name: sigma-designs` plus `orb-recipe.md`): moved to `~/.claude/skills-backup/sigma-designs.pre-family-<timestamp>` (`~/.agents/skills-backup` for Codex), outside the skills dir because backups inside it still load as skills, then linked
- any other real file or folder: left alone with `skip (not ours): <path>`

Per-project install instead: copy `skills/<name>` (and `skills/sigma-designs`
if you want the hub) into `<project>/.claude/skills/`.

Then ask for the look ("Sigma Designs style hero", "a
page that matches the Akademiya school site") and the right skill loads.

## Files

| File | Contents |
|---|---|
| `skills/sigma-designs/SKILL.md` | Family hub and routing |
| `skills/sigma-designs-living-glass/SKILL.md` | Core principles, quick-reference numbers, common mistakes |
| `skills/sigma-designs-living-glass/orb-recipe.md` | The complete living bubble: wobble GLSL, the four-rim-light tables, shimmer, flares, orbiting sets, the cursor |
| `skills/sigma-designs-living-glass/atmosphere.md` | Palette, background modes, glass rules, in-bubble text treatment |
| `skills/sigma-designs-living-glass/motion-language.md` | Easings, rails, shared-refs architecture, envelopes, performance and quality-tier discipline |
| `skills/sigma-designs-living-glass/navigation-rails.md` | Playhead ownership, input quantization, phase handoffs, clamped clocks, held-playhead revival |
| `skills/sigma-designs-living-glass/sfx-palette.md` | Synthesized voice recipes + envelope feeds + mix law |
| `skills/sigma-designs-living-glass/verification.md` | Objective proof methods, process rules, and the hard-won gotcha table |
| `skills/akademiya-ai-school-design/SKILL.md` | Principles, the page arc, quick reference, common mistakes |
| `skills/akademiya-ai-school-design/tokens-and-type.md` | Colour tokens, fonts, type scale, glass, buttons |
| `skills/akademiya-ai-school-design/page-anatomy.md` | Every section and page, the nav and the footer |
| `skills/akademiya-ai-school-design/motion-system.md` | Lenis, reveals, sky, carousel, red button, nav motion, gotchas |
| `skills/akademiya-ai-school-design/product-visuals.md` | Panels, phones, tilt, the three.js phone, overlays |
| `skills/akademiya-ai-school-design/copy-and-truth.md` | Voice, signature lines, owner decisions, never-claim lists, names, languages |
| `skills/akademiya-ai-school-design/verification.md` | The gate, the browser matrix, pixel parity, the review loop |
| `skills/sparkle-express-design/SKILL.md` | Principles, tokens at a glance, common mistakes |
| `skills/sparkle-express-design/visual-system.md` | Tokens, the grid, fonts, type scale, outline headlines, kickers, buttons, cards, marquee, layout |
| `skills/sparkle-express-design/pages-and-copy.md` | Site map, section order, content model, voice, truth rules, the brief |
| `skills/sparkle-express-design/motion-and-interactions.md` | View transitions, reveals, ink-fill, scroll-read, marquee, tucking header; the slider, tabs, process rail, brief builder |
| `skills/sparkle-express-design/build-and-verify.md` | The Python generator, preview, deploy, the verification checklist |

## License

MIT — take the bubbles, make something beautiful.

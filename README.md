# Sigma Designs 🫧

A family of [Claude Code](https://claude.com/claude-code) skills, each encoding
a complete design language distilled from a shipped project and tested with
skill-TDD (baseline agents miss the language; agents with the skill reproduce
it).

| Skill | Language |
|---|---|
| `sigma-designs` | The hub: routes to the right language |
| `sigma-designs-living-glass` | Apple Intelligence / Image Playground living glass (below) |
| `akademiya-ai-school-design` | The Akademiya AI school website: clear-sky hero, dark "Sound familiar?" pains, the "Let's fix this" turn, real 3D phones and tilting screenshots, the glass nav, pain-first and truth-first school copy in uz/ru/en |

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

Re-runnable and never overwrites an existing skill of the same name; update
later with `git pull`. Then ask for the look ("Sigma Designs style hero", "a
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

## License

MIT — take the bubbles, make something beautiful.

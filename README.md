# Sigma Designs 🫧

A [Claude Code](https://claude.com/claude-code) skill that encodes a complete
**Apple Intelligence / Image Playground**-style design language — distilled
from a production WebGL experience and battle-tested with skill-TDD (baseline
agents fail to produce this language; agents with the skill reproduce it
faithfully).

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

## Install (Claude Code)

```bash
git clone https://github.com/s1gmamale1/Sigma-Designs.git
cp -r Sigma-Designs/sigma-designs ~/.claude/skills/
```

That's it — Claude Code discovers skills in `~/.claude/skills/` automatically.
Then ask for anything in the aesthetic ("a living gradient orb like Apple
Intelligence", "Sigma Designs style hero") and the skill loads itself.

For a single project instead of globally: copy into
`<project>/.claude/skills/`.

## Files

| File | Contents |
|---|---|
| `sigma-designs/SKILL.md` | Core principles, quick-reference numbers, common mistakes |
| `sigma-designs/orb-recipe.md` | The complete living bubble: wobble GLSL, the four-rim-light tables, shimmer, flares, orbiting sets, the cursor |
| `sigma-designs/atmosphere.md` | Palette, background modes, glass rules, in-bubble text treatment |
| `sigma-designs/motion-language.md` | Easings, rails, shared-refs architecture, envelopes, performance and quality-tier discipline |
| `sigma-designs/navigation-rails.md` | Playhead ownership, input quantization, phase handoffs, clamped clocks, held-playhead revival |
| `sigma-designs/sfx-palette.md` | Synthesized voice recipes + envelope feeds + mix law |
| `sigma-designs/verification.md` | Objective proof methods, process rules, and the hard-won gotcha table |

## License

MIT — take the bubbles, make something beautiful.

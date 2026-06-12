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
  banned), time-rails vs scroll-rails on shared refs, asymmetric flare
  envelopes, entrance grammar ("born inside the world"), the ScrollTrigger
  pin trap
- 🔊 **Synthesized UI sound** — glassy WebAudio voice recipes, continuous
  envelope-driven feeds (sound rides the same curves as the light), the mix law
- ✅ **Verification craft** — motion-proof screenshots, RMS tables, cue-log
  probes, and a gotcha table where every entry cost a real debugging session

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
| `sigma-designs/orb-recipe.md` | The complete living bubble: wobble GLSL, the four-rim-light tables, flares, mini/cursor variants |
| `sigma-designs/atmosphere.md` | Palette, background modes, glass rules, in-bubble text treatment |
| `sigma-designs/motion-language.md` | Easings, rails, shared-refs architecture, envelopes, performance discipline |
| `sigma-designs/sfx-palette.md` | Synthesized voice recipes + envelope feeds + mix law |
| `sigma-designs/verification.md` | Objective proof methods + the hard-won gotcha table |

## License

MIT — take the bubbles, make something beautiful.

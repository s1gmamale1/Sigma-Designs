# Synthesized SFX — the glassy voice palette

WebAudio synthesis, zero asset files. The defining idea: **feeds, not just
triggers** — continuous voices whose gain follows the SAME live envelopes
the visuals read (per-frame `setTargetAtTime`, allocation-free), so sound
and light share one curve. Trigger-only thinking with cooldown hacks is the
fresh-agent failure mode; edge-detect cues from the envelopes instead
(rising-threshold 0.5 crossings; gaussians re-arm naturally on the way down).

## Architecture

- Freeze the engine interface in its own module (one-shots + `feedX(v)`
  methods + `unlock()`/`setMuted()`), with a silent no-op default — UI wires
  against the seam, engine registers at the user's first gesture (autoplay
  unlock). Everything callable pre-unlock must silently no-op.
- Bus: voices → master gain (≈ −14dB under any music) → compressor
  (threshold −18, ratio 6, knee 12, attack 3ms, release 250ms) → out.
- Mute = one switch, smooth 20ms ramp (clicks otherwise). Music + SFX together.
- ONE shared looping white-noise buffer (~2s) feeds every breathy voice. Do not
  allocate noise per event.
- `exponentialRampToValueAtTime` CANNOT reach 0 — ramp to a floor (1e-4) and
  stop the node shortly after, or the ramp silently does nothing.
- Express every level through a `dB(x) = 10^(x/20)` helper and name the
  constant. A bare `0.11` in a voice body is unreviewable.
- **One-shot envelope, universal:** `setValueAtTime(0)` → LINEAR ramp to peak
  over attack → EXPONENTIAL ramp to the floor over release. Linear attack with
  exponential decay is what reads as glass; the reverse reads as a synth pad.
- **Reap every voice.** On the longest-lived source's `onended`, disconnect the
  source AND every node in its chain, and stop it at `attack + release + 0.05`.
  Without this a synth engine's node graph grows for the whole session.
- jsdom has no WebAudio — guard CONTEXT CONSTRUCTION (`if (typeof AudioContext
  === 'undefined') return` inside `unlock()`). Importing is already safe if
  nothing is constructed at module scope — which is the actual rule.
- No `destroy()`/`ctx.close()` seam means HMR orphans AudioContexts against the
  browser's ~6-context cap. Build the teardown seam early.

## Voice recipes (tuned values)

| voice | recipe |
|---|---|
| bloom (begin) | sine partials 523/784/1244 Hz, gains .5/.3/.18, attack 30ms, exp release 1.8s + 0.8s noise shimmer (bp 3kHz) at .06 |
| swell (arrival) | noise bp sweep 600→2400Hz over 0.7s (gain 0→.18→0) + sine glide 392→523Hz; the arrival bell starts 0.12s BEFORE the sweep dies (overlap = one gesture, gap = two) |
| ping (crossing) | sine 2349Hz at .11 + a 2954Hz partial at 0.35 OF it, attack 5ms, release .5s — crystalline |
| bloop (bubble) | sine exp pitch sweep 880·(1+.15·var) → ×0.45 over 140ms, level .22, attack 8ms, release 250ms + a 5ms noise click at .04 |
| fuse (climax) | the LOUDEST one-shot: bloom ×1.15 + a low E3 164.81Hz at .16 (attack 40ms, release 2.2s, glide ×0.97 over 1.1s) + shimmer bp 3400Hz at .09 for 1.0s |
| dock (object clicks home) | bell 1318.5Hz +2.5 semitones per index, body glide ×0.94, a fifth partial ×1.5 at 0.4× body, .085, attack 4ms, release 420ms + bp 5200Hz tail at .025 |
| pip (playful, laddered) | triangle, 440·2^(n·2/12) rising per repeat (cap n=12), 90ms, .18 |
| deflate (give-in) | triangle glide 520→260Hz over 350ms, .15 — soft, never slide-whistle comedy |
| celebrate | bloom + bell arpeggio 523/659/784Hz, 90ms apart, .3 — warm, not fanfare |
| tick (UI) | 8ms noise burst bp 5kHz, .1 |
| twinkle (ambient) | one sine from {1047,1175,1319,1568} by seed, .07, release 1.2s; schedule with a deterministic LCG, gaps 7–15s |

## Continuous feeds

| feed | chain | shape |
|---|---|---|
| glitter/flare | looped noise → bandpass 2800Hz Q1.2 (+600·v freq nudge) | v²·0.20, smoothing 50ms |
| transition sweep | noise → bp 1200Hz + 0.6Hz LFO ±300Hz | v·0.16, 80ms — watery |
| submerge | noise → lowpass 300+900·(1−v) Hz | v·0.28, 120ms — a closed lowpass eats most of the noise energy, so this needs more level than it looks |
| union/merge | 3 detuned triangles A3/C♯4/E4, detune `[-4, +4, -4]` cents — asymmetric on purpose, so no two voices beat in step | v²·0.08, 300ms — the hottest steady feed; it should glow, not sing |
| spin-up | noise → bp 900+1700·v Hz Q1.1, plus a bright triad E4/G♯4/B4 ±3 cents | noise v²·0.12 / triad v²·0.05, 60ms — brightens as it gathers |
| writing | noise → highpass 4.2kHz + sparse bell grains | 0.08 · v·(1−v)·4 — peaks mid-act, silent at both ends |

Grains ride a PRE-RENDERED loop, not per-event scheduling: 12 slots at ~180ms
spacing, pitches C7/D7/E7/G7, 45ms decay in a 120ms window. One buffer, one
gain — the feed shape does the rest.

## The release gate (how a soundscape ENDS)

The most portable lesson in the audio layer. A feed driven by a progress-like
signal that STICKS at 1 — a completed spiral, a held playhead, a finished
climax — will hold its chord forever, and two detuned chords left running beat
against each other as audible echo. The visual flash cannot rescue you: it
sticks at 1 too.

Multiply every tension feed by a release gate that eases 1 → 0 once the climax
resolves:

```js
const s = elapsedSincePeak / RELEASE_S          // RELEASE_S ≈ 2.5
release = s >= 1 ? 0 : Math.cos((Math.PI/2) * s) ** 2
```

`cos²` has zero-slope endpoints (a settle, not a cut) and floors around 1e-33 —
never actually zero, so **snap to a literal 0 past the window** or the feed
whispers forever.

**Choose the envelope that returns to 0 AT REST, not the one that merely
correlates.** Driving a submersion feed from a position-derived depth sounds
right until a resting plateau sits inside the entry envelope — then a phantom
whoosh drones at the hub forever. Drive it from the camera/transition timer,
which is 0 at rest by construction.

## Mix law

Hierarchy by meaning: celebration > beginning > crossings > objects >
playful > ambient > UI (measured peak RMS ~0.20 → 0.003). The music owns the
room; SFX are candlelight. Every level a named dB constant.

**That hierarchy is an RMS ordering, not a gain ordering** — raw gains invert
it across frequency. An ~880Hz object sits at .22 while a ~2.3kHz crossing sits
at .11 and still reads LOUDER. Roughly: a 2.3kHz voice needs about half the
gain of an 880Hz voice for equal loudness. Tune by measured RMS; never compare
two constants and conclude anything.

Two gain-tuning rules learned the hard way: tune a filtered feed AFTER its
filter (a closed lowpass eats most of the noise energy), and tune sustained
feeds AGAINST EACH OTHER (the hottest steady feed is never the one you expect).

## Cue architecture — where a sound is declared

Two patterns, chosen by the SHAPE of the driving signal:

- **Rising-threshold edge detect** for signals that return to ~0 (gaussians,
  `sin²` humps): fire on `prev < 0.5 && cur >= 0.5`. They re-arm for free on the
  way down.
- **Hysteresis latch** for signals that are monotone and PLATEAU instead of
  falling: fire at `≥ 0.98`, re-arm only below `0.9`. Without the two
  thresholds a plateauing signal either fires once and never again, or
  chatters on the boundary.

**Split by origin, not by convenience:** discrete user actions call the engine
directly at the interaction site (a click handler knows exactly what happened);
only continuous story beats are edge-detected inside the frame-loop director.
Routing clicks through envelope detection is how you get a cue that fires twice
or not at all.

Keep silent frames free: return one frozen shared empty array, and build a cue
array lazily (`out ??= []`) only when something actually fires.

Gate ambient voices on the VISUAL arrival, not on audio unlock, and anchor the
first scheduled one to "now" rather than firing it immediately — otherwise the
ambience starts before the world the listener is looking at.

**Mute-toggle timing:** a confirmation tick should be audible on both edges, but
`setTargetAtTime(τ = 20ms)` is only ~63% settled after 20ms. Fire the tick
BEFORE muting, and schedule it ~5τ (100ms) AFTER unmuting — otherwise the
unmute tick lands ~20dB down and sounds broken.

## Verifying sound objectively

- Per voice: AnalyserNode RMS table — non-silent peak, decays to ~0 within
  expected duration, no exceptions; feeds rise with v and return to 0.
- Whole experience: wrap the engine registry in a logging proxy and walk the
  full UX — assert cue counts/order/windows (e.g. "ping exactly 2×",
  "feed >0 only inside its story window"), mute → literal 0 RMS.

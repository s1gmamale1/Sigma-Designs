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
- jsdom has no WebAudio — guard module import (`typeof AudioContext`).

## Voice recipes (tuned values)

| voice | recipe |
|---|---|
| bloom (begin) | sine partials 523/784/1244 Hz, gains .5/.3/.18, attack 30ms, exp release 1.8s + 0.8s noise shimmer (bp 3kHz) at .06 |
| swell (arrival) | noise bp sweep 600→2400Hz over 0.7s (gain 0→.18→0) + sine glide 392→523Hz; the arrival bell starts 0.12s BEFORE the sweep dies (overlap = one gesture, gap = two) |
| ping (crossing) | sine 2349 + 2954Hz at .35, attack 5ms, release .5s — crystalline |
| bloop (bubble) | sine exp pitch sweep 880·(1+.15·var) → ×0.45 over 140ms + 5ms noise click at .04 |
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
| submerge | noise → lowpass 300+900·(1−v) Hz | v·0.22, 120ms |
| union/merge | 3 detuned triangles A3/C♯4/E4 ±4 cents | v²·0.10, 300ms |
| writing | noise → highpass 4.2kHz + sparse bell grains | 0.32·v·(1−v) — peaks mid-act, silent at both ends |

## Mix law

Hierarchy by meaning: celebration > beginning > crossings > objects >
playful > ambient > UI (measured peak RMS ~0.20 → 0.003). The music owns the
room; SFX are candlelight. Every level a named dB constant.

## Verifying sound objectively

- Per voice: AnalyserNode RMS table — non-silent peak, decays to ~0 within
  expected duration, no exceptions; feeds rise with v and return to 0.
- Whole experience: wrap the engine registry in a logging proxy and walk the
  full UX — assert cue counts/order/windows (e.g. "ping exactly 2×",
  "feed >0 only inside its story window"), mute → literal 0 RMS.

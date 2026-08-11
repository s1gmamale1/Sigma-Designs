# Navigation rails — driving one continuous world

A cinematic single-canvas experience has ONE protagonist element that never
unmounts and ONE story position. This file is the architecture for moving that
position: who writes it, how input is quantized, and how to change drive modes
without a visible seam.

## The rail model

| Term | Meaning |
|---|---|
| **playhead** | the single 0..1 story position every scrubbed effect reads |
| **rail** | what advances the playhead (scroll offset, wall clock, nav state) |
| **phase** | which rail owns the playhead right now |
| **bridge** | the eased carry of a continuous value across a phase change |

## Law 1 — one writer per phase

Exactly ONE module may write the playhead in any given phase, and the phases
must be mutually exclusive. Two writers in one frame flicker.

```js
// scroll rail: owns the playhead only while in the scroll phase
onUpdate: (self) => { progress.value = clampForPhase(self.progress, isScrollPhase()) }
// click rail: writes only when NOT in the scroll phase
if (!isScrollPhase()) progress.value = playheadFor(nav, now)
```

Mount both controllers together and let the phase flag — not mount order —
keep them exclusive. Anything that must run every frame regardless (settling a
transition) stays outside the gate.

## Law 2 — bridge EVERY continuous channel at a seam

When a phase flip swaps render branches, every continuous quantity that both
branches compute independently will STEP unless it is explicitly carried. The
failure is silent: nobody notices the un-bridged channel until it visibly jumps.

At the seam, capture the live values, then ease each toward the new branch's
resting value over ONE shared timer:

| channel | capture | ease to |
|---|---|---|
| camera depth | `fromZ` (live dolly z) | the new phase's resting z |
| submersion / interior wash | `fromDepth` | 0 |
| effective playhead | `fromProgress` | the new phase's resting playhead |
| retired one-shots | a `…Retired` boolean | never replay |

Real measured misses from omitting these: a playhead step of 0.2446→0.2292
produced a ~0.07 glow jump; an un-captured submersion surged 0.05→1 (a phantom
interior wash and audio blast); an un-flagged entrance one-shot replayed a
~1s ghost of an already-retired element over its replacement.

**Audit rule:** list every value that is continuous across the seam and prove
each is either bridged or provably identical on both sides. A channel nobody
listed is the one that steps.

## Law 3 — quantize the INPUT, never the render layer

To stop a fast gesture blowing through the story, change what input MEANS, not
what the renderer does. The renderer keeps receiving a normal timeline; it just
hops and holds.

```
wheel/touch delta → quantizer → (maybe) one eased scrollTo to the next anchor
```

| constant | value | role |
|---|---|---|
| hop duration | 1.6 s | fixed cinematic pace at ANY input speed |
| charge to fire | 800 px accumulated \|Δy\| | ≈2 firm scrolls; a light flick falls short |
| charge half-life | 260 ms | a pause bleeds partial charge — no carry-over |
| re-arm idle | 350 ms | after firing, input is DEAD until it goes idle this long |
| dwell after landing | 2000 ms | the beat SETTLES; input does nothing |

The re-arm gate is what defeats a continuous scroll: sustained input keeps the
idle gap tiny, so it never re-arms — one gesture advances exactly one beat, then
nothing until the reader deliberately pauses. Charge decays BEFORE accumulating,
and a direction flip resets it.

**Forward-only.** A trackpad's momentum tail flips the delta sign as inertia
decays. A quantizer that honors retreat reads those up-blips as a deliberate
backward gesture and ping-pongs between beats. Ignore retreat on the wheel/touch
path (spend the charge, don't move); keep retreat on the keyboard path, where a
keypress carries no momentum. One key press = exactly one beat, no charge.

**Clamp the output too.** Quantizing hops does not clamp scroll RANGE — a
full-height document still lets raw scroll run past the last anchor into
undesigned territory. Clamp the written playhead at the lock point for the
duration of that phase; make it a pure passthrough afterward.

## Law 4 — feed animation clocks a JANK-CLAMPED time

Any easing library you drive manually (smooth-scroll tweens, accumulated
rotations) must be fed `Σ min(Δt, cap)`, never raw wall clock.

```js
const MAX_TICK_MS = 33
let clockMs = 0, lastMs = -1
const tick = (timeSec) => {
  const now = timeSec * 1000
  clockMs += lastMs < 0 ? 16 : Math.min(now - lastMs, MAX_TICK_MS)
  lastMs = now
  lenis.raf(clockMs)          // same pattern: rotationAcc += Math.min(delta, 0.1)
}
```

The wall clock keeps running through a stalled frame, so the tween consumes the
whole gap on the next tick and **teleports**. Measured: a first-hop shader/raster
compile stall made the playhead leap 0.012→0.060 in ONE frame — read as "instant,
snappy, glitchy". GSAP's `lagSmoothing` does NOT fix this: a series of 100–300ms
frames each stays under its 500ms threshold and still fast-forwards cumulatively.
Clamping makes any stall pattern play slightly SLOWER instead of skipping — a
dive stays a dive. Idle behavior is unaffected (no tween in flight ⇒ the clock
offset is irrelevant to event-driven input).

Same rule for any accumulator (`+= Math.min(delta, 0.1)`) or a background tab
returns and your slow rotation snaps a half-turn.

## Law 5 — a HELD playhead freezes everything keyed to it

The moment you move from a scrubbed rail to a discrete one (click navigation),
the playhead stops moving — and every effect still scrubbed by it silently dies:
light choreography, interior wash, particle fields, boundary films, audio feeds,
in-element text. Green tests keep passing; the world just stops breathing.

**Revive by mapping, not retuning.** Give the frozen effects a derived playhead
that reports the REPRESENTATIVE position each was tuned for, eased over the
transition timer:

- settled at a hub → the resting-read position (an awake, alive value — NOT the
  dormant near-zero one)
- settled in a section → that section's read plateau, `range[0] + 0.78·span`
- entering → sweep `sectionStart → readPlateau` across the eased transition, so
  crossing effects (shell flashes, entry films) actually fire
- leaving → the reverse sweep, so exit effects fire on the way out

Pick the read fraction deliberately: 0.78 sits past the entry crossing (so no
residual flash at rest) yet below the section-end boundary window (so no
resident exit film).

**Depth is separate from position.** Derive camera submersion from the
transition timer, not from the derived playhead — a read plateau sitting inside
an entry envelope would report phantom submersion at rest (and a permanent
audio drone at the hub).

The class extends to STATE predicates, not just numbers: any latch computed from
the old rail (`dockedCount(playhead)`, `act`, `chapterIndex`) is equally frozen.
After migrating rails, audit every `f(playhead)` value AND every latch.

## Law 6 — single ease, raw-linear inputs

Rails return RAW LINEAR fractions; exactly one consumer applies the ease.

Double-easing is invisible in a unit test and obvious on screen: an element
measured perfectly smooth still arrives ~0.56 of the way ahead of the camera,
because `emphDecel(emphDecel(t))` front-loads twice. If a pose function eases,
the rail feeding it must return `(now − startSec) / duration` clamped 0..1 —
nothing more.

## Law 7 — pure reads, explicit settles

A per-frame read must never mutate shared state. A transition helper that
flipped `kind → 'none'` on READ meant callers later in the same frame saw a
different phase than callers earlier — a one-frame glitch that moves depending
on call order.

Split it: the value settles itself (returns 1 past its duration, idempotent),
and ONE writer per frame flips the state explicitly. Then every consumer in a
frame sees a consistent world.

Guard re-entry by ELAPSED TIME rather than state alone (`kind !== 'none' && now
> startSec && now − startSec < DURATION`), so a fast double-click is blocked
even without a prior settle call.

## Law 8 — a windowed effect needs a rule for every state that can REST in
its window

An effect keyed to a narrow band of the playhead (a boundary sweep, a crossing
flash) assumes the playhead moves THROUGH the band. Two states break that:

- **Resting inside the window.** A lock/anchor position that happens to sit
  inside a boundary band leaves the effect permanently resident — a film that
  should sweep for 400ms sits over the content forever.
- **Teleporting across the window.** A phase handoff that jumps the playhead
  crosses boundaries it never travelled; any non-zero strength there is a snap.

Suppress explicitly for both (`strength = 0 when restingPhase || handoff`), and
hide the mesh entirely below a strength epsilon so a fullscreen transparent
quad is not overdrawing every idle frame.

## Law 9 — when the trigger source changes, audit for a SECOND pulse

Migrating a trigger (scroll position → click state) leaves the old consumers
running. The classic result is one event firing twice: an interior bloom on the
new timer, plus a narrow flash still fired by the old geometric crossing —
which the new camera path may not even reach.

Derive channels that should read as ONE event from ONE envelope, and conserve
the original peak when you unify them (measure it; don't eyeball it). Where the
old geometry is still real — a phase that genuinely dives through the shell —
keep the old trigger for that phase only.

**DOM affordances must import the 3D transition's constants.** A pill fading
over a hand-picked `0.45s` beside a 1.6s camera move vanishes a full second
early. Import the duration AND the bezier the camera rides, so the overlay and
the world share one clock and one curve.

## Reference numbers

| constant | value |
|---|---|
| transition / cutscene duration | 1.6 s (same as the hop) |
| resting camera z (framed out) | 3.2 |
| held reading z | 2.5 — pulled back for a dark margin around the text |
| transiently-crossed dive apex z | 0.4 |
| read plateau fraction | 0.78 |
| jank clamp | 33 ms (frame clocks) / 0.1 s (accumulators) |

**Camera is dolly-ONLY with fixed fov.** No lateral moves, no fov animation —
vection breaks the "the element is the character" illusion and induces motion
sickness on a continuous canvas. A depth the camera merely CROSSES can be far
tighter than one it HOLDS: a framing tuned for a transient apex will feel
suffocating the moment a navigation model starts resting there.

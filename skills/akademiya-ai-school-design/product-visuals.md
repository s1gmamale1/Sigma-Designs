# Product visuals (marketing site)

Source: `src/marketing/` of the Akademiya Frontend repo (on dev and prod since #221/#222). §6 lives in `components/FamiliarBeats.tsx`, `styles/familiar.css`, `publicAssets.test.ts` and `tests/e2e-marketing/familiar-art.spec.ts`. The rest: `components/Visuals.tsx`, `useTilt.ts`, `styles/tilt.css`, `styles/phone3d.css`, `styles/home.css` (phone body), `phone3d/{model,scene,usePhone3d}.ts`. Contracts: `tilt.test.tsx`, `phone3d/scene.test.ts`.

## 1. Rules

- Real captures only, from in-house fixtures with fictional names. No browser/window frames. No CSS-drawn placeholder UIs.
- No per-image "sample data" chip or label. This is an approved owner exception: DESIGN.md `DEMO-01` (approved 2026-10-31; test: `marketingSite.test.tsx` "captures shown without a per-image sample-data label"). The interactive demo page keeps its one-line notice. Review if real school data or client screenshots are ever used.
- Image sizes come from `productAssets.ts` (`ProductShot { src, width, height }`) so the box is reserved (no layout shift). Page's largest image `priority` (eager, `fetchPriority=high`); all others `loading=lazy decoding=async`.
- Every capture keeps real `alt` text. The tutor card stays Uzbek (`lang="uz"`) on ru/en pages.

## 2. Markup

PanelShot (desktop capture):
```
<figure class="mk-panel" data-tilt="panel">
  <span class="mk-tilt-shadow" aria-hidden="true"/>      <!-- moving shadow layer -->
  <span class="mk-panel__plane">                          <!-- the tilted plane -->
    <img width height alt .../>
    <span class="mk-glare" aria-hidden="true"/>           <!-- moving highlight -->
  </span>
</figure>
```
PhoneShot (mobile capture):
```
<figure class="mk-phone" data-tilt="phone">
  <span class="mk-tilt-shadow" aria-hidden="true"/>
  <div class="mk-phone__body">
    <span class="mk-phone__island" aria-hidden="true"/>
    <div class="mk-phone__screen"><img .../></div>
    <span class="mk-glare" aria-hidden="true"/>
    {overlay && <div class="mk-phone__overlay">{overlay}</div>}   <!-- tutor card -->
  </div>
</figure>
```
Tutor card: `<div class="mk-tutor-card" role="img" lang="uz" aria-label="{title}. {body}">` with three `aria-hidden` children (title, body, button).

CSS phone geometry (`home.css`, designed for a 300px body): `.mk-phone { width: min(300px,72vw) }`; body `padding 11px; radius 46px; background linear-gradient(145deg,#2a2530,#0e0b11)`; screen `padding-top 38px` (status band), `radius 36px`, bg `#f4f6f8`; island `top 22px; width 30%; height 22px; #050407`. Panel: `perspective: 1800px`, image radius 18px.

## 3. Tilt contract (`useTilt.ts` writes, `tilt.css` reads)

Variables on the figure: `--mk-rx`, `--mk-ry` (deg), `--mk-px`, `--mk-py` (-1..1), `--mk-gx`, `--mk-gy` (% for glare). Attributes: `data-tilt-state` (`armed` | `in`), `data-tilt-hover`, `data-tilt-near`; `data-tilt-live` on `<html>`. Registered props: `--mk-lift` (length, transition `.5s cubic-bezier(.16,1,.3,1)`), `--mk-glare` (number, `.35s ease`).

| Item | Value |
|---|---|
| Who | mouse and pen only (`pointerType`), only when `(hover: hover) and (pointer: fine)`. Touch/coarse: entrance only, no tilt. Reduced motion: nothing at all |
| Lean | not hovered: max 8deg, normalised by the VIEWPORT half-size. Hovered: max 14deg, normalised by the FIGURE half-size |
| Axes | `rx = -ny * max * 0.7`, `ry = nx * max`, nx/ny clamped to -1..1 around the figure centre |
| Glare | `gx, gy` = pointer position in the figure, clamped 0..100% |
| Hover | topmost element at the pointer (`elementFromPoint(...).closest('[data-tilt]') === node`), so the nav or a card overlay wins; hover raises `--mk-glare: 1` and `--mk-lift`: panel 36px, phone 28px |
| Easing | per-frame `pose += (goal - pose) * 0.12`; settled below 0.01 |
| Loop | rAF; reads all rects first, then writes (no layout thrash); sleeps when nothing moves; wakes on pointermove, scroll, resize; `blur`/`pointerleave` releases to flat. Writes only changed values |
| Measured while entering | a figure that is `armed`, or `in` with a running `mk-spin-up` animation, is held flat and unhovered |
| near | `IntersectionObserver` (default margin) sets `data-tilt-near`; only near figures are measured and carry `will-change: transform` |
| Cleanup | removes every variable and attribute |

Panel: `.mk-panel__plane { transform-origin: 60% 50%; transform: rotateY(calc(var(--mk-base-ry,-9deg) + var(--mk-ry))) rotateX(calc(4deg + var(--mk-rx))) translateZ(var(--mk-lift)) }`. Flipped (`.mk-cure--flip`): base ry `9deg`, origin `40% 50%`, spin sign flips. Contact shadow on the img only `0 2px 6px rgba(21,25,34,.08)`.

Phone: `.mk-phone__body { transform: perspective(1400px) rotateY(calc(10deg + var(--mk-ry))) rotateX(calc(3deg + var(--mk-rx))) translateZ(var(--mk-lift)); box-shadow: inset 0 0 0 1.5px rgba(255,255,255,.12) }`. Screen img drifts inside the clipped screen: `translate3d(px * -7px, max(0, -py) * 7px, 0) scale(1.04)`, origin `50% 0`.

Shadow layer (own static layer, only `transform` moves per frame): `inset: 6% 5% 0; radius 18px; rgba(36,18,60,.4); blur(30px); opacity .8 (1 on hover)`; `transform: translate3d(px*-18px, calc(30px + lift*.6 + py*-14px), 0) scale(.95)`. Phone shadow: `inset: 4% 10% 1%; radius 46px`.

Glare: `inset:0; radial-gradient(circle at var(--mk-gx,50%) var(--mk-gy,30%), rgba(255,255,255,.32), transparent 55%); mix-blend-mode: soft-light; opacity: var(--mk-glare)`.

### Entrance (spin-in)

- Armed only for figures with `top > innerHeight * 0.92` at hydration (`data-tilt-state="armed"`); fires at IO `threshold [0, 0.2]` when `intersectionRatio >= 0.2` (`in`). Works on coarse pointers too. Never for the first screen.
- Armed: `opacity 0; transform: perspective(1600px) rotateY(var(--mk-spin-y)) rotateX(18deg) rotateZ(-3deg) translateY(80px) scale(.8); blur(8px)`. `--mk-spin-y`: `-55deg`, phone and flipped `55deg`.
- In: `animation: mk-spin-up 1.3s cubic-bezier(.16,1,.3,1) both`; `opacity 1` at 40%; ends `transform:none; filter:none`. It runs on the figure so it composes with the tilt on the plane/body.
- One entrance per visual: the surrounding reveal box is exempt (see motion-system.md section 2).

### Tutor card as phone overlay

- `.mk-phone__body { transform-style: preserve-3d }`; `.mk-phone__overlay { position:absolute; z-index:3; left:34%; bottom:18%; width:100%; transform: translateZ(48px) }` so it tilts, lifts and spins with the phone and overhangs the right edge on wide screens.
- <=720px: `left:6%; width:88%; bottom:10%`, card `rotate:none` (inside the frame; an overhang would be cut off).
- Lands after the phone: `[data-tilt-state="in"] .mk-tutor-card { animation: mk-card-land .7s cubic-bezier(.16,1,.3,1) .85s both }`, from `opacity 0; translate 0 24px; scale .9`.
- Reduced motion: `[data-tilt][data-tilt-state]` forced `animation none; opacity 1; transform none; filter none`; plane and screen img `transform none`; `.mk-glare` hidden; shadow `translate3d(0,30px,0) scale(.95)`, no transition; phone body keeps its rest lean `perspective(1400px) rotateY(10deg) rotateX(3deg)`; card `translateZ(48px)` stays on it.

## 4. Real 3D phone (`phone3d/`)

Swaps the CSS phone for WebGL per figure; the CSS phone stays in the layout (it carries the tutor card), so any failure leaves it as it was. three.js r170 (WebGL2), procedural model, no asset files. The scene module is a lazy chunk (`import('./scene')`), one load shared by all figures, retried if it failed.

### Mount gate (`usePhone3d.ts`)

| Step | Contract |
|---|---|
| When | per figure `figure[data-tilt="phone"]`, `IntersectionObserver rootMargin '400px 0px'`, first time near; needs hydration + IO |
| Probe before fetching | `webglUsable()`: `getContext('webgl2', { failIfMajorPerformanceCaveat: true })`; reject if the unmasked renderer matches `/swiftshader\|llvmpipe\|softpipe\|software\|basic render/i`; then `WEBGL_lose_context.loseContext()`. Result cached; if false the chunk is never fetched |
| Canvas | `<canvas class="mk-phone__canvas" aria-hidden="true">` inserted BEFORE the body (after the shadow) so the body's tutor card paints above; `position:absolute; z-index:1; pointer-events:none` |
| Canvas box | body box grown by margin X `0.14 * bodyWidth`, Y `0.08 * bodyHeight` (whole px); on narrow columns X margin capped by `(parentWidth - bodyWidth)/2`, min 8 |
| Ready | `data-phone3d="ready"`: CSS body goes `background: transparent; box-shadow: none`; its children except the overlay fade to `opacity 0; pointer-events:none` (NOT `visibility:hidden`, so the capture `<img>` alt stays in the accessibility tree) |
| Failure | no context, chunk error, texture/image error, `webglcontextlost` => `discard()` (dispose, remove canvas and attrs) => CSS phone returns |
| Pose source | read from what useTilt writes (`--mk-rx/ry`) plus CSS-eased `--mk-lift` (computed style), so canvas and card rise together; draws only when the pose changed; rAF sleeps when settled (lift within 0.05 of goal 0/28) |
| Spin | if still `armed` when ready: `data-phone3d-entry`, spin starts at 55deg; on `armed -> in` (MutationObserver) spin eases `55 * (1 - t)^4` over 1300ms. CSS figure animation is swapped to `mk-phone3d-in` (opacity fade only) so the flat spin does not lay the canvas flat; only if ready BEFORE the entrance (swapping on an `in` figure restarts and blinks) |
| Resize | debounced 150ms; re-place canvas, `resize(box)`, forced redraw |
| Reduced motion | pose forced flat, no rAF: one still frame at the rest lean; `[data-tilt="phone"][data-phone3d="ready"][data-tilt-state] { animation:none }` |

### Camera and pose (`scene.ts`)

- Built in CSS px; camera reproduces `perspective(1400px)`: `fov = 2*atan(canvasHeight/2/1400)`, `aspect = canvasW/canvasH`, camera on the z axis at distance 1400, `near = 140`, `far = 5600`. So the DOM overlay aligns.
- Pose = `rotateY(10deg + ry + spin) rotateX(3deg + rx) translateZ(lift)` as Euler `YXZ`: X is NEGATIVE (CSS rotateX brings the bottom forward; three y is up), lift runs along the phone's own normal.
- Renderer: `outputColorSpace sRGB`, `ACESFilmicToneMapping`, clear alpha 0, pixel ratio `min(dpr, 2)`. Lighting: `RoomEnvironment` through `PMREMGenerator.fromScene(room, 0.04)` (set per material; three ignores `envMapIntensity` for `scene.environment`) + one `DirectionalLight(0xffffff, 2.5)` at (-1, 1.3, 1.1). Env rotated `-PI/3` about X so light boxes sit behind the phone (glass mirrors the dim floor, not a light box).
- Context attributes: `alpha, depth, premultipliedAlpha, stencil:false, failIfMajorPerformanceCaveat:true, powerPreference:'low-power', preserveDrawingBuffer:false`; `antialias = dpr < 2 || (pointer: fine)` (MSAA stays wherever a mouse tilts it; touch 2x skips it).
- `createPhone3D` returns `null` (quiet) on no context or renderer throw.
- Load: `await image.decode()` (crossOrigin anonymous) -> paint texture -> `compileAsync` if `KHR_parallel_shader_compile` exists, else one draw. `ready` rejects if disposed or context lost. `dispose` waits for the compile to finish, frees model, texture, env, renderer, then `forceContextLoss()` unless already lost.

### Model (`model.ts`), all sizes scale by `k = bodyWidth / 300`

| Part | Spec |
|---|---|
| Body (titanium) | rounded slab radius `46k`, thickness `0.115 * bodyWidth`, edge `0.17 * thickness`, bevel 6 segments, `toCreasedNormals(PI/3)`; `MeshPhysicalMaterial` color `0xb0aba2`, metalness 1, roughness .26, clearcoat .35 / .2 |
| Glass | slab inset by `1.6k` rim, depth `2k`; color `0x020203`, roughness .05, clearcoat 1 / .03, envMapIntensity .25 |
| Screen | rounded panel `(bodyW - 22k) x (bodyH - 22k)`, radius `36k`, z `+0.05k`; `MeshBasicMaterial({ toneMapped:false })` = unlit, exact capture colours |
| Island | panel `0.3 * bodyW x 22k`, radius `11k`, top `22k`; black clearcoat .6, envMapIntensity .15, z `+0.1k` |
| Sheen | additive overlay over the screen, `opacity .06`, `depthWrite:false`, `renderOrder 1`, z `+0.2k`: adds reflection only, can never darken the screen |
| Side buttons | `RoundedBoxGeometry`, width `4k`; left: action (at 0.215h, length .052h), volume (.305h, .092h), volume (.41h, .092h); right: power (.335h, .15h) |

### Screen texture

- Canvas 2D: fill `#f4f6f8`, draw the capture at full screen width below a `38k` status band (same composition as the CSS phone). `CanvasTexture`, sRGB, anisotropy `min(8, max)`.
- Scale (`textureScale`): `shown = min(dpr, 2)`; `useful = max(shown, min(2*shown, captureWidth/screenWidth))`; capped by `maxTextureSize / max(screenW, screenH)`. At 1x = 2; at 2x stops at the capture's native width (780px capture on a 278px screen = 2.81x).
- After upload the source drawing is shrunk to 1x1 (`onUpdate`); a resize redraws from the decoded image.
- Texture memory (measured at dpr 2): the screen texture is capped at the capture's own resolution, 780×1795 for a 780-wide capture, about 5.6 MB, about 7.5 MB with mipmaps (uncapped it was 1112×2558, about 15 MB). The 2D source canvas is shrunk to 1×1 after upload.

### Budgets

| Item | Number |
|---|---|
| three chunk | ~130 KB gzip (measured 129,931 bytes for scene-*.js in the built site), lazy, never in the main bundle, never fetched when the probe fails |
| Canvas margin | 14% X, 8% Y (farthest pose lands within ~5%; more only costs GPU memory) |
| Pixel ratio | capped at 2 |
| Draw budget | only when pose changes; one rAF shared by all near figures |

## 5. Gotchas

| Bug | Cause | Fix / rule |
|---|---|---|
| Tilt measured wrong during entry | rect of a transformed (armed / spinning) figure | hold flat + unhovered until the `mk-spin-up` animation has finished |
| Hover on a figure behind the nav / card | rect test only | `elementFromPoint(...).closest('[data-tilt]')` |
| Idle pages burning GPU memory | permanent layer per figure | `will-change` only on `data-tilt-near` figures |
| Shadow repainting per frame | shadow blur animated | static blurred layer, only `transform` moves |
| Box rose AND figure spun | two entrances on one visual | exempt the reveal box via `:has([data-tilt])` |
| Tutor card lost its 3D place | overlay outside the phone's 3D space | inside `.mk-phone__body` with `preserve-3d`, `translateZ(48px)`; stays on the CSS body even when WebGL is ready |
| Card cut off on phones | overhang beyond the column | <=720px inside-frame placement |
| 3D phone blinked / restarted spin | swapped figure animation on an already-`in` figure | `data-phone3d-entry` only when ready before the entrance |
| Flat spin laid the canvas down | figure-level `mk-spin-up` on a canvas phone | `mk-phone3d-in` (opacity) for ready-before-entry |
| Capture alt text lost | `visibility:hidden` on the CSS phone | opacity 0 instead; canvas `aria-hidden` |
| Screen washed out / dull | tone mapping + lit material | `MeshBasicMaterial`, `toneMapped:false`; glass envMapIntensity .25 so it stays black; sheen additive only |
| Frame and buttons stair-stepped | no MSAA | MSAA wherever `(pointer: fine)`; skip only on touch at 2x |
| Software GL users got a slow phone | WebGL context exists but is CPU | `failIfMajorPerformanceCaveat` + renderer-name regex, before fetching the chunk |
| First frame stalled | shaders compiled synchronously | `compileAsync` with `KHR_parallel_shader_compile`; otherwise one draw during load |
| Teardown threw | disposing under `compileAsync` polling | `dispose` waits for `warming` |
| Mirrored tilt | CSS rotateX vs three y-up | X rotation negated in `poseMatrix` |
| Lost context left a blank phone | no fallback | `webglcontextlost` => `discard()` => CSS phone |
| Texture memory | 4x screen texture on 3x phones | cap at capture native width and GPU limit |

## 6. Pain plates ("Sound familiar?" cards)

Each carousel card carries a path-traced still from the sales deck's 3D studio. That's an evening desk (warm-black table and room, one lamp key, warm except a cold key on `quarter`, and a faint cool rim) with the brand objects: red spiral notebooks, a yellow pencil and star, a paper speech bubble, the red-roofed schoolhouse. One scene per pain `key`. Each scene sits in the right half of a 16:9 frame, and the left half is dark negative space for the text.

| key | Scene | Deck scene (`marketing/deck/3d/plates.mjs`) |
|---|---|---|
| opinion | a lone speech bubble | `p4`, rendered with the camera 0.02 left of the deck framing (position `[0.057, 0.16, 0.33]`, target `[0.057, 0.03, -0.012]`) so the bubble sits further right |
| scattered | every object scattered apart | `scattered` |
| checking | a notebook stack with a pencil | `p3` |
| scratch | the schoolhouse alone at dusk, a short loose red end at the door | `p1` |
| stuck | an open notebook with the pencil on its page, a cut red end | `stuck` |
| parents | a lone star | `p2` |
| quarter | a closed red notebook | `quarter` |

- **Making them:** the deck's Higgsfield path tracer (headless Chrome WebGPU on 127.0.0.1 only), 1920×1080 at 256 spp (about 15 s each on an M4), made 8-bit before use. Then `cwebp` at 1600×900 (q86) and 800×450 (q84), into `public/landing/img/familiar/<key>-<w>.webp`, about 155 KB (155,950 B) for all 14. No text, people or product UI in a plate; `alt=""` (decorative, the line carries the meaning). List the files in `publicAssets.test.ts`. The `ART` map is typed `Record<HomePain['key'], …>`, so a new key needs its plate.
- **Desktop:** the plate is fit by **width** (`width:100%; height:auto`), anchored right and bottom, over a `#000` base, with a 6% top mask so it has no seam.
  - Never use `object-fit: cover` here. The cards share the tallest card's height, so cover scales the plate and slides the scene under the text.
  - Card `min-height` is at least the plate's height (a container-query calc). Put the plain `clamp(19rem, 50svh, 29rem)` first as the fallback.
  - Line measure `min(20ch, 52%)`; scrim `rgba(18,13,20)` .92 → .78 at 35% → .62 at 58% → 0 at 72%, plus a bottom fade.
- **Mobile (≤720px):** a full-bleed 4:3 band above the text (`object-position: right center`), fading into the card. `sizes="(max-width: 720px) calc((100vw - 3rem) * 1.34), 50rem"`.
- **Loading:** lazy in the static HTML; once the gallery is first on screen, all seven switch to eager. Lazy images inside a horizontal scroller only load as each card slides in, so they would pop in mid-slide.
- **Long Uzbek words:** `overflow-wrap: break-word`, and a soft hyphen at the morpheme boundary where a word is wider than the measure ('O‘qituvchi\u00ADlaringiz').
- **Proof before merge:**
  - glyph-masked contrast on every card × uz/ru/en × 1440 and 1024, giving line ≥ 3:1 and detail ≥ 4.5:1 (measured 18.2 / 8.4);
  - glyph-to-object clearance > 0;
  - `tests/e2e-marketing/familiar-art.spec.ts` checks decode, width-fit geometry, the mobile band, and each line's right edge ≤ 53% of the card.

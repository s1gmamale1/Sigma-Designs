# Build and verify (Sparkle Express)

Source root: `sparkle-express-source/` (README.md, build_content.py, content/, dist/, docs/). Static site, no backend.

## 1. Build

| Item | Fact | File |
|---|---|---|
| Tooling | Python 3 only. No npm, no third-party packages (stdlib: pathlib, html, json, hashlib, re) | README.md |
| Command | `python3 build_content.py` (run from the source root) | README.md |
| Output | 8 HTML pages, `404.html`, `sitemap.xml`, `robots.txt`, all under `dist/` | build_content.py build() |
| 8 pages | `/`, `/services/`, `/approach/`, `/about/`, `/contact/`, `/company/` (from `content/corporate.py`) + `/terms/`, `/privacy/` (from `content/legal.py`) | build_content.py |
| Console line | `Generated N complete pages, 404.html, sitemap.xml, and robots.txt.` N should equal the page count | build() |
| Page shape | `render(route, page)`: head (meta, robots, canonical, og, twitter, favicon, font preloads, motion-gate inline script, `site.css`, `motion.css`, deferred `site.js` and `motion.js`, JSON-LD Organization) then `body#top` with skip link, header, `<main id="main">`, footer | build_content.py |
| Asset versioning | `version_assets()` appends `?v=<first 10 hex of sha256>` to local `.css .js .webp .png .jpg .svg` URLs in `src`/`href`; re-run the build after editing CSS/JS/images so cache-busting hashes update | build_content.py |
| Body class | `page-home` for `/`, else `light-page` | build_content.py |
| 404 | `render(..., indexable=False, canonical=False)`: `noindex,nofollow`, no canonical, no og:url | build_content.py |

### Switches (top of `build_content.py`)

| Name | Default | Effect |
|---|---|---|
| `ORIGIN` | `https://sparkleexpressllc.com` | canonical, og:url, og:image (`/assets/images/hero-devices.webp`), JSON-LD url and logo (`/favicon.svg`), sitemap `<loc>` |
| `INDEXABLE` | `True` | `True`: `robots` meta `index,follow`, `robots.txt` = `Allow: /` + Sitemap line. `False`: `noindex,nofollow` and `Disallow: /` (use for staging) |

Change `ORIGIN` for a different domain, then rebuild.

## 2. Editing rules

| Change | Where | Never |
|---|---|---|
| Page copy, markup, new page, `idea_stage()` calls | `content/corporate.py`, `content/legal.py` | Edit generated `dist/**/index.html`: the next build overwrites it |
| Header, nav (`NAV` list), footer, meta, JSON-LD | `build_content.py` | |
| Hero sketch SVG | `content/sketch.py` | |
| CSS | `dist/site.css`, `dist/motion.css` directly | Put CSS in Python strings |
| JS | `dist/site.js`, `dist/motion.js` directly | Add a bundler or dependency |
| Images | `dist/assets/images/*.webp` (hero 1672x941) | Hotlink an image |
| Fonts | `dist/assets/fonts/` (Schibsted Grotesk variable `woff2` + italic, Kalam 400 and 700; SIL OFL texts included) | Load Google Fonts or any CDN |
| Image prompts and provenance | `docs/image-prompts.md` | |

- The generator rewrites HTML only; CSS, JS, images stay as edited.
- New route: add a row to the `data` list in `build_corporate_pages()` (route, title, description, body, active nav key, theme). The sitemap picks it up automatically.
- Self-hosted assets only: no external fonts, scripts, images, analytics, or trackers. The only outbound links are `rel="noopener noreferrer"` anchors to the products site (`target="_blank"`, `↗` arrow).
- Images use `picture()` -> `<img ... width height loading="lazy" decoding="async">`; the hero uses `fetchpriority="high"`. Always set `width`/`height` and a descriptive alt that says the image is illustrative.

## 3. Local preview

```bash
python3 -m http.server 8000 --bind 127.0.0.1 --directory dist
```

Open `http://localhost:8000/`. Use a server, not `file://`, because asset and link paths start at the site root (`/site.css`, `/assets/...`). View Transitions need real same-origin navigation.

## 4. Deploy (nginx, static)

Serve `dist/` at the domain root. DNS `A` record for `@` and `www` to the server IP.

```nginx
server {
    server_name sparkleexpressllc.com www.sparkleexpressllc.com;
    root /var/www/sparkle-express/dist;
    index index.html;
    location / { try_files $uri $uri/ =404; }
    error_page 404 /404.html;
    location /assets/ { expires 30d; add_header Cache-Control "public"; }
}
```

- HTTPS: `certbot --nginx -d sparkleexpressllc.com -d www.sparkleexpressllc.com`.
- `/assets/` is cached 30 days; `site.css`/`motion.css`/JS rely on the `?v=` hash for freshness, so rebuild before deploy.
- Before going live: `ORIGIN` correct, `INDEXABLE` correct for the target, the studio mailbox exists and receives mail, policies match real practice.

## 5. Verification checklist for a new or changed page

Mark each item with a receipt (command output, screenshot, or console log). Anything not run is UNVERIFIED.

1. Build: `python3 build_content.py` exits 0 and prints the expected count; `git diff`/file listing shows only intended `dist/` changes; `sitemap.xml` lists the new route.
2. Serve locally with the command in section 3; `curl -sI http://127.0.0.1:8000/<route>/` returns 200; an unknown path returns the 404 page.
3. Console: load the page and click through; zero errors and zero warnings; no failed requests; every request is same-origin (Network tab shows no third-party host).
4. Layout at 1440px wide and 390px wide: no horizontal scroll, hero headline outline and fill legible, nav collapses to the toggle at <=880px, tap targets >= 44px, sticky header does not cover anchors.
5. Reduced motion (emulate `prefers-reduced-motion: reduce`): no `html.motion`, all content visible immediately, no view transition, sketch slider shows at 52% without intro, marquee static.
6. No JS (disable scripting): all copy, images, panels, and links are visible and readable; workflow panels stack; brief fieldset shows the `<noscript>` message; desktop nav still works.
7. Keyboard only: Tab order is logical and skip link works; focus ring visible (3px violet); slider moves with arrow keys and Home/End and announces via the range label; workflow tabs use Left/Right/Home/End with one tab stop; Escape closes the mobile menu and returns focus to the toggle; focus reveals a tucked header.
8. Motion layer: scroll top to bottom once; every `.reveal` becomes visible (also check after 4s with scripting stalled); progress bar reaches the right edge; header tucks on scroll down and returns on scroll up; process rail fills and steps activate; marquee speeds up with scroll.
9. Brief builder: with DevTools Network open, fill the form and use create, copy, save, and email: no request is made, nothing in localStorage/sessionStorage/cookies, the mail link is `mailto:` only, the copy, select-fallback and download statuses say "Nothing has been sent" (the create status does not), validation blocks names <2 chars and descriptions <20 chars.
10. Image disclosure: AI-generated photos carry an "illustrative" caption or alt, and the `#imagery` "About the imagery" section is present and linked from the footer.
11. Meta: `<title>` and description unique per page; canonical equals `ORIGIN` + route; `robots` meta and `robots.txt` match `INDEXABLE`; JSON-LD parses.
12. Print preview hides header, footer, nav toggle, brief panel, slider handle and range (`@media print`, `site.css`).

## 6. Not found in source

- Portfolio filters: mentioned in `README.md` but no markup or code exists in `dist/site.js` or `content/corporate.py`.
- Playwright observation of live motion was not run for these two files; values come from source.

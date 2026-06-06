# CLAUDE.md — rollingcat-website

Guidance for AI agents (and humans) working in this repo. Read this first.

## What this is

The public marketing/portfolio site for **RollingCat Software**
(https://rollingcatsoftware.com) — the solo software brand of Ahmet Abdullah
Gültekin. It is **one hand-written `index.html`** (~110 KB) with **all CSS and
JavaScript inline**. No framework, no bundler, no build step, no runtime
dependency. The simplicity is the product statement.

## Hard constraints (do not violate)

- **Keep it static. NEVER dockerize this site.** Explicit owner rule — it stays
  a static file set on Hostinger shared hosting. No containers, no server-side
  runtime, no Node/PHP backend.
- **No build step / no framework** unless a review explicitly calls for one and
  it's low-risk. New capability is added as inline HTML/CSS/JS. (A *build-time-
  only* static generator is a deliberate future option — see ROADMAP Phase 6 —
  but the deployed output must stay plain static files.)
- **Bilingual parity.** Every user-facing string ships an EN + TR pair via the
  inline `data-en` / `data-tr` toggle. Keep the counts balanced on every
  content PR (currently 113 / 113 — check with
  `grep -o data-en index.html | wc -l` vs `data-tr`).
- **Reversible changes.** This is the brand's front door. Prefer one-line,
  easily-revertible edits; browser-verify before merging.

## Repository layout

| File | Purpose | Ships to live host? |
|------|---------|---------------------|
| `index.html` | The entire site (inline CSS + JS) | **yes** |
| `.htaccess` | Security headers (incl. CSP), caching, gzip | **yes** |
| `sitemap.xml`, `robots.txt` | Crawl directives | **yes** |
| `og-image.png` | 1200×630 social card | **yes** |
| `humans.txt`, `security.txt`, `.well-known/security.txt` | Credits + RFC 9116 | **yes** |
| `deploy.sh` | Manual rsync deploy | no (excluded) |
| `.github/workflows/deploy.yml` | Best-effort Actions deploy | no (excluded) |
| `README.md`, `CLAUDE.md`, `ROADMAP.md`, `TODO.md` | Project docs | **no** (excluded) |
| `docs/` | Review / planning docs | **no** (excluded) |

## Deploy mechanism

- **Reliable path: `./deploy.sh`** — rsync over SSH port 65002 to
  `~/domains/rollingcatsoftware.com/public_html/` with `--delete`. Run it from a
  host that can reach Hostinger (`46.202.158.52:65002`) and has the SSH key
  (e.g. the project server).
- **Best-effort: `.github/workflows/deploy.yml`** on push to `master`. The
  GitHub-hosted runner **often cannot reach Hostinger**, so treat Actions as a
  convenience that may not land. There is **no reliable auto-deploy** — merging
  does not guarantee a live deploy; run `./deploy.sh` manually.
- **Deploy excludes** (kept out of the live bundle, in BOTH `deploy.sh` and
  `deploy.yml`): `.git`, `.github`, `deploy.sh`, `.claude`, `docs`, `CLAUDE.md`,
  `README.md`, `ROADMAP.md`, `TODO.md`. So docs you add under `docs/` (or any of
  the listed markdown files) **never ship** — good. If you add a new docs file
  at the repo root, either put it under `docs/` or add it to both exclude lists.

## `.htaccess` quoting gotcha (IMPORTANT)

Hostinger's Apache **leaks literal backslashes** into `Header` directive values
when you use escaped inner quotes. When editing `.htaccess` `Header` lines, use
a **single double-quoted outer delimiter with no escaped inner quotes**. The
CSP value is the canonical safe example: its directives use *single* quotes for
keywords (`'self'`, `'unsafe-inline'`) inside one pair of double quotes — never
write `\"...\"` inside a header value.

## Stack notes

- **Fonts:** Bunny Fonts (`fonts.bunny.net`) — a GDPR/KVKK-compliant, EU-hosted,
  cookieless drop-in for Google Fonts (same `css2?family=...` API; no visitor IP
  sent to Google). Both the font CSS and woff2 files come from the one
  `fonts.bunny.net` origin, which is therefore listed in the CSP `style-src` and
  `font-src`. Only the weights actually used are requested (400/500/600/700) with
  `display=swap`. (Self-hosting woff2 is the deeper Phase 4 option if SRI /
  zero-third-party is ever required.)
- **No third-party JavaScript** is loaded from any CDN — zero versioned-library
  CVE surface.
- **SEO:** canonical + hreflang (x-default/en/tr on one URL), OG + Twitter cards
  (with `image:alt`), four JSON-LD nodes (Person/Organization/WebSite/
  ProfilePage). Keep `sitemap.xml` `lastmod` and JSON-LD `dateModified` wired to
  real change dates.
- **a11y:** skip link (surfaced on focus), `aria-expanded`/`aria-controls`
  mobile menu, language-aware toggle `aria-label`, `aria-hidden` decorative
  icons, `:focus-visible` rings, WCAG-AA text contrast, and a **no-JS /
  reduced-motion fallback** (scroll-reveal content stays visible when JS is off —
  the hidden state is gated on an `html.js` class set before paint). Preserve
  all of this when editing.

## Working conventions

- Default branch: **`master`**. Branch protection requires 1 review; admin
  bypass is allowed for the solo owner. No CI gate.
- Always pass the repo flag to `gh`: **`gh ... -R ahmetabdullahgultekin/rolling-cat`**.
- Conventional commits. End every commit message with the required
  `Co-Authored-By` trailer.
- **Browser-verify every live change** (renders, EN/TR toggle works, no console
  errors) before considering it done.
- See `ROADMAP.md` for the phased plan and `TODO.md` for the prioritized backlog.

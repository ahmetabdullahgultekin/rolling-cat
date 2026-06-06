# RollingCat Website

The public marketing/portfolio site for **RollingCat Software** —
the solo software brand of Ahmet Abdullah Gültekin.

Live: **https://rollingcatsoftware.com**

## What it is

A single, hand-written `index.html` (~110 KB) with all CSS and JavaScript
inline. **No framework, no bundler, no build step** — the simplicity is the
product statement. Supporting files:

| File | Purpose |
|------|---------|
| `index.html` | The entire site (inline CSS + JS) |
| `.htaccess` | Security headers (incl. CSP), caching, gzip |
| `sitemap.xml` | URL + image + hreflang sitemap |
| `robots.txt` | Crawl directives |
| `og-image.png` | 1200×630 social card |
| `humans.txt` | Authorship credits |
| `security.txt` + `.well-known/security.txt` | RFC 9116 security contact |
| `ROADMAP.md`, `TODO.md` | Planning docs (excluded from deploy) |

## Features

- **Bilingual (EN/TR)** via an inline `data-en` / `data-tr` toggle, persisted
  to `localStorage`, with `navigator.language` first-visit detection and a
  per-language `<title>` swap. Strings are kept at EN/TR parity.
- **SEO**: canonical + hreflang (x-default/en/tr on one URL), OG + Twitter
  cards, four JSON-LD blocks (Person, Organization, WebSite, ProfilePage),
  `robots.txt`, `sitemap.xml`.
- **Accessibility**: skip link, keyboard-navigable nav with `aria-expanded`
  mobile menu and a language-aware `aria-label` on the toggle, decorative
  emoji marked `aria-hidden`, `:focus-visible` rings, WCAG-AA text contrast,
  and a **no-JS / reduced-motion fallback** — scroll-reveal content stays
  fully visible when JavaScript is disabled (the hidden state is gated on an
  `html.js` class set before paint).
- **Performance**: only the font weights actually used (400/500/600/700) are
  requested with `display=swap`.
- **Privacy**: fonts are served from **Bunny Fonts** (`fonts.bunny.net`), an
  EU-hosted, cookieless, GDPR/KVKK-compliant drop-in for Google Fonts — no
  visitor IP is transferred to Google. No analytics, no third-party JS.

## Deployment

> [!IMPORTANT]
> **Deploy from a host that can reach Hostinger.** The GitHub-hosted Actions
> runner frequently **cannot** open the SSH/rsync connection to the Hostinger
> box (`46.202.158.52:65002`) — runs hang or fail at the rsync step. The
> reliable path is the **manual `./deploy.sh`** from a developer/ops host that
> has the SSH key and network reach (e.g. the project server). Treat the
> Actions workflow as a convenience that may not land.

### Manual deploy (reliable)

```bash
./deploy.sh
```

`deploy.sh` rsyncs the repo to
`~/domains/rollingcatsoftware.com/public_html/` over SSH port 65002, with
`--delete`, **excluding** `.git`, `.github`, `deploy.sh`, `.claude`, `docs/`,
`CLAUDE.md`, `README.md`, `ROADMAP.md`, and `TODO.md` (planning/review docs
never ship to the live host).

### Automatic deploy (best-effort)

`.github/workflows/deploy.yml` runs on push to `master` and uses
`burnett01/rsync-deployments` with the same excludes plus `.github`.
Requires the `HOSTINGER_SSH_KEY` secret. **May not reach Hostinger** — see the
note above; fall back to `./deploy.sh`.

### After every deploy

Browser-verify the live site: the change renders, the **EN/TR toggle works**,
and there are no console errors. The site is low-risk static, but the live
page is the brand's front door — confirm it visually.

## Branch / PR conventions

- Default branch: **`master`**. Branch protection requires 1 review
  (admin bypass allowed for the solo owner).
- Always pass the repo flag to `gh`:
  `gh ... -R ahmetabdullahgultekin/rolling-cat`.
- Content changes that touch the live page can be merged + deployed once
  browser-verified.

## Planning

- `TODO.md` — prioritized backlog (P0–P3).
- `ROADMAP.md` — long-range vision, phases, and the professionalization plan.

# ROADMAP — rollingcat-website

## Vision

A fast, bilingual (EN/TR), zero-build one-page site that is the public face of
**RollingCat Software** — the solo agency/brand of Ahmet Abdullah Gültekin.
It must (1) accurately showcase shipped, self-hosted work, (2) read as
credible engineering proof to prospective collaborators/clients, and (3) stay
dead-simple to operate: a single hand-written `index.html`, deployed by rsync
on push to `master`. No framework, no bundler, no runtime dependency — the
simplicity is the product statement.

Design principles:
- **Truth over polish.** Every project card, status badge, link, and infra
  claim must match reality. A stale "Live demo 404" costs more credibility
  than a missing feature.
- **Single source, single file.** Keep the no-build constraint. New capability
  is added as inline HTML/CSS/JS, not a toolchain.
- **Bilingual parity.** Every user-facing string ships EN + TR via the
  `data-en`/`data-tr` toggle. Currently balanced 106/106 — keep it that way.
- **Reversible deploys.** Push-to-master auto-deploys; `deploy.sh` is the manual
  fallback. Branch protection (1 review, admin bypass) gates `master`.

---

## Current state (verified 2026-06-04, HEAD)

**Structure** — `index.html` (~104 KB, fully inline CSS+JS). Sections:
`#hero` → `#services` (4 cards) → `#work` (9 project cards) →
`#infrastructure` (infra grid) → `#about` → `#tech` (15-item stack) →
`#updates` (timeline) → `#contact` (mailto + GitHub) → footer.

**SEO** — strong: canonical + hreflang (x-default/en/tr, single-URL bilingual
per Google guidance), OG + Twitter cards, 4 JSON-LD blocks (Person,
Organization, WebSite, ProfilePage), `robots.txt`, `sitemap.xml` (with
image + hreflang), security headers + caching + gzip in `.htaccess`.

**i18n** — EN/TR toggle is complete and balanced (106/106), persisted to
`localStorage`, with `navigator.language` first-visit detection and a
title swap per language.

**Deploy** — GitHub Actions (`burnett01/rsync-deployments`) on push to
`master`, plus identical manual `deploy.sh`. Hostinger over SSH port 65002.

**Pending (P0):** branch `fix/site-audit-2026-06-01` (`868c0a3`) sits 1 commit
ahead of `origin/master` and is pushed but **unmerged + undeployed**. It fixes
the dead `app.fivucsas.com` "Live demo" link, fixes the wrong Fahrieren source
link, adds the amispoof card, marks Sarnic private, de-versions infra cards,
and polishes TR diacritics. `gh pr list` shows 0 open PRs. Local `master`
checkout is stale (7 behind origin) but the merge happens on origin.

**Known content debt:** amispoof "19 analyzers" needs verification against the
`spoof-detector` repo (memory says 12); the Updates timeline stops at April
2026 (~2 months stale); `sitemap.xml lastmod` and JSON-LD `dateModified`
frozen at 2026-04-22; hero "8 Projects" now undercounts the 9 rendered cards.

---

## Next up (immediate)

1. **Ship the audit branch** (P0) — merge `fix/site-audit-2026-06-01` → `master`,
   confirm the Actions deploy is green, verify the live link fixes + amispoof card.
2. **Correct the amispoof analyzer count** against the real repo.
3. **Add a May/June 2026 timeline entry** so the site isn't visibly stale.

---

## Phases

### Phase 1 — Content accuracy & freshness  *(highest leverage)*
Goal: nothing on the live site is wrong or stale.
- Merge + deploy the audit branch (P0).
- Verify amispoof analyzer count; reconcile hero stat-strip numbers (projects/
  in-production) with the actual cards.
- Refresh the Updates timeline (rolling, ≤1-month-old newest entry).
- Wire `lastmod` / `dateModified` to real change dates (release checklist or
  pre-commit hook so they never drift again).
Exit: a fresh visitor sees only true, current claims; SEO date signals are live.

### Phase 2 — Case studies & depth  *(turn portfolio into proof)*
Goal: each flagship project tells a problem→approach→result story with metrics.
- Per-project detail content (FIVUCSAS, amispoof, Mizan first) — still inline,
  still no-build (e.g. expandable card or a hash-routed detail panel).
- Optional lightweight blog / engineering log seeded from the Updates timeline.
Exit: ≥1 case study and ≥1 deeper write-up exist, linked from cards and the
sitemap.

### Phase 3 — Accessibility & performance
Goal: Lighthouse a11y + perf ≥ 95 on mobile, usable keyboard-only and no-JS.
- a11y: `lang-toggle` / mobile-menu ARIA state, decorative-emoji `aria-hidden`,
  `.reveal` no-JS / reduced-motion fallback, focus-visible + contrast audit.
- perf: trim/self-host Google Fonts with `font-display: swap`, confirm OG image
  dimensions, ensure any raster carries explicit width/height.
- Validate all 4 JSON-LD blocks in Rich Results; confirm org-name casing.
Exit: green Lighthouse, clean axe run, valid structured data.

### Phase 4 — Lead generation & analytics  *(growth)*
Goal: measure traffic and capture inbound without adding a backend.
- Privacy-respecting analytics (Plausible/Umami — fits the self-hosted story;
  update `.htaccess`/CSP accordingly).
- Lead capture beyond `mailto:` via a static-form provider (Formspree/Web3Forms).
- `humans.txt` / `security.txt` to match the rest of the web estate.
Exit: page-views visible in a dashboard; a real inquiry arrives through an
on-page form.

> Phases 2 and 4 introduce design/product choices (case-study format, form
> provider, analytics vendor) — recommend and get sign-off before building,
> per the reversible-changes preference. Phase 1 is pre-authorized execution.

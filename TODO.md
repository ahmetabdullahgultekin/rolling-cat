# TODO — rollingcat-website

Single static `index.html` marketing/portfolio site for RollingCat Software
(rollingcatsoftware.com). No build step. Deployed to Hostinger via GitHub
Actions (push to `master` → rsync) and/or manual `deploy.sh`.

Status snapshot (verified 2026-06-04 at HEAD):
- Working branch `fix/site-audit-2026-06-01` = `origin/master` (d0b900b) + 1 commit `868c0a3`. Pushed, NOT merged, NOT deployed.
- `gh pr list -R ahmetabdullahgultekin/rolling-cat --state open` → **0 open PRs** (audit branch has no PR yet).
- EN/TR `data-en`/`data-tr` perfectly balanced (106/106).
- All external links resolve to real targets; audit branch already repaired the known dead links.
- Local `master` checkout is STALE (0a909a4, 7 commits behind `origin/master`); irrelevant to the merge since it happens on origin, but don't deploy from the local `master` working copy.

---

## P0 — do first (pre-approved: "merge & deploy")

- [ ] **Merge `fix/site-audit-2026-06-01` → `master` and redeploy.**
  - Branch: `fix/site-audit-2026-06-01` (commit `868c0a3`, base = `origin/master` d0b900b).
  - Repo: `ahmetabdullahgultekin/rolling-cat` (always pass `-R`).
  - What it ships (diff `master..fix/site-audit-2026-06-01`, index.html, +57/-17):
    - Fixes dead/wrong links: FIVUCSAS "Live demo" `app.fivucsas.com → demo.fivucsas.com`; Fahrieren source `trader-comm-platform → fahrieren`.
    - Adds the **amispoof** project card (live demo + source + "npm coming soon" muted pill).
    - Converts Sarnic source link → "Private repo" muted (no public repo).
    - Info-hygiene: de-versions infra cards (Hetzner CX43→Cloud, Traefik v3.6→Traefik, PostgreSQL 17→PostgreSQL, Redis 7→Redis), WireGuard copy reworded.
    - TR diacritics polish (İşler, Çok platform, web arayüzü, etc.).
  - **Why P0:** user already authorized; the live site currently has a dead "Live demo" link (`app.fivucsas.com`) and a wrong Fahrieren source link, and is missing the amispoof project.
  - **Method:** open a PR (branch protection needs 1 review; admin bypass allowed) OR fast-forward merge to `master`. Push to `master` auto-triggers `.github/workflows/deploy.yml` (rsync to Hostinger). `deploy.sh` is the manual fallback.
  - **DONE when:** `master` (origin) contains `868c0a3`; GitHub Actions "Deploy to Hostinger" run is green; `curl -s https://rollingcatsoftware.com/ | grep -c demo.fivucsas.com` returns 1 and `grep -c app.fivucsas.com` returns 0; the amispoof card is visible on the live site.
  - **Note:** do NOT run the deploy from this analysis session — the user/operator merges.

---

## P1 — content accuracy & freshness (next session)

- [ ] **Verify the amispoof "19 analyzers" claim before it stays live.**
  - Path: index.html amispoof card (`feature-pill` "19 analyzers" + desc "19 analyzers").
  - Why: project memory records the browser port shipped **12 analyzers + 3 gates** (`project_amispoof_browser_port`). 19 may over-count or may be current — source of truth is the `spoof-detector` repo.
  - DONE when: the number matches the analyzer count in `github.com/Rollingcat-Software/spoof-detector` HEAD, or the pill is reworded to a defensible figure.

- [ ] **Refresh the "Updates" timeline — it stops at April 2026.**
  - Path: index.html `#updates` `.timeline` (6 items, newest = April 2026).
  - Why: heavy May 2026 work (identifier-first login, passkey/approve-login/NFC, amispoof browser port + deploy, SSO launcher design) is invisible; site reads ~2 months stale on a 2026-06-04 visit.
  - DONE when: at least one May/June 2026 entry is added (EN+TR), newest item ≤ 1 month old.

- [ ] **Bump `sitemap.xml` `lastmod` and the `ProfilePage` `dateModified` when content changes.**
  - Paths: `sitemap.xml` (`<lastmod>2026-04-22</lastmod>`), index.html JSON-LD ProfilePage (`"dateModified": "2026-04-22"`).
  - Why: both are frozen at 2026-04-22 while the site is actively edited; stale lastmod weakens crawl signals.
  - DONE when: both reflect the latest real content-change date (and a release checklist / git hook keeps them in sync).

- [ ] **Audit stat-strip numbers against the actual project list.**
  - Path: index.html hero `.strip` ("8 Projects / 6 In production / 15+ Technologies / 100% Self-hosted").
  - Why: the Work grid now shows 9 cards (FIVUCSAS, amispoof, Sarnic, Mizan, Fahrieren, Muhabbet, Share-Agent, geleceginadanasi, TrainVoc); "8 Projects" undercounts after the amispoof add. Production count: 7 cards carry a `status production` badge, not 6.
  - DONE when: hero numbers equal a deliberate, verifiable count of the cards actually rendered.

- [ ] **Confirm `og-image.png` declared dimensions (1200×630) match the real file.**
  - Path: `og-image.png` (32 KB), `og:image:width/height` meta = 1200×630.
  - Why: mismatched OG dimensions degrade link-preview rendering; file weight is fine (32 KB).
  - DONE when: actual PNG dimensions are confirmed 1200×630, or the meta is corrected.

---

## P2 — accessibility, perf, SEO depth

- [ ] **Accessibility pass (a11y).**
  - Paths: nav `lang-toggle` button, mobile menu button, all `.reveal` content, emoji icons used as `project-icon`/`service-icon`/`about-card-icon`.
  - Checks: `lang-toggle` should expose state (`aria-pressed` or descriptive `aria-label` per current language, not a static "Toggle language"); mobile menu `aria-expanded` toggling; decorative emoji wrapped with `aria-hidden="true"` (infra dots already do this); `.reveal` content must remain readable if IntersectionObserver/JS never fires (no-JS / `prefers-reduced-motion` fallback so opacity isn't stuck at 0); verify focus-visible styles and color contrast on `--ink-mute` (#6b6b80) text.
  - DONE when: keyboard-only nav works end-to-end, an axe/Lighthouse a11y run has no serious violations, and content is visible with JS disabled.

- [ ] **Performance: self-host or `font-display`-optimize Google Fonts; add width/height to any raster.**
  - Path: index.html `<head>` Google Fonts `<link>` (Inter + JetBrains Mono + Space Grotesk, 3 families with many weights).
  - Why: three font families with 6–9 weights each is the heaviest network cost on an otherwise single-file static page; `preconnect` is present but the request is render-blocking.
  - DONE when: unused weights trimmed and/or fonts self-hosted with `font-display: swap`; Lighthouse perf ≥ 95 on mobile.

- [ ] **Validate JSON-LD and confirm `sameAs` / org-casing consistency.**
  - Paths: 4 JSON-LD blocks (Person, Organization, WebSite, ProfilePage); links mix `github.com/Rollingcat-Software` (FIVUCSAS, spoof-detector) and `github.com/ahmetabdullahgultekin` (personal repos).
  - DONE when: all 4 blocks pass Google Rich Results / schema.org validator with no errors, and org-name casing ("Rollingcat-Software" vs "RollingCat Software") is intentional and consistent.

- [ ] **Mobile responsiveness spot-check on the new amispoof card + 9-card grid.**
  - Path: index.html `.projects-section` grid, infra grid, stat strip.
  - DONE when: 320px–1440px widths render without overflow/clipping; the muted "npm (coming soon)" pill and badges wrap cleanly.

---

## P3 — growth opportunities (deliberate, not urgent)

- [ ] **Case studies / project deep-dives.** Add a per-project detail (problem → approach → result, metrics) for FIVUCSAS / amispoof / Mizan instead of a single card line. Why: converts a portfolio into proof-of-work for leads. DONE when ≥1 case-study page exists and links from its card.
- [ ] **Lead capture beyond `mailto:`.** Contact section is `mailto:` + GitHub only. Consider a static-form provider (Formspree/Web3Forms — no backend needed). DONE when a submittable form posts to an endpoint and the user receives a test message. (Recommend, don't build, until approved — design choice.)
- [ ] **Privacy-respecting analytics.** No analytics today (CSP/headers in `.htaccess` are clean). Consider Plausible/Umami (self-hostable, fits the "self-hosted" story). DONE when page-views are visible in a dashboard and `.htaccess`/CSP allows the script. (Design choice — recommend first.)
- [ ] **Blog / engineering log.** The "Updates" timeline is the seed; a `/blog` of longer write-ups would feed SEO + the case-study story. DONE when ≥1 post is published and indexed in `sitemap.xml`.
- [ ] **Add `humans.txt` / `security.txt`.** Matches the rest of the user's web properties (fivucsas.com has them). DONE when both are served and reachable.

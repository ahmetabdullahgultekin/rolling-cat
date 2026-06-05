# TODO — rollingcat-website

Single static `index.html` marketing/portfolio site for RollingCat Software
(rollingcatsoftware.com). No build step. Deploy = manual `./deploy.sh` (rsync
to Hostinger). The GitHub Actions workflow is best-effort — the runner often
can't reach the Hostinger box, so treat `./deploy.sh` as the reliable path.

Status snapshot (updated 2026-06-05):
- P0 audit (PR #9) merged + deployed (demo URL, npm pill, infra hygiene, TR).
- P1 content (PR #10) merged + deployed + browser-verified: amispoof 23
  analyzers, May/June 2026 timeline, hero stat-strip 9/7, sitemap + JSON-LD
  dates → 2026-06-05.
- P2/P3 a11y + perf + growth pass shipped on branch `dev/2026-06-05`
  (see "Done 2026-06-05" below).
- EN/TR `data-en`/`data-tr` parity maintained (113/113).

---

## Done 2026-06-05 (P2 + P3 — a11y / perf / growth)

- [x] **Accessibility pass.** `html.js` gate so scroll-reveal content is fully
  visible with JS disabled (no-JS fallback verified); reduced-motion shows all
  content immediately; `aria-expanded` + `aria-controls` on the mobile menu
  (Escape closes it); language-aware `aria-label` on the toggle; `aria-hidden`
  on 56 decorative emoji/SVG icons; `:focus-visible` rings added; `--ink-mute`
  bumped `#6b6b80 → #8888a0` for WCAG-AA contrast.
- [x] **Performance: fonts trimmed.** Google Fonts request reduced to the
  weights actually used (Inter/JetBrains/Space Grotesk @ 400/500/600/700),
  dropping unused Inter 300/800/900. `display=swap` retained.
- [x] **JSON-LD validated.** All 4 blocks (Person, Organization, WebSite,
  ProfilePage) parse as valid JSON; casing intentional.
- [x] **og-image dimension check.** `og-image.png` confirmed **1200×630** —
  matches the declared `og:image:width/height`. No change needed.
- [x] **`humans.txt` + `security.txt`.** Added, plus `/.well-known/security.txt`
  (RFC 9116) and an `.htaccess` content-type rule; `<link rel="author">` added.
- [x] **Lead-capture improvement.** Pre-filled `mailto:` subject + body
  template; a "Copy email" button (clipboard API + execCommand fallback) with
  EN/TR label and copied-state feedback.
- [x] **Analytics readiness (CSP).** Added a Content-Security-Policy to
  `.htaccess` (was absent) structured so a self-hosted Plausible/Umami origin
  can be appended in one edit. Live analytics deferred to a design decision —
  see ROADMAP Phase 5.
- [x] **Responsive spot-check.** No horizontal overflow at 320 / 768 / 1440px;
  no console errors. Copy button, lang toggle, mobile menu all verified.

---

## Backlog (deliberate — recommend before building)

- [ ] **Case studies / project deep-dives (ROADMAP Phase 2).** Per-project
  problem → approach → result with metrics for FIVUCSAS / amispoof / Mizan.
  Decide page-vs-panel format first (lean: per-project static pages for SEO).
- [ ] **Blog / engineering log (ROADMAP Phase 3).** Seed from the Updates
  timeline; `/blog/` static pages + index + RSS/JSON feed + `Article` JSON-LD.
- [ ] **Privacy-respecting analytics (ROADMAP Phase 5).** Stand up a cookieless
  self-hosted Plausible/Umami; append its origin to the CSP; add the snippet.
- [ ] **Lead capture beyond `mailto:` (ROADMAP Phase 5).** Static-form provider
  (Formspree/Web3Forms) + honeypot; route to a tracked inbox/CRM.
- [ ] **Self-host trimmed fonts as woff2 (ROADMAP Phase 4).** Removes the
  render-blocking cross-origin font request; pair with `preload`.
- [ ] **Release checklist / pre-commit hook.** Auto-bump `lastmod` +
  `dateModified`, run a link-check + EN/TR-parity check on every content PR.
- [ ] **Lighthouse + axe in CI (ROADMAP Phase 4/6).** Track a perf/a11y budget.

---

## Standing rules

- Always `gh ... -R ahmetabdullahgultekin/rolling-cat`.
- Deploy via `./deploy.sh` (reliable) — Actions runner reachability is flaky.
- Browser-verify every live change (render + EN/TR toggle + no console errors).
- Keep `data-en` / `data-tr` counts balanced on every content PR.
- `ROADMAP.md` / `TODO.md` never ship to the live host (excluded from deploy).

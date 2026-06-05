# ROADMAP — rollingcat-website

The long-range plan for **rollingcatsoftware.com** — the public face of
RollingCat Software, the solo software brand of Ahmet Abdullah Gültekin.

---

## Vision

A fast, bilingual (EN/TR), zero-build site that is the most credible possible
proof-of-work for a solo full-stack engineer who designs, builds, deploys, and
operates real software end-to-end. It must:

1. **Showcase shipped, self-hosted work accurately** — every claim verifiable.
2. **Convert visitors into conversations** — read as engineering proof to
   prospective collaborators and clients, then make it easy to reach out.
3. **Stay dead-simple to operate** — a single hand-written `index.html`,
   deployed by rsync. No framework, no bundler, no runtime dependency. The
   simplicity is itself the statement.

### Design principles

- **Truth over polish.** Every project card, status badge, link, and infra
  claim must match reality. A stale "Live demo 404" costs more credibility
  than a missing feature.
- **Single source, single file.** Keep the no-build constraint as long as it
  serves us. New capability is added as inline HTML/CSS/JS, not a toolchain —
  until the maintenance cost of a single file outweighs the simplicity (see
  the optional build-step discussion in Phase 6).
- **Bilingual parity.** Every user-facing string ships EN + TR via the
  `data-en` / `data-tr` toggle. Keep the pairs balanced.
- **Accessible by default.** No-JS users and keyboard/AT users get a fully
  usable page. Reveal animations are progressive enhancement, never a gate.
- **Reversible deploys.** Manual `./deploy.sh` is the reliable path (the
  GitHub Actions runner often can't reach Hostinger). Branch protection
  (1 review, admin bypass) gates `master`. Risky changes ship behind a clear
  diff and are easy to revert.

---

## Current state (2026-06-05, HEAD)

**Structure** — `index.html` (~110 KB, fully inline CSS+JS). Sections:
`#hero` → `#services` (4 cards) → `#work` (9 project cards) →
`#infrastructure` (infra grid) → `#about` → `#tech` (15-item stack) →
`#updates` (timeline) → `#contact` → footer.

**Content** — amispoof analyzer count reconciled to **23** (verified against
the `spoof-detector` repo); Updates timeline refreshed through **June 2026**;
hero stat-strip reconciled to **9 projects / 7 in production**; `sitemap.xml`
`lastmod` and JSON-LD `dateModified` wired to the real change date.

**SEO** — canonical + hreflang (x-default/en/tr, single-URL bilingual), OG +
Twitter cards, 4 valid JSON-LD blocks (Person, Organization, WebSite,
ProfilePage), `robots.txt`, `sitemap.xml`, security headers + CSP + caching +
gzip in `.htaccess`.

**i18n** — EN/TR toggle complete and balanced, persisted to `localStorage`,
with first-visit language detection and a per-language title swap.

**a11y / perf** — skip link; `aria-expanded` mobile menu; language-aware
`aria-label` on the toggle; decorative emoji `aria-hidden`; `:focus-visible`
rings; WCAG-AA body contrast (`--ink-mute` bumped to `#8888a0`); **no-JS /
reduced-motion reveal fallback**; Google Fonts trimmed to the 4 weights
actually used with `display=swap`. og-image confirmed 1200×630.

**Growth scaffolding** — `humans.txt`, `security.txt` (+ `/.well-known/`),
a pre-filled `mailto:` subject/body and a copy-email button, and an
analytics-ready CSP.

**Deploy** — manual `./deploy.sh` (rsync over SSH 65002) is the reliable path;
the Actions workflow is best-effort (runner reachability is flaky). Both
exclude `ROADMAP.md` / `TODO.md`.

---

## Phases

### Phase 1 — Content accuracy & freshness  *(highest leverage — ongoing)*
**Goal:** nothing on the live site is ever wrong or stale.
- Keep the Updates timeline rolling (newest entry ≤ 1 month old).
- Keep `lastmod` / `dateModified` wired to real change dates — ideally via a
  release checklist or a pre-commit hook so they never drift again.
- Re-verify project counts, statuses, and analyzer/feature numbers against the
  source repos whenever a flagship project changes.
**Exit (rolling):** a fresh visitor only ever sees true, current claims.

### Phase 2 — Case studies & proof-of-work  *(turn a portfolio into evidence)*
**Goal:** each flagship project tells a problem → approach → result story with
real metrics, not a one-line card.
- **Case-study format (design decision — recommend before building):** the
  no-build-friendly option is an in-page, hash-routed detail panel
  (`#case/fivucsas`) or an `<details>`-style expandable card, so it stays a
  single file. The alternative is per-project static pages
  (`/case/fivucsas.html`) — better for SEO and shareable links, at the cost of
  more files. **Lean toward per-project pages** for SEO + linkability; revisit
  if the file count gets unwieldy.
- **First three:** FIVUCSAS (biometric auth platform — multi-factor, identity
  linking, self-hosted ML), amispoof (browser anti-spoof port — 23 analyzers,
  zero frames uploaded), Mizan (hybrid BM25 + embedding search over Arabic
  text). Each: the problem, the constraints, the architecture in one diagram,
  the measurable result, and a "what I'd do next" honesty note.
- Link each case study from its card and add it to `sitemap.xml`.
**Exit:** ≥3 case studies live, linked from cards, indexed in the sitemap.

### Phase 3 — Blog / engineering log  *(SEO + narrative compounding)*
**Goal:** a stream of short, technical write-ups that feed SEO and give leads
a reason to return.
- Seed from the Updates timeline (each timeline entry is a candidate post).
- **Format decision:** start with hand-written static post pages under
  `/blog/` + an index page, each in `sitemap.xml` with `Article` JSON-LD and
  OG tags. Keep the no-build constraint until post volume justifies a
  generator (see Phase 6).
- Topics with built-in audience: "Running face anti-spoof entirely in the
  browser", "Identifier-first login without locking users out", "Self-hosting
  a biometric platform on one Hetzner box", "Why I keep my portfolio a single
  HTML file".
- Add an RSS/Atom feed and a JSON feed for syndication.
**Exit:** ≥3 posts published + indexed; feed validates; blog index links from
nav.

### Phase 4 — Accessibility & performance excellence
**Goal:** Lighthouse a11y **+ perf ≥ 95** on mobile; clean axe run; usable
keyboard-only and no-JS. *(Foundations shipped in the 2026-06-05 pass.)*
- Run and track Lighthouse (mobile) + axe-core in a checklist; fix any
  remaining serious violations.
- **Fonts:** evaluate self-hosting the trimmed weights as `woff2` (removes the
  render-blocking cross-origin request entirely; pairs with `font-display:
  swap` and a `preload`). Weigh against the simplicity of the CDN link.
- Confirm every raster carries explicit `width`/`height`; lazy-load any
  below-the-fold imagery added later.
- Re-validate all 4 JSON-LD blocks in Google Rich Results after content edits;
  keep org-name casing intentional and consistent.
- Add automated link-checking (dead-link sweep) to the release checklist.
**Exit:** green Lighthouse a11y + perf on mobile, clean axe, valid structured
data, zero dead links.

### Phase 5 — Lead generation & CRM hooks  *(growth)*
**Goal:** measure interest and capture inbound without standing up a backend.
- **Analytics (design decision — recommend before enabling):** privacy-first,
  cookieless, self-hostable to fit the "self-hosted" story — Plausible or
  Umami at e.g. `analytics.rollingcatsoftware.com`. The CSP in `.htaccess` is
  already structured so the script/connect origins can be appended in one
  edit. No consent banner needed if it's genuinely cookieless.
- **Lead capture beyond `mailto:`:** a static-form provider (Formspree /
  Web3Forms / Basin — no backend) posting from an on-page contact form, with
  spam protection (honeypot + provider-side). The pre-filled `mailto:` and
  copy-email button shipped as the zero-dependency baseline.
- **CRM hooks:** route form submissions into a lightweight pipeline — provider
  webhook → a simple inbox/Notion/Airtable/Google Sheet, or an email
  auto-tagged for follow-up. Track inquiry → reply → outcome so the funnel is
  visible. Add UTM parameters to outbound links the brand controls so traffic
  sources are attributable.
**Exit:** page-views visible in a privacy-respecting dashboard; a real inquiry
arrives through an on-page form and lands in a tracked pipeline.

### Phase 6 — Tooling & sustainability  *(only if the single file strains)*
**Goal:** keep authoring fast as content grows, without betraying the
no-runtime-dependency promise.
- **Optional lightweight build step:** if blog + case studies make one file
  unwieldy, introduce a *build-time-only* generator (e.g. a tiny static-site
  generator or a hand-rolled HTML-partials + i18n-injection script) that still
  emits plain static HTML to deploy. The runtime stays dependency-free; only
  authoring gains structure. Decide explicitly — don't drift into a toolchain.
- **i18n source of truth:** as strings grow, consider extracting EN/TR pairs
  into a JSON catalog injected at build time, keeping parity mechanically
  enforced rather than by hand.
- **Lightweight CMS (optional):** a git-backed / flat-file CMS (e.g.
  Decap/Netlify CMS pointed at the repo) so non-code edits don't require
  touching HTML. Only if edit frequency justifies it.
- **CI quality gates:** HTML validation, link-check, Lighthouse-CI budget, and
  EN/TR-parity check on every PR.
**Exit:** content can grow 10× without the source becoming unmaintainable, and
the live output is still plain static files.

> **Decision discipline.** Phases 2, 3, 5, and 6 introduce product/tooling
> choices (case-study format, blog engine, analytics + form vendors, whether
> to add a build step). Per the reversible-changes preference: recommend and
> get sign-off before building each. Phase 1 and the shipped a11y/perf/growth
> scaffolding are pre-authorized execution.

---

## Future / Professionalization

Beyond the phased roadmap, these moves turn the site from a personal portfolio
into the credible front door of a one-person software studio:

- **Brand system.** A small, documented design-token set (already partly
  present as CSS custom properties) and a consistent logo/OG treatment across
  rollingcatsoftware.com and the FIVUCSAS / amispoof properties, so the estate
  reads as one studio.
- **A services → engagement path.** Make "what I can be hired for" explicit:
  per-service outcomes, a rough engagement model (consulting / build /
  self-hosted-handover), and an honest availability signal. Pair each service
  with a matching case study (Phase 2) as proof.
- **Trust & legitimacy surface.** Add the things clients check before they
  email a solo dev: a clear contact channel (shipped), `security.txt` /
  `humans.txt` (shipped), a privacy note for any analytics/forms, and — when
  real — testimonials or named project references with permission.
- **Distribution.** RSS/JSON feeds (Phase 3), correct OG/Twitter cards
  (shipped), structured data (shipped), and a habit of cross-posting blog
  write-ups to dev communities to pull qualified traffic back to case studies.
- **Operational maturity.** A release checklist (content freshness, lastmod,
  link-check, Lighthouse, EN/TR parity, browser-verify) and eventually CI
  gates (Phase 6) so quality is enforced, not remembered. A documented
  deploy/rollback runbook (the GH-runner-can't-reach-Hostinger reality is
  captured in the README).
- **Measurable funnel.** Once analytics + forms land (Phase 5): track the path
  from visit → case-study read → inquiry → engagement, and let the data steer
  which projects to feature and which write-ups to invest in.
- **Internationalization beyond EN/TR.** The `data-en`/`data-tr` mechanism
  generalizes; if a market warrants it, the i18n catalog (Phase 6) makes a
  third language a content task, not a rewrite.

The north star: a prospective client lands, immediately believes "this person
ships and operates real, secure software end-to-end", reads one case study
that proves it, and reaches out through a frictionless, tracked channel — all
served from a site that's still small enough for one person to own completely.

---

## Operating notes

- **Deploy reality.** `./deploy.sh` from a host with SSH reach to Hostinger is
  the reliable path; the GitHub Actions runner often can't open the rsync
  connection. Browser-verify every live change.
- **Excludes.** `ROADMAP.md` and `TODO.md` never ship to the live host (both
  `deploy.sh` and the workflow exclude them).
- **gh flag.** Always `gh ... -R ahmetabdullahgultekin/rolling-cat`.
- **Parity.** Keep `data-en` / `data-tr` counts balanced on every content PR.

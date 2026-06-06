# Tech-Stack & Design Review — rollingcat-website (2026-06-05)

Reviewer: senior tech-stack & design review pass on `master` HEAD.
Scope: `index.html` (~2150 lines, all CSS + JS inline), `.htaccess`, `deploy.sh`, `.github/workflows/deploy.yml`, and supporting text files (`sitemap.xml`, `robots.txt`, `humans.txt`, `security.txt`).

This is a single-file static marketing/portfolio site with no build step by design. The review is deliberately proportionate — "enterprise-grade" tooling would be overkill here.

---

## Tech-Stack Inventory

| Component | What's used | How it's loaded | Verdict |
|---|---|---|---|
| **HTML** | Hand-written semantic HTML5 | Inline in `index.html` | KEEP |
| **CSS** | Vanilla CSS with custom properties (design system) | Inline `<style>` block | KEEP |
| **JavaScript** | Vanilla ES2020+ (IntersectionObserver, clipboard API, rAF, localStorage) | Inline `<script>` block | KEEP |
| **Fonts** | Inter 400/500/600/700, JetBrains Mono 400/500/600, Space Grotesk 400/500/600/700 | Google Fonts CDN (`fonts.googleapis.com` + `fonts.gstatic.com`) | CONSIDER (see §3) |
| **Icons / SVG** | Inline SVG throughout | No external CDN | KEEP |
| **Analytics** | None — CSP pre-wired for future Plausible/Umami | — | KEEP (deferred correctly) |
| **Build system** | None | N/A | KEEP |
| **Deploy** | rsync via `deploy.sh` to Hostinger (manual, reliable) + GitHub Actions (best-effort) | SSH port 65002 | KEEP |
| **Web server** | Apache (Hostinger shared hosting) | Hostinger | KEEP |
| **Security headers** | `.htaccess`: HSTS, X-Frame-Options DENY, nosniff, Referrer-Policy, Permissions-Policy, CSP, X-XSS-Protection | Apache `mod_headers` | KEEP (1 tweak — see §2) |

**No third-party JavaScript libraries are loaded from any CDN.** The only external runtime dependency is Google Fonts. There is no jQuery, Bootstrap, React, or any other versioned library with a CVE surface.

---

## Verdict: Single-file, no-build approach

**KEEP. The zero-dependency, zero-build approach is the correct choice for this site.**

Rationale:
- The site is a single-page marketing/portfolio. There is no routing, no state management, no component churn, and no data fetching. A bundler/framework would add complexity with no functional return.
- The JS is exemplary vanilla code — IntersectionObserver scroll-reveal with `unobserve`, rAF-throttled cursor spotlight, `localStorage`/clipboard wrapped in try/catch, `prefers-reduced-motion` honoured, Escape-to-close menu, no-JS progressive enhancement. It needs no library help.
- The CSS uses a well-organized custom-properties design system that is easier to maintain inline than through a preprocessor for a single file.
- Deploy is trivially a single rsync. Zero build pipeline = zero pipeline failure surface.

The only valid trigger to add a build step would be: adding a second page (to share CSS/JS), frequent project-card churn (to template from data), or self-hosting fonts (to run `fontsource` or `fonttools`). None of those conditions apply today.

---

## Genuine Issues Found

### 1. X-XSS-Protection header — REMOVE or NEUTRALISE (low effort)

**File:** `.htaccess`, line 8:
```
Header always set X-XSS-Protection "1; mode=block"
```

`X-XSS-Protection` is **deprecated** and was removed from all modern browsers (Chrome 78+, Firefox never supported it). The MDN recommendation as of 2025 is to set it to `"0"` to explicitly disable the IE/old-Edge XSS auditor, which has known bypass CVEs, rather than leaving it as `"1; mode=block"`.

The existing CSP (`script-src 'self' 'unsafe-inline'`) is the correct modern control. The header is harmless to browsers that ignore it, but security scanners flag `"1; mode=block"` on modern stacks as a misconfiguration.

**Fix:** Change to `Header always set X-XSS-Protection "0"` to disarm the legacy auditor and silence scanner noise.
Source: [MDN X-XSS-Protection](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-XSS-Protection), [OWASP Secure Headers Project](https://owasp.org/www-project-secure-headers/)

---

### 2. Google Fonts via Google CDN — GDPR / privacy note (low urgency for TR audience, medium for EU)

**File:** `index.html`, lines 48–53:
```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500;600&family=Space+Grotesk:wght@400;500;600;700&display=swap" rel="stylesheet">
```

Two issues:

**a) GDPR: IP address transfer to Google.** A 2022 Munich court ruling (Az. 3 O 17493/20) established that loading fonts from Google's CDN transfers visitor IP addresses to Google (US), which counts as personal data processing under GDPR without explicit consent. The site's audience is Turkish (KVKK) + potentially EU. While enforcement risk for a personal portfolio is low, it is a real legal gap if the site targets EU visitors professionally.

**b) SRI not possible.** Google Fonts cannot be protected with Subresource Integrity because the API returns User-Agent-personalized CSS, making the hash non-deterministic. This means a Google Fonts CDN compromise would be undetectable by the browser. This is a supply-chain risk inherent to the CDN model, not a misconfiguration — but it is worth documenting.

**Fix options (in order of effort):**
1. **Self-host the fonts (ROADMAP Phase 4, already tracked).** Download woff2 subsets via `google-webfonts-helper`, serve from the same origin, add `<link rel="preload">`. Eliminates GDPR exposure, enables SRI, removes render-blocking cross-origin request. The TODO.md already tracks this ("Self-host trimmed fonts as woff2").
2. **Drop-in privacy CDN** (`fonts.bunny.net` or `staticdelivr.com`) — same API, EU-hosted, GDPR-compliant, one-line URL swap, no self-hosting required. Fastest path to GDPR compliance.
3. Accept status quo for now. The site has no analytics, no tracking, and Google Fonts is the *only* external data transfer. For a personal Turkish portfolio site this is low-risk in practice.

This is **not a blocker today** — it is the same trade-off that most small personal sites make. Flag it and track it against the self-hosting roadmap item.

Sources: [Usercentrics GDPR/Google Fonts](https://usercentrics.com/knowledge-hub/google-fonts-gdpr-compliant/), [PrivacyChecker 2026](https://privacychecker.pro/blog/google-fonts-gdpr-compliant), [google/fonts#473 — why SRI is unsupported](https://github.com/google/fonts/issues/473)

---

### 3. No font-display fallback metrics / CLS risk (minor)

`display=swap` on Google Fonts is correct, but there are no `size-adjust`, `ascent-override`, or `descent-override` descriptors to match fallback font metrics. On a slow connection the layout will shift when Inter loads and replaces the system-sans fallback. This is a polish item, not a correctness bug — it only matters on slow connections and only until fonts load.

**Fix:** If/when fonts are self-hosted, add `@font-face` override descriptors (easily generated via `fontaine` or `fonttools`). Not worth doing while Google CDN is in use.

---

### 4. deploy.sh excludes ROADMAP/TODO — confirm docs/ is also excluded (VERIFY)

The deploy script currently excludes `.git`, `deploy.sh`, `ROADMAP.md`, and `TODO.md`. The new `docs/` directory (including this review file) was not in the exclude list at the time of writing. Planning/review documents should not ship to the live host.

**Fix:** Add `--exclude='docs/'` to `deploy.sh` and to `.github/workflows/deploy.yml`.

---

## Non-issues (confirmed good — do not change)

| Item | Status |
|---|---|
| No third-party JS libraries | No versioned CDN JS → no CVE/EOL surface at all |
| CSP in `.htaccess` | Well-scoped: `'unsafe-inline'` documented + justified; fonts gated to `fonts.googleapis.com`/`fonts.gstatic.com`; `frame-ancestors 'none'` (stronger than X-Frame-Options) |
| HSTS | `max-age=31536000; includeSubDomains` — correct |
| Permissions-Policy | Camera/mic/geo all locked — appropriate for a portfolio site |
| Referrer-Policy | `strict-origin-when-cross-origin` — correct |
| SEO | Four JSON-LD nodes (Person/Organization/WebSite/ProfilePage), OG/Twitter, canonical, hreflang x-default+en+tr, robots.txt, sitemap.xml — complete |
| Accessibility | Skip link (surfaced on focus), aria-expanded/aria-controls on mobile menu, aria-hidden on decorative elements, focus-visible rings, prefers-reduced-motion, no-JS fallback — thorough |
| i18n data-attr parity | 113 `data-en` / 113 `data-tr` — perfectly balanced |
| Inline SVG favicon | Data-URI SVG favicon — zero extra request, renders at any resolution |
| Apple touch icon | Points to og-image.png — acceptable |
| Font weights | Only weights actually used are requested (400/500/600/700) — trim and correct |
| Caching | `.htaccess` ExpiresActive rules for CSS/JS/font/image — correct |
| Gzip | `mod_deflate` for HTML/CSS/JS/JSON — correct |
| security.txt | RFC 9116 compliant, `.well-known/` symlink present |
| humans.txt | Present, `<link rel="author">` wired |
| robots.txt | Present, allows all |
| og-image.png | 1200×630, declared dimensions match |

---

## Prioritised Recommendations

| Priority | Item | Effort | Impact |
|---|---|---|---|
| P2 | Change `X-XSS-Protection "1; mode=block"` → `"0"` in `.htaccess` | 1 line | Silences scanner noise, removes legacy auditor CVE risk |
| P2 | Add `--exclude='docs/'` to `deploy.sh` + `deploy.yml` | 2 lines | Prevents review/planning docs shipping to live host |
| P3 | Swap Google Fonts CDN → Bunny Fonts or self-host (already in ROADMAP Phase 4) | 1 URL or moderate effort | GDPR/privacy + SRI + removes render-blocking cross-origin request |
| P4 | Font fallback metrics (`size-adjust` etc.) — do when self-hosting fonts | Deferred | Reduces CLS on slow connections |

Items P3–P4 are roadmap items, not defects. P2 items are one-liners.

---

## Overall Assessment

**A− (proportionate to a single-file static site).** The stack is deliberately minimal and that is the right call. The only genuine technical debt is one deprecated header and one missing deploy exclude. The Google Fonts CDN usage is a known, documented trade-off, not an oversight, and self-hosting is already on the roadmap. There is nothing here that warrants a framework, bundler, or architectural change.

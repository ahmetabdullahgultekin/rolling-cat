# Code Quality Review — rollingcat-website (2026-06-05)

Reviewer: senior code-quality pass on `master` HEAD (`8ca53ec`).
Scope: a single static `index.html` (~2130 lines) with inline CSS + JS, plus `.htaccess`,
`robots.txt`, `sitemap.xml`, `security.txt`, `humans.txt`. No build step, no framework
(by design — the no-build constraint is intentional). This is a portfolio/marketing site, so
the review is deliberately proportionate: a single-file static site has limited "architecture".
Two small safe fixes were applied on branch `quality/2026-06-05` and verified in a headless
browser load.

## Scorecard (1 = poor, 5 = excellent)

| Dimension | Score | One-line justification |
|---|---|---|
| Structure / maintainability (single file) | 4 | One file by design, but cleanly sectioned with banner comments (`═══ NAV ═══`, etc.); CSS custom-properties design system makes it readable and editable. The only real cost is that all 2130 lines live together. |
| Dead / duplicate markup | 4 | Very little dead markup; the nav/footer logo SVG is duplicated inline (expected for a no-component site) and the GitHub icon path repeats 3×. No orphaned sections found. |
| JS quality | 5 | Genuinely good vanilla JS: IntersectionObserver reveal with `unobserve`, passive scroll listener, rAF-throttled cursor spotlight, clipboard with `execCommand` fallback, `localStorage` wrapped in try/catch, Escape-to-close menu, `navigator.language` detection. No libraries, no leaks. |
| a11y correctness (in code) | 4 | Skip link, `aria-label`/`aria-controls`/`aria-expanded` on the menu button, `aria-hidden` on decorative SVGs, `:focus-visible` rings, `prefers-reduced-motion` honored, no-JS reveal fallback, WCAG-AA-bumped `--ink-mute`. One gap: the skip link didn't reveal on focus (**fixed**). |
| SEO correctness (in code) | 5 | Four JSON-LD nodes (Person/Organization/WebSite/ProfilePage), full OG/Twitter, canonical, hreflang x-default+en+tr for the same-URL bilingual model, robots/googlebot, semantic `<main>/<nav>/<footer>/<section>/<article>`, clean heading order (1×h1, 7×h2, 21×h3). |
| `.htaccess` / CSP hygiene | 5 | Strong header set (HSTS, X-Frame-Options DENY, nosniff, Referrer-Policy, Permissions-Policy locking camera/mic/geo) and a tight CSP that correctly scopes `'unsafe-inline'` (unavoidable for inline CSS/JS) + Google Fonts only, with a documented note on how to extend it for future analytics. |
| i18n data-attr consistency | 5 | Exactly 113 `data-en` / 113 `data-tr` — perfectly balanced; toggle persists to `localStorage`, updates `<html lang>`, `document.title`, and the toggle's own `aria-label` in the readable language. |

**Overall: A− (4.6/5).** A polished, accessible, SEO-complete, security-hardened single-file
static site. The issues found are a stale project count and one a11y polish item — both fixed.

---

## Findings

### P0 / P1 — none

No security, correctness, or accessibility blocker. CSP and security headers are sound; the
bilingual toggle and SEO schema are complete and consistent.

### P2 — Medium

**P2-1 Project count out of sync (stale heading). — FIXED**
`index.html:1404-1405` (pre-fix) — the Work section heading read "Eight projects / Sekiz
proje", but there are **9** `.project` cards (`index.html:1416-1677`) and the hero stats strip
correctly says "9 Projects" (`index.html:1333`). Off-by-one content drift, likely from adding a
9th project without updating the heading. *Fix applied:* "Nine projects / Dokuz proje".
Verified in a headless load: heading text, 9 rendered cards, and the "9" strip now agree.

### P3 — Low / polish

**P3-1 Skip link not revealed on focus. — FIXED**
`index.html:1245-1253` (`.sr-only`) — the `#main` skip link
(`index.html:1262-1264`) is permanently `clip`-hidden, so a sighted keyboard user who tabs to
it never sees it (WCAG 2.4.1 "bypass blocks" is technically met by the link existing, but the
UX is poor). *Fix applied:* added a `.sr-only:focus` rule that surfaces the link top-left with
a visible chip on focus. Verified live: on `.focus()` it becomes `position:fixed`, `z-index:200`,
padded/visible.

**P3-2 Repeated inline SVG / logo markup (acceptable for no-build).**
The brand-mark SVG appears in nav (`:1271`) and footer (`:1992`), and the GitHub icon path
repeats at `:1326`, `:1977`, `:2004`. With no build/component system this is the expected
trade-off; not worth a JS-templating refactor for a static page. Documented only — if the site
ever grows a second page, extract a tiny build step (see roadmap).

**P3-3 Single-file size.**
~2130 lines in one file. Fine today and arguably a feature (zero-dependency, trivially
deployable). If content keeps growing, a minimal build (e.g. CSS in a separate cached file,
data-driven project cards from a JSON array) would cut duplication. Roadmap item, not a defect.

---

## Honest strengths

- **The vanilla JS is exemplary** — every listener is cleaned up or throttled, every browser API
  has a fallback, and storage/clipboard access is defensively wrapped. This is how to write
  no-framework interactivity.
- **Accessibility was clearly thought about**, not bolted on: reduced-motion, focus-visible,
  no-JS progressive enhancement, ARIA on the only interactive widgets, and an AA-corrected mute
  color with an inline comment explaining the contrast bump.
- **SEO is complete and correct** for a same-URL bilingual site — the hreflang x-default+en+tr
  choice matches Google's guidance, and four JSON-LD nodes cover Person/Org/Site/Page.
- **Security headers + CSP are production-grade** and, notably, *documented* — the CSP comment
  explains why `'unsafe-inline'` is present and how to extend it later.
- **i18n is airtight** — perfectly balanced data attributes and a toggle that updates lang,
  title, and its own assistive-tech label.

## Fixes applied on `quality/2026-06-05` (safe only, headless-verified)

- **P2-1** Work heading "Eight/Sekiz" → "Nine/Dokuz" projects (matches 9 cards + hero strip).
- **P3-1** Added `.sr-only:focus` so the skip link is visible to keyboard users.
- i18n attrs remain balanced (113/113); page loads clean, title + lang toggle + 9-card render
  all confirmed in a Playwright load.

## Routed to ROADMAP (only if the site grows)

A minimal build step to (a) extract inline CSS into a separately-cached file, (b) render the
project cards from a data array to kill the repeated card markup, and (c) deduplicate the
inline SVG icons — **only worth doing if a second page or frequent content churn appears.**
Today the single-file, zero-build approach is the right call.

---
description: "Use when deploying the MkDocs site, running scripts/release.sh, or troubleshooting a deployment. Covers the GitHub Action in .github/workflows/deploy-docs.yml (Cloudflare Pages + GitHub Pages from one build), the required CLOUDFLARE_API_TOKEN / CLOUDFLARE_ACCOUNT_ID secrets, the PAGES_PROJECT name, docs/_headers and the frame-ancestors rule, site_url / SITE_URL, mkdocs gh-deploy, the release.sh script (full flow and --deploy flag), the strict build check, and how to preview before going live. Also use when asked to publish or ship documentation changes."
applyTo: "scripts/release.sh, .github/workflows/**, docs/_headers"
---

# Deploying the documentation site

## Two hosts, one build

The site is published to **two** places from the same `site/` directory:

| Host | URL | Role |
| --- | --- | --- |
| Cloudflare Pages | <https://autoboat-docs.pages.dev/> | **Primary.** Canonical host. |
| GitHub Pages (`gh-pages`) | <https://autoboat-vt.github.io/documentation/> | Mirror, kept for old links. |

<https://autoboat.aoe.vt.edu/documentation/> is a **loader page** that frames the
Cloudflare copy in an iframe. It is not a deployment of this repo — it lives in
the *website* repo (`website/public/documentation/index.html`) and ships with
that site's S4 deploy. See "The VT entry point" below.

## The GitHub Action (normal path)

`.github/workflows/deploy-docs.yml` runs on every push to `main` (and via
`workflow_dispatch`). It is the **only** deployment mechanism anyone needs:

1. Installs `requirements.txt` on Python 3.12 (pinned, because `.python-version`
   holds a pyenv env *name*, not a version).
2. `mkdocs build --strict --clean` — fails on broken links, missing images, or
   nav errors.
3. Creates the Cloudflare Pages project if it does not exist, then
   `wrangler pages deploy site`.
4. `mkdocs gh-deploy --force` — mirrors the same `site/` to `gh-pages`.

Both hosts are updated in one run, so they cannot drift apart.

### Required secrets

Both are set as **organization** secrets on `autoboat-vt` with `ALL` repository
visibility, not as repo secrets — so they are available here without being
duplicated per repo:

| Secret | Where to get it |
| --- | --- |
| `CLOUDFLARE_API_TOKEN` | Cloudflare dashboard -> API Tokens -> custom token with **Account : Cloudflare Pages : Edit** |
| `CLOUDFLARE_ACCOUNT_ID` | Cloudflare dashboard URL, or `npx wrangler whoami` |

WARNING: `gh secret list -R autoboat-vt/documentation` reports **"no secrets
found"** even though both exist, because it lists repo-level secrets only. Check
the org instead: `gh secret list --org autoboat-vt`.

WARNING: If the secrets are missing the Cloudflare steps **fail** rather than
skip. A silent skip would leave the VT entry point framing a stale deployment,
which looks like the docs are out of date rather than like CI is misconfigured.

NOTE: A local `wrangler login` cannot be used here. That is an OAuth token tied
to a browser session, and GitHub Actions is unattended, so CI needs an API token
instead. They are different credentials.

### One-time Cloudflare project setup

The workflow creates the project on first run, so there is nothing to click. The
project name lives in the workflow's `PAGES_PROJECT` env var (`autoboat-docs`).

WARNING: `website/public/documentation/index.html` hard-codes
`https://autoboat-docs.pages.dev/` as the iframe `src`. Renaming `PAGES_PROJECT`
means editing that file in the *website* repo in the same change, or the VT page
frames a 404. `website/src/test/lib/docsPlaceholder.test.ts` cross-checks the two
and fails if they disagree.

## The VT entry point

`https://autoboat.aoe.vt.edu/documentation/` needs three things from this repo:

1. **Not forbidding framing.** `docs/_headers` sets
   `Content-Security-Policy: frame-ancestors 'self' https://autoboat.aoe.vt.edu
   https://www.autoboat.aoe.vt.edu`. Cloudflare Pages reads `_headers` from the
   **root of the uploaded directory**, which is why the file lives in `docs/` and
   not the repo root — MkDocs copies `docs/` into `site/`.
   NOTE: Framing works because nothing forbids it, not because of this header.
   With no CSP and no `X-Frame-Options`, framing is allowed by default; the
   header narrows it to the two site origins. So a *missing* header is not what
   breaks the page — a restrictive one is.
   WARNING: Do **not** add `X-Frame-Options` there. `SAMEORIGIN`/`DENY` would
   break the whole arrangement, since the embedding page is a different origin.
   WARNING: `_headers` must contain exactly ONE `/*` block. It originally had
   two, and Pages applied only the second, silently dropping the CSP. Verify with
   `curl -sSI https://autoboat-docs.pages.dev/ | grep -i content-security`.
2. **A stable canonical.** `mkdocs.yml` sets `site_url` so the framed copy and
   the `pages.dev` copy agree on one canonical URL.
3. **Nothing else.** The deep-link stubs are the *website* repo's job — see below.

### Deep links need a stub on the S3 side

A page at `/documentation/getting_started/setting_up_dev_environment/` only works
because the **website** repo writes a loader stub there. VT S4 is plain Amazon
S3, which has no directory-index fallback, so a deep path is a 404 unless a real
`index.html` exists at that key.

**WARNING: Adding a docs page is a two-repo change.** The page will work at
`https://autoboat-docs.pages.dev/<path>/` immediately, but the equivalent
`autoboat.aoe.vt.edu/documentation/<path>/` URL will **404** until the website
repo's path manifest is refreshed:

```sh
# in the website repo
bun run sync-docs-paths      # regenerates src/lib/docsPaths.json
```

There is no automation for this — the website's CI never checks out this repo, so
the list is committed rather than derived. If you add or rename a page, update it
in the same batch of work. (The website's `docsPlaceholder` test will catch the
drift, but only on a machine that has both repos checked out.)

## `site_url` and canonicals

`site_url` in `mkdocs.yml` is `!ENV [SITE_URL, "https://autoboat-docs.pages.dev/"]`.
The Action sets `SITE_URL` from `PAGES_PROJECT`, so the canonical cannot disagree
with the hostname actually deployed.

WARNING: `site_url` used to be `https://autoboat-vt.github.io/` — missing the
`/documentation/` path the site is served from — so **every page declared a
canonical URL that 404s**, and the generated sitemap listed those same dead URLs.
Verified before the fix: `/documentation/getting_started/installing_docker/`
claimed a canonical of `https://autoboat-vt.github.io/getting_started/installing_docker/`.
If you change the hostname, change it here and nowhere else.

## Preview before deploying

Always preview changes locally first; there is no staging environment, but
pushing to `main` deploys automatically. `mkdocs serve` hot-reloads on save:

```sh
pip install -r requirements.txt   # one-time
mkdocs serve                      # → http://127.0.0.1:8000
```

`mkdocs build --strict` before committing catches exactly what CI will reject.

## The `scripts/release.sh` script (legacy manual path)

Still works, and still deploys **only to GitHub Pages** — it does not touch
Cloudflare. Prefer pushing to `main` and letting the Action handle both hosts.

```sh
./scripts/release.sh           # full flow: build → commit → push → deploy
./scripts/release.sh --deploy  # rebuild + deploy only (skip git on main)
```

The script uses `set -euo pipefail`, so any failed step aborts before the next
runs. It `cd`s to the repo root itself, so it works from anywhere.

### Full flow (`./scripts/release.sh`)

1. **Strict build** — `mkdocs build --strict --clean`. Broken link, missing
   image, or nav warning aborts here.
2. **Stage** — `git add -A`.
3. **Commit** — prompts for a message (required). If nothing is staged, asks
   whether to deploy the current state anyway.
4. **Push** — `git push` to `origin`. This also triggers the Action, which is the
   better path — it updates Cloudflare too.
5. **Confirm** — asks `[y/N]` before `mkdocs gh-deploy`.
6. **Deploy** — `mkdocs gh-deploy` pushes `site/` to `gh-pages`.

### Deploy-only (`./scripts/release.sh --deploy`)

Skips the git steps on `main` and goes straight to `mkdocs gh-deploy`. Use it when
the commit is already pushed and only the `gh-pages` branch needs refreshing.
Still runs the strict build first.

## When to deploy

- **Deploy** when changes are ready to go live. On `main`, a push is a deploy.
- **Don't deploy** for in-progress work — use `mkdocs serve` instead.
- **Don't deploy** if `mkdocs build --strict` emits warnings. Fix them first.

## Troubleshooting


- **Script aborts at the strict build step** — there's a broken link, missing image, or nav entry pointing to a nonexistent file. Fix the issue in `docs/` or `mkdocs.yml` and re-run.
- **Page returns 404 after deploy** — the page isn't in `mkdocs.yml` `nav:`, or the path in `nav:` doesn't match the file path under `docs/`.
- **Image broken after deploy** — the relative path in the Markdown is wrong. Count the `../`s against the page's depth.
- **`mkdocs gh-deploy` fails with permission error** — check that you have push access to `autoboat-vt/documentation` and that your git credentials are set up.
- **Old content still showing** — GitHub Pages caches aggressively. Wait 1-2 minutes, or hard-refresh the page.
- **`site/` directory has stale files** — `mkdocs gh-deploy` rebuilds from scratch, so this shouldn't happen. If it does, `rm -rf site/` and rebuild.

---
description: "Use when deploying the MkDocs site to GitHub Pages, running scripts/release.sh, or troubleshooting a deployment. Covers mkdocs gh-deploy, the release.sh script (full flow and --deploy flag), the strict build check, the deploy confirmation prompt, the gh-pages branch flow, when to rebuild the site/ directory, and how to preview before going live. Also use when asked to publish or ship documentation changes."
applyTo: "scripts/release.sh"
---

# Deploying the documentation site

## Preview before deploying

Always preview changes locally before deploying — there is no staging environment. `mkdocs serve` hot-reloads on save:

```sh
mkdocs serve
# → open http://127.0.0.1:8000
```

Only deploy once the preview looks good.

## How deployment works

The site is deployed to GitHub Pages via the `gh-pages` branch. The flow is:

1. `mkdocs gh-deploy` builds the site into `site/`, then pushes the contents of `site/` to the `gh-pages` branch as a new commit.
2. GitHub Pages serves the `gh-pages` branch at <https://autoboat-vt.github.io/documentation/>.
3. The deployment is live within a minute or two of the push.

The `site/` directory in the `main` branch is **generated output** — never edit it directly. It's regenerated from `docs/` on every deploy.

## The `scripts/release.sh` script

The release workflow lives in `scripts/release.sh` (run from the repo root). It replaces the old `Makefile` and adds two safety checks the Makefile didn't have: a strict build check and a deploy confirmation prompt.

```sh
./scripts/release.sh           # full flow: build → commit → push → deploy
./scripts/release.sh --deploy  # rebuild + deploy only (skip git on main)
```

The script uses `set -euo pipefail`, so any failed step aborts the whole release before the next step runs. It also `cd`s to the repo root itself, so it works regardless of where you invoke it from.

### Full flow (`./scripts/release.sh`)

1. **Strict build** — runs `mkdocs build --strict --clean`. Any broken link, missing image, or nav warning becomes a hard error and the script aborts here.
2. **Stage** — `git add -A`.
3. **Commit** — prompts for a commit message in the terminal (required). If nothing is staged, it asks whether to deploy the current state anyway.
4. **Push** — `git push` to `origin`.
5. **Confirm** — asks `[y/N]` before `mkdocs gh-deploy`, since there is no staging environment.
6. **Deploy** — `mkdocs gh-deploy` builds and pushes `site/` to `gh-pages`.

### Deploy-only (`./scripts/release.sh --deploy`)

Skips the git steps on `main` (commit/push) and goes straight to `mkdocs gh-deploy`. Use this when your changes are already committed and pushed and you just want to rebuild and ship the site. Still runs the strict build check first.

## When to deploy

- **Deploy** when changes are ready to go live (a new page is finished, a doc update is confirmed accurate, etc.).
- **Don't deploy** for in-progress work — use `mkdocs serve` instead.
- **Don't deploy** if `mkdocs build --strict` emits warnings (broken links, missing images). The script will refuse to proceed, which is the desired behavior — fix the warnings first.

## Troubleshooting

- **Script aborts at the strict build step** — there's a broken link, missing image, or nav entry pointing to a nonexistent file. Fix the issue in `docs/` or `mkdocs.yml` and re-run.
- **Page returns 404 after deploy** — the page isn't in `mkdocs.yml` `nav:`, or the path in `nav:` doesn't match the file path under `docs/`.
- **Image broken after deploy** — the relative path in the Markdown is wrong. Count the `../`s against the page's depth.
- **`mkdocs gh-deploy` fails with permission error** — check that you have push access to `autoboat-vt/documentation` and that your git credentials are set up.
- **Old content still showing** — GitHub Pages caches aggressively. Wait 1-2 minutes, or hard-refresh the page.
- **`site/` directory has stale files** — `mkdocs gh-deploy` rebuilds from scratch, so this shouldn't happen. If it does, `rm -rf site/` and rebuild.

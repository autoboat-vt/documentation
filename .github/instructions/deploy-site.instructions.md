---
description: "Use when deploying the MkDocs site to GitHub Pages, running make release, or troubleshooting a deployment. Covers mkdocs gh-deploy, the Makefile targets (add/commit/push/deploy/release), the gh-pages branch flow, when to rebuild the site/ directory, and how to preview before going live. Also use when asked to publish or ship documentation changes."
applyTo: "Makefile"
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

## Makefile targets

The `Makefile` at the repo root provides convenience targets:

| Target              | What it does                                          |
| ------------------- | ----------------------------------------------------- |
| `make add`          | `git add -A`                                          |
| `make commit`       | Prompts for a commit message, then `git commit`       |
| `make push`         | `git push`                                            |
| `make deploy`       | `mkdocs gh-deploy` (builds + pushes to `gh-pages`)    |
| `make release`      | `add` → `commit` → `push` → `deploy` (full ship)      |
| `make` (default)    | Same as `make release` (`release` is the default goal)|

### `make release` is the full workflow

```sh
make release
```

This runs `add` → `commit` (interactive prompt for message) → `push` → `deploy`. Use this when you want to ship a set of changes end-to-end. It will prompt for a commit message in the terminal.

### `make deploy` only deploys

If your changes are already committed and pushed, you can skip straight to deploy:

```sh
make deploy
```

This runs `mkdocs gh-deploy` without touching git on `main`.

## When to deploy

- **Deploy** when changes are ready to go live (a new page is finished, a doc update is confirmed accurate, etc.).
- **Don't deploy** for in-progress work — use `mkdocs serve` instead.
- **Don't deploy** if `mkdocs build` emits warnings (broken links, missing images). Fix those first.

## Troubleshooting

- **Page returns 404 after deploy** — the page isn't in `mkdocs.yml` `nav:`, or the path in `nav:` doesn't match the file path under `docs/`.
- **Image broken after deploy** — the relative path in the Markdown is wrong. Count the `../`s against the page's depth.
- **`mkdocs gh-deploy` fails with permission error** — check that you have push access to `autoboat-vt/documentation` and that your git credentials are set up.
- **Old content still showing** — GitHub Pages caches aggressively. Wait 1-2 minutes, or hard-refresh the page.
- **`site/` directory has stale files** — `mkdocs gh-deploy` rebuilds from scratch, so this shouldn't happen. If it does, `rm -rf site/` and rebuild.

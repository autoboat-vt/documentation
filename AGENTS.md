# AutoBoat Documentation — Agent Guidelines

This repo is the source for the AutoBoat team's MkDocs Material site. It is
published to two hosts from one build:

- **Cloudflare Pages** (primary): <https://autoboat-docs.pages.dev/>
- **GitHub Pages** (mirror): <https://autoboat-vt.github.io/documentation/>

It is also framed at <https://autoboat.aoe.vt.edu/documentation/>, a loader page
in the *website* repo. Every change here eventually becomes a page on those sites.

## What this repo is

- A **documentation-only** repo. No application code runs here — the only "build" is `mkdocs build` / `mkdocs serve`.
- Source lives in `docs/` as Markdown (`.md`) files. The compiled site goes into `site/` (generated, gitignored on deploy).
- Site config is `mkdocs.yml` at the repo root. The `nav:` block there is the single source of truth for the sidebar.
- Dependencies: `mkdocs` + `mkdocs-material` (see `requirements.txt`). Install with `pip install -r requirements.txt` or `brew install mkdocs-material` on macOS.
- This repo documents three sibling repos: [`autoboat-vt/autoboat_vt`](https://github.com/autoboat-vt/autoboat_vt), [`autoboat-vt/telemetry_server`](https://github.com/autoboat-vt/telemetry_server), and [`autoboat-vt/website`](https://github.com/autoboat-vt/website). When asked to "update the docs based on repo X", fetch the current state of that repo before editing.

## Build, preview, deploy

```sh
pip install -r requirements.txt   # one-time
mkdocs serve                      # live preview at http://127.0.0.1:8000
mkdocs build --strict             # build into site/; what CI runs

# Normal deploy: push to main. The GitHub Action does the rest.
./scripts/release.sh              # legacy manual path (GitHub Pages only)
```

Prefer `mkdocs serve` while editing — it hot-reloads. **A push to `main` is a
deploy**: `.github/workflows/deploy-docs.yml` builds strictly and publishes to
both Cloudflare Pages and GitHub Pages. Run `mkdocs build --strict` locally first
so CI does not reject a broken link you could have caught.

`./scripts/release.sh` still exists but deploys **only** to GitHub Pages. Prefer
pushing to `main` and letting the Action update both hosts.

WARNING: **Adding a page is a two-repo change.** The page goes live on
`pages.dev` as soon as this repo's Action runs, but the equivalent
`https://autoboat.aoe.vt.edu/documentation/<path>/` URL 404s until the *website*
repo regenerates its deep-link manifest (`bun run sync-docs-paths`). VT S4 is
plain S3 with no directory-index fallback, so each path needs a real stub file.
See `deploy-site.instructions.md`.


## Editing conventions

- **Every `.md` page must start with YAML frontmatter** with `title` and `description`, e.g.:
  ```markdown
  ---
  title: Add Documentation
  description: Add a new documentation page.
  ---
  ```
- **Filenames use `snake_case`** with underscores (e.g. `adding_documentation.md`, `new_member_info.md`).
- **Directory structure under `docs/` mirrors the nav hierarchy in `mkdocs.yml`.** When adding a page, create the `.md` file in the right folder AND add a nav entry — an unlisted page won't appear in the sidebar.
- **Image references use relative paths to `docs/assets/images/`**: `![alt](../assets/images/foo.png)`. Put new images there, never inline them.
- **MkDocs Material extensions are enabled** (see `mkdocs.yml` `markdown_extensions`): admonitions (`!!! note`, `!!! warning`), `pymdownx.superfences` (nested code blocks, Mermaid), `pymdownx.keys`, `pymdownx.critic`, `pymdownx.arithmatex` (MathJax). Prefer these over raw HTML where possible.
- **Heading levels start at `#` (H1) for the page title**, then `##`, `###`, etc. Don't skip levels. Match the existing nesting style in files like `docs/groundstation_telemetry/groundstation_overview.md`.
- **The `site/` directory is generated output — never edit it directly.** Edit `docs/` and rebuild.
- **Link to detailed docs instead of duplicating them.** If a sibling repo's README already explains something, link to it rather than copying the text here.

## When updating docs from sibling repos

1. Fetch the current state of the sibling repo (use `fetch_webpage` on its GitHub tree, or `github_text_search` for specific files) before editing docs.
2. Verify file paths, function/class names, and directory structure against the actual repo — don't trust memory or stale docs.
3. If you find a discrepancy between the docs and the repo, fix the **docs** to match the repo (the repo is the source of truth, not the docs).
4. After editing, run `mkdocs build` (or just check for errors) to confirm the Markdown is valid.

## Conventions that aren't enforced by linters

- There is no Markdown linter configured. Read an existing file in the same directory before writing a new one to match tone, frontmatter style, and heading depth.
- The `description` field in frontmatter shows up in search and nav previews — keep it to one sentence and make it descriptive.
- Code blocks should specify a language when possible (```sh, ```python, ```json) so syntax highlighting works if it's re-enabled.
- Use admonitions (`!!! note`, `!!! warning`) for callouts instead of bold "NOTE:" text in paragraphs.

## Don't

- Don't edit files under `site/` — they're regenerated.
- Don't add a `.md` file without also adding it to `mkdocs.yml` `nav:`.
- Don't use `applyTo: "**"` style broad-scoped instructions (this is a docs repo, keep edits targeted).
- Don't deploy (`mkdocs gh-deploy` / `make release`) unless explicitly asked — preview with `mkdocs serve` instead.

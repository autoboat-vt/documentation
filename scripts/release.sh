#!/usr/bin/env bash

# Release script for the AutoBoat documentation site.
#
# Builds the site with `mkdocs build --strict` (fails on broken links / missing
# images), prompts for a commit message, pushes to main, then deploys to GitHub
# Pages via `mkdocs gh-deploy`.
#
# Usage:
#   ./scripts/release.sh           # full flow: build → commit → push → deploy
#   ./scripts/release.sh --deploy  # skip git on main, just rebuild + deploy
#
# Run from the repo root. Requires pip dependencies from requirements.txt.

set -euo pipefail

# --- preflight -----------------------------------------------------------------

# Always run from the repo root, regardless of where the script was invoked.
# Resolve symlinks so `./scripts/release.sh` and `bash scripts/release.sh` both work.
script_path="${BASH_SOURCE[0]}"
while [ -h "$script_path" ]; do
    dir="$(cd -P "$(dirname "$script_path")" && pwd)"
    script_path="$(readlink "$script_path")"
    [[ $script_path != /* ]] && script_path="$dir/$script_path"
done
repo_root="$(cd -P "$(dirname "$script_path")/.." && pwd)"
cd "$repo_root"

# Check that mkdocs is installed.
if ! command -v mkdocs >/dev/null 2>&1; then
    echo "error: mkdocs not found. Install with 'pip install -r requirements.txt' or 'brew install mkdocs-material'." >&2
    exit 1
fi

# --- parse args ----------------------------------------------------------------

deploy_only=0
if [[ "${1:-}" == "--deploy" ]]; then
    deploy_only=1
elif [[ $# -gt 0 ]]; then
    echo "usage: $0 [--deploy]" >&2
    exit 2
fi

# --- build (strict) ------------------------------------------------------------

echo "==> Building site with --strict (warnings become errors)..."
# --strict turns broken-link and missing-image warnings into build failures,
# so we never deploy a site with broken navigation.
mkdocs build --strict --clean

# --- deploy-only path ----------------------------------------------------------

if [[ $deploy_only -eq 1 ]]; then
    echo "==> Deploying to GitHub Pages (--deploy mode, skipping git on main)..."
    mkdocs gh-deploy
    echo "==> Done. Live at https://autoboat-vt.github.io/documentation/ within 1-2 minutes."
    exit 0
fi

# --- full flow: commit → push → deploy -----------------------------------------

echo "==> Staging changes..."
git add -A

# Check if there's anything to commit. If not, ask whether to deploy anyway.
if git diff --cached --quiet; then
    echo "warning: nothing staged to commit."
    read -r -p "Deploy current state anyway? [y/N] " deploy_anyway
    if [[ ! "$deploy_anyway" =~ ^[Yy]$ ]]; then
        echo "==> Aborting."
        exit 0
    fi
else
    read -r -e -p "Commit message: " message
    if [ -z "$message" ]; then
        echo "error: commit message is required." >&2
        exit 1
    fi
    git commit -m "$message"
fi

echo "==> Pushing to origin..."
git push

echo "==> Deploying to GitHub Pages (this is irreversible)..."
# Confirm before gh-deploy since there's no staging environment.
read -r -p "Deploy to production (https://autoboat-vt.github.io/documentation/)? [y/N] " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "==> Aborted before deploy. Your changes are committed and pushed to main, but not live."
    echo "    To deploy later, run: ./scripts/release.sh --deploy"
    exit 0
fi

mkdocs gh-deploy

echo "==> Done. Live at https://autoboat-vt.github.io/documentation/ within 1-2 minutes."

---
description: "Use when editing mkdocs.yml, especially the nav: section. Covers how to add a new page to the navigation hierarchy, match the directory structure under docs/, keep section ordering, and avoid leaving pages unlisted. Also use when reorganizing the sidebar or adding a new section."
applyTo: "mkdocs.yml"
---

# Editing mkdocs.yml and the nav hierarchy

`mkdocs.yml` at the repo root is the single source of truth for the site's sidebar. **A page that isn't listed in `nav:` will still render if someone navigates to its URL, but it won't appear in the sidebar.** Always add new pages to `nav:`.

## Structure

The `nav:` block is a nested list. Each entry is either:

- A single page: `- Page Title: path/to/page.md` (path is relative to `docs/`)
- A section with children:
  ```yaml
  - Section Name:
      - Page 1: path/to/page1.md
      - Page 2: path/to/page2.md
  ```
- A commented-out page: `#   - Disabled Page: path/to/page.md` (use this to temporarily hide a page without deleting it)

## Adding a new page

1. Create the `.md` file under `docs/` in the appropriate subdirectory (e.g. `docs/groundstation_telemetry/my_new_page.md`).
2. Add a nav entry under the matching section in `mkdocs.yml`:
   ```yaml
   - Groundstation/Telemetry:
         - New Member Overview: groundstation_telemetry/new_member_info.md
         - Groundstation: groundstation_telemetry/groundstation_overview.md
         - Telemetry Server: groundstation_telemetry/telemetry_server_api_routes.md
         - My New Page: groundstation_telemetry/my_new_page.md   # <-- add here
   ```
3. The path is relative to `docs/`, so it does **not** include the `docs/` prefix.
4. The page title in the nav can differ from the `title:` in the page's frontmatter — the nav title is what shows in the sidebar, the frontmatter title is what shows at the top of the page. Convention is to keep them similar.

## Directory structure mirrors nav

The folder structure under `docs/` should match the nav hierarchy. If you're adding a page to the `Groundstation/Telemetry` nav section, put the file in `docs/groundstation_telemetry/`. This isn't enforced, but breaking it makes the repo hard to navigate.

## Indentation

`mkdocs.yml` uses 4-space indentation for nav entries under a section (see existing entries). Match the surrounding style — YAML is whitespace-sensitive.

## Commenting out a page

If a page isn't ready for publication but you want to keep it in the repo, comment it out with `#` at the start of the line, preserving indentation:

```yaml
- Examples:
      - Running the Simulation: examples/running_simulation.md
      #   - Running Individual Nodes for Testing: examples/running_individual_nodes.md
```

## After editing

Run `mkdocs serve` and verify the new page appears in the sidebar and links to the right file. If you see a "file not found" error in the terminal, the path in `nav:` doesn't match the actual file path under `docs/`.

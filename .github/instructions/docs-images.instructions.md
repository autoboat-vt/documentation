---
description: "Use when adding or referencing images and static assets in documentation. Covers where to put images (docs/assets/images/), the required relative-path reference syntax, SVG vs PNG conventions, and the alt-text requirement. Also use when adding JavaScript or CSS assets under docs/assets/."
applyTo: "docs/**/*.md"
---

# Adding images and static assets

## Where images go

All images live in `docs/assets/images/`. There are subdirectories for organization (e.g. `docs/assets/images/system_diagram_files/`), but most images go directly in `docs/assets/images/`.

- **PNG** for screenshots, photos, and raster graphics.
- **SVG** for diagrams, logos, and anything that should scale (the site logo and favicon are SVG).
- No JPEG, GIF, or WebP unless there's a specific reason (PNG is the default).

## Referencing images in Markdown

Use a relative path from the `.md` file to the image. Since most pages are one level deep under `docs/` (e.g. `docs/groundstation_telemetry/foo.md`), the path is usually `../assets/images/`:

```markdown
![descriptive alt text](../assets/images/my_screenshot.png)
```

For pages deeper in the tree (e.g. `docs/ros2_packages/autopilot_package/foo.md`), the path is `../../assets/images/`:

```markdown
![descriptive alt text](../../assets/images/my_screenshot.png)
```

### Alt text is required

The `![alt text]` portion is not optional — it's used by screen readers and shows when the image fails to load. Use a description of what the image shows, not the filename:

```markdown
# Good
![WSL USB GUI Releases Image](../assets/images/wsl_usb_gui_releases.png)

# Bad
![alt text](../assets/images/wsl_usb_gui_releases.png)
![image](../assets/images/foo.png)
```

(Some older pages use `![alt text](...)` as a placeholder — that's legacy, don't copy it. Write a real description.)

## Referencing the site logo

The site logo and favicon are configured in `mkdocs.yml`:

```yaml
theme:
    name: material
    logo: assets/images/logo.svg
    favicon: assets/images/logo.svg
```

These paths are relative to `docs/`, so the logo lives at `docs/assets/images/logo.svg`.

## JavaScript and CSS assets

Custom JS and CSS live in `docs/assets/javascript/` and `docs/assets/styles/` respectively, and are registered in `mkdocs.yml`:

```yaml
extra_javascript:
    - javascript/static_title.js
    - javascript/mathjax.js
    - https://unpkg.com/mathjax@3/es5/tex-mml-chtml.js

extra_css:
    - styles/extra.css
```

Paths are relative to `docs/`. Only add new JS/CSS if there's a real need — most styling should use MkDocs Material's built-in theme and Markdown extensions.

## After adding an image

Run `mkdocs serve` and confirm the image renders on the page. A broken image icon usually means the relative path is wrong — count the `../`s against the page's depth under `docs/`.

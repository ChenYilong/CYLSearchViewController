---
name: cyl-example-taglist
description: "Use when a demo or example needs a table-view-like grouped list (sections): show it as CollectionViewClassifyMenu's tag list instead, with sections, adaptive tag width, wrapping titles, 3-row fold with more/less, tap = cell tap, long-press subtitle bubble."
---

# Grouped example lists as tag lists

Full rule: [docs/instructions/example-demos.md](../../../docs/instructions/example-demos.md) (tag: `example-demos`).

## Steps

1. Find the grouped list (table view with sections, settings-style rows) in the example of the platform.
2. Replace it with the platform's tag list: each cell is a tag (main title and icon), each section has a header with a
   non-empty title. Default initialization first; adaptive tag width, so a row holds as many tags as possible.
3. Allow the tag title to wrap (ClassifyMenu's title wrapping API). Fold after 3 rows; the fold control shows `more` /
   `less` with its built-in icon (icon-and-title content).
4. A tag tap behaves like the cell tap. A long press shows the subtitle in a small floating bubble with an arrow, through the
   tag list's long-press API.
5. A missing capability is added to the core or bridge first, never worked around in the example (`cyl-fix-in-core`).
6. The tag list uses the Liquid Glass background through the core's one parameter (`backgroundStyle` `liquidGlass`), no custom fills.
7. Build and screenshot the page before reporting (`cyl-verify`).

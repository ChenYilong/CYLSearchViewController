---
name: cyl-search-field
description: "Adding or changing any search or text field in the core or an example, on any platform: use CYLSearchBarView with the navigation field preset, never a system search bar."
---

# One search field

Full rule: `docs/instructions/core.md`, "One search field, no system search bar"; examples: `docs/instructions/example-demos.md`, rule 8.

## Rules (owner, 2026-11-26)

1. Every search field is the core's `CYLSearchBarView` (the same name on every platform). Never a system search bar:
   iOS `UISearchBar` / `UISearchController` / `UISearchTextField`, Android `SearchView` / `SearchBar`, HarmonyOS `Search()`,
   Flutter `SearchBar` / `SearchAnchor` / `SearchDelegate` / `CupertinoSearchTextField`, React Native `TextInput` as a search box,
   the mini program's `<input type="search">` / `<search>`.
2. The look is the navigation field preset (Discover look): bordered capsule radius 18, soft shadow 0.06, no magnifier, 16 pt text,
   opaque white / black fill. iOS: `applyNavigationFieldStyle()`. Other platforms: the same preset in their core; bridges pass a
   `navigationFieldStyle` parameter. An example calls the preset, it never sets those values.
3. In a navigation bar use the platform's embed call (iOS `embedInNavigationBar(of:)`).
4. Find leftovers with the greps in the task-log entry "no system search bar on any platform".
5. Default search button: every field keeps the core's built-in search button (the icon style by default; `searchButtonStyle` icon or
   text, custom title or icon); never hide it in an example, never add a second one. Docs: core.md rule 5, example-demos.md rule 9.
6. Keyboard: the Search key, `focusesOnAppear`, `dismissesKeyboardOnOutsideTouch`, through CYLDeallocBlockExecutor events (core.md rule 6).
7. Before a git operation, read `docs/instructions/git.md` in full (skill `cyl-commit`).
8. Trailing group (owner, 2026-11-26): gaps beside a divider are even; items are spaced only by the container's spacing; a plain icon or text item hugs its content (36 dp touch by hit area, never by empty room); an item with a shape of its own keeps its size. Docs: core.md, "Trailing group layout".

# Folder Instructions

- Inherit the repository's `instructions.md` and `AGENTS.md`.
- Keep integration tests for the root example app and its local Pods here.
- Update the explicit Xcode test target references when moving test files.

## Search bar placement

- A search bar never covers the main view, that is, the view controller's
  view (`self.view`), or any other view, at any time and at every Dynamic
  Type size. Full rule: `instructions.md` and `AGENTS.md`, "Search bar
  placement".
- Add every new search bar (screen, state, Dynamic Type size) to
  `testSearchBarsCoverNoView`, which checks it with `CYLViewsCoveredByView`.

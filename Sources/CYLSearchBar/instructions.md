# Folder Instructions

- Inherit the repository's `instructions.md` and `AGENTS.md`.
- This folder is the whole iOS search core, CYLSearchBar (`docs/search-core-merge.md`, "Target design"): three
  files and four public classes, nothing else.
  - `CYLSearchBarView.swift`: `CYLSearchBarView` (one field, or several searches with `mode = .multiple`) and
    `CYLSearchBarItem`, with `CYLSearchBarViewDelegate` and the bar's enums; the item view and the multiple-search
    content are private helpers of this file.
  - `CYLSearchView.swift`: `CYLSearchView` (the search page: suggestions, the results of `CYLSearchViewDataSource`,
    the empty placeholders, and the only refresh API of the core), with `CYLSearchViewDelegate`.
  - `CYLSearchResources.swift`: `CYLSearchResources` (the bundle's images and strings), the
    `CYLSearchSuggestionCache` protocol and its policies; the default store is internal.
- Add a feature to the class it belongs to (a parameter or a mode) instead of a new public class. An API that
  duplicates another is kept once.
- The core depends only on CollectionViewClassifyMenu (tags) and CYLTableViewPlaceHolder (placeholders and
  pull-to-refresh). It never depends on another search library: CYLSearchBar is the only search kernel. Apps and the
  example reach CYLTableViewPlaceHolder's pull-to-refresh only through `CYLSearchView`'s refresh API.
- Keep this UIKit component independent of the example app. Expose integration points through public interfaces.
- The module stays `CYLSearchViewController`; the resource bundle `CYLSearchViewController.bundle` keeps all its
  files (the other platforms import its images and strings).
- New and translated code is Swift: follow `docs/swift-coding-standard.md`, keep the Objective-C names with
  `@objc(...)`, and document every `public` declaration with a three-line `/** */` block
  (`scripts/check-public-api-comments.sh`).

## Search bar placement

- A search bar never covers the main view, that is, the view controller's
  view (`self.view`), or any other view, at any time and at every Dynamic
  Type size. Full rule: `instructions.md` and `AGENTS.md`, "Search bar
  placement".
- `CYLSearchView` lays its bar out against the safe area, on an opaque page of its own, with the suggestions and
  results below it, so the bar never sits on top of a view.

## Task log before every task

Before any task, log it as `TODO` in the most suitable document in `docs/`
(else `docs/task-log.md`): context, the user's requirements, the user's prompt
(verbatim plus English translation) and a status line. Commit and push it,
then start; mark it `DONE (YYYY-MM-DD)` with the result when the task ends.
Full rule: `AGENTS.md`, "Task log before every task".

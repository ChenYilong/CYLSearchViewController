# Folder Instructions

- Inherit the repository's `instructions.md` and `AGENTS.md`.
- Keep integration tests for the root example app and its local Pods here.
- Update the explicit Xcode test target references when moving test files.
- Write tests in Swift (`docs/swift-migration.md`, step 4): one `XCTestCase` subclass of `CYLSearchExampleTestCase` per
  area, shared recorders and view helpers in `CYLSearchExampleTestSupport.swift`. The one Objective-C file,
  `CYLSearchCoreObjectiveCSmokeTests.m`, stays: it checks that Objective-C callers see the Swift core through its
  generated header.

## API fence

- `CYLSearchAPIFenceTests.swift` (public `import`, no `@testable`) and the "API fence" part of
  `CYLSearchCoreObjectiveCSmokeTests.m` name every public and `@objc` member of the search classes, their delegate
  protocols and enums. A refactor must keep both compiling unchanged: add a test line for a new public member, never
  edit one away (`docs/qmui-search-controller.md`, "Merge design", phase 0).

## Search bar placement

- A search bar never covers the main view, that is, the view controller's
  view (`self.view`), or any other view, at any time and at every Dynamic
  Type size. Full rule: `instructions.md` and `AGENTS.md`, "Search bar
  placement".
- Add every new search bar (screen, state, Dynamic Type size) to
  `testSearchBarsCoverNoView`, which checks it with `CYLViewsCoveredByView`.

## Task log before every task

Before any task, log it as `TODO` in the most suitable document in `docs/`
(else `docs/task-log.md`): context, the user's requirements, the user's prompt
(verbatim plus English translation) and a status line. Commit and push it,
then start; mark it `DONE (YYYY-MM-DD)` with the result when the task ends.
Full rule: `AGENTS.md`, "Task log before every task".

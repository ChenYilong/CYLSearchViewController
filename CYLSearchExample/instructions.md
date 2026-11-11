# Folder Instructions

- Follow the repository's `instructions.md` and `AGENTS.md`.
- Integrate the search component and the sibling placeholder library as local
  CocoaPods dependencies. Keep reproduction-specific code in the example.
- Example sources and the app Info.plist live in this directory. The Xcode
  project and Podfile remain at the repository root.
- Keep project file references and the test target's header search path in
  sync when moving example sources.

## CYLTabBarController

- Every `CYLTabBarController` here is created from a local configuration file
  in this directory and has a plus button with a plus child view controller,
  unless a task says otherwise. Follow the `cyl-tabbar-integration` skill.
- Register a page provider for every page ID before creating the controller,
  and keep search pages inside a `UINavigationController`.

## Search bar placement

- A search bar never covers the main view, that is, the view controller's
  view (`self.view`), or any other view, at any time and at every Dynamic
  Type size. Full rule: `instructions.md` and `AGENTS.md`, "Search bar
  placement".
- Lay out every `CYLSearchBarView` against the safe area, beside the
  content; do not let search screens extend under the top bar.

## Task log before every task

Before any task, log it as `TODO` in the most suitable document in `docs/`
(else `docs/task-log.md`): context, the user's requirements, the user's prompt
(verbatim plus English translation) and a status line. Commit and push it,
then start; mark it `DONE (YYYY-MM-DD)` with the result when the task ends.
Full rule: `AGENTS.md`, "Task log before every task".

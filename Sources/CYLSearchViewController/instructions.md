# Folder Instructions

- Inherit the repository's `instructions.md` and `AGENTS.md`.
- Keep this UIKit component independent of the example app and refresh or
  placeholder libraries. Expose integration points through public interfaces.
- Keep public headers suitable for CocoaPods consumers.

## Search bar placement

- A search bar never covers the main view, that is, the view controller's
  view (`self.view`), or any other view, at any time and at every Dynamic
  Type size. Full rule: `instructions.md` and `AGENTS.md`, "Search bar
  placement".
- Search screens in this component keep their views out from under the top
  bar (`edgesForExtendedLayout` without `UIRectEdgeTop`), so the navigation
  bar's search field never sits on top of the view controller's view.

## Task log before every task

Before any task, log it as `TODO` in the most suitable document in `docs/`
(else `docs/task-log.md`): context, the user's requirements, the user's prompt
(verbatim plus English translation) and a status line. Commit and push it,
then start; mark it `DONE (YYYY-MM-DD)` with the result when the task ends.
Full rule: `AGENTS.md`, "Task log before every task".

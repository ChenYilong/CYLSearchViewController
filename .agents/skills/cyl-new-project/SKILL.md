---
name: cyl-new-project
description: "Create or extend an Objective-C example using CYLTableViewPlaceHolder and CYLTabBarController (configuration file plus plus child view controller by default)."
---

# New example project

- Prefer the existing `CYLSearchExample.xcodeproj`; do not create a
  second app target for a focused issue reproduction.
- Declare the local dependency in the app Podfile with
  `pod 'CYLTableViewPlaceHolder', :path => '../CYLTableViewPlaceHolder'`.
- Keep `platform :ios, '15.0'`, `ENV['SWIFT_VERSION'] = '5'`,
  `use_frameworks!`, and the project declaration aligned with the app target. Run `pod install` and open the workspace.
- Import only `<CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.h>`.
- Use `CYL`-prefixed names for newly created project-owned classes and
  protocols. Keep third-party copyright and attribution intact.
- Keep the issue reproduction small and independently configurable. Do not
  couple dependency APIs to the demo's app delegate or sample model.
- Document the run steps and the known `hidesSearchBarWhenScrolling` workaround
  in the repository README.

## CYLTabBarController

Adapted from CYLTabBarController's `cyl-new-project` skill (commit `caf3c92`).

- The example integrates CYLTabBarController by default. Unless a task says
  otherwise, build it from a local configuration file with a plus button that
  has a plus child view controller: follow `cyl-tabbar-integration`.
- Depend on the latest commit on any branch, never a version, branch or tag:
  `scripts/latest-cyl-commit.sh --podfile`, then `pod install`.
- Import only `<CYLTabBarController/CYLTabBarController.h>`.
- Do not start from an Xcode template: it writes a newer project format.
- Do not set `UIViewControllerBasedStatusBarAppearance = NO`, and add no
  orientation limit in code; the target settings decide.
- Plus button details: `cyl-plus-button`.

## Search bar placement

A search bar never covers the main view, the view controller's view
(`self.view`), or any other view, at any time: a navigation-item
`UISearchController`, a `CYLSearchBarView` and the overlay, in every state and
at every Dynamic Type size. Full rule: `AGENTS.md`, "Search bar placement".

- Search screens do not extend under the top bar (`edgesForExtendedLayout`
  without `UIRectEdgeTop`).
- Lay out a `CYLSearchBarView` against the safe area, beside the content,
  never on top of it; a colored area behind it ends where the bar begins.
- Add each new search bar to `testSearchBarsCoverNoView`.

## Task log before every task

Before any task, log it as `TODO` in the most suitable document in `docs/`
(else `docs/task-log.md`): context, the user's requirements, the user's prompt
(verbatim plus English translation) and a status line. Commit and push it,
then start; mark it `DONE (YYYY-MM-DD)` with the result when the task ends.
Full rule: `AGENTS.md`, "Task log before every task".

## Swift

Swift code follows `docs/swift-coding-standard.md` and the third-party Swift skills in `.agents/skills`
(`swift-api-design-guidelines`, `swift-language`, `swift-concurrency`, `swift-testing`, `swift-architecture`,
`uikit`, `uikit-layouting`). The core's translation and its score: `docs/swift-migration.md`.

## Screenshots

Screenshots of builds and CI/CD: committed, shown in `docs/`, clear originals, labeled with platform,
environment, version or commit, and time; README updated at key milestones (`AGENTS.md`, "Screenshots of builds
and CI/CD").

## Open pull requests and issues of projects we translate

When we translate or port another GitHub project's code (for example `android/`), merge its open pull requests
(before translating, or translate and merge them afterwards), list its open issues in a `docs/` table (issue link,
description, fix status `TODO`), fix them in our code and score after every fix until 100; a translation that has not
started begins at 60. Full rule: `AGENTS.md`, same section.

## Sub-repositories

CollectionViewClassifyMenu and CYLTableViewPlaceHolder are sub-repositories: pinned to their newest commit (never a
local path in a commit), used through an enum or parameter of the core, shown in the example, on every platform.
CYLTableViewPlaceHolder shows its empty-content placeholder when a search has no results. Follow the
`cyl-sub-repositories` skill.

## Screenshot stitching order

Stitched screenshots: stacked top to bottom first, then two columns over several rows, then one row of at most
three. Correction (user, 2026-11-12): the original wording, "prefer the horizontal arrangement" and "worst is horizontal stitching", contradicted itself; the rule is to prefer the vertical arrangement, one image per row stacked top to bottom.

## Swift core: examples adapt to the core (added 2026-11-13)

When an Objective-C to Swift change of the core breaks an example's build, fix the example: example code has the lowest weight of all code here. Change any example code as needed; never keep a core API, overload, shim or deprecated alias only because an example uses it, and never lower the Swift core's quality (naming, types, optionality, access control) to fit an example. Compatibility matters only for callers outside the examples (published API users). The Swift coding standard (docs/swift-coding-standard.md) decides. Rule and context: [docs/swift-migration.md](../../../docs/swift-migration.md).

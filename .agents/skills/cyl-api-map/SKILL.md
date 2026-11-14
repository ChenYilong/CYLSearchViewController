---
name: cyl-api-map
description: "Find the public CYLTableViewPlaceHolder and CYLTabBarController APIs used by the search example."
---

# Public API map

Use the dependency's public headers only:

| Need | Public API |
|:---|:---|
| Refresh and empty-state umbrella | `CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.h` |
| Empty-state callback | `CYLTableViewPlaceHolderDelegate` |
| Reload and placeholder update | `UITableView (CYLTableViewPlaceHolder)`, `-cyl_reloadData` |
| Pull-to-refresh | `CYLRefreshNormalHeader` and `UIScrollView (CYLRefresh)`, `cyl_header` |
| Refresh completion | `-endRefreshing` on the public refresh component |

Keep the sample independent of the pod's private implementation. Put search
data access behind a project-owned protocol if it grows beyond local demo data.

## CYLTabBarController

Umbrella header: `<CYLTabBarController/CYLTabBarController.h>`. Upstream docs
at commit `caf3c92`
(`https://github.com/ChenYilong/CYLTabBarController/blob/caf3c925966f71edfc87d1dd2ed9f03cbad6aba1/docs/<Name>.md`):

| Need | Public API | Upstream doc |
|:---|:---|:---|
| Create from a local file (default) | `+tabBarControllerWithConfigurationFile:error:` | Configuration-File |
| Edit the dictionary first (add an action) | `+configurationWithContentsOfFile:error:`, `-initWithConfiguration:` | Configuration-File |
| Tabs | `CYLTabBarControllerTabBarItemsAttributes`, `CYLTabBarItemTitle` / `Image` / `SelectedImage` / `Identifier` | Configuration-File |
| Plus button and its child page | `CYLTabBarControllerPlusButton` + `CYLTabBarItemPageIdentifier`; `CYLTabBarControllerPlusButtonAction` | Configuration-File, PlusButton |
| Pages for page IDs | `CYLTabBarPageRegistry.sharedRegistry`, `-registerPageProvider:forPageIdentifier:`, `CYLTabBarControllerPageRegistry` | Tab-Page-Registry |
| Plus button in code (only when asked) | `+[CYLPlusButton cyl_registerPlusButtonWithAttributes:action:context:]` | PlusButton |
| Plus page navigation title | `CYL_NAVIGATION_TITLE_FOLLOWS_TAB_BAR_ITEM` | Update-Tab-Bar-Items-In-Place |
| Badges on the plus button | `-cyl_showBadge`, `-cyl_showBadgeValue:…` | PlusButton-Badge |
| Accessibility identifiers | tab accessibility API | Tab-Accessibility |

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

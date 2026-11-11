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

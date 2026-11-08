---
name: cyl-api-map
description: "Find the public CYLTableViewPlaceHolder APIs used by the search and refresh reproduction."
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

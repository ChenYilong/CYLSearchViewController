# Search Core Merge (CYLSearchBar)

## TODO (2026-11-17): merge the search core into the fewest classes, on every platform

- **Context**: branch `feat/harmonyos-parity` (PR #11). The iOS core (`Sources/CYLSearchViewController`, Swift) has 9
  files and 15 public types: three search screens with overlapping roles (`CYLSearchView` suggestions page,
  `CYLSearchController` overlay, `CYLSearchResultsViewController` results table), two search bars (`CYLSearchBarView`,
  `CYLMultiSearchView`), `CYLSearchBarItem` / `CYLSearchBarItemView`, `CYLSearchPlaceholderView`,
  `CYLSearchResources` and the suggestion cache (`CYLSearchSuggestionStore`). The example calls
  CYLTableViewPlaceHolder's pull-to-refresh directly (`CYLRefreshNormalHeader`, `cyl_header`, `endRefreshing`). The
  Android core `android/merged/cylsearch` declares `search-lapism`, `search-materialsearchview` and
  `search-multisearchview` as `api` dependencies but uses none of them. The other platforms (React Native, Flutter,
  HarmonyOS, mini program) port the same classes. Nothing can be compiled in this session (Linux: no Xcode, no Android
  SDK); iOS CI on PR #11 is the only automatic check.
- **Requirements**:
  1. Merge every search-related component of the core into the fewest classes. On iOS, move every search file into
     one folder, `CYLSearchBar`, and merge classes with similar features and similar APIs into suitable files.
  2. Merge the search-related APIs of the other core folders. An API that duplicates another is kept once. An API
     that differs only by a parameter becomes one API with the new parameter, in the suitable file.
  3. Refresh interfaces live in the `CYLSearchBar` component; change the example's refresh calls that do not go
     through the core.
  4. CYLSearch is the only search kernel: it must not depend on another search kernel. CollectionViewClassifyMenu is
     excluded (it is not search-related).
  5. Then apply the same to Android and the other platforms.
  6. Example code may change freely; its current usage need not be kept.
- **Decisions (user, 2026-11-17)**: 3 files with 4 classes; the core wraps pull-to-refresh (one refresh API that uses
  CYLTableViewPlaceHolder inside, the example uses only that API); all platforms in one go.
- **Prompt (verbatim)**: "先将项目中所有core里面的search相关的组件进行merge 到最少的类。在iOS端重构core 核心代码，merge所有与search相关的文件夹文件进入CYLSearchBar文件夹， merge类似功能类似API进入合适的文件， ，merge其他core文件夹里的search相关api。，如果其他文件夹里的文件的API与它重复，那么仅仅保留一个的api。如果不重复仅仅api新增参数就能实现，那么找到文件夹里的合适文件，复制某一api并新增参数。并修改example的非core相关的刷新api。修改完成后同样的要求作用于android端与其他端。保证刷新接口聚合在CYLSearchBar组件内。要求CYLSearch  为唯一kernel，不能依赖其他search类kernel。collectview除外他不是search相关。example代码可以随便改，无须考虑example用法。"
- **Prompt (English)**: "First merge all search-related components in the project's core into the fewest classes. On
  iOS, refactor the core: merge all search-related folders and files into a CYLSearchBar folder, merge classes with
  similar features and APIs into suitable files, and merge the search-related APIs of other core folders. If an API
  in another folder duplicates one, keep only one. If it does not duplicate but can be done by adding a parameter,
  find the suitable file in the folder, copy that API and add the parameter. Also change the example's refresh APIs
  that are not core. When done, apply the same requirements to Android and the other platforms. Make sure the refresh
  interfaces are aggregated in the CYLSearchBar component. CYLSearch must be the only kernel and must not depend on
  other search kernels; the collection view is excluded, it is not search-related. Example code may change freely,
  regardless of its current usage."
- **Status**: logged; design next (section "Target design").

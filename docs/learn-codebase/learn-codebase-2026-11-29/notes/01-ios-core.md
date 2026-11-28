> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Working notes from the first read: NOT re-checked, and some were later corrected (see 02-findings.md).

# iOS core: reading notes

Saved during the 2026-11-29 full read (work list `learn-codebase-2026-11-29`). The text under "Saved note" is **verbatim**; it was written at that moment, so `next=…` markers are progress bookkeeping. Where it disagrees with [../02-findings.md](../02-findings.md), the findings file is newer.

## Saved note

12/12 chunks read. Files: BarView (bar+item+multi), SearchView (page; suggestions/results/refresh), SearchController (own page over host, QMUI-shaped), Appearance, NavigationBar+presets, PresentationState+edge swipe, Resources+SQLite history, ResultsComponent, SuggestionArea, TableViewController, HeaderSnapper, TagList style/header. Findings: searchButtonItem doc says tint kept on rebuild but rebuildSearchButton copies only accessibility id; public doc comments garbled by a find-replace (QMthe system search controller, qmui_styledAsQMthe system search bar, class CYLSearchBar that no longer exists); duplicated header line in CYLSearchController.swift; Podfile pins PlaceHolder f4cf9785 but instruction docs say 62e40c0 on every platform; iOS Podfile pins TabBar+AnimatedItem 08343e9f, ClassifyMenu c0b183de

## Files read (15)

- `CYLSearchViewController.podspec` (41)
- `Podfile` (39)
- `Sources/CYLSearchBar/CYLSearchBarAppearance.swift` (286)
- `Sources/CYLSearchBar/CYLSearchBarView.swift` (3384)
- `Sources/CYLSearchBar/CYLSearchController.swift` (791)
- `Sources/CYLSearchBar/CYLSearchHeaderSnapper.swift` (156)
- `Sources/CYLSearchBar/CYLSearchNavigationBar.swift` (201)
- `Sources/CYLSearchBar/CYLSearchPresentationState.swift` (274)
- `Sources/CYLSearchBar/CYLSearchResources.swift` (348)
- `Sources/CYLSearchBar/CYLSearchResultsComponent.swift` (344)
- `Sources/CYLSearchBar/CYLSearchSuggestionArea.swift` (313)
- `Sources/CYLSearchBar/CYLSearchTableViewController.swift` (204)
- `Sources/CYLSearchBar/CYLSearchTagListHeader.swift` (44)
- `Sources/CYLSearchBar/CYLSearchTagListStyle.swift` (140)
- `Sources/CYLSearchBar/CYLSearchView.swift` (1323)

Declarations with line numbers: [../reference/01-ios-core.md](../reference/01-ios-core.md)

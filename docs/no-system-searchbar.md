# No system search bar: CYLSearchBarView everywhere (iOS plan and API map)

Owner order 2026-11-26 (tags `core`, `example-demos`; skill `cyl-search-field`): no platform may use a system search bar. Owner decision for the iOS
QMUI port: "Rebuild on CYLSearchBarView". Task log entry: `docs/task-log.md`, "no system search bar on any platform".

## Design (facade over CYLSearchView)

`CYLSearchView` already owns `CYLSearchBarView` (every `CYLSearchBar` knob exists on it under the same name), the launch / suggestions
view, the results table, the scrim, match highlighting, empty states, refresh and swipe-to-dismiss. `CYLSearchController` becomes a thin
view controller facade over it: it hosts the contents view controller as a child and one `CYLSearchView` over it; the delegate
(`CYLSearchControllerDelegate`: results update + the results table's data source and delegate) is adapted to the view's results table. No
`UISearchController`, no `UISearchBar`, no `UISearchTextField` is created. `CYLSearchTableViewController` keeps its API and hosts the field.

## API map (every public member of the three classes)

| Member | Fate | Backed by |
|---|---|---|
| `CYLSearchBar` (the `UISearchBar` subclass) | removed (breaking) | `CYLSearchBarView` (typealias `CYLSearchBar = CYLSearchBarView` is NOT kept: it would hide the change) |
| `appearanceStyle`, `placeholderColor`, `textColor`, `font`, `textFieldMargins(Provider)`, `centersPlaceholder`, `cancelButtonFont`, `cancelButtonMarginsProvider`, `alwaysEnablesCancelButton`, `backgroundView`, `leading/trailingAccessoryView` + margins + `setShows…Animated` | kept, re-backed | the same-named `CYLSearchBarView` members |
| `usedAsTableHeaderView`, `segmentedControl`, `cancelButton`, `barTintColor`, `setBackgroundImage(_:for:)`, `searchController` (back reference) | removed or replaced | `fieldBackgroundImage`, `fieldBackgroundColor`; no UISearchController exists |
| `CYLSearchController(contentsViewController:resultsViewController:)` and the two convenience inits | kept, re-backed | the facade; `resultsViewController` must be a table view controller |
| `searchResultsDelegate`, `tableView`, `searchBar` (type `CYLSearchBarView`), `highlightsResultMatches`, `resultMatchHighlightColor`, `launchView`, `showsSuggestionsLaunchView`, `suggestions`, `dimmingColor`, `isActive`, `setActive(_:animated:)`, `showSearch`, `closeSearch`, `searchOpen`, `supportsSwipeToDismissSearch`, `swipeGestureRecognizer`, `isEmptyViewShowing`, `showEmptyView(...)`, `hideEmptyView`, `noResultsText`, `historyStore`, `historyDidChangeNotification` | kept, re-backed | `CYLSearchView` (`resultsTableView`, `scrimColor`, `suggestions`, `searchOpen`, ...) |
| `searchController` (`UISearchController`), `searchResultsController`, `hidesNavigationBarDuringPresentation`, `alwaysShowsSearchResultsController`, `forwardsAppearanceFromContentsViewController`, `searchBarMaxY`, `prefersStatusBarHiddenProvider`, `preferredStatusBarStyleProvider`, UISearchResultsUpdating / UISearchControllerDelegate conformance | removed (UIKit-only) | none; each removal and its test is listed in the task log |
| `installSearchBar(asHeaderOf:)`, `install(in: UINavigationItem)`, `snapsHeaderSearchBar` | kept, re-backed | `CYLSearchBarView` as the header / `embedInNavigationBar(of:)`, `CYLSearchView.setSnapsHeader` |
| `CYLSearchTableViewController` (`showsSearchBar`, `searchController`, `searchBar` type, `hidesSearchBarWhenEmptyViewShowing`, `hidesSearchBarInitially`, `isEmptyViewShowing`, `setUpSearchBar`, `searchController(_:updateResultsFor:)`, empty-view API) | kept, `searchBar` becomes `CYLSearchBarView?` | the facade |

## Status 2026-11-26

Steps 1 to 7 below are done on iOS; the grep is clean. Differences from the first plan (the design that shipped):

- `CYLSearchController` does not sit on `CYLSearchView`. It hosts `CYLSearchBarView` (`searchBar`) and, while active, one page below the field
  (dimming view, launch view, the results view controller's view, the empty view) over the navigation controller's view (or the window).
  The results table is the caller's (`searchResultsDelegate` keeps the full `UITableViewDataSource` / `UITableViewDelegate`).
- Kept (re-backed): `searchResultsController` (now a `let`), `searchBar` (type `CYLSearchBarView`), `searchBarMaxY`,
  `alwaysShowsSearchResultsController`, `supportsSwipeToDismissSearch` (the page slides, no window snapshot).
- Removed (breaking): `CYLSearchBar`, `searchController`, `hidesNavigationBarDuringPresentation`,
  `forwardsAppearanceFromContentsViewController`, `prefersStatusBarHiddenProvider`, `preferredStatusBarStyleProvider`, the
  `UISearchResultsUpdating` / `UISearchControllerDelegate` conformance, `CYLSearchBarAppearance`'s system-bar probe.
- Text assigned in code (`searchBar.text = ...`) updates the results through the internal `CYLSearchBarView.textAssignedHandler`.

## Work list (status in `docs/task-log.md`)

1. Facade `CYLSearchController` + `CYLSearchTableViewController` (core). TODO.
2. Remove `CYLSearchBar`, `CYLSearchHeaderSnapper`'s UISearchBar paths, `CYLSearchPresentationState`'s UISearchController paths, the UISearchBar parts of `CYLSearchBarAppearance`. TODO.
3. Demos: Search controller, Navigation item, Collection view, Original, Lapis, Reveal, Yechaoa, the search bar styles screen use the core field. TODO.
4. `CrossPlatform/react-native-cylsearch/ios/CylsearchListView.mm` (UISearchBar). TODO.
5. Tests: rewrite the UIKit-only assertions (`obscuresBackgroundDuringPresentation`, `automaticallyShowsCancelButton`, `searchResultsController is UITableViewController`, swipe on the system controller) against the new contract, or delete them with the reason in the task log; update `CYLSearchAPIFenceTests` and `CYLSearchCoreObjectiveCSmokeTests.m`. TODO.
6. `docs/qmui-search-controller.md` rows E1 to E22: mark each as kept, replaced or dropped. TODO.
7. Done when `grep -rnE "UISearchBar|UISearchController|UISearchTextField" Sources CYLSearchExample CrossPlatform/*/ios` has no hit outside Pods and vendor.

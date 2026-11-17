## 0.1.0

* Moved onto the merged CYLSearchBar core (iOS `Sources/CYLSearchBar`, Android `cylsearch`): `CYLSearchView` gains
  results (`results`, `onSelectResult`) and pull-to-refresh (`refreshEnabled`, `onRefresh`, and
  `CYLSearchViewWidgetController.beginRefreshing()` / `endRefreshing()` / `isRefreshing()` / `reloadResults()`);
  `CYLSearchBarView` gains `mode` (`CYLSearchBarMode.single` / `multiple`), `searches`, `onTextChange`,
  `onCompleteSearch`, `onRemoveSearch`, `onSelectSearch` and `CYLSearchBarWidgetController`. The iOS pod no longer
  declares CYLTableViewPlaceHolder: the placeholder and refresh come only through the core.

* `CYLTagListView`: CollectionViewClassifyMenu's native tag list as a widget, sized to its tags (the example's discover
  page uses it).

* First version: `CYLSearchView` (the native search page with list or tag suggestions and CYLTableViewPlaceHolder's empty
  results placeholder) and `CYLSearchBarView` (the native search bar) as platform views on iOS and Android; the views
  follow the app's theme brightness.

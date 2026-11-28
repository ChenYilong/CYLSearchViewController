## 0.1.0

* Merge phase 5 (docs/qmui-search-controller.md): one implementation per concept, with the iOS names. `CYLSearchView` takes
  `scrimColor` (the native scrim; a tap ends the search), `noResultsText`, `resultMatchHighlightColor` (the match ignores case
  and diacritics), `onWillShow`, `onDidShow`, `onWillClose` (`onClose` is the did-close event), and its native launch area
  (the ClassifyMenu tag list with the recent searches, folded, fold control last) is used through `suggestions`,
  `showsSuggestionsForEmptyQuery` and `submitsOnSuggestionSelection`; a tapped tag submits. The controller has
  `setQuery(query, submit:)`. `CYLSearchBarView` has `leadingView` and `trailingAccessoryViews` (Flutter widgets in a row
  beside the native field: a platform view cannot host them). `launchViewBuilder` stays for content that is not tags.
  The Dart overlays for dimming, the empty view and the edge swipe are removed (native now); `dimmingColor`,
  `onUpdateResults`, `onWillPresent`, `onDidPresent`, `onWillDismiss`, `onDidDismiss`, `showEmptyView`, `hideEmptyView`,
  `isEmptyViewShowing` and the `...AccessoryView` names of the unreleased QMUI port are gone.

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

# flutter_cylsearch

CYLSearchViewController for Flutter: the native search page and search bar of the CYLSearchBar core (iOS
`Sources/CYLSearchBar`, Android `cylsearch`), shown as platform views (`UiKitView` on iOS, hybrid composition on
Android). The widgets follow the core's classes: `CYLSearchView` (suggestions as a list or as tags from
CollectionViewClassifyMenu, results, pull-to-refresh, and CYLTableViewPlaceHolder's placeholder for a query without
results) and `CYLSearchBarView` (one field, or several searches side by side with `mode: CYLSearchBarMode.multiple`).
The plugin depends on no other search library; CYLTableViewPlaceHolder comes only through the core.

```dart
// The search page: push it as a full screen route, its bar takes the navigation bar's place.
CYLSearchView(
  suggestions: const ['Android', 'iOS', 'Kotlin', 'Swift'],
  suggestionStyle: CYLSearchSuggestionStyle.tags,
  showsEmptyResultsPlaceholder: true,
  onSubmitted: (query) {},
  onSuggestionSelected: (suggestion, index) {},
  onClose: () => Navigator.of(context).pop(),
);

// Results with pull to refresh: filter `results` yourself as the query changes.
final controller = CYLSearchViewWidgetController();
CYLSearchView(
  controller: controller,
  results: matches,
  refreshEnabled: true,
  onRefresh: () async {
    await reload();
    await controller.endRefreshing(); // on every completion path
  },
  onTextChanged: (query) => setState(() => matches = filter(query)),
  onSelectResult: (result, index) {},
);

// The search bar, inline (give it a height of about 48).
CYLSearchBarView(placeholder: 'Search', showsCancelButton: true, onTextChanged: (text) {});

// Several searches side by side (a height of about 56).
CYLSearchBarView(
  mode: CYLSearchBarMode.multiple,
  controller: barController, // beginNewSearch(), completeSearch(), addSearch(), selectSearch(), removeSearch()
  searches: const ['Swift', 'Kotlin'],
  onCompleteSearch: (text, index) {},
  onRemoveSearch: (index) {},
  onSelectSearch: (text, index) {},
  onTextChange: (text, index) {},
);
CYLTagListView(tags: const ['Swift', 'Kotlin'], onTagSelected: (index, title) {});
```

| Widget | Native view | Parameters (iOS names) | Events |
|:---|:---|:---|:---|
| `CYLSearchView` | `CYLSearchView` | `suggestions`, `suggestionStyle`, `placeholder`, `query`, `showsSuggestionsForEmptyQuery`, `submitsOnSuggestionSelection`, `showsEmptyResultsPlaceholder`, `emptyResultsScenario`, `results` (`resultsDataSource`), `refreshEnabled` (`refreshHandler`), `controller` (`beginRefreshing()`, `endRefreshing()`, `isRefreshing`, `reloadResults()`) | `onTextChanged`, `onSubmitted`, `onSuggestionSelected`, `onSelectResult`, `onRefresh`, `onClose` |
| `CYLSearchBarView` | `CYLSearchBarView` | `placeholder`, `text`, `showsCancelButton`, `fieldShadowOpacity`, `searchBarStyle`, `items`, `mode`, `searches`, `controller` (`beginNewSearch()`, `completeSearch()`, `addSearch(_:)`, `selectSearch(at:)`, `removeSearch(at:)`, `searches`, `selectedSearchIndex`) | `onTextChanged` (single), `onSubmitted`, `onCancel`, `onItemSelected`, `onTextChange`, `onCompleteSearch`, `onRemoveSearch`, `onSelectSearch` (multiple) |
| `CYLTagListView` | CollectionViewClassifyMenu's `CYLTagListView` (the tags of `suggestionsTagView`); takes the height its tags need | `tags` | `onTagSelected` |

The native views use the app's theme brightness (`Theme.of(context)`), whatever the system setting is.

## Building

- Android: the plugin depends on `com.cyl.search:cylsearch`; an app in this repository includes `../../android/merged`
  as a composite build that substitutes it (`example/android/settings.gradle.kts`). A composite build allows one
  Android Gradle plugin version, so `android/merged` and the app use AGP 8.11.1 and Kotlin 2.2.20 (Flutter 3.47's
  minimums).
- iOS: CocoaPods (Swift Package Manager is off in the example: the plugin depends on the CYLSearchViewController pod).
  The app links pods as static frameworks, as CollectionViewClassifyMenu and CYLTableViewPlaceHolder are.

Tests: `flutter test` (the parameters and events of both widgets). Details and screenshots:
`docs/android-and-cross-platform.md`.

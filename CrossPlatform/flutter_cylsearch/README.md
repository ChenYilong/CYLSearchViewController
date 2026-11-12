# flutter_cylsearch

CYLSearchViewController for Flutter: the native search page and search bar of the iOS Swift core and the Android
`cylsearch` module, shown as platform views (`UiKitView` on iOS, hybrid composition on Android). Every feature of the
core comes with them: suggestions as a list or as tags (CollectionViewClassifyMenu), and CYLTableViewPlaceHolder's
placeholder for a query without results.

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

// The search bar, inline (give it a height of about 48).
CYLSearchBarView(placeholder: 'Search', showsCancelButton: true, onTextChanged: (text) {});
```

| Widget | Native view | Parameters (iOS names) | Events |
|:---|:---|:---|:---|
| `CYLSearchView` | `CYLSearchView` | `suggestions`, `suggestionStyle`, `placeholder`, `query`, `showsSuggestionsForEmptyQuery`, `submitsOnSuggestionSelection`, `showsEmptyResultsPlaceholder`, `emptyResultsScenario` | `onTextChanged`, `onSubmitted`, `onSuggestionSelected`, `onClose` |
| `CYLSearchBarView` | `CYLSearchBarView` | `placeholder`, `text`, `showsCancelButton`, `fieldShadowOpacity` | `onTextChanged`, `onSubmitted`, `onCancel` |

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

# Android API Alignment

Step 4 and 5 of [android-and-cross-platform.md](android-and-cross-platform.md): every public API of the iOS library
(`Sources/CYLSearchViewController`) next to its counterpart in `android/merged`. The second column names the
upstream API (one of the projects merged in `android/merged`) that the iOS doc comment cites; the third column is
the Kotlin API of the `cylsearch` module, which keeps the iOS names (Kotlin conventions: `isSearchOpen` for
`isSearchOpen`, delegate methods named after the Objective-C selector, such as `searchBarViewTextDidChange` for
`searchBarView:textDidChange:`).

## DONE (2026-11-12): align every iOS API in android/merged, score to 100

- Context: step 4 lists the iOS API with its counterpart; step 5 adds what `merged` lacks and scores after each
  added API until full alignment (100).
- Rules of the table: `DONE` when the Kotlin declaration exists in `cylsearch` (checked by
  `android/merged/scripts/api-alignment.py`, which writes the table); `N/A` for UIKit protocol conformances (public
  in Swift only because `UITextFieldDelegate` or `UITableViewDataSource` requires it; Android uses internal
  listeners); `TODO` otherwise.
- Android types for iOS types: colors are `@ColorInt Int` (null = the theme default), images `Drawable`, sizes dp,
  durations seconds (as on iOS), `UIFont` is `font: Typeface` plus `fontSize` (sp), `UIKeyboardType` an `InputType`
  class, `UIReturnKeyType` an `EditorInfo.IME_ACTION_*`, `NSNotFound` is -1, view controllers are fragments.
- Status: DONE for steps 4 and 5 (score 100, 2026-11-12). The iOS examples in the Android example app are step 6.

## Score log

Score = (DONE + N/A) / rows × 100, recomputed by the script after each change.

| Date | Change | Score |
| :--- | :--- | ---: |
| 2026-11-12 | Table listed, `cylsearch` empty (only the N/A rows count) | 11 |
| 2026-11-12 | `CYLSearchResources`, `CYLSearchPlaceholderView` and their enums; iOS images and strings imported (`scripts/import-ios-resources.py`) | 33 |
| 2026-11-12 | `CYLSearchBarView`, its delegate and enums | 68 |
| 2026-11-12 | `CYLSearchView`, its delegate, `CYLSearchSuggestionCell`, `CYLLineBreakMode` | 83 |
| 2026-11-12 | `CYLMultiSearchView` and its delegate | 91 |
| 2026-11-12 | `CYLSearchResultsViewController`, `CYLSearchController` (fragments) and their protocols | 100 |

The scores per step are replayed with `--only=<classes added so far>` on the final sources, so they include the
`requestFocus` / `clearFocus` / `setBackgroundColor` overrides that were added last.

Behavior checks: `cylsearch/src/test/kotlin/com/cyl/search/CYLSearchBehaviorTest.kt` (Robolectric, 9 tests, all
pass): diacritic- and case-insensitive filtering, custom filters and empty queries; submit closes unless the
delegate handles it; the navigation button closes by default; a tapped suggestion fills the query; the bar skips
blank text and asks the delegate; programmatic text does not report a change, typing does; `maximumTextLength`;
iconified state; multi-search complete, add, select and remove with the iOS selection rules; placeholder images,
messages, localized strings (English, Simplified Chinese, a missing key) and the invalid style.

## Table

<!-- api-alignment:begin -->
Rows: 294; DONE 261, N/A 33, TODO 0; score 100/100.

| iOS API | Upstream counterpart (named in the iOS doc comment) | Android (`cylsearch`) | Status |
| :--- | :--- | :--- | :--- |
| **protocol `CYLMultiSearchViewDelegate`** | iammert `MultiSearchViewListener` | CYLMultiSearchViewDelegate | DONE |
| `CYLMultiSearchViewDelegate.-multiSearchView:textDidChange:atIndex:` | `onTextChanged` | `CYLMultiSearchViewDelegate.multiSearchViewTextDidChange` | DONE |
| `CYLMultiSearchViewDelegate.-multiSearchView:didCompleteSearch:atIndex:` | `onSearchComplete` | `CYLMultiSearchViewDelegate.multiSearchViewDidCompleteSearch` | DONE |
| `CYLMultiSearchViewDelegate.-multiSearchView:didRemoveItemAtIndex:` | `onSearchItemRemoved` | `CYLMultiSearchViewDelegate.multiSearchViewDidRemoveItemAtIndex` | DONE |
| `CYLMultiSearchViewDelegate.-multiSearchView:didSelectItem:atIndex:` | `onItemSelected` | `CYLMultiSearchViewDelegate.multiSearchViewDidSelectItem` | DONE |
| **class `CYLMultiSearchView`** | iammert `MultiSearchView` | CYLMultiSearchView | DONE |
| `CYLMultiSearchView.delegate` | — | `CYLMultiSearchView.delegate` | DONE |
| `CYLMultiSearchView.selectedIndex` | — | `CYLMultiSearchView.selectedIndex` | DONE |
| `CYLMultiSearchView.inSearchMode` | `isInSearchMode` | `CYLMultiSearchView.isInSearchMode` | DONE |
| `CYLMultiSearchView.searchButton` | — | `CYLMultiSearchView.searchButton` | DONE |
| `CYLMultiSearchView.placeholder` | `android:hint` | `CYLMultiSearchView.placeholder` | DONE |
| `CYLMultiSearchView.font` | `android:textSize` | `CYLMultiSearchView.font` | DONE |
| `CYLMultiSearchView.textColor` | `android:textColor` | `CYLMultiSearchView.textColor` | DONE |
| `CYLMultiSearchView.placeholderColor` | `android:textColorHint` | `CYLMultiSearchView.placeholderColor` | DONE |
| `CYLMultiSearchView.maximumTextLength` | `android:maxLength` | `CYLMultiSearchView.maximumTextLength` | DONE |
| `CYLMultiSearchView.minimumTextLength` | — | `CYLMultiSearchView.minimumTextLength` | DONE |
| `CYLMultiSearchView.returnKeyType` | `android:imeOptions` | `CYLMultiSearchView.returnKeyType` | DONE |
| `CYLMultiSearchView.keyboardType` | `android:inputType` | `CYLMultiSearchView.keyboardType` | DONE |
| `CYLMultiSearchView.autocapitalizationType` | `textCapSentences` | `CYLMultiSearchView.autocapitalizationType` | DONE |
| `CYLMultiSearchView.indicatorColor` | — | `CYLMultiSearchView.indicatorColor` | DONE |
| `CYLMultiSearchView.unselectedItemAlpha` | — | `CYLMultiSearchView.unselectedItemAlpha` | DONE |
| `CYLMultiSearchView.searchFieldWidth` | — | `CYLMultiSearchView.searchFieldWidth` | DONE |
| `CYLMultiSearchView.animationDuration` | — | `CYLMultiSearchView.animationDuration` | DONE |
| `CYLMultiSearchView.searchImage` | — | `CYLMultiSearchView.searchImage` | DONE |
| `CYLMultiSearchView.removeImage` | — | `CYLMultiSearchView.removeImage` | DONE |
| `CYLMultiSearchView.searchTexts` | — | `CYLMultiSearchView.searchTexts` | DONE |
| `CYLMultiSearchView.init(frame:)` | — | constructor(context) | DONE |
| `CYLMultiSearchView.init(coder:)` | — | constructor(context, attrs) (XML) | DONE |
| `CYLMultiSearchView.tintColorDidChange()` | — | framework override (Android has no inherited tint) | N/A |
| `CYLMultiSearchView.traitCollectionDidChange(_:)` | — | framework override (Android recreates views on configuration changes) | N/A |
| `CYLMultiSearchView.intrinsicContentSize` | — | framework override (Android: measured height, `minimumHeight`) | N/A |
| `CYLMultiSearchView.layoutSubviews()` | — | framework override (Android lays out with its layout classes) | N/A |
| `CYLMultiSearchView.search()` | `search` | `CYLMultiSearchView.search` | DONE |
| `CYLMultiSearchView.completeSearch()` | `completeSearch` | `CYLMultiSearchView.completeSearch` | DONE |
| `CYLMultiSearchView.addSearchText(_:)` | — | `CYLMultiSearchView.addSearchText` | DONE |
| `CYLMultiSearchView.selectItem(at:)` | — | `CYLMultiSearchView.selectItemAtIndex` | DONE |
| `CYLMultiSearchView.removeItem(at:)` | — | `CYLMultiSearchView.removeItemAtIndex` | DONE |
| `CYLMultiSearchView.textFieldShouldBeginEditing(_:)` | — | internal listener (UIKit protocol conformance) | N/A |
| `CYLMultiSearchView.textFieldShouldReturn(_:)` | — | internal listener (UIKit protocol conformance) | N/A |
| `CYLMultiSearchView.textField(_:shouldChangeCharactersIn:replacementString:)` | — | internal listener (UIKit protocol conformance) | N/A |
| **enum `CYLSearchBarNavigationIcon`** | lapism `NavigationIconCompat` | CYLSearchBarNavigationIcon | DONE |
| `CYLSearchBarNavigationIcon.none` | — | `CYLSearchBarNavigationIcon.None` | DONE |
| `CYLSearchBarNavigationIcon.arrow` | `chevron.backward` | `CYLSearchBarNavigationIcon.Arrow` | DONE |
| `CYLSearchBarNavigationIcon.search` | `magnifyingglass` | `CYLSearchBarNavigationIcon.Search` | DONE |
| **enum `CYLSearchBarIconPosition`** | — | CYLSearchBarIconPosition | DONE |
| `CYLSearchBarIconPosition.trailing` | — | `CYLSearchBarIconPosition.Trailing` | DONE |
| `CYLSearchBarIconPosition.center` | — | `CYLSearchBarIconPosition.Center` | DONE |
| `CYLSearchBarIconPosition.leading` | — | `CYLSearchBarIconPosition.Leading` | DONE |
| **enum `CYLSearchBarExpansionAnimation`** | — | CYLSearchBarExpansionAnimation | DONE |
| `CYLSearchBarExpansionAnimation.fade` | — | `CYLSearchBarExpansionAnimation.Fade` | DONE |
| `CYLSearchBarExpansionAnimation.circularReveal` | — | `CYLSearchBarExpansionAnimation.CircularReveal` | DONE |
| **protocol `CYLSearchBarViewDelegate`** | — | CYLSearchBarViewDelegate | DONE |
| `CYLSearchBarViewDelegate.-searchBarViewShouldBeginEditing:` | lapism `MaterialSearchBar.setOnClickListener` | `CYLSearchBarViewDelegate.searchBarViewShouldBeginEditing` | DONE |
| `CYLSearchBarViewDelegate.-searchBarViewDidTapWhileNotEditable:` | — | `CYLSearchBarViewDelegate.searchBarViewDidTapWhileNotEditable` | DONE |
| `CYLSearchBarViewDelegate.-searchBarViewDidBeginEditing:` | — | `CYLSearchBarViewDelegate.searchBarViewDidBeginEditing` | DONE |
| `CYLSearchBarViewDelegate.-searchBarViewDidEndEditing:` | — | `CYLSearchBarViewDelegate.searchBarViewDidEndEditing` | DONE |
| `CYLSearchBarViewDelegate.-searchBarView:textDidChange:` | typing, the clear button, Cancel with `clearsTextOnCancel` | `CYLSearchBarViewDelegate.searchBarViewTextDidChange` | DONE |
| `CYLSearchBarViewDelegate.-searchBarViewSearchButtonClicked:` | — | `CYLSearchBarViewDelegate.searchBarViewSearchButtonClicked` | DONE |
| `CYLSearchBarViewDelegate.-searchBarViewCancelButtonClicked:` | — | `CYLSearchBarViewDelegate.searchBarViewCancelButtonClicked` | DONE |
| `CYLSearchBarViewDelegate.-searchBarViewNavigationButtonClicked:` | `navigationIcon`, `navigationImage` | `CYLSearchBarViewDelegate.searchBarViewNavigationButtonClicked` | DONE |
| `CYLSearchBarViewDelegate.-searchBarViewVoiceButtonClicked:` | `showsVoiceButton` | `CYLSearchBarViewDelegate.searchBarViewVoiceButtonClicked` | DONE |
| `CYLSearchBarViewDelegate.-searchBarView:shouldSubmitText:` | — | `CYLSearchBarViewDelegate.searchBarViewShouldSubmitText` | DONE |
| `CYLSearchBarViewDelegate.-searchBarView:didChangeIconified:` | `iconified` | `CYLSearchBarViewDelegate.searchBarViewDidChangeIconified` | DONE |
| **class `CYLSearchBarView`** | — | CYLSearchBarView | DONE |
| `CYLSearchBarView.delegate` | — | `CYLSearchBarView.delegate` | DONE |
| `CYLSearchBarView.textField` | — | `CYLSearchBarView.textField` | DONE |
| `CYLSearchBarView.fieldView` | — | `CYLSearchBarView.fieldView` | DONE |
| `CYLSearchBarView.searchIconView` | — | `CYLSearchBarView.searchIconView` | DONE |
| `CYLSearchBarView.cancelButton` | `showsCancelButton` | `CYLSearchBarView.cancelButton` | DONE |
| `CYLSearchBarView.placeholderLabel` | — | `CYLSearchBarView.placeholderLabel` | DONE |
| `CYLSearchBarView.navigationButton` | — | `CYLSearchBarView.navigationButton` | DONE |
| `CYLSearchBarView.voiceButton` | — | `CYLSearchBarView.voiceButton` | DONE |
| `CYLSearchBarView.submitButton` | — | `CYLSearchBarView.submitButton` | DONE |
| `CYLSearchBarView.iconButton` | — | `CYLSearchBarView.iconButton` | DONE |
| `CYLSearchBarView.text` | — | `CYLSearchBarView.text` | DONE |
| `CYLSearchBarView.placeholder` | — | `CYLSearchBarView.placeholder` | DONE |
| `CYLSearchBarView.font` | pass a `UIFontMetrics` font to scale it | `CYLSearchBarView.font` | DONE |
| `CYLSearchBarView.textColor` | — | `CYLSearchBarView.textColor` | DONE |
| `CYLSearchBarView.placeholderColor` | — | `CYLSearchBarView.placeholderColor` | DONE |
| `CYLSearchBarView.cursorColor` | MaterialSearchView `setCursorDrawable` | `CYLSearchBarView.cursorColor` | DONE |
| `CYLSearchBarView.fieldHeight` | — | `CYLSearchBarView.fieldHeight` | DONE |
| `CYLSearchBarView.contentInsets` | — | `CYLSearchBarView.contentInsets` | DONE |
| `CYLSearchBarView.fieldBackgroundColor` | — | `CYLSearchBarView.fieldBackgroundColor` | DONE |
| `CYLSearchBarView.fieldCornerRadius` | — | `CYLSearchBarView.fieldCornerRadius` | DONE |
| `CYLSearchBarView.fieldBorderColor` | — | `CYLSearchBarView.fieldBorderColor` | DONE |
| `CYLSearchBarView.fieldBorderWidth` | — | `CYLSearchBarView.fieldBorderWidth` | DONE |
| `CYLSearchBarView.fieldShadowOpacity` | — | `CYLSearchBarView.fieldShadowOpacity` | DONE |
| `CYLSearchBarView.searchIcon` | — | `CYLSearchBarView.searchIcon` | DONE |
| `CYLSearchBarView.searchIconTintColor` | — | `CYLSearchBarView.searchIconTintColor` | DONE |
| `CYLSearchBarView.trailingAccessoryViews` | — | `CYLSearchBarView.trailingAccessoryViews` | DONE |
| `CYLSearchBarView.leadingView` | — | `CYLSearchBarView.leadingView` | DONE |
| `CYLSearchBarView.showsCancelButton` | — | `CYLSearchBarView.showsCancelButton` | DONE |
| `CYLSearchBarView.cancelButtonTitle` | — | `CYLSearchBarView.cancelButtonTitle` | DONE |
| `CYLSearchBarView.cancelButtonEndsEditing` | — | `CYLSearchBarView.cancelButtonEndsEditing` | DONE |
| `CYLSearchBarView.clearsTextOnCancel` | lapism `setTextClearOnBackPressed` | `CYLSearchBarView.clearsTextOnCancel` | DONE |
| `CYLSearchBarView.clearsTextOnEndEditing` | lapism `setTextClearOnClearFocus` | `CYLSearchBarView.clearsTextOnEndEditing` | DONE |
| `CYLSearchBarView.navigationIcon` | — | `CYLSearchBarView.navigationIcon` | DONE |
| `CYLSearchBarView.navigationImage` | — | `CYLSearchBarView.navigationImage` | DONE |
| `CYLSearchBarView.navigationAccessibilityLabel` | — | `CYLSearchBarView.navigationAccessibilityLabel` | DONE |
| `CYLSearchBarView.navigationBackgroundColor` | — | `CYLSearchBarView.navigationBackgroundColor` | DONE |
| `CYLSearchBarView.navigationShadowOpacity` | lapism `setNavigationElevation` | `CYLSearchBarView.navigationShadowOpacity` | DONE |
| `CYLSearchBarView.navigationHandler` | — | `CYLSearchBarView.navigationHandler` | DONE |
| `CYLSearchBarView.showsVoiceButton` | — | `CYLSearchBarView.showsVoiceButton` | DONE |
| `CYLSearchBarView.voiceImage` | — | `CYLSearchBarView.voiceImage` | DONE |
| `CYLSearchBarView.showsSubmitButton` | Android `isSubmitButtonEnabled` | `CYLSearchBarView.showsSubmitButton` | DONE |
| `CYLSearchBarView.submitImage` | — | `CYLSearchBarView.submitImage` | DONE |
| `CYLSearchBarView.clearImage` | — | `CYLSearchBarView.clearImage` | DONE |
| `CYLSearchBarView.keyboardType` | Android `inputType` | `CYLSearchBarView.keyboardType` | DONE |
| `CYLSearchBarView.returnKeyType` | Android `imeOptions` | `CYLSearchBarView.returnKeyType` | DONE |
| `CYLSearchBarView.autocapitalizationType` | — | `CYLSearchBarView.autocapitalizationType` | DONE |
| `CYLSearchBarView.autocorrectionType` | — | `CYLSearchBarView.autocorrectionType` | DONE |
| `CYLSearchBarView.isSecureTextEntry` | Android `inputType="textPassword"` | `CYLSearchBarView.isSecureTextEntry` | DONE |
| `CYLSearchBarView.maximumTextLength` | Android `maxLength` | `CYLSearchBarView.maximumTextLength` | DONE |
| `CYLSearchBarView.isIconified` | Android `SearchView.isIconified` | `CYLSearchBarView.isIconified` | DONE |
| `CYLSearchBarView.iconifiedByDefault` | Android `setIconifiedByDefault` | `CYLSearchBarView.iconifiedByDefault` | DONE |
| `CYLSearchBarView.expansionAnimation` | — | `CYLSearchBarView.expansionAnimation` | DONE |
| `CYLSearchBarView.iconPosition` | — | `CYLSearchBarView.iconPosition` | DONE |
| `CYLSearchBarView.animationDuration` | — | `CYLSearchBarView.animationDuration` | DONE |
| `CYLSearchBarView.init(frame:)` | — | constructor(context) | DONE |
| `CYLSearchBarView.init(coder:)` | — | constructor(context, attrs) (XML) | DONE |
| `CYLSearchBarView.setText(_:submit:)` | MaterialSearchView `setQuery`, lapism `setTextQuery` | `CYLSearchBarView.setText` | DONE |
| `CYLSearchBarView.submit()` | — | `CYLSearchBarView.submit` | DONE |
| `CYLSearchBarView.showKeyboard()` | — | `CYLSearchBarView.showKeyboard` | DONE |
| `CYLSearchBarView.hideKeyboard()` | — | `CYLSearchBarView.hideKeyboard` | DONE |
| `CYLSearchBarView.setIconified(_:animated:)` | — | `CYLSearchBarView.setIconified` | DONE |
| `CYLSearchBarView.encodeRestorableState(with:)` | `onSaveInstanceState` | `onSaveInstanceState()` | DONE |
| `CYLSearchBarView.decodeRestorableState(with:)` | `onRestoreInstanceState` | `onRestoreInstanceState(state)` | DONE |
| `CYLSearchBarView.traitCollectionDidChange(_:)` | — | framework override (Android recreates views on configuration changes) | N/A |
| `CYLSearchBarView.intrinsicContentSize` | — | framework override (Android: measured height, `minimumHeight`) | N/A |
| `CYLSearchBarView.sizeThatFits(_:)` | — | framework override (Android: `onMeasure`) | N/A |
| `CYLSearchBarView.layoutSubviews()` | — | framework override (Android lays out with its layout classes) | N/A |
| `CYLSearchBarView.textFieldShouldBeginEditing(_:)` | — | internal listener (UIKit protocol conformance) | N/A |
| `CYLSearchBarView.textFieldShouldReturn(_:)` | — | internal listener (UIKit protocol conformance) | N/A |
| `CYLSearchBarView.textField(_:shouldChangeCharactersIn:replacementString:)` | — | internal listener (UIKit protocol conformance) | N/A |
| `CYLSearchBarView.textFieldDidBeginEditing(_:)` | — | internal listener (UIKit protocol conformance) | N/A |
| `CYLSearchBarView.textFieldDidEndEditing(_:)` | — | internal listener (UIKit protocol conformance) | N/A |
| `CYLSearchBarView.becomeFirstResponder()` | — | `requestFocus()` | DONE |
| `CYLSearchBarView.resignFirstResponder()` | — | `clearFocus()` | DONE |
| **protocol `CYLSearchControllerDelegate`** | — | CYLSearchControllerDelegate | DONE |
| `CYLSearchControllerDelegate.-searchControllerDidCancel:` | — | `CYLSearchControllerDelegate.searchControllerDidCancel` | DONE |
| **class `CYLSearchController`** | — | CYLSearchController | DONE |
| `CYLSearchController.delegate` | — | `CYLSearchController.delegate` | DONE |
| `CYLSearchController.resultsViewController` | — | `CYLSearchController.resultsViewController` | DONE |
| `CYLSearchController.presented` | — | `CYLSearchController.isPresented` | DONE |
| `CYLSearchController.init(searchDataSource:)` | — | constructor(searchDataSource) | DONE |
| `CYLSearchController.init(nibName:bundle:)` | — | not available on iOS either (`@available(*, unavailable)`) | N/A |
| `CYLSearchController.init(coder:)` | — | no-argument constructor (fragment recreation) | DONE |
| `CYLSearchController.viewDidLoad()` | — | framework override (Android: `onViewCreated`) | N/A |
| `CYLSearchController.show(in:)` | — | `CYLSearchController.showInViewController` | DONE |
| `CYLSearchController.hide(_:)` | — | `CYLSearchController.hide` | DONE |
| **enum `CYLSearchPlaceholderKind`** | — | CYLSearchPlaceholderKind | DONE |
| `CYLSearchPlaceholderKind.empty` | — | `CYLSearchPlaceholderKind.Empty` | DONE |
| `CYLSearchPlaceholderKind.noResults` | — | `CYLSearchPlaceholderKind.NoResults` | DONE |
| `CYLSearchPlaceholderKind.error` | — | `CYLSearchPlaceholderKind.Error` | DONE |
| **enum `CYLSearchPlaceholderStyle`** | — | CYLSearchPlaceholderStyle | DONE |
| `CYLSearchPlaceholderStyle.empty` | — | `CYLSearchPlaceholderStyle.Empty` | DONE |
| `CYLSearchPlaceholderStyle.noResults` | — | `CYLSearchPlaceholderStyle.NoResults` | DONE |
| `CYLSearchPlaceholderStyle.error` | — | `CYLSearchPlaceholderStyle.Error` | DONE |
| `CYLSearchPlaceholderStyle.wifiOff` | — | `CYLSearchPlaceholderStyle.WifiOff` | DONE |
| `CYLSearchPlaceholderStyle.signalWifiOff` | — | `CYLSearchPlaceholderStyle.SignalWifiOff` | DONE |
| `CYLSearchPlaceholderStyle.noInternet` | — | `CYLSearchPlaceholderStyle.NoInternet` | DONE |
| `CYLSearchPlaceholderStyle.cloudOff` | — | `CYLSearchPlaceholderStyle.CloudOff` | DONE |
| `CYLSearchPlaceholderStyle.syncProblem` | — | `CYLSearchPlaceholderStyle.SyncProblem` | DONE |
| `CYLSearchPlaceholderStyle.syncDisabled` | — | `CYLSearchPlaceholderStyle.SyncDisabled` | DONE |
| `CYLSearchPlaceholderStyle.networkLocked` | — | `CYLSearchPlaceholderStyle.NetworkLocked` | DONE |
| `CYLSearchPlaceholderStyle.bluetoothDisabled` | — | `CYLSearchPlaceholderStyle.BluetoothDisabled` | DONE |
| `CYLSearchPlaceholderStyle.locationOff` | — | `CYLSearchPlaceholderStyle.LocationOff` | DONE |
| `CYLSearchPlaceholderStyle.publicOff` | — | `CYLSearchPlaceholderStyle.PublicOff` | DONE |
| `CYLSearchPlaceholderStyle.errorOutline` | — | `CYLSearchPlaceholderStyle.ErrorOutline` | DONE |
| `CYLSearchPlaceholderStyle.warning` | — | `CYLSearchPlaceholderStyle.Warning` | DONE |
| `CYLSearchPlaceholderStyle.reportProblem` | — | `CYLSearchPlaceholderStyle.ReportProblem` | DONE |
| `CYLSearchPlaceholderStyle.blocked` | — | `CYLSearchPlaceholderStyle.Blocked` | DONE |
| `CYLSearchPlaceholderStyle.help` | — | `CYLSearchPlaceholderStyle.Help` | DONE |
| `CYLSearchPlaceholderStyle.hourglass` | — | `CYLSearchPlaceholderStyle.Hourglass` | DONE |
| `CYLSearchPlaceholderStyle.locked` | — | `CYLSearchPlaceholderStyle.Locked` | DONE |
| `CYLSearchPlaceholderStyle.visibilityOff` | — | `CYLSearchPlaceholderStyle.VisibilityOff` | DONE |
| `CYLSearchPlaceholderStyle.searchOff` | — | `CYLSearchPlaceholderStyle.SearchOff` | DONE |
| `CYLSearchPlaceholderStyle.folderOff` | — | `CYLSearchPlaceholderStyle.FolderOff` | DONE |
| `CYLSearchPlaceholderStyle.folderOpen` | — | `CYLSearchPlaceholderStyle.FolderOpen` | DONE |
| `CYLSearchPlaceholderStyle.downloadOff` | — | `CYLSearchPlaceholderStyle.DownloadOff` | DONE |
| `CYLSearchPlaceholderStyle.uploadOff` | — | `CYLSearchPlaceholderStyle.UploadOff` | DONE |
| `CYLSearchPlaceholderStyle.inbox` | — | `CYLSearchPlaceholderStyle.Inbox` | DONE |
| `CYLSearchPlaceholderStyle.brokenImage` | — | `CYLSearchPlaceholderStyle.BrokenImage` | DONE |
| `CYLSearchPlaceholderStyle.imageUnavailable` | — | `CYLSearchPlaceholderStyle.ImageUnavailable` | DONE |
| `CYLSearchPlaceholderStyle.photoLibrary` | — | `CYLSearchPlaceholderStyle.PhotoLibrary` | DONE |
| `CYLSearchPlaceholderStyle.musicOff` | — | `CYLSearchPlaceholderStyle.MusicOff` | DONE |
| `CYLSearchPlaceholderStyle.videoOff` | — | `CYLSearchPlaceholderStyle.VideoOff` | DONE |
| `CYLSearchPlaceholderStyle.personOff` | — | `CYLSearchPlaceholderStyle.PersonOff` | DONE |
| `CYLSearchPlaceholderStyle.groupOff` | — | `CYLSearchPlaceholderStyle.GroupOff` | DONE |
| `CYLSearchPlaceholderStyle.eventBusy` | — | `CYLSearchPlaceholderStyle.EventBusy` | DONE |
| `CYLSearchPlaceholderStyle.emptyCart` | — | `CYLSearchPlaceholderStyle.EmptyCart` | DONE |
| `CYLSearchPlaceholderStyle.favorite` | — | `CYLSearchPlaceholderStyle.Favorite` | DONE |
| `CYLSearchPlaceholderStyle.batteryAlert` | — | `CYLSearchPlaceholderStyle.BatteryAlert` | DONE |
| `CYLSearchPlaceholderStyle.unknownDevice` | — | `CYLSearchPlaceholderStyle.UnknownDevice` | DONE |
| `CYLSearchPlaceholderStyle.phoneDisabled` | — | `CYLSearchPlaceholderStyle.PhoneDisabled` | DONE |
| `CYLSearchPlaceholderStyle.wrongLocation` | — | `CYLSearchPlaceholderStyle.WrongLocation` | DONE |
| `CYLSearchPlaceholderStyle.count` | — | `CYLSearchPlaceholderStyle.Count` | DONE |
| **enum `CYLSearchPlaceholderMessage`** | — | CYLSearchPlaceholderMessage | DONE |
| `CYLSearchPlaceholderMessage.empty` | — | `CYLSearchPlaceholderMessage.Empty` | DONE |
| `CYLSearchPlaceholderMessage.noResults` | — | `CYLSearchPlaceholderMessage.NoResults` | DONE |
| `CYLSearchPlaceholderMessage.error` | — | `CYLSearchPlaceholderMessage.Error` | DONE |
| `CYLSearchPlaceholderMessage.network` | — | `CYLSearchPlaceholderMessage.Network` | DONE |
| **class `CYLSearchPlaceholderView`** | — | CYLSearchPlaceholderView | DONE |
| `CYLSearchPlaceholderView.imageView` | — | `CYLSearchPlaceholderView.imageView` | DONE |
| `CYLSearchPlaceholderView.textLabel` | — | `CYLSearchPlaceholderView.textLabel` | DONE |
| `CYLSearchPlaceholderView.imageName(for:)` | — | `CYLSearchPlaceholderView.imageNameForStyle` | DONE |
| `CYLSearchPlaceholderView.init(kind:)` | — | constructor(context, kind) | DONE |
| `CYLSearchPlaceholderView.init(style:message:)` | — | constructor(context, style, message) | DONE |
| `CYLSearchPlaceholderView.init(style:text:)` | — | constructor(context, style, text) | DONE |
| `CYLSearchPlaceholderView.init(image:message:)` | — | constructor(context, image, message) | DONE |
| `CYLSearchPlaceholderView.init(image:text:)` | — | constructor(context, image, text) | DONE |
| **class `CYLSearchResources`** | — | CYLSearchResources | DONE |
| `CYLSearchResources.resourceBundle` | — | `CYLSearchResources.resourceBundle` | DONE |
| `CYLSearchResources.image(named:)` | — | `CYLSearchResources.imageNamed` | DONE |
| `CYLSearchResources.localizedString(forKey:)` | — | `CYLSearchResources.localizedString` | DONE |
| `CYLSearchResources.localizedString(forKey:language:)` | — | `CYLSearchResources.localizedString` | DONE |
| **protocol `CYLSearchResultsDataSource`** | — | CYLSearchResultsDataSource | DONE |
| `CYLSearchResultsDataSource.-searchResultsViewController:resultsForQuery:` | — | `CYLSearchResultsDataSource.searchResultsViewControllerResultsForQuery` | DONE |
| `CYLSearchResultsDataSource.-searchResultsViewController:configureCell:withResult:` | — | `CYLSearchResultsDataSource.searchResultsViewControllerConfigureCell` | DONE |
| `CYLSearchResultsDataSource.-searchResultsViewController:didSelectResult:` | — | `CYLSearchResultsDataSource.searchResultsViewControllerDidSelectResult` | DONE |
| **class `CYLSearchResultsViewController`** | — | CYLSearchResultsViewController | DONE |
| `CYLSearchResultsViewController.searchDataSource` | — | `CYLSearchResultsViewController.searchDataSource` | DONE |
| `CYLSearchResultsViewController.searchController` | — | `CYLSearchResultsViewController.searchController` | DONE |
| `CYLSearchResultsViewController.searchResults` | — | `CYLSearchResultsViewController.searchResults` | DONE |
| `CYLSearchResultsViewController.init(searchDataSource:)` | — | constructor(searchDataSource) | DONE |
| `CYLSearchResultsViewController.init(style:)` | — | not available on iOS either (`@available(*, unavailable)`) | N/A |
| `CYLSearchResultsViewController.init(nibName:bundle:)` | — | not available on iOS either (`@available(*, unavailable)`) | N/A |
| `CYLSearchResultsViewController.init(coder:)` | — | no-argument constructor (fragment recreation) | DONE |
| `CYLSearchResultsViewController.viewDidLoad()` | — | framework override (Android: `onViewCreated`) | N/A |
| `CYLSearchResultsViewController.reloadSearchResults()` | — | `CYLSearchResultsViewController.reloadSearchResults` | DONE |
| `CYLSearchResultsViewController.reloadResultsTableView()` | — | `CYLSearchResultsViewController.reloadResultsTableView` | DONE |
| `CYLSearchResultsViewController.updateSearchResults(for:)` | — | `CYLSearchResultsViewController.updateSearchResults` | DONE |
| `CYLSearchResultsViewController.tableView(_:numberOfRowsInSection:)` | — | `CYLSearchResultsViewController.tableView` | DONE |
| `CYLSearchResultsViewController.tableView(_:cellForRowAt:)` | — | `CYLSearchResultsViewController.tableView` | DONE |
| `CYLSearchResultsViewController.tableView(_:didSelectRowAt:)` | — | `CYLSearchResultsViewController.tableView` | DONE |
| **protocol `CYLSearchViewDelegate`** | — | CYLSearchViewDelegate | DONE |
| `CYLSearchViewDelegate.-searchViewDidShow:` | MaterialSearchView `onSearchViewShown` | `CYLSearchViewDelegate.searchViewDidShow` | DONE |
| `CYLSearchViewDelegate.-searchViewDidClose:` | MaterialSearchView `onSearchViewClosed` | `CYLSearchViewDelegate.searchViewDidClose` | DONE |
| `CYLSearchViewDelegate.-searchView:textDidChange:` | `onQueryTextChange` | `CYLSearchViewDelegate.searchViewTextDidChange` | DONE |
| `CYLSearchViewDelegate.-searchView:didSubmitText:` | `onQueryTextSubmit` | `CYLSearchViewDelegate.searchViewDidSubmitText` | DONE |
| `CYLSearchViewDelegate.-searchView:didChangeFocus:` | lapism `OnFocusChangeListener` | `CYLSearchViewDelegate.searchViewDidChangeFocus` | DONE |
| `CYLSearchViewDelegate.-searchView:didSelectSuggestion:atIndex:` | MaterialSearchView `setOnItemClickListener` | `CYLSearchViewDelegate.searchViewDidSelectSuggestion` | DONE |
| `CYLSearchViewDelegate.-searchViewVoiceButtonClicked:` | — | `CYLSearchViewDelegate.searchViewVoiceButtonClicked` | DONE |
| `CYLSearchViewDelegate.-searchViewNavigationButtonClicked:` | — | `CYLSearchViewDelegate.searchViewNavigationButtonClicked` | DONE |
| **class `CYLSearchView`** | MiguelCatalan and lapism `MaterialSearchView` | CYLSearchView | DONE |
| `CYLSearchView.delegate` | — | `CYLSearchView.delegate` | DONE |
| `CYLSearchView.searchBarView` | — | `CYLSearchView.searchBarView` | DONE |
| `CYLSearchView.dividerView` | — | `CYLSearchView.dividerView` | DONE |
| `CYLSearchView.suggestionsTableView` | — | `CYLSearchView.suggestionsTableView` | DONE |
| `CYLSearchView.dividerColor` | lapism `setDividerColor` | `CYLSearchView.dividerColor` | DONE |
| `CYLSearchView.contentView` | lapism `addView` | `CYLSearchView.contentView` | DONE |
| `CYLSearchView.scrimColor` | lapism `setScrimColor` | `CYLSearchView.scrimColor` | DONE |
| `CYLSearchView.suggestions` | MaterialSearchView `setSuggestions` | `CYLSearchView.suggestions` | DONE |
| `CYLSearchView.suggestionFilter` | — | `CYLSearchView.suggestionFilter` | DONE |
| `CYLSearchView.showsSuggestionsForEmptyQuery` | — | `CYLSearchView.showsSuggestionsForEmptyQuery` | DONE |
| `CYLSearchView.filteredSuggestions` | — | `CYLSearchView.filteredSuggestions` | DONE |
| `CYLSearchView.suggestionImage` | MaterialSearchView `setSuggestionIcon` | `CYLSearchView.suggestionImage` | DONE |
| `CYLSearchView.suggestionImageTintColor` | — | `CYLSearchView.suggestionImageTintColor` | DONE |
| `CYLSearchView.suggestionBackgroundColor` | `setSuggestionBackground` | `CYLSearchView.suggestionBackgroundColor` | DONE |
| `CYLSearchView.suggestionTextColor` | — | `CYLSearchView.suggestionTextColor` | DONE |
| `CYLSearchView.suggestionLineBreakMode` | MaterialSearchView `setEllipsize` | `CYLSearchView.suggestionLineBreakMode` | DONE |
| `CYLSearchView.submitsOnSuggestionSelection` | `setSubmitOnClick` | `CYLSearchView.submitsOnSuggestionSelection` | DONE |
| `CYLSearchView.suggestionCellConfiguration` | — | `CYLSearchView.suggestionCellConfiguration` | DONE |
| `CYLSearchView.searchOpen` | MaterialSearchView `isSearchOpen` | `CYLSearchView.isSearchOpen` | DONE |
| `CYLSearchView.animationDuration` | `setAnimationDuration` | `CYLSearchView.animationDuration` | DONE |
| `CYLSearchView.closesOnSubmit` | — | `CYLSearchView.closesOnSubmit` | DONE |
| `CYLSearchView.query` | lapism `getTextQuery` | `CYLSearchView.query` | DONE |
| `CYLSearchView.backgroundColor` | — | `setBackgroundColor(color)` (the page) | DONE |
| `CYLSearchView.init(frame:)` | — | constructor(context) | DONE |
| `CYLSearchView.init(coder:)` | — | constructor(context, attrs) (XML) | DONE |
| `CYLSearchView.layoutSubviews()` | — | framework override (Android lays out with its layout classes) | N/A |
| `CYLSearchView.safeAreaInsetsDidChange()` | — | framework override (Android: window insets listener) | N/A |
| `CYLSearchView.install(in:)` | — | `CYLSearchView.installInView` | DONE |
| `CYLSearchView.showSearch()` | `showSearch` | `CYLSearchView.showSearch` | DONE |
| `CYLSearchView.showSearch(animated:)` | — | `CYLSearchView.showSearch` | DONE |
| `CYLSearchView.closeSearch()` | `closeSearch` | `CYLSearchView.closeSearch` | DONE |
| `CYLSearchView.closeSearch(animated:)` | — | `CYLSearchView.closeSearch` | DONE |
| `CYLSearchView.encodeRestorableState(with:)` | `onSaveInstanceState` | `onSaveInstanceState()` | DONE |
| `CYLSearchView.decodeRestorableState(with:)` | `onRestoreInstanceState` | `onRestoreInstanceState(state)` | DONE |
| `CYLSearchView.accessibilityPerformEscape()` | — | the back key closes the search (`OnBackPressedCallback`) | DONE |
| `CYLSearchView.attach(to:)` | `setMenuItem` | `CYLSearchView.attachToMenuItem` | DONE |
| `CYLSearchView.setQuery(_:submit:)` | `setQuery`, `setTextQuery` | `CYLSearchView.setQuery` | DONE |
| `CYLSearchView.showSuggestions()` | `showSuggestions` | `CYLSearchView.showSuggestions` | DONE |
| `CYLSearchView.dismissSuggestions()` | `dismissSuggestions` | `CYLSearchView.dismissSuggestions` | DONE |
| `CYLSearchView.searchBarView(_:textDidChange:)` | — | internal listener (UIKit protocol conformance) | N/A |
| `CYLSearchView.searchBarViewSearchButtonClicked(_:)` | — | internal listener (UIKit protocol conformance) | N/A |
| `CYLSearchView.searchBarViewNavigationButtonClicked(_:)` | — | internal listener (UIKit protocol conformance) | N/A |
| `CYLSearchView.searchBarViewVoiceButtonClicked(_:)` | — | internal listener (UIKit protocol conformance) | N/A |
| `CYLSearchView.searchBarViewCancelButtonClicked(_:)` | — | internal listener (UIKit protocol conformance) | N/A |
| `CYLSearchView.searchBarViewDidBeginEditing(_:)` | — | internal listener (UIKit protocol conformance) | N/A |
| `CYLSearchView.searchBarViewDidEndEditing(_:)` | — | internal listener (UIKit protocol conformance) | N/A |
| `CYLSearchView.tableView(_:numberOfRowsInSection:)` | — | internal listener (UIKit protocol conformance) | N/A |
| `CYLSearchView.tableView(_:cellForRowAt:)` | — | internal listener (UIKit protocol conformance) | N/A |
| `CYLSearchView.tableView(_:didSelectRowAt:)` | — | internal listener (UIKit protocol conformance) | N/A |
<!-- api-alignment:end -->

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
| 2026-11-12 | iOS added `CYLSearchSuggestionStyle` and `suggestionsTagView` / `suggestionStyle` (299 rows); Android had them already | 100 |
| 2026-11-13 | iOS and Android added `showsEmptyResultsPlaceholder`, `emptyResultsScenario`, `emptyResultsView` (302 rows) | 100 |
| 2026-11-13 | iOS and Android added the suggestion cache (`CYLSearchSuggestionCachePolicy`, `CYLSearchSuggestionCache`, `CYLSearchSuggestionStore`, the cache properties of `CYLSearchView`) and `focusesSearchFieldOnShow` (323 rows; docs/core-todo.md) | 100 |
| 2026-11-17 | Regenerated: two new rows, `viewDidLayoutSubviews()` of `CYLSearchController` and `CYLSearchResultsViewController`, marked N/A as UIKit overrides (397 rows) | 100 |

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
Rows: 283; DONE 261, N/A 22, TODO 0; score 100/100.

| iOS API | Upstream counterpart (named in the iOS doc comment) | Android (`cylsearch`) | Status |
| :--- | :--- | :--- | :--- |
| **enum `CYLSearchBarMode`** | — | CYLSearchBarMode | DONE |
| `CYLSearchBarMode.single` | — | `CYLSearchBarMode.Single` | DONE |
| `CYLSearchBarMode.multiple` | iammert `MultiSearchView` | `CYLSearchBarMode.Multiple` | DONE |
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
| **enum `CYLSearchBarItemStyle`** | — | CYLSearchBarItemStyle | DONE |
| `CYLSearchBarItemStyle.icon` | — | `CYLSearchBarItemStyle.Icon` | DONE |
| `CYLSearchBarItemStyle.divider` | — | `CYLSearchBarItemStyle.Divider` | DONE |
| `CYLSearchBarItemStyle.text` | — | `CYLSearchBarItemStyle.Text` | DONE |
| **enum `CYLSearchBarStyle`** | — | CYLSearchBarStyle | DONE |
| `CYLSearchBarStyle.plain` | — | `CYLSearchBarStyle.Plain` | DONE |
| `CYLSearchBarStyle.bordered` | — | `CYLSearchBarStyle.Bordered` | DONE |
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
| `CYLSearchBarViewDelegate.-searchBarView:didSelectItem:` | — | `CYLSearchBarViewDelegate.searchBarViewDidSelectItem` | DONE |
| `CYLSearchBarViewDelegate.-searchBarView:textDidChange:atIndex:` | MultiSearchView `onTextChanged` | `CYLSearchBarViewDelegate.searchBarViewTextDidChange` | DONE |
| `CYLSearchBarViewDelegate.-searchBarView:didCompleteSearch:atIndex:` | `onSearchComplete` | `CYLSearchBarViewDelegate.searchBarViewDidCompleteSearch` | DONE |
| `CYLSearchBarViewDelegate.-searchBarView:didRemoveSearchAtIndex:` | `onSearchItemRemoved` | `CYLSearchBarViewDelegate.searchBarViewDidRemoveSearchAtIndex` | DONE |
| `CYLSearchBarViewDelegate.-searchBarView:didSelectSearch:atIndex:` | `onItemSelected` | `CYLSearchBarViewDelegate.searchBarViewDidSelectSearch` | DONE |
| **class `CYLSearchBarView`** | iammert `MultiSearchView` | CYLSearchBarView | DONE |
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
| `CYLSearchBarView.items` | like the FlatDesign tab bar's `items` | `CYLSearchBarView.items` | DONE |
| `CYLSearchBarView.itemViews` | — | `CYLSearchBarView.itemViews` | DONE |
| `CYLSearchBarView.itemTintColor` | — | `CYLSearchBarView.itemTintColor` | DONE |
| `CYLSearchBarView.searchBarStyle` | — | `CYLSearchBarView.searchBarStyle` | DONE |
| `CYLSearchBarView.fieldBackgroundImage` | — | `CYLSearchBarView.fieldBackgroundImage` | DONE |
| `CYLSearchBarView.selectedItem` | — | `CYLSearchBarView.selectedItem` | DONE |
| `CYLSearchBarView.selectedIndex` | — | `CYLSearchBarView.selectedIndex` | DONE |
| `CYLSearchBarView.addItem(_:)` | — | `CYLSearchBarView.addItem` | DONE |
| `CYLSearchBarView.insertItem(_:at:)` | clamped to `items` | `CYLSearchBarView.insertItem` | DONE |
| `CYLSearchBarView.addItem(style:title:image:index:handler:)` | — | `CYLSearchBarView.addItem` | DONE |
| `CYLSearchBarView.removeItem(_:)` | — | `CYLSearchBarView.removeItem` | DONE |
| `CYLSearchBarView.removeAllItems()` | — | `CYLSearchBarView.removeAllItems` | DONE |
| `CYLSearchBarView.hasItem(of:)` | — | `CYLSearchBarView.hasItem` | DONE |
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
| `CYLSearchBarView.mode` | `CYLSearchBarModeSingle`, the default; `CYLSearchBarModeMultiple`, iammert `MultiSearchView`; `placeholder`, `font`, `textColor`, `placeholderColor`, the keyboard options, `maximumTextLength` | `CYLSearchBarView.mode` | DONE |
| `CYLSearchBarView.searches` | — | `CYLSearchBarView.searches` | DONE |
| `CYLSearchBarView.selectedSearchIndex` | — | `CYLSearchBarView.selectedSearchIndex` | DONE |
| `CYLSearchBarView.isEditingNewSearch` | MultiSearchView `isInSearchMode` | `CYLSearchBarView.isEditingNewSearch` | DONE |
| `CYLSearchBarView.newSearchButton` | — | `CYLSearchBarView.newSearchButton` | DONE |
| `CYLSearchBarView.minimumTextLength` | — | `CYLSearchBarView.minimumTextLength` | DONE |
| `CYLSearchBarView.searchIndicatorColor` | — | `CYLSearchBarView.searchIndicatorColor` | DONE |
| `CYLSearchBarView.unselectedSearchAlpha` | — | `CYLSearchBarView.unselectedSearchAlpha` | DONE |
| `CYLSearchBarView.searchFieldWidth` | — | `CYLSearchBarView.searchFieldWidth` | DONE |
| `CYLSearchBarView.newSearchImage` | — | `CYLSearchBarView.newSearchImage` | DONE |
| `CYLSearchBarView.removeSearchImage` | — | `CYLSearchBarView.removeSearchImage` | DONE |
| `CYLSearchBarView.beginNewSearch()` | MultiSearchView `search` | `CYLSearchBarView.beginNewSearch` | DONE |
| `CYLSearchBarView.completeSearch()` | `completeSearch` | `CYLSearchBarView.completeSearch` | DONE |
| `CYLSearchBarView.addSearch(_:)` | — | `CYLSearchBarView.addSearch` | DONE |
| `CYLSearchBarView.selectSearch(at:)` | — | `CYLSearchBarView.selectSearch` | DONE |
| `CYLSearchBarView.removeSearch(at:)` | — | `CYLSearchBarView.removeSearch` | DONE |
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
| `CYLSearchBarView.tintColorDidChange()` | — | framework override (Android has no inherited tint) | N/A |
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
| **class `CYLSearchBarItem`** | — | CYLSearchBarItem | DONE |
| `CYLSearchBarItem.style` | — | `CYLSearchBarItem.style` | DONE |
| `CYLSearchBarItem.title` | — | `CYLSearchBarItem.title` | DONE |
| `CYLSearchBarItem.image` | — | `CYLSearchBarItem.image` | DONE |
| `CYLSearchBarItem.selectedImage` | — | `CYLSearchBarItem.selectedImage` | DONE |
| `CYLSearchBarItem.animatedImage` | `+[UIImage animatedImageWithImages:duration:]` | `CYLSearchBarItem.animatedImage` | DONE |
| `CYLSearchBarItem.imageSize` | — | `CYLSearchBarItem.imageSize` | DONE |
| `CYLSearchBarItem.itemAccessibilityLabel` | — | `CYLSearchBarItem.itemAccessibilityLabel` | DONE |
| `CYLSearchBarItem.itemAccessibilityIdentifier` | — | `CYLSearchBarItem.itemAccessibilityIdentifier` | DONE |
| `CYLSearchBarItem.isEnabled` | — | `CYLSearchBarItem.isEnabled` | DONE |
| `CYLSearchBarItem.isSelectable` | — | `CYLSearchBarItem.isSelectable` | DONE |
| `CYLSearchBarItem.isSelected` | drawn with `selectedImage`, `selectedBackgroundColor` and the selected title attributes | `CYLSearchBarItem.isSelected` | DONE |
| `CYLSearchBarItem.tintColor` | — | `CYLSearchBarItem.tintColor` | DONE |
| `CYLSearchBarItem.backgroundColor` | — | `CYLSearchBarItem.backgroundColor` | DONE |
| `CYLSearchBarItem.selectedBackgroundColor` | — | `CYLSearchBarItem.selectedBackgroundColor` | DONE |
| `CYLSearchBarItem.contentInsets` | — | `CYLSearchBarItem.contentInsets` | DONE |
| `CYLSearchBarItem.imagePositionAdjustment` | — | `CYLSearchBarItem.imagePositionAdjustment` | DONE |
| `CYLSearchBarItem.titlePositionAdjustment` | — | `CYLSearchBarItem.titlePositionAdjustment` | DONE |
| `CYLSearchBarItem.badgeValue` | — | `CYLSearchBarItem.badgeValue` | DONE |
| `CYLSearchBarItem.badgeColor` | — | `CYLSearchBarItem.badgeColor` | DONE |
| `CYLSearchBarItem.badgeSize` | — | `CYLSearchBarItem.badgeSize` | DONE |
| `CYLSearchBarItem.badgeContentInsets` | — | `CYLSearchBarItem.badgeContentInsets` | DONE |
| `CYLSearchBarItem.badgePositionAdjustment` | — | `CYLSearchBarItem.badgePositionAdjustment` | DONE |
| `CYLSearchBarItem.handler` | — | `CYLSearchBarItem.handler` | DONE |
| `CYLSearchBarItem.index` | — | `CYLSearchBarItem.index` | DONE |
| `CYLSearchBarItem.itemView` | — | `CYLSearchBarItem.itemView` | DONE |
| `CYLSearchBarItem.init(style:title:image:)` | — | constructor(style, title, image) | DONE |
| `CYLSearchBarItem.init(title:image:)` | — | constructor(title, image) | DONE |
| `CYLSearchBarItem.init(title:image:selectedImage:)` | — | constructor(title, image, selectedImage) | DONE |
| `CYLSearchBarItem.iconItem(image:title:handler:)` | — | `CYLSearchBarItem.iconItem` | DONE |
| `CYLSearchBarItem.textItem(title:handler:)` | — | `CYLSearchBarItem.textItem` | DONE |
| `CYLSearchBarItem.divider()` | — | `CYLSearchBarItem.divider` | DONE |
| `CYLSearchBarItem.item(dictionary:)` | `icon`, `divider`, `text`; `camera`, `mic`, `search`, `back`, else an asset or SF Symbol name | `CYLSearchBarItem.fromMap` | DONE |
| `CYLSearchBarItem.setTitleTextAttributes(_:for:)` | `UIControlStateNormal`, `UIControlStateSelected`, `UIControlStateDisabled` | `CYLSearchBarItem.setTitleTextAttributes` | DONE |
| `CYLSearchBarItem.titleTextAttributes(for:)` | — | `CYLSearchBarItem.titleTextAttributes` | DONE |
| `CYLSearchBarItem.setBadgeTextAttributes(_:for:)` | — | `CYLSearchBarItem.setBadgeTextAttributes` | DONE |
| `CYLSearchBarItem.badgeTextAttributes(for:)` | — | `CYLSearchBarItem.badgeTextAttributes` | DONE |
| `CYLSearchBarItem.actualBadgeSuperView()` | — | `CYLSearchBarItem.actualBadgeSuperView` | DONE |
| **class `CYLSearchResources`** | — | CYLSearchResources | DONE |
| `CYLSearchResources.resourceBundle` | — | `CYLSearchResources.resourceBundle` | DONE |
| `CYLSearchResources.image(named:)` | — | `CYLSearchResources.imageNamed` | DONE |
| `CYLSearchResources.localizedString(forKey:)` | — | `CYLSearchResources.localizedString` | DONE |
| `CYLSearchResources.localizedString(forKey:language:)` | — | `CYLSearchResources.localizedString` | DONE |
| **enum `CYLSearchSuggestionStyle`** | `CYLSearchView.suggestionStyle` | CYLSearchSuggestionStyle | DONE |
| `CYLSearchSuggestionStyle.list` | — | `CYLSearchSuggestionStyle.List` | DONE |
| `CYLSearchSuggestionStyle.tags` | CollectionViewClassifyMenu's `CYLTagListView` | `CYLSearchSuggestionStyle.Tags` | DONE |
| **protocol `CYLSearchViewDelegate`** | — | CYLSearchViewDelegate | DONE |
| `CYLSearchViewDelegate.-searchViewDidShow:` | MaterialSearchView `onSearchViewShown` | `CYLSearchViewDelegate.searchViewDidShow` | DONE |
| `CYLSearchViewDelegate.-searchViewDidClose:` | MaterialSearchView `onSearchViewClosed` | `CYLSearchViewDelegate.searchViewDidClose` | DONE |
| `CYLSearchViewDelegate.-searchView:textDidChange:` | `onQueryTextChange` | `CYLSearchViewDelegate.searchViewTextDidChange` | DONE |
| `CYLSearchViewDelegate.-searchView:didSubmitText:` | `onQueryTextSubmit` | `CYLSearchViewDelegate.searchViewDidSubmitText` | DONE |
| `CYLSearchViewDelegate.-searchView:didChangeFocus:` | lapism `OnFocusChangeListener` | `CYLSearchViewDelegate.searchViewDidChangeFocus` | DONE |
| `CYLSearchViewDelegate.-searchView:didSelectSuggestion:atIndex:` | MaterialSearchView `setOnItemClickListener` | `CYLSearchViewDelegate.searchViewDidSelectSuggestion` | DONE |
| `CYLSearchViewDelegate.-searchViewVoiceButtonClicked:` | — | `CYLSearchViewDelegate.searchViewVoiceButtonClicked` | DONE |
| `CYLSearchViewDelegate.-searchViewNavigationButtonClicked:` | — | `CYLSearchViewDelegate.searchViewNavigationButtonClicked` | DONE |
| `CYLSearchViewDelegate.-searchView:didSelectResult:` | was `-searchResultsViewController:didSelectResult:` | `CYLSearchViewDelegate.searchViewDidSelectResult` | DONE |
| **protocol `CYLSearchViewDataSource`** | was `CYLSearchResultsDataSource` | CYLSearchViewDataSource | DONE |
| `CYLSearchViewDataSource.-searchView:resultsForQuery:` | — | `CYLSearchViewDataSource.searchViewResultsForQuery` | DONE |
| `CYLSearchViewDataSource.-searchView:configureResultCell:withResult:` | — | `CYLSearchViewDataSource.searchViewConfigureResultCell` | DONE |
| **class `CYLSearchView`** | MiguelCatalan and lapism `MaterialSearchView`; `refreshHandler`, and the class methods for a scroll view of yours | CYLSearchView | DONE |
| `CYLSearchView.delegate` | — | `CYLSearchView.delegate` | DONE |
| `CYLSearchView.searchBarView` | — | `CYLSearchView.searchBarView` | DONE |
| `CYLSearchView.dividerView` | — | `CYLSearchView.dividerView` | DONE |
| `CYLSearchView.suggestionsTableView` | — | `CYLSearchView.suggestionsTableView` | DONE |
| `CYLSearchView.suggestionsTagView` | CollectionViewClassifyMenu's `CYLTagListView` | `CYLSearchView.suggestionsTagView` | DONE |
| `CYLSearchView.suggestionsFoldControl` | CollectionViewClassifyMenu's `CYLMenuFoldControl` | `CYLSearchView.suggestionsFoldControl` | DONE |
| `CYLSearchView.suggestionsFoldedRowCount` | — | `CYLSearchView.suggestionsFoldedRowCount` | DONE |
| `CYLSearchView.suggestionStyle` | `CYLSearchSuggestionStyleList`, the default; `CYLSearchSuggestionStyleTags` | `CYLSearchView.suggestionStyle` | DONE |
| `CYLSearchView.showsEmptyResultsPlaceholder` | — | `CYLSearchView.showsEmptyResultsPlaceholder` | DONE |
| `CYLSearchView.emptyResultsScenario` | — | `CYLSearchView.emptyResultsScenario` | DONE |
| `CYLSearchView.emptyResultsView` | CYLTableViewPlaceHolder's `CYLPlaceholderStackView` | `CYLSearchView.emptyResultsView` | DONE |
| `CYLSearchView.resultsDataSource` | was `CYLSearchController`'s and `CYLSearchResultsViewController`'s `searchDataSource` | `CYLSearchView.resultsDataSource` | DONE |
| `CYLSearchView.resultsTableView` | was `CYLSearchResultsViewController.tableView` | `CYLSearchView.resultsTableView` | DONE |
| `CYLSearchView.searchResults` | — | `CYLSearchView.searchResults` | DONE |
| `CYLSearchView.refreshHandler` | — | `CYLSearchView.refreshHandler` | DONE |
| `CYLSearchView.isRefreshing` | — | `CYLSearchView.isRefreshing` | DONE |
| `CYLSearchView.beginRefreshing()` | — | `CYLSearchView.beginRefreshing` | DONE |
| `CYLSearchView.endRefreshing()` | — | `CYLSearchView.endRefreshing` | DONE |
| `CYLSearchView.setRefreshHandler(_:)` | — | `CYLSearchView.setRefreshHandler` | DONE |
| `CYLSearchView.beginRefreshing(in:)` | — | `CYLSearchView.beginRefreshing` | DONE |
| `CYLSearchView.endRefreshing(in:)` | — | `CYLSearchView.endRefreshing` | DONE |
| `CYLSearchView.isRefreshing(in:)` | — | `CYLSearchView.isRefreshing` | DONE |
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
| `CYLSearchView.suggestionCachePolicy` | `CYLSearchSuggestionCachePolicyDatabase`, a local SQLite database, by default | `CYLSearchView.suggestionCachePolicy` | DONE |
| `CYLSearchView.suggestionCacheName` | — | `CYLSearchView.suggestionCacheName` | DONE |
| `CYLSearchView.suggestionCache` | — | `CYLSearchView.suggestionCache` | DONE |
| `CYLSearchView.suggestionCacheHeaderView` | — | `CYLSearchView.suggestionCacheHeaderView` | DONE |
| `CYLSearchView.suggestionCacheTitleLabel` | — | `CYLSearchView.suggestionCacheTitleLabel` | DONE |
| `CYLSearchView.clearSuggestionCacheButton` | — | `CYLSearchView.clearSuggestionCacheButton` | DONE |
| `CYLSearchView.showsEmptySuggestionsPlaceholder` | — | `CYLSearchView.showsEmptySuggestionsPlaceholder` | DONE |
| `CYLSearchView.emptySuggestionsScenario` | — | `CYLSearchView.emptySuggestionsScenario` | DONE |
| `CYLSearchView.emptySuggestionsView` | — | `CYLSearchView.emptySuggestionsView` | DONE |
| `CYLSearchView.focusesSearchFieldOnShow` | — | `CYLSearchView.focusesSearchFieldOnShow` | DONE |
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
| `CYLSearchView.closeSearch(animated:completion:)` | was `-[CYLSearchController hide:]` | `CYLSearchView.closeSearch` | DONE |
| `CYLSearchView.encodeRestorableState(with:)` | `onSaveInstanceState` | `onSaveInstanceState()` | DONE |
| `CYLSearchView.decodeRestorableState(with:)` | `onRestoreInstanceState` | `onRestoreInstanceState(state)` | DONE |
| `CYLSearchView.accessibilityPerformEscape()` | — | the back key closes the search (`OnBackPressedCallback`) | DONE |
| `CYLSearchView.attach(to:)` | `setMenuItem` | `CYLSearchView.attachToMenuItem` | DONE |
| `CYLSearchView.setQuery(_:submit:)` | `setQuery`, `setTextQuery` | `CYLSearchView.setQuery` | DONE |
| `CYLSearchView.showSuggestions()` | `showSuggestions` | `CYLSearchView.showSuggestions` | DONE |
| `CYLSearchView.reloadResults()` | was `reloadSearchResults` and `reloadResultsTableView` | `CYLSearchView.reloadResults` | DONE |
| `CYLSearchView.dismissSuggestions()` | `dismissSuggestions` | `CYLSearchView.dismissSuggestions` | DONE |
| `CYLSearchView.clearSuggestionCache()` | — | `CYLSearchView.clearSuggestionCache` | DONE |
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

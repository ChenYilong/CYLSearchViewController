# Search API Comparison

This document compares the public API of CYLSearchViewController with five
open-source search components (Android), one table per project, and tracks
the work to reach full parity (100/100 for each project).

## DONE (2026-11-12): match and exceed five search libraries, then port their examples

- Context: CYLSearchViewController (Objective-C, UIKit) ships
  `CYLSearchResultsViewController`, `CYLSearchController` (overlay),
  `CYLSearchBarView`, `CYLSearchPlaceholderView` and `CYLSearchResources`
  (`Sources/CYLSearchViewController/`). `master` is at `55022ba` (PR #5
  merged: CYLSearchBarView, the CYLTabBarController example, search bar
  placement rule). Work happens on `feat/search-api-parity`, created from
  `master`. The five reference projects are Android libraries:
  - https://github.com/lapism/search
  - https://github.com/MiguelCatalan/MaterialSearchView
  - https://github.com/yechaoa/MaterialDesign
  - https://github.com/android-cjj/MaterialSearchView
  - https://github.com/iammert/MultiSearchView
- Requirements:
  1. The task is mainly about the core code (`Sources/`).
  2. Read each project's code and README; add every feature we lack.
  3. Align the API: study each project's initialization style and add
     matching API next to our existing API (keep what we have).
  4. Our features must be a superset of each project's: never fewer.
  5. In `docs/`, one table per project: first column the project's public
     API, second column our API; list the match where one exists, then list
     what we are missing.
  6. A project scores 100 when every one of its APIs has a counterpart; keep
     adding API until every project is at 100.
  7. After 100: port each project's example completely to Swift and add it
     to our example.
  8. Core first: the example only passes data and style parameters in and
     implements tap handling.
- Prompt (verbatim): "注意本任务主要针对core代码修改 ：阅读该项目代码 以及readme  https://github.com/lapism/search https://github.com/MiguelCatalan/MaterialSearchView https://github.com/yechaoa/MaterialDesign https://github.com/android-cjj/MaterialSearchView https://github.com/iammert/MultiSearchView 加入我们缺失的功能。第二步对齐api ，分别学习该项目的初始化方式，新增我们原有api。保证我们得功能要比这个项目更多，绝对不能少。docs中写个表格，对上面每一个链接分别写表格，第一列为的公开api，第二列为我们的api。如果能找到对应的，就列出，最后查看我们少了什么API。如果链接中的项目 API 完全存在对应版本，那么就满分，持续更新我们的API，一直到100分 。满分后的，将每一个链接里的项目里面的example完全复刻为swift版本 加入我们的example 。优先更新core层面代码，example仅仅负责数据传入以及样式参数输入，点击事件实现。"
- Prompt (English): "Note that this task is mainly about changing the core
  code: read these projects' code and READMEs (the five links above) and add
  the features we are missing. Second step, align the API: study each
  project's initialization style and add it alongside our existing API.
  Make sure we have more features than each project, never fewer. In docs,
  write a table for each link: first column its public API, second column
  ours. List the counterpart where one exists, then see which APIs we lack.
  If every API of a linked project has a counterpart, it scores full marks;
  keep updating our API until 100. After full marks, port each project's
  example completely to Swift and add it to our example. Update the core
  first; the example only passes data and style parameters and implements
  tap handling."
- Order: this task runs before the Swift migration (`docs/swift-migration.md`), which was asked later; the
  user's rule is to work through tasks in the order they were given.
- Result: 100/100 for all five projects (tables below). Core: `CYLSearchBarView` options, `CYLSearchView`,
  `CYLMultiSearchView` (Objective-C, 0 warnings in `Sources/`). Example: Demos → "Other libraries' examples"
  holds the Swift ports of the five projects' examples (screenshots below); they pass only data, style
  parameters and taps to the core. Tests: `testSearchBarViewParityOptions`,
  `testSearchViewSuggestionsOpenAndClose`, `testMultiSearchViewFlow`, `testSwiftPortsOfOtherLibrariesLoad`;
  19/19 on Xcode 27.2, iPhone 17 simulator, iOS 26.1. Bugs found on the simulator and fixed: two magnifiers in the
  lapism bar, the cjj button not centered (new `iconPosition`), gray suggestion icons on a colored theme (new
  `suggestionImageTintColor`), and the yechaoa field losing focus when it opened. Branch
  `feat/search-api-parity`, PR #7.
- Not verified: speech recognition in the Voice sample needs a device or a simulator with a microphone; on the
  simulator used here it shows "Speech recognition is not available." as designed.

## How to read the tables

- First column: the project's public API (classes, constructors, methods, listeners, XML attributes and, for the
  two projects that ship only a sample app, the platform API the sample uses). Second column: our counterpart.
- Our types: `CYLSearchBarView` (bar), `CYLSearchView` (search page with suggestions), `CYLMultiSearchView`,
  `CYLSearchResultsViewController`, `CYLSearchController` (overlay), `CYLSearchPlaceholderView`.
- Android XML attributes map to properties: iOS views are configured in code (or Interface Builder through the
  same properties).
- Score = matched APIs / all APIs of the project × 100. Read from each project's latest commit (2026-11-12).

## lapism/search (2d55614)

Kotlin; `MaterialSearchBar`, `MaterialSearchView`, `MaterialSearchToolbar`, `NavigationIconCompat`.

| lapism/search | CYLSearchViewController |
|:---|:---|
| `MaterialSearchBar(context, attrs)` | `-[CYLSearchBarView initWithFrame:]` / `initWithCoder:` |
| `getToolbar()` | `CYLSearchBarView.fieldView` (the rounded field) |
| `setText(text)` | `CYLSearchBarView.text` |
| `setHint(hint)`, `android:hint` | `CYLSearchBarView.placeholder` |
| `setForegroundColor(colorStateList)` | `fieldBackgroundColor` |
| `setStrokeWidth(width)` | `fieldBorderWidth` |
| `setStrokeColor(colorStateList)` | `fieldBorderColor` |
| `setRadius(radius)`, `getRadius()`, `search_radius` | `fieldCornerRadius` (negative = capsule) |
| `navigationIconCompat` = `NONE` / `ARROW` / `SEARCH`, `search_navigationIconCompat` | `navigationIcon` = `CYLSearchBarNavigationIconNone` / `Arrow` / `Search` |
| `setNavigationIcon(resId / drawable)`, `search_navigationIcon` | `navigationImage` |
| `setNavigationContentDescription(...)`, `search_navigationContentDescription` | `navigationAccessibilityLabel` |
| `setNavigationOnClickListener(listener)` | `-searchBarViewNavigationButtonClicked:`, `navigationHandler` |
| `setNavigationElevation(elevation)`, `search_navigationElevation` | `navigationShadowOpacity` |
| `setNavigationBackgroundColor(color)`, `search_navigationBackgroundColor` | `navigationBackgroundColor` |
| `setOnClickListener(listener)` (the bar opens the search view) | `-searchBarViewShouldBeginEditing:` returning NO + `-searchBarViewDidTapWhileNotEditable:` |
| `ScrollingViewBehavior` (the bar scrolls away) | `navigationItem.hidesSearchBarWhenScrolling` of `CYLSearchResultsViewController` |
| margins (`search_margins*` dimensions) | `contentInsets` |
| `MaterialSearchView(context, attrs)` | `-[CYLSearchView initWithFrame:]` / `initWithCoder:` |
| `addView(child)` | `CYLSearchView.contentView` |
| `setClearIcon(drawable)`, `search_clearIcon` | `searchBarView.clearImage` |
| `setImeOptions(options)`, `android:imeOptions` | `searchBarView.returnKeyType` |
| `setInputType(type)`, `android:inputType` | `searchBarView.keyboardType`, `autocapitalizationType`, `autocorrectionType` |
| `setTextClearOnBackPressed(clear)` | `searchBarView.clearsTextOnCancel` |
| `setTextClearOnClearFocus(clear)` | `searchBarView.clearsTextOnEndEditing` |
| `getTextQuery()` | `CYLSearchView.query` |
| `setTextQuery(query, submit)` | `-setQuery:submit:` |
| `setTextTypeface(typeface)` | `searchBarView.font` |
| `setHint(hint)` | `searchBarView.placeholder` |
| `setDividerColor(color)`, `search_dividerColor` | `dividerColor` |
| `setDividerResource(resId)` | `dividerView` (style it directly: color, image view, height) |
| `setScrimColor(color)`, `search_scrimColor` | `scrimColor` |
| `setTextHintColor(color)` | `searchBarView.placeholderColor` |
| `setTextColor(color)` | `searchBarView.textColor` |
| `setBackgroundColor(color)` | `CYLSearchView.backgroundColor` |
| `setOnFocusChangeListener` → `onFocusChange(hasFocus)` | `-searchView:didChangeFocus:` |
| `setOnQueryTextListener` → `onQueryTextChange(newText)` | `-searchView:textDidChange:` |
| `setOnQueryTextListener` → `onQueryTextSubmit(query)` | `-searchView:didSubmitText:` |
| `showKeyboard()` / `hideKeyboard()` | `searchBarView.showKeyboard` / `hideKeyboard` |
| `requestFocus()` (opens) / `clearFocus()` (closes) | `-showSearch` / `-closeSearch` |
| `onSaveInstanceState()` / `onRestoreInstanceState(state)` | `-encodeRestorableStateWithCoder:` / `-decodeRestorableStateWithCoder:` (bar and search view) |
| `MaterialSearchToolbar.setText(text)` / `setHint(hint)` | `CYLSearchBarView.text` / `placeholder` |
| `MaterialSearchToolbar.setTitle` / `setSubtitle` / `setElevation` (no-ops upstream) | not needed: the bar shows its text or placeholder, as upstream |
| toolbar accessibility (hint and text read as a text field) | `textField.accessibilityLabel` ("Search") with the text as its value |

Missing: none. Score: **100/100** (before this task, estimated: 41/100; navigation button, clear icon, keyboard options,
clear-on-back/focus, the search page with divider, scrim, content view, focus listener and state restoration
were missing).

## MiguelCatalan/MaterialSearchView (53e163c)

Java; `MaterialSearchView`, `SearchAdapter`.

| MiguelCatalan/MaterialSearchView | CYLSearchViewController |
|:---|:---|
| `MaterialSearchView(context[, attrs[, defStyle]])` | `-[CYLSearchView initWithFrame:]` / `initWithCoder:` |
| `setMenuItem(menuItem)` | `-attachToBarButtonItem:` |
| `showSearch()` / `showSearch(animate)` | `-showSearch` / `-showSearchAnimated:` |
| `closeSearch()` | `-closeSearch` / `-closeSearchAnimated:` |
| `isSearchOpen()` | `isSearchOpen` |
| `setAnimationDuration(duration)` | `animationDuration` |
| `setOnQueryTextListener` → `onQueryTextSubmit(query)` (true = handled) | `-searchView:didSubmitText:` (YES = handled, stays open) |
| `setOnQueryTextListener` → `onQueryTextChange(newText)` | `-searchView:textDidChange:` |
| `setOnSearchViewListener` → `onSearchViewShown()` | `-searchViewDidShow:` |
| `setOnSearchViewListener` → `onSearchViewClosed()` | `-searchViewDidClose:` |
| `setQuery(query, submit)` | `-setQuery:submit:` |
| `setSuggestions(String[])` | `suggestions` |
| `showSuggestions()` / `dismissSuggestions()` | `-showSuggestions` / `-dismissSuggestions` |
| `setAdapter(ListAdapter)` | `suggestionCellConfiguration`, `suggestionFilter`, `suggestionsTableView` |
| `setOnItemClickListener(listener)` | `-searchView:didSelectSuggestion:atIndex:` |
| `setSubmitOnClick(submit)` | `submitsOnSuggestionSelection` |
| `setSuggestionIcon(drawable)`, `searchSuggestionIcon` | `suggestionImage`, `suggestionImageTintColor` |
| `setSuggestionBackground(drawable)`, `searchSuggestionBackground` | `suggestionBackgroundColor` |
| `setEllipsize(ellipsize)` | `suggestionLineBreakMode` |
| `setVoiceSearch(enabled)` / `showVoice(show)` | `searchBarView.showsVoiceButton` |
| `setVoiceIcon(drawable)`, `searchVoiceIcon` | `searchBarView.voiceImage` |
| `REQUEST_VOICE` + `onActivityResult` (speech result) | `-searchViewVoiceButtonClicked:` (start `SFSpeechRecognizer`), then `-setQuery:submit:` |
| `setCloseIcon(drawable)`, `searchCloseIcon` | `searchBarView.clearImage` |
| `setBackIcon(drawable)`, `searchBackIcon` | `searchBarView.navigationImage` (arrow by default) |
| `setBackground(drawable)` / `setBackgroundColor(color)`, `searchBackground` | `CYLSearchView.backgroundColor` |
| `setTextColor(color)`, `android:textColor` | `searchBarView.textColor` |
| `setHintTextColor(color)`, `android:textColorHint` | `searchBarView.placeholderColor` |
| `setHint(hint)`, `android:hint` | `searchBarView.placeholder` |
| `setInputType(type)`, `android:inputType` (`textPassword` in the sample) | `searchBarView.keyboardType`, `autocapitalizationType`, `secureTextEntry` |
| `setCursorDrawable(drawable)` | `searchBarView.cursorColor` |
| `showKeyboard(view)` / `hideKeyboard(view)` | `searchBarView.showKeyboard` / `hideKeyboard` |
| `requestFocus(...)` / `clearFocus()` | `-showSearch` / `-closeSearch` |
| `onSaveInstanceState()` / `onRestoreInstanceState(state)` (query, open state) | `-encodeRestorableStateWithCoder:` / `-decodeRestorableStateWithCoder:` |
| `onFilterComplete(count)` | `filteredSuggestions.count` after each change |
| `SearchAdapter(context, suggestions[, icon, ellipsize])` | `suggestions`, `suggestionImage`, `suggestionLineBreakMode` |
| `SearchAdapter.getFilter()` | `suggestionFilter` (default: case- and diacritic-insensitive contains) |
| `SearchAdapter.getCount()` / `getItem(i)` / `getItemId(i)` | `filteredSuggestions.count` / `filteredSuggestions[i]` / the index |
| `SearchAdapter.getView(...)` | `suggestionCellConfiguration` |

Missing: none. Score: **100/100** (before, estimated: 22/100; the whole search page, suggestions and voice were missing).

## yechaoa/MaterialDesign (2d6ac57)

A Material Design showcase app. Its search screen (`SearchViewActivity`) uses `androidx.appcompat.widget.SearchView`;
the table lists the API it uses.

| yechaoa/MaterialDesign (`SearchView`) | CYLSearchViewController |
|:---|:---|
| menu item with `actionViewClass="SearchView"` | `CYLSearchBarView` as `navigationItem.titleView`, or `CYLSearchView` + `-attachToBarButtonItem:` |
| `setIconifiedByDefault(true)` | `CYLSearchBarView.iconifiedByDefault` |
| `isIconified = true` | `iconified`, `-setIconified:animated:` |
| `isSubmitButtonEnabled = true` | `showsSubmitButton`, `submitButton`, `submitImage` |
| `imeOptions = IME_ACTION_SEARCH` | `returnKeyType` |
| `isFocusable` + `requestFocusFromTouch()` | `-showKeyboard` |
| `queryHint = "…"` | `placeholder` |
| search text `setHintTextColor(color)` | `placeholderColor` |
| search text `setTextColor(color)` | `textColor` |
| `setOnQueryTextListener` → `onQueryTextSubmit(query)` | `-searchBarViewSearchButtonClicked:` (with `-searchBarView:shouldSubmitText:`) |
| `setOnQueryTextListener` → `onQueryTextChange(newText)` | `-searchBarView:textDidChange:` |
| clearing the result when the text is empty | `textDidChange` with `@""`; `CYLSearchPlaceholderView` for the empty state |

Missing: none. Score: **100/100** (before, estimated: 58/100; iconified state and submit button were missing).

## android-cjj/MaterialSearchView (298db81)

A sample app (no library): a floating button opens a search card with a circular reveal, the magnifier slides to
the end of the card, and a tap on it closes the card again.

| android-cjj/MaterialSearchView (sample) | CYLSearchViewController |
|:---|:---|
| `FloatingActionButton` that opens the search | `CYLSearchBarView.iconButton` while `iconified` |
| `layout_gravity="center"` of the button | `iconPosition = CYLSearchBarIconPositionCenter` |
| `ViewAnimationUtils.createCircularReveal(card, …)` | `expansionAnimation = CYLSearchBarExpansionAnimationCircularReveal` |
| `mAnimator.reverse()` (close the card) | `-setIconified:YES animated:YES` |
| `setDuration(1000)` | `animationDuration` |
| `AccelerateDecelerateInterpolator` | ease-in-ease-out timing of the reveal |
| magnifier translation across the card | the icon fades into the field's magnifier (`searchIconView`) |
| `CardView` `cardBackgroundColor` | `fieldBackgroundColor` |
| `CardView` `cardCornerRadius` | `fieldCornerRadius` |
| `EditText` `hint` | `placeholder` |
| `EditText` `textColor` | `textColor` |
| `EditText` `singleLine` | `UITextField` is single-line |
| open / close state | `iconified`, `-searchBarView:didChangeIconified:` |

Missing: none. Score: **100/100** (before, estimated: 33/100; the iconified state and the reveal were missing).

## iammert/MultiSearchView (b37f248)

Kotlin; `MultiSearchView`, `MultiSearchContainerView`, `searchTextStyle`.

| iammert/MultiSearchView | CYLSearchViewController |
|:---|:---|
| `MultiSearchView(context, attrs)` | `-[CYLMultiSearchView initWithFrame:]` / `initWithCoder:` |
| `setSearchViewListener(listener)` | `delegate` |
| `onTextChanged(index, s)` | `-multiSearchView:textDidChange:atIndex:` |
| `onSearchComplete(index, s)` | `-multiSearchView:didCompleteSearch:atIndex:` |
| `onSearchItemRemoved(index)` | `-multiSearchView:didRemoveItemAtIndex:` |
| `onItemSelected(index, s)` | `-multiSearchView:didSelectItem:atIndex:` |
| `search()` | `-search` |
| `completeSearch()` (drops a search shorter than 3 characters) | `-completeSearch`, `minimumTextLength` (3) |
| `isInSearchMode()` | `isInSearchMode` |
| search icon (start / complete) | `searchButton`, `searchImage` |
| remove icon on the selected item | the item's remove button, `removeImage`, `-removeItemAtIndex:` |
| indicator under the selected item | indicator, `indicatorColor` |
| unselected items at half opacity | `unselectedItemAlpha` (0.5) |
| `searchTextStyle`: `android:hint` | `placeholder` |
| `searchTextStyle`: `android:textSize` | `font` |
| `searchTextStyle`: `android:textColor` | `textColor` |
| `searchTextStyle`: `android:textColorHint` | `placeholderColor` |
| `searchTextStyle`: `android:maxLength` | `maximumTextLength` |
| `searchTextStyle`: `android:imeOptions` | `returnKeyType` |
| `searchTextStyle`: `android:inputType` | `keyboardType`, `autocapitalizationType` |
| item width (`msv_size_*` dimensions) | `searchFieldWidth` |

Missing: none. Score: **100/100** (before, estimated: 0/100; there was no multi-search view).

## What we have that none of them has

`CYLSearchResultsViewController` (results driven by a data source, pull to refresh, placeholders),
`CYLSearchPlaceholderView` (45 placeholder styles, localized messages), trailing accessory views and a leading view
in the field, a localized Cancel button, Dynamic Type with a growing field, the large content viewer, VoiceOver
labels for every button and item, localized strings in four languages, and `-searchBarView:shouldSubmitText:`.

## Scores

| Project | Before (estimate) | Now |
|:---|---:|---:|
| lapism/search | 41 | 100 |
| MiguelCatalan/MaterialSearchView | 22 | 100 |
| yechaoa/MaterialDesign | 58 | 100 |
| android-cjj/MaterialSearchView | 33 | 100 |
| iammert/MultiSearchView | 0 | 100 |

## Screenshots of the Swift ports

One state per row, top to bottom. Platform iOS; host macOS 27.3 (26C5035r), Xcode 27.2 (27B52); iPhone 17
simulator, iOS 26.1, English; iOS SDK 27.2; repository
[`63825b0`](https://github.com/ChenYilong/CYLSearchViewController/commit/63825b0) on `feat/search-api-parity`
(Objective-C core); taken 2026-11-12 (NZDT; the exact time was not recorded).

| State | Screenshot |
|:---|:---|
| lapism/search: the bar over the list (magnifier navigation icon, hint) | ![lapism bar](assets/port-lapism-bar.png) |
| lapism/search: the search view with the filtered list ("1") | ![lapism search](assets/port-lapism-search.png) |
| MaterialSearchView Default: suggestions for "A", one line each | ![default](assets/port-materialsearchview-default.png) |
| MaterialSearchView Default: "Query: A" after submitting | ![query](assets/port-materialsearchview-query.png) |
| MaterialSearchView Themed: white text on the primary color | ![themed](assets/port-materialsearchview-themed.png) |
| MaterialSearchView Voice: the microphone in the empty field | ![voice](assets/port-materialsearchview-voice.png) |
| MaterialSearchView Tabs: three pages under tabs | ![tabs](assets/port-materialsearchview-tabs.png) |
| MaterialSearchView Input type: password input | ![input type](assets/port-materialsearchview-inputtype.png) |
| yechaoa SearchView: iconified in the toolbar | ![iconified](assets/port-yechaoa-iconified.png) |
| yechaoa SearchView: open, submit button, snackbar and result | ![submitted](assets/port-yechaoa-submitted.png) |
| android-cjj: the round button in the middle | ![button](assets/port-cjj-button.png) |
| android-cjj: the card after the circular reveal | ![card](assets/port-cjj-card.png) |
| iammert MultiSearchView: two searches and the event log | ![multi search](assets/port-multisearchview.png) |

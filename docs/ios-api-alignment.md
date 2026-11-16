# iOS API Alignment (Android core → iOS)

The reverse of [android-api-alignment.md](android-api-alignment.md): every public API and feature of the Android core
(the code published to Maven / Gradle: `android/merged/cylsearch`, and the Android libraries of the sub-repositories
this project ships with, such as CollectionViewClassifyMenu's tag views) next to its iOS counterpart.

## IN PROGRESS (TODO 2026-11-17): Android core → iOS table, score to 100, then iOS → Android

- Prompt (verbatim): "找到下面描述中相关的文档，如果没有就新建，如果有就插入：将iOS端与Android的core核心代码，制作一个表格，第一列为Android 端core核心代码的API以及功能列表，第二列为功能描述，第三列为iOS端对应的api或者功能。第三列默认为TODO。制作评分系统，第三列没有TODO 为满分，全部是TODO为0分。制作表格完成后，第一步 寻找iOS端对应的api和功能。第二：打分。第三步：开始实现iOS端没有的功能。和api。第三步：更新iOS端example 使用新增api 和功能，复刻Android的对应的example。我举例说明：android端有一个拖拽tag 的功能，以及诸多API。iOS端则完全没有。你需要标记todo，然后先实现core核心代码，然后复刻example。第二个例子，第一个的例子中其中的tag 结构比iOS端丰富。左侧为icon中间为title，右侧为总是固定保留的删除icon。iOS端缺少删除icon。你应该首选修改core核心代码，将iOS端的封装好的icon加title的组合再merge进android的逻辑，新增删除icon。并支持点击事件 允许拖拽事件。并保持iOS端与android的核心空间代码逻辑一致，API一致。并且taglist也应展示删除tag的演示。删除后更新list数据源后展示是否重新布局。100分后，再制作一个表格格式类似，第一列为iOS端api与功能，第二列描述，第三列为android端的对应，默认TODO，制作评分系统. 找到下面描述中相关的文档，如果没有就新建，如果有就插入：全英文写入：制作一个表格，第一列为，第二列为功能描述，第三列为 对应的api或者功能。第三列默认为TODO。制作评分系统，第三列没有TODO 为满分，全部是TODO为0分。制作表格以及评分系统完成后，第一步 尝试搜索现有代码，尝试匹配TODO项，寻找对应的api和功能。第二：打分。第三：。开始逐一处理TODO。并更新TODO为对应实现。第四步骤：打分。如此循环往复一直到满分为止。同样优先更新核心组件，使用example展示用法。"
- Prompt (English): "Find the related documents (create one if none) and insert: a table of the iOS and Android core
  code. Column 1: the Android core APIs and features; column 2: what each does; column 3: the iOS counterpart, `TODO`
  by default. Scoring: no `TODO` in column 3 is 100, all `TODO` is 0. Then (1) find the iOS counterparts, (2) score,
  (3) implement on iOS what it lacks, (4) update the iOS example to use the new APIs, copying the Android example.
  Example 1: Android has tag dragging and many APIs; iOS has none: mark TODO, implement the core first, then copy the
  example. Example 2: the Android tag is richer: icon on the left, title in the middle, an always-present delete icon on
  the right; iOS lacks the delete icon. Change the core first: merge iOS's icon + title tag into the Android logic, add
  the delete icon, support tap and drag, keep the iOS and Android core logic and API the same, and show tag deletion in
  the tag list demo (after deleting, update the data source and show the relayout). After 100, make the reverse table
  (column 1 iOS APIs, column 2 description, column 3 Android counterpart, `TODO` by default) with its score. Write the
  general process in English into the related documents: a table (column 1 an API or feature, column 2 its
  description, column 3 the counterpart, `TODO` by default), scored (no `TODO` = 100, all `TODO` = 0); then search the
  code to match the `TODO` rows, score, resolve the `TODO` rows one by one (each becomes its implementation), score,
  and repeat until 100. Core components first; examples show the usage."
- Rule written: `AGENTS.md`, "API parity tables"; skill `cyl-api-parity`.
- Status (2026-11-17, second pass): step 1 (match existing code) and step 2 (score) done again: 99 (923 of 924).
  - Section A (this repository's core): 100. The 27 `TODO` rows were Android stand-ins for UIKit types
    (`CYLSearchBarItemState` → `UIControl.State`, `CYLTextAutocapitalizationType` → `UITextAutocapitalizationType`,
    `CYLLineBreakMode` → `NSLineBreakMode`, `fontSize` → `UIFont.pointSize`, …) that the iOS API already takes, plus
    two cache policy cases the matcher missed (Kotlin `UserDefaults` vs Swift `userDefaults`). No iOS code was
    missing.
  - Section B (CollectionViewClassifyMenu): 99. Measured at that repository's newest commit (`41aec0d`,
    `feat/harmony`), where its iOS core became Swift and reached its own Android → iOS parity
    (`docs/android-ios-api.md` there, 611 / 611). The generator now reads that table, then `MANUAL` for the Swift
    renames of the selectors (`deleteItemAtIndexPath` → `deleteItem(at:)`, `scrollToSection` →
    `scroll(toSection:animated:)`, …).
  - The reverse table ([android-api-alignment.md](android-api-alignment.md)) is still 100: the two new rows,
    `viewDidLayoutSubviews()` of `CYLSearchController` and `CYLSearchResultsViewController`, are UIKit overrides
    (N/A), like `viewDidLoad()`.

### TODO

- Status (2026-11-17, third pass): 99 (917 of 924); A 100, B 98. The generator now checks every bare name it takes
  from the sub-repository's table against the iOS sources it measures (`existsInIOS`): that table lags behind its own
  Swift migration. 38 of its names were missing: 23 lived in `TagCollectionView/` (now searched), 9 are Swift
  replacements now in `MANUAL` (`CYLMenuColorFromString` → `UIColor.cylMenuColor(from:)`, `CYLTagHeightForFont` →
  `CYLTagMetrics.tagHeight(for:minimumHeight:)`, `CYLMenuAnimationURLWithOptions` →
  `URL.cylAddingAnimationOptions(_:)`, `filterParamsArray` → `CYLMultipleFilterController.selectedIndexPaths()`, …),
  and 6 were removed from iOS (below). Rows matched only by name were reviewed (114): 2 were wrong
  (`CYLSearchSuggestionCell.imageView` / `textLabel` had matched `CYLSearchPlaceholderView`) and now name the
  suggestion row's `UIListContentConfiguration.image` / `.text`. Cells with prose are no longer wrapped in backticks.
- DONE (generator review): see the third pass above.
- TODO (blocked: no push access to CollectionViewClassifyMenu from this session; two attempts denied): the
  multiple filter's state object. Android `CYLFilterParamsTool` (`dataSources`, `filterParamsDictionary`,
  `filterParamsContentDictionary`, `filename`: titles, settings with a modified flag, free-form content, saved to a
  file) and `CYLFilterBaseController.settingArray` have no iOS counterpart since the sub-repository's Swift migration
  step 5 (`70dcc816`), which removed `CYLFilterParamsTool` and keeps the titles and selection private in
  `CYLMultipleFilterController`. Either bring the state object back on iOS with the Android names (core first,
  then the filter example), or remove it from Android; decide in that repository, then pin and regenerate. Its own
  table still claims these rows (611 / 611): fix its generator to check names against the Swift sources.
- TODO (blocked, same reason): `CYLTag.resetColors()` is missing
  on iOS. Android: `fun resetColors() { colors = CYLTagColors() }` (`CYLTag.kt:85`), all four colors back to the
  list's. iOS today: `tag.colors = CYLTagColors()` does the same, without the method. Add to
  `CollectionViewClassifyMenu/Class/TagList/CYLTag.swift`, with a `/** … */` comment:
  `public func resetColors() { colors = CYLTagColors() }`. Then pin that commit here and rerun
  `node android/merged/scripts/ios-alignment.mjs` (score 100). No example on any platform calls it, so no example
  change is needed. That repository's own table missed the row too (its generator did not list `CYLTag.resetColors`
  or `CYLTagListView.scrollToSection`); fix its generator in the same change.
- TODO (pin): this repository still pins CollectionViewClassifyMenu `f972416` (2026-11-12, Objective-C iOS core) in
  `Podfile` and `android/merged/gradle.properties`; the table measures `41aec0d` (newest, Swift iOS core). The rule
  "Sub-repositories" asks for the newest commit. Details of the bump in the next item.
- TODO (pin, found 2026-11-17): bumping the pin is a breaking change for this repository. At `41aec0d` the fold
  position `inline` is renamed `tail` (iOS `.tail`, Objective-C `CYLMenuFoldControlPositionTail`, Android `TAIL`;
  sub-repository `e0129e8`, no alias), and the Objective-C factory `+foldControlWithPosition:content:` became
  `init(position:content:)`. Call sites to change with the bump: `Sources/CYLSearchViewController/CYLSearchView.swift`
  (`suggestionsTagView`), `CYLSearchExample/CYLMaterialSearchMenuViewController.swift`,
  `CYLSearchExample/CYLSearchDiscoverViewController.swift`, `CYLSearchExampleTests/CYLSearchExampleTests.m`,
  `android/merged/cylsearch/.../CYLSearchView.kt` and its test, `android/merged/app/.../CYLSuggestionStyleFragment.kt`
  and `CYLSearchDiscoverFragment.kt`, the React Native wrapper (`CYLRNSearchSupport.h`, `CylsearchSupport.kt`, and the
  `"inline"` string of its prop) and the Flutter plugin (`FlutterCylsearchPlugin.swift` / `.kt`), plus the pins in
  `Podfile`, `android/merged/gradle.properties` and the React Native and Flutter example Podfiles. Every other
  CollectionViewClassifyMenu API this repository's iOS core and example call was checked at `41aec0d` and exists with
  the same Swift names and signatures (`CYLMenuDelegate`, `CYLMenuDataSource`, `CYLMenuStyle`, `CYLTagAppearance`).
  Not done here: CI builds only iOS, the Android SDK host is blocked by this session's network proxy, and React
  Native and Flutter have no CI; a blind change to four platforms needs the maintainer's go-ahead.
- TODO (pin, blocker found 2026-11-17, after the go-ahead): the bump cannot be finished without a change in
  CollectionViewClassifyMenu. At `41aec0d` its Swift `CYLTagListView` no longer exposes most members to
  Objective-C (`showsSectionHeaders`, `menuDelegate`, `style`, `tagClickHandler`, `foldControl`,
  `setTags(withTitles:colors:)`, `heightThatFitsWidth(_:)` have no `@objc`; only `init(foldControl:)` and
  `defaultVisibleRows` do), `CYLTag` is a pure Swift class (not an `NSObject`), and the pod ships no headers (import
  `CollectionViewClassifyMenu-Swift.h`, not `-umbrella.h`). The React Native iOS wrapper
  (`CrossPlatform/react-native-cylsearch/ios/CylsearchTagListView.mm`, `CYLRNSearchSupport.h`, Objective-C++, as
  Fabric requires) calls all of them, and its example compiles this repository's `Sources/` too, so iOS cannot move
  without it. Core-first fix: in CollectionViewClassifyMenu, mark those members `@objc` and give `tagClickHandler` an
  Objective-C-compatible tag type (or make `CYLTag` an `NSObject`); then pin, apply
  [patches/classifymenu-41aec0d-fold-position-rename.patch](patches/classifymenu-41aec0d-fold-position-rename.patch)
  (the `inline` → `tail` rename on iOS, Android, React Native Android, Flutter iOS and Android; the plugins keep
  their `"inline"` / `"bottom"` strings and also accept the new names), update the React Native iOS mapping
  (`CYLMenuFoldControlPositionTail`… and `-initWithPosition:content:` in place of `+foldControlWithPosition:content:`),
  bump every pin (`Podfile`, `android/merged/gradle.properties`, both CrossPlatform example Podfiles), and build iOS,
  Android, React Native and Flutter. Fallback without the sub-repository: a Swift `@objc` adapter for
  `CYLTagListView` inside the React Native package (its core, npm), called from the `.mm` files. The patch was
  checked to apply (`git apply --check`); none of it was compiled (no Xcode, no Android SDK here).

## Score log

Score = rows whose iOS column is not `TODO` / rows × 100 (no `TODO` = 100, all `TODO` = 0).

| Date | Step | Score |
| :--- | :--- | :--- |
| 2026-11-17 | Table generated; iOS counterparts matched from the iOS-to-Android table and by name | 82 (760 of 917) |
| 2026-11-17 | Regenerated against CollectionViewClassifyMenu's newest commit `41aec0d` (Swift iOS core, more rows; name matching found fewer) | 72 (668 of 924) |
| 2026-11-17 | Step 1: the sub-repository's own Android → iOS table read for section B | 94 (875 of 924) |
| 2026-11-17 | Step 1: `MANUAL` map (UIKit types for the Android stand-ins, Swift selector renames) and case-insensitive enum cases; A 100, B 99 | 99 (923 of 924) |
| 2026-11-17 | Review: sub-repository table names checked against the Swift sources (38 missing, 15 after adding `TagCollectionView/`) | 98 (908 of 924) |
| 2026-11-17 | Step 3: 9 Swift replacements mapped; 2 wrong name matches corrected; 7 rows left that need the sub-repository | 99 (917 of 924) |

## Table

<!-- ios-alignment:begin -->
Rows: 924; matched 917, TODO 7; score 99/100 (generated by `android/merged/scripts/ios-alignment.mjs`).

### A. CYLSearchViewController: `android/merged/cylsearch` → `Sources/CYLSearchViewController`

Rows: 320; matched 320, TODO 0; score 100/100.

| Android API or feature | Description | iOS counterpart |
| :--- | :--- | :--- |
| **interface `CYLMultiSearchViewDelegate`** | Events of a `CYLMultiSearchView` (iammert `MultiSearchViewListener`). | **protocol `CYLMultiSearchViewDelegate`** |
| `CYLMultiSearchViewDelegate.multiSearchViewTextDidChange` | The text of the search being typed changed (`onTextChanged`). | `CYLMultiSearchViewDelegate.-multiSearchView:textDidChange:atIndex:` |
| `CYLMultiSearchViewDelegate.multiSearchViewDidCompleteSearch` | A search was completed and became an item (`onSearchComplete`). | `CYLMultiSearchViewDelegate.-multiSearchView:didCompleteSearch:atIndex:` |
| `CYLMultiSearchViewDelegate.multiSearchViewDidRemoveItemAtIndex` | An item was removed (`onSearchItemRemoved`). | `CYLMultiSearchViewDelegate.-multiSearchView:didRemoveItemAtIndex:` |
| `CYLMultiSearchViewDelegate.multiSearchViewDidSelectItem` | An item was selected by a tap (`onItemSelected`). | `CYLMultiSearchViewDelegate.-multiSearchView:didSelectItem:atIndex:` |
| **class `CYLMultiSearchView`** | Several searches side by side (iOS `CYLMultiSearchView`, iammert `MultiSearchView`): the search button starts a new search; a completed search becomes an item in a horizontally scr | **class `CYLMultiSearchView`** |
| `CYLMultiSearchView.delegate` | Receives the events. | `CYLMultiSearchView.delegate` |
| `CYLMultiSearchView.selectedIndex` | The selected item, or -1 (iOS `NSNotFound`) when there is none. | `CYLMultiSearchView.selectedIndex` |
| `CYLMultiSearchView.isInSearchMode` | True while a new search is being typed (`isInSearchMode`). | `CYLMultiSearchView.inSearchMode` |
| `CYLMultiSearchView.searchButton` | The button at the end: it starts a search, or completes the one being typed. | `CYLMultiSearchView.searchButton` |
| `CYLMultiSearchView.placeholder` | The placeholder of a new search (`android:hint`). | `CYLMultiSearchView.placeholder` |
| `CYLMultiSearchView.font` | The typeface of the items (`android:textStyle`). | `CYLMultiSearchView.font` |
| `CYLMultiSearchView.fontSize` | The text size in sp (`android:textSize`). | `CYLMultiSearchView.font` (`UIFont.pointSize`) |
| `CYLMultiSearchView.textColor` | The text color (`android:textColor`). | `CYLMultiSearchView.textColor` |
| `CYLMultiSearchView.placeholderColor` | The placeholder color (`android:textColorHint`). | `CYLMultiSearchView.placeholderColor` |
| `CYLMultiSearchView.maximumTextLength` | The longest search a person can type (`android:maxLength`); 0 means no limit. | `CYLMultiSearchView.maximumTextLength` |
| `CYLMultiSearchView.minimumTextLength` | A search shorter than this is dropped when it is completed. | `CYLMultiSearchView.minimumTextLength` |
| `CYLMultiSearchView.returnKeyType` | The action key (`android:imeOptions`). | `CYLMultiSearchView.returnKeyType` |
| `CYLMultiSearchView.keyboardType` | The keyboard (`android:inputType` class). | `CYLMultiSearchView.keyboardType` |
| `CYLMultiSearchView.autocapitalizationType` | Capitalization (`textCapSentences`). | `CYLMultiSearchView.autocapitalizationType` |
| `CYLMultiSearchView.indicatorColor` | The color of the indicator under the selected item and of the buttons. | `CYLMultiSearchView.indicatorColor` |
| `CYLMultiSearchView.unselectedItemAlpha` | The opacity of items that are not selected. | `CYLMultiSearchView.unselectedItemAlpha` |
| `CYLMultiSearchView.searchFieldWidth` | The width of the field for a new search, in dp. | `CYLMultiSearchView.searchFieldWidth` |
| `CYLMultiSearchView.animationDuration` | The length of the animations, in seconds. | `CYLMultiSearchView.animationDuration` |
| `CYLMultiSearchView.searchImage` | The search button's icon. | `CYLMultiSearchView.searchImage` |
| `CYLMultiSearchView.removeImage` | The remove button's icon. | `CYLMultiSearchView.removeImage` |
| `CYLMultiSearchView.searchTexts` | The texts of the items, completed searches first, then the one being typed. | `CYLMultiSearchView.searchTexts` |
| `CYLMultiSearchView.search` | Starts a new search and shows the keyboard (`search`). | `CYLMultiSearchView.search()` |
| `CYLMultiSearchView.completeSearch` | Completes the search being typed (`completeSearch`): it becomes the selected item, or is dropped when shorter than `minimumTextLength`. | `CYLMultiSearchView.completeSearch()` |
| `CYLMultiSearchView.addSearchText` | Adds a completed search without typing it and selects it. | `CYLMultiSearchView.addSearchText(_:)` |
| `CYLMultiSearchView.selectItemAtIndex` | Selects an item, like a tap on it. | `CYLMultiSearchView.selectItem(at:)` |
| `CYLMultiSearchView.removeItemAtIndex` | Removes an item, like a tap on its remove button. | `CYLMultiSearchView.removeItem(at:)` |
| **enum `CYLSearchBarItemStyle`** | How an item appended to a search bar looks (iOS `CYLSearchBarItemStyle`). | **enum `CYLSearchBarItemStyle`** |
| `CYLSearchBarItemStyle.Icon` | An icon button with a 36 dp touch area (a camera, a filter). | `CYLSearchBarItemStyle.icon` |
| `CYLSearchBarItemStyle.Divider` | A thin vertical line between two items; it takes no taps and TalkBack skips it. | `CYLSearchBarItemStyle.divider` |
| `CYLSearchBarItemStyle.Text` | A text button (a "Search" button); an image, when set, comes before the title. | `CYLSearchBarItemStyle.text` |
| **enum `CYLSearchBarStyle`** | The fixed look of the whole bar (iOS `CYLSearchBarStyle`): the field stays, the items are appended after its text. | **enum `CYLSearchBarStyle`** |
| `CYLSearchBarStyle.Plain` | The field as configured by its own properties (the default; nothing is changed). | `CYLSearchBarStyle.plain` |
| `CYLSearchBarStyle.Bordered` | A capsule with a 1 dp outline on the surface color, the field and its items inside one outline. | `CYLSearchBarStyle.bordered` |
| **enum `CYLSearchBarItemState`** | The item states for text attributes (iOS `UIControlState`). | `UIControl.State` (`CYLSearchBarItem.setTitleTextAttributes(_:for:)`; Android stand-in) |
| `CYLSearchBarItemState.Normal` | Enabled and not selected. | `UIControl.State.normal` |
| `CYLSearchBarItemState.Selected` | Selected (`isSelected`). | `UIControl.State.selected` |
| `CYLSearchBarItemState.Disabled` | Disabled (`isEnabled` false). | `UIControl.State.disabled` |
| **class `CYLSearchBarItemTextAttributes`** | Title or badge text attributes (iOS `NSAttributedString` attributes): a color in ARGB, a size in sp, a typeface. | `[NSAttributedString.Key: Any]` (`CYLSearchBarItem.setTitleTextAttributes(_:for:)`, `setBadgeTextAttributes(_:for:)`; Android stand-in) |
| **class `CYLSearchBarItem`** | One element after the text of a `CYLSearchBarView`: a model independent of its view (iOS `CYLSearchBarItem`, like `CYLFlatDesignTabBarItem`). | **class `CYLSearchBarItem`** |
| **class `CYLSearchBarItemView`** | The view of a `CYLSearchBarItem` (iOS `CYLSearchBarItemView`, like `CYLFlatDesignTabBarButton`). | **class `CYLSearchBarItemView`** |
| `CYLSearchBarItemView.item` | The item this view draws. | `CYLSearchBarItemView.item` |
| `CYLSearchBarItemView.imageView` | The icon. | `CYLSearchBarItemView.imageView` |
| `CYLSearchBarItemView.titleLabel` | The title of a text item. | `CYLSearchBarItemView.titleLabel` |
| `CYLSearchBarItemView.badgeLabel` | The badge (`badgeValue`). | `CYLSearchBarItemView.badgeLabel` |
| `CYLSearchBarItemView.actualBadgeSuperView` | The view the badge is drawn in (this view). | `CYLSearchBarItemView.actualBadgeSuperView()` |
| **enum `CYLSearchBarNavigationIcon`** | The icon of the navigation button before the field (lapism `NavigationIconCompat`). | **enum `CYLSearchBarNavigationIcon`** |
| `CYLSearchBarNavigationIcon.None` | No navigation button. | `CYLSearchBarNavigationIcon.none` |
| `CYLSearchBarNavigationIcon.Arrow` | A back arrow. | `CYLSearchBarNavigationIcon.arrow` |
| `CYLSearchBarNavigationIcon.Search` | A magnifier. | `CYLSearchBarNavigationIcon.search` |
| **enum `CYLSearchBarIconPosition`** | Where the search button sits while the bar is iconified. | **enum `CYLSearchBarIconPosition`** |
| `CYLSearchBarIconPosition.Trailing` | At the end, like an Android `SearchView` in a toolbar. | `CYLSearchBarIconPosition.trailing` |
| `CYLSearchBarIconPosition.Center` | In the middle, like a floating action button that opens a search card. | `CYLSearchBarIconPosition.center` |
| `CYLSearchBarIconPosition.Leading` | At the start. | `CYLSearchBarIconPosition.leading` |
| **enum `CYLSearchBarExpansionAnimation`** | How the field opens and closes when `iconified` changes with animation. | **enum `CYLSearchBarExpansionAnimation`** |
| `CYLSearchBarExpansionAnimation.Fade` | The field grows from the icon and fades in. | `CYLSearchBarExpansionAnimation.fade` |
| `CYLSearchBarExpansionAnimation.CircularReveal` | A circle grows from the icon until it uncovers the whole field (Material circular reveal). | `CYLSearchBarExpansionAnimation.circularReveal` |
| **enum `CYLTextAutocapitalizationType`** | Automatic capitalization of the typed text (iOS `UITextAutocapitalizationType`). | `UITextAutocapitalizationType` (`CYLSearchBarView.autocapitalizationType`, `CYLMultiSearchView.autocapitalizationType`; Android stand-in) |
| `CYLTextAutocapitalizationType.None` | No automatic capitalization. | `UITextAutocapitalizationType.none` |
| `CYLTextAutocapitalizationType.Words` | The first letter of each word. | `UITextAutocapitalizationType.words` |
| `CYLTextAutocapitalizationType.Sentences` | The first letter of each sentence. | `UITextAutocapitalizationType.sentences` |
| `CYLTextAutocapitalizationType.AllCharacters` | Every character. | `UITextAutocapitalizationType.allCharacters` |
| **enum `CYLTextAutocorrectionType`** | Automatic correction of the typed text (iOS `UITextAutocorrectionType`). | `UITextAutocorrectionType` (`CYLSearchBarView.autocorrectionType`; Android stand-in) |
| `CYLTextAutocorrectionType.Default` | The keyboard's default. | `UITextAutocorrectionType.default` |
| `CYLTextAutocorrectionType.No` | No correction. | `UITextAutocorrectionType.no` |
| `CYLTextAutocorrectionType.Yes` | Correction on. | `UITextAutocorrectionType.yes` |
| **interface `CYLSearchBarViewDelegate`** | Events of a `CYLSearchBarView`. | **protocol `CYLSearchBarViewDelegate`** |
| `CYLSearchBarViewDelegate.searchBarViewShouldBeginEditing` | Asks whether a tap may start editing. | `CYLSearchBarViewDelegate.-searchBarViewShouldBeginEditing:` |
| `CYLSearchBarViewDelegate.searchBarViewDidTapWhileNotEditable` | The bar was tapped while `searchBarViewShouldBeginEditing` refused editing. | `CYLSearchBarViewDelegate.-searchBarViewDidTapWhileNotEditable:` |
| `CYLSearchBarViewDelegate.searchBarViewDidBeginEditing` | Editing started. | `CYLSearchBarViewDelegate.-searchBarViewDidBeginEditing:` |
| `CYLSearchBarViewDelegate.searchBarViewDidEndEditing` | Editing ended. | `CYLSearchBarViewDelegate.-searchBarViewDidEndEditing:` |
| `CYLSearchBarViewDelegate.searchBarViewTextDidChange` | The text changed (typing, the clear button, Cancel with `clearsTextOnCancel`). | `CYLSearchBarViewDelegate.-searchBarView:textDidChange:` |
| `CYLSearchBarViewDelegate.searchBarViewSearchButtonClicked` | The keyboard's search key. | `CYLSearchBarViewDelegate.-searchBarViewSearchButtonClicked:` |
| `CYLSearchBarViewDelegate.searchBarViewCancelButtonClicked` | Cancel was tapped. | `CYLSearchBarViewDelegate.-searchBarViewCancelButtonClicked:` |
| `CYLSearchBarViewDelegate.searchBarViewNavigationButtonClicked` | The navigation button before the field (`navigationIcon`, `navigationImage`). | `CYLSearchBarViewDelegate.-searchBarViewNavigationButtonClicked:` |
| `CYLSearchBarViewDelegate.searchBarViewVoiceButtonClicked` | The voice button (`showsVoiceButton`). | `CYLSearchBarViewDelegate.-searchBarViewVoiceButtonClicked:` |
| `CYLSearchBarViewDelegate.searchBarViewShouldSubmitText` | Asks whether the query may be submitted (the search key, the submit button or `setText(text, true)`). | `CYLSearchBarViewDelegate.-searchBarView:shouldSubmitText:` |
| `CYLSearchBarViewDelegate.searchBarViewDidChangeIconified` | The field opened or closed (`isIconified`). | `CYLSearchBarViewDelegate.-searchBarView:didChangeIconified:` |
| `CYLSearchBarViewDelegate.searchBarViewDidSelectItem` | An appended item was tapped (`CYLSearchBarView.addItem`), like `-tabBar:didSelectItem:` (iOS `-searchBarView:didSelectItem:`). | `CYLSearchBarViewDelegate.-searchBarView:didSelectItem:` |
| **class `CYLSearchBarView`** | A configurable search bar (iOS `CYLSearchBarView`): a rounded field with a magnifier, text and clear button, views of the host inside the field after the text (a camera, a "Search" | **class `CYLSearchBarView`** |
| `CYLSearchBarView.delegate` | Receives the events. | `CYLSearchBarView.delegate` |
| `CYLSearchBarView.textField` | The text field inside the field. | `CYLSearchBarView.textField` |
| `CYLSearchBarView.fieldView` | The rounded field that holds the magnifier, the text and `trailingAccessoryViews`. | `CYLSearchBarView.fieldView` |
| `CYLSearchBarView.searchIconView` | The magnifier at the start of the field (decorative: hidden from TalkBack). | `CYLSearchBarView.searchIconView` |
| `CYLSearchBarView.cancelButton` | The Cancel button after the field (`showsCancelButton`). | `CYLSearchBarView.cancelButton` |
| `CYLSearchBarView.placeholderLabel` | Draws the placeholder, cut off with an ellipsis when it does not fit. | `CYLSearchBarView.placeholderLabel` |
| `CYLSearchBarView.navigationButton` | The button before the field. | `CYLSearchBarView.navigationButton` |
| `CYLSearchBarView.voiceButton` | A microphone inside the field, shown while the text is empty; it calls `searchBarViewVoiceButtonClicked`. | `CYLSearchBarView.voiceButton` |
| `CYLSearchBarView.submitButton` | A submit button inside the field, shown while there is text; it submits the query like the search key. | `CYLSearchBarView.submitButton` |
| `CYLSearchBarView.iconButton` | The button shown while `isIconified` is true. | `CYLSearchBarView.iconButton` |
| `CYLSearchBarView.text` | The text of the field. | `CYLSearchBarView.text` |
| `CYLSearchBarView.placeholder` | The placeholder, drawn by `placeholderLabel` and kept as the field's content description for TalkBack. | `CYLSearchBarView.placeholder` |
| `CYLSearchBarView.font` | The typeface of the text, the placeholder and Cancel. | `CYLSearchBarView.font` |
| `CYLSearchBarView.fontSize` | The text size in sp (the iOS font's point size). | `CYLSearchBarView.font` (`UIFont.pointSize`) |
| `CYLSearchBarView.textColor` | The text color. | `CYLSearchBarView.textColor` |
| `CYLSearchBarView.placeholderColor` | The placeholder color. | `CYLSearchBarView.placeholderColor` |
| `CYLSearchBarView.cursorColor` | The color of the text cursor (MaterialSearchView `setCursorDrawable`). | `CYLSearchBarView.cursorColor` |
| `CYLSearchBarView.fieldHeight` | The height of the field in dp; it grows when the text needs more. | `CYLSearchBarView.fieldHeight` |
| `CYLSearchBarView.contentInsets` | The space around the field in dp (left, top, right, bottom). | `CYLSearchBarView.contentInsets` |
| `CYLSearchBarView.fieldBackgroundColor` | The field's background. | `CYLSearchBarView.fieldBackgroundColor` |
| `CYLSearchBarView.fieldCornerRadius` | The field's corner radius in dp; negative makes a capsule. | `CYLSearchBarView.fieldCornerRadius` |
| `CYLSearchBarView.fieldBorderColor` | The field's border color; null draws no border. | `CYLSearchBarView.fieldBorderColor` |
| `CYLSearchBarView.fieldBorderWidth` | The field's border width in dp, used with `fieldBorderColor`. | `CYLSearchBarView.fieldBorderWidth` |
| `CYLSearchBarView.fieldShadowOpacity` | The field's shadow, 0 to 1 (drawn as elevation). | `CYLSearchBarView.fieldShadowOpacity` |
| `CYLSearchBarView.searchIcon` | The magnifier; null shows none. | `CYLSearchBarView.searchIcon` |
| `CYLSearchBarView.searchIconTintColor` | The magnifier's tint. | `CYLSearchBarView.searchIconTintColor` |
| `CYLSearchBarView.trailingAccessoryViews` | Views of yours inside the field after the text. | `CYLSearchBarView.trailingAccessoryViews` |
| `CYLSearchBarView.items` | The appended items, in order, after the text and after `trailingAccessoryViews` (like the FlatDesign tab bar's `items`). | `CYLSearchBarView.items` |
| `CYLSearchBarView.itemViews` | The views of `items`, in the same order. | `CYLSearchBarView.itemViews` |
| `CYLSearchBarView.itemTintColor` | The icon and title color of every item without its own `tintColor`; null uses the primary text color. | `CYLSearchBarView.itemTintColor` |
| `CYLSearchBarView.searchBarStyle` | The fixed look of the bar. | `CYLSearchBarView.searchBarStyle` |
| `CYLSearchBarView.fieldBackgroundImage` | An image drawn behind the field's content, clipped to its corners. | `CYLSearchBarView.fieldBackgroundImage` |
| `CYLSearchBarView.selectedItem` | The first selected item (a `isSelectable` item that is on), or null. | `CYLSearchBarView.selectedItem` |
| `CYLSearchBarView.selectedIndex` | The index of `selectedItem`, or -1. | `CYLSearchBarView.selectedIndex` |
| `CYLSearchBarView.addItem` | Appends an item after the others. | `CYLSearchBarView.addItem(_:)` |
| `CYLSearchBarView.insertItem` | Inserts an item at an index (clamped to `items`); an item already in a bar moves here. | `CYLSearchBarView.insertItem(_:at:)` |
| `CYLSearchBarView.removeItem` | Removes an item from the bar. | `CYLSearchBarView.removeItem(_:)` |
| `CYLSearchBarView.removeAllItems` | Removes every item. | `CYLSearchBarView.removeAllItems()` |
| `CYLSearchBarView.hasItem` | True when an item of the style was appended (a text "Search" button), like `-hasPlusButton`. | `CYLSearchBarView.hasItem(of:)` |
| `CYLSearchBarView.leadingView` | A view of yours before the field (a back button); it wins over the navigation button. | `CYLSearchBarView.leadingView` |
| `CYLSearchBarView.showsCancelButton` | Shows the Cancel button after the field. | `CYLSearchBarView.showsCancelButton` |
| `CYLSearchBarView.cancelButtonTitle` | The Cancel title. | `CYLSearchBarView.cancelButtonTitle` |
| `CYLSearchBarView.cancelButtonEndsEditing` | Taps on Cancel also end editing. | `CYLSearchBarView.cancelButtonEndsEditing` |
| `CYLSearchBarView.clearsTextOnCancel` | Taps on Cancel also clear the text (lapism `setTextClearOnBackPressed`). | `CYLSearchBarView.clearsTextOnCancel` |
| `CYLSearchBarView.clearsTextOnEndEditing` | Ending editing also clears the text (lapism `setTextClearOnClearFocus`). | `CYLSearchBarView.clearsTextOnEndEditing` |
| `CYLSearchBarView.navigationIcon` | A built-in navigation icon. | `CYLSearchBarView.navigationIcon` |
| `CYLSearchBarView.navigationImage` | A custom navigation icon; it wins over `navigationIcon`. | `CYLSearchBarView.navigationImage` |
| `CYLSearchBarView.navigationAccessibilityLabel` | What TalkBack reads for the navigation button. | `CYLSearchBarView.navigationAccessibilityLabel` |
| `CYLSearchBarView.navigationBackgroundColor` | A circle drawn behind the navigation icon. | `CYLSearchBarView.navigationBackgroundColor` |
| `CYLSearchBarView.navigationShadowOpacity` | The shadow of that circle, 0 to 1 (lapism `setNavigationElevation`). | `CYLSearchBarView.navigationShadowOpacity` |
| `CYLSearchBarView.navigationHandler` | Called on taps on the navigation button, after the delegate. | `CYLSearchBarView.navigationHandler` |
| `CYLSearchBarView.showsVoiceButton` | Shows `voiceButton` while the text is empty. | `CYLSearchBarView.showsVoiceButton` |
| `CYLSearchBarView.voiceImage` | The voice button's icon. | `CYLSearchBarView.voiceImage` |
| `CYLSearchBarView.showsSubmitButton` | Shows `submitButton` while there is text (Android `isSubmitButtonEnabled`). | `CYLSearchBarView.showsSubmitButton` |
| `CYLSearchBarView.submitImage` | The submit button's icon. | `CYLSearchBarView.submitImage` |
| `CYLSearchBarView.clearImage` | The clear button's icon, shown while editing with text. | `CYLSearchBarView.clearImage` |
| `CYLSearchBarView.keyboardType` | The keyboard (an `InputType` class, iOS `keyboardType`). | `CYLSearchBarView.keyboardType` |
| `CYLSearchBarView.returnKeyType` | The action key (an `EditorInfo.IME_ACTION_*`, iOS `returnKeyType`). | `CYLSearchBarView.returnKeyType` |
| `CYLSearchBarView.autocapitalizationType` | Automatic capitalization. | `CYLSearchBarView.autocapitalizationType` |
| `CYLSearchBarView.autocorrectionType` | Automatic correction. | `CYLSearchBarView.autocorrectionType` |
| `CYLSearchBarView.isSecureTextEntry` | Hides the typed characters (Android `inputType="textPassword"`). | `CYLSearchBarView.isSecureTextEntry` |
| `CYLSearchBarView.maximumTextLength` | The longest text a person can type (Android `maxLength`); 0 means no limit. | `CYLSearchBarView.maximumTextLength` |
| `CYLSearchBarView.isIconified` | Shows only a search button instead of the field (Android `SearchView.isIconified`). | `CYLSearchBarView.isIconified` |
| `CYLSearchBarView.iconifiedByDefault` | When true, the field closes back to its icon when editing ends with no text (Android `setIconifiedByDefault`). | `CYLSearchBarView.iconifiedByDefault` |
| `CYLSearchBarView.expansionAnimation` | How the field opens and closes. | `CYLSearchBarView.expansionAnimation` |
| `CYLSearchBarView.iconPosition` | Where `iconButton` sits while iconified; the field opens from there. | `CYLSearchBarView.iconPosition` |
| `CYLSearchBarView.animationDuration` | The length of the opening and closing animations, in seconds. | `CYLSearchBarView.animationDuration` |
| `CYLSearchBarView.setText` | Sets the text and, when `submit` is true and the text is not empty, submits it as if the search key were tapped (MaterialSearchView `setQuery`, lapism `setTextQuery`). | `CYLSearchBarView.setText(_:submit:)` |
| `CYLSearchBarView.submit` | Submits the current text: asks `searchBarViewShouldSubmitText`, then calls `searchBarViewSearchButtonClicked`. | `CYLSearchBarView.submit()` |
| `CYLSearchBarView.showKeyboard` | Starts editing and shows the keyboard. | `CYLSearchBarView.showKeyboard()` |
| `CYLSearchBarView.hideKeyboard` | Ends editing and hides the keyboard. | `CYLSearchBarView.hideKeyboard()` |
| `CYLSearchBarView.setIconified` | Opens or closes the field, with `expansionAnimation` when `animated` is true. | `CYLSearchBarView.setIconified(_:animated:)` |
| **interface `CYLSearchControllerDelegate`** | Events of a `CYLSearchController`. | **protocol `CYLSearchControllerDelegate`** |
| `CYLSearchControllerDelegate.searchControllerDidCancel` | Cancel was tapped and the overlay is gone. | `CYLSearchControllerDelegate.-searchControllerDidCancel:` |
| **class `CYLSearchController`** | An animated search overlay that uses the same injectable result source as `CYLSearchResultsViewController` (iOS `CYLSearchController`). | **class `CYLSearchController`** |
| `CYLSearchController.delegate` | Receives the cancel event. | `CYLSearchController.delegate` |
| `CYLSearchController.resultsViewController` | The results controller shown inside the overlay. | `CYLSearchController.resultsViewController` |
| `CYLSearchController.isPresented` | True while the overlay is on screen or animating in. | `CYLSearchController.presented` |
| `CYLSearchController.showInViewController` | Adds the overlay over the host activity's content and animates it into view. | `CYLSearchController.show(in:)` |
| `CYLSearchController.hide` | Completion is called after the overlay is removed, including when not presented. | `CYLSearchController.hide(_:)` |
| **enum `CYLSearchPlaceholderKind`** | The common placeholder kinds: an empty list, no search results, or an error. | **enum `CYLSearchPlaceholderKind`** |
| `CYLSearchPlaceholderKind.Empty` | Nothing to show yet. | `CYLSearchPlaceholderKind.empty` |
| `CYLSearchPlaceholderKind.NoResults` | The search found nothing. | `CYLSearchPlaceholderKind.noResults` |
| `CYLSearchPlaceholderKind.Error` | Loading failed. | `CYLSearchPlaceholderKind.error` |
| **enum `CYLSearchPlaceholderStyle`** | The image of a placeholder; each style has an image in this library's resources. | **enum `CYLSearchPlaceholderStyle`** |
| `CYLSearchPlaceholderStyle.Empty` | — | `CYLSearchPlaceholderStyle.empty` |
| `CYLSearchPlaceholderStyle.NoResults` | — | `CYLSearchPlaceholderStyle.noResults` |
| `CYLSearchPlaceholderStyle.Error` | — | `CYLSearchPlaceholderStyle.error` |
| `CYLSearchPlaceholderStyle.WifiOff` | — | `CYLSearchPlaceholderStyle.wifiOff` |
| `CYLSearchPlaceholderStyle.SignalWifiOff` | — | `CYLSearchPlaceholderStyle.signalWifiOff` |
| `CYLSearchPlaceholderStyle.NoInternet` | — | `CYLSearchPlaceholderStyle.noInternet` |
| `CYLSearchPlaceholderStyle.CloudOff` | — | `CYLSearchPlaceholderStyle.cloudOff` |
| `CYLSearchPlaceholderStyle.SyncProblem` | — | `CYLSearchPlaceholderStyle.syncProblem` |
| `CYLSearchPlaceholderStyle.SyncDisabled` | — | `CYLSearchPlaceholderStyle.syncDisabled` |
| `CYLSearchPlaceholderStyle.NetworkLocked` | — | `CYLSearchPlaceholderStyle.networkLocked` |
| `CYLSearchPlaceholderStyle.BluetoothDisabled` | — | `CYLSearchPlaceholderStyle.bluetoothDisabled` |
| `CYLSearchPlaceholderStyle.LocationOff` | — | `CYLSearchPlaceholderStyle.locationOff` |
| `CYLSearchPlaceholderStyle.PublicOff` | — | `CYLSearchPlaceholderStyle.publicOff` |
| `CYLSearchPlaceholderStyle.ErrorOutline` | — | `CYLSearchPlaceholderStyle.errorOutline` |
| `CYLSearchPlaceholderStyle.Warning` | — | `CYLSearchPlaceholderStyle.warning` |
| `CYLSearchPlaceholderStyle.ReportProblem` | — | `CYLSearchPlaceholderStyle.reportProblem` |
| `CYLSearchPlaceholderStyle.Blocked` | — | `CYLSearchPlaceholderStyle.blocked` |
| `CYLSearchPlaceholderStyle.Help` | — | `CYLSearchPlaceholderStyle.help` |
| `CYLSearchPlaceholderStyle.Hourglass` | — | `CYLSearchPlaceholderStyle.hourglass` |
| `CYLSearchPlaceholderStyle.Locked` | — | `CYLSearchPlaceholderStyle.locked` |
| `CYLSearchPlaceholderStyle.VisibilityOff` | — | `CYLSearchPlaceholderStyle.visibilityOff` |
| `CYLSearchPlaceholderStyle.SearchOff` | — | `CYLSearchPlaceholderStyle.searchOff` |
| `CYLSearchPlaceholderStyle.FolderOff` | — | `CYLSearchPlaceholderStyle.folderOff` |
| `CYLSearchPlaceholderStyle.FolderOpen` | — | `CYLSearchPlaceholderStyle.folderOpen` |
| `CYLSearchPlaceholderStyle.DownloadOff` | — | `CYLSearchPlaceholderStyle.downloadOff` |
| `CYLSearchPlaceholderStyle.UploadOff` | — | `CYLSearchPlaceholderStyle.uploadOff` |
| `CYLSearchPlaceholderStyle.Inbox` | — | `CYLSearchPlaceholderStyle.inbox` |
| `CYLSearchPlaceholderStyle.BrokenImage` | — | `CYLSearchPlaceholderStyle.brokenImage` |
| `CYLSearchPlaceholderStyle.ImageUnavailable` | — | `CYLSearchPlaceholderStyle.imageUnavailable` |
| `CYLSearchPlaceholderStyle.PhotoLibrary` | — | `CYLSearchPlaceholderStyle.photoLibrary` |
| `CYLSearchPlaceholderStyle.MusicOff` | — | `CYLSearchPlaceholderStyle.musicOff` |
| `CYLSearchPlaceholderStyle.VideoOff` | — | `CYLSearchPlaceholderStyle.videoOff` |
| `CYLSearchPlaceholderStyle.PersonOff` | — | `CYLSearchPlaceholderStyle.personOff` |
| `CYLSearchPlaceholderStyle.GroupOff` | — | `CYLSearchPlaceholderStyle.groupOff` |
| `CYLSearchPlaceholderStyle.EventBusy` | — | `CYLSearchPlaceholderStyle.eventBusy` |
| `CYLSearchPlaceholderStyle.EmptyCart` | — | `CYLSearchPlaceholderStyle.emptyCart` |
| `CYLSearchPlaceholderStyle.Favorite` | — | `CYLSearchPlaceholderStyle.favorite` |
| `CYLSearchPlaceholderStyle.BatteryAlert` | — | `CYLSearchPlaceholderStyle.batteryAlert` |
| `CYLSearchPlaceholderStyle.UnknownDevice` | — | `CYLSearchPlaceholderStyle.unknownDevice` |
| `CYLSearchPlaceholderStyle.PhoneDisabled` | — | `CYLSearchPlaceholderStyle.phoneDisabled` |
| `CYLSearchPlaceholderStyle.WrongLocation` | — | `CYLSearchPlaceholderStyle.wrongLocation` |
| `CYLSearchPlaceholderStyle.Count` | The number of styles; not an image. | `CYLSearchPlaceholderStyle.count` |
| **enum `CYLSearchPlaceholderMessage`** | The localized message of a placeholder. | **enum `CYLSearchPlaceholderMessage`** |
| `CYLSearchPlaceholderMessage.Empty` | "No data". | `CYLSearchPlaceholderMessage.empty` |
| `CYLSearchPlaceholderMessage.NoResults` | "No matching results". | `CYLSearchPlaceholderMessage.noResults` |
| `CYLSearchPlaceholderMessage.Error` | "Something went wrong". | `CYLSearchPlaceholderMessage.error` |
| `CYLSearchPlaceholderMessage.Network` | "Check your internet connection". | `CYLSearchPlaceholderMessage.network` |
| **class `CYLSearchPlaceholderView`** | An image above a message, centered in its bounds: the empty, no-result and error states of a list (iOS `CYLSearchPlaceholderView`). | **class `CYLSearchPlaceholderView`** |
| `CYLSearchPlaceholderView.imageView` | The image, 80 × 80 dp, tinted with the secondary text color (except the colored empty image). | `CYLSearchPlaceholderView.imageView` |
| `CYLSearchPlaceholderView.textLabel` | The message, centered, in the body text size. | `CYLSearchPlaceholderView.textLabel` |
| **object `CYLSearchResources`** | Images and localized strings of this library (iOS `CYLSearchResources`, the `CYLSearchViewController.bundle`). | **class `CYLSearchResources`** |
| `CYLSearchResources.resourceBundle` | The resources that hold the images and strings (iOS `resourceBundle`): the app's resources, which include this library's. | `CYLSearchResources.resourceBundle` |
| `CYLSearchResources.imageNamed` | An image of this library by its iOS name ("CYLSearchNoResults"), or null (logged) when it is missing. | `CYLSearchResources.image(named:)` |
| `CYLSearchResources.localizedString` | The text of `key` in the language the app shows, English when the key has no translation, or the key itself (logged) when it is missing everywhere. | `CYLSearchResources.localizedString(forKey:)` |
| **interface `CYLSearchResultsDataSource`** | Supplies the results of a `CYLSearchResultsViewController` and configures their cells. | **protocol `CYLSearchResultsDataSource`** |
| `CYLSearchResultsDataSource.searchResultsViewControllerResultsForQuery` | The results for `query` (an empty string while nothing is typed). | `CYLSearchResultsDataSource.-searchResultsViewController:resultsForQuery:` |
| `CYLSearchResultsDataSource.searchResultsViewControllerConfigureCell` | Shows `result` in `cell`. | `CYLSearchResultsDataSource.-searchResultsViewController:configureCell:withResult:` |
| `CYLSearchResultsDataSource.searchResultsViewControllerDidSelectResult` | A result was tapped. | `CYLSearchResultsDataSource.-searchResultsViewController:didSelectResult:` |
| **class `CYLSearchResultsViewController`** | A list of search results under a search bar, driven by a `CYLSearchResultsDataSource` (iOS `CYLSearchResultsViewController`, a `UITableViewController` with a navigation-item search | **class `CYLSearchResultsViewController`** |
| `CYLSearchResultsViewController.searchDataSource` | The data source given at creation. | `CYLSearchResultsViewController.searchDataSource` |
| `CYLSearchResultsViewController.searchController` | The search bar above the list (iOS `searchController`, the navigation-item search bar). | `CYLSearchResultsViewController.searchController` |
| `CYLSearchResultsViewController.tableView` | The list of results (iOS `tableView`). | `CYLSearchResultsViewController.tableView(_:numberOfRowsInSection:)` |
| `CYLSearchResultsViewController.searchResults` | The results of the last query. | `CYLSearchResultsViewController.searchResults` |
| `CYLSearchResultsViewController.reloadSearchResults` | Requeries the data source using the current search text and reloads the list. | `CYLSearchResultsViewController.reloadSearchResults()` |
| `CYLSearchResultsViewController.reloadResultsTableView` | Override to integrate a custom list reload, such as an empty-state provider. | `CYLSearchResultsViewController.reloadResultsTableView()` |
| `CYLSearchResultsViewController.updateSearchResults` | Requeries the results when the search text changes (iOS `updateSearchResults(for:)`). | `CYLSearchResultsViewController.updateSearchResults(for:)` |
| **enum `CYLSearchSuggestionCachePolicy`** | Where the suggestion cache keeps the submitted queries (iOS `CYLSearchSuggestionCachePolicy`). | `CYLSearchSuggestionCachePolicy` |
| `CYLSearchSuggestionCachePolicy.None` | No cache: the suggestion list shows only `suggestions`. | `CYLSearchSuggestionCachePolicy.None` |
| `CYLSearchSuggestionCachePolicy.Database` | A SQLite database in the app's database folder (the local cache, the default). | `CYLSearchSuggestionCachePolicy.Database` |
| `CYLSearchSuggestionCachePolicy.UserDefaults` | `SharedPreferences` (iOS `NSUserDefaults`). | `CYLSearchSuggestionCachePolicy.UserDefaults` |
| `CYLSearchSuggestionCachePolicy.SandboxFile` | A JSON file in the app's files folder (the sandbox). | `CYLSearchSuggestionCachePolicy.SandboxFile` |
| **interface `CYLSearchSuggestionCache`** | A store of submitted queries, newest first (iOS `CYLSearchSuggestionCache`). | `CYLSearchSuggestionCache` |
| `CYLSearchSuggestionCache.cachedQueries` | The cached queries, newest first. | `CYLSearchSuggestionCache.cachedQueries` |
| `CYLSearchSuggestionCache.addQuery` | Adds `query` at the front; an equal query already cached moves to the front instead of being repeated. | `CYLSearchSuggestionCache.addQuery` |
| `CYLSearchSuggestionCache.removeQuery` | Removes `query`. | `CYLSearchSuggestionCache.removeQuery` |
| `CYLSearchSuggestionCache.removeAllQueries` | Removes every cached query. | `CYLSearchSuggestionCache.removeAllQueries` |
| **class `CYLSearchSuggestionStore`** | The built-in caches: a database, `SharedPreferences` or a file, behind one class (iOS `CYLSearchSuggestionStore`). | **class `CYLSearchSuggestionStore`** |
| `CYLSearchSuggestionStore.name` | Separates the caches of different search screens: the database key, the preferences key or the file name. | `CYLSearchSuggestionStore.name` |
| `CYLSearchSuggestionStore.maximumCount` | The largest number of queries kept; the oldest go first. | `CYLSearchSuggestionStore.maximumCount` |
| **enum `CYLLineBreakMode`** | How a long suggestion is cut (iOS `NSLineBreakMode`). | `NSLineBreakMode` (`CYLSearchView.suggestionLineBreakMode`; Android stand-in) |
| `CYLLineBreakMode.WordWrapping` | The whole text on several lines, wrapped at word boundaries. | `NSLineBreakMode.byWordWrapping` |
| `CYLLineBreakMode.CharWrapping` | The whole text on several lines, wrapped at any character. | `NSLineBreakMode.byCharWrapping` |
| `CYLLineBreakMode.Clipping` | One line, cut off at the edge. | `NSLineBreakMode.byClipping` |
| `CYLLineBreakMode.TruncatingHead` | One line with an ellipsis at the start. | `NSLineBreakMode.byTruncatingHead` |
| `CYLLineBreakMode.TruncatingTail` | One line with an ellipsis at the end. | `NSLineBreakMode.byTruncatingTail` |
| `CYLLineBreakMode.TruncatingMiddle` | One line with an ellipsis in the middle. | `NSLineBreakMode.byTruncatingMiddle` |
| **enum `CYLSearchSuggestionStyle`** | How the suggestions are shown under the search bar (`CYLSearchView.suggestionStyle`). | **enum `CYLSearchSuggestionStyle`** |
| `CYLSearchSuggestionStyle.List` | One suggestion per row with its icon (`suggestionsTableView`; iOS table view). | `CYLSearchSuggestionStyle.list` |
| `CYLSearchSuggestionStyle.Tags` | Tags that wrap like words (`suggestionsTagView`, CollectionViewClassifyMenu's `CYLTagListView`; iOS collection view). | `CYLSearchSuggestionStyle.tags` |
| **interface `CYLSearchViewDelegate`** | Events of a `CYLSearchView`: opening and closing, the query, focus, suggestions and the voice button. | **protocol `CYLSearchViewDelegate`** |
| `CYLSearchViewDelegate.searchViewDidShow` | The search view finished opening (MaterialSearchView `onSearchViewShown`). | `CYLSearchViewDelegate.-searchViewDidShow:` |
| `CYLSearchViewDelegate.searchViewDidClose` | The search view finished closing (MaterialSearchView `onSearchViewClosed`). | `CYLSearchViewDelegate.-searchViewDidClose:` |
| `CYLSearchViewDelegate.searchViewTextDidChange` | The query changed (`onQueryTextChange`). | `CYLSearchViewDelegate.-searchView:textDidChange:` |
| `CYLSearchViewDelegate.searchViewDidSubmitText` | The query was submitted (`onQueryTextSubmit`). | `CYLSearchViewDelegate.-searchView:didSubmitText:` |
| `CYLSearchViewDelegate.searchViewDidChangeFocus` | The field started or stopped editing (lapism `OnFocusChangeListener`). | `CYLSearchViewDelegate.-searchView:didChangeFocus:` |
| `CYLSearchViewDelegate.searchViewDidSelectSuggestion` | A suggestion was tapped (MaterialSearchView `setOnItemClickListener`). | `CYLSearchViewDelegate.-searchView:didSelectSuggestion:atIndex:` |
| `CYLSearchViewDelegate.searchViewVoiceButtonClicked` | The voice button was tapped. | `CYLSearchViewDelegate.-searchViewVoiceButtonClicked:` |
| `CYLSearchViewDelegate.searchViewNavigationButtonClicked` | The navigation button (the back arrow by default) was tapped. | `CYLSearchViewDelegate.-searchViewNavigationButtonClicked:` |
| **class `CYLSearchSuggestionCell`** | A suggestion row of a `CYLSearchView`: an icon and a text (iOS `UITableViewCell` with a list content configuration). | the `CYLSearchView` suggestion row: a `UITableViewCell` (reuse identifier `CYLSearchSuggestionCell`) with a `UIListContentConfiguration` (icon and text) |
| `CYLSearchSuggestionCell.imageView` | The icon before the text (`suggestionImage`). | the suggestion row's `UIListContentConfiguration.image` (`CYLSearchView.suggestionImage`) |
| `CYLSearchSuggestionCell.textLabel` | The suggestion text. | the suggestion row's `UIListContentConfiguration.text` (the suggestion) |
| **class `CYLSearchView`** | A search page that opens over its host view (iOS `CYLSearchView`; MiguelCatalan and lapism `MaterialSearchView`): a `CYLSearchBarView` below the status bar, a divider, a list of su | **class `CYLSearchView`** |
| `CYLSearchView.delegate` | Receives the events of the search view. | `CYLSearchView.delegate` |
| `CYLSearchView.searchBarView` | The search bar at the top. | `CYLSearchView.searchBarView` |
| `CYLSearchView.dividerView` | The line under the search bar. | `CYLSearchView.dividerView` |
| `CYLSearchView.suggestionsTableView` | The list of suggestions (iOS `suggestionsTableView`). | `CYLSearchView.suggestionsTableView` |
| `CYLSearchView.suggestionsTagView` | The tags that show the suggestions when `suggestionStyle` is `Tags` (CollectionViewClassifyMenu's `CYLTagListView`). | `CYLSearchView.suggestionsTagView` |
| `CYLSearchView.suggestionsFoldControl` | The fold control of the tag suggestions (CollectionViewClassifyMenu's `CYLMenuFoldControl`; iOS `suggestionsFoldControl`). | `CYLSearchView.suggestionsFoldControl` |
| `CYLSearchView.suggestionsFoldedRowCount` | The rows of tag suggestions shown while folded (iOS `suggestionsFoldedRowCount`). | `CYLSearchView.suggestionsFoldedRowCount` |
| `CYLSearchView.suggestionStyle` | How the suggestions are shown: a list (`List`, the default) or tags (`Tags`). | `CYLSearchView.suggestionStyle` |
| `CYLSearchView.showsEmptyResultsPlaceholder` | Shows CYLTableViewPlaceHolder's placeholder for `emptyResultsScenario` under the search bar while a non-empty query matches no suggestion, in both suggestion styles. | `CYLSearchView.showsEmptyResultsPlaceholder` |
| `CYLSearchView.emptyResultsScenario` | The CYLTableViewPlaceHolder scenario of that placeholder. | `CYLSearchView.emptyResultsScenario` |
| `CYLSearchView.emptyResultsView` | The placeholder shown for empty results (CYLTableViewPlaceHolder's `CYLPlaceholderStackView`), created the first time it is shown; null before. | `CYLSearchView.emptyResultsView` |
| `CYLSearchView.suggestionCachePolicy` | Where submitted queries are cached for the suggestion list (iOS `suggestionCachePolicy`): `Database`, a local SQLite database, by default. | `CYLSearchView.suggestionCachePolicy` |
| `CYLSearchView.suggestionCacheName` | Separates the caches of different search screens. | `CYLSearchView.suggestionCacheName` |
| `CYLSearchView.suggestionCache` | The cache in use: the built-in store of `suggestionCachePolicy`, or a store of yours (set it after the policy). | `CYLSearchView.suggestionCache` |
| `CYLSearchView.suggestionCacheHeaderView` | The header above the cached queries: a title and, at its end, `clearSuggestionCacheButton`. | `CYLSearchView.suggestionCacheHeaderView` |
| `CYLSearchView.suggestionCacheTitleLabel` | The title of `suggestionCacheHeaderView` ("Recent searches"). | `CYLSearchView.suggestionCacheTitleLabel` |
| `CYLSearchView.clearSuggestionCacheButton` | Clears the whole cache (a delete icon at the top right of the suggestion list). | `CYLSearchView.clearSuggestionCacheButton` |
| `CYLSearchView.showsEmptySuggestionsPlaceholder` | Shows CYLTableViewPlaceHolder's placeholder for `emptySuggestionsScenario` while the query is empty and the cache holds nothing. | `CYLSearchView.showsEmptySuggestionsPlaceholder` |
| `CYLSearchView.emptySuggestionsScenario` | The scenario of that placeholder. | `CYLSearchView.emptySuggestionsScenario` |
| `CYLSearchView.emptySuggestionsView` | The placeholder shown for an empty cache, created the first time it is shown; null before. | `CYLSearchView.emptySuggestionsView` |
| `CYLSearchView.focusesSearchFieldOnShow` | Focuses the search field when the search opens, which raises the keyboard (iOS `focusesSearchFieldOnShow`). | `CYLSearchView.focusesSearchFieldOnShow` |
| `CYLSearchView.dividerColor` | The color of `dividerView` (lapism `setDividerColor`). | `CYLSearchView.dividerColor` |
| `CYLSearchView.contentView` | A view of yours shown under the divider, behind the suggestions (lapism `addView`): a results list, a history, anything. | `CYLSearchView.contentView` |
| `CYLSearchView.scrimColor` | The color behind the page while it is open (lapism `setScrimColor`). | `CYLSearchView.scrimColor` |
| `CYLSearchView.pageBackgroundColor` | The page background. | `CYLSearchView.backgroundColor` (the page background; the view itself only shows the scrim) |
| `CYLSearchView.suggestions` | The suggestions to filter as the text changes (MaterialSearchView `setSuggestions`). | `CYLSearchView.suggestions` |
| `CYLSearchView.suggestionFilter` | Decides whether a suggestion matches the query: `(suggestion, query) -> Boolean`. | `CYLSearchView.suggestionFilter` |
| `CYLSearchView.showsSuggestionsForEmptyQuery` | Lists every suggestion while the query is empty. | `CYLSearchView.showsSuggestionsForEmptyQuery` |
| `CYLSearchView.filteredSuggestions` | The suggestions that match the current query, in their original order. | `CYLSearchView.filteredSuggestions` |
| `CYLSearchView.suggestionImage` | The icon before each suggestion (MaterialSearchView `setSuggestionIcon`). | `CYLSearchView.suggestionImage` |
| `CYLSearchView.suggestionImageTintColor` | The tint of `suggestionImage`. | `CYLSearchView.suggestionImageTintColor` |
| `CYLSearchView.suggestionBackgroundColor` | The background of the suggestion rows (`setSuggestionBackground`). | `CYLSearchView.suggestionBackgroundColor` |
| `CYLSearchView.suggestionTextColor` | The color of the suggestion text. | `CYLSearchView.suggestionTextColor` |
| `CYLSearchView.suggestionLineBreakMode` | How a long suggestion is cut (MaterialSearchView `setEllipsize`). | `CYLSearchView.suggestionLineBreakMode` |
| `CYLSearchView.submitsOnSuggestionSelection` | Submits a suggestion as soon as it is tapped (`setSubmitOnClick`). | `CYLSearchView.submitsOnSuggestionSelection` |
| `CYLSearchView.suggestionCellConfiguration` | Configures each suggestion cell after the defaults (a custom adapter's `getView`): `(cell, suggestion, index)`. | `CYLSearchView.suggestionCellConfiguration` |
| `CYLSearchView.isSearchOpen` | True while the search view is open (MaterialSearchView `isSearchOpen`). | `CYLSearchView.searchOpen` |
| `CYLSearchView.animationDuration` | The length of the open and close animations, in seconds (`setAnimationDuration`). | `CYLSearchView.animationDuration` |
| `CYLSearchView.closesOnSubmit` | Closes the search view after a submitted query that the delegate did not handle. | `CYLSearchView.closesOnSubmit` |
| `CYLSearchView.query` | The current query (lapism `getTextQuery`). | `CYLSearchView.query` |
| `CYLSearchView.installInView` | Adds the search view over `view` (filling it) without opening it. | `CYLSearchView.install(in:)` |
| `CYLSearchView.showSearch` | Opens the search view with animation and starts editing (`showSearch`). | `CYLSearchView.showSearch()` |
| `CYLSearchView.closeSearch` | Closes the search view with animation and ends editing (`closeSearch`). | `CYLSearchView.closeSearch()` |
| `CYLSearchView.attachToMenuItem` | Makes a toolbar menu item open the search view (`setMenuItem`; iOS `attachToBarButtonItem:`). | `CYLSearchView.attach(to:)` |
| `CYLSearchView.setQuery` | Sets the query and submits it when `submit` is true (`setQuery`, `setTextQuery`). | `CYLSearchView.setQuery(_:submit:)` |
| `CYLSearchView.showSuggestions` | Lists the suggestions that match the current query (`showSuggestions`). | `CYLSearchView.showSuggestions()` |
| `CYLSearchView.dismissSuggestions` | Hides the suggestions (`dismissSuggestions`). | `CYLSearchView.dismissSuggestions()` |
| `CYLSearchView.clearSuggestionCache` | Removes every cached query (the delete button of `suggestionCacheHeaderView`) and shows the list again (iOS `clearSuggestionCache`). | `CYLSearchView.clearSuggestionCache()` |

### B. CollectionViewClassifyMenu (tag views): `com.cyl.classifymenu` → its iOS library (measured at `41aec0d 2026-11-17`)

Rows: 604; matched 597, TODO 7; score 98/100.

| Android API or feature | Description | iOS counterpart |
| :--- | :--- | :--- |
| **class `CYLIndexPathButton`** | `CYLIndexPathButton`: a button that knows its item (section, row), with spacing between its image and title and an inset before the title (dp). | `CYLIndexPathButton` |
| `CYLIndexPathButton.section` | — | `CYLIndexPathButton.section` |
| `CYLIndexPathButton.row` | — | `CYLIndexPathButton.row` |
| `CYLIndexPathButton.cyl_imageTitleSpacing` | The space between the image and the title, dp. | `CYLIndexPathButton.cyl_imageTitleSpacing` |
| `CYLIndexPathButton.cyl_titleLeadingInset` | Extra space before the title, dp. | `CYLIndexPathButton.cyl_titleLeadingInset` |
| `CYLIndexPathButton.setImage` | `setImage:forState:` for the normal state: the image before the title. | `UIButton.setImage(_:for: .normal)` (`CYLIndexPathButton` is a `UIButton`) |
| `CYLIndexPathButton.currentImage` | `currentImage`. | `UIButton.currentImage` |
| **class `CYLRightImageButton`** | `CYLRightImageButton`: the "Expand / Collapse" button of a section header: the title, then the arrow image after it (7 dp apart); selected means expanded. | `CYLRightImageButton` |
| **class `CYLCollectionViewCell`** | `CYLCollectionViewCell`: the classify menu's cell: a `CYLIndexPathButton` filling it, in `cyl_chengNiStyle`. | `CYLCollectionViewCell` |
| `CYLCollectionViewCell.button` | — | `CYLCollectionViewCell.button` |
| `CYLCollectionViewCell.section` | — | `CYLCollectionViewCell.section` |
| `CYLCollectionViewCell.row` | — | `CYLCollectionViewCell.row` |
| `CYLCollectionViewCell.shouldShow` | — | `CYLCollectionViewCell.shouldShow` |
| **interface `CYLFilterHeaderViewDelegate`** | `CYLFilterHeaderViewDelegate`: the More button of a section header was tapped. | `CYLFilterHeaderViewDelegate` |
| `CYLFilterHeaderViewDelegate.filterHeaderViewDidTapMoreButton` | `-filterHeaderViewDidTapMoreButton:`: `sender` is the header's More button. | `CYLFilterHeaderViewDelegate -filterHeaderViewDidTapMoreButton:` |
| **class `CYLFilterHeaderView`** | `CYLFilterHeaderView`: a section header of the classify menu: the title (with the section's image), the More button at the trailing edge (hidden unless the section folds) and a sep | `CYLFilterHeaderView` |
| `CYLFilterHeaderView.titleButton` | — | `CYLFilterHeaderView.titleButton` |
| `CYLFilterHeaderView.moreButton` | — | `CYLFilterHeaderView.moreButton` |
| `CYLFilterHeaderView.delegate` | — | `CYLFilterHeaderView.delegate` |
| `CYLFilterHeaderView.moreButtonTapped` | `-moreButtonTapped:`: tells the delegate. | `CYLFilterHeaderView -moreButtonTapped:` |
| **class `CYLClassifyMenuViewController`** | `CYLClassifyMenuViewController`: the original classify menu: sections of tags in left-aligned rows, folded to `defaultVisibleRows` with an Expand / Collapse button per section, a h | `CYLClassifyMenuViewController` |
| `CYLClassifyMenuViewController.menuDataSource` | — | `CYLClassifyMenuViewController.menuDataSource` |
| `CYLClassifyMenuViewController.menuDelegate` | — | `CYLClassifyMenuViewController.menuDelegate` |
| `CYLClassifyMenuViewController.menuHeaderView` | A view above the sections. | `CYLClassifyMenuViewController.menuHeaderView` |
| `CYLClassifyMenuViewController.menuFooterView` | A view below the sections. | `CYLClassifyMenuViewController.menuFooterView` |
| `CYLClassifyMenuViewController.selectedIndexPath` | The selected item, shown selected. | `CYLClassifyMenuViewController.selectedIndexPath` |
| `CYLClassifyMenuViewController.defaultVisibleRows` | Rows a folded section shows, at least 1. | `CYLClassifyMenuViewController.defaultVisibleRows` |
| `CYLClassifyMenuViewController.menuTitle` | The menu's title ("Categories", localized): `self.title` on iOS. | `menuTitle` (same name in the iOS core) |
| `CYLClassifyMenuViewController.reloadMenuData` | `-reloadMenuData`: reads the data source again; every section folds again. | `CYLClassifyMenuViewController -reloadMenuData` |
| `CYLClassifyMenuViewController.updateMenuLayout` | `-updateMenuLayout`: lays the menu out again (after the header or footer changed size). | `CYLClassifyMenuViewController -updateMenuLayout` |
| `CYLClassifyMenuViewController.numberOfVisibleItemsInSection` | The number of items a section shows now, and whether its More button shows (for tests and the example). | `CYLClassifyMenuViewController.numberOfVisibleItems(inSection:)` (`-numberOfVisibleItemsInSection:`) |
| `CYLClassifyMenuViewController.isSectionExpanded` | Whether a section is expanded. | `isSectionExpanded` (same name in the iOS core) |
| `CYLClassifyMenuViewController.setSectionExpanded` | Expands or folds a section, as its More button does. | `CYLClassifyMenuViewController.setSection(_:expanded:)` (`-setSection:expanded:`; the More button calls it) |
| **class `CYLCollectionViewLeftAlignedLayout`** | `CYLCollectionViewLeftAlignedLayout`: a flow layout whose rows start at the leading edge (or are centered / at the trailing edge, `rowAlignment`): items in order, a new row when th | `CYLCollectionViewLeftAlignedLayout` |
| `CYLCollectionViewLeftAlignedLayout.rowAlignment` | A `CYLTagRowAlignment` raw value: 0 leading, 1 center, 2 trailing. | `CYLCollectionViewLeftAlignedLayout.rowAlignment` |
| `CYLCollectionViewLeftAlignedLayout.frames` | The frames of items of `sizes` in a section that starts at `top`, `width` wide, with `insets`, the spacing between items and between rows. | `CYLCollectionViewLeftAlignedLayout.layoutAttributesForElements(in:)` (UIKit computes the frames; Android's helper returns them for its own list view) |
| **interface `UICollectionViewDelegateLeftAlignedLayout`** | `UICollectionViewDelegateLeftAlignedLayout`: the delegate protocol of the left-aligned layout; on Android the list view computes the sizes itself, so it declares nothing. | `UICollectionViewDelegateLeftAlignedLayout` |
| `cyl_setWidth` | `-cyl_setWidth:`, dp. | `UIView (CYLGeneral) -cyl_setWidth:` |
| `cyl_setHeight` | `-cyl_setHeight:`, dp. | `UIView (CYLGeneral) -cyl_setHeight:` |
| `cyl_setX` | `-cyl_setX:`, dp. | `UIView (CYLGeneral) -cyl_setX:` |
| `cyl_setY` | `-cyl_setY:`, dp. | `UIView (CYLGeneral) -cyl_setY:` |
| `cyl_setSize` | `-cyl_setSize:`, dp. | `UIView (CYLGeneral) -cyl_setSize:` |
| `cyl_height` | `-cyl_height`, dp. | `UIView (CYLGeneral) -cyl_height` |
| `cyl_width` | `-cyl_width`, dp. | `UIView (CYLGeneral) -cyl_width` |
| `cyl_x` | `-cyl_x`, dp. | `UIView (CYLGeneral) -cyl_x` |
| `cyl_y` | `-cyl_y`, dp. | `UIView (CYLGeneral) -cyl_y` |
| `cyl_maxY` | `-cyl_maxY`, dp. | `UIView (CYLGeneral) -cyl_maxY` |
| `cyl_maxX` | `-cyl_maxX`, dp. | `UIView (CYLGeneral) -cyl_maxX` |
| `cyl_horizontalCenterWithWidth` | `-cyl_horizontalCenterWithWidth:`: centers the view in `width` dp. | `UIView (CYLGeneral) -cyl_horizontalCenterWithWidth:` |
| `cyl_verticalCenterWithHeight` | `-cyl_verticalCenterWithHeight:`: centers the view in `height` dp. | `UIView (CYLGeneral) -cyl_verticalCenterWithHeight:` |
| `cyl_verticalCenterInSuperView` | `-cyl_verticalCenterInSuperView`. | `UIView (CYLGeneral) -cyl_verticalCenterInSuperView` |
| `cyl_horizontalCenterInSuperView` | `-cyl_horizontalCenterInSuperView`. | `UIView (CYLGeneral) -cyl_horizontalCenterInSuperView` |
| `cyl_setBorderWidth` | `-cyl_setBorderWidth:color:`: a border of `width` dp in `color`. | `UIView (CYLGeneral) -cyl_setBorderWidth:color:` |
| `cyl_setCornerRadius` | `-cyl_setCornerRadius:`: rounds the view (and clips it) with `radius` dp. | `UIView (CYLGeneral) -cyl_setCornerRadius:` |
| `cyl_addSubLayerWithFrame` | `-cyl_addSubLayerWithFrame:color:`: a colored rectangle drawn over the view (its overlay), at `frame` dp; change its bounds later to move it, as iOS changes the layer's frame. | `UIView (CYLGeneral) -cyl_addSubLayerWithFrame:color:` |
| `cyl_setTarget` | `-cyl_setTarget:action:`: runs `action` when the view is tapped. | `UIView (CYLGeneral) -cyl_setTarget:action:` |
| `cyl_capture` | `-cyl_capture`: the view drawn into a bitmap 270 dp wide. | `UIView (CYLGeneral) -cyl_capture` |
| `cyl_captureWithWidth` | `-cyl_captureWithWidth:`: the view drawn into a bitmap `width` dp wide and as high as the view. | `UIView (CYLGeneral) -cyl_captureWithWidth:` |
| `cyl_blurredImageWithRadius` | `-cyl_blurredImageWithRadius:iterations:tintColor:`: `iterations` box blurs of `radius` px (made odd, as vImage), then the tint at 25 % added on top; an empty bitmap is returned as | `UIImage (CYLBlur) -cyl_blurredImageWithRadius:iterations:tintColor:` |
| `List` | `-cyl_descriptionWithLocale:`: "count (" then one tab-indented item per line, then ")". | `List` (same name in the iOS core) |
| `Map` | `-cyl_descriptionWithLocale:`: "{" then one tab-indented "key = value;" per line, then "}". | `NSDictionary.cyl_descriptionWithLocale(_:)` (`NSDictionary+CYLLog.swift`; the Android row is the `Map<*, *>.cyl_descriptionWithLocale` extension) |
| `cyl_generalStyle` | `-cyl_generalStyle`: white, 1 dp border, 5 dp corners. | `UIButton (CYLCollectionCellStyle) -cyl_generalStyle` |
| `cyl_homeStyle` | `-cyl_homeStyle`: green title (lighter when selected, white when pressed on green) and a green border. | `UIButton (CYLCollectionCellStyle) -cyl_homeStyle` |
| `cyl_redStyle` | `-cyl_redStyle`: red title (white when pressed on green) and a red border. | `UIButton (CYLCollectionCellStyle) -cyl_redStyle` |
| `cyl_chengNiStyle` | `-cyl_chengNiStyle`: the classify menu's tag: a light green pill with the tint color, the highlighted background and white title when pressed or selected. | `UIButton (CYLCollectionCellStyle) -cyl_chengNiStyle` |
| **enum `CYLImageTagDirection`** | `CYLImageTagDirection`: where a tag sits around its group's dot (TagViewGroup's DIRECTION). | `CYLImageTagDirection` |
| `CYLImageTagDirection.CYLImageTagDirectionLeftCenter` | — | `CYLImageTagDirectionLeftCenter` (same name in the iOS core) |
| `CYLImageTagDirection.CYLImageTagDirectionLeftTop` | — | `CYLImageTagDirectionLeftTop` (same name in the iOS core) |
| `CYLImageTagDirection.CYLImageTagDirectionLeftTopStraight` | — | `CYLImageTagDirectionLeftTopStraight` (same name in the iOS core) |
| `CYLImageTagDirection.CYLImageTagDirectionLeftBottom` | — | `CYLImageTagDirectionLeftBottom` (same name in the iOS core) |
| `CYLImageTagDirection.CYLImageTagDirectionLeftBottomStraight` | — | `CYLImageTagDirectionLeftBottomStraight` (same name in the iOS core) |
| `CYLImageTagDirection.CYLImageTagDirectionRightCenter` | — | `CYLImageTagDirectionRightCenter` (same name in the iOS core) |
| `CYLImageTagDirection.CYLImageTagDirectionRightTop` | — | `CYLImageTagDirectionRightTop` (same name in the iOS core) |
| `CYLImageTagDirection.CYLImageTagDirectionRightTopStraight` | — | `CYLImageTagDirectionRightTopStraight` (same name in the iOS core) |
| `CYLImageTagDirection.CYLImageTagDirectionRightBottom` | — | `CYLImageTagDirectionRightBottom` (same name in the iOS core) |
| `CYLImageTagDirection.CYLImageTagDirectionRightBottomStraight` | — | `CYLImageTagDirectionRightBottomStraight` (same name in the iOS core) |
| `CYLImageTagDirection.CYLImageTagDirectionCenter` | — | `CYLImageTagDirectionCenter` (same name in the iOS core) |
| `CYLImageTagDirectionNext` | `CYLImageTagDirectionNext`: the next direction, the last one (and Center) wrapping to LeftCenter. | `CYLImageTagDirectionNext` |
| **interface `CYLImageTagItem`** | `CYLImageTagItem`: a view shown as a tag of a group. | `CYLImageTagItem` |
| `CYLImageTagItem.tagDirection` | Where the view sits around the dot. | `CYLImageTagItem.tagDirection` |
| **class `CYLImageTag`** | `CYLImageTag`: a tag of a picture: its title, direction, link and user info. | `CYLImageTag` |
| `CYLImageTag.link` | A link the tag opens, if any. | `CYLImageTag.link` |
| `CYLImageTag.userInfo` | Anything the app attaches. | `CYLImageTag.userInfo` |
| `CYLImageTag.copy` | `-copy`. | `copy` (same name in the iOS core) |
| **class `CYLImageTagGroup`** | `CYLImageTagGroup`: the tags around one dot, at a position given in fractions of the picture (0…1). | `CYLImageTagGroup` |
| `CYLImageTagGroup.copy` | `-copy`: the tags are copied too. | `copy` (same name in the iOS core) |
| **class `CYLImageTagLabel`** | `CYLImageTagLabel`: the default tag view: white 13 sp text with a shadow, inside `contentInsets`. | `CYLImageTagLabel` |
| `CYLImageTagLabel.contentInsets` | The space around the text, dp (4, 12, 4, 12 by default). | `CYLImageTagLabel.contentInsets` |
| **class `CYLImageTagRippleView`** | `CYLImageTagRippleView`: a circle growing and fading from the dot, repeated every second (not with Reduce Motion). | `CYLImageTagRippleView` |
| `CYLImageTagRippleView.maximumRadius` | The radius the ripple grows to, dp. | `CYLImageTagRippleView.maximumRadius` |
| `CYLImageTagRippleView.startAlpha` | The opacity the ripple starts with (100 / 255 by default). | `CYLImageTagRippleView.startAlpha` |
| `CYLImageTagRippleView.color` | The ripple's color (white by default). | `CYLImageTagRippleView.color` |
| `CYLImageTagRippleView.startAnimating` | `-startAnimating`. | `CYLImageTagRippleView -startAnimating` |
| `CYLImageTagRippleView.stopAnimating` | `-stopAnimating`. | `CYLImageTagRippleView -stopAnimating` |
| `CYLImageTagRippleView.isAnimating` | Whether the ripple is animating. | `isAnimating` (same name in the iOS core) |
| **interface `CYLImageTagGroupViewDataSource`** | `CYLImageTagGroupViewDataSource`: custom tag views instead of `tags`. | `CYLImageTagGroupViewDataSource` |
| `CYLImageTagGroupViewDataSource.numberOfTagsInGroupView` | The number of tags (at most `CYLImageTagGroupMaximumTagCount` are shown). | `CYLImageTagGroupViewDataSource -numberOfTagsInGroupView:` |
| `CYLImageTagGroupViewDataSource.groupViewViewForTagAtIndex` | The view of a tag. | `CYLImageTagGroupViewDataSource -groupView:viewForTagAtIndex:` |
| **interface `CYLImageTagGroupViewDelegate`** | `CYLImageTagGroupViewDelegate`: taps, long press and drags of a group; every method is optional. | `CYLImageTagGroupViewDelegate` |
| `CYLImageTagGroupViewDelegate.groupViewDidTapCircle` | `-groupViewDidTapCircle:`. | `groupViewDidTapCircle` (same name in the iOS core) |
| `CYLImageTagGroupViewDelegate.groupViewDidTapTagAtIndex` | `-groupView:didTapTagAtIndex:`. | `CYLImageTagGroupViewDelegate.groupView(_:didTapTagAt:)` |
| `CYLImageTagGroupViewDelegate.groupViewDidLongPress` | `-groupViewDidLongPress:`. | `groupViewDidLongPress` (same name in the iOS core) |
| `CYLImageTagGroupViewDelegate.groupViewDidDragToPercentPosition` | `-groupView:didDragToPercentPosition:`. | `CYLImageTagGroupViewDelegate.groupView(_:didDragToPercentPosition:)` |
| `CYLImageTagGroupViewDelegate.handlesLongPress` | Whether `groupViewDidLongPress` is implemented (respondsToSelector on iOS). | `CYLImageTagGroupViewDelegate.groupViewDidLongPress(_:)` (a Swift protocol method with a default; Android needs a flag instead of `respondsToSelector:`) |
| **class `CYLImageTagGroupView`** | `CYLImageTagGroupView`: a dot on a picture with up to six tags around it, joined by lines (TagViewGroup): position in fractions of the view, ripple, show / hide animations, tap, lo | `CYLImageTagGroupView` |
| `CYLImageTagGroupView.circleRadius` | — | `CYLImageTagGroupView.circleRadius` |
| `CYLImageTagGroupView.circleInnerRadius` | — | `CYLImageTagGroupView.circleInnerRadius` |
| `CYLImageTagGroupView.lineWidth` | — | `CYLImageTagGroupView.lineWidth` |
| `CYLImageTagGroupView.verticalDistance` | — | `CYLImageTagGroupView.verticalDistance` |
| `CYLImageTagGroupView.tiltDistance` | — | `CYLImageTagGroupView.tiltDistance` |
| `CYLImageTagGroupView.circleColor` | — | `CYLImageTagGroupView.circleColor` |
| `CYLImageTagGroupView.circleInnerColor` | — | `CYLImageTagGroupView.circleInnerColor` |
| `CYLImageTagGroupView.lineColor` | — | `CYLImageTagGroupView.lineColor` |
| `CYLImageTagGroupView.percentPosition` | The dot's position in fractions of the view, each clamped to 0…1. | `CYLImageTagGroupView.percentPosition` |
| `CYLImageTagGroupView.setPercentX` | `-setPercentX:percentY:`. | `CYLImageTagGroupView -setPercentX:percentY:` |
| `CYLImageTagGroupView.centerPoint` | The dot's center after layout, dp. | `CYLImageTagGroupView.centerPoint` |
| `CYLImageTagGroupView.displayOffset` | An offset added to the dot (the picture view moves groups apart with it), dp. | `CYLImageTagGroupView.displayOffset` |
| `CYLImageTagGroupView.occupiedFrame` | The dot and the tags' frames together, dp. | `CYLImageTagGroupView.occupiedFrame` |
| `CYLImageTagGroupView.tags` | The tags (a copy); setting them rebuilds the tag views. | `CYLImageTagGroupView.tags` |
| `CYLImageTagGroupView.dataSource` | — | `CYLImageTagGroupView.dataSource` |
| `CYLImageTagGroupView.tagViews` | The tag views, in order. | `CYLImageTagGroupView.tagViews` |
| `CYLImageTagGroupView.tagLabelConfiguration` | Called for every default label, to style it. | `tagLabelConfiguration` (same name in the iOS core) |
| `CYLImageTagGroupView.reloadData` | `-reloadData`: rebuilds the tag views from the data source or from `tags`. | `CYLImageTagGroupView -reloadData` |
| `CYLImageTagGroupView.showsRipple` | — | `CYLImageTagGroupView.showsRipple` |
| `CYLImageTagGroupView.rippleMaxRadius` | — | `CYLImageTagGroupView.rippleMaxRadius` |
| `CYLImageTagGroupView.rippleAlpha` | — | `CYLImageTagGroupView.rippleAlpha` |
| `CYLImageTagGroupView.rippleView` | — | `CYLImageTagGroupView.rippleView` |
| `CYLImageTagGroupView.linesProgress` | How much of each line is drawn, 0…1. | `CYLImageTagGroupView.linesProgress` |
| `CYLImageTagGroupView.tagAlpha` | The tags' opacity, 0…1. | `CYLImageTagGroupView.tagAlpha` |
| `CYLImageTagGroupView.animateValueForKey` | `-animateValueForKey:values:duration:completion:`: animates one of the `CYLImageTagGroupKey…` values through `values` (eased out); with Reduce Motion, or no duration, it jumps to t | `CYLImageTagGroupView -animateValueForKey:values:duration:completion:` |
| `CYLImageTagGroupView.isGroupHidden` | Whether the group is hidden by `hideAnimated`. | `isGroupHidden` (same name in the iOS core) |
| `CYLImageTagGroupView.groupHidden` | `groupHidden`. | `CYLImageTagGroupView.groupHidden` |
| `CYLImageTagGroupView.showAnimation` | — | `showAnimation` (same name in the iOS core) |
| `CYLImageTagGroupView.hideAnimation` | — | `hideAnimation` (same name in the iOS core) |
| `CYLImageTagGroupView.showAnimated` | `-showAnimated:completion:`: the dot bounces, the lines draw, then the tags fade in. | `CYLImageTagGroupView -showAnimated:completion:` |
| `CYLImageTagGroupView.hideAnimated` | `-hideAnimated:completion:`: the dot bounces, the tags fade and the lines retract, then the group hides. | `CYLImageTagGroupView -hideAnimated:completion:` |
| `CYLImageTagGroupView.delegate` | — | `CYLImageTagGroupView.delegate` |
| `CYLImageTagGroupView.draggable` | — | `CYLImageTagGroupView.draggable` |
| `CYLImageTagGroupView.isDraggable` | `isDraggable`. | `isDraggable` (same name in the iOS core) |
| `CYLImageTagGroupView.circleAccessibilityElement` | The dot as an accessibility element ("Tag group: …"), with the long press and move actions. | `CYLImageTagGroupView.circleAccessibilityElement` |
| `CYLImageTagGroupView.longPressAccessibilityActionName` | — | `CYLImageTagGroupView.longPressAccessibilityActionName` |
| `CYLImageTagGroupView.tagAccessibilityHint` | — | `CYLImageTagGroupView.tagAccessibilityHint` |
| `CYLImageTagGroupView.accessibilityMoveStep` | How far a move action moves the dot, in fractions of the view (0.05). | `CYLImageTagGroupView.accessibilityMoveStep` |
| `CYLImageTagGroupView.tagSpaceUsed` | `-tagSpaceUsed`: how far the tags reach from the dot on each side, dp. | `CYLImageTagGroupView -tagSpaceUsed` |
| `CYLImageTagGroupView.originForTagOfSize` | `-originForTagOfSize:direction:`: the top-left corner of a tag of `size` in `direction`, dp. | `CYLImageTagGroupView -originForTagOfSize:direction:` |
| `CYLImageTagGroupView.layoutGroup` | Lays the dot and the tags out now (`-layoutIfNeeded` on iOS); the picture view calls it to move groups apart. | `UIView.layoutIfNeeded()` on the group view |
| `CYLImageTagGroupView.frameOfTagView` | The frame of a tag view after layout, dp. | `UIView.frame` of the tag view (after `layoutIfNeeded()`) |
| `CYLImageTagGroupView.pointInside` | `-pointInside:withEvent:`: only the dot and the tags take touches (dp). | `CYLImageTagGroupView.point(inside:with:)` (only the dot and the tags take touches) |
| **class `CYLImageTagView`** | `CYLImageTagView`: a picture with tag groups (TagViewGroup's sample): groups from models, edit mode (drag the dots, tap a tag to turn it), show / hide all groups, groups moved apar | `CYLImageTagView` |
| `CYLImageTagView.imageView` | The picture, filling the view (center crop). | `CYLImageTagView.imageView` |
| `CYLImageTagView.image` | The picture (`imageView`'s drawable). | `CYLImageTagView.image` |
| `CYLImageTagView.tagGroups` | The groups (copies); setting them replaces every group. | `CYLImageTagView.tagGroups` |
| `CYLImageTagView.addTagGroup` | `-addTagGroup:`: adds a copy of the group and its view. | `CYLImageTagView -addTagGroup:` |
| `CYLImageTagView.removeTagGroupAtIndex` | `-removeTagGroupAtIndex:`. | `CYLImageTagView -removeTagGroupAtIndex:` |
| `CYLImageTagView.removeAllTagGroups` | `-removeAllTagGroups`. | `CYLImageTagView -removeAllTagGroups` |
| `CYLImageTagView.groupViews` | The group views, in order. | `CYLImageTagView.groupViews` |
| `CYLImageTagView.editing` | Edit mode: dots can be dragged and a tap turns a tag; no ripple. | `CYLImageTagView.editing` |
| `CYLImageTagView.isEditing` | `isEditing`. | `isEditing` (same name in the iOS core) |
| `CYLImageTagView.toggleTagGroupsAnimated` | `-toggleTagGroupsAnimated:`: shows hidden groups and hides shown ones. | `CYLImageTagView -toggleTagGroupsAnimated:` |
| `CYLImageTagView.groupConfiguration` | Called for every new group view, to style it. | `groupConfiguration` (same name in the iOS core) |
| `CYLImageTagView.imageTapHandler` | — | `imageTapHandler` (same name in the iOS core) |
| `CYLImageTagView.circleTapHandler` | — | `circleTapHandler` (same name in the iOS core) |
| `CYLImageTagView.tagTapHandler` | — | `tagTapHandler` (same name in the iOS core) |
| `CYLImageTagView.longPressHandler` | — | `longPressHandler` (same name in the iOS core) |
| `CYLImageTagView.dragHandler` | — | `dragHandler` (same name in the iOS core) |
| `CYLImageTagView.imageAccessibilityHint` | — | `CYLImageTagView.imageAccessibilityHint` |
| `CYLImageTagView.longPressAccessibilityActionName` | — | `CYLImageTagView.longPressAccessibilityActionName` |
| `CYLMenuColorFromString` | `CYLMenuColorFromString`: "#RGB", "#RRGGBB", "#RRGGBBAA" (alpha last, as on iOS), or the name of a UIColor class property ("systemBlue", "systemBlueColor", "red"…); null when it is | `UIColor.cylMenuColor(from:)` |
| **enum `CYLMenuItemType`** | `CYLMenuItemType`: a tag, or the "+ New tag" item that asks for a name. | `CYLMenuItemType` |
| **interface `CYLMenuDataSource`** | `CYLMenuDataSource`: the sections and items of a tag list. | `CYLMenuDataSource` |
| `CYLMenuDataSource.numberOfSectionsInMenu` | — | `CYLMenuDataSource -numberOfSectionsInMenu` |
| `CYLMenuDataSource.menuNumberOfItemsInSection` | — | `CYLMenuDataSource -menuNumberOfItemsInSection:` |
| `CYLMenuDataSource.menuTitleForSection` | — | `CYLMenuDataSource -menuTitleForSection:` |
| `CYLMenuDataSource.menuTitleForItemAtIndexPath` | — | `CYLMenuDataSource -menuTitleForItemAtIndexPath:` |
| `CYLMenuDataSource.menuImageForItemAtIndexPath` | — | `CYLMenuDataSource -menuImageForItemAtIndexPath:` |
| `CYLMenuDataSource.menuSelectedImageForItemAtIndexPath` | — | `CYLMenuDataSource -menuSelectedImageForItemAtIndexPath:` |
| `CYLMenuDataSource.menuAnimationURLForItemAtIndexPath` | — | `CYLMenuDataSource -menuAnimationURLForItemAtIndexPath:` |
| `CYLMenuDataSource.menuAnimationRestingProgressForItemAtIndexPath` | — | `CYLMenuDataSource -menuAnimationRestingProgressForItemAtIndexPath:` |
| `CYLMenuDataSource.menuStyleForSection` | — | `CYLMenuDataSource -menuStyleForSection:` |
| `CYLMenuDataSource.menuStyleForItemAtIndexPath` | — | `CYLMenuDataSource -menuStyleForItemAtIndexPath:` |
| `CYLMenuDataSource.menuImageForSection` | — | `CYLMenuDataSource -menuImageForSection:` |
| `CYLMenuDataSource.menuAccessoryViewForSection` | — | `CYLMenuDataSource -menuAccessoryViewForSection:` |
| `CYLMenuDataSource.menuItemIsEnabledAtIndexPath` | — | `CYLMenuDataSource -menuItemIsEnabledAtIndexPath:` |
| `CYLMenuDataSource.menuItemIsExclusiveAtIndexPath` | — | `CYLMenuDataSource -menuItemIsExclusiveAtIndexPath:` |
| `CYLMenuDataSource.menuItemIsSelectableAtIndexPath` | — | `CYLMenuDataSource -menuItemIsSelectableAtIndexPath:` |
| `CYLMenuDataSource.menuItemTypeAtIndexPath` | — | `CYLMenuDataSource -menuItemTypeAtIndexPath:` |
| `CYLMenuDataSource.menuAccessibilityHintForItemAtIndexPath` | — | `CYLMenuDataSource -menuAccessibilityHintForItemAtIndexPath:` |
| `CYLMenuDataSource.menuShowsMoreButtonInSection` | — | `CYLMenuDataSource -menuShowsMoreButtonInSection:` |
| `CYLMenuDataSource.menuAccessibilityLabelForMoreButtonInSection` | — | `CYLMenuDataSource -menuAccessibilityLabelForMoreButtonInSection:` |
| `CYLMenuDataSource.menuItemIsDeletableAtIndexPath` | — | `CYLMenuDataSource -menuItemIsDeletableAtIndexPath:` |
| `CYLMenuDataSource.menuRemoveItemAtIndexPath` | — | `CYLMenuDataSource -menuRemoveItemAtIndexPath:` |
| `CYLMenuDataSource.menuMoveItemAtIndexPath` | Optional on iOS: a list may only reorder items when its data source moves them. | `CYLMenuDataSource -menuMoveItemAtIndexPath:toIndexPath:` |
| `CYLMenuDataSource.supportsMovingItems` | Whether `menuMoveItemAtIndexPath` is implemented (`respondsToSelector:` on iOS). | `responds(to: #selector(CYLMenuDataSource.menuMoveItem(at:to:)))` (optional Objective-C method; `CYLTagListView` checks it) |
| **interface `CYLMenuDelegate`** | `CYLMenuDelegate`: selection, new items, folding, height, the More button, deletion, long press, reordering and dragging of a tag list. | `CYLMenuDelegate` |
| `CYLMenuDelegate.menuShouldSelectItemAtIndexPath` | — | `CYLMenuDelegate -menu:shouldSelectItemAtIndexPath:` |
| `CYLMenuDelegate.menuDidSelectItemAtIndexPath` | — | `CYLMenuDelegate -menu:didSelectItemAtIndexPath:` |
| `CYLMenuDelegate.menuDidRequestNewItemWithName` | — | `CYLMenuDelegate -menu:didRequestNewItemWithName:atIndexPath:` |
| `CYLMenuDelegate.menuDidDeselectItemAtIndexPath` | — | `CYLMenuDelegate -menu:didDeselectItemAtIndexPath:` |
| `CYLMenuDelegate.menuDidChangeSelectedItems` | — | `CYLMenuDelegate -menu:didChangeSelectedItems:` |
| `CYLMenuDelegate.menuDidConfirmSelectedItems` | — | `CYLMenuDelegate -menu:didConfirmSelectedItems:` |
| `CYLMenuDelegate.menuDidChangeExpanded` | — | `CYLMenuDelegate -menu:didChangeExpanded:inSection:` |
| `CYLMenuDelegate.menuDidChangeContentHeight` | — | `CYLMenuDelegate -menu:didChangeContentHeight:` |
| `CYLMenuDelegate.menuDidTapMoreButtonInSection` | — | `CYLMenuDelegate -menu:didTapMoreButtonInSection:` |
| `CYLMenuDelegate.menuDidDeleteItemAtIndexPath` | — | `CYLMenuDelegate -menu:didDeleteItemAtIndexPath:` |
| `CYLMenuDelegate.menuDidLongPressItemAtIndexPath` | — | `CYLMenuDelegate -menu:didLongPressItemAtIndexPath:` |
| `CYLMenuDelegate.menuDidMoveItemAtIndexPath` | — | `CYLMenuDelegate -menu:didMoveItemAtIndexPath:toIndexPath:` |
| `CYLMenuDelegate.menuDidBeginDraggingSelectedItemAtIndexPath` | — | `CYLMenuDelegate -menu:didBeginDraggingSelectedItemAtIndexPath:` |
| `CYLMenuDelegate.handlesLongPress` | Whether the long press is handled (`respondsToSelector:` of `menu:didLongPressItemAtIndexPath:`). | `responds(to: #selector(CYLMenuDelegate.menu(_:didLongPressItemAt:)))` (optional Objective-C method; `CYLTagListView` checks it) |
| **enum `CYLMenuFoldControlPosition`** | `CYLMenuFoldControlPosition`: where a section's fold control sits. | `CYLMenuFoldControlPosition` |
| `CYLMenuFoldControlPosition.NONE` | — | `CYLMenuFoldControlPositionNone` |
| `CYLMenuFoldControlPosition.FOOTER` | — | `CYLMenuFoldControlPositionFooter` |
| `CYLMenuFoldControlPosition.HEADER_TRAILING` | — | `CYLMenuFoldControlPositionHeaderTrailing` |
| `CYLMenuFoldControlPosition.HEADER_LEADING` | — | `CYLMenuFoldControlPositionHeaderLeading` |
| `CYLMenuFoldControlPosition.TAIL` | — | `CYLMenuFoldControlPositionTail` |
| **enum `CYLMenuFoldControlContent`** | `CYLMenuFoldControlContent`: what a fold control shows. | `CYLMenuFoldControlContent` |
| `CYLMenuFoldControlContent.CYLMenuFoldControlContentIconAndTitle` | — | `CYLMenuFoldControlContentIconAndTitle` (same name in the iOS core) |
| `CYLMenuFoldControlContent.CYLMenuFoldControlContentTitle` | — | `CYLMenuFoldControlContentTitle` (same name in the iOS core) |
| `CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon` | — | `CYLMenuFoldControlContentIcon` (same name in the iOS core) |
| **class `CYLMenuFoldControl`** | `CYLMenuFoldControl`: the control that expands or collapses a folded section: its position, content, titles, image (a chevron by default, turned when expanded), color and font. | `CYLMenuFoldControl` |
| `CYLMenuFoldControl.position` | — | `CYLMenuFoldControl.position` |
| `CYLMenuFoldControl.content` | — | `CYLMenuFoldControl.content` |
| `CYLMenuFoldControl.title` | null_resettable: "Expand" (localized) by default. | `CYLMenuFoldControl.title` |
| `CYLMenuFoldControl.collapseTitle` | null_resettable: "Collapse" (localized) by default. | `CYLMenuFoldControl.collapseTitle` |
| `CYLMenuFoldControl.image` | null_resettable: a chevron by default. | `CYLMenuFoldControl.image` |
| `CYLMenuFoldControl.usesDefaultImage` | Whether `image` is the default chevron. | `CYLMenuFoldControl.usesDefaultImage` |
| `CYLMenuFoldControl.color` | — | `CYLMenuFoldControl.color` |
| `CYLMenuFoldControl.font` | — | `CYLMenuFoldControl.font` |
| `CYLMenuFoldControl.rotatesImageWhenExpanded` | — | `CYLMenuFoldControl.rotatesImageWhenExpanded` |
| `CYLMenuFoldControl.showsImageWhenExpanded` | — | `CYLMenuFoldControl -showsImageWhenExpanded:` |
| `CYLMenuFoldControl.showsTitleWhenExpanded` | — | `CYLMenuFoldControl -showsTitleWhenExpanded:` |
| `CYLMenuFoldControl.titleWhenExpanded` | — | `CYLMenuFoldControl -titleWhenExpanded:` |
| `CYLMenuFoldControl.copy` | NSCopying. | `CYLMenuFoldControl -copyWith:` |
| **class `CYLMenuIconDrawable`** | The core's default icons, drawn in code (SF Symbols on iOS): the fold chevron ("chevron.down"), the plus of the "+ New tag" item ("plus") and the More button ("ellipsis"). | the bundle images `cyl_fold_chevron`, `cyl_tag_plus`, `cyl_more` (`CYLMenuResources.image(named:)`, SF Symbol fallback); Android draws them |
| **enum `Kind`** | — | `CYLMenuIconDrawable.Kind` → the bundle images `cyl_fold_chevron` (CHEVRON_DOWN), `cyl_tag_plus` (PLUS), `cyl_more` (ELLIPSIS) |
| **object `CYLMenuResources`** | The core's localized strings and images: the same `<language>.lproj/CYLClassifyMenu.strings` tables as iOS (`CYLClassifyMenuResources.bundle`), packaged as Java resources under `CY | `CYLMenuResources` |
| `CYLMenuResources.bundle` | `+bundle`: the resource folder's name in the library's Java resources. | `CYLMenuResources +bundle` |
| `CYLMenuResources.imageNamed` | `+imageNamed:`: a drawable of the bundle's images (`CYLClassifyMenuResources/<name>@3x.png`, `@2x` or 1x, copied from the iOS asset catalog), scaled like the iOS image (3x as xxhdp | `CYLMenuResources +imageNamed:` |
| `CYLMenuResources.availableLanguages` | `+availableLanguages`, sorted. | `CYLMenuResources +availableLanguages` |
| `CYLMenuResources.preferredLanguage` | `preferredLanguage`: a language of `availableLanguages()` used instead of the system's; null for the system's. | `CYLMenuResources.preferredLanguage` |
| `CYLMenuResources.currentLanguage` | `+currentLanguage`: the preferred language when set, else the system language, else English. | `CYLMenuResources +currentLanguage` |
| `CYLMenuResources.localizedStringForKey` | `+localizedStringForKey:`. | `CYLMenuResources +localizedStringForKey:` |
| `CYLMenuLocalizedStringForKey` | `CYLMenuLocalizedStringForKey` / the macro `CYLMenuLocalizedString(key, comment)`. | `CYLMenuLocalizedString(_:)` |
| `CYLMenuLocalizedString` | The macro `CYLMenuLocalizedString(key, comment)`: the comment only documents the key. | `CYLMenuLocalizedString` |
| `CYLMenuImage` | The macro `CYLMenuImage(name)`. | `CYLMenuResources.image(named:)` |
| **enum `CYLTagImagePlacement`** | `CYLTagImagePlacement`: the icon before or after the title. | `CYLTagImagePlacement` |
| **enum `CYLTagContentAlignment`** | `CYLTagContentAlignment`: the icon and title centered in the tag, or at its leading edge. | `CYLTagContentAlignment` |
| **enum `CYLTagRowAlignment`** | `CYLTagRowAlignment`: where a row of tags sits in the list's width. | `CYLTagRowAlignment` |
| **enum `CYLTagDeleteIndicatorPlacement`** | `CYLTagDeleteIndicatorPlacement`: the delete indicator after or before the title. | `CYLTagDeleteIndicatorPlacement` |
| **class `CYLMenuStyle`** | `CYLMenuStyle`: the look of a tag list: the tags in each state (`CYLTagAppearance`), the delete indicator, the touch ripple, titles, rows, icons, layout spacing, section headers, f | `CYLMenuStyle` |
| `CYLMenuStyle.normalAppearance` | — | `CYLMenuStyle.normalAppearance` |
| `CYLMenuStyle.selectedAppearance` | — | `CYLMenuStyle.selectedAppearance` |
| `CYLMenuStyle.disabledAppearance` | — | `CYLMenuStyle.disabledAppearance` |
| `CYLMenuStyle.highlightedBackgroundColor` | — | `CYLMenuStyle.highlightedBackgroundColor` |
| `CYLMenuStyle.deleteIndicatorTitle` | — | `CYLMenuStyle.deleteIndicatorTitle` |
| `CYLMenuStyle.deleteIndicatorColor` | — | `CYLMenuStyle.deleteIndicatorColor` |
| `CYLMenuStyle.deleteIndicatorFont` | — | `CYLMenuStyle.deleteIndicatorFont` |
| `CYLMenuStyle.deleteIndicatorLineWidth` | — | `CYLMenuStyle.deleteIndicatorLineWidth` |
| `CYLMenuStyle.deleteIndicatorWidth` | — | `CYLMenuStyle.deleteIndicatorWidth` |
| `CYLMenuStyle.deleteIndicatorPadding` | — | `CYLMenuStyle.deleteIndicatorPadding` |
| `CYLMenuStyle.deleteIndicatorPlacement` | — | `CYLMenuStyle.deleteIndicatorPlacement` |
| `CYLMenuStyle.rippleColor` | — | `CYLMenuStyle.rippleColor` |
| `CYLMenuStyle.rippleAlpha` | — | `CYLMenuStyle.rippleAlpha` |
| `CYLMenuStyle.rippleDuration` | Seconds, as `NSTimeInterval`. | `CYLMenuStyle.rippleDuration` |
| `CYLMenuStyle.maximumTitleLength` | — | `CYLMenuStyle.maximumTitleLength` |
| `CYLMenuStyle.reversesTitleCharacters` | — | `CYLMenuStyle.reversesTitleCharacters` |
| `CYLMenuStyle.rowAlignment` | — | `CYLMenuStyle.rowAlignment` |
| `CYLMenuStyle.headerIndicatorColor` | — | `CYLMenuStyle.headerIndicatorColor` |
| `CYLMenuStyle.headerIndicatorSize` | — | `CYLMenuStyle.headerIndicatorSize` |
| `CYLMenuStyle.imageCornerRadius` | — | `CYLMenuStyle.imageCornerRadius` |
| `CYLMenuStyle.imageTitleSpacing` | — | `CYLMenuStyle.imageTitleSpacing` |
| `CYLMenuStyle.imageSize` | — | `CYLMenuStyle.imageSize` |
| `CYLMenuStyle.imageInsets` | — | `CYLMenuStyle.imageInsets` |
| `CYLMenuStyle.titlePositionAdjustment` | — | `CYLMenuStyle.titlePositionAdjustment` |
| `CYLMenuStyle.imagePositionAdjustment` | — | `CYLMenuStyle.imagePositionAdjustment` |
| `CYLMenuStyle.imagePlacement` | — | `CYLMenuStyle.imagePlacement` |
| `CYLMenuStyle.layoutCentered` | — | `CYLMenuStyle.layoutCentered` |
| `CYLMenuStyle.contentAlignment` | — | `CYLMenuStyle.contentAlignment` |
| `CYLMenuStyle.animationSize` | — | `CYLMenuStyle.animationSize` |
| `CYLMenuStyle.animationSpeed` | — | `CYLMenuStyle.animationSpeed` |
| `CYLMenuStyle.adjustsFontForContentSizeCategory` | — | `CYLMenuStyle.adjustsFontForContentSizeCategory` |
| `CYLMenuStyle.itemHeight` | — | `CYLMenuStyle.itemHeight` |
| `CYLMenuStyle.numberOfItemsPerRow` | — | `CYLMenuStyle.numberOfItemsPerRow` |
| `CYLMenuStyle.interitemSpacing` | — | `CYLMenuStyle.interitemSpacing` |
| `CYLMenuStyle.lineSpacing` | — | `CYLMenuStyle.lineSpacing` |
| `CYLMenuStyle.sectionInsets` | — | `CYLMenuStyle.sectionInsets` |
| `CYLMenuStyle.backgroundColor` | — | `CYLMenuStyle.backgroundColor` |
| `CYLMenuStyle.headerHeight` | — | `CYLMenuStyle.headerHeight` |
| `CYLMenuStyle.headerFont` | — | `CYLMenuStyle.headerFont` |
| `CYLMenuStyle.headerTextColor` | — | `CYLMenuStyle.headerTextColor` |
| `CYLMenuStyle.headerHorizontalInset` | — | `CYLMenuStyle.headerHorizontalInset` |
| `CYLMenuStyle.foldControlColor` | — | `CYLMenuStyle.foldControlColor` |
| `CYLMenuStyle.expandTitle` | — | `CYLMenuStyle.expandTitle` |
| `CYLMenuStyle.foldChevronImage` | — | `CYLMenuStyle.foldChevronImage` |
| `CYLMenuStyle.collapseTitle` | — | `CYLMenuStyle.collapseTitle` |
| `CYLMenuStyle.moreButtonImage` | — | `CYLMenuStyle.moreButtonImage` |
| `CYLMenuStyle.moreButtonColor` | — | `CYLMenuStyle.moreButtonColor` |
| `CYLMenuStyle.tagContentInsets` | The content insets of every state; reads the normal state's. | `CYLMenuStyle.tagContentInsets` |
| `CYLMenuStyle.appearanceForState` | `-appearanceForState:`: disabled wins over selected, which wins over normal. | `CYLMenuStyle -appearanceForState:` |
| `CYLMenuStyle.displayedTitleForTitle` | `-displayedTitleForTitle:`: at most `maximumTitleLength` characters (whole grapheme clusters) then "...", and reversed character by character when `reversesTitleCharacters`. | `CYLMenuStyle -displayedTitleForTitle:` |
| `CYLMenuStyle.setTitleTextAttributes` | `-setTitleTextAttributes:forState:`: the font and text color of `state` (null resets them). | `CYLMenuStyle -setTitleTextAttributes:forState:` |
| `CYLMenuStyle.titleTextAttributesForState` | `-titleTextAttributesForState:`: the font and text color of `state`. | `CYLMenuStyle -titleTextAttributesForState:` |
| `CYLMenuStyle.setIconColor` | `-setIconColor:forState:`. | `CYLMenuStyle -setIconColor:forState:` |
| `CYLMenuStyle.iconColorForState` | `-iconColorForState:`: the icon color, else the text color. | `CYLMenuStyle -iconColorForState:` |
| `CYLMenuStyle.titleFontForState` | `-titleFontForState:traitCollection:`; the trait collection is the font scale and Bold Text. | `CYLMenuStyle -titleFontForState:traitCollection:` |
| `CYLMenuStyle.deleteIndicatorFontForState` | `-deleteIndicatorFontForState:traitCollection:`: `deleteIndicatorFont`, else the title font. | `CYLMenuStyle -deleteIndicatorFontForState:traitCollection:` |
| `CYLMenuStyle.headerFontForTraitCollection` | `-headerFontForTraitCollection:`. | `CYLMenuStyle -headerFontForTraitCollection:` |
| `CYLMenuStyle.copy` | NSCopying. | `CYLMenuStyle -copyWith:` |
| **class `CYLFilterParamsTool`** | `CYLFilterParamsTool`: the state of the multiple filter: the titles per section (`dataSources`) and a selected flag per item (`filterParamsArray`, the first item of each section se | TODO |
| `CYLFilterParamsTool.dataSources` | The titles, one list per section. | TODO |
| `CYLFilterParamsTool.filterParamsArray` | One selected flag per item; made from `dataSources` (first item selected) on first use. | `CYLMultipleFilterController.selectedIndexPaths()` / `setSelectedIndexPaths(_:)` (index paths instead of flags) |
| `CYLFilterParamsTool.filterParamsDictionary` | The settings and the modified flag. | TODO |
| `CYLFilterParamsTool.filterParamsContentDictionary` | Free-form content of the filter ("skilled" by default, as on iOS). | TODO |
| `CYLFilterParamsTool.filename` | Where the settings are saved: `kMultipleFilterSetting` in the app's files folder (the documents folder on iOS), once `filesDir` is known; set it to choose another file. | TODO |
| `CYLFilterParamsTool.filesDir` | The folder `filename` defaults to (an app sets `context.filesDir`). | N/A on iOS: `CYLFilterParamsTool` was removed in the Swift migration (`70dcc816`); `CYLMultipleFilterController` keeps its state (`selectedIndexPaths()` / `setSelectedIndexPaths(_:)`) |
| **class `CYLFilterCollectionCell`** | `CYLFilterCollectionCell`: an item of the multiple filter: a button with the slide backgrounds (green title, white when selected), not touchable itself (the cell is). | `CYLFilterCollectionCell` |
| `CYLFilterCollectionCell.titleButton` | — | `CYLFilterCollectionCell.titleButton` |
| **class `CYLMultipleFilterHeaderView`** | `CYLMultipleFilterHeaderView`: a section header of the multiple filter: an image at the leading edge and the title (50 dp in, half-transparent black) above a green line. | `CYLMultipleFilterHeaderView` |
| `CYLMultipleFilterHeaderView.imageView` | — | `CYLMultipleFilterHeaderView.imageView` |
| `CYLMultipleFilterHeaderView.titleLabel` | — | `CYLMultipleFilterHeaderView.titleLabel` |
| **interface `CYLFilterControllerDelegate`** | `CYLFilterControllerDelegate`: the filter panel closed after Apply or Reset. | `CYLFilterControllerDelegate` |
| `CYLFilterControllerDelegate.filterControllerDidComplete` | `-filterControllerDidComplete:`. | `CYLFilterControllerDelegate -filterControllerDidComplete:` |
| **class `CYLFilterBaseController`** | `CYLFilterBaseController`: a panel that slides in from the leading edge over a dimmed screen, on a blurred capture of the screen, with Reset and Apply buttons at the bottom; tappin | `CYLFilterBaseController` |
| `CYLFilterBaseController.collectionView` | The panel's scrolling content (the collection view on iOS). | `CYLFilterBaseController.collectionView` |
| `CYLFilterBaseController.contentView` | The dimmed area beside the panel. | `CYLFilterBaseController.contentView` |
| `CYLFilterBaseController.restoreButton` | — | `CYLFilterBaseController.restoreButton` |
| `CYLFilterBaseController.okButton` | — | `CYLFilterBaseController.okButton` |
| `CYLFilterBaseController.dataSource` | Free-form data of a subclass. | `CYLFilterBaseController.dataSource` |
| `CYLFilterBaseController.settingArray` | Free-form settings of a subclass. | TODO |
| `CYLFilterBaseController.delegate` | — | `CYLFilterBaseController.delegate` |
| `CYLFilterBaseController.showInView` | `-showInView:`: captures and blurs `view` as the panel's background, adds the panel over it and slides it in. | `CYLFilterBaseController -showInView:` |
| `CYLFilterBaseController.hide` | Closes the panel without applying (a tap on the dimmed area). | `hide` (same name in the iOS core) |
| `CYLFilterBaseController.itemButtonClicked` | `-itemButtonClicked:`: a subclass's item was tapped (nothing in the base class). | `CYLFilterBaseController -itemButtonClicked:` |
| `CYLFilterBaseController.confirmButtonClicked` | `-confirmButtonClicked:`: closes the panel, then tells the delegate. | `CYLFilterBaseController -confirmButtonClicked:` |
| `CYLFilterBaseController.restoreButtonClicked` | `-restoreButtonClicked:`: closes like Apply (a subclass resets first). | `CYLFilterBaseController -restoreButtonClicked:` |
| `CYLFilterBaseController.isShowing` | Whether the panel is on screen. | `isShowing` (same name in the iOS core) |
| **class `CYLMultipleFilterController`** | `CYLMultipleFilterController`: the multiple-choice filter: sections of items from a `CYLMenuDataSource`, one or more selected per section, an exclusive item ("All") selected alone; | `CYLMultipleFilterController` |
| `CYLMultipleFilterController.menuDataSource` | — | `CYLMultipleFilterController.menuDataSource` |
| `CYLMultipleFilterController.menuDelegate` | — | `CYLMultipleFilterController.menuDelegate` |
| `CYLMultipleFilterController.refreshFilterParams` | `-refreshFilterParams`: shows the current selection again. | `CYLMultipleFilterController -refreshFilterParams` |
| `CYLMultipleFilterController.reloadMenuData` | `-reloadMenuData`: reads the data source again; each section selects its first exclusive item. | `CYLMultipleFilterController -reloadMenuData` |
| `CYLMultipleFilterController.selectedIndexPaths` | `-selectedIndexPaths`. | `CYLMultipleFilterController -selectedIndexPaths` |
| `CYLMultipleFilterController.setSelectedIndexPaths` | `-setSelectedIndexPaths:`: throws for an invalid item, or an exclusive item selected with another in its section. | `CYLMultipleFilterController -setSelectedIndexPaths:` |
| `CYLMultipleFilterController.selectItemAtIndexPath` | Selects or deselects an item as a tap does (the collection view's `didSelectItemAtIndexPath:`). | `CYLMultipleFilterController.collectionView(_:didSelectItemAt:)` (a tap) |
| `CYLScaledSystemFont` | `CYLScaledSystemFont`: the system font of `pointSize` scaled by `fontScale` (the system font scale, 1 by default), at most `CYLMaximumFontScale` times. | `CYLTagMetrics.scaledSystemFont(ofSize:traitCollection:)` |
| `CYLTagHeightForFont` | `CYLTagHeightForFont`: at least `minimumHeight`, else the font's line height plus 10. | `CYLTagMetrics.tagHeight(for:minimumHeight:)` |
| `CYLTagTitleFontForTraitCollection` | `CYLTagTitleFontForTraitCollection`: the scaled title font. | `CYLTagMetrics.titleFont(for:)` |
| **class `CYLTag`** | `CYLTag`: one tag of a `CYLTagDataSource`: its title, identifier, icons, badge, state, and the look it changes over the list's style (android-tagview's `Tag`). | `CYLTag` |
| `CYLTag.title` | The title; null becomes "". | `CYLTag.title` |
| `CYLTag.image` | — | `CYLTag.image` |
| `CYLTag.selectedImage` | — | `CYLTag.selectedImage` |
| `CYLTag.animationURL` | — | `CYLTag.animationURL` |
| `CYLTag.isEnabled` | — | `CYLTag.isEnabled` |
| `CYLTag.isDeletable` | — | `CYLTag.isDeletable` |
| `CYLTag.badgeText` | — | `CYLTag.badgeText` |
| `CYLTag.badgeColor` | — | `CYLTag.badgeColor` |
| `CYLTag.badgeAccessibilityLabel` | — | `CYLTag.badgeAccessibilityLabel` |
| `CYLTag.userInfo` | — | `CYLTag.userInfo` |
| `CYLTag.style` | — | `CYLTag.style` |
| `CYLTag.textColor` | — | `CYLTag.textColor` |
| `CYLTag.font` | — | `CYLTag.font` |
| `CYLTag.textSize` | — | `CYLTag.textSize` |
| `CYLTag.highlightedBackgroundColor` | — | `CYLTag.highlightedBackgroundColor` |
| `CYLTag.selectedBackgroundColor` | — | `CYLTag.selectedBackgroundColor` |
| `CYLTag.backgroundImage` | — | `CYLTag.backgroundImage` |
| `CYLTag.cornerRadius` | — | `CYLTag.cornerRadius` |
| `CYLTag.borderWidth` | — | `CYLTag.borderWidth` |
| `CYLTag.borderColor` | — | `CYLTag.borderColor` |
| `CYLTag.deleteIndicatorTitle` | — | `CYLTag.deleteIndicatorTitle` |
| `CYLTag.deleteIndicatorColor` | — | `CYLTag.deleteIndicatorColor` |
| `CYLTag.deleteIndicatorSize` | — | `CYLTag.deleteIndicatorSize` |
| `CYLTag.colors` | The four colors of the tag; setting it sets them. | `CYLTag.colors` |
| `CYLTag.resetColors` | Resets `colors` (null_resettable): all four colors to the list's. | TODO |
| `CYLTag.hasCustomStyle` | Whether the tag changes anything of the list's style. | `CYLTag.hasCustomStyle` |
| `CYLTag.styleWithBaseStyle` | `-styleWithBaseStyle:`: the tag's style over `baseStyle` (its own `style` when set). | `CYLTag.style(basedOn:)` |
| `CYLTag.copy` | NSCopying. | `CYLTag.copy` |
| **class `CYLBadgeDrawable`** | A badge image with the label VoiceOver/TalkBack reads (`UIImage.accessibilityLabel` on iOS). | `UIImage` with `accessibilityLabel` (`CYLTag.swift` badge images) |
| **class `CYLOriginalImageDrawable`** | `-[UIImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]` for tags: `drawable` drawn in its own colors. | `UIImage.withRenderingMode(.alwaysOriginal)` |
| `cyl_imageWithRenderingModeAlwaysOriginal` | `imageWithRenderingMode(.alwaysOriginal)`: this drawable, drawn in its own colors by tags (see `CYLOriginalImageDrawable`). | `UIImage.withRenderingMode(.alwaysOriginal)` (`-imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal`) |
| **class `CYLTagDataSource`** | `CYLTagDataSource`: a one-section `CYLMenuDataSource` of `CYLTag`s, with a section title and the list's base style; each tag's style is computed once and cached until it or the bas | `CYLTagDataSource` |
| `CYLTagDataSource.tags` | The tags, a copy; setting it replaces them and clears the cached styles. | `CYLTagDataSource.tags` |
| `CYLTagDataSource.sectionTitle` | — | `CYLTagDataSource.sectionTitle` |
| `CYLTagDataSource.baseStyle` | The list's style the tags change; the default style when null (null_resettable). | `CYLTagDataSource.baseStyle` |
| `CYLTagDataSource.addTag` | — | `CYLTagDataSource -addTag:` |
| `CYLTagDataSource.addTags` | — | `CYLTagDataSource -addTags:` |
| `CYLTagDataSource.insertTag` | — | `CYLTagDataSource -insertTag:atIndex:` |
| `CYLTagDataSource.removeTagAtIndex` | — | `CYLTagDataSource -removeTagAtIndex:` |
| `CYLTagDataSource.removeAllTags` | — | `CYLTagDataSource -removeAllTags` |
| `CYLTagDataSource.moveTagAtIndex` | — | `CYLTagDataSource -moveTagAtIndex:toIndex:` |
| `CYLTagDataSource.invalidateStyles` | — | `CYLTagDataSource -invalidateStyles` |
| **class `CYLTagAppearance`** | `CYLTagAppearance`: the box and text of a tag in one state (normal, selected, disabled). | `CYLTagAppearance` |
| `CYLTagAppearance.backgroundColor` | null_resettable: white by default. | `CYLTagAppearance.backgroundColor` |
| `CYLTagAppearance.textColor` | null_resettable: dark gray (white 0.25) by default. | `CYLTagAppearance.textColor` |
| `CYLTagAppearance.font` | null_resettable: the 14 sp system font by default. | `CYLTagAppearance.font` |
| `CYLTagAppearance.iconColor` | — | `CYLTagAppearance.iconColor` |
| `CYLTagAppearance.cornerRadius` | — | `CYLTagAppearance.cornerRadius` |
| `CYLTagAppearance.borderColor` | — | `CYLTagAppearance.borderColor` |
| `CYLTagAppearance.borderWidth` | — | `CYLTagAppearance.borderWidth` |
| `CYLTagAppearance.margin` | The larger of the left and right content insets; setting it sets both. | `CYLTagAppearance.margin` |
| `CYLTagAppearance.contentInsets` | — | `CYLTagAppearance.contentInsets` |
| `CYLTagAppearance.backgroundImage` | — | `CYLTagAppearance.backgroundImage` |
| `CYLTagAppearance.reset` | Resets the colors and font to null (the defaults) and the lengths to their defaults. | `CYLTagAppearance -reset` |
| `CYLTagAppearance.resetBackgroundColor` | Resets the background color to its default (null_resettable). | `CYLTagAppearance.defaultBackgroundColor` |
| `CYLTagAppearance.resetTextColor` | Resets the text color to its default (null_resettable). | `CYLTagAppearance.defaultTextColor` |
| `CYLTagAppearance.resetFont` | Resets the font to its default (null_resettable). | `CYLTagAppearance.defaultFont` |
| **class `CYLTagButton`** | `CYLTagButton`: one tag: an icon (or an animated icon from CYLTabBarController's animation engine, found at run time), a title, an optional delete indicator (a title or a drawn cro | `CYLTagButton` |
| `CYLTagButton.imageView` | — | `CYLTagButton.imageView` |
| `CYLTagButton.titleLabel` | — | `CYLTagButton.titleLabel` |
| `CYLTagButton.deleteIndicatorLabel` | — | `CYLTagButton.deleteIndicatorLabel` |
| `CYLTagButton.animationView` | The animated icon's view (CYLTabBarController's engine), or null. | `CYLTagButton.animationView` |
| `CYLTagButton.animationPlayer` | The engine's player of `animationView`, or null. | `CYLTagButton.animationPlayer` |
| `CYLTagButton.deleteIndicatorHitFrame` | The delete indicator's touch area in this view, dp (`CGRectZero` when hidden). | `CYLTagButton.deleteIndicatorHitFrame` |
| `CYLTagButton.style` | The style (a copy); null resets it to the default style (null_resettable). | `CYLTagButton.style` |
| `CYLTagButton.title` | — | `CYLTagButton.title` |
| `CYLTagButton.image` | — | `CYLTagButton.image` |
| `CYLTagButton.selectedImage` | — | `CYLTagButton.selectedImage` |
| `CYLTagButton.animationURL` | An animation file for the engine (Lottie, PAG, Rive, GIF); ignored when the engine is not linked. | `CYLTagButton.animationURL` |
| `CYLTagButton.animationRestingProgress` | Where an unselected animation rests, 0…1 (0: the first frame). | `CYLTagButton.animationRestingProgress` |
| `CYLTagButton.showsDeleteIndicator` | — | `CYLTagButton.showsDeleteIndicator` |
| `CYLTagButton.isHighlighted` | `isHighlighted`: pressed. | `CYLTagButton.isHighlighted` |
| `CYLTagButton.animationSpeed` | `animationSpeed`: the playback speed of the animated icon, applied at once, also to an animation that is playing. | `CYLTagButton.animationSpeed` |
| `CYLTagButton.animationLoops` | `animationLoops`: true repeats the animated icon after `playAnimation()` until it is false, the selection changes or the file changes; false (the default) plays once. | `CYLTagButton.animationLoops` |
| `CYLTagButton.playAnimation` | Plays the animated icon from its start (not with Remove animations / Reduce Motion); with `animationLoops`, it repeats. | `CYLTagButton.playAnimation` |
| **object `CYLAccessibility`** | The system accessibility settings the core follows: Reduce Motion (Remove animations) and Increase Contrast (High contrast text). | `UIAccessibility` (UIKit) |
| `CYLAccessibility.isReduceMotionEnabled` | `UIAccessibilityIsReduceMotionEnabled()`: the animator duration scale is 0. | `UIAccessibility.isReduceMotionEnabled` (`UIAccessibilityIsReduceMotionEnabled()`) |
| `CYLAccessibility.isIncreaseContrastEnabled` | `UIAccessibilityDarkerSystemColorsEnabled()`: High contrast text. | `UIAccessibility.isDarkerSystemColorsEnabled` (`UIAccessibilityDarkerSystemColorsEnabled()`) |
| **enum `CYLTagColorTheme`** | `CYLTagColorTheme`: AndroidTagView's `tag_theme`. | `CYLTagColorTheme` |
| `CYLTagColorTheme.CYLTagColorThemeNone` | — | `CYLTagColorThemeNone` (same name in the iOS core) |
| `CYLTagColorTheme.CYLTagColorThemeRandom` | — | `CYLTagColorThemeRandom` (same name in the iOS core) |
| `CYLTagColorTheme.CYLTagColorThemePureCyan` | — | `CYLTagColorThemePureCyan` (same name in the iOS core) |
| `CYLTagColorTheme.CYLTagColorThemePureTeal` | — | `CYLTagColorThemePureTeal` (same name in the iOS core) |
| **class `CYLTagColors`** | `CYLTagColors`: the four colors of a tag (background, border, text, selected background), AndroidTagView's ColorFactory: a theme, a random palette color, or your own. | `CYLTagColors` |
| `CYLTagColors.styleByApplyingToStyle` | `-styleByApplyingToStyle:`: a copy of `style` (the default style when null) with these colors. | `CYLTagColors.styleByApplying(to:)` |
| **class `CYLTagCreateCell`** | `CYLTagCreateCell`: the "+ New tag" item: an outlined tag with a plus; it shows the typed name ("+ New tag "name""). | `CYLTagCreateCell` |
| `CYLTagCreateCell.configureWithName` | `-configureWithName:style:enabled:`. | `CYLTagCreateCell -configureWithName:style:enabled:` |
| **class `CYLTagFoldButton`** | `CYLTagFoldButton`: a section's fold control as a tag button: its title and chevron, turned when expanded. | `CYLTagFoldButton` |
| `CYLTagFoldButton.foldControl` | — | `CYLTagFoldButton.foldControl` |
| `CYLTagFoldButton.isExpanded` | — | `CYLTagFoldButton.expanded` |
| `CYLTagFoldButton.applyInlineFoldControl` | — | `CYLTagFoldButton -applyInlineFoldControl:itemStyle:expanded:animated:` |
| `CYLTagFoldButton.applyFoldControl` | — | `CYLTagFoldButton -applyFoldControl:color:expanded:animated:` |
| **class `CYLTagFoldCell`** | `CYLTagFoldCell`: the inline fold control of a section, as the last item of its folded rows. | `CYLTagFoldCell` |
| `CYLTagFoldCell.foldButton` | — | `CYLTagFoldCell.foldButton` |
| `CYLTagFoldCell.configureWithFoldControl` | `-configureWithFoldControl:itemStyle:expanded:animated:`. | `CYLTagFoldCell -configureWithFoldControl:itemStyle:expanded:animated:` |
| **class `CYLAccessibilityAction`** | `UIAccessibilityCustomAction`: a named action TalkBack, Switch Access and Voice Access offer on a view. | `UIAccessibilityCustomAction` |
| `cyl_viewsWithAccessibilityIdentifier` | Finds the descendants (and this view) whose `cyl_accessibilityIdentifier` is `identifier`. | `UIView (CYLGeneral) -cyl_viewsWithAccessibilityIdentifier:` |
| **class `CYLTagListCell`** | `CYLTagListCell`: the cell of a tag in a `CYLTagListView`: a `CYLTagButton` filling it, a delete control over the button's delete indicator, the touch ripple of the style (AndroidT | `CYLTagListCell` |
| `CYLTagListCell.button` | — | `CYLTagListCell.button` |
| `CYLTagListCell.appliedStyle` | The style last applied to `button` (held weakly on iOS: compared by identity only). | `CYLTagListCell.appliedStyle` |
| `CYLTagListCell.deletable` | — | `CYLTagListCell.deletable` |
| `CYLTagListCell.deleteHandler` | — | `deleteHandler` (same name in the iOS core) |
| `CYLTagListCell.additionalAccessibilityActions` | — | `CYLTagListCell.additionalAccessibilityActions` |
| `CYLTagListCell.accessibilityHint` | `accessibilityHint` of the cell. | `UIView.accessibilityHint` of the cell |
| `CYLTagListCell.showRippleAtPoint` | `-showRippleAtPoint:`: the style's ripple from `point` (dp), unless there is no ripple color or Reduce Motion. | `CYLTagListCell -showRippleAtPoint:` |
| `CYLTagListCell.prepareForReuse` | `-prepareForReuse`. | `prepareForReuse` (same name in the iOS core) |
| `CYLTagListCell.configureWithTitle` | `-configureWithTitle:image:selectedImage:animationURL:style:selected:enabled:`. | `CYLTagListCell -configureWithTitle:image:selectedImage:animationURL:style:selected:enabled:` |
| **enum `CYLMenuSelectionMode`** | `CYLMenuSelectionMode`. | `CYLMenuSelectionMode` |
| **enum `CYLMenuTitlePosition`** | `CYLMenuTitlePosition`: where the list's title sits. | `CYLMenuTitlePosition` |
| **enum `CYLMenuFoldStyle`** | `CYLMenuFoldStyle`: the older form of `CYLMenuFoldControl`, and truncation (AndroidTagView's max lines). | `CYLMenuFoldStyle` |
| **class `CYLTagListView`** | `CYLTagListView`: a list of tags in sections (a `CYLMenuDataSource`) or of `CYLTag`s (`addTag…`, android-tagview's TagView and AndroidTagView's TagContainerLayout): flowing rows, s | `CYLTagListView` |
| `CYLTagListView.titleView` | The title of the list (`titleView`), hidden when there is neither title nor title image. | `CYLTagListView.titleView` |
| `CYLTagListView.titleLabel` | The label of `titleView`. | `CYLTagListView.titleLabel` |
| `CYLTagListView.menuDataSource` | — | `CYLTagListView.menuDataSource` |
| `CYLTagListView.menuDelegate` | — | `CYLTagListView.menuDelegate` |
| `CYLTagListView.style` | The list's style (a copy); null resets it (null_resettable). | `CYLTagListView.style` |
| `CYLTagListView.selectionMode` | — | `CYLTagListView.selectionMode` |
| `CYLTagListView.allowsEmptySelection` | — | `CYLTagListView.allowsEmptySelection` |
| `CYLTagListView.showsSectionHeaders` | — | `CYLTagListView.showsSectionHeaders` |
| `CYLTagListView.foldControl` | The fold control (a copy); null resets it to no control (null_resettable). | `CYLTagListView.foldControl` |
| `CYLTagListView.foldStyle` | — | `CYLTagListView.foldStyle` |
| `CYLTagListView.title` | — | `CYLTagListView.title` |
| `CYLTagListView.titleImage` | — | `CYLTagListView.titleImage` |
| `CYLTagListView.titlePosition` | — | `CYLTagListView.titlePosition` |
| `CYLTagListView.titleStyle` | The title's style (a copy); null resets it to `defaultTitleStyle()` (null_resettable). | `CYLTagListView.titleStyle` |
| `CYLTagListView.defaultVisibleRows` | Rows a folded section shows (1 by default). | `CYLTagListView.defaultVisibleRows` |
| `CYLTagListView.isScrollEnabled` | Whether the list scrolls (off inside another scrolling container: it then reports its height). | `CYLTagListView.isScrollEnabled` |
| `CYLTagListView.contentHeight` | The height of all sections and the title for the current width, dp. | `CYLTagListView.contentHeight` |
| `CYLTagListView.reloadMenuData` | `-reloadMenuData`: reads the data source again and lays the list out. | `CYLTagListView.reloadMenuData` |
| `CYLTagListView.heightThatFitsWidth` | `-heightThatFitsWidth:`: the height of the title and every section at `width` dp. | `CYLTagListView.heightThatFitsWidth` |
| `CYLTagListView.lineSpacing` | — | `CYLTagListView.lineSpacing` |
| `CYLTagListView.interitemSpacing` | — | `CYLTagListView.interitemSpacing` |
| `CYLTagListView.tagContentInsets` | — | `CYLTagListView.tagContentInsets` |
| `CYLTagListView.tagContentInsetTop` | — | `CYLTagListView.tagContentInsetTop` |
| `CYLTagListView.tagContentInsetLeft` | — | `CYLTagListView.tagContentInsetLeft` |
| `CYLTagListView.tagContentInsetBottom` | — | `CYLTagListView.tagContentInsetBottom` |
| `CYLTagListView.tagContentInsetRight` | — | `CYLTagListView.tagContentInsetRight` |
| `CYLTagListView.tagDataSource` | The `CYLTagDataSource` the `addTag…` methods fill (made on first use). | `CYLTagListView.tagDataSource` |
| `CYLTagListView.tags` | The tags of `tagDataSource`. | `CYLTagListView.tags` |
| `CYLTagListView.addTag` | — | `CYLTagListView.addTag` |
| `CYLTagListView.addTags` | — | `CYLTagListView.addTags` |
| `CYLTagListView.addTagsWithTitles` | — | `CYLTagListView.addTags(withTitles:)` |
| `CYLTagListView.insertTag` | — | `CYLTagListView.insertTag` |
| `CYLTagListView.removeTagAtIndex` | — | `CYLTagListView.removeTag(at:)` |
| `CYLTagListView.removeAllTags` | — | `CYLTagListView.removeAllTags` |
| `CYLTagListView.tagClickHandler` | — | `CYLTagListView.tagClickHandler` |
| `CYLTagListView.tagDeleteHandler` | — | `CYLTagListView.tagDeleteHandler` |
| `CYLTagListView.deleteItemAtIndexPath` | `-deleteItemAtIndexPath:`: removes it (when `removesItemsOnDelete`) and tells the delegate. | `CYLTagListView.deleteItem(at:)` |
| `CYLTagListView.containerBorderWidth` | — | `CYLTagListView.containerBorderWidth` |
| `CYLTagListView.containerBorderColor` | — | `CYLTagListView.containerBorderColor` |
| `CYLTagListView.containerCornerRadius` | — | `CYLTagListView.containerCornerRadius` |
| `CYLTagListView.maximumNumberOfRows` | At most this many rows, the others cut (truncation); 0 for no limit. | `CYLTagListView.maximumNumberOfRows` |
| `CYLTagListView.colorTheme` | — | `CYLTagListView.colorTheme` |
| `CYLTagListView.allowsTapping` | — | `CYLTagListView.allowsTapping` |
| `CYLTagListView.defaultTagImage` | — | `CYLTagListView.defaultTagImage` |
| `CYLTagListView.removesItemsOnDelete` | — | `CYLTagListView.removesItemsOnDelete` |
| `CYLTagListView.tagButtonAtIndexPath` | `-tagButtonAtIndexPath:`: the button of a visible tag, or null. | `CYLTagListView.tagButton(at:)` |
| `CYLTagListView.animationSpeed` | `animationSpeed`: the playback speed of every animated icon, applied at once, also to animations that are playing, without reloading the list. | `CYLTagListView.animationSpeed` |
| `CYLTagListView.animationLoops` | `animationLoops`: true repeats the animated icons after they start playing (a tap, `playAllAnimations()`) until it is false; false (the default) plays them once. | `CYLTagListView.animationLoops` |
| `CYLTagListView.playAllAnimations` | `-playAllAnimations`: plays the animated icon of every tag from its start (progress 0), whatever its selection. | `CYLTagListView.playAllAnimations` |
| `CYLTagListView.tagLongPressHandler` | — | `CYLTagListView.tagLongPressHandler` |
| `CYLTagListView.longPressAccessibilityActionName` | — | `CYLTagListView.longPressAccessibilityActionName` |
| `CYLTagListView.allowsReordering` | — | `CYLTagListView.allowsReordering` |
| `CYLTagListView.reorderingSensitivity` | Higher is quicker: the long press before a drag lasts 0.5 s / sensitivity. | `CYLTagListView.reorderingSensitivity` |
| `CYLTagListView.reordering` | — | `CYLTagListView.isReordering` |
| `CYLTagListView.isReordering` | `isReordering`. | `CYLTagListView.isReordering` |
| `CYLTagListView.tagMoveHandler` | — | `CYLTagListView.tagMoveHandler` |
| `CYLTagListView.selectedTagDragHandler` | — | `CYLTagListView.selectedTagDragHandler` |
| `CYLTagListView.replaceTags` | — | `CYLTagListView.replaceTags` |
| `CYLTagListView.setTagsWithTitles` | — | `CYLTagListView.setTags(withTitles:colors:)` |
| `CYLTagListView.addTagWithTitle` | — | `CYLTagListView.addTag(withTitle:)` |
| `CYLTagListView.insertTagWithTitle` | — | `CYLTagListView.insertTag(withTitle:at:)` |
| `CYLTagListView.removeTagsAtIndexes` | `-removeTagsAtIndexes:`. | `CYLTagListView.removeTags(at:)` |
| `CYLTagListView.toggleSelectionOfItemAtIndexPath` | — | `CYLTagListView.toggleSelection(at:)` |
| `CYLTagListView.selectedTitles` | — | `CYLTagListView.selectedTitles` |
| `CYLTagListView.selectedIndexPaths` | The selected items, sorted; setting an invalid one throws, as on iOS. | `CYLTagListView.selectedIndexPaths` |
| `CYLTagListView.selectItemAtIndexPath` | — | `CYLTagListView.selectItem(at:)` |
| `CYLTagListView.deselectItemAtIndexPath` | — | `CYLTagListView.deselectItem(at:)` |
| `CYLTagListView.deselectAllItems` | — | `CYLTagListView.deselectAllItems` |
| `CYLTagListView.canFoldSection` | — | `CYLTagListView.canFoldSection` |
| `CYLTagListView.numberOfRowsInSection` | — | `CYLTagListView.numberOfRows(inSection:)` |
| `CYLTagListView.isSectionExpanded` | — | `CYLTagListView.isSectionExpanded` |
| `CYLTagListView.numberOfVisibleItemsInSection` | — | `CYLTagListView.numberOfVisibleItems(inSection:)` |
| `CYLTagListView.setExpanded` | — | `CYLTagListView.setExpanded` |
| `CYLTagListView.scrollToSection` | `-scrollToSection:animated:`. | `CYLTagListView.scroll(toSection:animated:)` |
| `CYLTagListView.scrollToItemAtIndexPath` | `-scrollToItemAtIndexPath:animated:`: centers a visible item. | `CYLTagListView.scrollToItem(at:animated:)` |
| **enum `CYLMenuConfigurationError`** | `CYLMenuConfigurationError`: why a configuration file could not be read. | `Code` |
| `CYLMenuConfigurationError.CYLMenuConfigurationErrorFileNotFound` | — | `Code.fileNotFound` |
| `CYLMenuConfigurationError.CYLMenuConfigurationErrorInvalidContents` | — | `Code.invalidContents` |
| `CYLMenuConfigurationError.CYLMenuConfigurationErrorUnsupportedFormat` | — | `Code.unsupportedFormat` |
| **class `CYLMenuConfigurationException`** | The exception thrown where iOS returns an `NSError` of `CYLMenuConfigurationErrorDomain`. | `CYLMenuConfigurationError` thrown as `NSError` (domain `CYLMenuConfigurationErrorDomain`) |
| `CYLMenuConfigurationException.domain` | Always `CYLMenuConfigurationErrorDomain`. | `CYLMenuConfigurationError.errorDomain` (`"CYLMenuConfigurationErrorDomain"`) |
| `CYLMenuAnimationURLWithOptions` | `CYLMenuAnimationURLWithOptions`: `fileURL` with `options` as its fragment ("name=value&…", names sorted, percent encoded), which the animation engine reads (Rive's artboard and st | `URL.cylAddingAnimationOptions(_:)` |
| `foldControlWithConfiguration` | `CYLMenuFoldControl (CYLConfiguration) +foldControlWithConfiguration:`: a copy of a fold control, a control for a position name (with the position's usual content), or one built fr | `CYLMenuFoldControl (CYLConfiguration) +foldControlWithConfiguration:` |
| `applyConfiguration` | `CYLMenuFoldControl (CYLConfiguration) -applyConfiguration:`: sets the values the dictionary holds. | `CYLTagListView (CYLConfiguration) -applyConfiguration:` |
| `styleWithConfiguration` | `CYLMenuStyle (CYLConfiguration) +styleWithConfiguration:`: the default style with the dictionary applied. | `CYLMenuStyle (CYLConfiguration) +styleWithConfiguration:` |
| `tagWithConfiguration` | `CYLTag (CYLConfiguration) +tagWithConfiguration:`: a tag from an item dictionary (id, title, images, animation, enabled, deletable, style). | `CYLTag (CYLConfiguration) +tagWithConfiguration:` |
| `tagListViewWithConfiguration` | `-initWithConfiguration:` / `+tagListViewWithConfiguration:`: a list with the configuration applied. | `CYLTagListView (CYLConfiguration) +tagListViewWithConfiguration:` |
| `configurationWithContentsOfFile` | `+configurationWithContentsOfFile:error:`: reads a JSON file or an XML property list (a path, a `file:` / `content:` URI, or a path inside the app's assets). | `CYLTagListView (CYLConfiguration) +configurationWithContentsOfFile:error:` |
| `tagListViewWithConfigurationFile` | `-initWithConfigurationFile:error:` / `+tagListViewWithConfigurationFile:error:`. | `CYLTagListView(configurationFile:)` (`throws`) |
| **class `CYLTagModel`** | `CYLTagModel`: a tag's title and its size: the title's width at 17 sp plus 50, and the height of that font (at least 35), dp. | `CYLTagModel` |
| `CYLTagModel.title` | The title; setting it measures the tag again. | `CYLTagModel.title` |
| `CYLTagModel.width` | — | `CYLTagModel.width` |
| `CYLTagModel.height` | — | `CYLTagModel.height` |
| `CYLTagModel.updateSizeForTraitCollection` | `-updateSizeForTraitCollection:`: measures the tag at `fontScale` (null: the system's text size). | `CYLTagModel -updateSizeForTraitCollection:` |
| **class `CYLTagGroup`** | `CYLTagGroup`: a section of a `CYLTagView`: its name, its tags, whether it is opened, and how many tags fit on its first row (dp). | `CYLTagGroup` |
| `CYLTagGroup.groupName` | — | `CYLTagGroup.groupName` |
| `CYLTagGroup.width` | The width of the view, dp (0 until laid out: then the screen's width). | `CYLTagGroup.width` |
| `CYLTagGroup.height` | The header's height, dp (38). | `CYLTagGroup.height` |
| `CYLTagGroup.opened` | Whether every tag shows (`isOpened`). | `CYLTagGroup.opened` |
| `CYLTagGroup.isOpened` | `isOpened`. | `isOpened` (same name in the iOS core) |
| `CYLTagGroup.section` | — | `CYLTagGroup.section` |
| `CYLTagGroup.itemArr` | The tags; setting them computes the rows again. | `CYLTagGroup.itemArr` |
| `CYLTagGroup.firstRowCount` | — | `CYLTagGroup.cellCountsPerRow.first` (computed on iOS, stored on Android) |
| `CYLTagGroup.cellsCountArrayPerRowInSections` | The number of tags of each row at the view's width. | `CYLTagGroup.cellsCountArrayPerRowInSections` |
| `CYLTagGroup.firstRowCellCountForContentWidth` | `-firstRowCellCountForContentWidth:`: how many tags fit on the first row of `contentWidth` dp. | `CYLTagGroup -firstRowCellCountForContentWidth:` |
| **class `CYLTagCell`** | `CYLTagCell`: a tag: white text on a blue pill (the XIB's label). | `CYLTagCell` |
| `CYLTagCell.model` | The tag shown. | `CYLTagCell.model` |
| **interface `CYLTagHeaderCellDelegate`** | `CYLTagHeaderCellDelegate`: the header's button was tapped. | `CYLTagHeaderCellDelegate` |
| `CYLTagHeaderCellDelegate.headerViewDidTapNameView` | `-headerViewDidTapNameView:index:`. | `CYLTagHeaderCellDelegate -headerViewDidTapNameView:index:` |
| **class `CYLTagHeaderCell`** | `CYLTagHeaderCell`: a section header: the group's name and a More / Less button that opens or closes the group. | `CYLTagHeaderCell` |
| `CYLTagHeaderCell.delegate` | — | `CYLTagHeaderCell.delegate` |
| `CYLTagHeaderCell.group` | The group shown. | `CYLTagHeaderCell.group` |
| `CYLTagHeaderCell.btnClick` | `-btnClick`: opens or closes the group and tells the delegate. | `btnClick` (same name in the iOS core) |
| **class `CYLTagView`** | `CYLTagView`: the sections of a `CYLMenuDataSource` as blue tags in left-aligned rows, each section showing its first row until its header's More button opens it. | `CYLTagView` |
| `CYLTagView.showHeader` | Whether the section headers show (`isShowHeader`). | `CYLTagView.showHeader` |
| `CYLTagView.isShowHeader` | `isShowHeader`. | `isShowHeader` (same name in the iOS core) |
| `CYLTagView.groups` | The sections, made by `reloadMenuData`. | `CYLTagView.groups` |
| `CYLTagView.menuDataSource` | — | `CYLTagView.menuDataSource` |
| `CYLTagView.menuDelegate` | — | `CYLTagView.menuDelegate` |
| `CYLTagView.reloadMenuData` | `-reloadMenuData`: reads the data source again. | `CYLTagView -reloadMenuData` |
| `CYLTagView.numberOfVisibleItemsInSection` | The number of tags a section shows now (for tests). | `CYLTagView.numberOfVisibleItems(inSection:)` (`-numberOfVisibleItemsInSection:`) |
| **class `CYLEdgeInsets`** | The Android forms of the UIKit value types the iOS API uses. | `UIEdgeInsets` (UIKit; Android stand-in) |
| **class `CYLSize`** | `CGSize` in dp. | `CGSize` (Core Graphics; Android stand-in) |
| **class `CYLOffset`** | `UIOffset` in dp. | `UIOffset` (UIKit; Android stand-in) |
| **class `CYLPoint`** | `CGPoint` / `CGRect` in dp (view coordinates). | `CGPoint` (Core Graphics; Android stand-in) |
| **class `CYLRect`** | `CGRect` in dp. | `CGRect` (Core Graphics; Android stand-in) |
| `CYLRect.maxX` | — | `CGRect.maxX` (`CGRectGetMaxX`) |
| `CYLRect.maxY` | — | `CGRect.maxY` (`CGRectGetMaxY`) |
| `CYLRect.intersects` | — | `CGRect.intersects(_:)` (`CGRectIntersectsRect`) |
| **class `CYLIndexPath`** | `NSIndexPath` of a list: an item in a section. | `IndexPath` / `NSIndexPath` (`item`, `section`; Android stand-in) |
| **class `CYLFont`** | `UIFont`: a size in sp and a typeface. | `UIFont` (UIKit; Android stand-in) |
| `CYLFont.isBold` | — | `UIFont.fontDescriptor.symbolicTraits.contains(.traitBold)` |
| `CYLFont.bold` | The same font in bold (Bold Text). | `bold` (same name in the iOS core) |
| `CYLFont.withSize` | — | `UIFont.withSize(_:)` (`-fontWithSize:`) |
| **object `CYLControlState`** | `UIControlState`: bit flags, `NORMAL` being none of them. | `UIControl.State` (`UIControlState`; Android stand-in) |
| `CYLControlState.NORMAL` | — | `UIControl.State.normal` |
| `CYLControlState.HIGHLIGHTED` | — | `UIControl.State.highlighted` |
| `CYLControlState.DISABLED` | — | `UIControl.State.disabled` |
| `CYLControlState.SELECTED` | — | `UIControl.State.selected` |
| **object `CYLColor`** | Colors as ARGB ints, the Android form of `UIColor`. | `UIColor` (UIKit; Android stand-in: colors as ARGB ints) |
| `CYLColor.white` | `+[UIColor colorWithWhite:alpha:]`. | `UIColor(white:alpha:)` (`+colorWithWhite:alpha:`) |
| `CYLColor.rgb` | `+[UIColor colorWithRed:green:blue:alpha:]` with components 0...1. | `rgb` (same name in the iOS core) |
| `CYLColor.withAlpha` | `-[UIColor colorWithAlphaComponent:]`. | `UIColor.withAlphaComponent(_:)` (`-colorWithAlphaComponent:`) |
| `CYLColor.fromHex` | A "RRGGBB" or "#RRGGBB" hex string with `alpha`, or null when it does not parse. | `UIColor.cylMenuColor(from:)` (`CYLTagListView+CYLConfiguration.swift`: "RRGGBB", "#RRGGBB" or a color name) |
| `CYLColor.APP_TINT` | `CYLAppTintColor` (42, 185, 160). | `UIColor.cylAppTint` (`+[UIColor cyl_appTintColor]`) |
| `CYLColor.CLEAR` | `+[UIColor clearColor]`. | `UIColor.clear` (`+clearColor`) |
<!-- ios-alignment:end -->

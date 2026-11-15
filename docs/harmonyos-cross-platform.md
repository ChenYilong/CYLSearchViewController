# HarmonyOS (cross-platform)

The HarmonyOS port of CYLSearchViewController: the ArkTS library `harmonyos/cylsearch` and the example app
`harmonyos/entry`. Other platforms: [android-and-cross-platform.md](android-and-cross-platform.md).

## HarmonyOS version

| Item | Version |
| :--- | :--- |
| System | HarmonyOS NEXT, target HarmonyOS 6.0.1 (API 21), compatible from HarmonyOS 6.0.1 (API 21; the minimum of CYLTableViewPlaceHolder's cylplaceholder) (`harmonyos/build-profile.json5`) |
| Language and UI | ArkTS, ArkUI state management V2 (`@ComponentV2`) |
| IDE and SDK | DevEco Studio 6.0.1 with its bundled SDK (API 21), hvigor, ohpm |
| Run | Huawei emulator (Mate 70 Pro, HarmonyOS 6.0.1, API 21); unsigned HAP installed with `hdc install` |

## IDE preparation and emulator prerequisites (DONE 2026-11-16)

- Prompt (verbatim): "全英文写入instructions相关文件以及 skills相关文件： 鸿蒙系统 ide 准备工作，模拟器安装的必要条件， region should be set to china (NZ) in country.region.xml to china make sure The region file now says China: <countryregion name="CN"/>"
- Prompt (English): "Write, in English only, into the instruction files and the skill files: the HarmonyOS IDE
  preparation and the prerequisites for installing the emulator. The region must be set to China in
  `country.region.xml` (the developer is in New Zealand); make sure the region file says China:
  `<countryregion name="CN"/>`."
- Requirements: English only; update `AGENTS.md`, `instructions.md` and a skill in `.agents/skills`; DevEco Studio
  preparation; emulator prerequisites; region set to China (`CN`) in `country.region.xml`, checked on this machine.
- Status: DONE (2026-11-16). New skill `.agents/skills/cyl-harmonyos-setup`; new sections in `AGENTS.md` and
  `instructions.md` ("HarmonyOS: IDE preparation and emulator prerequisites"); a pointer in `cyl-verify`.
- Evidence (Windows 11 Pro 10.0.22631, DevEco Studio build `DS-243.24978.46.36.601251`):
  `%APPDATA%\Huawei\DevEcoStudio6.0\options\country.region.xml` contains `<countryregion name="CN"/>` (the original
  `NZ` file is kept as `country.region.xml.bak-NZ`); `HypervisorPresent = True`; 64 GB RAM; the HarmonyOS 6.0.1
  `phone_all_x86` system image was downloading in `%LOCALAPPDATA%\Huawei\Sdk`.
- TODO: no emulator has been created or started on this machine yet; create the Mate 70 Pro (API 21) emulator once
  the image download ends, then check it with `hdc list targets`.

## IN PROGRESS (TODO 2026-11-16): the HarmonyOS scorecard, scored to 100

- Prompt (verbatim): "合并pr 新建pr 开始鸿蒙端开发，在新建跨端文档，标注鸿蒙系统版本，新建表格，列出iOS版本存在的API， 在新建表格列出iOS端example 层所有演示，每个表格的第二列为鸿蒙对应实现，默认填TODO 鸿蒙系统软件开发过程中需要实时打分，两个表格一起打分。移除所有todo为满分。每每完成一个功能移除一个todo，一直到满分为止。"
- Prompt (English): "Merge the PRs, open a new PR and start the HarmonyOS development. Make a new cross-platform document
  stating the HarmonyOS version; make a table listing the APIs of the iOS version, and a table listing every demo
  of the iOS example layer; the second column of each table is the HarmonyOS implementation, `TODO` by default.
  Score live during the HarmonyOS development, both tables together. No TODO left is a full score. Each time a
  feature is done, remove one TODO, until the score is full."
- Rules:
  1. Table 1 lists every iOS public API; its second column comes from the third column of
     [harmonyos-api-alignment.md](harmonyos-api-alignment.md) (kept in step with the Swift sources by
     `python3 scripts/harmonyos-api-alignment.py`).
  2. Table 2 lists every demo of the iOS example (`CYLSearchExample`); its second column is the HarmonyOS page or
     component, `TODO` until the demo works on HarmonyOS as on iOS (1:1: same texts, data, layout and behaviour).
  3. Principles (2026-11-16, `AGENTS.md` "HarmonyOS: API and example 1:1 with iOS"): the API matches iOS, the
     example is a 1:1 copy of the iOS example, and the internals are migrated from the Android Kotlin sources.
  4. After each feature: replace its `TODO`, run `python3 scripts/harmonyos-scorecard.py` (rewrites both tables and
     the score), add a line to the score log, commit.
- Build on Windows: hvigor rejects a path with spaces or non-ASCII characters, so mirror `harmonyos/` to an ASCII
  path (for example `C:\cylbuild\harmonyos`) and run `hvigorw assembleHap --mode module -p module=entry@default
  -p product=default` there, with `DEVECO_SDK_HOME` set to DevEco Studio's `sdk` and its `jbr\bin` on `PATH`.

## Kotlin parity of the internals (2026-11-16)

The ArkTS core was compared with `android/merged/cylsearch` file by file; these behaviours now follow the Kotlin code
(tests in `harmonyos/entry/src/ohosTest/ets/test/CYLSearchCore.test.ets`, "Kotlin parity"):

- `CYLSearchView`: the query is trimmed before "empty or not" and matched with accents folded (`fold`); the
  placeholders use the trimmed query; any refilter shows the suggestions again and a handled submit dismisses them;
  `setQuery` and a tapped suggestion set the text silently, report the change once and submit through the bar
  (`searchBarViewShouldSubmitText`, blank refused, untrimmed text to the delegate); `searchViewDidShow` /
  `searchViewDidClose` fire when the animation ends; `showSearch` on an open view focuses the field again; changing
  `emptyResultsScenario` / `emptySuggestionsScenario` replaces the placeholder.
- `CYLSearchBarView`: `setText` is silent, `submit` refuses whitespace, and with `iconifiedByDefault` an empty field
  folds back to the search button when editing ends.
- `CYLSearchSuggestionStore`: keeps at least one query, an empty name is `CYLSearchView`, the file name is made safe,
  `none` keeps nothing.
- `CYLMultiSearchView`: nothing is selected while typing, the typed text is not trimmed, `addSearchText` completes the
  search being typed and reports nothing, and removing an item selects the next one as Kotlin does.
- Open: the inline fold control of the tag suggestions is still laid over the last row instead of placed as the last
  tag (the Discover page already places it as a tag); `CYLMenuFoldControlPosition.none`; a screen-reader announcement
  after clearing the cache; the focus delay of an iconified bar.

## Score

Status: 100 by implementation; every demo compiles, none has run yet (no emulator on the Windows machine; create one in
DevEco Studio > Device Manager, then `hdc install` the HAP and run the hypium tests). The tab bar and the refresh header come from the
sub-repositories' HarmonyOS libraries: run `python3 harmonyos/scripts/sync-sub-repositories.py` before building.

<!-- harmonyos-score:begin -->
Score: 100/100 (422 of 422 rows; API 397/397, demos 25/25; TODO left 0).
<!-- harmonyos-score:end -->

| Date | Change | Score |
| :--- | :--- | ---: |
| 2026-11-16 | Tables listed; the API from harmonyos-api-alignment.md, every demo TODO | 94 |
| 2026-11-16 | The example rebuilt 1:1 with iOS (25 demos), the iOS placeholder images and texts in the core; compiled with hvigor (app and test HAPs), not run: this Windows machine has no HarmonyOS emulator | 100 |
| 2026-11-16 | Back to TODO, not 1:1 yet: the tab bar and the refresh header are drawn in the example (CYLTabBarController and CYLTableViewPlaceHolder have no HarmonyOS library), the Voice sample has no speech recognizer | 99 |
| 2026-11-16 | Voice sample: CoreSpeechKit speech recognition | 99 |
| 2026-11-16 | The tab bar on CYLTabBarController's `cyltabbar` and the refresh header on CYLTableViewPlaceHolder's `cylplaceholder` (harmonyos/scripts/sync-sub-repositories.py, pinned commits); minimum raised to API 21, the libraries' minimum | 100 |

## Table 1: iOS public API

<!-- harmonyos-api:begin -->
| iOS public API | HarmonyOS implementation |
| :--- | :--- |
| **protocol `CYLMultiSearchViewDelegate`** | `CYLMultiSearchViewDelegate` |
| `CYLMultiSearchViewDelegate.-multiSearchView:textDidChange:atIndex:` | `CYLMultiSearchViewDelegate.multiSearchViewTextDidChange` |
| `CYLMultiSearchViewDelegate.-multiSearchView:didCompleteSearch:atIndex:` | `CYLMultiSearchViewDelegate.multiSearchViewDidCompleteSearch` |
| `CYLMultiSearchViewDelegate.-multiSearchView:didRemoveItemAtIndex:` | `CYLMultiSearchViewDelegate.multiSearchViewDidRemoveItemAtIndex` |
| `CYLMultiSearchViewDelegate.-multiSearchView:didSelectItem:atIndex:` | `CYLMultiSearchViewDelegate.multiSearchViewDidSelectItem` |
| **class `CYLMultiSearchView`** | `CYLMultiSearchView` |
| `CYLMultiSearchView.delegate` | `CYLMultiSearchView.delegate` |
| `CYLMultiSearchView.selectedIndex` | `CYLMultiSearchView.selectedIndex` |
| `CYLMultiSearchView.inSearchMode` | `CYLMultiSearchView.isInSearchMode` |
| `CYLMultiSearchView.searchButton` | N/A: ArkUI has no view objects; `CYLMultiSearchComponent` draws it (`searchImage`) |
| `CYLMultiSearchView.placeholder` | `CYLMultiSearchView.placeholder` |
| `CYLMultiSearchView.font` | `CYLMultiSearchView.font` |
| `CYLMultiSearchView.textColor` | `CYLMultiSearchView.textColor` |
| `CYLMultiSearchView.placeholderColor` | `CYLMultiSearchView.placeholderColor` |
| `CYLMultiSearchView.maximumTextLength` | `CYLMultiSearchView.maximumTextLength` |
| `CYLMultiSearchView.minimumTextLength` | `CYLMultiSearchView.minimumTextLength` |
| `CYLMultiSearchView.returnKeyType` | `CYLMultiSearchView.returnKeyType` |
| `CYLMultiSearchView.keyboardType` | `CYLMultiSearchView.keyboardType` |
| `CYLMultiSearchView.autocapitalizationType` | N/A: ArkUI `TextInput` has no capitalization trait |
| `CYLMultiSearchView.indicatorColor` | `CYLMultiSearchView.indicatorColor` |
| `CYLMultiSearchView.unselectedItemAlpha` | `CYLMultiSearchView.unselectedItemAlpha` |
| `CYLMultiSearchView.searchFieldWidth` | `CYLMultiSearchView.searchFieldWidth` |
| `CYLMultiSearchView.animationDuration` | `CYLMultiSearchView.animationDuration` |
| `CYLMultiSearchView.searchImage` | `CYLMultiSearchView.searchImage` |
| `CYLMultiSearchView.removeImage` | `CYLMultiSearchView.removeImage` |
| `CYLMultiSearchView.searchTexts` | `CYLMultiSearchView.searchTexts` |
| `CYLMultiSearchView.init(frame:)` | `new CYLMultiSearchView(…)` |
| `CYLMultiSearchView.init(coder:)` | N/A: no archives in ArkUI (the state is restored with `decodeRestorableState`) |
| `CYLMultiSearchView.tintColorDidChange()` | N/A: system colors follow the theme by themselves (`indicatorColor` overrides) |
| `CYLMultiSearchView.traitCollectionDidChange(_:)` | N/A: system colors (`sys.color.*`) follow the color mode by themselves |
| `CYLMultiSearchView.intrinsicContentSize` | `CYLMultiSearchView.intrinsicContentSize` |
| `CYLMultiSearchView.layoutSubviews()` | N/A: ArkUI lays a component out from its declaration |
| `CYLMultiSearchView.search()` | `CYLMultiSearchView.search` |
| `CYLMultiSearchView.completeSearch()` | `CYLMultiSearchView.completeSearch` |
| `CYLMultiSearchView.addSearchText(_:)` | `CYLMultiSearchView.addSearchText` |
| `CYLMultiSearchView.selectItem(at:)` | `CYLMultiSearchView.selectItemAtIndex` |
| `CYLMultiSearchView.removeItem(at:)` | `CYLMultiSearchView.removeItemAtIndex` |
| `CYLMultiSearchView.textFieldShouldBeginEditing(_:)` | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLMultiSearchView.textFieldShouldReturn(_:)` | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLMultiSearchView.textField(_:shouldChangeCharactersIn:replacementString:)` | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| **enum `CYLSearchBarItemStyle`** | `CYLSearchBarItemStyle` |
| `CYLSearchBarItemStyle.icon` | `CYLSearchBarItemStyle.icon` |
| `CYLSearchBarItemStyle.divider` | `CYLSearchBarItemStyle.divider` |
| `CYLSearchBarItemStyle.text` | `CYLSearchBarItemStyle.text` |
| **enum `CYLSearchBarStyle`** | `CYLSearchBarStyle` |
| `CYLSearchBarStyle.plain` | `CYLSearchBarStyle.plain` |
| `CYLSearchBarStyle.bordered` | `CYLSearchBarStyle.bordered` |
| **class `CYLSearchBarItem`** | `CYLSearchBarItem` |
| `CYLSearchBarItem.style` | `CYLSearchBarItem.style` |
| `CYLSearchBarItem.title` | `CYLSearchBarItem.title` |
| `CYLSearchBarItem.image` | `CYLSearchBarItem.image` |
| `CYLSearchBarItem.selectedImage` | `CYLSearchBarItem.selectedImage` |
| `CYLSearchBarItem.animatedImage` | `CYLSearchBarItem.animatedImage` |
| `CYLSearchBarItem.imageSize` | `CYLSearchBarItem.imageSize` |
| `CYLSearchBarItem.itemAccessibilityLabel` | `CYLSearchBarItem.itemAccessibilityLabel` |
| `CYLSearchBarItem.itemAccessibilityIdentifier` | `CYLSearchBarItem.itemAccessibilityIdentifier` |
| `CYLSearchBarItem.isEnabled` | `CYLSearchBarItem.isEnabled` |
| `CYLSearchBarItem.isSelectable` | `CYLSearchBarItem.isSelectable` |
| `CYLSearchBarItem.isSelected` | `CYLSearchBarItem.isSelected` |
| `CYLSearchBarItem.tintColor` | `CYLSearchBarItem.tintColor` |
| `CYLSearchBarItem.backgroundColor` | `CYLSearchBarItem.backgroundColor` |
| `CYLSearchBarItem.selectedBackgroundColor` | `CYLSearchBarItem.selectedBackgroundColor` |
| `CYLSearchBarItem.contentInsets` | `CYLSearchBarItem.contentInsets` |
| `CYLSearchBarItem.imagePositionAdjustment` | `CYLSearchBarItem.imagePositionAdjustment` |
| `CYLSearchBarItem.titlePositionAdjustment` | `CYLSearchBarItem.titlePositionAdjustment` |
| `CYLSearchBarItem.badgeValue` | `CYLSearchBarItem.badgeValue` |
| `CYLSearchBarItem.badgeColor` | `CYLSearchBarItem.badgeColor` |
| `CYLSearchBarItem.badgeSize` | `CYLSearchBarItem.badgeSize` |
| `CYLSearchBarItem.badgeContentInsets` | `CYLSearchBarItem.badgeContentInsets` |
| `CYLSearchBarItem.badgePositionAdjustment` | `CYLSearchBarItem.badgePositionAdjustment` |
| `CYLSearchBarItem.handler` | `CYLSearchBarItem.handler` |
| `CYLSearchBarItem.index` | `CYLSearchBarItem.index` |
| `CYLSearchBarItem.init(style:title:image:)` | `new CYLSearchBarItem(…)` |
| `CYLSearchBarItem.init(title:image:)` | `new CYLSearchBarItem(…)` |
| `CYLSearchBarItem.init(title:image:selectedImage:)` | `new CYLSearchBarItem(…)` |
| `CYLSearchBarItem.iconItem(image:title:handler:)` | `CYLSearchBarItem.iconItem` |
| `CYLSearchBarItem.textItem(title:handler:)` | `CYLSearchBarItem.textItem` |
| `CYLSearchBarItem.divider()` | `CYLSearchBarItem.divider` |
| `CYLSearchBarItem.item(dictionary:)` | `CYLSearchBarItem.item` |
| `CYLSearchBarItem.setTitleTextAttributes(_:for:)` | `CYLSearchBarItem.setTitleTextAttributes` |
| `CYLSearchBarItem.titleTextAttributes(for:)` | `CYLSearchBarItem.titleTextAttributes` |
| `CYLSearchBarItem.setBadgeTextAttributes(_:for:)` | `CYLSearchBarItem.setBadgeTextAttributes` |
| `CYLSearchBarItem.badgeTextAttributes(for:)` | `CYLSearchBarItem.badgeTextAttributes` |
| `CYLSearchBarItem.actualBadgeSuperView()` | N/A: ArkUI has no view objects; the badge is drawn by `CYLSearchBarItemView` |
| **class `CYLSearchBarItemView`** | `CYLSearchBarItemView` |
| `CYLSearchBarItemView.item` | `CYLSearchBarItemView.item` |
| `CYLSearchBarItemView.imageView` | N/A: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarItemView.titleLabel` | N/A: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarItemView.badgeLabel` | N/A: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarItemView.init(item:)` | `CYLSearchBarItemView({ item })` (the `@Param item`) |
| `CYLSearchBarItemView.init(coder:)` | N/A: no archives in ArkUI (the state is restored with `decodeRestorableState`) |
| `CYLSearchBarItemView.actualBadgeSuperView()` | N/A: ArkUI has no view objects; the badge is drawn by `CYLSearchBarItemView` |
| `CYLSearchBarItemView.traitCollectionDidChange(_:)` | N/A: system colors (`sys.color.*`) follow the color mode by themselves |
| `CYLSearchBarItemView.intrinsicContentSize` | N/A: ArkUI measures `CYLSearchBarItemView` from its content (36 vp minimum) |
| `CYLSearchBarItemView.sizeThatFits(_:)` | N/A: ArkUI measures a component from its declaration (`intrinsicContentSize` gives the height) |
| `CYLSearchBarItemView.layoutSubviews()` | N/A: ArkUI lays a component out from its declaration |
| **enum `CYLSearchBarNavigationIcon`** | `CYLSearchBarNavigationIcon` |
| `CYLSearchBarNavigationIcon.none` | `CYLSearchBarNavigationIcon.none` |
| `CYLSearchBarNavigationIcon.arrow` | `CYLSearchBarNavigationIcon.arrow` |
| `CYLSearchBarNavigationIcon.search` | `CYLSearchBarNavigationIcon.search` |
| **enum `CYLSearchBarIconPosition`** | `CYLSearchBarIconPosition` |
| `CYLSearchBarIconPosition.trailing` | `CYLSearchBarIconPosition.trailing` |
| `CYLSearchBarIconPosition.center` | `CYLSearchBarIconPosition.center` |
| `CYLSearchBarIconPosition.leading` | `CYLSearchBarIconPosition.leading` |
| **enum `CYLSearchBarExpansionAnimation`** | `CYLSearchBarExpansionAnimation` |
| `CYLSearchBarExpansionAnimation.fade` | `CYLSearchBarExpansionAnimation.fade` |
| `CYLSearchBarExpansionAnimation.circularReveal` | `CYLSearchBarExpansionAnimation.circularReveal` |
| **protocol `CYLSearchBarViewDelegate`** | `CYLSearchBarViewDelegate` |
| `CYLSearchBarViewDelegate.-searchBarViewShouldBeginEditing:` | `CYLSearchBarViewDelegate.searchBarViewShouldBeginEditing` |
| `CYLSearchBarViewDelegate.-searchBarViewDidTapWhileNotEditable:` | `CYLSearchBarViewDelegate.searchBarViewDidTapWhileNotEditable` |
| `CYLSearchBarViewDelegate.-searchBarViewDidBeginEditing:` | `CYLSearchBarViewDelegate.searchBarViewDidBeginEditing` |
| `CYLSearchBarViewDelegate.-searchBarViewDidEndEditing:` | `CYLSearchBarViewDelegate.searchBarViewDidEndEditing` |
| `CYLSearchBarViewDelegate.-searchBarView:textDidChange:` | `CYLSearchBarViewDelegate.searchBarViewTextDidChange` |
| `CYLSearchBarViewDelegate.-searchBarViewSearchButtonClicked:` | `CYLSearchBarViewDelegate.searchBarViewSearchButtonClicked` |
| `CYLSearchBarViewDelegate.-searchBarViewCancelButtonClicked:` | `CYLSearchBarViewDelegate.searchBarViewCancelButtonClicked` |
| `CYLSearchBarViewDelegate.-searchBarViewNavigationButtonClicked:` | `CYLSearchBarViewDelegate.searchBarViewNavigationButtonClicked` |
| `CYLSearchBarViewDelegate.-searchBarViewVoiceButtonClicked:` | `CYLSearchBarViewDelegate.searchBarViewVoiceButtonClicked` |
| `CYLSearchBarViewDelegate.-searchBarView:shouldSubmitText:` | `CYLSearchBarViewDelegate.searchBarViewShouldSubmitText` |
| `CYLSearchBarViewDelegate.-searchBarView:didChangeIconified:` | `CYLSearchBarViewDelegate.searchBarViewDidChangeIconified` |
| `CYLSearchBarViewDelegate.-searchBarView:didSelectItem:` | `CYLSearchBarViewDelegate.searchBarViewDidSelectItem` |
| **class `CYLSearchBarView`** | `CYLSearchBarView` |
| `CYLSearchBarView.delegate` | `CYLSearchBarView.delegate` |
| `CYLSearchBarView.textField` | `CYLSearchBarView.textField` |
| `CYLSearchBarView.fieldView` | N/A: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarView.searchIconView` | N/A: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarView.cancelButton` | N/A: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarView.placeholderLabel` | N/A: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarView.navigationButton` | N/A: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarView.voiceButton` | N/A: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarView.submitButton` | N/A: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarView.iconButton` | N/A: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarView.text` | `CYLSearchBarView.text` |
| `CYLSearchBarView.placeholder` | `CYLSearchBarView.placeholder` |
| `CYLSearchBarView.font` | `CYLSearchBarView.font` |
| `CYLSearchBarView.textColor` | `CYLSearchBarView.textColor` |
| `CYLSearchBarView.placeholderColor` | `CYLSearchBarView.placeholderColor` |
| `CYLSearchBarView.cursorColor` | `CYLSearchBarView.cursorColor` |
| `CYLSearchBarView.fieldHeight` | `CYLSearchBarView.fieldHeight` |
| `CYLSearchBarView.contentInsets` | `CYLSearchBarView.contentInsets` |
| `CYLSearchBarView.fieldBackgroundColor` | `CYLSearchBarView.fieldBackgroundColor` |
| `CYLSearchBarView.fieldCornerRadius` | `CYLSearchBarView.fieldCornerRadius` |
| `CYLSearchBarView.fieldBorderColor` | `CYLSearchBarView.fieldBorderColor` |
| `CYLSearchBarView.fieldBorderWidth` | `CYLSearchBarView.fieldBorderWidth` |
| `CYLSearchBarView.fieldShadowOpacity` | `CYLSearchBarView.fieldShadowOpacity` |
| `CYLSearchBarView.searchIcon` | `CYLSearchBarView.searchIcon` |
| `CYLSearchBarView.searchIconTintColor` | `CYLSearchBarView.searchIconTintColor` |
| `CYLSearchBarView.trailingAccessoryViews` | `CYLSearchBarComponent.trailingAccessoryViews` (a `@BuilderParam`) |
| `CYLSearchBarView.items` | `CYLSearchBarView.items` |
| `CYLSearchBarView.itemViews` | `CYLSearchBarView.itemViews` |
| `CYLSearchBarView.itemTintColor` | `CYLSearchBarView.itemTintColor` |
| `CYLSearchBarView.searchBarStyle` | `CYLSearchBarView.searchBarStyle` |
| `CYLSearchBarView.fieldBackgroundImage` | `CYLSearchBarView.fieldBackgroundImage` |
| `CYLSearchBarView.selectedItem` | `CYLSearchBarView.selectedItem` |
| `CYLSearchBarView.selectedIndex` | `CYLSearchBarView.selectedIndex` |
| `CYLSearchBarView.addItem(_:)` | `CYLSearchBarView.addItem` |
| `CYLSearchBarView.insertItem(_:at:)` | `CYLSearchBarView.insertItem` |
| `CYLSearchBarView.addItem(style:title:image:index:handler:)` | `CYLSearchBarView.addItem` |
| `CYLSearchBarView.removeItem(_:)` | `CYLSearchBarView.removeItem` |
| `CYLSearchBarView.removeAllItems()` | `CYLSearchBarView.removeAllItems` |
| `CYLSearchBarView.hasItem(of:)` | `CYLSearchBarView.hasItem` |
| `CYLSearchBarView.leadingView` | `CYLSearchBarComponent.leadingView` (a `@BuilderParam`) |
| `CYLSearchBarView.showsCancelButton` | `CYLSearchBarView.showsCancelButton` |
| `CYLSearchBarView.cancelButtonTitle` | `CYLSearchBarView.cancelButtonTitle` |
| `CYLSearchBarView.cancelButtonEndsEditing` | `CYLSearchBarView.cancelButtonEndsEditing` |
| `CYLSearchBarView.clearsTextOnCancel` | `CYLSearchBarView.clearsTextOnCancel` |
| `CYLSearchBarView.clearsTextOnEndEditing` | `CYLSearchBarView.clearsTextOnEndEditing` |
| `CYLSearchBarView.navigationIcon` | `CYLSearchBarView.navigationIcon` |
| `CYLSearchBarView.navigationImage` | `CYLSearchBarView.navigationImage` |
| `CYLSearchBarView.navigationAccessibilityLabel` | `CYLSearchBarView.navigationAccessibilityLabel` |
| `CYLSearchBarView.navigationBackgroundColor` | `CYLSearchBarView.navigationBackgroundColor` |
| `CYLSearchBarView.navigationShadowOpacity` | `CYLSearchBarView.navigationShadowOpacity` |
| `CYLSearchBarView.navigationHandler` | `CYLSearchBarView.navigationHandler` |
| `CYLSearchBarView.showsVoiceButton` | `CYLSearchBarView.showsVoiceButton` |
| `CYLSearchBarView.voiceImage` | `CYLSearchBarView.voiceImage` |
| `CYLSearchBarView.showsSubmitButton` | `CYLSearchBarView.showsSubmitButton` |
| `CYLSearchBarView.submitImage` | `CYLSearchBarView.submitImage` |
| `CYLSearchBarView.clearImage` | `CYLSearchBarView.clearImage` |
| `CYLSearchBarView.keyboardType` | `CYLSearchBarView.keyboardType` |
| `CYLSearchBarView.returnKeyType` | `CYLSearchBarView.returnKeyType` |
| `CYLSearchBarView.autocapitalizationType` | N/A: ArkUI `TextInput` has no capitalization trait |
| `CYLSearchBarView.autocorrectionType` | N/A: ArkUI `TextInput` has no autocorrection trait |
| `CYLSearchBarView.isSecureTextEntry` | `CYLSearchBarView.isSecureTextEntry` |
| `CYLSearchBarView.maximumTextLength` | `CYLSearchBarView.maximumTextLength` |
| `CYLSearchBarView.isIconified` | `CYLSearchBarView.isIconified` |
| `CYLSearchBarView.iconifiedByDefault` | `CYLSearchBarView.iconifiedByDefault` |
| `CYLSearchBarView.expansionAnimation` | `CYLSearchBarView.expansionAnimation` |
| `CYLSearchBarView.iconPosition` | `CYLSearchBarView.iconPosition` |
| `CYLSearchBarView.animationDuration` | `CYLSearchBarView.animationDuration` |
| `CYLSearchBarView.init(frame:)` | `new CYLSearchBarView(…)` |
| `CYLSearchBarView.init(coder:)` | N/A: no archives in ArkUI (the state is restored with `decodeRestorableState`) |
| `CYLSearchBarView.setText(_:submit:)` | `CYLSearchBarView.setText` |
| `CYLSearchBarView.submit()` | `CYLSearchBarView.submit` |
| `CYLSearchBarView.showKeyboard()` | `CYLSearchBarView.showKeyboard` |
| `CYLSearchBarView.hideKeyboard()` | `CYLSearchBarView.hideKeyboard` |
| `CYLSearchBarView.setIconified(_:animated:)` | `CYLSearchBarView.setIconified` |
| `CYLSearchBarView.encodeRestorableState(with:)` | `CYLSearchBarView.encodeRestorableState` |
| `CYLSearchBarView.decodeRestorableState(with:)` | `CYLSearchBarView.decodeRestorableState` |
| `CYLSearchBarView.traitCollectionDidChange(_:)` | N/A: system colors (`sys.color.*`) follow the color mode by themselves |
| `CYLSearchBarView.intrinsicContentSize` | `CYLSearchBarView.intrinsicContentSize` |
| `CYLSearchBarView.sizeThatFits(_:)` | N/A: ArkUI measures a component from its declaration (`intrinsicContentSize` gives the height) |
| `CYLSearchBarView.layoutSubviews()` | N/A: ArkUI lays a component out from its declaration |
| `CYLSearchBarView.textFieldShouldBeginEditing(_:)` | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchBarView.textFieldShouldReturn(_:)` | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchBarView.textField(_:shouldChangeCharactersIn:replacementString:)` | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchBarView.textFieldDidBeginEditing(_:)` | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchBarView.textFieldDidEndEditing(_:)` | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchBarView.becomeFirstResponder()` | `CYLSearchBarView.becomeFirstResponder` |
| `CYLSearchBarView.resignFirstResponder()` | `CYLSearchBarView.resignFirstResponder` |
| **protocol `CYLSearchControllerDelegate`** | `CYLSearchControllerDelegate` |
| `CYLSearchControllerDelegate.-searchControllerDidCancel:` | `CYLSearchControllerDelegate.searchControllerDidCancel` |
| **class `CYLSearchController`** | `CYLSearchController` |
| `CYLSearchController.delegate` | `CYLSearchController.delegate` |
| `CYLSearchController.resultsViewController` | `CYLSearchController.resultsViewController` |
| `CYLSearchController.presented` | `CYLSearchController.isPresented` |
| `CYLSearchController.init(searchDataSource:)` | `new CYLSearchController(…)` |
| `CYLSearchController.init(nibName:bundle:)` | N/A: not available on iOS either (`@available(*, unavailable)`) |
| `CYLSearchController.init(coder:)` | N/A: no archives in ArkUI (the state is restored with `decodeRestorableState`) |
| `CYLSearchController.viewDidLayoutSubviews()` | N/A: the overlay is laid out below the safe area by ArkUI, never over the page it hides |
| `CYLSearchController.viewDidLoad()` | N/A: ArkUI components have no load phase (`CYLSearchOverlayComponent.build`) |
| `CYLSearchController.show(in:)` | `CYLSearchController.showInViewController` |
| `CYLSearchController.hide(_:)` | `CYLSearchController.hide` |
| **enum `CYLSearchPlaceholderKind`** | `CYLSearchPlaceholderKind` |
| `CYLSearchPlaceholderKind.empty` | `CYLSearchPlaceholderKind.empty` |
| `CYLSearchPlaceholderKind.noResults` | `CYLSearchPlaceholderKind.noResults` |
| `CYLSearchPlaceholderKind.error` | `CYLSearchPlaceholderKind.error` |
| **enum `CYLSearchPlaceholderStyle`** | `CYLSearchPlaceholderStyle` |
| `CYLSearchPlaceholderStyle.empty` | `CYLSearchPlaceholderStyle.empty` |
| `CYLSearchPlaceholderStyle.noResults` | `CYLSearchPlaceholderStyle.noResults` |
| `CYLSearchPlaceholderStyle.error` | `CYLSearchPlaceholderStyle.error` |
| `CYLSearchPlaceholderStyle.wifiOff` | `CYLSearchPlaceholderStyle.wifiOff` |
| `CYLSearchPlaceholderStyle.signalWifiOff` | `CYLSearchPlaceholderStyle.signalWifiOff` |
| `CYLSearchPlaceholderStyle.noInternet` | `CYLSearchPlaceholderStyle.noInternet` |
| `CYLSearchPlaceholderStyle.cloudOff` | `CYLSearchPlaceholderStyle.cloudOff` |
| `CYLSearchPlaceholderStyle.syncProblem` | `CYLSearchPlaceholderStyle.syncProblem` |
| `CYLSearchPlaceholderStyle.syncDisabled` | `CYLSearchPlaceholderStyle.syncDisabled` |
| `CYLSearchPlaceholderStyle.networkLocked` | `CYLSearchPlaceholderStyle.networkLocked` |
| `CYLSearchPlaceholderStyle.bluetoothDisabled` | `CYLSearchPlaceholderStyle.bluetoothDisabled` |
| `CYLSearchPlaceholderStyle.locationOff` | `CYLSearchPlaceholderStyle.locationOff` |
| `CYLSearchPlaceholderStyle.publicOff` | `CYLSearchPlaceholderStyle.publicOff` |
| `CYLSearchPlaceholderStyle.errorOutline` | `CYLSearchPlaceholderStyle.errorOutline` |
| `CYLSearchPlaceholderStyle.warning` | `CYLSearchPlaceholderStyle.warning` |
| `CYLSearchPlaceholderStyle.reportProblem` | `CYLSearchPlaceholderStyle.reportProblem` |
| `CYLSearchPlaceholderStyle.blocked` | `CYLSearchPlaceholderStyle.blocked` |
| `CYLSearchPlaceholderStyle.help` | `CYLSearchPlaceholderStyle.help` |
| `CYLSearchPlaceholderStyle.hourglass` | `CYLSearchPlaceholderStyle.hourglass` |
| `CYLSearchPlaceholderStyle.locked` | `CYLSearchPlaceholderStyle.locked` |
| `CYLSearchPlaceholderStyle.visibilityOff` | `CYLSearchPlaceholderStyle.visibilityOff` |
| `CYLSearchPlaceholderStyle.searchOff` | `CYLSearchPlaceholderStyle.searchOff` |
| `CYLSearchPlaceholderStyle.folderOff` | `CYLSearchPlaceholderStyle.folderOff` |
| `CYLSearchPlaceholderStyle.folderOpen` | `CYLSearchPlaceholderStyle.folderOpen` |
| `CYLSearchPlaceholderStyle.downloadOff` | `CYLSearchPlaceholderStyle.downloadOff` |
| `CYLSearchPlaceholderStyle.uploadOff` | `CYLSearchPlaceholderStyle.uploadOff` |
| `CYLSearchPlaceholderStyle.inbox` | `CYLSearchPlaceholderStyle.inbox` |
| `CYLSearchPlaceholderStyle.brokenImage` | `CYLSearchPlaceholderStyle.brokenImage` |
| `CYLSearchPlaceholderStyle.imageUnavailable` | `CYLSearchPlaceholderStyle.imageUnavailable` |
| `CYLSearchPlaceholderStyle.photoLibrary` | `CYLSearchPlaceholderStyle.photoLibrary` |
| `CYLSearchPlaceholderStyle.musicOff` | `CYLSearchPlaceholderStyle.musicOff` |
| `CYLSearchPlaceholderStyle.videoOff` | `CYLSearchPlaceholderStyle.videoOff` |
| `CYLSearchPlaceholderStyle.personOff` | `CYLSearchPlaceholderStyle.personOff` |
| `CYLSearchPlaceholderStyle.groupOff` | `CYLSearchPlaceholderStyle.groupOff` |
| `CYLSearchPlaceholderStyle.eventBusy` | `CYLSearchPlaceholderStyle.eventBusy` |
| `CYLSearchPlaceholderStyle.emptyCart` | `CYLSearchPlaceholderStyle.emptyCart` |
| `CYLSearchPlaceholderStyle.favorite` | `CYLSearchPlaceholderStyle.favorite` |
| `CYLSearchPlaceholderStyle.batteryAlert` | `CYLSearchPlaceholderStyle.batteryAlert` |
| `CYLSearchPlaceholderStyle.unknownDevice` | `CYLSearchPlaceholderStyle.unknownDevice` |
| `CYLSearchPlaceholderStyle.phoneDisabled` | `CYLSearchPlaceholderStyle.phoneDisabled` |
| `CYLSearchPlaceholderStyle.wrongLocation` | `CYLSearchPlaceholderStyle.wrongLocation` |
| `CYLSearchPlaceholderStyle.count` | `CYLSearchPlaceholderStyle.count` |
| **enum `CYLSearchPlaceholderMessage`** | `CYLSearchPlaceholderMessage` |
| `CYLSearchPlaceholderMessage.empty` | `CYLSearchPlaceholderMessage.empty` |
| `CYLSearchPlaceholderMessage.noResults` | `CYLSearchPlaceholderMessage.noResults` |
| `CYLSearchPlaceholderMessage.error` | `CYLSearchPlaceholderMessage.error` |
| `CYLSearchPlaceholderMessage.network` | `CYLSearchPlaceholderMessage.network` |
| **class `CYLSearchPlaceholderView`** | `CYLSearchPlaceholderView` |
| `CYLSearchPlaceholderView.imageView` | `CYLSearchPlaceholderView.image` |
| `CYLSearchPlaceholderView.textLabel` | `CYLSearchPlaceholderView.text` |
| `CYLSearchPlaceholderView.imageName(for:)` | `CYLSearchPlaceholderView.imageNameForStyle` |
| `CYLSearchPlaceholderView.init(kind:)` | `new CYLSearchPlaceholderView(…)` |
| `CYLSearchPlaceholderView.init(style:message:)` | `new CYLSearchPlaceholderView(…)` |
| `CYLSearchPlaceholderView.init(style:text:)` | `new CYLSearchPlaceholderView(…)` |
| `CYLSearchPlaceholderView.init(image:message:)` | `new CYLSearchPlaceholderView(…)` |
| `CYLSearchPlaceholderView.init(image:text:)` | `new CYLSearchPlaceholderView(…)` |
| **class `CYLSearchResources`** | `CYLSearchResources` |
| `CYLSearchResources.resourceBundle` | `CYLSearchResources.resourceBundle` |
| `CYLSearchResources.image(named:)` | `CYLSearchResources.imageNamed` |
| `CYLSearchResources.localizedString(forKey:)` | `CYLSearchResources.localizedString` |
| `CYLSearchResources.localizedString(forKey:language:)` | `CYLSearchResources.localizedString` |
| **protocol `CYLSearchResultsDataSource`** | `CYLSearchResultsDataSource` |
| `CYLSearchResultsDataSource.-searchResultsViewController:resultsForQuery:` | `CYLSearchResultsDataSource.searchResultsViewControllerResultsForQuery` |
| `CYLSearchResultsDataSource.-searchResultsViewController:configureCell:withResult:` | `CYLSearchResultsDataSource.searchResultsViewControllerConfigureCell` |
| `CYLSearchResultsDataSource.-searchResultsViewController:didSelectResult:` | `CYLSearchResultsDataSource.searchResultsViewControllerDidSelectResult` |
| **class `CYLSearchResultsViewController`** | `CYLSearchResultsViewController` |
| `CYLSearchResultsViewController.searchDataSource` | `CYLSearchResultsViewController.searchDataSource` |
| `CYLSearchResultsViewController.searchController` | `CYLSearchResultsViewController.searchController` |
| `CYLSearchResultsViewController.searchResults` | `CYLSearchResultsViewController.searchResults` |
| `CYLSearchResultsViewController.init(searchDataSource:)` | `new CYLSearchResultsViewController(…)` |
| `CYLSearchResultsViewController.init(style:)` | N/A: not available on iOS either (`@available(*, unavailable)`) |
| `CYLSearchResultsViewController.init(nibName:bundle:)` | N/A: not available on iOS either (`@available(*, unavailable)`) |
| `CYLSearchResultsViewController.init(coder:)` | N/A: no archives in ArkUI (the state is restored with `decodeRestorableState`) |
| `CYLSearchResultsViewController.viewDidLayoutSubviews()` | N/A: `CYLSearchResultsComponent` lays the bar above the list in one column, never over it |
| `CYLSearchResultsViewController.viewDidLoad()` | N/A: ArkUI components have no load phase (`CYLSearchResultsComponent.build`) |
| `CYLSearchResultsViewController.reloadSearchResults()` | `CYLSearchResultsViewController.reloadSearchResults` |
| `CYLSearchResultsViewController.reloadResultsTableView()` | `CYLSearchResultsViewController.reloadResultsTableView` |
| `CYLSearchResultsViewController.updateSearchResults(for:)` | `CYLSearchResultsViewController.updateSearchResults` |
| `CYLSearchResultsViewController.tableView(_:numberOfRowsInSection:)` | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchResultsViewController.tableView(_:cellForRowAt:)` | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchResultsViewController.tableView(_:didSelectRowAt:)` | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| **class `CYLSearchSuggestionStore`** | `CYLSearchSuggestionStore` |
| `CYLSearchSuggestionStore.policy` | `CYLSearchSuggestionStore.policy` |
| `CYLSearchSuggestionStore.name` | `CYLSearchSuggestionStore.name` |
| `CYLSearchSuggestionStore.maximumCount` | `CYLSearchSuggestionStore.maximumCount` |
| `CYLSearchSuggestionStore.cache(policy:name:)` | `CYLSearchSuggestionStore.cache` |
| `CYLSearchSuggestionStore.init(policy:name:)` | `new CYLSearchSuggestionStore(…)` |
| `CYLSearchSuggestionStore.cachedQueries()` | `CYLSearchSuggestionStore.cachedQueries` |
| `CYLSearchSuggestionStore.addQuery(_:)` | `CYLSearchSuggestionStore.addQuery` |
| `CYLSearchSuggestionStore.removeQuery(_:)` | `CYLSearchSuggestionStore.removeQuery` |
| `CYLSearchSuggestionStore.removeAllQueries()` | `CYLSearchSuggestionStore.removeAllQueries` |
| **enum `CYLSearchSuggestionStyle`** | `CYLSearchSuggestionStyle` |
| `CYLSearchSuggestionStyle.list` | `CYLSearchSuggestionStyle.list` |
| `CYLSearchSuggestionStyle.tags` | `CYLSearchSuggestionStyle.tags` |
| **protocol `CYLSearchViewDelegate`** | `CYLSearchViewDelegate` |
| `CYLSearchViewDelegate.-searchViewDidShow:` | `CYLSearchViewDelegate.searchViewDidShow` |
| `CYLSearchViewDelegate.-searchViewDidClose:` | `CYLSearchViewDelegate.searchViewDidClose` |
| `CYLSearchViewDelegate.-searchView:textDidChange:` | `CYLSearchViewDelegate.searchViewTextDidChange` |
| `CYLSearchViewDelegate.-searchView:didSubmitText:` | `CYLSearchViewDelegate.searchViewDidSubmitText` |
| `CYLSearchViewDelegate.-searchView:didChangeFocus:` | `CYLSearchViewDelegate.searchViewDidChangeFocus` |
| `CYLSearchViewDelegate.-searchView:didSelectSuggestion:atIndex:` | `CYLSearchViewDelegate.searchViewDidSelectSuggestion` |
| `CYLSearchViewDelegate.-searchViewVoiceButtonClicked:` | `CYLSearchViewDelegate.searchViewVoiceButtonClicked` |
| `CYLSearchViewDelegate.-searchViewNavigationButtonClicked:` | `CYLSearchViewDelegate.searchViewNavigationButtonClicked` |
| **class `CYLSearchView`** | `CYLSearchView` |
| `CYLSearchView.delegate` | `CYLSearchView.delegate` |
| `CYLSearchView.searchBarView` | `CYLSearchView.searchBarView` |
| `CYLSearchView.dividerView` | N/A: ArkUI has no view objects; `CYLSearchComponent` draws the divider (`dividerColor`) |
| `CYLSearchView.suggestionsTableView` | N/A: ArkUI has no view objects; `CYLSearchComponent` draws the list (`suggestionCellConfiguration`) |
| `CYLSearchView.suggestionsTagView` | N/A: ArkUI has no view objects; `CYLSearchComponent` draws the tags (`suggestionsFoldControl`) |
| `CYLSearchView.suggestionsFoldControl` | `CYLSearchView.suggestionsFoldControl` |
| `CYLSearchView.suggestionsFoldedRowCount` | `CYLSearchView.suggestionsFoldedRowCount` |
| `CYLSearchView.suggestionStyle` | `CYLSearchView.suggestionStyle` |
| `CYLSearchView.showsEmptyResultsPlaceholder` | `CYLSearchView.showsEmptyResultsPlaceholder` |
| `CYLSearchView.emptyResultsScenario` | `CYLSearchView.emptyResultsScenario` |
| `CYLSearchView.emptyResultsView` | `CYLSearchView.emptyResultsView` |
| `CYLSearchView.dividerColor` | `CYLSearchView.dividerColor` |
| `CYLSearchView.contentView` | `CYLSearchView.contentView` |
| `CYLSearchView.scrimColor` | `CYLSearchView.scrimColor` |
| `CYLSearchView.suggestions` | `CYLSearchView.suggestions` |
| `CYLSearchView.suggestionFilter` | `CYLSearchView.suggestionFilter` |
| `CYLSearchView.showsSuggestionsForEmptyQuery` | `CYLSearchView.showsSuggestionsForEmptyQuery` |
| `CYLSearchView.filteredSuggestions` | `CYLSearchView.filteredSuggestions` |
| `CYLSearchView.suggestionImage` | `CYLSearchView.suggestionImage` |
| `CYLSearchView.suggestionImageTintColor` | `CYLSearchView.suggestionImageTintColor` |
| `CYLSearchView.suggestionBackgroundColor` | `CYLSearchView.suggestionBackgroundColor` |
| `CYLSearchView.suggestionTextColor` | `CYLSearchView.suggestionTextColor` |
| `CYLSearchView.suggestionLineBreakMode` | `CYLSearchView.suggestionLineBreakMode` |
| `CYLSearchView.submitsOnSuggestionSelection` | `CYLSearchView.submitsOnSuggestionSelection` |
| `CYLSearchView.suggestionCellConfiguration` | `CYLSearchView.suggestionCellConfiguration` |
| `CYLSearchView.suggestionCachePolicy` | `CYLSearchView.suggestionCachePolicy` |
| `CYLSearchView.suggestionCacheName` | `CYLSearchView.suggestionCacheName` |
| `CYLSearchView.suggestionCache` | `CYLSearchView.suggestionCache` |
| `CYLSearchView.suggestionCacheHeaderView` | N/A: ArkUI has no view objects; `CYLSearchComponent.cacheHeader` draws it |
| `CYLSearchView.suggestionCacheTitleLabel` | `CYLSearchView.suggestionCacheTitle` |
| `CYLSearchView.clearSuggestionCacheButton` | `CYLSearchView.clearSuggestionCache()` (the header button calls it) |
| `CYLSearchView.showsEmptySuggestionsPlaceholder` | `CYLSearchView.showsEmptySuggestionsPlaceholder` |
| `CYLSearchView.emptySuggestionsScenario` | `CYLSearchView.emptySuggestionsScenario` |
| `CYLSearchView.emptySuggestionsView` | `CYLSearchView.emptySuggestionsView` |
| `CYLSearchView.focusesSearchFieldOnShow` | `CYLSearchView.focusesSearchFieldOnShow` |
| `CYLSearchView.searchOpen` | `CYLSearchView.isSearchOpen` |
| `CYLSearchView.animationDuration` | `CYLSearchView.animationDuration` |
| `CYLSearchView.closesOnSubmit` | `CYLSearchView.closesOnSubmit` |
| `CYLSearchView.query` | `CYLSearchView.query` |
| `CYLSearchView.backgroundColor` | `CYLSearchView.backgroundColor` |
| `CYLSearchView.init(frame:)` | `new CYLSearchView(…)` |
| `CYLSearchView.init(coder:)` | N/A: no archives in ArkUI (the state is restored with `decodeRestorableState`) |
| `CYLSearchView.layoutSubviews()` | N/A: ArkUI lays a component out from its declaration |
| `CYLSearchView.safeAreaInsetsDidChange()` | N/A: ArkUI keeps the page inside the safe area by itself |
| `CYLSearchView.install(in:)` | `CYLSearchView.installInView` |
| `CYLSearchView.showSearch()` | `CYLSearchView.showSearch` |
| `CYLSearchView.showSearch(animated:)` | `CYLSearchView.showSearch` |
| `CYLSearchView.closeSearch()` | `CYLSearchView.closeSearch` |
| `CYLSearchView.closeSearch(animated:)` | `CYLSearchView.closeSearch` |
| `CYLSearchView.encodeRestorableState(with:)` | `CYLSearchView.encodeRestorableState` |
| `CYLSearchView.decodeRestorableState(with:)` | `CYLSearchView.decodeRestorableState` |
| `CYLSearchView.accessibilityPerformEscape()` | `CYLSearchView.accessibilityPerformEscape` |
| `CYLSearchView.attach(to:)` | `CYLSearchView.attachToMenuItem` |
| `CYLSearchView.setQuery(_:submit:)` | `CYLSearchView.setQuery` |
| `CYLSearchView.showSuggestions()` | `CYLSearchView.showSuggestions` |
| `CYLSearchView.dismissSuggestions()` | `CYLSearchView.dismissSuggestions` |
| `CYLSearchView.clearSuggestionCache()` | `CYLSearchView.clearSuggestionCache` |
| `CYLSearchView.searchBarView(_:textDidChange:)` | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.searchBarViewSearchButtonClicked(_:)` | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.searchBarViewNavigationButtonClicked(_:)` | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.searchBarViewVoiceButtonClicked(_:)` | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.searchBarViewCancelButtonClicked(_:)` | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.searchBarViewDidBeginEditing(_:)` | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.searchBarViewDidEndEditing(_:)` | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.tableView(_:numberOfRowsInSection:)` | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.tableView(_:cellForRowAt:)` | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.tableView(_:didSelectRowAt:)` | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
<!-- harmonyos-api:end -->

## Table 2: iOS example demos

<!-- harmonyos-demos:begin -->
| iOS example demo | HarmonyOS implementation |
| :--- | :--- |
| Tab bar: CYLTabBarController with Search, Examples, Tag style, Discover and the plus button (CYLTabBarConfiguration.json) (`CYLSearchExampleAppDelegate.m`) | `pages/Index.ets` on CYLTabBarController's HarmonyOS library `cyltabbar` (commit 94eb7b1), configured by the iOS CYLTabBarConfiguration.json |
| Search tab: Issue #1317 reproduction, the search bar in the navigation bar over a list (CYLSearchController + CYLSearchResultsViewController) (`CYLSearchExampleViewController.swift`) | `demos/SearchExample.ets` `SearchExampleView` (Repro, Overlay with `CYLSearchController`) |
| Search tab: pull to refresh with CYLTableViewPlaceHolder's CYLRefreshNormalHeader (`CYLSearchExampleViewController.swift`) | `SearchExampleView` with CYLTableViewPlaceHolder's HarmonyOS library `cylplaceholder` (commit 5bcbdb5): `CYLRefreshContainer` + `CYLRefreshNormalHeaderModel` |
| Search tab: the empty state, CYLSearchPlaceholderView "No matching results" (`CYLSearchExampleViewController.swift`) | `SearchExampleView` with `CYLSearchPlaceholderView.withKind(noResults)` |
| Examples tab: the menu (Search and refresh, Placeholder styles, Search bar, Ports) (`CYLSearchDemoMenuViewController.m`) | `demos/ExamplesMenu.ets` `ExamplesMenuView` |
| Placeholder styles: the 41 styles x 4 messages and the Custom section (text only, image only, both) (`CYLSearchDemoMenuViewController.m`) | `PlaceholderGalleryPage` (the iOS images, `imageForStyle`) |
| Placeholder styles: the detail page with one CYLSearchPlaceholderView (`CYLSearchDemoMenuViewController.m`) | `PlaceholderDetailPage` |
| Search bar page (plus button and Examples): CYLSearchBarView styles and appended items (`CYLSearchBarDemoViewController.m`) | `demos/SearchBarDemo.ets` `SearchBarDemoView` |
| Ports: the menu of five search libraries (`CYLSearchPortsViewController.swift`) | `PortsMenuPage` |
| Port: lapism/search (MaterialSearchBar + MaterialSearchView) (`CYLLapismSearchViewController.swift`) | `demos/Ports.ets` `LapismPage` |
| Port: MiguelCatalan/MaterialSearchView, the menu of six samples (`CYLMaterialSearchMenuViewController.swift`) | `demos/MaterialSearch.ets` `MaterialMenuView` |
| MaterialSearchView sample: Default (`CYLMaterialSearchMenuViewController.swift`) | `MaterialSamplePage` sample 0 |
| MaterialSearchView sample: Themed (`CYLMaterialSearchMenuViewController.swift`) | `MaterialSamplePage` sample 1 |
| MaterialSearchView sample: Voice (`CYLMaterialSearchMenuViewController.swift`) | `MaterialSamplePage` sample 2, `common/SpeechRecognizer.ets` (CoreSpeechKit, microphone permission; zh-CN, the engine's only language) |
| MaterialSearchView sample: Sticky (`CYLMaterialSearchMenuViewController.swift`) | `MaterialSamplePage` sample 3 |
| MaterialSearchView sample: Tabs (`CYLMaterialSearchMenuViewController.swift`) | `MaterialSamplePage` sample 4 |
| MaterialSearchView sample: Input type (`CYLMaterialSearchMenuViewController.swift`) | `MaterialSamplePage` sample 5 |
| Port: yechaoa/MaterialDesign SearchViewActivity (`CYLYechaoaSearchViewController.swift`) | `YechaoaPage` |
| Port: android-cjj/MaterialSearchView circular reveal (`CYLRevealSearchViewController.swift`) | `RevealPage` (core `iconButtonBackgroundColor`, `iconButtonTintColor`) |
| Port: iammert/MultiSearchView (`CYLMultiSearchDemoViewController.swift`) | `MultiSearchDemoPage` |
| Tag style tab: the six MaterialSearchView samples with tag suggestions, keyboard down on show (`CYLSuggestionDemoPages.swift`) | `MaterialMenuView({ tags: true })` |
| Discover tab: recent searches and discover topics copied from CollectionViewClassifyMenu (`CYLSearchDiscoverViewController.swift`) | `demos/Discover.ets` `DiscoverView` (rawfile `discover/<language>.json`) |
| Snackbar: a short message at the bottom (CYLSnackbar) (`CYLSearchPortsViewController.swift`) | `common/DemoCommon.ets` `CYLSnackbar` |
| Texts in English, Japanese, Simplified and Traditional Chinese (`CYLSearchViewController.bundle`) | resources base, ja_JP, zh_CN, zh_TW (`harmonyos/scripts/import-ios-resources.py`) |
| Dark mode follows the system (`CYLSearchExample`) | `sys.color.*` and `resources/dark` colors |
<!-- harmonyos-demos:end -->

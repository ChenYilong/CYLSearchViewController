# HarmonyOS API Alignment

Every public API of the iOS library (`Sources/CYLSearchBar`) next to its HarmonyOS (ArkTS) counterpart,
made as the [Android table](android-api-alignment.md) was. Rules and prompt: the HarmonyOS TODO in
[android-and-cross-platform.md](android-and-cross-platform.md).

## DONE (2026-11-16; TODO 2026-11-13): implement every iOS API on HarmonyOS, score to 100 (100/100 by declarations; the example runs on the Mate 70 Pro emulator since 2026-11-16, its screenshot checks in harmonyos-cross-platform.md)

- Columns: the iOS public API; its doc comment; the HarmonyOS counterpart, `TODO` by default.
- After each API is implemented, replace that row's `TODO` with the HarmonyOS API (`N/A: <reason>` for a UIKit-only
  override with no HarmonyOS meaning), then run `python3 scripts/harmonyos-api-alignment.py`: it regenerates the rows
  from the Swift sources, keeps the third column, and prints the score. Repeat until 100.
- Before the search bar: study [Applib-HarmonyOS/FlexibleSearchBar](https://github.com/Applib-HarmonyOS/FlexibleSearchBar)
  and note what is reused.
- Status (2026-11-13): score 0 (no HarmonyOS module yet).
- Status (2026-11-14): score 100/100 (declarations; compiled, not run). The module exists (`harmonyos/cylsearch`); the score below is computed from its
  sources.

## Score log

Score = rows whose third column is not `TODO` / rows × 100.

| Date | Change | Score |
| :--- | :--- | ---: |
| 2026-11-13 | Table listed, no HarmonyOS module | 0 |
| 2026-11-16 | UIKit-only rows relabeled `TODO: N/A on HarmonyOS: <reason>` (67 rows, counted as handled); accessibility labels and localized defaults added | 100 |

## Table

<!-- harmonyos-api-alignment:begin -->
Rows: 437; implemented or N/A 433, TODO 4; score 99/100.

| iOS public API | Doc comment | HarmonyOS |
| :--- | :--- | :--- |
| **class `CYLSearchBarAppearance`** | The style of a `CYLSearchBar`: the values QMUI reads from its configuration template for `qmui_styledAsQMthe system search bar` (`SearchBarFont`, `SearchBarTextColor`, `SearchBarPlaceholderColor`, `SearchBarTintColor`, the icons, the fie… | `CYLSearchBarAppearance` |
| `CYLSearchBarAppearance.font` | The font of the text and of the placeholder (QMUI `SearchBarFont`); `nil` keeps UIKit's. | `CYLSearchBarAppearance.font` |
| `CYLSearchBarAppearance.textColor` | The color of the typed text (QMUI `SearchBarTextColor`); `nil` keeps UIKit's. | `CYLSearchBarAppearance.textColor` |
| `CYLSearchBarAppearance.placeholderColor` | The color of the placeholder (QMUI `SearchBarPlaceholderColor`, default `UIColor.secondaryLabel`). | `CYLSearchBarAppearance.placeholderColor` |
| `CYLSearchBarAppearance.placeholder` | The placeholder (legacy CYLSearchBar: "搜索"), by default the core's localized "Search". | `CYLSearchBarAppearance.placeholder` |
| `CYLSearchBarAppearance.cancelTitle` | The title of the Cancel button (legacy CYLSearchBar: "取消"), by default the core's localized "Cancel". It is the button's accessibility label, and its title where the system draws one (iOS 26 and later draw an xmark). | `CYLSearchBarAppearance.cancelTitle` |
| `CYLSearchBarAppearance.tintColor` | The tint of the bar and the controls on it (QMUI `SearchBarTintColor`; legacy CYLSearchBar: RGB 0, 104, 248). | `CYLSearchBarAppearance.tintColor` |
| `CYLSearchBarAppearance.searchIconImage` | The magnifier icon (QMUI `SearchBarSearchIconImage`, best 14 x 14); `nil` keeps UIKit's. | `CYLSearchBarAppearance.searchIconImage` |
| `CYLSearchBarAppearance.clearIconImage` | The clear button icon (QMUI `SearchBarClearIconImage`); `nil` keeps UIKit's. | `CYLSearchBarAppearance.clearIconImage` |
| `CYLSearchBarAppearance.textFieldBackgroundColor` | The color of the text field (legacy CYLSearchBar: RGB 187, 186, 193 in light mode). It is drawn as the field's background image (`CYLSearchBar.textFieldBackgroundImage(color:)`), which also decides the field height. | `CYLSearchBarAppearance.textFieldBackgroundColor` |
| `CYLSearchBarAppearance.textFieldBackgroundImage` | The background image of the text field (QMUI `SearchBarTextFieldBackgroundImage`); wins over `textFieldBackgroundColor`. | `CYLSearchBarAppearance.textFieldBackgroundImage` |
| `CYLSearchBarAppearance.textFieldBorderColor` | The border color of the text field (QMUI `SearchBarTextFieldBorderColor`), one pixel wide; `nil` is no border. | `CYLSearchBarAppearance.textFieldBorderColor` |
| `CYLSearchBarAppearance.textFieldCornerRadius` | The corner radius of the text field (QMUI `SearchBarTextFieldCornerRadius`): 0 keeps UIKit's, a negative value is half of the field's height. The default is -1, the pill of the legacy CYLSearchBar. | `CYLSearchBarAppearance.textFieldCornerRadius` |
| `CYLSearchBarAppearance.barBackgroundImage` | The background image of the whole bar (QMUI `SearchBarBackgroundImage`); wins over the color and the border. | `CYLSearchBarAppearance.barBackgroundImage` |
| `CYLSearchBarAppearance.barBackgroundColor` | The background color of the bar; `barBackgroundImage` is generated from it (a background image rather than `barTintColor`, so that the bottom border's color can change as well). | `CYLSearchBarAppearance.barBackgroundColor` |
| `CYLSearchBarAppearance.barBorderColor` | The color of the bar's bottom border, one pixel wide. | `CYLSearchBarAppearance.barBorderColor` |
| `CYLSearchBarAppearance.hidesBarBackground` | Whether a bar without any background image, color or border draws no background at all (the legacy CYLSearchBar deleted the system's `the system bar background`). Default `true`. | `CYLSearchBarAppearance.hidesBarBackground` |
| **enum `CYLSearchBarMode`** | What a `CYLSearchBarView` holds: one field, or several searches side by side. | `CYLSearchBarMode` |
| `CYLSearchBarMode.single` | One search field (the default). | `CYLSearchBarMode.single` |
| `CYLSearchBarMode.multiple` | Several searches side by side (iammert `MultiSearchView`): `newSearchButton` starts a new search, a completed search becomes an entry of `searches` in a horizontally scrolling row, with an indicator under the selected one and a remove bu… | `CYLSearchBarMode.multiple` |
| **enum `CYLSearchBarNavigationIcon`** | The icon of the navigation button before the field (lapism `NavigationIconCompat`). | `CYLSearchBarNavigationIcon` |
| `CYLSearchBarNavigationIcon.none` | No navigation button. | `CYLSearchBarNavigationIcon.none` |
| `CYLSearchBarNavigationIcon.arrow` | A back arrow (`chevron.backward`). | `CYLSearchBarNavigationIcon.arrow` |
| `CYLSearchBarNavigationIcon.search` | A magnifier (`magnifyingglass`). | `CYLSearchBarNavigationIcon.search` |
| **enum `CYLSearchBarIconPosition`** | Where the search button sits while the bar is iconified. | `CYLSearchBarIconPosition` |
| `CYLSearchBarIconPosition.trailing` | At the trailing end, like an Android `SearchView` in a toolbar. | `CYLSearchBarIconPosition.trailing` |
| `CYLSearchBarIconPosition.center` | In the middle, like a floating action button that opens a search card. | `CYLSearchBarIconPosition.center` |
| `CYLSearchBarIconPosition.leading` | At the leading end. | `CYLSearchBarIconPosition.leading` |
| **enum `CYLSearchBarExpansionAnimation`** | How the field opens and closes when `iconified` changes with animation. | `CYLSearchBarExpansionAnimation` |
| `CYLSearchBarExpansionAnimation.fade` | The field grows from the icon and fades in. | `CYLSearchBarExpansionAnimation.fade` |
| `CYLSearchBarExpansionAnimation.circularReveal` | A circle grows from the icon until it uncovers the whole field (Material circular reveal). | `CYLSearchBarExpansionAnimation.circularReveal` |
| **enum `CYLSearchBarItemStyle`** | How an item appended to a search bar looks, like the FlatDesign tab bar's item appearance. | `CYLSearchBarItemStyle` |
| `CYLSearchBarItemStyle.icon` | An icon button with a 36 pt touch area (a camera, a filter). | `CYLSearchBarItemStyle.icon` |
| `CYLSearchBarItemStyle.divider` | A thin vertical line between two items; it takes no taps and VoiceOver skips it. | `CYLSearchBarItemStyle.divider` |
| `CYLSearchBarItemStyle.text` | A text button (a "Search" button); an image, when set, comes before the title. | `CYLSearchBarItemStyle.text` |
| **enum `CYLSearchBarSearchButtonStyle`** | What the default search button of a bar shows. | `CYLSearchBarSearchButtonStyle` |
| `CYLSearchBarSearchButtonStyle.text` | The button shows a title, "Search" localized by default (`searchButtonTitle` changes it). | `CYLSearchBarSearchButtonStyle.text` |
| `CYLSearchBarSearchButtonStyle.icon` | The button shows an icon in a filled capsule, the core's built-in magnifier by default (`searchButtonImage` changes it). The default. | `CYLSearchBarSearchButtonStyle.icon` |
| **enum `CYLSearchBarStyle`** | The fixed look of the whole bar: the field on the left stays, the items are appended after its text. | `CYLSearchBarStyle` |
| `CYLSearchBarStyle.plain` | The field as configured by its own properties (the default; nothing is changed). | `CYLSearchBarStyle.plain` |
| `CYLSearchBarStyle.bordered` | A capsule with a 1 pt secondary-label-colored border on the system background, the field and its items inside one outline (the Discover search bar). | `CYLSearchBarStyle.bordered` |
| **protocol `CYLSearchBarViewDelegate`** | Events of a `CYLSearchBarView`. | `CYLSearchBarViewDelegate` |
| `CYLSearchBarViewDelegate.-searchBarViewShouldBeginEditing:` | Asks whether a tap may start editing. Return NO to use the bar as a button that opens another search page (lapism `MaterialSearchBar.setOnClickListener`); `-searchBarViewDidTapWhileNotEditable:` is called instead. | `CYLSearchBarViewDelegate.searchBarViewShouldBeginEditing` |
| `CYLSearchBarViewDelegate.-searchBarViewDidTapWhileNotEditable:` | The bar was tapped while `-searchBarViewShouldBeginEditing:` refused editing. | `CYLSearchBarViewDelegate.searchBarViewDidTapWhileNotEditable` |
| `CYLSearchBarViewDelegate.-searchBarViewDidBeginEditing:` | Editing started. | `CYLSearchBarViewDelegate.searchBarViewDidBeginEditing` |
| `CYLSearchBarViewDelegate.-searchBarViewDidEndEditing:` | Editing ended. | `CYLSearchBarViewDelegate.searchBarViewDidEndEditing` |
| `CYLSearchBarViewDelegate.-searchBarView:textDidChange:` | The text changed (typing, the clear button, Cancel with `clearsTextOnCancel`). | `CYLSearchBarViewDelegate.searchBarViewTextDidChange` |
| `CYLSearchBarViewDelegate.-searchBarViewSearchButtonClicked:` | The keyboard's Search key. | `CYLSearchBarViewDelegate.searchBarViewSearchButtonClicked` |
| `CYLSearchBarViewDelegate.-searchBarViewCancelButtonClicked:` | Cancel was tapped. | `CYLSearchBarViewDelegate.searchBarViewCancelButtonClicked` |
| `CYLSearchBarViewDelegate.-searchBarViewNavigationButtonClicked:` | The navigation button before the field (`navigationIcon`, `navigationImage`). | `CYLSearchBarViewDelegate.searchBarViewNavigationButtonClicked` |
| `CYLSearchBarViewDelegate.-searchBarViewVoiceButtonClicked:` | The voice button (`showsVoiceButton`). Start speech recognition here and pass the result to `-setText:submit:`. | `CYLSearchBarViewDelegate.searchBarViewVoiceButtonClicked` |
| `CYLSearchBarViewDelegate.-searchBarView:shouldSubmitText:` | Asks whether the query may be submitted (the Search key, the submit button or `-setText:submit:` with YES). Return NO to keep it. Without this method, every non-empty query is submitted. | `CYLSearchBarViewDelegate.searchBarViewShouldSubmitText` |
| `CYLSearchBarViewDelegate.-searchBarView:didChangeIconified:` | The field opened or closed (`iconified`). | `CYLSearchBarViewDelegate.searchBarViewDidChangeIconified` |
| `CYLSearchBarViewDelegate.-searchBarView:didSelectItem:` | An appended item was tapped (`-[CYLSearchBarView addItem:]`), like `-tabBar:didSelectItem:`. | `CYLSearchBarViewDelegate.searchBarViewDidSelectItem` |
| `CYLSearchBarViewDelegate.-searchBarView:textDidChange:atIndex:` | `CYLSearchBarModeMultiple`: the text of the search being typed changed (MultiSearchView `onTextChanged`). `CYLSearchBarModeSingle` reports `-searchBarView:textDidChange:` instead. | `CYLSearchBarViewDelegate.searchBarViewTextDidChange` |
| `CYLSearchBarViewDelegate.-searchBarView:didCompleteSearch:atIndex:` | `CYLSearchBarModeMultiple`: a search was completed and became an entry of `searches` (`onSearchComplete`). | `CYLSearchBarViewDelegate.searchBarViewDidCompleteSearch` |
| `CYLSearchBarViewDelegate.-searchBarView:didRemoveSearchAtIndex:` | `CYLSearchBarModeMultiple`: a search was removed by its remove button or `-removeSearchAtIndex:` (`onSearchItemRemoved`). | `CYLSearchBarViewDelegate.searchBarViewDidRemoveSearchAtIndex` |
| `CYLSearchBarViewDelegate.-searchBarView:didSelectSearch:atIndex:` | `CYLSearchBarModeMultiple`: a search was selected by a tap or `-selectSearchAtIndex:` (`onItemSelected`). | `CYLSearchBarViewDelegate.searchBarViewDidSelectSearch` |
| **class `CYLSearchBarView`** | A configurable search bar: a rounded field with a magnifier, text and clear button, views of the host inside the field after the text (a camera, a "Search" button) or before the field (a back button), and an optional Cancel button. Use i… | `CYLSearchBarView` |
| `CYLSearchBarView.delegate` | Receives the events. | `CYLSearchBarView.delegate` |
| `CYLSearchBarView.textField` | The text field inside the field. | `CYLSearchBarView.textField` |
| `CYLSearchBarView.fieldView` | The rounded field that holds the magnifier, the text and `trailingAccessoryViews`. | TODO: N/A on HarmonyOS: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarView.searchIconView` | The magnifier at the start of the field (decorative: hidden from VoiceOver). | TODO: N/A on HarmonyOS: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarView.cancelButton` | The Cancel button after the field (`showsCancelButton`). | TODO: N/A on HarmonyOS: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarView.placeholderLabel` | Draws the placeholder at the full font size, cut off with an ellipsis when it does not fit. | TODO: N/A on HarmonyOS: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarView.navigationButton` | The button before the field. It is shown when `navigationIcon` is not none or `navigationImage` is set, and `leadingView` is nil; taps call `-searchBarViewNavigationButtonClicked:` and `navigationHandler`. | TODO: N/A on HarmonyOS: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarView.voiceButton` | A microphone inside the field, shown while the text is empty; it calls `-searchBarViewVoiceButtonClicked:`. | TODO: N/A on HarmonyOS: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarView.submitButton` | A submit button inside the field, shown while there is text; it submits the query like the Search key. | TODO: N/A on HarmonyOS: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarView.iconButton` | The button shown while `iconified` is YES. VoiceOver reads it as "Search". | TODO: N/A on HarmonyOS: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarView.text` | The text of the field. | `CYLSearchBarView.text` |
| `CYLSearchBarView.placeholder` | The placeholder, drawn by `placeholderLabel` and kept on the text field for VoiceOver. | `CYLSearchBarView.placeholder` |
| `CYLSearchBarView.font` | The font of the text, the placeholder and Cancel. The body text style by default, following Dynamic Type; a custom font is used as given (pass a `UIFontMetrics` font to scale it). | `CYLSearchBarView.font` |
| `CYLSearchBarView.textColor` | The text color. `labelColor` by default. | `CYLSearchBarView.textColor` |
| `CYLSearchBarView.placeholderColor` | The placeholder color. `UIColor.secondaryLabel` when nil (readable in dark mode). | `CYLSearchBarView.placeholderColor` |
| `CYLSearchBarView.cursorColor` | The color of the text cursor (MaterialSearchView `setCursorDrawable`). The tint color by default. | `CYLSearchBarView.cursorColor` |
| `CYLSearchBarView.fieldHeight` | The height of the field; it grows when the scaled text needs more. 36 by default. | `CYLSearchBarView.fieldHeight` |
| `CYLSearchBarView.contentInsets` | The space around the field. (6, 16, 6, 16) by default: the same 16 pt as the tag list's section insets and section header (CollectionViewClassifyMenu), so a bar placed edge to edge lines up with the suggestions below it. | `CYLSearchBarView.contentInsets` |
| `CYLSearchBarView.textFieldMarginsProvider` | The content insets for the bar's state (`true` while editing); wins over `contentInsets`, the resting value (the same knob as `CYLSearchBar.textFieldMarginsProvider`). The bar's height is measured with `contentInsets`, so it does not jum… | `CYLSearchBarView.textFieldMarginsProvider` |
| `CYLSearchBarView.centersPlaceholder` | Whether the magnifier and the placeholder are centered in the field while the bar is not editing and has no text (the same knob as `CYLSearchBar.centersPlaceholder`). NO by default. | `CYLSearchBarView.centersPlaceholder` |
| `CYLSearchBarView.appearanceStyle` | The style of the field, one `CYLSearchBarAppearance` for this bar and `CYLSearchBar`; nil by default (the bar keeps its own look). Assigning a style maps it onto `font`, `textColor`, `placeholderColor`, `placeholder`, `tintColor`, `searc… | `CYLSearchBarView.appearanceStyle` |
| `CYLSearchBarView.applyDefaultAppearance()` | Applies `CYLSearchBarAppearance.defaultAppearance` (the same method as `CYLSearchBar`). | `CYLSearchBarView.applyDefaultAppearance` |
| `CYLSearchBarView.fieldBackgroundColor` | The field's background. `tertiarySystemFillColor` by default. | `CYLSearchBarView.fieldBackgroundColor` |
| `CYLSearchBarView.fieldCornerRadius` | The field's corner radius; negative makes a capsule. -1 by default. | `CYLSearchBarView.fieldCornerRadius` |
| `CYLSearchBarView.fieldBorderColor` | The field's border color; nil draws no border. | `CYLSearchBarView.fieldBorderColor` |
| `CYLSearchBarView.fieldBorderWidth` | The field's border width, used with `fieldBorderColor`. 0 by default. | `CYLSearchBarView.fieldBorderWidth` |
| `CYLSearchBarView.fieldShadowOpacity` | The field's shadow, 0 to 1. 0 by default. | `CYLSearchBarView.fieldShadowOpacity` |
| `CYLSearchBarView.searchIcon` | The magnifier; nil shows none. `magnifyingglass` by default. | `CYLSearchBarView.searchIcon` |
| `CYLSearchBarView.searchIconTintColor` | The magnifier's tint. `secondaryLabelColor` by default. | `CYLSearchBarView.searchIconTintColor` |
| `CYLSearchBarView.trailingAccessoryViews` | Views of yours inside the field after the text, scaled down when they would squeeze it. | `CYLSearchBarComponent.trailingAccessoryViews` (a `@BuilderParam`) |
| `CYLSearchBarView.showsTrailingAccessoryViews` | Whether `trailingAccessoryViews` are shown, without animation. YES by default; hidden views give their room to the text. | `CYLSearchBarView.showsTrailingAccessoryViews` |
| `CYLSearchBarView.setShowsTrailingAccessoryViews(_:animated:)` | Shows or hides `trailingAccessoryViews`, optionally fading them with the text taking or giving up their room (QMUI `qmui_setShowsRightAccessoryView:animated:`, the same knob as `CYLSearchBar`). Toggling quickly ends in the last requested… | `CYLSearchBarView.setShowsTrailingAccessoryViews` |
| `CYLSearchBarView.items` | The appended items, in order, after the text and after `trailingAccessoryViews` (like the FlatDesign tab bar's `items`). The field stays; only items are appended. | `CYLSearchBarView.items` |
| `CYLSearchBarView.showsSearchButton` | Whether the bar shows its default search button, after the field and the items: YES by default (an editing bar and a bar in `CYLSearchBarModeMultiple` never show it). A tap calls `searchButtonHandler`, else submits the text (`submit()`),… | `CYLSearchBarView.showsSearchButton` |
| `CYLSearchBarView.searchButtonStyle` | Whether the default search button shows an icon in a filled capsule (`.icon`, the default) or a title (`.text`). | `CYLSearchBarView.searchButtonStyle` |
| `CYLSearchBarView.searchButtonTitle` | The title of the default search button (also its accessibility label in the icon style); nil is the localized "Search". | `CYLSearchBarView.searchButtonTitle` |
| `CYLSearchBarView.searchButtonImage` | The icon of the default search button in the `.icon` style; nil is the core's built-in magnifier (SF Symbol `magnifyingglass`). | `CYLSearchBarView.searchButtonImage` |
| `CYLSearchBarView.searchButtonHandler` | Called instead of the default action when the default search button is tapped. | `CYLSearchBarView.searchButtonHandler` |
| `CYLSearchBarView.itemViews` | The views of `items` (`CYLTagButton`s), in the same order. | `CYLSearchBarView.itemViews` |
| `CYLSearchBarView.itemTintColor` | The icon and title color of every item without its own `tintColor`; nil uses the label color. | `CYLSearchBarView.itemTintColor` |
| `CYLSearchBarView.searchBarStyle` | The fixed look of the bar. `.bordered` draws the field and its items inside one capsule outline. | `CYLSearchBarView.searchBarStyle` |
| `CYLSearchBarView.fieldBackgroundImage` | An image drawn behind the field's content, clipped to its corners. | `CYLSearchBarView.fieldBackgroundImage` |
| `CYLSearchBarView.selectedItem` | The first selected item (an item with `selectable` YES that was tapped on), or nil. | `CYLSearchBarView.selectedItem` |
| `CYLSearchBarView.selectedIndex` | The index of `selectedItem`, or `NSNotFound`. | `CYLSearchBarView.selectedIndex` |
| `CYLSearchBarView.addItem(_:)` | Appends an item after the others. | `CYLSearchBarView.addItem` |
| `CYLSearchBarView.insertItem(_:at:)` | Inserts an item at an index (clamped to `items`); an item already in a bar moves here. | `CYLSearchBarView.insertItem` |
| `CYLSearchBarView.addItem(style:title:image:index:handler:)` | Creates an item and inserts it at an index; `NSNotFound` or a larger index appends it. Mirrors `-addItemWithTitle:tabBarItemImage:tabBarItemSelectedImage:index:`. | `CYLSearchBarView.addItem` |
| `CYLSearchBarView.removeItem(_:)` | Removes an item from the bar. | `CYLSearchBarView.removeItem` |
| `CYLSearchBarView.removeAllItems()` | Removes every item. | `CYLSearchBarView.removeAllItems` |
| `CYLSearchBarView.setItems(dictionaries:)` | Replaces the items with the ones the dictionaries describe (`+itemWithDictionary:`), as the cross-platform bridges send them. When only `animationLoops` and `animationSpeed` differ from the last call, the items stay and take the two valu… | `CYLSearchBarView.setItems` |
| `CYLSearchBarView.hasItem(of:)` | YES when an item of the style was appended (a text "Search" button), like `-hasPlusButton`. | `CYLSearchBarView.hasItem` |
| `CYLSearchBarView.leadingView` | A view of yours before the field (a back button); it wins over the navigation button. | `CYLSearchBarComponent.leadingView` (a `@BuilderParam`) |
| `CYLSearchBarView.showsLeadingView` | Whether the view before the field (`leadingView`, or the navigation button) is shown, without animation. YES by default; a hidden view gives its room to the field. | `CYLSearchBarView.showsLeadingView` |
| `CYLSearchBarView.setShowsLeadingView(_:animated:)` | Shows or hides the view before the field, optionally sliding it in from or out to the left edge while the field takes or gives up its room (QMUI `qmui_setShowsLeftAccessoryView:animated:`). Toggling quickly ends in the last requested state. | `CYLSearchBarView.setShowsLeadingView` |
| `CYLSearchBarView.showsCancelButton` | Shows the Cancel button after the field. NO by default. | `CYLSearchBarView.showsCancelButton` |
| `CYLSearchBarView.setShowsCancelButton(_:animated:)` | Shows or hides the Cancel button, optionally sliding and fading it while the field takes or gives up its room (UIKit `setShowsCancelButton:animated:`, the same method as `CYLSearchBar`). Toggling quickly ends in the last requested state. | `CYLSearchBarView.setShowsCancelButton` |
| `CYLSearchBarView.cancelButtonMarginsProvider` | Returns the margins applied to the Cancel button's frame for the bar's state (`true` while editing); a negative left value moves it left and widens it (the same knob as `CYLSearchBar.cancelButtonMarginsProvider`). | `CYLSearchBarView.cancelButtonMarginsProvider` |
| `CYLSearchBarView.cancelButtonFont` | The font of the Cancel button's title; `font` when nil (the same knob as `CYLSearchBar.cancelButtonFont`). | `CYLSearchBarView.cancelButtonFont` |
| `CYLSearchBarView.cancelButtonTitle` | The Cancel title. The localized "Cancel" by default. | `CYLSearchBarView.cancelButtonTitle` |
| `CYLSearchBarView.cancelButtonEndsEditing` | Taps on Cancel also end editing and clear nothing. YES by default. | `CYLSearchBarView.cancelButtonEndsEditing` |
| `CYLSearchBarView.clearsTextOnCancel` | Taps on Cancel also clear the text (lapism `setTextClearOnBackPressed`). NO by default. | `CYLSearchBarView.clearsTextOnCancel` |
| `CYLSearchBarView.isEditingBar` | Whether the bar is an editing bar (`editingBar(placeholder:actionTitle:)`): an edit field in the search bar's look, whose trailing button submits instead of cancelling. | `CYLSearchBarView.isEditingBar` |
| `CYLSearchBarView.editingSubmitHandler` | An editing bar's submit: the trimmed text, when its action button or the return key is tapped (after `-searchBarView:shouldSubmitText:` and `-searchBarViewSearchButtonClicked:`). Empty text submits nothing. | `CYLSearchBarView.editingSubmitHandler` |
| `CYLSearchBarView.editingBar(placeholder:actionTitle:)` | An editing bar: the search bar's field and look for editing a name (a tag, a title), without the magnifier, with `actionTitle` ("Add", "Done") as its trailing button, which submits through `editingSubmitHandler`, as the return key does.… | `CYLSearchBarView.editingBar` |
| `CYLSearchBarView.pinToKeyboard(in:)` | Pins the bar to the top of the keyboard in `view` (its keyboard layout guide, iOS 15): full width within the safe area, at the bottom while the keyboard is down, riding on the keyboard while it is up, docked or not. | `CYLSearchBarView.pinToKeyboard` |
| `CYLSearchBarView.clearsTextOnEndEditing` | Ending editing also clears the text (lapism `setTextClearOnClearFocus`). NO by default. | `CYLSearchBarView.clearsTextOnEndEditing` |
| `CYLSearchBarView.navigationIcon` | A built-in navigation icon. `CYLSearchBarNavigationIconNone` by default. | `CYLSearchBarView.navigationIcon` |
| `CYLSearchBarView.navigationImage` | A custom navigation icon; it wins over `navigationIcon`. | `CYLSearchBarView.navigationImage` |
| `CYLSearchBarView.navigationAccessibilityLabel` | What VoiceOver reads for the navigation button. Defaults to "Back" for the arrow and "Search" for the magnifier. | `CYLSearchBarView.navigationAccessibilityLabel` |
| `CYLSearchBarView.navigationBackgroundColor` | A circle drawn behind the navigation icon. Nil (none) by default. | `CYLSearchBarView.navigationBackgroundColor` |
| `CYLSearchBarView.navigationShadowOpacity` | The shadow of that circle, 0 to 1 (lapism `setNavigationElevation`). 0 by default. | `CYLSearchBarView.navigationShadowOpacity` |
| `CYLSearchBarView.navigationHandler` | Called on taps on the navigation button, after the delegate. | `CYLSearchBarView.navigationHandler` |
| `CYLSearchBarView.showsVoiceButton` | Shows `voiceButton` while the text is empty. NO by default. | `CYLSearchBarView.showsVoiceButton` |
| `CYLSearchBarView.voiceImage` | The voice button's icon. `mic` by default. | `CYLSearchBarView.voiceImage` |
| `CYLSearchBarView.showsSubmitButton` | Shows `submitButton` while there is text (Android `isSubmitButtonEnabled`). NO by default. | `CYLSearchBarView.showsSubmitButton` |
| `CYLSearchBarView.submitImage` | The submit button's icon. `arrow.forward.circle.fill` by default. | `CYLSearchBarView.submitImage` |
| `CYLSearchBarView.clearImage` | A custom clear button icon, shown while editing with text. Nil keeps the system clear button. | `CYLSearchBarView.clearImage` |
| `CYLSearchBarView.keyboardType` | The keyboard type (Android `inputType`). `UIKeyboardTypeDefault` by default. | `CYLSearchBarView.keyboardType` |
| `CYLSearchBarView.returnKeyType` | The return key (Android `imeOptions`). `UIReturnKeySearch` by default. | `CYLSearchBarView.returnKeyType` |
| `CYLSearchBarView.autocapitalizationType` | Automatic capitalization. `UITextAutocapitalizationTypeSentences` by default. | TODO: N/A on HarmonyOS: ArkUI `TextInput` has no capitalization trait |
| `CYLSearchBarView.autocorrectionType` | Automatic correction. `UITextAutocorrectionTypeDefault` by default. | TODO: N/A on HarmonyOS: ArkUI `TextInput` has no autocorrection trait |
| `CYLSearchBarView.isSecureTextEntry` | Hides the typed characters (Android `inputType="textPassword"`). NO by default. | `CYLSearchBarView.isSecureTextEntry` |
| `CYLSearchBarView.maximumTextLength` | The longest text a person can type (Android `maxLength`); 0 means no limit. 0 by default. | `CYLSearchBarView.maximumTextLength` |
| `CYLSearchBarView.isIconified` | Shows only a search button instead of the field (Android `SearchView.isIconified`). Tapping the button opens the field and starts editing. NO by default. | `CYLSearchBarView.isIconified` |
| `CYLSearchBarView.iconifiedByDefault` | When YES, the field closes back to its icon when editing ends with no text (Android `setIconifiedByDefault`). NO by default. | `CYLSearchBarView.iconifiedByDefault` |
| `CYLSearchBarView.expansionAnimation` | How the field opens and closes. `CYLSearchBarExpansionAnimationFade` by default. | `CYLSearchBarView.expansionAnimation` |
| `CYLSearchBarView.iconPosition` | Where `iconButton` sits while iconified; the field opens from there. `CYLSearchBarIconPositionTrailing` by default. | `CYLSearchBarView.iconPosition` |
| `CYLSearchBarView.animationDuration` | The length of the opening and closing animations, in seconds. 0.3 by default. | `CYLSearchBarView.animationDuration` |
| `CYLSearchBarView.mode` | One field (`CYLSearchBarModeSingle`, the default) or several searches side by side (`CYLSearchBarModeMultiple`, iammert `MultiSearchView`). The text style (`placeholder`, `font`, `textColor`, `placeholderColor`, the keyboard options, `ma… | `CYLSearchBarView.mode` |
| `CYLSearchBarView.searches` | `CYLSearchBarModeMultiple`: the texts of the searches, completed searches first, then the one being typed. | `CYLSearchBarView.searches` |
| `CYLSearchBarView.selectedSearchIndex` | `CYLSearchBarModeMultiple`: the index of the selected search in `searches`, or `NSNotFound` when none is selected. | `CYLSearchBarView.selectedSearchIndex` |
| `CYLSearchBarView.isEditingNewSearch` | `CYLSearchBarModeMultiple`: YES while a new search is being typed (MultiSearchView `isInSearchMode`). | `CYLSearchBarView.isEditingNewSearch` |
| `CYLSearchBarView.newSearchButton` | `CYLSearchBarModeMultiple`: the button at the trailing end; it starts a new search, or completes the one being typed. VoiceOver reads it as "New search". | TODO: N/A on HarmonyOS: ArkUI has no view objects; `CYLSearchBarComponent` draws it in `CYLSearchBarModeMultiple` (`newSearchImage`) |
| `CYLSearchBarView.minimumTextLength` | `CYLSearchBarModeMultiple`: a search shorter than this is dropped by `-completeSearch`. 3 by default, as in MultiSearchView. | `CYLSearchBarView.minimumTextLength` |
| `CYLSearchBarView.searchIndicatorColor` | `CYLSearchBarModeMultiple`: the color of the indicator under the selected search and of `newSearchButton`; the tint color when nil. | `CYLSearchBarView.searchIndicatorColor` |
| `CYLSearchBarView.unselectedSearchAlpha` | `CYLSearchBarModeMultiple`: the opacity of the searches that are not selected, 0 to 1. 0.5 by default. | `CYLSearchBarView.unselectedSearchAlpha` |
| `CYLSearchBarView.searchFieldWidth` | `CYLSearchBarModeMultiple`: the width of the field of a new search, in points (at least 44). 160 by default. | `CYLSearchBarView.searchFieldWidth` |
| `CYLSearchBarView.newSearchImage` | `CYLSearchBarModeMultiple`: the icon of `newSearchButton`. `magnifyingglass` by default. | `CYLSearchBarView.newSearchImage` |
| `CYLSearchBarView.removeSearchImage` | `CYLSearchBarModeMultiple`: the icon of the remove button on the selected search. `xmark.circle.fill` by default. | `CYLSearchBarView.removeSearchImage` |
| `CYLSearchBarView.beginNewSearch()` | `CYLSearchBarModeMultiple`: starts a new search and shows the keyboard (MultiSearchView `search`). Does nothing while a search is being typed, or in `CYLSearchBarModeSingle`. | `CYLSearchBarView.beginNewSearch` |
| `CYLSearchBarView.completeSearch()` | `CYLSearchBarModeMultiple`: completes the search being typed (`completeSearch`). It becomes the selected search, or is dropped when shorter than `minimumTextLength`. | `CYLSearchBarView.completeSearch` |
| `CYLSearchBarView.addSearch(_:)` | `CYLSearchBarModeMultiple`: adds a completed search without typing it, and selects it. An empty text is ignored. | `CYLSearchBarView.addSearch` |
| `CYLSearchBarView.selectSearch(at:)` | `CYLSearchBarModeMultiple`: selects a search, like a tap on it. | `CYLSearchBarView.selectSearch` |
| `CYLSearchBarView.removeSearch(at:)` | `CYLSearchBarModeMultiple`: removes a search, like a tap on its remove button. The next search is selected, or the previous one when the last search went away. | `CYLSearchBarView.removeSearch` |
| `CYLSearchBarView.init(frame:)` | — | `new CYLSearchBarView(…)` |
| `CYLSearchBarView.init(coder:)` | Creates the bar from an archive (a storyboard or a XIB). | TODO: N/A on HarmonyOS: no archives in ArkUI (the state is restored with `decodeRestorableState`) |
| `CYLSearchBarView.setText(_:submit:)` | Sets the text and, when `submit` is YES and the text is not empty, submits it as if the Search key were tapped (MaterialSearchView `setQuery`, lapism `setTextQuery`). | `CYLSearchBarView.setText` |
| `CYLSearchBarView.submit()` | Submits the current text: asks `-searchBarView:shouldSubmitText:`, then calls `-searchBarViewSearchButtonClicked:`. Returns NO when the text is empty or the delegate refused it. | `CYLSearchBarView.submit` |
| `CYLSearchBarView.showKeyboard()` | Starts editing and shows the keyboard. | `CYLSearchBarView.showKeyboard` |
| `CYLSearchBarView.pushesOnTap` | Whether a tap on the field does not edit but calls `onFirstLevelTap` (and `performFirstLevelTap()`): the bar of a first-level page (a tab root) shows the whole search look and a tap pushes the second-level search page. NO by default; no… | `CYLSearchBarView.pushesOnTap` |
| `CYLSearchBarView.onFirstLevelTap` | Called when the field of a `pushesOnTap` bar is tapped: push the second-level search page. The second-level page's bar brings its back button in and shrinks alongside the push (`embedInNavigationBar(of:)` does it), so the host only pushes. | `CYLSearchBarView.onFirstLevelTap` |
| `CYLSearchBarView.performFirstLevelTap()` | The tap of a first-level bar, also callable from code: runs `onFirstLevelTap`. | TODO |
| `CYLSearchBarView.isBackButtonShown` | Whether the back button (the navigation arrow before the field) is shown. | `CYLSearchBarView.isBackButtonShown` |
| `CYLSearchBarView.backButtonProgress` | 1 while the bar's own back button (its navigation arrow before the field) is shown, 0 while it is hidden. It is for a host that puts the bar where no navigation controller supplies a back button (a plain view, a sheet); in a navigation b… | `CYLSearchBarView.backButtonProgress` |
| `CYLSearchBarView.focusesOnAppear` | Whether the field takes focus (and the keyboard, with the search key, shows) every time the bar appears on screen, like a `viewDidAppear`: the first time its page is entered, after a push and pop, and after the app returns from the backg… | `CYLSearchBarView.focusesOnAppear` |
| `CYLSearchBarView.pageDepth` | The depth of the page the bar is on, set by a host that has no navigation controller to read: 0 is a first-level page, 1 or more a second-level or deeper one. -1 (the default) reads the navigation stack (`isOnSecondLevelOrDeeperPage`). | `CYLSearchBarView.pageDepth` |
| `CYLSearchBarView.dismissesKeyboardOnOutsideTouch` | Whether a touch anywhere in the window outside this bar (a tap, or the start of a scroll or drag in any container) hides the keyboard while the field is editing: CYLDeallocBlockExecutor's `didTouchOutside`, observed only while editing. Y… | TODO |
| `CYLSearchBarView.hideKeyboard()` | Ends editing and hides the keyboard. | `CYLSearchBarView.hideKeyboard` |
| `CYLSearchBarView.setIconified(_:animated:)` | Opens or closes the field, with `expansionAnimation` when `animated` is YES. Opening also starts editing. | `CYLSearchBarView.setIconified` |
| `CYLSearchBarView.encodeRestorableState(with:)` | Saves the text, whether it is editing and whether it is iconified (`onSaveInstanceState`). | `CYLSearchBarView.encodeRestorableState` |
| `CYLSearchBarView.decodeRestorableState(with:)` | Restores the text, the iconified state and editing (`onRestoreInstanceState`). | `CYLSearchBarView.decodeRestorableState` |
| `CYLSearchBarView.traitCollectionDidChange(_:)` | — | TODO: N/A on HarmonyOS: system colors (`sys.color.*`) follow the color mode by themselves |
| `CYLSearchBarView.tintColorDidChange()` | — | TODO: N/A on HarmonyOS: system colors follow the theme by themselves (`searchIndicatorColor` overrides) |
| `CYLSearchBarView.intrinsicContentSize` | — | `CYLSearchBarView.intrinsicContentSize` |
| `CYLSearchBarView.sizeThatFits(_:)` | — | TODO: N/A on HarmonyOS: ArkUI measures a component from its declaration (`intrinsicContentSize` gives the height) |
| `CYLSearchBarView.layoutSubviews()` | — | TODO: N/A on HarmonyOS: ArkUI lays a component out from its declaration |
| `CYLSearchBarView.textFieldShouldBeginEditing(_:)` | Asks the delegate whether editing may start; a refusal reports a tap instead. | TODO: N/A on HarmonyOS: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchBarView.textFieldShouldReturn(_:)` | The return key submits the text. | TODO: N/A on HarmonyOS: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchBarView.textField(_:shouldChangeCharactersIn:replacementString:)` | Enforces `maximumTextLength`; deleting is always allowed. | TODO: N/A on HarmonyOS: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchBarView.textFieldDidBeginEditing(_:)` | Reports the start of editing. | TODO: N/A on HarmonyOS: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchBarView.textFieldDidEndEditing(_:)` | Clears the text and closes to the icon when configured, then reports the end of editing. | TODO: N/A on HarmonyOS: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchBarView.becomeFirstResponder()` | Starts editing in the text field. | `CYLSearchBarView.becomeFirstResponder` |
| `CYLSearchBarView.resignFirstResponder()` | Ends editing; the bar itself also gives up first responder as UIKit expects. | `CYLSearchBarView.resignFirstResponder` |
| **class `CYLSearchBarItem`** | One element after the text of a `CYLSearchBarView`: a model independent of its view, like `CYLFlatDesignTabBarItem`. Append it with `-[CYLSearchBarView addItem:]`; its view is `itemView`. | `CYLSearchBarItem` |
| `CYLSearchBarItem.style` | How the item looks (icon, divider or text); set when the item is created. | `CYLSearchBarItem.style` |
| `CYLSearchBarItem.title` | The text of a text item, and the VoiceOver label of an icon item without `accessibilityLabel`. | `CYLSearchBarItem.title` |
| `CYLSearchBarItem.image` | The icon (a template image is tinted with `tintColor`). | `CYLSearchBarItem.image` |
| `CYLSearchBarItem.selectedImage` | The icon while `selected` is YES; nil uses `image`. | `CYLSearchBarItem.selectedImage` |
| `CYLSearchBarItem.animatedImage` | An animated icon (`+[UIImage animatedImageWithImages:duration:]`), drawn instead of `image` when set. | `CYLSearchBarItem.animatedImage` |
| `CYLSearchBarItem.animationURL` | An animated icon file (Lottie .json, .pag, .riv, .svga, .gif), drawn by the item's `CYLTagButton` (a `CYLAnimatedItemView`) when the app adds the engine of its type (`CYLAnimatedItem/<Type>`; the core adds none) and played on each tap. O… | `CYLSearchBarItem.animationURL` |
| `CYLSearchBarItem.animationLoops` | Whether `animationURL` plays again after each pass; NO plays once on each tap. The same on every platform. | `CYLSearchBarItem.animationLoops` |
| `CYLSearchBarItem.animationSpeed` | The playback speed of `animationURL`; 1 is the file's own. An engine without speed ignores it. The same on every platform. | `CYLSearchBarItem.animationSpeed` |
| `CYLSearchBarItem.restartAnimation()` | Plays `animationURL` again from the start, as a tap does. Does nothing without an animation. The same on every platform. | `CYLSearchBarItem.restartAnimation` |
| `CYLSearchBarItem.imageSize` | The icon size; zero uses 20 x 20 pt. | `CYLSearchBarItem.imageSize` |
| `CYLSearchBarItem.itemAccessibilityLabel` | What VoiceOver reads; nil reads `title`. | `CYLSearchBarItem.itemAccessibilityLabel` |
| `CYLSearchBarItem.itemAccessibilityIdentifier` | A test identifier for the item view. | `CYLSearchBarItem.itemAccessibilityIdentifier` |
| `CYLSearchBarItem.isEnabled` | NO dims the item and ignores taps. YES by default. | `CYLSearchBarItem.isEnabled` |
| `CYLSearchBarItem.isSelectable` | YES makes each tap toggle `selected` (a filter that stays on). NO by default. | `CYLSearchBarItem.isSelectable` |
| `CYLSearchBarItem.isSelected` | The selected state (drawn with `selectedImage`, `selectedBackgroundColor` and the selected title attributes). | `CYLSearchBarItem.isSelected` |
| `CYLSearchBarItem.tintColor` | The icon and title color; nil uses the bar's `itemTintColor`. | `CYLSearchBarItem.tintColor` |
| `CYLSearchBarItem.backgroundColor` | The item background; nil is clear. | `CYLSearchBarItem.backgroundColor` |
| `CYLSearchBarItem.selectedBackgroundColor` | The item background while selected; nil uses `backgroundColor`. | `CYLSearchBarItem.selectedBackgroundColor` |
| `CYLSearchBarItem.contentInsets` | Space around the icon and title inside the item; `UIEdgeInsetsZero` uses the style's default. | `CYLSearchBarItem.contentInsets` |
| `CYLSearchBarItem.automaticCornerRadius` | `cornerRadius` that follows the item: 10 pt with a background, square without one. | TODO |
| `CYLSearchBarItem.cornerRadius` | The corner radius of the item's background and border, in points: 0 is square, `CYLAnimatedItemCornerRadiusCapsule` a capsule, `automaticCornerRadius` (the default) 10 pt with a background and square without one. The icon, the background… | `CYLSearchBarItem.cornerRadius` |
| `CYLSearchBarItem.borderColor` | The border color of the item's own outline; nil (the default) draws none. | `CYLSearchBarItem.borderColor` |
| `CYLSearchBarItem.borderWidth` | The width of the item's own outline, in points; 0 by default. | `CYLSearchBarItem.borderWidth` |
| `CYLSearchBarItem.itemHeight` | The height of the item in points; 0 (the default) is the 36 pt touch size. | `CYLSearchBarItem.itemHeight` |
| `CYLSearchBarItem.imagePositionAdjustment` | Moves the icon without changing the item's size. | `CYLSearchBarItem.imagePositionAdjustment` |
| `CYLSearchBarItem.titlePositionAdjustment` | Moves the title without changing the item's size. | `CYLSearchBarItem.titlePositionAdjustment` |
| `CYLSearchBarItem.badgeValue` | The badge text; nil hides the badge, an empty string draws a dot. | `CYLSearchBarItem.badgeValue` |
| `CYLSearchBarItem.badgeColor` | The badge background; nil is system red. | `CYLSearchBarItem.badgeColor` |
| `CYLSearchBarItem.badgeSize` | The smallest badge size; zero uses 16 x 16 pt (a dot is 8 x 8 pt). | `CYLSearchBarItem.badgeSize` |
| `CYLSearchBarItem.badgeContentInsets` | Space around the badge text. | `CYLSearchBarItem.badgeContentInsets` |
| `CYLSearchBarItem.badgePositionAdjustment` | Moves the badge from the icon's top trailing corner. | `CYLSearchBarItem.badgePositionAdjustment` |
| `CYLSearchBarItem.handler` | Called on each tap, after `-searchBarView:didSelectItem:`. | `CYLSearchBarItem.handler` |
| `CYLSearchBarItem.index` | The item's position in its bar's `items`; `NSNotFound` when it is in no bar. | `CYLSearchBarItem.index` |
| `CYLSearchBarItem.itemView` | The item's view, a `CYLTagButton` (CollectionViewClassifyMenu) created on first use. The bar adds it inside its field and sends its taps to `-searchBarView:didSelectItem:` and `handler`. | `CYLSearchBarItem.itemView` |
| `CYLSearchBarItem.init(style:title:image:)` | An item of the given style with a title and an icon. | `new CYLSearchBarItem(…)` |
| `CYLSearchBarItem.init(title:image:)` | An icon item, or a text item when the title is set and the image is nil. | `new CYLSearchBarItem(…)` |
| `CYLSearchBarItem.init(title:image:selectedImage:)` | Like `-initWithTitle:image:`, with an icon for the selected state. | `new CYLSearchBarItem(…)` |
| `CYLSearchBarItem.iconItem(image:title:handler:)` | An icon item: the title is what VoiceOver reads. | `CYLSearchBarItem.iconItem` |
| `CYLSearchBarItem.textItem(title:handler:)` | A text item (a "Search" button). | `CYLSearchBarItem.textItem` |
| `CYLSearchBarItem.divider()` | A divider between two items. | `CYLSearchBarItem.divider` |
| `CYLSearchBarItem.item(dictionary:)` | An item from plain values, for the cross-platform wrappers (Flutter, React Native): `style` (`icon`, `divider`, `text`), `title`, `image` (`camera`, `mic`, `search`, `back`, else an asset or SF Symbol name), `accessibilityIdentifier`, `i… | `CYLSearchBarItem.item` |
| `CYLSearchBarItem.setTitleTextAttributes(_:for:)` | The title attributes for a state (`UIControlStateNormal`, `UIControlStateSelected`, `UIControlStateDisabled`). | `CYLSearchBarItem.setTitleTextAttributes` |
| `CYLSearchBarItem.titleTextAttributes(for:)` | The title attributes set for a state, or nil. | `CYLSearchBarItem.titleTextAttributes` |
| `CYLSearchBarItem.setBadgeTextAttributes(_:for:)` | The badge text attributes for a state. | `CYLSearchBarItem.setBadgeTextAttributes` |
| `CYLSearchBarItem.badgeTextAttributes(for:)` | The badge text attributes set for a state, or nil. | `CYLSearchBarItem.badgeTextAttributes` |
| `CYLSearchBarItem.actualBadgeSuperView()` | The view the badge is drawn in (the item view). | TODO: N/A on HarmonyOS: ArkUI has no view objects; the badge is drawn by the item's `CYLTagButton` (`itemView`) |
| **protocol `CYLSearchControllerDelegate`** | What a `CYLSearchController` asks of its owner (QMUI `QMthe system search controllerDelegate`): the search results (called on every text change) and the data source and delegate of the results table view, plus optional life cycle callbacks. | `CYLSearchControllerDelegate` |
| `CYLSearchControllerDelegate.-searchController:updateResultsForSearchString:` | Called when the text of the search bar changes, also with "" (the first activation, all text deleted, the clear button), as UIKit does. Reload `searchController.tableView` here. | `CYLSearchControllerDelegate.searchControllerUpdateResultsForSearchString` |
| `CYLSearchControllerDelegate.-searchController:didLoadSearchResultsTableView:` | Called once when the results table view is created, to register cells or change its style. | `CYLSearchControllerDelegate.searchControllerDidLoadSearchResultsTableView` |
| `CYLSearchControllerDelegate.-searchController:willShowEmptyView:` | Called before the empty view is shown, to change its look. | `CYLSearchControllerDelegate.searchControllerWillShowEmptyView` |
| **class `CYLSearchController`** | A search over `contentsViewController`: the core's search field `searchBar` (`CYLSearchBarView`), and, while the search is active, a page below the field with the launch view (recent searches or suggestions) while the text is empty, the… | `CYLSearchController` |
| `CYLSearchController.searchResultsDelegate` | The owner of the results: its data source and delegate drive the results table view, and it is told about the text and the life cycle. Held weakly. | `CYLSearchController.searchResultsDelegate` |
| `CYLSearchController.searchResultsController` | The view controller that shows the results: a table view controller unless the controller was created with `init(contentsViewController:resultsViewController:)`. | `CYLSearchController.searchResultsController` |
| `CYLSearchController.searchBar` | The search field, the core's `CYLSearchBarView`; use it as a table header or in a navigation item. | `CYLSearchController.searchBar` |
| `CYLSearchController.tableView` | The results table view; `nil` unless the results controller is a `UITableViewController`. | `CYLSearchController.tableView` |
| `CYLSearchController.highlightsResultMatches` | Gives the first match of the search text in each row of the results table `resultMatchHighlightColor` (the tint color by default), after `searchResultsDelegate` configured the row. While it is on, the table's `dataSource` is a forwarding… | `CYLSearchController.highlightsResultMatches` |
| `CYLSearchController.resultMatchHighlightColor` | The color of the highlighted match; nil uses the tint color. | `CYLSearchController.resultMatchHighlightColor` |
| `CYLSearchController.launchView` | A view shown over the contents below the field while the search is active and the text is empty (QMUI `launchView`); nil shows none. | `CYLSearchController.launchView` |
| `CYLSearchController.showsSuggestionsLaunchView` | Whether `launchView` is the built-in one (the recent searches of `historyStore`, else `suggestions`, as tags). | `CYLSearchController.showsSuggestionsLaunchView` |
| `CYLSearchController.suggestions` | The suggestions of the built-in launch view. | `CYLSearchController.suggestions` |
| `CYLSearchController.dimmingColor` | The color of a dimming view over the contents while the search is active and the text is empty (no launch view); a tap on it leaves the search. nil shows none. | `CYLSearchController.dimmingColor` |
| `CYLSearchController.isActive` | Whether the search is active; setting it does not animate. | `CYLSearchController.isActive` |
| `CYLSearchController.alwaysShowsSearchResultsController` | Shows the results view controller even while the text is empty (QMUI `qmui_alwaysShowsSearchResultsController`); the launch view is dropped. | `CYLSearchController.alwaysShowsSearchResultsController` |
| `CYLSearchController.supportsSwipeToDismissSearch` | Whether a swipe from the left screen edge leaves the search while it is active. NO by default. | `CYLSearchController.supportsSwipeToDismissSearch` |
| `CYLSearchController.swipeGestureRecognizer` | The recognizer of the swipe; nil until the search was first active with `supportsSwipeToDismissSearch`. | TODO: N/A on HarmonyOS: ArkUI declares the gesture in `CYLSearchComponent` (a `PanGesture`, enabled by `supportsSwipeToDismissSearch`), there is no recognizer object |
| `CYLSearchController.searchBarMaxY` | The bottom edge of the search field in the coordinates of its window; 0 while it is not in a window. | `CYLSearchController.searchBarMaxY` |
| `CYLSearchController.isEmptyViewShowing` | Whether an empty view is showing. | `CYLSearchController.isEmptyViewShowing` |
| `CYLSearchController.noResultsText` | The text of the empty view `CYLSearchController` shows by itself when the text is not empty and the results table has no row; nil shows none. | `CYLSearchController.noResultsText` |
| `CYLSearchController.historyStore` | The history of submitted queries the built-in launch view shows; a return key or a tapped tag submits. | `CYLSearchController.historyStore` |
| `CYLSearchController.historyDidChangeNotification` | Posted when a submitted query is added to `historyStore`; `userInfo["query"]` is the query. | `CYLSearchController.observeHistoryDidChange` |
| `CYLSearchController.init(contentsViewController:resultsViewController:)` | Creates a search controller for `contentsViewController` that shows its results in `resultsViewController` (QMUI `initWithContentsViewController:resultsViewController:`). | `new CYLSearchController(…)` |
| `CYLSearchController.init(contentsViewController:resultsTableViewStyle:)` | Creates a search controller whose results are a table view of `resultsTableViewStyle` (QMUI `initWithContentsViewController:resultsTableViewStyle:`). | `new CYLSearchController(…)` |
| `CYLSearchController.init(contentsViewController:)` | Creates a search controller with a plain results table view (QMUI `initWithContentsViewController:`). | `new CYLSearchController(…)` |
| `CYLSearchController.init(coder:)` | Not available: create the controller with its contents view controller. | TODO: N/A on HarmonyOS: no archives in ArkUI (the state is restored with `decodeRestorableState`) |
| `CYLSearchController.setActive(_:animated:)` | Enters or leaves the search (QMUI `setActive:animated:`). | `CYLSearchController.setActive` |
| `CYLSearchController.searchOpen` | Whether the search is active (`CYLSearchView.searchOpen`); the same as `isActive`. | `CYLSearchController.isSearchOpen` |
| `CYLSearchController.showSearch(animated:)` | Starts the search with animation (`CYLSearchView.showSearch(animated:)`); `setActive(true, animated:)`. | `CYLSearchController.showSearch` |
| `CYLSearchController.closeSearch(animated:)` | Leaves the search (`CYLSearchView.closeSearch(animated:)`); `setActive(false, animated:)`. | `CYLSearchController.closeSearch` |
| `CYLSearchController.installSearchBar(asHeaderOf:)` | Shows the search field as the table view's header (QMUI `qmui_usedAsTableHeaderView`) and keeps this controller alive as long as the table view lives. It also sets the table's estimated row, header and footer heights to 0, adds the botto… | `CYLSearchController.installSearchBar` |
| `CYLSearchController.install(in:)` | Puts the search field into `navigationItem` as its title view (`embedInNavigationBar(of:)` of the core), and keeps this controller alive with the contents view controller (a caller who drops its own reference does not crash on the first… | `CYLSearchController.installInView` |
| `CYLSearchController.snapsHeaderSearchBar` | Whether a header search field settles fully shown or fully hidden when a drag ends. YES by default. | `CYLSearchController.snapsHeaderSearchBar` |
| `CYLSearchController.showEmptyView(scenario:)` | Shows one of CYLTableViewPlaceHolder's scenarios over the results; nothing happens while the text is empty. | `CYLSearchController.showEmptyViewScenario` |
| `CYLSearchController.hideEmptyView()` | Removes the empty view. | `CYLSearchController.hideEmptyView` |
| `CYLSearchController.searchBarViewDidBeginEditing(_:)` | The field began editing: the search becomes active. | TODO: N/A on HarmonyOS: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchController.searchBarView(_:textDidChange:)` | The text changed: the results update. | TODO: N/A on HarmonyOS: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchController.searchBarViewCancelButtonClicked(_:)` | Cancel was tapped: the search ends. | TODO: N/A on HarmonyOS: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchController.gestureRecognizerShouldBegin(_:)` | The swipe begins only while the search is active. | `CYLSearchController.gestureRecognizerShouldBegin` |
| **class `CYLSearchNavigationBar`** | A navigation bar the core creates for a view controller that has none, holding the search bar as its title view, attached to the top edge so its background reaches under the status bar. | `CYLSearchNavigationBar` |
| `CYLSearchNavigationBar.standardHeight` | The height of a navigation bar below the status bar, 44 pt. | `CYLSearchNavigationBar.standardHeight` |
| `CYLSearchNavigationBar.init(frame:)` | — | `new CYLSearchNavigationBar(…)` |
| `CYLSearchNavigationBar.backHandler` | Called when the back button is tapped (a bar made with `showsBackButton`); the bar itself never pops, the host decides (a Flutter route pops, a React Native screen closes). | `CYLSearchNavigationBar.backHandler` |
| `CYLSearchNavigationBar.holding(_:)` | A navigation bar holding `searchBar` as its title view, with the bar set up for it (36 pt field, no side inset of its own, `isEmbeddedInNavigationBar`). The bridges use it as the content of their native view. | `CYLSearchNavigationBar.holding` |
| `CYLSearchNavigationBar.holding(_:showsBackButton:)` | As `holding(_:)`, and with `showsBackButton` the bar has the back button of a second-level page on its leading side (a root item titled "Back" below the item of the search bar); the search bar takes the width that is left. A tap on it ca… | `CYLSearchNavigationBar.holding` |
| `CYLSearchNavigationBar.navigationBar(_:shouldPop:)` | The back button was tapped: the host's `backHandler` runs, the bar keeps its items. | `CYLSearchNavigationBar.navigationBar` |
| `CYLSearchNavigationBar.position(for:)` | Attached to the top edge: the background extends under the status bar. | `CYLSearchNavigationBar.position` |
| `CYLSearchNavigationBar.embedInNavigationBar(of:)` | Puts this bar into the navigation bar of `viewController` and returns that navigation bar; a navigation bar always exists afterwards. With a `navigationController` the bar becomes the `navigationItem`'s title view and the controller's ow… | `CYLSearchNavigationBar.embedInNavigationBar` |
| `CYLSearchNavigationBar.applyNavigationFieldStyle()` | The look of the input box of a navigation bar, the one every screen uses: a bordered capsule (`.bordered`, corner radius 18) with a soft shadow, an opaque white (light) or black (dark) fill, no magnifier, 16 pt text that scales with Dyna… | TODO |
| **enum `CYLSearchBarPreset`** | The looks of a search bar the core ships, one per tab of the example (`CYLSearchBarView.applyPreset(_:)`); the same names on every platform. | `CYLSearchBarPreset` |
| `CYLSearchBarPreset.navigationField` | The navigation field, the Discover look (bordered capsule radius 18, soft shadow, no magnifier, opaque fill). | `CYLSearchBarPreset.navigationField` |
| `CYLSearchBarPreset.pill` | A borderless full capsule with a magnifier. | `CYLSearchBarPreset.pill` |
| `CYLSearchBarPreset.rounded` | A borderless rounded rectangle (radius 10) with a magnifier. | `CYLSearchBarPreset.rounded` |
| `CYLSearchBarPreset.outlined` | A bordered rounded rectangle (radius 8) with a magnifier. | `CYLSearchBarPreset.outlined` |
| `CYLSearchBarPreset.centeredCapsule` | A bordered full capsule with a magnifier, a soft shadow and a centered placeholder. | `CYLSearchBarPreset.centeredCapsule` |
| **class `CYLSearchResources`** | Images and localized strings of `CYLSearchViewController.bundle`, the resource bundle of this pod. | `CYLSearchResources` |
| `CYLSearchResources.resourceBundle` | The resource bundle, found next to this class's framework or in the main bundle; nil when it is missing. | `CYLSearchResources.resourceBundle` |
| `CYLSearchResources.historyDidChangeNotification` | Posted after a built-in history store changed (a query was added or removed, or the history cleared), whoever changed it: the object is the store, and `userInfo` holds `"policy"` (the raw value of `CYLSearchSuggestionCachePolicy`) and `"… | `CYLSearchResources.historyDidChangeNotification` |
| `CYLSearchResources.suggestionCache(policy:name:)` | The built-in store of submitted queries (database, `NSUserDefaults` or file, newest first, no duplicates) that `CYLSearchView` uses, for other search screens such as `CYLSearchController.historyStore`; nil for the policy none. | `CYLSearchResources.suggestionCache` |
| `CYLSearchResources.image(named:)` | An image of the resource bundle, or nil (logged) when it is missing. | `CYLSearchResources.imageNamed` |
| `CYLSearchResources.localizedString(forKey:)` | The text of `key` in the language the app shows (the preferred languages), English when the key has no translation, or the key itself (logged) when it is missing everywhere. | `CYLSearchResources.localizedString` |
| `CYLSearchResources.localizedString(forKey:language:)` | The text of `key` in `language` (for example "zh-Hans"), or in the preferred languages when `language` is nil. | `CYLSearchResources.localizedString` |
| **class `CYLSearchTableViewController`** | A table view controller that can show a `CYLSearchBarView` as its table header, with the `CYLSearchController` that drives it (QMUI's `QMUICommonTableViewController (Search)`). Set `showsSearchBar`; configure the bar in `setUpSearchBar()… | `CYLSearchTableViewController` |
| `CYLSearchTableViewController.showsSearchBar` | Whether the search bar is shown as the table header (QMUI `shouldShowSearchBar`, default `false`). The controller and the bar are created, or removed, once the view is loaded: a value set before `viewDidLoad` takes effect in `viewDidLoad… | `CYLSearchTableViewController.showsSearchBar` |
| `CYLSearchTableViewController.searchController` | The search controller, `nil` while `showsSearchBar` is off or the view is not loaded (QMUI `searchController`). | `CYLSearchTableViewController.searchController` |
| `CYLSearchTableViewController.searchBar` | The search bar that is the table header, `nil` while `showsSearchBar` is off or the view is not loaded (QMUI `searchBar`). | `CYLSearchTableViewController.searchBar` |
| `CYLSearchTableViewController.hidesSearchBarWhenEmptyViewShowing` | Whether the search bar leaves the table header while an empty view shows and returns when it is hidden (QMUI `shouldHideSearchBarWhenEmptyViewShowing`, default `false`). | `CYLSearchTableViewController.hidesSearchBarWhenEmptyViewShowing` |
| `CYLSearchTableViewController.hidesSearchBarInitially` | Whether the table is scrolled so that the search bar is out of sight when it is first shown (QMUI `shouldHideTableHeaderViewInitial`, default `false`), and again each time the bar returns after an empty view. | `CYLSearchTableViewController.hidesSearchBarInitially` |
| `CYLSearchTableViewController.isEmptyViewShowing` | Whether the empty view is on screen. | `CYLSearchTableViewController.isEmptyViewShowing` |
| `CYLSearchTableViewController.setUpSearchBar()` | Called once after the search controller and the bar are created and before the bar becomes the table header: set the bar's style, margins and accessory views here (QMUI `initSearchController`, which subclasses extend). | `CYLSearchTableViewController.setUpSearchBar` |
| `CYLSearchTableViewController.searchController(_:updateResultsFor:)` | Called with every text change of the search, also with "" (QMUI `searchController:updateResultsForSearchString:`); does nothing by default. | `CYLSearchTableViewController.searchControllerUpdateResultsForSearchString` |
| `CYLSearchTableViewController.showEmptyView(text:detailText:)` | Shows CYLTableViewPlaceHolder's placeholder with a title and an optional detail over the table (QMUI `showEmptyViewWithText:detailText:buttonTitle:buttonAction:`, without the button). With `hidesSearchBarWhenEmptyViewShowing` the search… | `CYLSearchTableViewController.showEmptyView` |
| `CYLSearchTableViewController.showEmptyView(scenario:)` | Shows one of CYLTableViewPlaceHolder's scenarios over the table (the placeholder `CYLSearchView` shows for empty results). | `CYLSearchTableViewController.showEmptyViewScenario` |
| `CYLSearchTableViewController.hideEmptyView()` | Removes the empty view; with `hidesSearchBarWhenEmptyViewShowing` the search bar returns to the header, hidden again if `hidesSearchBarInitially` is on (issue #128). | `CYLSearchTableViewController.hideEmptyView` |
| **class `CYLSearchTagListHeader`** | The refresh icon and text of a tag list's section header, one place for every bridge. | `CYLSearchTagListHeader` |
| `CYLSearchTagListHeader.refreshImage` | The refresh icon, the SF Symbol "arrow.clockwise": the icon is the default, not a text button. | `CYLSearchTagListHeader.refreshImage` |
| `CYLSearchTagListHeader.refreshAccessibilityLabel` | The VoiceOver label of the refresh icon, in the language the app shows ("Refresh", 更新, 刷新, 重新整理). | `CYLSearchTagListHeader.refreshAccessibilityLabel` |
| `CYLSearchTagListHeader.applyRefreshIcon(to:)` | Sets the refresh icon as the icon of `list`'s header More button (`menuShowsMoreButton(inSection:)`), in place of the three dots. | TODO: N/A on HarmonyOS: the page draws a tag list header (title and `CYLSearchRefreshButton`), so there is no More button to change; use `CYLSearchTagListHeader.refreshImage` |
| **class `CYLSearchTagListStyle`** | The search bar core's default style of a tag list, the look of the iOS example's recent searches. | `CYLSearchTagListStyle` |
| `CYLSearchTagListStyle.tagCornerRadius` | The corner radius of every tag, in points. The default `CYLAnimatedItemCornerRadiusCapsule` (CYLAnimatedItem's one named constant, 1000; pass it, never the literal) is a capsule, as in the iOS example's recent searches; 0 is square corne… | `CYLSearchTagListStyle.tagCornerRadius` |
| `CYLSearchTagListStyle.tagBackgroundStyle` | The background of every tag, handed to CollectionViewClassifyMenu's `CYLMenuStyle.backgroundStyle`: `.flat` by default (the tag's own colors), `.liquidGlass` for the glass material (flat below iOS 26). | `CYLSearchTagListStyle.tagBackgroundStyle` |
| `CYLSearchTagListStyle.styleCustomizer` | Called with the style after the defaults are set, to change any value of it. nil by default. | `CYLSearchTagListStyle.styleCustomizer` |
| `CYLSearchTagListStyle.applyDefaults(to:)` | Sets the defaults on `style`: white tags with a 1 pt separator border and `tagCornerRadius`, 17 pt text, 36 pt high, 12 pt apart, a 16 pt section inset, a bold 20 pt section header and a clear list background (the page's color shows thro… | `CYLSearchTagListStyle.applyDefaults` |
| `CYLSearchTagListStyle.applyDefaultStyle(to:)` | Sets the defaults on `list`'s style (a copy, so the list's other values stay), and the refresh icon of its header (`CYLSearchTagListHeader`). | `CYLSearchTagListStyle.applyDefaultStyle` |
| `CYLSearchTagListStyle.applyGrid(columns:to:)` | Turns `list` into a grid of `columns` plain titles per row (CollectionViewClassifyMenu's `gridStyle(itemsPerRow:)`, 17 pt medium text, 36 pt rows 16 pt apart, a tag's own image at its own size), the look of the iOS example's discover top… | `CYLSearchTagListStyle.applyGrid` |
| `CYLSearchTagListStyle.applyBackgroundStyle(named:to:)` | Sets the background of every tag of `list` by name, the one parameter of a Liquid Glass list: "liquidGlass" (case-insensitive) is the glass material (flat below iOS 26), anything else, "" or "flat" is flat. The list's other style values… | `CYLSearchTagListStyle.applyBackgroundStyle` |
| **enum `CYLSearchSuggestionStyle`** | How the suggestions are shown under the search bar (`CYLSearchView.suggestionStyle`). | `CYLSearchSuggestionStyle` |
| `CYLSearchSuggestionStyle.list` | One suggestion per row with its icon, in `suggestionsTableView`. | `CYLSearchSuggestionStyle.list` |
| `CYLSearchSuggestionStyle.tags` | Tags that wrap like words, in `suggestionsTagView` (CollectionViewClassifyMenu's `CYLTagListView`). | `CYLSearchSuggestionStyle.tags` |
| **protocol `CYLSearchViewDelegate`** | Events of a `CYLSearchView`: opening and closing, the query, focus, suggestions and the voice button. | `CYLSearchViewDelegate` |
| `CYLSearchViewDelegate.-searchViewWillShow:` | The search view is about to open, before the animation starts (`CYLSearchControllerDelegate`'s `willPresentSearchController:`). | `CYLSearchViewDelegate.searchViewWillShow` |
| `CYLSearchViewDelegate.-searchViewWillClose:` | The search view is about to close, before the animation starts (`CYLSearchControllerDelegate`'s `willDismissSearchController:`). | `CYLSearchViewDelegate.searchViewWillClose` |
| `CYLSearchViewDelegate.-searchViewDidShow:` | The search view finished opening (MaterialSearchView `onSearchViewShown`). | `CYLSearchViewDelegate.searchViewDidShow` |
| `CYLSearchViewDelegate.-searchViewDidClose:` | The search view finished closing (MaterialSearchView `onSearchViewClosed`). | `CYLSearchViewDelegate.searchViewDidClose` |
| `CYLSearchViewDelegate.-searchView:textDidChange:` | The query changed (`onQueryTextChange`). | `CYLSearchViewDelegate.searchViewTextDidChange` |
| `CYLSearchViewDelegate.-searchView:didSubmitText:` | The query was submitted (`onQueryTextSubmit`). Return YES when you handled it and the search view stays open; return NO (or leave this method out) to let the search view close. | `CYLSearchViewDelegate.searchViewDidSubmitText` |
| `CYLSearchViewDelegate.-searchView:didChangeFocus:` | The field started or stopped editing (lapism `OnFocusChangeListener`). | `CYLSearchViewDelegate.searchViewDidChangeFocus` |
| `CYLSearchViewDelegate.-searchView:didSelectSuggestion:atIndex:` | A suggestion was tapped (MaterialSearchView `setOnItemClickListener`). The field shows it first, and it is submitted when `submitsOnSuggestionSelection` is YES. | `CYLSearchViewDelegate.searchViewDidSelectSuggestion` |
| `CYLSearchViewDelegate.-searchViewVoiceButtonClicked:` | The voice button was tapped. Start speech recognition and pass the result to `-setQuery:submit:`. | `CYLSearchViewDelegate.searchViewVoiceButtonClicked` |
| `CYLSearchViewDelegate.-searchViewNavigationButtonClicked:` | The navigation button (the back arrow by default) was tapped. Without this method it closes the search view. | `CYLSearchViewDelegate.searchViewNavigationButtonClicked` |
| `CYLSearchViewDelegate.-searchView:didSelectResult:` | A row of `resultsTableView` was tapped (was `-searchResultsViewController:didSelectResult:`). | `CYLSearchViewDelegate.searchViewDidSelectResult` |
| **protocol `CYLSearchViewDataSource`** | Supplies the results of a `CYLSearchView` and configures their cells (was `CYLSearchResultsDataSource`). While it is set and the query is not empty, `resultsTableView` lists the results under the search bar instead of the suggestions. | `CYLSearchViewDataSource` |
| `CYLSearchViewDataSource.-searchView:resultsForQuery:` | The results for `query` (never empty: an empty query shows the suggestions instead). | `CYLSearchViewDataSource.searchViewResultsForQuery` |
| `CYLSearchViewDataSource.-searchView:configureResultCell:withResult:` | Shows `result` in `cell`, a row of `resultsTableView`. | `CYLSearchViewDataSource.searchViewConfigureResultCell` |
| **class `CYLSearchView`** | A search page that opens over its host view: a `CYLSearchBarView` at the top of the safe area, a divider, a list of suggestions filtered as you type, the results of `resultsDataSource`, and an optional content view of yours below (Miguel… | `CYLSearchView` |
| `CYLSearchView.delegate` | Receives the events of the search view. | `CYLSearchView.delegate` |
| `CYLSearchView.searchBarView` | The search bar at the top. Style it directly (placeholder, colors, icons, keyboard, voice button). | `CYLSearchView.searchBarView` |
| `CYLSearchView.dividerView` | The line under the search bar. | TODO: N/A on HarmonyOS: ArkUI has no view objects; `CYLSearchComponent` draws the divider (`dividerColor`) |
| `CYLSearchView.suggestionsTableView` | The table that lists the suggestions. | TODO: N/A on HarmonyOS: ArkUI has no view objects; `CYLSearchComponent` draws the list (`suggestionCellConfiguration`) |
| `CYLSearchView.suggestionsTagView` | The tags that show the suggestions when `suggestionStyle` is `CYLSearchSuggestionStyleTags` (CollectionViewClassifyMenu's `CYLTagListView`). Style it directly: `style`, spacing, rows, colors. | TODO: N/A on HarmonyOS: ArkUI has no view objects; `CYLSearchComponent` draws the tags (`suggestionsFoldControl`) |
| `CYLSearchView.suggestionsFoldControl` | The fold control of the tag suggestions (CollectionViewClassifyMenu's `CYLMenuFoldControl`). An inline chevron as the last tag by default, as in the example's Discover page: tap it to show every row, again to fold. Position `CYLMenuFoldC… | `CYLSearchView.suggestionsFoldControl` |
| `CYLSearchView.suggestionsFoldedRowCount` | The rows of tag suggestions shown while folded. 2 by default; 0 shows every row. | `CYLSearchView.suggestionsFoldedRowCount` |
| `CYLSearchView.suggestionStyle` | How the suggestions are shown: tags (`CYLSearchSuggestionStyleTags`, the default, folded to `suggestionsFoldedRowCount` rows with the fold control as the last tag) or a list (`CYLSearchSuggestionStyleList`). A tapped tag works like a tap… | `CYLSearchView.suggestionStyle` |
| `CYLSearchView.showsEmptyResultsPlaceholder` | Shows CYLTableViewPlaceHolder's placeholder for `emptyResultsScenario` under the search bar while a non-empty query matches no suggestion, in both suggestion styles, or `resultsDataSource` returns no result. NO by default. | `CYLSearchView.showsEmptyResultsPlaceholder` |
| `CYLSearchView.noResultsText` | The title of the empty results placeholder, with the bundled "no results" animation (the component `CYLSearchController.noResultsText` shows). A text that is not empty also turns the placeholder on, as `showsEmptyResultsPlaceholder` does… | `CYLSearchView.noResultsText` |
| `CYLSearchView.emptyResultsScenario` | The CYLTableViewPlaceHolder scenario of that placeholder. `CYLPlaceholderScenarioNoSearchResults` (an icon, a title and a hint) by default; `CYLPlaceholderScenarioNoContent` shows the plain empty state. | `CYLSearchView.emptyResultsScenario` |
| `CYLSearchView.emptyResultsView` | The placeholder shown for empty results (CYLTableViewPlaceHolder's `CYLPlaceholderStackView`), created the first time it is shown; nil before. Style it after it appears, or change `emptyResultsScenario`. | `CYLSearchView.emptyResultsView` |
| `CYLSearchView.resultsDataSource` | Supplies the results (was `CYLSearchController`'s and `CYLSearchResultsViewController`'s `searchDataSource`). While it is set and the query is not empty, `resultsTableView` lists them under the search bar and the suggestions are hidden;… | `CYLSearchView.resultsDataSource` |
| `CYLSearchView.resultsTableView` | The table that lists `searchResults` (was `CYLSearchResultsViewController.tableView`). Style it directly; its data source and delegate are the search view. | `CYLSearchView.resultsTableView` |
| `CYLSearchView.searchResults` | The results of the current query, from `resultsDataSource`; empty while the suggestions are shown. | `CYLSearchView.searchResults` |
| `CYLSearchView.highlightsResultMatches` | Gives the first match of the query in each result row `resultMatchHighlightColor` (the tint color by default), after `resultsDataSource` configured the row; the text label and a list content configuration are both highlighted. `CYLSearch… | `CYLSearchView.highlightsResultMatches` |
| `CYLSearchView.resultMatchHighlightColor` | The color of the highlighted match. Nil (the default) uses the tint color. | `CYLSearchView.resultMatchHighlightColor` |
| `CYLSearchView.resultsHeaderTitleProvider` | Titles the results: while results show, a header above the first row says what this closure returns for the query (a footnote, `resultsHeaderTextColor`, a header trait for VoiceOver); nil from the closure, or no closure (the default), sh… | `CYLSearchView.resultsHeaderTitleProvider` |
| `CYLSearchView.resultsHeaderTextColor` | The color of the results header text. Nil (the default) is the secondary label color. | `CYLSearchView.resultsHeaderTextColor` |
| `CYLSearchView.refreshHandler` | Pull-to-refresh of `resultsTableView` (CYLTableViewPlaceHolder's normal header inside): non-nil adds it, nil removes it. Call `-endRefreshing` on every completion path, and do not capture the view controller strongly. | `CYLSearchView.refreshHandler` |
| `CYLSearchView.isRefreshing` | YES while `resultsTableView` refreshes. | `CYLSearchView.isRefreshing` |
| `CYLSearchView.beginRefreshing()` | Starts the refresh of `resultsTableView`, as a pull would; calls `refreshHandler`. | `CYLSearchView.beginRefreshing` |
| `CYLSearchView.endRefreshing()` | Stops the refresh of `resultsTableView`. | `CYLSearchView.endRefreshing` |
| `CYLSearchView.setRefreshHandler(_:)` | The same pull-to-refresh on a scroll view of yours, such as the table of a screen whose navigation item holds a `the system search controller` (the Issue #1317 page): non-nil adds CYLTableViewPlaceHolder's normal header with the handler,… | `CYLSearchView.setRefreshHandler` |
| `CYLSearchView.beginRefreshing(in:)` | Starts the refresh of a scroll view set up with `+setRefreshHandler:forScrollView:`. | `CYLSearchView.beginRefreshing` |
| `CYLSearchView.endRefreshing(in:)` | Stops the refresh of a scroll view set up with `+setRefreshHandler:forScrollView:`. Call it on every completion path of the handler. | `CYLSearchView.endRefreshing` |
| `CYLSearchView.isRefreshing(in:)` | YES while a scroll view set up with `+setRefreshHandler:forScrollView:` refreshes. | `CYLSearchView.isRefreshing` |
| `CYLSearchView.dividerColor` | The color of `dividerView` (lapism `setDividerColor`). `separatorColor` by default; clear hides it. | `CYLSearchView.dividerColor` |
| `CYLSearchView.contentView` | A view of yours shown under the divider, behind the suggestions (lapism `addView`): a results list, a history, anything. Nil by default. | `CYLSearchView.contentView` |
| `CYLSearchView.scrimColor` | The color behind the page while it is open (lapism `setScrimColor`). Nil (none) by default; the page itself uses `backgroundColor`, `systemBackgroundColor` by default. | `CYLSearchView.scrimColor` |
| `CYLSearchView.suggestions` | The suggestions to filter as the text changes (MaterialSearchView `setSuggestions`). | `CYLSearchView.suggestions` |
| `CYLSearchView.suggestionFilter` | Decides whether a suggestion matches the query. Nil uses a case- and diacritic-insensitive "contains" test. An empty query matches nothing unless `showsSuggestionsForEmptyQuery` is YES. | `CYLSearchView.suggestionFilter` |
| `CYLSearchView.showsSuggestionsForEmptyQuery` | Lists every suggestion while the query is empty. NO by default. | `CYLSearchView.showsSuggestionsForEmptyQuery` |
| `CYLSearchView.filteredSuggestions` | The suggestions that match the current query, in their original order. | `CYLSearchView.filteredSuggestions` |
| `CYLSearchView.suggestionImage` | The icon before each suggestion (MaterialSearchView `setSuggestionIcon`). `magnifyingglass` by default; nil shows none. | `CYLSearchView.suggestionImage` |
| `CYLSearchView.suggestionImageTintColor` | The tint of `suggestionImage`. `secondaryLabelColor` by default. | `CYLSearchView.suggestionImageTintColor` |
| `CYLSearchView.suggestionBackgroundColor` | The background of the suggestion rows (`setSuggestionBackground`). Nil keeps the page background. | `CYLSearchView.suggestionBackgroundColor` |
| `CYLSearchView.suggestionTextColor` | The color of the suggestion text. `labelColor` by default. | `CYLSearchView.suggestionTextColor` |
| `CYLSearchView.suggestionLineBreakMode` | How a long suggestion is cut (MaterialSearchView `setEllipsize`). `NSLineBreakByWordWrapping` by default (whole text on several lines); `NSLineBreakByTruncatingTail` keeps one line with an ellipsis. | `CYLSearchView.suggestionLineBreakMode` |
| `CYLSearchView.submitsOnSuggestionSelection` | Submits a suggestion as soon as it is tapped (`setSubmitOnClick`). NO by default: the field shows it and the person can edit it. | `CYLSearchView.submitsOnSuggestionSelection` |
| `CYLSearchView.suggestionCellConfiguration` | Configures each suggestion cell after the defaults (a custom adapter's `getView`). Optional. | `CYLSearchView.suggestionCellConfiguration` |
| `CYLSearchView.suggestionCachePolicy` | Where submitted queries are cached for the suggestion list (`CYLSearchSuggestionCachePolicyDatabase`, a local SQLite database, by default). While the query is empty, the list shows the cached queries, newest first, under a header whose d… | `CYLSearchView.suggestionCachePolicy` |
| `CYLSearchView.suggestionCacheName` | Separates the caches of different search screens. "CYLSearchView" by default. | `CYLSearchView.suggestionCacheName` |
| `CYLSearchView.suggestionCache` | The cache in use: the built-in store of `suggestionCachePolicy`, or a store of yours (set it after the policy). Nil when the policy is `CYLSearchSuggestionCachePolicyNone`. | `CYLSearchView.suggestionCache` |
| `CYLSearchView.suggestionCacheHeaderView` | The header above the cached queries: a title and, at its trailing edge, `clearSuggestionCacheButton`. | TODO: N/A on HarmonyOS: ArkUI has no view objects; `CYLSearchComponent.cacheHeader` draws it |
| `CYLSearchView.showsSuggestionCacheHeader` | Whether `suggestionCacheHeaderView` (the title and the trash icon) shows above the cached queries. YES by default; NO takes the header away, for a host that clears the history with its own control, for example a button in `suggestionsTab… | `CYLSearchView.showsSuggestionCacheHeader` |
| `CYLSearchView.suggestionCacheFooterTitle` | A text button under the cached queries and the suggestions of the list style that clears the cache, with this title (a bordered footnote button centered below the last row). Nil (the default) shows none; with it, set `showsSuggestionCach… | `CYLSearchView.suggestionCacheFooterTitle` |
| `CYLSearchView.suggestionCacheTitleLabel` | The title of `suggestionCacheHeaderView` ("Recent searches"). | `CYLSearchView.suggestionCacheTitle` |
| `CYLSearchView.clearSuggestionCacheButton` | Clears the whole cache (a trash icon at the top right of the suggestion list). | `CYLSearchView.clearSuggestionCache()` (the header button calls it) |
| `CYLSearchView.showsEmptySuggestionsPlaceholder` | Shows CYLTableViewPlaceHolder's placeholder for `emptySuggestionsScenario` while the query is empty and the cache holds nothing, so an open search is never a blank page. YES by default. | `CYLSearchView.showsEmptySuggestionsPlaceholder` |
| `CYLSearchView.emptySuggestionsScenario` | The scenario of that placeholder. `CYLPlaceholderScenarioNoContent` by default. | `CYLSearchView.emptySuggestionsScenario` |
| `CYLSearchView.emptySuggestionsView` | The placeholder shown for an empty cache, created the first time it is shown; nil before. | `CYLSearchView.emptySuggestionsView` |
| `CYLSearchView.focusesSearchFieldOnShow` | Focuses the search field when the search opens, which raises the keyboard. YES by default. NO opens the search with the suggestion list (or the empty placeholder) and the keyboard down; the field is focused when the person taps it. | `CYLSearchView.focusesSearchFieldOnShow` |
| `CYLSearchView.searchOpen` | YES while the search view is open (MaterialSearchView `isSearchOpen`). | `CYLSearchView.isSearchOpen` |
| `CYLSearchView.isActive` | Whether the search is active, changed without animation (`CYLSearchController.isActive`); the same state as `searchOpen`: YES opens the search view, NO closes it. | `CYLSearchView.isActive` |
| `CYLSearchView.setActive(_:animated:)` | Opens or closes the search view (`CYLSearchController.setActive(_:animated:)`), like `showSearch(animated:)` and `closeSearch(animated:)`. | `CYLSearchView.setActive` |
| `CYLSearchView.supportsSwipeToDismissSearch` | Whether a swipe from the left screen edge leaves the search, as `CYLSearchController.supportsSwipeToDismissSearch` does: the page follows the finger and the search closes when it was dragged past a quarter of the width, moving right. NO… | `CYLSearchView.supportsSwipeToDismissSearch` |
| `CYLSearchView.animationDuration` | The length of the open and close animations, in seconds (`setAnimationDuration`). 0.25 by default. | `CYLSearchView.animationDuration` |
| `CYLSearchView.closesOnSubmit` | Closes the search view after a submitted query that the delegate did not handle. YES by default. | `CYLSearchView.closesOnSubmit` |
| `CYLSearchView.query` | The current query (lapism `getTextQuery`). | `CYLSearchView.query` |
| `CYLSearchView.backgroundColor` | The page background (the view itself only shows the scrim). `systemBackgroundColor` by default. | `CYLSearchView.backgroundColor` |
| `CYLSearchView.init(frame:)` | — | `new CYLSearchView(…)` |
| `CYLSearchView.init(coder:)` | Creates the search view from an archive (a storyboard or a XIB). | TODO: N/A on HarmonyOS: no archives in ArkUI (the state is restored with `decodeRestorableState`) |
| `CYLSearchView.layoutSubviews()` | — | TODO: N/A on HarmonyOS: ArkUI lays a component out from its declaration |
| `CYLSearchView.safeAreaInsetsDidChange()` | — | TODO: N/A on HarmonyOS: ArkUI keeps the page inside the safe area by itself |
| `CYLSearchView.install(in:)` | Adds the search view over `view` (pinned to its edges) without opening it. `-showSearch` calls it with the key window's root view when the search view has no superview. | `CYLSearchView.installInView` |
| `CYLSearchView.showSearch()` | Opens the search view with animation and starts editing (`showSearch`). | `CYLSearchView.showSearch` |
| `CYLSearchView.showSearch(animated:)` | Opens the search view and starts editing (`showSearch(animate)`). | `CYLSearchView.showSearch` |
| `CYLSearchView.closeSearch()` | Closes the search view with animation and ends editing (`closeSearch`). | `CYLSearchView.closeSearch` |
| `CYLSearchView.closeSearch(animated:)` | Closes the search view and ends editing. | `CYLSearchView.closeSearch` |
| `CYLSearchView.closeSearch(animated:completion:)` | Closes the search view and ends editing, then calls `completion` once the view is hidden; at once when it is already closed (was `-[CYLSearchController hide:]`). | `CYLSearchView.closeSearch` |
| `CYLSearchView.encodeRestorableState(with:)` | Saves whether the search view is open and its query (`onSaveInstanceState`). UIKit calls it for a view with a `restorationIdentifier` inside a restored view controller. | `CYLSearchView.encodeRestorableState` |
| `CYLSearchView.decodeRestorableState(with:)` | Restores the query and reopens the search view when it was open (`onRestoreInstanceState`). | `CYLSearchView.decodeRestorableState` |
| `CYLSearchView.accessibilityPerformEscape()` | — | `CYLSearchView.accessibilityPerformEscape` |
| `CYLSearchView.attach(to:)` | Makes a bar button item open the search view (`setMenuItem`). | `CYLSearchView.attachToMenuItem` |
| `CYLSearchView.setSnapsHeader(_:for:in:)` | Keeps `header`, a search bar that is the header of `tableView`, scrollable out of sight above a short list and settles it fully shown or fully hidden when a drag ends, while this search view is not open (what `CYLSearchController.snapsHe… | `CYLSearchView.setSnapsHeader` |
| `CYLSearchView.setQuery(_:submit:)` | Sets the query and submits it when `submit` is YES (`setQuery`, `setTextQuery`). | `CYLSearchView.setQuery` |
| `CYLSearchView.showSuggestions()` | Lists the suggestions that match the current query (`showSuggestions`). | `CYLSearchView.showSuggestions` |
| `CYLSearchView.reloadResults()` | Queries `resultsDataSource` again for the current query and reloads `resultsTableView` (was `reloadSearchResults` and `reloadResultsTableView`). Call it when the results changed, for example after a refresh. | `CYLSearchView.reloadResults` |
| `CYLSearchView.dismissSuggestions()` | Hides the suggestions and the results (`dismissSuggestions`). | `CYLSearchView.dismissSuggestions` |
| `CYLSearchView.clearSuggestionCache()` | Removes every cached query (the delete button of `suggestionCacheHeaderView`) and shows the list again. | `CYLSearchView.clearSuggestionCache` |
| `CYLSearchView.searchBarView(_:textDidChange:)` | Filters the suggestions and reports the change. | TODO: N/A on HarmonyOS: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.searchBarViewSearchButtonClicked(_:)` | Reports the submitted query and closes unless the delegate handled it. | TODO: N/A on HarmonyOS: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.searchBarViewNavigationButtonClicked(_:)` | Reports the navigation button, or closes the search view. | TODO: N/A on HarmonyOS: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.searchBarViewVoiceButtonClicked(_:)` | Reports the voice button. | TODO: N/A on HarmonyOS: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.searchBarViewCancelButtonClicked(_:)` | Cancel closes the search view. | TODO: N/A on HarmonyOS: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.searchBarViewDidBeginEditing(_:)` | Reports focus. | TODO: N/A on HarmonyOS: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.searchBarViewDidEndEditing(_:)` | Reports the loss of focus. | TODO: N/A on HarmonyOS: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.tableView(_:numberOfRowsInSection:)` | One row per result in `resultsTableView`, one row per matching suggestion while the suggestions are shown. | TODO: N/A on HarmonyOS: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.tableView(_:cellForRowAt:)` | A result row configured by `resultsDataSource`, or a suggestion row: icon, text, background, then `suggestionCellConfiguration`. | TODO: N/A on HarmonyOS: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.tableView(_:didSelectRowAt:)` | Reports a tapped result (`-searchView:didSelectResult:`); for a suggestion, fills the field with it, reports it, and submits it when `submitsOnSuggestionSelection` is YES. | TODO: N/A on HarmonyOS: a UIKit protocol conformance (ArkUI reports the same events to the model) |
<!-- harmonyos-api-alignment:end -->

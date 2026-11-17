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
- Status: `TODO`, score 0 (no HarmonyOS module yet).
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
Rows: 284; implemented or N/A 284, TODO 0; score 100/100.

| iOS public API | Doc comment | HarmonyOS |
| :--- | :--- | :--- |
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
| **enum `CYLSearchBarStyle`** | The fixed look of the whole bar: the field on the left stays, the items are appended after its text. | `CYLSearchBarStyle` |
| `CYLSearchBarStyle.plain` | The field as configured by its own properties (the default; nothing is changed). | `CYLSearchBarStyle.plain` |
| `CYLSearchBarStyle.bordered` | A capsule with a 1 pt separator-colored border on the system background, the field and its items inside one outline (the Discover search bar). | `CYLSearchBarStyle.bordered` |
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
| `CYLSearchBarView.placeholderColor` | The placeholder color. `placeholderTextColor` when nil. | `CYLSearchBarView.placeholderColor` |
| `CYLSearchBarView.cursorColor` | The color of the text cursor (MaterialSearchView `setCursorDrawable`). The tint color by default. | `CYLSearchBarView.cursorColor` |
| `CYLSearchBarView.fieldHeight` | The height of the field; it grows when the scaled text needs more. 36 by default. | `CYLSearchBarView.fieldHeight` |
| `CYLSearchBarView.contentInsets` | The space around the field. (6, 12, 6, 12) by default. | `CYLSearchBarView.contentInsets` |
| `CYLSearchBarView.fieldBackgroundColor` | The field's background. `tertiarySystemFillColor` by default. | `CYLSearchBarView.fieldBackgroundColor` |
| `CYLSearchBarView.fieldCornerRadius` | The field's corner radius; negative makes a capsule. -1 by default. | `CYLSearchBarView.fieldCornerRadius` |
| `CYLSearchBarView.fieldBorderColor` | The field's border color; nil draws no border. | `CYLSearchBarView.fieldBorderColor` |
| `CYLSearchBarView.fieldBorderWidth` | The field's border width, used with `fieldBorderColor`. 0 by default. | `CYLSearchBarView.fieldBorderWidth` |
| `CYLSearchBarView.fieldShadowOpacity` | The field's shadow, 0 to 1. 0 by default. | `CYLSearchBarView.fieldShadowOpacity` |
| `CYLSearchBarView.searchIcon` | The magnifier; nil shows none. `magnifyingglass` by default. | `CYLSearchBarView.searchIcon` |
| `CYLSearchBarView.searchIconTintColor` | The magnifier's tint. `secondaryLabelColor` by default. | `CYLSearchBarView.searchIconTintColor` |
| `CYLSearchBarView.trailingAccessoryViews` | Views of yours inside the field after the text, scaled down when they would squeeze it. | `CYLSearchBarComponent.trailingAccessoryViews` (a `@BuilderParam`) |
| `CYLSearchBarView.items` | The appended items, in order, after the text and after `trailingAccessoryViews` (like the FlatDesign tab bar's `items`). The field stays; only items are appended. | `CYLSearchBarView.items` |
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
| `CYLSearchBarView.hasItem(of:)` | YES when an item of the style was appended (a text "Search" button), like `-hasPlusButton`. | `CYLSearchBarView.hasItem` |
| `CYLSearchBarView.leadingView` | A view of yours before the field (a back button); it wins over the navigation button. | `CYLSearchBarComponent.leadingView` (a `@BuilderParam`) |
| `CYLSearchBarView.showsCancelButton` | Shows the Cancel button after the field. NO by default. | `CYLSearchBarView.showsCancelButton` |
| `CYLSearchBarView.cancelButtonTitle` | The Cancel title. The localized "Cancel" by default. | `CYLSearchBarView.cancelButtonTitle` |
| `CYLSearchBarView.cancelButtonEndsEditing` | Taps on Cancel also end editing and clear nothing. YES by default. | `CYLSearchBarView.cancelButtonEndsEditing` |
| `CYLSearchBarView.clearsTextOnCancel` | Taps on Cancel also clear the text (lapism `setTextClearOnBackPressed`). NO by default. | `CYLSearchBarView.clearsTextOnCancel` |
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
| `CYLSearchBarItem.animationURL` | An animated icon file (Lottie .json, .pag, .riv, .svga, .gif), drawn by the item's `CYLTagButton` (a `CYLAnimatedItemView`) when the app adds the engine of its type (`CYLTabBarController/CYLAnimatedItem<Type>`; the core adds none) and pl… | `CYLSearchBarItem.animationURL` |
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
| **class `CYLSearchResources`** | Images and localized strings of `CYLSearchViewController.bundle`, the resource bundle of this pod. | `CYLSearchResources` |
| `CYLSearchResources.resourceBundle` | The resource bundle, found next to this class's framework or in the main bundle; nil when it is missing. | `CYLSearchResources.resourceBundle` |
| `CYLSearchResources.image(named:)` | An image of the resource bundle, or nil (logged) when it is missing. | `CYLSearchResources.imageNamed` |
| `CYLSearchResources.localizedString(forKey:)` | The text of `key` in the language the app shows (the preferred languages), English when the key has no translation, or the key itself (logged) when it is missing everywhere. | `CYLSearchResources.localizedString` |
| `CYLSearchResources.localizedString(forKey:language:)` | The text of `key` in `language` (for example "zh-Hans"), or in the preferred languages when `language` is nil. | `CYLSearchResources.localizedString` |
| **enum `CYLSearchSuggestionStyle`** | How the suggestions are shown under the search bar (`CYLSearchView.suggestionStyle`). | `CYLSearchSuggestionStyle` |
| `CYLSearchSuggestionStyle.list` | One suggestion per row with its icon, in `suggestionsTableView`. | `CYLSearchSuggestionStyle.list` |
| `CYLSearchSuggestionStyle.tags` | Tags that wrap like words, in `suggestionsTagView` (CollectionViewClassifyMenu's `CYLTagListView`). | `CYLSearchSuggestionStyle.tags` |
| **protocol `CYLSearchViewDelegate`** | Events of a `CYLSearchView`: opening and closing, the query, focus, suggestions and the voice button. | `CYLSearchViewDelegate` |
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
| `CYLSearchView.suggestionStyle` | How the suggestions are shown: a list (`CYLSearchSuggestionStyleList`, the default) or tags (`CYLSearchSuggestionStyleTags`). A tapped tag works like a tapped row. | `CYLSearchView.suggestionStyle` |
| `CYLSearchView.showsEmptyResultsPlaceholder` | Shows CYLTableViewPlaceHolder's placeholder for `emptyResultsScenario` under the search bar while a non-empty query matches no suggestion, in both suggestion styles, or `resultsDataSource` returns no result. NO by default. | `CYLSearchView.showsEmptyResultsPlaceholder` |
| `CYLSearchView.emptyResultsScenario` | The CYLTableViewPlaceHolder scenario of that placeholder. `CYLPlaceholderScenarioNoSearchResults` (an icon, a title and a hint) by default; `CYLPlaceholderScenarioNoContent` shows the plain empty state. | `CYLSearchView.emptyResultsScenario` |
| `CYLSearchView.emptyResultsView` | The placeholder shown for empty results (CYLTableViewPlaceHolder's `CYLPlaceholderStackView`), created the first time it is shown; nil before. Style it after it appears, or change `emptyResultsScenario`. | `CYLSearchView.emptyResultsView` |
| `CYLSearchView.resultsDataSource` | Supplies the results (was `CYLSearchController`'s and `CYLSearchResultsViewController`'s `searchDataSource`). While it is set and the query is not empty, `resultsTableView` lists them under the search bar and the suggestions are hidden;… | `CYLSearchView.resultsDataSource` |
| `CYLSearchView.resultsTableView` | The table that lists `searchResults` (was `CYLSearchResultsViewController.tableView`). Style it directly; its data source and delegate are the search view. | `CYLSearchView.resultsTableView` |
| `CYLSearchView.searchResults` | The results of the current query, from `resultsDataSource`; empty while the suggestions are shown. | `CYLSearchView.searchResults` |
| `CYLSearchView.refreshHandler` | Pull-to-refresh of `resultsTableView` (CYLTableViewPlaceHolder's normal header inside): non-nil adds it, nil removes it. Call `-endRefreshing` on every completion path, and do not capture the view controller strongly. | `CYLSearchView.refreshHandler` |
| `CYLSearchView.isRefreshing` | YES while `resultsTableView` refreshes. | `CYLSearchView.isRefreshing` |
| `CYLSearchView.beginRefreshing()` | Starts the refresh of `resultsTableView`, as a pull would; calls `refreshHandler`. | `CYLSearchView.beginRefreshing` |
| `CYLSearchView.endRefreshing()` | Stops the refresh of `resultsTableView`. | `CYLSearchView.endRefreshing` |
| `CYLSearchView.setRefreshHandler(_:)` | The same pull-to-refresh on a scroll view of yours, such as the table of a screen whose navigation item holds a `UISearchController` (the Issue #1317 page): non-nil adds CYLTableViewPlaceHolder's normal header with the handler, nil remov… | `CYLSearchView.setRefreshHandler` |
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
| `CYLSearchView.suggestionCacheTitleLabel` | The title of `suggestionCacheHeaderView` ("Recent searches"). | `CYLSearchView.suggestionCacheTitle` |
| `CYLSearchView.clearSuggestionCacheButton` | Clears the whole cache (a trash icon at the top right of the suggestion list). | `CYLSearchView.clearSuggestionCache()` (the header button calls it) |
| `CYLSearchView.showsEmptySuggestionsPlaceholder` | Shows CYLTableViewPlaceHolder's placeholder for `emptySuggestionsScenario` while the query is empty and the cache holds nothing, so an open search is never a blank page. YES by default. | `CYLSearchView.showsEmptySuggestionsPlaceholder` |
| `CYLSearchView.emptySuggestionsScenario` | The scenario of that placeholder. `CYLPlaceholderScenarioNoContent` by default. | `CYLSearchView.emptySuggestionsScenario` |
| `CYLSearchView.emptySuggestionsView` | The placeholder shown for an empty cache, created the first time it is shown; nil before. | `CYLSearchView.emptySuggestionsView` |
| `CYLSearchView.focusesSearchFieldOnShow` | Focuses the search field when the search opens, which raises the keyboard. YES by default. NO opens the search with the suggestion list (or the empty placeholder) and the keyboard down; the field is focused when the person taps it. | `CYLSearchView.focusesSearchFieldOnShow` |
| `CYLSearchView.searchOpen` | YES while the search view is open (MaterialSearchView `isSearchOpen`). | `CYLSearchView.isSearchOpen` |
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

# HarmonyOS API Alignment

Every public API of the iOS library (`Sources/CYLSearchViewController`) next to its HarmonyOS (ArkTS) counterpart,
made as the [Android table](android-api-alignment.md) was. Rules and prompt: the HarmonyOS TODO in
[android-and-cross-platform.md](android-and-cross-platform.md).

## TODO (2026-11-13): implement every iOS API on HarmonyOS, score to 100

- Columns: the iOS public API; its doc comment; the HarmonyOS counterpart, `TODO` by default.
- After each API is implemented, replace that row's `TODO` with the HarmonyOS API (`N/A: <reason>` for a UIKit-only
  override with no HarmonyOS meaning), then run `python3 scripts/harmonyos-api-alignment.py`: it regenerates the rows
  from the Swift sources, keeps the third column, and prints the score. Repeat until 100.
- Before the search bar: study [Applib-HarmonyOS/FlexibleSearchBar](https://github.com/Applib-HarmonyOS/FlexibleSearchBar)
  and note what is reused.
- Status: `TODO`, score 0 (no HarmonyOS module yet).
- Status (2026-11-14): `IN PROGRESS`: the module exists (`harmonyos/cylsearch`); the score below is computed from its
  sources.

## Score log

Score = rows whose third column is not `TODO` / rows × 100.

| Date | Change | Score |
| :--- | :--- | ---: |
| 2026-11-13 | Table listed, no HarmonyOS module | 0 |

## Table

<!-- harmonyos-api-alignment:begin -->
Rows: 397; implemented or N/A 196, TODO 201; score 49/100.

| iOS public API | Doc comment | HarmonyOS |
| :--- | :--- | :--- |
| **protocol `CYLMultiSearchViewDelegate`** | Events of a `CYLMultiSearchView` (iammert `MultiSearchViewListener`). | TODO |
| `CYLMultiSearchViewDelegate.-multiSearchView:textDidChange:atIndex:` | The text of the search being typed changed (`onTextChanged`). | TODO |
| `CYLMultiSearchViewDelegate.-multiSearchView:didCompleteSearch:atIndex:` | A search was completed and became an item (`onSearchComplete`). | TODO |
| `CYLMultiSearchViewDelegate.-multiSearchView:didRemoveItemAtIndex:` | An item was removed (`onSearchItemRemoved`). | TODO |
| `CYLMultiSearchViewDelegate.-multiSearchView:didSelectItem:atIndex:` | An item was selected by a tap (`onItemSelected`). | TODO |
| **class `CYLMultiSearchView`** | Several searches side by side (iammert `MultiSearchView`): the search button starts a new search; a completed search becomes an item in a horizontally scrolling row, with an indicator under the selected item and a remove button on it. Us… | TODO |
| `CYLMultiSearchView.delegate` | Receives the events. | TODO |
| `CYLMultiSearchView.selectedIndex` | The selected item, or `NSNotFound` when there is none. | TODO |
| `CYLMultiSearchView.inSearchMode` | YES while a new search is being typed (`isInSearchMode`). | TODO |
| `CYLMultiSearchView.searchButton` | The button at the trailing end: it starts a search, or completes the one being typed. | TODO |
| `CYLMultiSearchView.placeholder` | The placeholder of a new search (`android:hint`). "Search" by default. | TODO |
| `CYLMultiSearchView.font` | The font of the items (`android:textSize`). The body text style by default, following Dynamic Type. | TODO |
| `CYLMultiSearchView.textColor` | The text color (`android:textColor`). `labelColor` by default. | TODO |
| `CYLMultiSearchView.placeholderColor` | The placeholder color (`android:textColorHint`). `placeholderTextColor` by default. | TODO |
| `CYLMultiSearchView.maximumTextLength` | The longest search a person can type (`android:maxLength`); 0 means no limit. 0 by default. | TODO |
| `CYLMultiSearchView.minimumTextLength` | A search shorter than this is dropped when it is completed. 3 by default, as in MultiSearchView. | TODO |
| `CYLMultiSearchView.returnKeyType` | The return key (`android:imeOptions`). `UIReturnKeySearch` by default. | TODO |
| `CYLMultiSearchView.keyboardType` | The keyboard (`android:inputType`). `UIKeyboardTypeDefault` by default. | TODO |
| `CYLMultiSearchView.autocapitalizationType` | Capitalization (`textCapSentences`). `UITextAutocapitalizationTypeSentences` by default. | TODO |
| `CYLMultiSearchView.indicatorColor` | The color of the indicator under the selected item and of the buttons. `tintColor` by default. | TODO |
| `CYLMultiSearchView.unselectedItemAlpha` | The opacity of items that are not selected. 0.5 by default. | TODO |
| `CYLMultiSearchView.searchFieldWidth` | The width of the field for a new search, in points. 160 by default. | TODO |
| `CYLMultiSearchView.animationDuration` | The length of the animations, in seconds. 0.25 by default. | TODO |
| `CYLMultiSearchView.searchImage` | The search button's icon. `magnifyingglass` by default. | TODO |
| `CYLMultiSearchView.removeImage` | The remove button's icon. `xmark.circle.fill` by default. | TODO |
| `CYLMultiSearchView.searchTexts` | The texts of the items, completed searches first, then the one being typed. | TODO |
| `CYLMultiSearchView.init(frame:)` | — | TODO |
| `CYLMultiSearchView.init(coder:)` | — | N/A: no archives in ArkUI (the state is restored with `decodeRestorableState`) |
| `CYLMultiSearchView.tintColorDidChange()` | — | TODO |
| `CYLMultiSearchView.traitCollectionDidChange(_:)` | — | N/A: system colors (`sys.color.*`) follow the color mode by themselves |
| `CYLMultiSearchView.intrinsicContentSize` | — | TODO |
| `CYLMultiSearchView.layoutSubviews()` | — | N/A: ArkUI lays a component out from its declaration |
| `CYLMultiSearchView.search()` | Starts a new search and shows the keyboard (`search`). Does nothing while a search is being typed. | TODO |
| `CYLMultiSearchView.completeSearch()` | Completes the search being typed (`completeSearch`): it becomes the selected item, or is dropped when shorter than `minimumTextLength`. | TODO |
| `CYLMultiSearchView.addSearchText(_:)` | Adds a completed search without typing it and selects it. | TODO |
| `CYLMultiSearchView.selectItem(at:)` | Selects an item, like a tap on it. | TODO |
| `CYLMultiSearchView.removeItem(at:)` | Removes an item, like a tap on its remove button. | TODO |
| `CYLMultiSearchView.textFieldShouldBeginEditing(_:)` | Only the search being typed is editable; a tap on a completed one selects it. | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLMultiSearchView.textFieldShouldReturn(_:)` | The return key completes the search. | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLMultiSearchView.textField(_:shouldChangeCharactersIn:replacementString:)` | Enforces `maximumTextLength`. | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| **enum `CYLSearchBarItemStyle`** | How an item appended to a search bar looks, like the FlatDesign tab bar's item appearance. | `CYLSearchBarItemStyle` |
| `CYLSearchBarItemStyle.icon` | An icon button with a 36 pt touch area (a camera, a filter). | `CYLSearchBarItemStyle.icon` |
| `CYLSearchBarItemStyle.divider` | A thin vertical line between two items; it takes no taps and VoiceOver skips it. | `CYLSearchBarItemStyle.divider` |
| `CYLSearchBarItemStyle.text` | A text button (a "Search" button); an image, when set, comes before the title. | `CYLSearchBarItemStyle.text` |
| **enum `CYLSearchBarStyle`** | The fixed look of the whole bar: the field on the left stays, the items are appended after its text. | `CYLSearchBarStyle` |
| `CYLSearchBarStyle.plain` | The field as configured by its own properties (the default; nothing is changed). | `CYLSearchBarStyle.plain` |
| `CYLSearchBarStyle.bordered` | A capsule with a 1 pt separator-colored border on the system background, the field and its items inside one outline (the Discover search bar). | `CYLSearchBarStyle.bordered` |
| **class `CYLSearchBarItem`** | One element after the text of a `CYLSearchBarView`: a model independent of its view, like `CYLFlatDesignTabBarItem`. Append it with `-[CYLSearchBarView addItem:]`; its view is `itemView`. | `CYLSearchBarItem` |
| `CYLSearchBarItem.style` | How the item looks (icon, divider or text); set when the item is created. | `CYLSearchBarItem.style` |
| `CYLSearchBarItem.title` | The text of a text item, and the VoiceOver label of an icon item without `accessibilityLabel`. | `CYLSearchBarItem.title` |
| `CYLSearchBarItem.image` | The icon (a template image is tinted with `tintColor`). | `CYLSearchBarItem.image` |
| `CYLSearchBarItem.selectedImage` | The icon while `selected` is YES; nil uses `image`. | `CYLSearchBarItem.selectedImage` |
| `CYLSearchBarItem.animatedImage` | An animated icon (`+[UIImage animatedImageWithImages:duration:]`), drawn instead of `image` when set. | `CYLSearchBarItem.animatedImage` |
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
| `CYLSearchBarItem.actualBadgeSuperView()` | The view the badge is drawn in (the item view). | N/A: ArkUI has no view objects; the badge is drawn by `CYLSearchBarItemView` |
| **class `CYLSearchBarItemView`** | The view of a `CYLSearchBarItem` (a control), like `CYLFlatDesignTabBarButton`. | `CYLSearchBarItemView` |
| `CYLSearchBarItemView.item` | The item this view draws. | `CYLSearchBarItemView.item` |
| `CYLSearchBarItemView.imageView` | The icon. | N/A: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarItemView.titleLabel` | The title of a text item. | N/A: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarItemView.badgeLabel` | The badge (`badgeValue`). | N/A: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarItemView.init(item:)` | The view for an item; the item's `itemView` is the one the bar shows. | TODO |
| `CYLSearchBarItemView.init(coder:)` | Not supported: an item view is created from its item. | N/A: no archives in ArkUI (the state is restored with `decodeRestorableState`) |
| `CYLSearchBarItemView.actualBadgeSuperView()` | The view the badge is drawn in (this view). | N/A: ArkUI has no view objects; the badge is drawn by `CYLSearchBarItemView` |
| `CYLSearchBarItemView.traitCollectionDidChange(_:)` | — | N/A: system colors (`sys.color.*`) follow the color mode by themselves |
| `CYLSearchBarItemView.intrinsicContentSize` | — | TODO |
| `CYLSearchBarItemView.sizeThatFits(_:)` | — | N/A: ArkUI measures a component from its declaration (`intrinsicContentSize` gives the height) |
| `CYLSearchBarItemView.layoutSubviews()` | — | N/A: ArkUI lays a component out from its declaration |
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
| **class `CYLSearchBarView`** | A configurable search bar: a rounded field with a magnifier, text and clear button, views of the host inside the field after the text (a camera, a "Search" button) or before the field (a back button), and an optional Cancel button. Use i… | `CYLSearchBarView` |
| `CYLSearchBarView.delegate` | Receives the events. | `CYLSearchBarView.delegate` |
| `CYLSearchBarView.textField` | The text field inside the field. | `CYLSearchBarView.textField` |
| `CYLSearchBarView.fieldView` | The rounded field that holds the magnifier, the text and `trailingAccessoryViews`. | N/A: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarView.searchIconView` | The magnifier at the start of the field (decorative: hidden from VoiceOver). | N/A: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarView.cancelButton` | The Cancel button after the field (`showsCancelButton`). | N/A: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarView.placeholderLabel` | Draws the placeholder at the full font size, cut off with an ellipsis when it does not fit. | N/A: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarView.navigationButton` | The button before the field. It is shown when `navigationIcon` is not none or `navigationImage` is set, and `leadingView` is nil; taps call `-searchBarViewNavigationButtonClicked:` and `navigationHandler`. | N/A: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarView.voiceButton` | A microphone inside the field, shown while the text is empty; it calls `-searchBarViewVoiceButtonClicked:`. | N/A: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarView.submitButton` | A submit button inside the field, shown while there is text; it submits the query like the Search key. | N/A: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
| `CYLSearchBarView.iconButton` | The button shown while `iconified` is YES. VoiceOver reads it as "Search". | N/A: ArkUI has no view objects; `CYLSearchBarComponent` / `CYLSearchBarItemView` draw it from the properties |
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
| `CYLSearchBarView.trailingAccessoryViews` | Views of yours inside the field after the text, scaled down when they would squeeze it. | TODO |
| `CYLSearchBarView.items` | The appended items, in order, after the text and after `trailingAccessoryViews` (like the FlatDesign tab bar's `items`). The field stays; only items are appended. | `CYLSearchBarView.items` |
| `CYLSearchBarView.itemViews` | The views of `items`, in the same order. | `CYLSearchBarView.itemViews` |
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
| `CYLSearchBarView.leadingView` | A view of yours before the field (a back button); it wins over the navigation button. | TODO |
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
| `CYLSearchBarView.autocapitalizationType` | Automatic capitalization. `UITextAutocapitalizationTypeSentences` by default. | TODO |
| `CYLSearchBarView.autocorrectionType` | Automatic correction. `UITextAutocorrectionTypeDefault` by default. | TODO |
| `CYLSearchBarView.isSecureTextEntry` | Hides the typed characters (Android `inputType="textPassword"`). NO by default. | `CYLSearchBarView.isSecureTextEntry` |
| `CYLSearchBarView.maximumTextLength` | The longest text a person can type (Android `maxLength`); 0 means no limit. 0 by default. | `CYLSearchBarView.maximumTextLength` |
| `CYLSearchBarView.isIconified` | Shows only a search button instead of the field (Android `SearchView.isIconified`). Tapping the button opens the field and starts editing. NO by default. | `CYLSearchBarView.isIconified` |
| `CYLSearchBarView.iconifiedByDefault` | When YES, the field closes back to its icon when editing ends with no text (Android `setIconifiedByDefault`). NO by default. | `CYLSearchBarView.iconifiedByDefault` |
| `CYLSearchBarView.expansionAnimation` | How the field opens and closes. `CYLSearchBarExpansionAnimationFade` by default. | `CYLSearchBarView.expansionAnimation` |
| `CYLSearchBarView.iconPosition` | Where `iconButton` sits while iconified; the field opens from there. `CYLSearchBarIconPositionTrailing` by default. | `CYLSearchBarView.iconPosition` |
| `CYLSearchBarView.animationDuration` | The length of the opening and closing animations, in seconds. 0.3 by default. | `CYLSearchBarView.animationDuration` |
| `CYLSearchBarView.init(frame:)` | — | `new CYLSearchBarView(…)` |
| `CYLSearchBarView.init(coder:)` | — | N/A: no archives in ArkUI (the state is restored with `decodeRestorableState`) |
| `CYLSearchBarView.setText(_:submit:)` | Sets the text and, when `submit` is YES and the text is not empty, submits it as if the Search key were tapped (MaterialSearchView `setQuery`, lapism `setTextQuery`). | `CYLSearchBarView.setText` |
| `CYLSearchBarView.submit()` | Submits the current text: asks `-searchBarView:shouldSubmitText:`, then calls `-searchBarViewSearchButtonClicked:`. Returns NO when the text is empty or the delegate refused it. | `CYLSearchBarView.submit` |
| `CYLSearchBarView.showKeyboard()` | Starts editing and shows the keyboard. | `CYLSearchBarView.showKeyboard` |
| `CYLSearchBarView.hideKeyboard()` | Ends editing and hides the keyboard. | `CYLSearchBarView.hideKeyboard` |
| `CYLSearchBarView.setIconified(_:animated:)` | Opens or closes the field, with `expansionAnimation` when `animated` is YES. Opening also starts editing. | `CYLSearchBarView.setIconified` |
| `CYLSearchBarView.encodeRestorableState(with:)` | Saves the text, whether it is editing and whether it is iconified (`onSaveInstanceState`). | `CYLSearchBarView.encodeRestorableState` |
| `CYLSearchBarView.decodeRestorableState(with:)` | Restores the text, the iconified state and editing (`onRestoreInstanceState`). | `CYLSearchBarView.decodeRestorableState` |
| `CYLSearchBarView.traitCollectionDidChange(_:)` | — | N/A: system colors (`sys.color.*`) follow the color mode by themselves |
| `CYLSearchBarView.intrinsicContentSize` | — | `CYLSearchBarView.intrinsicContentSize` |
| `CYLSearchBarView.sizeThatFits(_:)` | — | N/A: ArkUI measures a component from its declaration (`intrinsicContentSize` gives the height) |
| `CYLSearchBarView.layoutSubviews()` | — | N/A: ArkUI lays a component out from its declaration |
| `CYLSearchBarView.textFieldShouldBeginEditing(_:)` | Asks the delegate whether editing may start; a refusal reports a tap instead. | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchBarView.textFieldShouldReturn(_:)` | The return key submits the text. | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchBarView.textField(_:shouldChangeCharactersIn:replacementString:)` | Enforces `maximumTextLength`; deleting is always allowed. | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchBarView.textFieldDidBeginEditing(_:)` | Reports the start of editing. | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchBarView.textFieldDidEndEditing(_:)` | Clears the text and closes to the icon when configured, then reports the end of editing. | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchBarView.becomeFirstResponder()` | Starts editing in the text field. | TODO |
| `CYLSearchBarView.resignFirstResponder()` | Ends editing; the bar itself also gives up first responder as UIKit expects. | TODO |
| **protocol `CYLSearchControllerDelegate`** | Events of a `CYLSearchController`. | TODO |
| `CYLSearchControllerDelegate.-searchControllerDidCancel:` | Cancel was tapped and the overlay is gone. | TODO |
| **class `CYLSearchController`** | An animated search overlay that uses the same injectable result source as `CYLSearchResultsViewController`. Keep the controller while it is presented. | TODO |
| `CYLSearchController.delegate` | Receives the cancel event. | TODO |
| `CYLSearchController.resultsViewController` | The results controller shown inside the overlay. | TODO |
| `CYLSearchController.presented` | YES while the overlay is on screen or animating in. | TODO |
| `CYLSearchController.init(searchDataSource:)` | Creates the overlay with the data source of its results. | TODO |
| `CYLSearchController.init(nibName:bundle:)` | Not available: use `init(searchDataSource:)`. | N/A: not available on iOS either (`@available(*, unavailable)`) |
| `CYLSearchController.init(coder:)` | Not available: use `init(searchDataSource:)`. | N/A: no archives in ArkUI (the state is restored with `decodeRestorableState`) |
| `CYLSearchController.viewDidLayoutSubviews()` | Keeps the view below the navigation bar and its search bar after every layout (a search bar never covers a view). | TODO |
| `CYLSearchController.viewDidLoad()` | — | TODO |
| `CYLSearchController.show(in:)` | Adds a child navigation controller to the host and animates it into view. | TODO |
| `CYLSearchController.hide(_:)` | Completion is called after the overlay is removed, including when not presented. | TODO |
| **enum `CYLSearchPlaceholderKind`** | The common placeholder kinds: an empty list, no search results, or an error. | TODO |
| `CYLSearchPlaceholderKind.empty` | Nothing to show yet. | TODO |
| `CYLSearchPlaceholderKind.noResults` | The search found nothing. | TODO |
| `CYLSearchPlaceholderKind.error` | Loading failed. | TODO |
| **enum `CYLSearchPlaceholderStyle`** | The image of a placeholder; each style has an image in the resource bundle. | TODO |
| `CYLSearchPlaceholderStyle.empty` | The Empty placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.noResults` | The NoResults placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.error` | The Error placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.wifiOff` | The WifiOff placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.signalWifiOff` | The SignalWifiOff placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.noInternet` | The NoInternet placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.cloudOff` | The CloudOff placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.syncProblem` | The SyncProblem placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.syncDisabled` | The SyncDisabled placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.networkLocked` | The NetworkLocked placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.bluetoothDisabled` | The BluetoothDisabled placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.locationOff` | The LocationOff placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.publicOff` | The PublicOff placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.errorOutline` | The ErrorOutline placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.warning` | The Warning placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.reportProblem` | The ReportProblem placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.blocked` | The Blocked placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.help` | The Help placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.hourglass` | The Hourglass placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.locked` | The Locked placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.visibilityOff` | The VisibilityOff placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.searchOff` | The SearchOff placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.folderOff` | The FolderOff placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.folderOpen` | The FolderOpen placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.downloadOff` | The DownloadOff placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.uploadOff` | The UploadOff placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.inbox` | The Inbox placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.brokenImage` | The BrokenImage placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.imageUnavailable` | The ImageUnavailable placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.photoLibrary` | The PhotoLibrary placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.musicOff` | The MusicOff placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.videoOff` | The VideoOff placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.personOff` | The PersonOff placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.groupOff` | The GroupOff placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.eventBusy` | The EventBusy placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.emptyCart` | The EmptyCart placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.favorite` | The Favorite placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.batteryAlert` | The BatteryAlert placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.unknownDevice` | The UnknownDevice placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.phoneDisabled` | The PhoneDisabled placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.wrongLocation` | The WrongLocation placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.count` | The Count placeholder image. | TODO |
| **enum `CYLSearchPlaceholderMessage`** | The localized message of a placeholder. | TODO |
| `CYLSearchPlaceholderMessage.empty` | "No data". | TODO |
| `CYLSearchPlaceholderMessage.noResults` | "No matching results". | TODO |
| `CYLSearchPlaceholderMessage.error` | "Something went wrong". | TODO |
| `CYLSearchPlaceholderMessage.network` | "Check your internet connection". | TODO |
| **class `CYLSearchPlaceholderView`** | An image above a message, centered in its bounds: the empty, no-result and error states of a list. | TODO |
| `CYLSearchPlaceholderView.imageView` | The image, 80 × 80 points, tinted with `secondaryLabelColor` (except the colored empty image). | TODO |
| `CYLSearchPlaceholderView.textLabel` | The message, in the body text style with Dynamic Type. | TODO |
| `CYLSearchPlaceholderView.imageName(for:)` | The name of the image of `style` in the resource bundle. | TODO |
| `CYLSearchPlaceholderView.init(kind:)` | A placeholder of a common kind with its built-in image and message. | TODO |
| `CYLSearchPlaceholderView.init(style:message:)` | A built-in image with a built-in message. | TODO |
| `CYLSearchPlaceholderView.init(style:text:)` | A built-in image with your own text. | TODO |
| `CYLSearchPlaceholderView.init(image:message:)` | Your own image with a built-in message. | TODO |
| `CYLSearchPlaceholderView.init(image:text:)` | Your own image and text. | TODO |
| **class `CYLSearchResources`** | Images and localized strings of `CYLSearchViewController.bundle`, the resource bundle of this pod. | TODO |
| `CYLSearchResources.resourceBundle` | The resource bundle, found next to this class's framework or in the main bundle; nil when it is missing. | TODO |
| `CYLSearchResources.image(named:)` | An image of the resource bundle, or nil (logged) when it is missing. | TODO |
| `CYLSearchResources.localizedString(forKey:)` | The text of `key` in the language the app shows (the preferred languages), English when the key has no translation, or the key itself (logged) when it is missing everywhere. | TODO |
| `CYLSearchResources.localizedString(forKey:language:)` | The text of `key` in `language` (for example "zh-Hans"), or in the preferred languages when `language` is nil. | TODO |
| **protocol `CYLSearchResultsDataSource`** | Supplies the results of a `CYLSearchResultsViewController` and configures their cells. | TODO |
| `CYLSearchResultsDataSource.-searchResultsViewController:resultsForQuery:` | The results for `query` (an empty string while nothing is typed). | TODO |
| `CYLSearchResultsDataSource.-searchResultsViewController:configureCell:withResult:` | Shows `result` in `cell`. | TODO |
| `CYLSearchResultsDataSource.-searchResultsViewController:didSelectResult:` | A result was tapped. | TODO |
| **class `CYLSearchResultsViewController`** | A table of search results with a search bar in its navigation item, driven by a `CYLSearchResultsDataSource`. The search bar stays pinned under the title, and the view starts below it, so the bar never covers the list. | TODO |
| `CYLSearchResultsViewController.searchDataSource` | The data source given at creation. | TODO |
| `CYLSearchResultsViewController.searchController` | The search controller installed in the navigation item. | TODO |
| `CYLSearchResultsViewController.searchResults` | The results of the last query. | TODO |
| `CYLSearchResultsViewController.init(searchDataSource:)` | Creates the controller with its data source (plain table style). | TODO |
| `CYLSearchResultsViewController.init(style:)` | Not available: use `init(searchDataSource:)`. | N/A: not available on iOS either (`@available(*, unavailable)`) |
| `CYLSearchResultsViewController.init(nibName:bundle:)` | Not available: use `init(searchDataSource:)`. | N/A: not available on iOS either (`@available(*, unavailable)`) |
| `CYLSearchResultsViewController.init(coder:)` | Not available: use `init(searchDataSource:)`. | N/A: no archives in ArkUI (the state is restored with `decodeRestorableState`) |
| `CYLSearchResultsViewController.viewDidLayoutSubviews()` | Keeps the view below the navigation bar and its search bar after every layout (a search bar never covers a view): on some devices ("iPhone Duo") UIKit places the view 10 pt under the stacked search bar. | TODO |
| `CYLSearchResultsViewController.viewDidLoad()` | — | TODO |
| `CYLSearchResultsViewController.reloadSearchResults()` | Requeries the data source using the current search text and reloads the table. | TODO |
| `CYLSearchResultsViewController.reloadResultsTableView()` | Override to integrate a custom table reload, such as an empty-state provider. | TODO |
| `CYLSearchResultsViewController.updateSearchResults(for:)` | Requeries the results when the search text changes. | TODO |
| `CYLSearchResultsViewController.tableView(_:numberOfRowsInSection:)` | — | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchResultsViewController.tableView(_:cellForRowAt:)` | — | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchResultsViewController.tableView(_:didSelectRowAt:)` | — | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| **class `CYLSearchSuggestionStore`** | The built-in caches: a database, `NSUserDefaults` or a file, behind one class. | `CYLSearchSuggestionStore` |
| `CYLSearchSuggestionStore.policy` | The policy of this store. | `CYLSearchSuggestionStore.policy` |
| `CYLSearchSuggestionStore.name` | Separates the caches of different search screens: the database table key, the defaults key or the file name. | `CYLSearchSuggestionStore.name` |
| `CYLSearchSuggestionStore.maximumCount` | The largest number of queries kept; the oldest go first. 20 by default. | `CYLSearchSuggestionStore.maximumCount` |
| `CYLSearchSuggestionStore.cache(policy:name:)` | Makes the store for `policy` and `name`; nil for `CYLSearchSuggestionCachePolicyNone`. | `CYLSearchSuggestionStore.cache` |
| `CYLSearchSuggestionStore.init(policy:name:)` | Makes the store for `policy` (not `none`) and `name`. | `new CYLSearchSuggestionStore(…)` |
| `CYLSearchSuggestionStore.cachedQueries()` | The cached queries, newest first. | `CYLSearchSuggestionStore.cachedQueries` |
| `CYLSearchSuggestionStore.addQuery(_:)` | Adds `query` at the front, without repeating it. | `CYLSearchSuggestionStore.addQuery` |
| `CYLSearchSuggestionStore.removeQuery(_:)` | Removes `query`. | `CYLSearchSuggestionStore.removeQuery` |
| `CYLSearchSuggestionStore.removeAllQueries()` | Removes every cached query. | `CYLSearchSuggestionStore.removeAllQueries` |
| **enum `CYLSearchSuggestionStyle`** | How the suggestions are shown under the search bar (`CYLSearchView.suggestionStyle`). | TODO |
| `CYLSearchSuggestionStyle.list` | One suggestion per row with its icon, in `suggestionsTableView`. | TODO |
| `CYLSearchSuggestionStyle.tags` | Tags that wrap like words, in `suggestionsTagView` (CollectionViewClassifyMenu's `CYLTagListView`). | TODO |
| **protocol `CYLSearchViewDelegate`** | Events of a `CYLSearchView`: opening and closing, the query, focus, suggestions and the voice button. | TODO |
| `CYLSearchViewDelegate.-searchViewDidShow:` | The search view finished opening (MaterialSearchView `onSearchViewShown`). | TODO |
| `CYLSearchViewDelegate.-searchViewDidClose:` | The search view finished closing (MaterialSearchView `onSearchViewClosed`). | TODO |
| `CYLSearchViewDelegate.-searchView:textDidChange:` | The query changed (`onQueryTextChange`). | TODO |
| `CYLSearchViewDelegate.-searchView:didSubmitText:` | The query was submitted (`onQueryTextSubmit`). Return YES when you handled it and the search view stays open; return NO (or leave this method out) to let the search view close. | TODO |
| `CYLSearchViewDelegate.-searchView:didChangeFocus:` | The field started or stopped editing (lapism `OnFocusChangeListener`). | TODO |
| `CYLSearchViewDelegate.-searchView:didSelectSuggestion:atIndex:` | A suggestion was tapped (MaterialSearchView `setOnItemClickListener`). The field shows it first, and it is submitted when `submitsOnSuggestionSelection` is YES. | TODO |
| `CYLSearchViewDelegate.-searchViewVoiceButtonClicked:` | The voice button was tapped. Start speech recognition and pass the result to `-setQuery:submit:`. | TODO |
| `CYLSearchViewDelegate.-searchViewNavigationButtonClicked:` | The navigation button (the back arrow by default) was tapped. Without this method it closes the search view. | TODO |
| **class `CYLSearchView`** | A search page that opens over its host view: a `CYLSearchBarView` at the top of the safe area, a divider, a list of suggestions filtered as you type, and an optional content view of yours below (MiguelCatalan and lapism `MaterialSearchVi… | TODO |
| `CYLSearchView.delegate` | Receives the events of the search view. | TODO |
| `CYLSearchView.searchBarView` | The search bar at the top. Style it directly (placeholder, colors, icons, keyboard, voice button). | TODO |
| `CYLSearchView.dividerView` | The line under the search bar. | TODO |
| `CYLSearchView.suggestionsTableView` | The table that lists the suggestions. | TODO |
| `CYLSearchView.suggestionsTagView` | The tags that show the suggestions when `suggestionStyle` is `CYLSearchSuggestionStyleTags` (CollectionViewClassifyMenu's `CYLTagListView`). Style it directly: `style`, spacing, rows, colors. | TODO |
| `CYLSearchView.suggestionsFoldControl` | The fold control of the tag suggestions (CollectionViewClassifyMenu's `CYLMenuFoldControl`). An inline chevron as the last tag by default, as in the example's Discover page: tap it to show every row, again to fold. Position `CYLMenuFoldC… | TODO |
| `CYLSearchView.suggestionsFoldedRowCount` | The rows of tag suggestions shown while folded. 2 by default; 0 shows every row. | TODO |
| `CYLSearchView.suggestionStyle` | How the suggestions are shown: a list (`CYLSearchSuggestionStyleList`, the default) or tags (`CYLSearchSuggestionStyleTags`). A tapped tag works like a tapped row. | TODO |
| `CYLSearchView.showsEmptyResultsPlaceholder` | Shows CYLTableViewPlaceHolder's placeholder for `emptyResultsScenario` under the search bar while a non-empty query matches no suggestion, in both suggestion styles. NO by default. | TODO |
| `CYLSearchView.emptyResultsScenario` | The CYLTableViewPlaceHolder scenario of that placeholder. `CYLPlaceholderScenarioNoSearchResults` (an icon, a title and a hint) by default; `CYLPlaceholderScenarioNoContent` shows the plain empty state. | TODO |
| `CYLSearchView.emptyResultsView` | The placeholder shown for empty results (CYLTableViewPlaceHolder's `CYLPlaceholderStackView`), created the first time it is shown; nil before. Style it after it appears, or change `emptyResultsScenario`. | TODO |
| `CYLSearchView.dividerColor` | The color of `dividerView` (lapism `setDividerColor`). `separatorColor` by default; clear hides it. | TODO |
| `CYLSearchView.contentView` | A view of yours shown under the divider, behind the suggestions (lapism `addView`): a results list, a history, anything. Nil by default. | TODO |
| `CYLSearchView.scrimColor` | The color behind the page while it is open (lapism `setScrimColor`). Nil (none) by default; the page itself uses `backgroundColor`, `systemBackgroundColor` by default. | TODO |
| `CYLSearchView.suggestions` | The suggestions to filter as the text changes (MaterialSearchView `setSuggestions`). | TODO |
| `CYLSearchView.suggestionFilter` | Decides whether a suggestion matches the query. Nil uses a case- and diacritic-insensitive "contains" test. An empty query matches nothing unless `showsSuggestionsForEmptyQuery` is YES. | TODO |
| `CYLSearchView.showsSuggestionsForEmptyQuery` | Lists every suggestion while the query is empty. NO by default. | TODO |
| `CYLSearchView.filteredSuggestions` | The suggestions that match the current query, in their original order. | TODO |
| `CYLSearchView.suggestionImage` | The icon before each suggestion (MaterialSearchView `setSuggestionIcon`). `magnifyingglass` by default; nil shows none. | TODO |
| `CYLSearchView.suggestionImageTintColor` | The tint of `suggestionImage`. `secondaryLabelColor` by default. | TODO |
| `CYLSearchView.suggestionBackgroundColor` | The background of the suggestion rows (`setSuggestionBackground`). Nil keeps the page background. | TODO |
| `CYLSearchView.suggestionTextColor` | The color of the suggestion text. `labelColor` by default. | TODO |
| `CYLSearchView.suggestionLineBreakMode` | How a long suggestion is cut (MaterialSearchView `setEllipsize`). `NSLineBreakByWordWrapping` by default (whole text on several lines); `NSLineBreakByTruncatingTail` keeps one line with an ellipsis. | TODO |
| `CYLSearchView.submitsOnSuggestionSelection` | Submits a suggestion as soon as it is tapped (`setSubmitOnClick`). NO by default: the field shows it and the person can edit it. | TODO |
| `CYLSearchView.suggestionCellConfiguration` | Configures each suggestion cell after the defaults (a custom adapter's `getView`). Optional. | TODO |
| `CYLSearchView.suggestionCachePolicy` | Where submitted queries are cached for the suggestion list (`CYLSearchSuggestionCachePolicyDatabase`, a local SQLite database, by default). While the query is empty, the list shows the cached queries, newest first, under a header whose d… | TODO |
| `CYLSearchView.suggestionCacheName` | Separates the caches of different search screens. "CYLSearchView" by default. | TODO |
| `CYLSearchView.suggestionCache` | The cache in use: the built-in store of `suggestionCachePolicy`, or a store of yours (set it after the policy). Nil when the policy is `CYLSearchSuggestionCachePolicyNone`. | TODO |
| `CYLSearchView.suggestionCacheHeaderView` | The header above the cached queries: a title and, at its trailing edge, `clearSuggestionCacheButton`. | TODO |
| `CYLSearchView.suggestionCacheTitleLabel` | The title of `suggestionCacheHeaderView` ("Recent searches"). | TODO |
| `CYLSearchView.clearSuggestionCacheButton` | Clears the whole cache (a trash icon at the top right of the suggestion list). | TODO |
| `CYLSearchView.showsEmptySuggestionsPlaceholder` | Shows CYLTableViewPlaceHolder's placeholder for `emptySuggestionsScenario` while the query is empty and the cache holds nothing, so an open search is never a blank page. YES by default. | TODO |
| `CYLSearchView.emptySuggestionsScenario` | The scenario of that placeholder. `CYLPlaceholderScenarioNoContent` by default. | TODO |
| `CYLSearchView.emptySuggestionsView` | The placeholder shown for an empty cache, created the first time it is shown; nil before. | TODO |
| `CYLSearchView.focusesSearchFieldOnShow` | Focuses the search field when the search opens, which raises the keyboard. YES by default. NO opens the search with the suggestion list (or the empty placeholder) and the keyboard down; the field is focused when the person taps it. | TODO |
| `CYLSearchView.searchOpen` | YES while the search view is open (MaterialSearchView `isSearchOpen`). | TODO |
| `CYLSearchView.animationDuration` | The length of the open and close animations, in seconds (`setAnimationDuration`). 0.25 by default. | TODO |
| `CYLSearchView.closesOnSubmit` | Closes the search view after a submitted query that the delegate did not handle. YES by default. | TODO |
| `CYLSearchView.query` | The current query (lapism `getTextQuery`). | TODO |
| `CYLSearchView.backgroundColor` | The page background (the view itself only shows the scrim). `systemBackgroundColor` by default. | TODO |
| `CYLSearchView.init(frame:)` | — | TODO |
| `CYLSearchView.init(coder:)` | — | N/A: no archives in ArkUI (the state is restored with `decodeRestorableState`) |
| `CYLSearchView.layoutSubviews()` | — | N/A: ArkUI lays a component out from its declaration |
| `CYLSearchView.safeAreaInsetsDidChange()` | — | TODO |
| `CYLSearchView.install(in:)` | Adds the search view over `view` (pinned to its edges) without opening it. `-showSearch` calls it with the key window's root view when the search view has no superview. | TODO |
| `CYLSearchView.showSearch()` | Opens the search view with animation and starts editing (`showSearch`). | TODO |
| `CYLSearchView.showSearch(animated:)` | Opens the search view and starts editing (`showSearch(animate)`). | TODO |
| `CYLSearchView.closeSearch()` | Closes the search view with animation and ends editing (`closeSearch`). | TODO |
| `CYLSearchView.closeSearch(animated:)` | Closes the search view and ends editing. | TODO |
| `CYLSearchView.encodeRestorableState(with:)` | Saves whether the search view is open and its query (`onSaveInstanceState`). UIKit calls it for a view with a `restorationIdentifier` inside a restored view controller. | TODO |
| `CYLSearchView.decodeRestorableState(with:)` | Restores the query and reopens the search view when it was open (`onRestoreInstanceState`). | TODO |
| `CYLSearchView.accessibilityPerformEscape()` | — | TODO |
| `CYLSearchView.attach(to:)` | Makes a bar button item open the search view (`setMenuItem`). | TODO |
| `CYLSearchView.setQuery(_:submit:)` | Sets the query and submits it when `submit` is YES (`setQuery`, `setTextQuery`). | TODO |
| `CYLSearchView.showSuggestions()` | Lists the suggestions that match the current query (`showSuggestions`). | TODO |
| `CYLSearchView.dismissSuggestions()` | Hides the suggestions (`dismissSuggestions`). | TODO |
| `CYLSearchView.clearSuggestionCache()` | Removes every cached query (the delete button of `suggestionCacheHeaderView`) and shows the list again. | TODO |
| `CYLSearchView.searchBarView(_:textDidChange:)` | Filters the suggestions and reports the change. | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.searchBarViewSearchButtonClicked(_:)` | Reports the submitted query and closes unless the delegate handled it. | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.searchBarViewNavigationButtonClicked(_:)` | Reports the navigation button, or closes the search view. | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.searchBarViewVoiceButtonClicked(_:)` | Reports the voice button. | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.searchBarViewCancelButtonClicked(_:)` | Cancel closes the search view. | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.searchBarViewDidBeginEditing(_:)` | Reports focus. | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.searchBarViewDidEndEditing(_:)` | Reports the loss of focus. | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.tableView(_:numberOfRowsInSection:)` | One row per matching suggestion while the suggestions are shown. | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.tableView(_:cellForRowAt:)` | A suggestion row: icon, text, background, then `suggestionCellConfiguration`. | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
| `CYLSearchView.tableView(_:didSelectRowAt:)` | Fills the field with the suggestion, reports it, and submits it when `submitsOnSuggestionSelection` is YES. | N/A: a UIKit protocol conformance (ArkUI reports the same events to the model) |
<!-- harmonyos-api-alignment:end -->

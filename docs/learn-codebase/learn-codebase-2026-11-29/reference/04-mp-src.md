> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Script-generated index of declarations, comments and test names; comments are quoted, not verified.

# WeChat mini program core: files and declarations

> **Generated mechanically** (regex extraction) from the source text read in the 2026-11-29 learn-codebase pass: HEAD `ad32984` plus the uncommitted working-tree changes. It is an index, not a review: a regex can miss or mis-pick a declaration, and "doc" is the comment found above it. Every line number was matched against the working tree with `git grep` on 2026-11-29. A declaration the regex missed is simply absent. Check the file before relying on a line.

| File | Lines |
|:---|---:|
| `CrossPlatform/wechat-miniprogram-cylsearch/package.json` | 37 |
| `CrossPlatform/wechat-miniprogram-cylsearch/project.config.json` | 23 |
| `CrossPlatform/wechat-miniprogram-cylsearch/src/core/CYLSearchBar.js` | 213 |
| `CrossPlatform/wechat-miniprogram-cylsearch/src/core/CYLSearchBarView.js` | 1507 |
| `CrossPlatform/wechat-miniprogram-cylsearch/src/core/CYLSearchController.js` | 355 |
| `CrossPlatform/wechat-miniprogram-cylsearch/src/core/CYLSearchNavigationBar.js` | 170 |
| `CrossPlatform/wechat-miniprogram-cylsearch/src/core/CYLSearchResources.js` | 492 |
| `CrossPlatform/wechat-miniprogram-cylsearch/src/core/CYLSearchTableViewController.js` | 127 |
| `CrossPlatform/wechat-miniprogram-cylsearch/src/core/CYLSearchTagListStyle.js` | 164 |
| `CrossPlatform/wechat-miniprogram-cylsearch/src/core/CYLSearchView.js` | 932 |
| `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search-bar/index.js` | 706 |
| `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search-bar/index.json` | 20 |
| `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search-bar/index.wxml` | 114 |
| `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search-bar/index.wxss` | 89 |
| `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search-navigation-bar/index.js` | 103 |
| `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search-navigation-bar/index.json` | 3 |
| `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search-navigation-bar/index.wxml` | 12 |
| `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search-navigation-bar/index.wxss` | 8 |
| `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search-refresh-button/index.js` | 26 |
| `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search-refresh-button/index.json` | 3 |
| `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search-refresh-button/index.wxml` | 4 |
| `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search-refresh-button/index.wxss` | 2 |
| `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search/index.js` | 752 |
| `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search/index.json` | 25 |
| `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search/index.wxml` | 133 |
| `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search/index.wxss` | 51 |
| `CrossPlatform/wechat-miniprogram-cylsearch/src/index.js` | 26 |

## `CrossPlatform/wechat-miniprogram-cylsearch/src/core/CYLSearchBar.js`

CYLSearchBar.swift for the mini program: the QMUI `UISearchBar` knobs (docs/qmui-search-controller.md) on one object. A mini program has no `UISearchBar`; `<cyl-search-bar>` draws a `CYLSearchBarView`, so this class is the iOS name of the same state: every knob reads and writes the bar view that `<cyl-search-bar>` draws, and nothing is kept twice.

- L12 `class CYLSearchBar` — The bar of a search (iOS `CYLSearchBar`, a `UISearchBar` styled by `CYLSearchBarAppearance`): the placeholder, text and Cancel knobs of QMUI's `QMUISearchBar`, over the `CYLSearchBarView` that `<cyl-search-bar>` draws.
- L28 `get appearanceStyle()` — The style applied to the bar; assigning one applies it.
- L32 `set appearanceStyle(value)`
- L39 `get leadingAccessoryViewMargins()` — The space around the leading accessory (`{ top, left, bottom, right }` in px); `right` is the gap to the field.
- L43 `set leadingAccessoryViewMargins(value)`
- L50 `get trailingAccessoryViewMargins()` — The space around the trailing accessories; `left` is the gap to the field.
- L54 `set trailingAccessoryViewMargins(value)`
- L61 `get centersPlaceholder()` — Whether the magnifier and the placeholder are centered in the field while the bar is not editing and has no text.
- L65 `set centersPlaceholder(value)`
- L72 `get placeholderColor()` — The placeholder's color.
- L76 `set placeholderColor(value)`
- L83 `get textColor()` — The color of the typed text.
- L87 `set textColor(value)`
- L94 `get font()` — The font size of the typed text and of the placeholder, in px.
- L98 `set font(value)`
- L105 `get textFieldMargins()` — The margins added to the field (`{ top, left, bottom, right }` in px).
- L109 `set textFieldMargins(value)`
- L116 `get textFieldMarginsProvider()` — Returns the field's margins for the bar's state, `(bar, active) => insets`; wins over `textFieldMargins`.
- L120 `set textFieldMarginsProvider(value)`
- L127 `get cancelButtonFont()` — The font of the Cancel button's title (`{ size, weight }`).
- L131 `set cancelButtonFont(value)`
- L138 `get cancelButtonMarginsProvider()` — Returns the margins of the Cancel button for the bar's state, `(bar, active) => insets`.
- L142 `set cancelButtonMarginsProvider(value)`
- L149 `get showsLeadingAccessoryView()` — Whether the leading accessory (the slot `leading` of `<cyl-search-bar>`) shows, without animation.
- L153 `set showsLeadingAccessoryView(value)`
- L160 `get showsTrailingAccessoryView()` — Whether the trailing accessories (the slot `trailing`) show, without animation.
- L164 `set showsTrailingAccessoryView(value)`
- L172 `isCancelButtonEnabled(editing)` — Whether the Cancel button is enabled while the field has (`editing`) or has not the focus: always with `alwaysEnablesCancelButton`.
- L179 `applyDefaultAppearance()` — Applies `CYLSearchBarAppearance.default()`.
- L186 `setShowsLeadingAccessoryView(shows, animated = false)` — Shows or hides the leading accessory, sliding it when `animated`; toggling quickly ends in the last request.
- L193 `setShowsTrailingAccessoryView(shows, animated = false)` — Shows or hides the trailing accessories, sliding them when `animated`.
- L200 `textFieldBackgroundImage(color)` — The CSS background of a text field in `color` (iOS draws a resizable image; CSS needs none), or undefined.
- L208 `backgroundImage(color, borderColor)` — The CSS background of a bar: `color` (white by default) with a 1 px bottom border in `borderColor`; undefined when both are missing.

## `CrossPlatform/wechat-miniprogram-cylsearch/src/core/CYLSearchBarView.js`

The search bar module of cyl-search-miniprogram (iOS `CYLSearchBarView.swift`): `CYLSearchBarView` (one search, or several searches side by side with `mode` "multiple", which was `CYLMultiSearchView`), `CYLSearchBarItem` (the appended items, which `<cyl-search-bar>` draws itself; was `CYLSearchBarItemView`), the delegate and the enums. The `<cyl-search-bar>` component draws a `CYLSearchBarView`. M

- L13 `const CYLSearchBarMode = Object.freeze(` — What the bar edits (iOS `CYLSearchBarMode`): one search (the default), or several searches side by side.
- L26 `const CYLSearchBarSearchButtonStyle = Object.freeze(` — How the default search button looks (iOS `CYLSearchBarSearchButtonStyle`): a filled capsule with the magnifier (the default), or the localized "Search" as text.
- L32 `const CYLSearchBarItemCornerRadiusAutomatic = -1;` — `CYLSearchBarItem.cornerRadius` automatic: 10 with a background, square without (iOS `automaticCornerRadius`).
- L35 `const CYLSearchBarItemCornerRadiusCapsule = 1000;` — `CYLSearchBarItem.cornerRadius` capsule (iOS `CYLAnimatedItemCornerRadiusCapsule`).
- L38 `const CYL_SEARCH_ITEM_MINIMUM_SIDE = 36;` — The smallest height of an item's view, in px.
- L43 `function cylSearchItemResolvedCornerRadius(cornerRadius, hasBackground)` — The corner radius an item is drawn with: its own unless automatic, which is 10 with a background and square without.
- L49 `function cylSearchItemResolvedHeight(itemHeight)` — The height of an item's view: its own `itemHeight` when above 0, else the 36 px minimum.
- L54 `const CYL_SEARCH_TRAILING_SPACING = 8;` — The space between two elements of the trailing group (camera, divider, search button), and before the first one, in px.
- L57 `const CYL_SEARCH_TOUCH_WIDTH = 36;` — The touch width of a plain item, in px: widened by the hit area, never by empty room around the glyph.
- L63 `function cylSearchItemHugsContent(style, hasShape, itemHeight)` — Whether an item hugs its content (owner, 2026-11-26): a plain icon or text item (no background, no outline, no custom height) is as wide as its glyph or title; an item with a shape of its own (the icon search capsule) keeps its size. A divider never hugs.
- L74 `function cylSearchTrailingGroupLayout(elements, spacing)` — The layout model of the trailing group: `elements` are `{ style, hasShape, itemHeight, contentWidth }` from the left; the group puts `spacing` before each element and nothing else (no empty room inside an item). Returns each element's `left`, `right`, `width` 
- L91 `function cylSearchButtonVisible(showsSearchButton, isEditingBar, isMultiple)` — Whether a bar draws the default search button: `showsSearchButton`, never for an editing bar or in multiple mode.
- L96 `function cylSearchButtonHasDivider(ownerItemCount)` — Whether a divider precedes the search button: only when an owner's item comes before it.
- L105 `function cylSearchButtonLook(style, customTitle, defaultTitle, hasCustomImage)` — The look of the default search button. Text: a text item with the custom title or the localized default and no fill. Icon: an icon item (the custom image, else the built-in magnifier) as a filled capsule 28 high with 16 side insets (`cylSearchButtonColors` giv
- L120 `function cylSearchButtonTrailingInset(fieldHeight, itemHeight, usualInset, isFilledIcon)` — The trailing inset of the field's content: with the filled icon style as the last element, the pill sits concentric in the field, so the gap at its right equals the gap above and below, (fieldHeight - itemHeight) / 2 (4 for a 36 field and a 28 pill); otherwise
- L125 `function cylSearchButtonTapAction(text)` — What a tap on the search button does with the text: 1 submit it (not empty), 0 only tell the listener (empty text).
- L130 `function cylSearchButtonColors(dark)` — The colors of the filled icon style, inverse of the color mode: black with a white magnifier, white with black in dark.
- L134 `const CYLSearchBarItemStyle = Object.freeze(`
- L143 `const CYLSearchBarStyle = Object.freeze(` — The fixed look of the whole bar (iOS `CYLSearchBarStyle`): the field as configured, or a capsule with an outline.
- L151 `const CYLSearchBarNavigationIcon = Object.freeze(` — The icon of the button before the field (iOS `CYLSearchBarNavigationIcon`).
- L160 `const CYLSearchBarIconPosition = Object.freeze(` — Where the search button sits while the bar is iconified (iOS `CYLSearchBarIconPosition`).
- L169 `const CYLSearchBarExpansionAnimation = Object.freeze(` — How the field opens from the search button (iOS `CYLSearchBarExpansionAnimation`).
- L177 `const CYLSearchBarItemState = Object.freeze(` — The item states for text attributes (iOS `UIControlState`).
- L194 `function cylNavigationFieldStyle()` — The navigation field preset (the Discover look), the one set of values behind `CYLSearchBarView.applyNavigationFieldStyle()` and the component property `navigationFieldStyle`: a bordered capsule (radius 18), a soft shadow (0.06), no magnifier, 16 text; the fil
- L204 `const CYLSearchBarPreset = Object.freeze(` — The looks of a search bar the core ships, one per tab of the example (`CYLSearchBarView.applyPreset(name)`, the component property `preset`): "navigationField" (the Discover look), "pill" (a borderless full capsule with a magnifier), "rounded" (borderless, rad
- L212 `function cylSearchBarPresetSpec(name)`
- L230 `function cylNavigationFieldFill(dark)` — The opaque fill of the navigation field: white in light mode, black in dark mode.
- L239 `function cylSearchShouldFocusOnAppear(focusesOnAppear, isOnSecondLevelOrDeeperPage, iconified, editable)` — Whether the bar takes focus when it appears (iOS `focusIfAppearing`, property `focusesOnAppear`): the option is on, the page is a SECOND-LEVEL OR DEEPER page (`getCurrentPages().length > 1`; a first-level page, a root tab or the first page of the stack, never 
- L247 `function cylSearchIsOnSecondLevelOrDeeperPage(pageCount)` — Whether the page is a second-level or deeper page: more than one page in the page stack (`getCurrentPages().length > 1`); iOS `isOnSecondLevelOrDeeperPage`.
- L251 `class CYLSearchBarAppearance`
- L295 `static default()` — A fresh plain copy of the merged defaults, to change and pass to the bar.
- L302 `static get defaultAppearance()` — The default style as a shared getter (iOS `CYLSearchBarAppearance.defaultAppearance`): a fresh copy each time.
- L309 `copy()` — An independent copy of this style (iOS `copy(with:)`).
- L316 `static styles(values, dark)` — The CSS of a style (`dark` picks the dark field color): the bar, the field, the input and the Cancel button.
- L347 `static textFieldBackgroundCSS(color)` — The CSS background of a text field in `color` (iOS `CYLSearchBar.textFieldBackgroundImage(color:)`): CSS draws it, so it has no bitmap; undefined without a color.
- L355 `static backgroundCSS(color, borderColor)` — The CSS background of a bar (iOS `CYLSearchBar.backgroundImage(color:borderColor:)`): `color` (white by default) with a 1 px bottom border in `borderColor`; undefined when both are missing.
- L366 `function cylInsetsCSS(insets)` — The insets of a state as CSS (`top right bottom left` in px) from `{ top, left, bottom, right }`; empty for nothing.
- L376 `class CYLSearchBarViewDelegate` — The events of a `CYLSearchBarView` (iOS `CYLSearchBarViewDelegate`); every method is optional. The four `...AtIndex` methods are the events of the "multiple" mode.
- L401 `function tell(delegate, method, ...args)` — Calls an optional delegate method.
- L410 `function cylFontWeightName(weight)` — A font weight of the title attributes (a number such as 600, or a name) as CollectionViewClassifyMenu names it (`semibold`); undefined is `semibold`, the iOS default of a bar item's title.
- L419 `const NAMED_IMAGES = { camera: 'camera', mic: 'mic', search: 'magnifyingglass', back: 'chevron_backward' };` — The names `CYLSearchBarItem.item` maps to the package's images.
- L425 `class CYLSearchBarItem` — One element after the text of a `CYLSearchBarView`: a model independent of its view (iOS `CYLSearchBarItem`, like `CYLFlatDesignTabBarItem`). Append it with `CYLSearchBarView.addItem`; `<cyl-search-bar>` draws its `items`.
- L500 `restartAnimation()` — Plays `animationURL` again from the start, as a tap does. Does nothing without an animation or a bar. The same on every platform.
- L510 `get index()` — The item's position in its bar's `items`; -1 when it is in no bar.
- L517 `get currentState()` — The state the item is drawn in.
- L525 `static iconItem(image, title, handler)` — An icon item: the title is what screen readers read (iOS `+iconItemWithImage:title:handler:`).
- L534 `static textItem(title, handler)` — A text item, a "Search" button (iOS `+textItemWithTitle:handler:`).
- L543 `static divider()` — A divider between two items (iOS `+dividerItem`).
- L553 `static item(values)` — An item from plain values, as `<cyl-search-bar items>` takes them (iOS `+itemWithDictionary:`): `style` (`icon`, `divider`, `text`), `title`, `image` (a path, or `camera`, `mic`, `search`, `back`), `selectedImage`, `animationURL`, `gifFirstFrame`, `gifLastFram
- L580 `get drawsShape()` — Whether the item draws a shape of its own (a background or an outline): it keeps its size (iOS item with a background).
- L585 `get hugsContent()` — Whether the item hugs its content in the trailing group (`cylSearchItemHugsContent`).
- L592 `itemDictionary()` — The plain values of the item, the inverse of `CYLSearchBarItem.item` (what `<cyl-search-bar items>` takes).
- L625 `tagButtonProperties(barTint, dark)` — The properties of the item's `<cyl-tag-button>` (CollectionViewClassifyMenu's `CYLTagButton`, the one icon + title + animated icon component; iOS `CYLSearchBarItemButton.reload()`): a text item shows its title (and its icon before it), an icon item only its ic
- L679 `get accessibilityText()` — What screen readers read for the item: its label (or title) and its badge, in one string.
- L688 `setTitleTextAttributes(attributes, state)` — The title attributes for a state (iOS `-setTitleTextAttributes:forState:`).
- L696 `titleTextAttributes(state)` — The title attributes set for a state, or undefined (iOS `-titleTextAttributesForState:`).
- L703 `setBadgeTextAttributes(attributes, state)` — The badge text attributes for a state (iOS `-setBadgeTextAttributes:forState:`).
- L711 `badgeTextAttributes(state)` — The badge text attributes set for a state, or undefined (iOS `-badgeTextAttributesForState:`).
- L723 `class CYLSearchBarView` — A configurable search bar (iOS `CYLSearchBarView`): a rounded field with a magnifier, text and clear button, appended items after the text, a button before the field and an optional Cancel button; with `mode` "multiple", several searches side by side (the comp
- L829 `get searchBarStyle()` — The fixed look of the bar. `bordered` draws the field and its items inside one capsule outline.
- L833 `set searchBarStyle(value)`
- L848 `applyNavigationFieldStyle()` — The look of the input box of a navigation bar, the one every screen uses (iOS `applyNavigationFieldStyle()`): a bordered capsule (corner radius 18) with a soft shadow (opacity 0.06), an opaque white (light) or black (dark) fill, no magnifier, 16 text. Call it 
- L861 `applyPreset(name)` — Applies one of the looks the core ships (`CYLSearchBarPreset`); call it on a new bar before `addItem()`.
- L879 `get isIconified()` — Whether the bar shows only its search button.
- L886 `get selectedItem()` — The first selected item (an `isSelectable` item that is on), or undefined.
- L893 `get selectedIndex()` — The index of `selectedItem`, or -1.
- L900 `addItem(item)` — Appends an item after the others (iOS `-addItem:`).
- L907 `insertItem(item, index)` — Inserts an item at an index, clamped to `items` (iOS `-insertItem:atIndex:`).
- L917 `addItemWithStyle(style, title, image, index = -1, handler = undefined)` — Creates an item and inserts it at an index; a negative or larger index appends it (iOS `-addItemWithStyle:title:image:index:handler:`).
- L927 `removeItem(item)` — Removes an item from the bar (iOS `-removeItem:`).
- L938 `removeAllItems()` — Removes every item (iOS `-removeAllItems`).
- L949 `hasItem(style)` — True when an item of the style was appended (iOS `-hasItemOfStyle:`).
- L959 `get appearanceStyle()` — The style of the field (iOS `appearanceStyle`, one `CYLSearchBarAppearance` for this bar and `CYLSearchBar`); undefined by default (the bar keeps its own look). Assigning plain values of `CYLSearchBarAppearance.default()` maps them onto `font`, `textColor`, `p
- L963 `set appearanceStyle(value)`
- L987 `applyDefaultAppearance()` — Applies `CYLSearchBarAppearance.default()` (iOS `applyDefaultAppearance()`, the same method as `CYLSearchBar`).
- L996 `setItems(dictionaries)` — Replaces the items with the ones the dictionaries describe (iOS `setItems(dictionaries:)`, `CYLSearchBarItem.item`). When only `animationLoops` and `animationSpeed` differ from the last call, the items stay and take the two values, so the animation is not relo
- L1021 `textFieldMarginsFor(active)` — The field's margins in a state (iOS `textFieldMarginsProvider`, else `textFieldMargins`); `active` is true while the bar is searching (editing).
- L1029 `cancelButtonMarginsFor(active)` — The Cancel button's margins in a state (iOS `cancelButtonMarginsProvider`, else `cancelButtonMargins`).
- L1038 `setShowsCancelButton(shows, animated = false)` — Shows or hides Cancel, animated or not (iOS `setShowsCancelButton(_:animated:)`); the component draws the change through `accessoryHandler`.
- L1047 `setShowsLeadingView(shows, animated = false)` — Shows or hides the leading view before the field (iOS `setShowsLeadingView(_:animated:)`). The request is a state flag, so fast toggling ends in the last request.
- L1055 `setShowsTrailingAccessoryViews(shows, animated = false)` — Shows or hides the trailing accessory views of the field (iOS `setShowsTrailingAccessoryViews(_:animated:)`).
- L1063 `setShowsLeadingAccessoryView(shows, animated = false)` — Deprecated: `setShowsLeadingView` (iOS `CYLSearchBar.setShowsLeadingAccessoryView`).
- L1070 `setShowsTrailingAccessoryView(shows, animated = false)` — Deprecated: `setShowsTrailingAccessoryViews` (iOS `CYLSearchBar.setShowsTrailingAccessoryView`).
- L1077 `get showsLeadingAccessoryView()` — Deprecated: `showsLeadingView`.
- L1081 `set showsLeadingAccessoryView(value)`
- L1088 `get showsTrailingAccessoryView()` — Deprecated: `showsTrailingAccessoryViews`.
- L1092 `set showsTrailingAccessoryView(value)`
- L1099 `get hasSearchButton()` — Whether the bar draws the search button now (`showsSearchButton`, not an editing bar, not "multiple" mode).
- L1107 `get searchButtonItem()` — The item the bar draws as its search button (iOS `searchButtonItem`): not in `items`; it follows `searchButtonStyle`, `searchButtonTitle` and `searchButtonImage`, and a change of one of them builds it again. Customize it after setting those.
- L1117 `makeSearchButtonItem()`
- L1134 `searchButtonTapped()` — The search button was tapped: submits the text (`submit()`); an empty text only tells the delegate (`searchBarViewSearchButtonClicked`); then `searchButtonHandler` runs (iOS `searchButtonTapped`).
- L1144 `itemTapped(item)` — An item was tapped: a selectable item toggles, then the delegate and the item's handler are told. A disabled item and a divider ignore taps.
- L1154 `setText(text, submit = false)` — Sets the text and, when `submit` is true, submits it (iOS `-setText:submit:`).
- L1163 `submit()` — Submits the text like the search key; false when the text is empty or the delegate refuses it. In the "multiple" mode the search key completes the search being typed instead (`completeSearch()`).
- L1178 `static editingBar(placeholder, actionTitle)` — An editing bar (iOS `editingBar(placeholder:actionTitle:)`): the search bar's field and look for editing a name (a tag, a title), without the magnifier, with `actionTitle` ("Add", "Done") as its trailing button, which submits the trimmed text through `editingS
- L1195 `submitEditing()` — An editing bar's submit (iOS `submitEditing`): empty text submits nothing; the delegate may refuse it; then `editingSubmitHandler` gets the trimmed text. Returns whether it was submitted.
- L1207 `showKeyboard()` — Focuses the field, which raises the keyboard (the component reads `isKeyboardRequested`).
- L1215 `hideKeyboard()` — Ends editing, which lowers the keyboard.
- L1223 `becomeFirstResponder()` — Focuses the field and returns true (iOS `-becomeFirstResponder`).
- L1231 `resignFirstResponder()` — Ends editing and returns true (iOS `-resignFirstResponder`).
- L1240 `setIconified(iconified, animated = true)` — Opens or closes the field, animated over `animationDuration` when `animated` is true (iOS `-setIconified:animated:`). Opening also starts editing.
- L1257 `encodeRestorableState()` — The state to keep across a restart: the text, whether the bar is iconified and the searches (iOS `-encodeRestorableStateWithCoder:`).
- L1264 `decodeRestorableState(state)` — Restores what `encodeRestorableState` returned (iOS `-decodeRestorableStateWithCoder:`).
- L1279 `get intrinsicContentSize()` — The bar's height: the field and the insets above and below it, or one row of searches (iOS `intrinsicContentSize`).
- L1287 `get searches()` — The searches of the "multiple" mode: the completed ones, then the one being typed (iOS `searches`).
- L1294 `get completedSearches()` — The completed searches of the "multiple" mode, as the component lists them.
- L1301 `get isEditingNewSearch()` — True while a new search is being typed in the "multiple" mode (iOS `isEditingNewSearch`).
- L1308 `beginNewSearch()` — Starts a new search and shows the keyboard (iOS `beginNewSearch()`). Does nothing while a search is being typed.
- L1320 `completeSearch()` — Completes the search being typed: it becomes the selected search, or is dropped when shorter than `minimumTextLength` (iOS `completeSearch()`). True when a search was added.
- L1339 `addSearch(text)` — Adds a completed search without typing it and selects it (iOS `addSearch(_:)`).
- L1354 `selectSearch(index)` — Selects a search, like a tap on it (iOS `selectSearch(at:)`).
- L1364 `removeSearch(index)` — Removes a search, like a tap on its remove button (iOS `removeSearch(at:)`).
- L1379 `textChanged(text)` — The component reports a new text; the delegate is told when it differs (`searchBarViewTextDidChange`, or `searchBarViewTextDidChangeAtIndex` with the index of the search being typed in the "multiple" mode).
- L1394 `editingChanged(editing)` — The component reports that editing started or ended.
- L1408 `shouldBeginEditing()` — Asks the delegate whether editing may start; false reports `searchBarViewDidTapWhileNotEditable` instead.
- L1419 `cancelTapped()` — Cancel was tapped.
- L1433 `navigationTapped()` — The button before the field was tapped.
- L1441 `voiceTapped()` — The microphone was tapped.
- L1448 `get navigationSymbol()` — The image of the button before the field, or undefined when it is hidden.
- L1461 `const CYLSearchBarColors =` — The default colors (iOS `.label`, `.secondaryLabel`, accent), light and dark. The bar's own CSS follows `prefers-color-scheme`; these serve the values CSS cannot reach (an input's `placeholder-style`, the tag buttons' properties), which the component recompute
- L1463 `secondaryLabel(dark) { return dark ? 'rgba(235, 235, 245, 0.6)' : 'rgba(60, 60, 67, 0.6)'; },` — The placeholder and divider color: secondary label, 60% alpha.
- L1465 `label(dark) { return dark ? '#FFFFFF' : '#000000'; },` — The label color: black in light, white in dark.
- L1467 `accent(dark) { return dark ? '#0A84FF' : '#007AFF'; },` — The accent: the selected item's color.
- L1469 `itemTint(selected, dark) { return selected ? CYLSearchBarColors.accent(dark) : CYLSearchBarColors.label(dark); },` — An item's icon and title color with no host tint: the accent while selected, else the label color.

## `CrossPlatform/wechat-miniprogram-cylsearch/src/core/CYLSearchController.js`

CYLSearchController.swift for the mini program: the QMUI `QMUISearchController` shape on top of `CYLSearchView`. The mini program's `<cyl-search>` draws a `CYLSearchView`, which already holds the launch view, the dimming color, the empty view and the result highlight; this class gives them their iOS names and owner, and forwards to the search view (nothing is kept twice).

- L11 `function tell(delegate, method, ...args)` — Calls an optional delegate method.
- L21 `class CYLSearchControllerDelegate` — What a `CYLSearchController` asks of its owner (iOS `CYLSearchControllerDelegate`): the results (called on every text change), and optional life cycle callbacks (`willPresentSearchController`, `didPresentSearchController`, `willDismissSearchController`, `didDi
- L41 `class CYLSearchController` — A search controller with the shape of QMUI's `QMUISearchController` (iOS `CYLSearchController`): a launch view while the text is empty, a dimming color, an empty view with its own text, result highlighting and a history store, over the `CYLSearchView` that `<c
- L59 `makeViewDelegate()` — The search view's events: the controller's own callbacks first, then the page's `viewDelegate`.
- L87 `get searchBar()` — The search bar (a `CYLSearchBar` over the search view's bar view).
- L94 `get highlightsResultMatches()` — Whether the first match of the text is marked in each result row.
- L98 `set highlightsResultMatches(value)`
- L105 `get resultMatchHighlightColor()` — The color of the marked match; undefined is the tint color.
- L109 `set resultMatchHighlightColor(value)`
- L116 `get launchView()` — Whether the page's own view (the slot `launch-view`) shows under the bar while the text is empty.
- L120 `set launchView(value)`
- L127 `get showsSuggestionsLaunchView()` — Whether the built-in launch view (the suggestions as tags over the history) shows while the text is empty.
- L131 `set showsSuggestionsLaunchView(value)`
- L138 `get suggestions()` — The suggestions of the launch view and the list.
- L142 `set suggestions(value)`
- L149 `get dimmingColor()` — The dimming color under the bar while the text is empty (the search view's `scrimColor`).
- L153 `set dimmingColor(value)`
- L160 `get isActive()` — Whether the search is active; assigning changes it without animation.
- L164 `set isActive(value)`
- L171 `get alwaysShowsSearchResultsController()` — Whether the results show while the text is empty.
- L175 `set alwaysShowsSearchResultsController(value)`
- L182 `get supportsSwipeToDismissSearch()` — Whether a swipe from the left edge leaves the search.
- L186 `set supportsSwipeToDismissSearch(value)`
- L193 `get searchBarMaxY()` — The bottom edge of the search bar in px from the top of the page: the status bar and the navigation bar above it.
- L201 `get isEmptyViewShowing()` — Whether the empty view shows.
- L208 `get noResultsText()` — The empty view's text while the text is not empty and the results are empty.
- L212 `set noResultsText(value)`
- L221 `get historyStore()` — Where the submitted queries are kept, newest first and without duplicates (a `CYLSearchSuggestionCache`); undefined keeps none. The built-in store is the search view's, shared through `CYLSearchResources`.
- L225 `set historyStore(value)`
- L233 `static get historyDidChangeNotification()` — The name of the event that the history changed (iOS `CYLSearchController.historyDidChangeNotification`); the page receives it as `searchViewHistoryDidChange`.
- L240 `get isSearchOpen()` — Whether the search is presented (the same as `isActive`).
- L247 `get snapsHeaderSearchBar()` — Whether the header bar of a list snaps fully shown or fully hidden when a drag ends.
- L251 `set snapsHeaderSearchBar(value)`
- L258 `setActive(active, animated = true)` — Starts or ends the search, with animation when `animated`.
- L265 `showSearch(animated = true)` — Presents the search.
- L272 `closeSearch(animated = true)` — Leaves the search.
- L280 `installSearchBar()` — Puts the search bar at the top of the list screen as its header (iOS `installSearchBar(asHeaderOf:)`): the search view draws the list screen, with the bar as the first block of the content (`<cyl-search showsSearchBar>`).
- L289 `showEmptyViewForScenario(scenario)` — Shows one of CYLTableViewPlaceHolder's scenarios as the results' empty view (iOS `showEmptyView(scenario:)`). Does nothing while the text is empty. Returns whether the placeholder shows.
- L300 `hideEmptyView()` — Removes the empty view (the search leaving always does).
- L307 `updateSearchResults(text)` — The text changed (iOS `updateSearchResults(for:)`, also called with the empty text): the delegate gives the results.
- L319 `willPresentSearchController()` — The search is about to be presented.
- L326 `didPresentSearchController()` — The search was presented.
- L333 `willDismissSearchController()` — The search is about to be dismissed.
- L340 `didDismissSearchController()` — The search was dismissed: the empty view is hidden (leaving the search always does) and the next results list is new.
- L350 `gestureRecognizerShouldBegin(startX, deltaX, deltaY)` — Whether the edge swipe may begin (iOS `gestureRecognizerShouldBegin(_:)`): the swipe is on, the search is open, and the touch that moved by (`deltaX`, `deltaY`) went down at `startX` within the edge band.

## `CrossPlatform/wechat-miniprogram-cylsearch/src/core/CYLSearchNavigationBar.js`

CYLSearchNavigationBar.swift for the mini program: the navigation bar that holds the search bar. `<cyl-search-navigation-bar>` draws it (below the status bar, clear of the capsule menu button); this class is its state and the measured widths.

- L14 `const CYL_BACK_SLOT_WIDTH = 32;` — The width of the back button's slot when fully shown (px), and the side inset of the bar without / with it.
- L15 `const CYL_TITLE_INSET_HIDDEN = 16;`
- L16 `const CYL_TITLE_INSET_SHOWN = 6;`
- L22 `function cylBackButtonRequest(currentlyShown, wantsShown, animated)` — What a request to show or hide the back button does: 0 nothing (already as requested), 1 applies at once, 2 applies animated. Asking for the state the button has is a no-op, so a push and an onShow that both ask do not animate twice.
- L28 `function cylBackButtonProgress(progress)` — The progress (0 hidden, 1 shown) clamped to its range; NaN is 0.
- L34 `function cylBackSlotWidth(progress)` — The width of the back button's slot at `progress`.
- L39 `function cylTitleLeadingInset(progress)` — The leading inset of the bar at `progress`: 16 hidden, 6 shown.
- L48 `function cylBarWidth(containerWidth, progress, trailing = CYL_TITLE_INSET_HIDDEN)` — The width the search bar gets in a title bar of `containerWidth` (inside the safe area, `trailing` px kept free for the menu button) at `progress`: the whole width at 0, narrower by the back slot and the smaller inset at 1. The component lays the bar out with 
- L56 `function cylFirstLevelTapAction(pushesOnTap, backButtonShown)` — What a tap on the bar does: 0 the bar edits as usual, 1 the tap is a push (back button in, then `firstleveltap` and the navigation), 2 nothing (a first-level bar whose back button is already shown: the push is under way).
- L62 `function cylBackButtonWantedFor(isRootPage)` — Whether the back button belongs to the page that is shown: the first-level (root) page has none, a pushed page has one.
- L66 `class CYLSearchNavigationBar`
- L70 `static get standardHeight()` — The height of a navigation bar below the status bar, 44 px (WeChat measures its own: `cylNavigationMetrics()`).
- L95 `showBackButton(animated = true)` — Brings the back button in on the left; the bar narrows to make room. Asking twice is a no-op.
- L102 `hideBackButton(animated = true)` — Takes the back button out; the bar grows back to its full width.
- L106 `setBackButton(shown, animated)`
- L117 `firstLevelTapped()` — The tap of a first-level bar: back button in, then `onFirstLevelTap`; nothing for another bar or a push under way.
- L126 `syncBackButton(isRootPage, animated)` — Keeps the back button in step with the page that is shown (the component calls it from the page's onShow).
- L134 `static holding(searchBarView, showsBackButton = false)` — A navigation bar holding `searchBarView` as its title, set up for it (a 36 px field, no side inset of its own); with `showsBackButton` it has a back button on its leading side (iOS `holding(_:)` and `holding(_:showsBackButton:)`).
- L146 `widths(window, menuButton)` — The widths of the bar, from the window and menu button rectangles (leading, trailing, back button, the search bar's).
- L154 `navigationBar()` — The back button was tapped (iOS `navigationBar(_:shouldPop:)`): `backHandler` runs and the bar keeps its items, so it returns false.

## `CrossPlatform/wechat-miniprogram-cylsearch/src/core/CYLSearchResources.js`

The resources module of cyl-search-miniprogram (iOS `CYLSearchResources.swift`): the package's images and localized strings, the suggestion cache (the `CYLSearchSuggestionCache` protocol, `CYLSearchSuggestionCachePolicy` and the private default store), the format of the core's strings, the navigation bar metrics of a "navigationStyle": "custom" page, and the few platform names the models were writ

- L11 `const STRINGS =` — Generated from harmonyos/cylsearch/src/main/resources/*/element/string.json (the Android strings). Do not edit.
- L110 `const historyObservers = new Set();` — The observers of `CYLSearchResources.historyDidChangeNotification`.
- L112 `class CYLSearchResources`
- L117 `static get historyDidChangeNotification()` — The name of the event that the default suggestion stores fire when a query is added or removed (iOS `historyDidChangeNotification`, "CYLSearchSuggestionStoreDidChange").
- L125 `static observeHistory(handler)` — Calls `handler(store)` every time a default suggestion store changed (the observer of `historyDidChangeNotification`); returns the function that removes the observer.
- L135 `static suggestionCache(policy, name, storage)` — The built-in store of submitted queries of a policy and a name (iOS `suggestionCache(policy:name:)`), newest first and without duplicates; undefined for the policy `none`. `storage` is `{ getSync(key), setSync(key, value) }` (wx storage by default).
- L143 `static imageNamed(name)` — The path of a bundled image ("camera", "mic", "search", "back", "clear", "submit", "trash", "refresh"), or undefined (iOS `+imageNamed:`), relative to a component folder of this package.
- L151 `static localizedString(context, key, language)` — The string for `key` ("search.placeholder") in `language` ("zh-Hans", "ja"…), the system language by default, else English, else the key (iOS `+localizedString:`). The first argument keeps the HarmonyOS signature.
- L161 `static languageFor(language)` — The table name for a language tag: "zh_CN", "zh-Hans-CN" give "zh-Hans"; "zh_TW", "zh-HK" give "zh-Hant".
- L180 `static formatString(format, args)` — Fills a format of the core's strings, which keep the iOS and Android forms: %@, %d, %ld, %lu, %s and the positional %1$d ("Search %1$d of %2$d").
- L203 `function cylFormatString(format, args)` — Fills the formats of the core's strings: %@, %d, %ld, %lu, %s and the positional %1$d / %1$lu.
- L213 `const SYMBOLS =` — System symbols of the HarmonyOS models -> the package's images (src/images).
- L219 `const COLORS = { comp_divider: '#e5e5ea', comp_background_primary: '#ffffff' };` — System colors -> CSS colors (light appearance; the components follow the page's colors).
- L239 `function cylAbsoluteImagePath(componentPath, image)` — An image path of this package (relative to a component of it, like `../images/search.svg`) as an absolute path of the mini program, from the component's own path (`this.is`, like `components/cyl-search-bar/index`). A component that is handed the path (the cyl-
- L253 `const CYL_NAVIGATION_FIELD_HEIGHT = 36;` — The height of the search field embedded in a navigation bar (docs/animated-icon-component.md, "The search bar is always in a navigation bar"): a standard bar is 44 pt, the field 36.
- L259 `function cylNavigationMetricsFrom(window, menuButton)` — Where a bar that takes the navigation bar's place goes on a "navigationStyle": "custom" page, from the window and menu button rectangles: below the status bar, as high as the navigation bar, clear of WeChat's menu button.
- L276 `const CYL_NAVIGATION_BACK_WIDTH = 24;` — The space a back button takes in the navigation bar (its 32 wide box, 10 pulled into the leading margin, 2 gap).
- L284 `function cylNavigationBarWidthsFrom(window, menuButton, showsBack)` — The widths in a navigation bar, from the window and menu button rectangles: the 16 leading margin, the trailing inset that clears the capsule menu button (16 without a rectangle), the back button's space (when shown) and the width left for the search bar. The 
- L295 `function cylNavigationMetrics()` — The navigation bar metrics of this device (see `cylNavigationMetricsFrom`).
- L310 `const CYLSearchSuggestionCachePolicy = Object.freeze(` — Where the suggestion cache keeps the submitted queries (iOS `CYLSearchSuggestionCachePolicy`).
- L321 `class CYLSearchSuggestionCache` — A suggestion cache (iOS `CYLSearchSuggestionCache` protocol): give `CYLSearchView.suggestionCache` an object with `cachedQueries()`, `addQuery(query)`, `removeQuery(query)` and `removeAllQueries()` to keep the queries elsewhere.
- L325 `cachedQueries()` — The cached queries, newest first.
- L332 `addQuery() {}` — Adds a query, or moves it to the front.
- L337 `removeQuery() {}` — Removes a query.
- L342 `removeAllQueries() {}` — Removes every query.
- L349 `class CYLSearchSuggestionDefaultStore extends CYLSearchSuggestionCache` — The default store (iOS: the private store behind `suggestionCachePolicy` / `suggestionCacheName`): newest first, at most `maximumCount` queries, one per policy and name. `database` keeps a storage key of its own, `userDefaults` one shared key holding every cac
- L362 `key()`
- L366 `filePath()`
- L370 `cachedQueries()`
- L389 `addQuery(query)`
- L397 `removeQuery(query)`
- L401 `removeAllQueries()`
- L405 `write(queries)`
- L425 `function parseQueries(value)` — A stored list: an array, or the JSON text earlier versions wrote; only strings are kept.
- L441 `function cylSuggestionCache(policy, name, storage)` — The default cache for a policy and a name, or undefined for `none`; `CYLSearchView` creates it from `suggestionCachePolicy` and `suggestionCacheName`.
- L448 `const Curve = Object.freeze({ EaseIn: 'ease-in', EaseOut: 'ease-out', EaseInOut: 'ease-in-out', Linear: 'linear' });` — The animation curves the models name (ArkUI `Curve`); the components map them to CSS timing functions.
- L454 `function animateTo(options, changes)` — Applies `changes` at once (the components animate the result with CSS transitions of `options.duration` ms) and calls `options.onFinish` when that time is over, like ArkUI `animateTo`.
- L462 `const InputType = Object.freeze({ Normal: 'text', Number: 'number', PhoneNumber: 'number', Email: 'text', Password: 'safe-password' });` — The `<input>` type of the field (ArkUI `InputType`): the component maps it to the `type` attribute.
- L467 `const EnterKeyType = Object.freeze({ Search: 'search', Done: 'done', Go: 'go', Next: 'next', Send: 'send' });` — The return key (ArkUI `EnterKeyType`): the component maps it to `confirm-type`.
- L472 `const TextOverflow = Object.freeze({ None: 'clip', Clip: 'clip', Ellipsis: 'ellipsis' });` — How a long text ends (ArkUI `TextOverflow`): the component maps it to `text-overflow`.

## `CrossPlatform/wechat-miniprogram-cylsearch/src/core/CYLSearchTableViewController.js`

CYLSearchTableViewController.swift for the mini program: a list screen that shows the search bar as its header, with the `CYLSearchController` that drives it (QMUI's `QMUICommonTableViewController (Search)`). `<cyl-search showsSearchBar>` draws it; this class owns the state and the hooks of a page.

- L13 `class CYLSearchTableViewController` — A list screen that can show a search bar as its header (iOS `CYLSearchTableViewController`). Set `showsSearchBar` and call `viewDidLoad()` once the page is ready (the controller and the bar are created or removed then); configure the bar in `setUpSearchBar()`;
- L28 `get searchController()` — The search controller, undefined while `showsSearchBar` is off or the view is not loaded.
- L35 `get searchBar()` — The search bar that is the list's header, undefined while `showsSearchBar` is off or the view is not loaded.
- L42 `get hidesSearchBarWhenEmptyViewShowing()` — Whether the search bar leaves the header while an empty view shows and returns when it is hidden (default false).
- L46 `set hidesSearchBarWhenEmptyViewShowing(value)`
- L54 `get hidesSearchBarInitially()` — Whether the list is scrolled so that the search bar is out of sight when it is first shown (default false).
- L58 `set hidesSearchBarInitially(value)`
- L66 `get isEmptyViewShowing()` — Whether the empty view is on screen.
- L73 `viewDidLoad()` — The view is loaded: creates the search controller and the bar when `showsSearchBar` is on, removes them when it is off.
- L95 `setUpSearchBar() {}` — Called once after the controller and the bar are created and before the bar becomes the header: set the bar's style, margins and accessories here. Does nothing by default.
- L101 `searchControllerUpdateResultsFor() {}` — Called with every text change of the search, also with "" (iOS `searchController(_:updateResultsFor:)`). Does nothing by default.
- L107 `showEmptyView(text, detailText)` — Shows an empty view with a title and an optional detail over the list; with `hidesSearchBarWhenEmptyViewShowing` the bar leaves the header.
- L115 `showEmptyViewForScenario(scenario)` — Shows one of CYLTableViewPlaceHolder's scenarios over the list (iOS `showEmptyView(scenario:)`).
- L122 `hideEmptyView()` — Removes the empty view; with `hidesSearchBarWhenEmptyViewShowing` the bar returns to the header.

## `CrossPlatform/wechat-miniprogram-cylsearch/src/core/CYLSearchTagListStyle.js`

CYLSearchTagListStyle.swift and CYLSearchTagListHeader.swift for the mini program: the default look of the tag lists that sit with a search bar, as the style of CollectionViewClassifyMenu's `<cyl-tag-list configuration>` (the keys are those of iOS `CYLMenuStyle`; sizes in px). The style is a plain object that these functions change in place.

- L11 `const CYL_ANIMATED_ITEM_CORNER_RADIUS_CAPSULE = 1000;` — The capsule corner radius of CYLAnimatedItem (`CYLAnimatedItemCornerRadiusCapsule`): pass it, never the literal.
- L16 `class CYLSearchTagListHeader` — The refresh icon and text of a tag list's section header (iOS `CYLSearchTagListHeader`).
- L20 `static get refreshImage()` — The refresh icon (`images/refresh.svg` of this package): the icon is the default, not a text button.
- L27 `static get refreshAccessibilityLabel()` — The label of the refresh icon for screen readers, in the language of the app ("Refresh", 更新, 刷新, 重新整理).
- L34 `static applyRefreshIcon(configuration)` — Sets the refresh icon as the icon of the header More button of `configuration.style`, in place of the three dots.
- L47 `class CYLSearchTagListStyle` — The search bar core's default style of a tag list, the look of the iOS example's recent searches (iOS `CYLSearchTagListStyle`).
- L51 `static get tagCornerRadius()` — The corner radius of every tag, in px; the default is the capsule (1000), 0 is square corners.
- L55 `static set tagCornerRadius(value)`
- L62 `static get tagBackgroundStyle()` — The background of every tag: "flat" (the tag's own colors, default) or "liquidGlass" (the glass material).
- L66 `static set tagBackgroundStyle(value)`
- L73 `static get styleCustomizer()` — Called with the style after the defaults are set, to change any value of it; undefined by default.
- L77 `static set styleCustomizer(value)`
- L86 `static applyDefaults(style, dark = false)` — Sets the defaults on `style`: white tags with a 1 px border and `tagCornerRadius`, 17 px text, 36 px high, 12 px apart, a 16 px section inset and a bold 20 px section header, then calls `styleCustomizer`. `dark` picks the dark colors. Returns `style`.
- L122 `static applyDefaultStyle(configuration, dark = false)` — Sets the defaults on a copy of the style of `configuration` (a tag list configuration; its other values stay), and the refresh icon of its header (`CYLSearchTagListHeader`).
- L132 `static applyGrid(columns, configuration, dark = false)` — Turns `configuration` into a grid of `columns` plain titles per row (17 px medium text, 36 px rows 16 px apart, no image), the look of the iOS example's discover topics, with the section header and the refresh icon as in `applyDefaultStyle`; 0 or less leaves i
- L158 `static applyBackgroundStyle(name, configuration)` — Sets the background of every tag of `configuration` by name: "liquidGlass" (case-insensitive) is the glass material, anything else, "" or "flat" is flat; the other style values stay.

## `CrossPlatform/wechat-miniprogram-cylsearch/src/core/CYLSearchView.js`

The search view module of cyl-search-miniprogram (iOS `CYLSearchView.swift`): `CYLSearchView` (the search page: the bar, the suggestions or the results of `resultsDataSource`, the empty placeholders, the pull-to-refresh of the results), its delegate and data source, `CYLSearchSuggestionStyle`, the fold control of the tag suggestions, and the playback strategy of the animated placeholders. The `<cy

- L15 `const CYLSearchSuggestionStyle = Object.freeze(` — How the suggestions are shown under the search bar (iOS `CYLSearchSuggestionStyle`): one per row, or tags.
- L23 `const CYLMenuFoldControlPosition = Object.freeze(` — Where the fold control of the tag suggestions sits (CollectionViewClassifyMenu's `CYLMenuFoldControlPosition`).
- L31 `const CYLMenuFoldControlContent = Object.freeze(` — What the fold control shows (CollectionViewClassifyMenu's `CYLMenuFoldControlContent`): a chevron (the default), a title, or both.
- L40 `class CYLMenuFoldControl` — The fold control of the tag suggestions (CollectionViewClassifyMenu's `CYLMenuFoldControl`).
- L54 `class CYLSearchViewDelegate` — The events of a `CYLSearchView` (iOS `CYLSearchViewDelegate`); every method is optional. `searchViewDidSubmitText` returns true when it handled the query and the search view stays open.
- L79 `class CYLSearchViewDataSource` — Supplies the results of a `CYLSearchView` and describes their rows (iOS `CYLSearchViewDataSource`, was `CYLSearchResultsDataSource`): `searchViewResultsForQuery(searchView, query)` returns an array; `searchViewConfigureResultCell(searchView, cell, result)` (op
- L90 `function tell(delegate, method, ...args)` — Calls an optional delegate method.
- L96 `function refreshTarget(target)` — The refresh state of a target of the static refresh API that is not a search view (a component or a model).
- L111 `class CYLSearchView` — A search page that opens over its host (iOS `CYLSearchView`): a `CYLSearchBarView` at the top, a divider, then either the results of `resultsDataSource` (while it is set and the query is not empty) or the suggestions as a list or as tags, the cached queries fi
- L213 `get dimmingColor()` — Deprecated: the scrim (iOS `dimmingColor`, which forwards to `scrimColor`).
- L217 `set dimmingColor(value)`
- L224 `get highlightsMatches()` — Deprecated: `highlightsResultMatches` (the earlier name of this port).
- L228 `set highlightsMatches(value)`
- L235 `get suggestions()` — The suggestions to filter as the text changes.
- L239 `set suggestions(value)`
- L247 `get showsSuggestionsForEmptyQuery()` — Lists every suggestion while the query is empty. False by default.
- L251 `set showsSuggestionsForEmptyQuery(value)`
- L260 `get suggestionCachePolicy()` — Where submitted queries are cached for the suggestion list (`CYLSearchSuggestionCachePolicy`). `database` by default; it replaces `suggestionCache` with the default store of that policy.
- L264 `set suggestionCachePolicy(value)`
- L273 `get suggestionCacheName()` — Separates the caches of different search screens. "CYLSearchView" by default.
- L277 `set suggestionCacheName(value)`
- L286 `get isSearchOpen()` — True while the search view is open (iOS `isSearchOpen`).
- L293 `get query()` — The current query.
- L297 `set query(value)`
- L304 `get suggestionsVisible()` — True while the suggestions are listed (`showSuggestions` / `dismissSuggestions`).
- L311 `get searchResults()` — The results of the current query from `resultsDataSource` (iOS `searchResults`, read-only).
- L319 `get showsResults()` — True while the results take the place of the suggestions: `resultsDataSource` is set and the query is not empty (or `showsResultsForEmptyQuery` is true).
- L327 `get resultsHeaderTitle()` — The text over the results while they show (iOS `resultsHeaderTitleProvider`), or undefined: no provider, no results shown, or the provider returned nothing or an empty text.
- L337 `get suggestionCacheFooter()` — The title of the clear button under the cached queries, or undefined while there is none or no cached query shows (iOS `suggestionCacheFooterTitle`).
- L347 `setSnapsHeader(snaps)` — Turns the snapping of the header search bar on or off (iOS `setSnapsHeader(_:for:in:)`, which names the header and its table view; the mini program's header bar is the one of `<cyl-search showsSearchBar>`, so only the flag is left): a bar half scrolled out set
- L355 `get showsEmptyResults()` — True while the empty results placeholder shows: it is on, and the results (or, without results, the suggestions of a non-empty query) are empty.
- L364 `get showsEmptySuggestions()` — True while the query is empty, there is nothing to list and the empty suggestions placeholder is on.
- L372 `get isRefreshing()` — True while the results are refreshing (iOS `isRefreshing`).
- L380 `showSearch(animated = true, completion = undefined)` — Opens the search view and, with `focusesSearchFieldOnShow`, starts editing (iOS `showSearch(animated:)`); `completion` runs once it is open, also when it already was.
- L401 `setActive(active, animated = true)` — Starts or ends the search (iOS `setActive(_:animated:)`): `showSearch` or `closeSearch`.
- L409 `get isActive()` — True while the search is active (iOS `isActive`), as `isSearchOpen`.
- L417 `closeSearch(animated = true, completion = undefined)` — Closes the search view and ends editing (iOS `closeSearch(animated:completion:)`); `completion` runs once it is closed, also when it was not open.
- L436 `encodeRestorableState()` — The state to keep across a restart: whether the search view is open and its query.
- L443 `decodeRestorableState(state)` — Restores the query and reopens the search view when it was open.
- L452 `accessibilityPerformEscape()` — The back gesture or key: closes an open search view and returns true (iOS `-accessibilityPerformEscape`).
- L461 `attachToMenuItem()` — A tap handler that opens the search view, for a menu item or a button (iOS `-attachToBarButtonItem:`).
- L468 `setQuery(text, submit = false)` — Sets the query and submits it when `submit` is true (iOS `-setQuery:submit:`).
- L479 `textChanged(text)` — The component reports the text of the field.
- L491 `focusChanged(focused)` — The component reports that the field started or stopped editing. Nothing below the search bar changes.
- L498 `showSuggestions()` — Lists the suggestions that match the current query.
- L506 `dismissSuggestions()` — Hides the suggestions.
- L513 `clearSuggestionCache()` — Clears the whole cache, as the trash button of the header does (iOS `-clearSuggestionCache`).
- L522 `get history()` — The submitted queries, newest first, no duplicates (iOS `historyStore.cachedQueries()`): the suggestion cache.
- L529 `get historyStore()` — Where submitted queries are kept (iOS `historyStore`): `suggestionCache`.
- L533 `set historyStore(value)`
- L541 `clearHistory()` — Clears the history (iOS `historyStore.removeAllQueries()`) and tells the delegate.
- L547 `historyChanged()` — Tells the delegate that the history changed (iOS `historyDidChangeNotification`), so a launch view that stays on screen reads it again.
- L556 `showEmptyView(text, detailText, buttonTitle, buttonAction)` — Shows the empty view with its own text (iOS `showEmptyView(text:detailText:buttonTitle:buttonAction:)`). It is not shown while the query is empty while searching (iOS E8, it would sit on the dimming); when the search is not active it takes the content's place 
- L567 `hideEmptyView()` — Hides the empty view (iOS `hideEmptyView()`).
- L575 `applyNoResultsText()` — `noResultsText` (iOS `CYLSearchController.noResultsText`): the empty view shows while the query is not empty and the results are empty, and goes with them; an empty view the page showed itself is never replaced or hidden by it.
- L591 `get isEmptyViewShowing()` — True while the empty view shows (iOS `isEmptyViewShowing`).
- L598 `get showsLaunch()` — True while the launch view shows: it is on, the query is empty and no results show (iOS `launchView`).
- L605 `get showsDimming()` — True while the scrim shows under the bar: a scrim color, an empty query, no launch view (iOS `scrimColor`).
- L613 `get hidesHeaderBar()` — True while the bar of the list screen is hidden: the content's empty view shows and the bar hides with it (iOS `hidesSearchBarWhenEmptyViewShowing`).
- L621 `suggestionSelected(suggestion, index)` — A suggestion was tapped: the field shows it, the delegate is told, and it is submitted with `submitsOnSuggestionSelection`.
- L636 `reloadResults()` — Queries `resultsDataSource` for the current query and reloads the results (iOS `reloadResults()`). Without a data source, or while the results do not show, the results are empty.
- L652 `resultCell(result)` — The row of a result: `{ title, subtitle, accessibilityLabel }`, `title` being the result's text unless `resultsDataSource.searchViewConfigureResultCell` fills it.
- L663 `resultSelected(result, index)` — A result was tapped: the delegate is told (iOS `searchView(_:didSelectResult:)`).
- L671 `beginRefreshing()` — Starts refreshing the results, as a pull does: `refreshHandler` is called (iOS `beginRefreshing()`). Does nothing without a handler or while refreshing.
- L680 `endRefreshing()` — Ends refreshing (iOS `endRefreshing()`); call it on every completion path of `refreshHandler`.
- L688 `static setRefreshHandler(handler, target)` — Sets the pull-to-refresh handler of another target (iOS `static setRefreshHandler(_:for:)`): a `<cyl-search>` instance (its `setRefreshHandler`) or a `CYLSearchView`; undefined removes it.
- L697 `static beginRefreshing(target)` — Starts refreshing that target (iOS `static beginRefreshing(in:)`).
- L704 `static endRefreshing(target)` — Ends refreshing that target (iOS `static endRefreshing(in:)`).
- L711 `static isRefreshing(target)` — Whether that target is refreshing (iOS `static isRefreshing(in:)`).
- L716 `submitted()`
- L729 `matches(suggestion, query)`
- L737 `refilter()` — Recomputes `filteredSuggestions`: the cached queries first, then `suggestions`, without repeats.
- L763 `suggestionTagConfiguration(dark = false)` — The suggestion tags as the configuration of CollectionViewClassifyMenu's tag list (`<cyl-tag-list>`, the mini program's `CYLTagListView`): one section without a header, no selection, folded to `suggestionsFoldedRowCount` rows with the fold control of `suggesti
- L790 `function cylFold(value)` — A text with case and diacritics folded away (iOS `range(of:options: [.caseInsensitive, .diacriticInsensitive])`): `folded` is the folded text and `map[i]` the `[start, end)` of the original characters that produced `folded[i]`, so a match in the folded text ma
- L809 `function cylHighlightParts(title, query)` — A result's title split around the first match of the query, ignoring case and diacritics like the suggestion filter (QMUI demo: the match in the tint color): `[{ text, highlighted }]`, the text as it was written; the whole title when the query is empty or does
- L831 `function cylSnapHeaderOffset(offset, headerHeight, velocity = 0)` — Where a header search bar settles when a drag ends inside its band (iOS `snapsHeaderSearchBar`, #1160): fully hidden (the header height) from half of it on, else fully shown (0); a fling decides by its direction (`velocity` in px per ms, positive scrolls the c
- L841 `function cylSwipeShouldDismiss(startX, deltaX, width, velocity = 0, edge = 24)` — Whether a swipe from the left edge ends the search (iOS `supportsSwipeToDismissSearch`): it began within `edge` px of the edge, and moved right more than a quarter of the `width` or fast to the right (iOS: velocity above 0).
- L850 `function cylEdgeSwipeBegins(startX, deltaX, deltaY, edge = 24, slop = 10)` — Whether a touch that moved by (`deltaX`, `deltaY`) has begun the edge swipe (iOS `CYLSearchEdgeSwipe`, the touch itself): it went down within `edge` px of the left edge and moved right past `slop` px, more than up or down.
- L861 `function cylFoldTags(widths, available, spacing, chevronWidth, rows)` — Deprecated: the suggestion tags are CollectionViewClassifyMenu's tag list, which folds them itself (`defaultVisibleRows`, its fold control last); nothing in this package calls this any more. How many tags fit in `rows` rows of width `available` when the fold c
- L886 `const CYLSearchAnimationSpeed = Object.freeze({ minimum: 0.25, maximum: 3, step: 0.25, standard: 1 });` — The speeds the playback slider of the animated placeholders offers, as multiples of the animation's own speed.
- L891 `function cylClampAnimationSpeed(speed)` — Clamps a speed to the slider's range and rounds it to its step; anything that is not a number is 1.
- L901 `function cylAnimationPlaybackDescription(speed, loops)` — What a screen reader says for the playback strategy, e.g. "1.5x, looping" or "0.25x, plays once".
- L910 `function cylSearchViewIgnoresEmptySubmit(text)` — Whether the search PAGE ignores a `submit` of its bar for this text: empty (or blank) text, as sent by a tap on the default search button, submits nothing, records nothing, closes nothing and keeps the keyboard, like the confirm key. The bar itself still fires

## `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search-bar/index.js`

- L4 `const text = (key) => CYLSearchResources.localizedString(undefined, key);`
- L7 `function defaultItemTint()` — The items' default tint, the label color of the color mode (iOS `UIColor.label`).

## `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search-bar/index.wxml`

The search bar (iOS CYLSearchBarView). mode "multiple": the completed searches in a row (the selected one underlined,

## `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search-navigation-bar/index.wxml`

The navigation bar: status bar space, then the back button (optional) and the search bar in the slot.

## `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search-refresh-button/index.wxml`

The refresh icon of a tag list header; the label is read by screen readers.

## `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search/index.js`

- L4 `const text = (key) => CYLSearchResources.localizedString(undefined, key);`

## `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search/index.wxml`

The empty view of the page's own text (iOS showEmptyView, noResultsText): one template for the content and the layer.

## `CrossPlatform/wechat-miniprogram-cylsearch/src/index.js`

The package entry of cyl-search-miniprogram: require('cyl-search-miniprogram') resolves to the index.js of the built miniprogram_npm folder (the "miniprogram" folder, src/), and Node loads it through package.json "main". It exports the three core modules, which keep the iOS names (CYLSearchBarView.swift, CYLSearchView.swift, CYLSearchResources.swift). The two components, <cyl-search-bar> and <cyl-

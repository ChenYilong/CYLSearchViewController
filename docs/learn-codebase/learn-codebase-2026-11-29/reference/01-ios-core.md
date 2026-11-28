> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Script-generated index of declarations, comments and test names; comments are quoted, not verified.

# iOS core: files and declarations

> **Generated mechanically** (regex extraction) from the source text read in the 2026-11-29 learn-codebase pass: HEAD `ad32984` plus the uncommitted working-tree changes. It is an index, not a review: a regex can miss or mis-pick a declaration, and "doc" is the comment found above it. Every line number was matched against the working tree with `git grep` on 2026-11-29. A declaration the regex missed is simply absent. Check the file before relying on a line.

| File | Lines |
|:---|---:|
| `CYLSearchViewController.podspec` | 41 |
| `Podfile` | 39 |
| `Sources/CYLSearchBar/CYLSearchBarAppearance.swift` | 286 |
| `Sources/CYLSearchBar/CYLSearchBarView.swift` | 3384 |
| `Sources/CYLSearchBar/CYLSearchController.swift` | 791 |
| `Sources/CYLSearchBar/CYLSearchHeaderSnapper.swift` | 156 |
| `Sources/CYLSearchBar/CYLSearchNavigationBar.swift` | 201 |
| `Sources/CYLSearchBar/CYLSearchPresentationState.swift` | 274 |
| `Sources/CYLSearchBar/CYLSearchResources.swift` | 348 |
| `Sources/CYLSearchBar/CYLSearchResultsComponent.swift` | 344 |
| `Sources/CYLSearchBar/CYLSearchSuggestionArea.swift` | 313 |
| `Sources/CYLSearchBar/CYLSearchTableViewController.swift` | 204 |
| `Sources/CYLSearchBar/CYLSearchTagListHeader.swift` | 44 |
| `Sources/CYLSearchBar/CYLSearchTagListStyle.swift` | 140 |
| `Sources/CYLSearchBar/CYLSearchView.swift` | 1323 |

## `Sources/CYLSearchBar/CYLSearchBarAppearance.swift`

Tencent is pleased to support the open source community by making QMUI_iOS available. Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved. Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://opensource.org/licenses/MIT Unless required by applicable law or agreed t

- L30 `public final class CYLSearchBarAppearance: NSObject, NSCopying` — The style of a `CYLSearchBar`: the values QMUI reads from its configuration template for `qmui_styledAsQMthe system search bar` (`SearchBarFont`, `SearchBarTextColor`, `SearchBarPlaceholderColor`, `SearchBarTintColor`, the icons, the field background and borde
- L37 `@objc public var font: UIFont?` — The font of the text and of the placeholder (QMUI `SearchBarFont`); `nil` keeps UIKit's.
- L42 `@objc public var textColor: UIColor?` — The color of the typed text (QMUI `SearchBarTextColor`); `nil` keeps UIKit's.
- L47 `@objc public var placeholderColor: UIColor?` — The color of the placeholder (QMUI `SearchBarPlaceholderColor`, default `UIColor.secondaryLabel`).
- L52 `@objc public var placeholder: String?` — The placeholder (legacy CYLSearchBar: "搜索"), by default the core's localized "Search".
- L58 `@objc public var cancelTitle: String?` — The title of the Cancel button (legacy CYLSearchBar: "取消"), by default the core's localized "Cancel". It is the button's accessibility label, and its title where the system draws one (iOS 26 and later draw an xmark).
- L63 `@objc public var tintColor: UIColor?` — The tint of the bar and the controls on it (QMUI `SearchBarTintColor`; legacy CYLSearchBar: RGB 0, 104, 248).
- L70 `@objc public var searchIconImage: UIImage?` — The magnifier icon (QMUI `SearchBarSearchIconImage`, best 14 x 14); `nil` keeps UIKit's.
- L75 `@objc public var clearIconImage: UIImage?` — The clear button icon (QMUI `SearchBarClearIconImage`); `nil` keeps UIKit's.
- L83 `@objc public var textFieldBackgroundColor: UIColor?` — The color of the text field (legacy CYLSearchBar: RGB 187, 186, 193 in light mode). It is drawn as the field's background image (`CYLSearchBar.textFieldBackgroundImage(color:)`), which also decides the field height.
- L89 `@objc public var textFieldBackgroundImage: UIImage?` — The background image of the text field (QMUI `SearchBarTextFieldBackgroundImage`); wins over `textFieldBackgroundColor`.
- L94 `@objc public var textFieldBorderColor: UIColor?` — The border color of the text field (QMUI `SearchBarTextFieldBorderColor`), one pixel wide; `nil` is no border.
- L100 `@objc public var textFieldCornerRadius: CGFloat = -1` — The corner radius of the text field (QMUI `SearchBarTextFieldCornerRadius`): 0 keeps UIKit's, a negative value is half of the field's height. The default is -1, the pill of the legacy CYLSearchBar.
- L107 `@objc public var barBackgroundImage: UIImage?` — The background image of the whole bar (QMUI `SearchBarBackgroundImage`); wins over the color and the border.
- L113 `@objc public var barBackgroundColor: UIColor?` — The background color of the bar; `barBackgroundImage` is generated from it (a background image rather than `barTintColor`, so that the bottom border's color can change as well).
- L118 `@objc public var barBorderColor: UIColor?` — The color of the bar's bottom border, one pixel wide.
- L124 `@objc public var hidesBarBackground = true` — Whether a bar without any background image, color or border draws no background at all (the legacy CYLSearchBar deleted the system's `the system bar background`). Default `true`.
- L134 `public static let 'default' = CYLSearchBarAppearance()` — The app-wide default style, merged from QMUI's template and the legacy CYLSearchBar. A change affects bars created afterwards.
- L139 `@objc public override init()` — A style with the merged defaults.
- L266 `@objc public func copy(with zone: NSZone? = nil) -> Any` — Returns an independent copy of this style.

## `Sources/CYLSearchBar/CYLSearchBarView.swift`

CYLAnimatedItemView, the base class of the bar items (through CollectionViewClassifyMenu's CYLTagButton). Swift Package Manager still compiles it into the CYLTabBarController module, where it is reached through CollectionViewClassifyMenu.

- L14 `public enum CYLSearchBarMode: Int` — What a `CYLSearchBarView` holds: one field, or several searches side by side.
- L31 `public enum CYLSearchBarNavigationIcon: Int` — The icon of the navigation button before the field (lapism `NavigationIconCompat`).
- L50 `public enum CYLSearchBarIconPosition: Int` — Where the search button sits while the bar is iconified.
- L69 `public enum CYLSearchBarExpansionAnimation: Int` — How the field opens and closes when `iconified` changes with animation.
- L84 `public enum CYLSearchBarItemStyle: Int` — How an item appended to a search bar looks, like the FlatDesign tab bar's item appearance.
- L103 `public enum CYLSearchBarSearchButtonStyle: Int` — What the default search button of a bar shows.
- L119 `public enum CYLSearchBarStyle: Int` — The fixed look of the whole bar: the field on the left stays, the items are appended after its text.
- L135 `public protocol CYLSearchBarViewDelegate: NSObjectProtocol` — Events of a `CYLSearchBarView`.
- L242 `public typealias CYLSearchBarViewMarginsProvider = (CYLSearchBarView, Bool) -> UIEdgeInsets` — Returns the content insets of a `CYLSearchBarView` or the margins of its Cancel button for its state (`true` while editing); the same shape as `CYLSearchBarMarginsProvider`.
- L251 `public final class CYLSearchBarView: UIView, UITextFieldDelegate` — A configurable search bar: a rounded field with a magnifier, text and clear button, views of the host inside the field after the text (a camera, a "Search" button) or before the field (a back button), and an optional Cancel button. Use it as a navigation item'
- L267 `@objc public weak var delegate: CYLSearchBarViewDelegate?` — Receives the events.
- L272 `@objc public let textField: UITextField = CYLSearchBarTextField()` — The text field inside the field.
- L277 `@objc public let fieldView = UIView()` — The rounded field that holds the magnifier, the text and `trailingAccessoryViews`.
- L282 `@objc public let searchIconView = UIImageView()` — The magnifier at the start of the field (decorative: hidden from VoiceOver).
- L287 `@objc public let cancelButton = UIButton(configuration: CYLSearchBarView.plainConfiguration(insets: NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)), primaryAction: nil)` — The Cancel button after the field (`showsCancelButton`).
- L292 `@objc public let placeholderLabel = UILabel()` — Draws the placeholder at the full font size, cut off with an ellipsis when it does not fit.
- L298 `@objc public let navigationButton = CYLSearchBarView.iconButton()` — The button before the field. It is shown when `navigationIcon` is not none or `navigationImage` is set, and `leadingView` is nil; taps call `-searchBarViewNavigationButtonClicked:` and `navigationHandler`.
- L303 `@objc public let voiceButton = CYLSearchBarView.iconButton()` — A microphone inside the field, shown while the text is empty; it calls `-searchBarViewVoiceButtonClicked:`.
- L308 `@objc public let submitButton = CYLSearchBarView.iconButton()` — A submit button inside the field, shown while there is text; it submits the query like the Search key.
- L313 `@objc public let iconButton = CYLSearchBarView.iconButton()` — The button shown while `iconified` is YES. VoiceOver reads it as "Search".
- L336 `@objc public var text: String?` — The text of the field.
- L350 `@objc public var placeholder: String?` — The placeholder, drawn by `placeholderLabel` and kept on the text field for VoiceOver.
- L365 `@objc public var font: UIFont!` — The font of the text, the placeholder and Cancel. The body text style by default, following Dynamic Type; a custom font is used as given (pass a `UIFontMetrics` font to scale it).
- L375 `@objc public var textColor: UIColor!` — The text color. `labelColor` by default.
- L383 `@objc public var placeholderColor: UIColor? { didSet { applyStyle() } }` — The placeholder color. `UIColor.secondaryLabel` when nil (readable in dark mode).
- L390 `@objc public var cursorColor: UIColor!` — The color of the text cursor (MaterialSearchView `setCursorDrawable`). The tint color by default.
- L400 `@objc public var fieldHeight: CGFloat = 36` — The height of the field; it grows when the scaled text needs more. 36 by default.
- L408 `@objc public var contentInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)` — The space around the field. (6, 16, 6, 16) by default: the same 16 pt as the tag list's section insets and section header (CollectionViewClassifyMenu), so a bar placed edge to edge lines up with the suggestions below it.
- L417 `@objc public var textFieldMarginsProvider: CYLSearchBarViewMarginsProvider?` — The content insets for the bar's state (`true` while editing); wins over `contentInsets`, the resting value (the same knob as `CYLSearchBar.textFieldMarginsProvider`). The bar's height is measured with `contentInsets`, so it does not jump when editing starts.
- L425 `@objc public var centersPlaceholder = false` — Whether the magnifier and the placeholder are centered in the field while the bar is not editing and has no text (the same knob as `CYLSearchBar.centersPlaceholder`). NO by default.
- L435 `@objc public var appearanceStyle: CYLSearchBarAppearance?` — The style of the field, one `CYLSearchBarAppearance` for this bar and `CYLSearchBar`; nil by default (the bar keeps its own look). Assigning a style maps it onto `font`, `textColor`, `placeholderColor`, `placeholder`, `tintColor`, `searchIcon`, `fieldBackgroun
- L442 `@objc public func applyDefaultAppearance()` — Applies `CYLSearchBarAppearance.defaultAppearance` (the same method as `CYLSearchBar`).
- L469 `@objc public var fieldBackgroundColor: UIColor!` — The field's background. `tertiarySystemFillColor` by default.
- L477 `@objc public var fieldCornerRadius: CGFloat = -1 { didSet { setNeedsLayout() } }` — The field's corner radius; negative makes a capsule. -1 by default.
- L482 `@objc public var fieldBorderColor: UIColor? { didSet { applyStyle() } }` — The field's border color; nil draws no border.
- L487 `@objc public var fieldBorderWidth: CGFloat = 0 { didSet { fieldBorderWidth = max(0, fieldBorderWidth); applyStyle() } }` — The field's border width, used with `fieldBorderColor`. 0 by default.
- L492 `@objc public var fieldShadowOpacity: CGFloat = 0 { didSet { fieldShadowOpacity = min(1, max(0, fieldShadowOpacity)); applyStyle() } }` — The field's shadow, 0 to 1. 0 by default.
- L497 `@objc public var searchIcon: UIImage? = UIImage(systemName: "magnifyingglass")` — The magnifier; nil shows none. `magnifyingglass` by default.
- L506 `@objc public var searchIconTintColor: UIColor!` — The magnifier's tint. `secondaryLabelColor` by default.
- L516 `@objc public var trailingAccessoryViews: [UIView] = []` — Views of yours inside the field after the text, scaled down when they would squeeze it.
- L534 `@objc public var showsTrailingAccessoryViews: Bool` — Whether `trailingAccessoryViews` are shown, without animation. YES by default; hidden views give their room to the text.
- L544 `@objc public func setShowsTrailingAccessoryViews(_ shows: Bool, animated: Bool)` — Shows or hides `trailingAccessoryViews`, optionally fading them with the text taking or giving up their room (QMUI `qmui_setShowsRightAccessoryView:animated:`, the same knob as `CYLSearchBar`). Toggling quickly ends in the last requested state.
- L589 `@objc public private(set) var items: [CYLSearchBarItem] = []` — The appended items, in order, after the text and after `trailingAccessoryViews` (like the FlatDesign tab bar's `items`). The field stays; only items are appended.
- L629 `@objc public var showsSearchButton = true` — Whether the bar shows its default search button, after the field and the items: YES by default (an editing bar and a bar in `CYLSearchBarModeMultiple` never show it). A tap calls `searchButtonHandler`, else submits the text (`submit()`), and tells the delegate
- L636 `@objc public var searchButtonStyle: CYLSearchBarSearchButtonStyle = .icon` — Whether the default search button shows an icon in a filled capsule (`.icon`, the default) or a title (`.text`).
- L643 `@objc public var searchButtonTitle: String?` — The title of the default search button (also its accessibility label in the icon style); nil is the localized "Search".
- L651 `@objc public var searchButtonImage: UIImage?` — The icon of the default search button in the `.icon` style; nil is the core's built-in magnifier (SF Symbol `magnifyingglass`).
- L658 `@objc public var searchButtonHandler: ((CYLSearchBarView) -> Void)?` — Called instead of the default action when the default search button is tapped.
- L664 `@objc public private(set) lazy var searchButtonItem: CYLSearchBarItem = makeSearchButtonItem()` — The default search button as an item, for its tint, its badge or its accessibility identifier. It is not in `items`. Replaced (with the tint and identifier kept) when the style, title or icon changes.
- L712 `@objc public var itemViews: [CYLTagButton]` — The views of `items` (`CYLTagButton`s), in the same order.
- L719 `@objc public var itemTintColor: UIColor?` — The icon and title color of every item without its own `tintColor`; nil uses the label color.
- L729 `@objc public var searchBarStyle: CYLSearchBarStyle = .plain` — The fixed look of the bar. `.bordered` draws the field and its items inside one capsule outline.
- L736 `@objc public var fieldBackgroundImage: UIImage?` — An image drawn behind the field's content, clipped to its corners.
- L747 `@objc public var selectedItem: CYLSearchBarItem?` — The first selected item (an item with `selectable` YES that was tapped on), or nil.
- L754 `@objc public var selectedIndex: Int` — The index of `selectedItem`, or `NSNotFound`.
- L764 `public func addItem(_ item: CYLSearchBarItem)` — Appends an item after the others.
- L772 `public func insertItem(_ item: CYLSearchBarItem, at index: Int)` — Inserts an item at an index (clamped to `items`); an item already in a bar moves here.
- L791 `public func addItem(style: CYLSearchBarItemStyle, title: String?, image: UIImage?, index: Int, handler: ((CYLSearchBarItem) -> Void)?) -> CYLSearchBarItem` — Creates an item and inserts it at an index; `NSNotFound` or a larger index appends it. Mirrors `-addItemWithTitle:tabBarItemImage:tabBarItemSelectedImage:index:`.
- L802 `public func removeItem(_ item: CYLSearchBarItem)` — Removes an item from the bar.
- L818 `@objc public func removeAllItems()` — Removes every item.
- L828 `public func setItems(dictionaries: [[String: Any]])` — Replaces the items with the ones the dictionaries describe (`+itemWithDictionary:`), as the cross-platform bridges send them. When only `animationLoops` and `animationSpeed` differ from the last call, the items stay and take the two values, so the animation is
- L852 `public func hasItem(of style: CYLSearchBarItemStyle) -> Bool` — YES when an item of the style was appended (a text "Search" button), like `-hasPlusButton`.
- L890 `@objc public var leadingView: UIView?` — A view of yours before the field (a back button); it wins over the navigation button.
- L908 `@objc public var showsLeadingView: Bool` — Whether the view before the field (`leadingView`, or the navigation button) is shown, without animation. YES by default; a hidden view gives its room to the field.
- L918 `@objc public func setShowsLeadingView(_ shows: Bool, animated: Bool)` — Shows or hides the view before the field, optionally sliding it in from or out to the left edge while the field takes or gives up its room (QMUI `qmui_setShowsLeftAccessoryView:animated:`). Toggling quickly ends in the last requested state.
- L955 `@objc public var showsCancelButton = false` — Shows the Cancel button after the field. NO by default.
- L967 `@objc public func setShowsCancelButton(_ shows: Bool, animated: Bool)` — Shows or hides the Cancel button, optionally sliding and fading it while the field takes or gives up its room (UIKit `setShowsCancelButton:animated:`, the same method as `CYLSearchBar`). Toggling quickly ends in the last requested state.
- L1004 `@objc public var cancelButtonMarginsProvider: CYLSearchBarViewMarginsProvider?` — Returns the margins applied to the Cancel button's frame for the bar's state (`true` while editing); a negative left value moves it left and widens it (the same knob as `CYLSearchBar.cancelButtonMarginsProvider`).
- L1011 `@objc public var cancelButtonFont: UIFont?` — The font of the Cancel button's title; `font` when nil (the same knob as `CYLSearchBar.cancelButtonFont`).
- L1020 `@objc public var cancelButtonTitle: String!` — The Cancel title. The localized "Cancel" by default.
- L1028 `@objc public var cancelButtonEndsEditing = true` — Taps on Cancel also end editing and clear nothing. YES by default.
- L1033 `@objc public var clearsTextOnCancel = false` — Taps on Cancel also clear the text (lapism `setTextClearOnBackPressed`). NO by default.
- L1041 `@objc public private(set) var isEditingBar = false` — Whether the bar is an editing bar (`editingBar(placeholder:actionTitle:)`): an edit field in the search bar's look, whose trailing button submits instead of cancelling.
- L1049 `@objc public var editingSubmitHandler: ((CYLSearchBarView, String) -> Void)?` — An editing bar's submit: the trimmed text, when its action button or the return key is tapped (after `-searchBarView:shouldSubmitText:` and `-searchBarViewSearchButtonClicked:`). Empty text submits nothing.
- L1057 `public static func editingBar(placeholder: String?, actionTitle: String) -> CYLSearchBarView` — An editing bar: the search bar's field and look for editing a name (a tag, a title), without the magnifier, with `actionTitle` ("Add", "Done") as its trailing button, which submits through `editingSubmitHandler`, as the return key does. Pin it above the keyboa
- L1079 `public func pinToKeyboard(in view: UIView)` — Pins the bar to the top of the keyboard in `view` (its keyboard layout guide, iOS 15): full width within the safe area, at the bottom while the keyboard is down, riding on the keyboard while it is up, docked or not.
- L1108 `@objc public var clearsTextOnEndEditing = false` — Ending editing also clears the text (lapism `setTextClearOnClearFocus`). NO by default.
- L1115 `@objc public var navigationIcon: CYLSearchBarNavigationIcon = .none { didSet { updateButtonImages() } }` — A built-in navigation icon. `CYLSearchBarNavigationIconNone` by default.
- L1120 `@objc public var navigationImage: UIImage? { didSet { updateButtonImages() } }` — A custom navigation icon; it wins over `navigationIcon`.
- L1127 `@objc public var navigationAccessibilityLabel: String!` — What VoiceOver reads for the navigation button. Defaults to "Back" for the arrow and "Search" for the magnifier.
- L1138 `@objc public var navigationBackgroundColor: UIColor? { didSet { updateButtonImages() } }` — A circle drawn behind the navigation icon. Nil (none) by default.
- L1143 `@objc public var navigationShadowOpacity: CGFloat = 0` — The shadow of that circle, 0 to 1 (lapism `setNavigationElevation`). 0 by default.
- L1150 `@objc public var navigationHandler: ((CYLSearchBarView) -> Void)?` — Called on taps on the navigation button, after the delegate.
- L1157 `@objc public var showsVoiceButton = false { didSet { setNeedsLayout() } }` — Shows `voiceButton` while the text is empty. NO by default.
- L1164 `@objc public var voiceImage: UIImage!` — The voice button's icon. `mic` by default.
- L1172 `@objc public var showsSubmitButton = false { didSet { setNeedsLayout() } }` — Shows `submitButton` while there is text (Android `isSubmitButtonEnabled`). NO by default.
- L1179 `@objc public var submitImage: UIImage!` — The submit button's icon. `arrow.forward.circle.fill` by default.
- L1187 `@objc public var clearImage: UIImage?` — A custom clear button icon, shown while editing with text. Nil keeps the system clear button.
- L1207 `@objc public var keyboardType: UIKeyboardType` — The keyboard type (Android `inputType`). `UIKeyboardTypeDefault` by default.
- L1215 `@objc public var returnKeyType: UIReturnKeyType` — The return key (Android `imeOptions`). `UIReturnKeySearch` by default.
- L1223 `@objc public var autocapitalizationType: UITextAutocapitalizationType` — Automatic capitalization. `UITextAutocapitalizationTypeSentences` by default.
- L1231 `@objc public var autocorrectionType: UITextAutocorrectionType` — Automatic correction. `UITextAutocorrectionTypeDefault` by default.
- L1239 `@objc(secureTextEntry) public var isSecureTextEntry: Bool` — Hides the typed characters (Android `inputType="textPassword"`). NO by default.
- L1247 `@objc public var maximumTextLength: UInt = 0` — The longest text a person can type (Android `maxLength`); 0 means no limit. 0 by default.
- L1263 `@objc(iconified) public var isIconified: Bool` — Shows only a search button instead of the field (Android `SearchView.isIconified`). Tapping the button opens the field and starts editing. NO by default.
- L1272 `@objc public var iconifiedByDefault = false` — When YES, the field closes back to its icon when editing ends with no text (Android `setIconifiedByDefault`). NO by default.
- L1283 `@objc public var expansionAnimation: CYLSearchBarExpansionAnimation = .fade` — How the field opens and closes. `CYLSearchBarExpansionAnimationFade` by default.
- L1289 `@objc public var iconPosition: CYLSearchBarIconPosition = .trailing { didSet { setNeedsLayout() } }` — Where `iconButton` sits while iconified; the field opens from there. `CYLSearchBarIconPositionTrailing` by default.
- L1294 `@objc public var animationDuration: TimeInterval = 0.3` — The length of the opening and closing animations, in seconds. 0.3 by default.
- L1307 `@objc public var mode: CYLSearchBarMode = .single` — One field (`CYLSearchBarModeSingle`, the default) or several searches side by side (`CYLSearchBarModeMultiple`, iammert `MultiSearchView`). The text style (`placeholder`, `font`, `textColor`, `placeholderColor`, the keyboard options, `maximumTextLength`) and `
- L1325 `@objc public var searches: [String]` — `CYLSearchBarModeMultiple`: the texts of the searches, completed searches first, then the one being typed.
- L1333 `@objc public var selectedSearchIndex: Int` — `CYLSearchBarModeMultiple`: the index of the selected search in `searches`, or `NSNotFound` when none is selected.
- L1340 `@objc public var isEditingNewSearch: Bool` — `CYLSearchBarModeMultiple`: YES while a new search is being typed (MultiSearchView `isInSearchMode`).
- L1348 `@objc public var newSearchButton: UIButton` — `CYLSearchBarModeMultiple`: the button at the trailing end; it starts a new search, or completes the one being typed. VoiceOver reads it as "New search".
- L1356 `@objc public var minimumTextLength: UInt = 3` — `CYLSearchBarModeMultiple`: a search shorter than this is dropped by `-completeSearch`. 3 by default, as in MultiSearchView.
- L1362 `@objc public var searchIndicatorColor: UIColor? { didSet { multiSearchView.applyStyle() } }` — `CYLSearchBarModeMultiple`: the color of the indicator under the selected search and of `newSearchButton`; the tint color when nil.
- L1367 `@objc public var unselectedSearchAlpha: CGFloat = 0.5` — `CYLSearchBarModeMultiple`: the opacity of the searches that are not selected, 0 to 1. 0.5 by default.
- L1374 `@objc public var searchFieldWidth: CGFloat = 160` — `CYLSearchBarModeMultiple`: the width of the field of a new search, in points (at least 44). 160 by default.
- L1381 `@objc public var newSearchImage: UIImage!` — `CYLSearchBarModeMultiple`: the icon of `newSearchButton`. `magnifyingglass` by default.
- L1390 `@objc public var removeSearchImage: UIImage!` — `CYLSearchBarModeMultiple`: the icon of the remove button on the selected search. `xmark.circle.fill` by default.
- L1399 `@objc public func beginNewSearch()` — `CYLSearchBarModeMultiple`: starts a new search and shows the keyboard (MultiSearchView `search`). Does nothing while a search is being typed, or in `CYLSearchBarModeSingle`.
- L1410 `@objc public func completeSearch()` — `CYLSearchBarModeMultiple`: completes the search being typed (`completeSearch`). It becomes the selected search, or is dropped when shorter than `minimumTextLength`.
- L1421 `public func addSearch(_ text: String)` — `CYLSearchBarModeMultiple`: adds a completed search without typing it, and selects it. An empty text is ignored.
- L1432 `public func selectSearch(at index: Int)` — `CYLSearchBarModeMultiple`: selects a search, like a tap on it.
- L1444 `public func removeSearch(at index: Int)` — `CYLSearchBarModeMultiple`: removes a search, like a tap on its remove button. The next search is selected, or the previous one when the last search went away.
- L1453 `override public init(frame: CGRect)`
- L1461 `public required init?(coder: NSCoder)` — Creates the bar from an archive (a storyboard or a XIB).
- L1546 `public func setText(_ text: String?, submit: Bool)` — Sets the text and, when `submit` is YES and the text is not empty, submits it as if the Search key were tapped (MaterialSearchView `setQuery`, lapism `setTextQuery`).
- L1559 `public func submit() -> Bool` — Submits the current text: asks `-searchBarView:shouldSubmitText:`, then calls `-searchBarViewSearchButtonClicked:`. Returns NO when the text is empty or the delegate refused it.
- L1574 `@objc public func showKeyboard()` — Starts editing and shows the keyboard.
- L1585 `@objc public var pushesOnTap = false` — Whether a tap on the field does not edit but calls `onFirstLevelTap` (and `performFirstLevelTap()`): the bar of a first-level page (a tab root) shows the whole search look and a tap pushes the second-level search page. NO by default; no keyboard comes up on th
- L1599 `@objc public var onFirstLevelTap: ((CYLSearchBarView) -> Void)?` — Called when the field of a `pushesOnTap` bar is tapped: push the second-level search page. The second-level page's bar brings its back button in and shrinks alongside the push (`embedInNavigationBar(of:)` does it), so the host only pushes.
- L1604 `@objc public func performFirstLevelTap()` — The tap of a first-level bar, also callable from code: runs `onFirstLevelTap`.
- L1611 `@objc public var isBackButtonShown: Bool` — Whether the back button (the navigation arrow before the field) is shown.
- L1620 `@objc public var backButtonProgress: CGFloat` — 1 while the bar's own back button (its navigation arrow before the field) is shown, 0 while it is hidden. It is for a host that puts the bar where no navigation controller supplies a back button (a plain view, a sheet); in a navigation bar the system back butt
- L1629 `public func showBackButton(animated: Bool = true)` — Brings the back button (the navigation arrow) in from the left, the field shrinking to make room.
- L1638 `public func hideBackButton(animated: Bool = true)` — Takes the back button out to the left, the field growing back.
- L1673 `@objc public var focusesOnAppear = false` — Whether the field takes focus (and the keyboard, with the search key, shows) every time the bar appears on screen, like a `viewDidAppear`: the first time its page is entered, after a push and pop, and after the app returns from the background, but only on a se
- L1729 `@objc public var pageDepth = -1` — The depth of the page the bar is on, set by a host that has no navigation controller to read: 0 is a first-level page, 1 or more a second-level or deeper one. -1 (the default) reads the navigation stack (`isOnSecondLevelOrDeeperPage`).
- L1761 `@objc public var dismissesKeyboardOnOutsideTouch = true` — Whether a touch anywhere in the window outside this bar (a tap, or the start of a scroll or drag in any container) hides the keyboard while the field is editing: CYLDeallocBlockExecutor's `didTouchOutside`, observed only while editing. YES by default; an editi
- L1785 `@objc public func hideKeyboard()` — Ends editing and hides the keyboard.
- L1842 `public func setIconified(_ iconified: Bool, animated: Bool)` — Opens or closes the field, with `expansionAnimation` when `animated` is YES. Opening also starts editing.
- L1931 `override public func encodeRestorableState(with coder: NSCoder)` — Saves the text, whether it is editing and whether it is iconified (`onSaveInstanceState`).
- L1941 `override public func decodeRestorableState(with coder: NSCoder)` — Restores the text, the iconified state and editing (`onRestoreInstanceState`).
- L2010 `override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?)`
- L2018 `override public func tintColorDidChange()`
- L2028 `@objc public internal(set) var isEmbeddedInNavigationBar = false` — True after `embedInNavigationBar(of:)`: the bar is the title view of a navigation bar and fills its width.
- L2032 `override public var intrinsicContentSize: CGSize`
- L2041 `override public func sizeThatFits(_ size: CGSize) -> CGSize`
- L2059 `override public func layoutSubviews()`
- L2259 `public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool` — Asks the delegate whether editing may start; a refusal reports a tap instead.
- L2275 `public func textFieldShouldReturn(_ textField: UITextField) -> Bool` — The return key submits the text.
- L2287 `public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool` — Enforces `maximumTextLength`; deleting is always allowed.
- L2298 `public func textFieldDidBeginEditing(_ textField: UITextField)` — Reports the start of editing.
- L2307 `public func textFieldDidEndEditing(_ textField: UITextField)` — Clears the text and closes to the icon when configured, then reports the end of editing.
- L2323 `override public func becomeFirstResponder() -> Bool` — Starts editing in the text field.
- L2330 `override public func resignFirstResponder() -> Bool` — Ends editing; the bar itself also gives up first responder as UIKit expects.
- L2342 `public final class CYLSearchBarItem: NSObject` — One element after the text of a `CYLSearchBarView`: a model independent of its view, like `CYLFlatDesignTabBarItem`. Append it with `-[CYLSearchBarView addItem:]`; its view is `itemView`.
- L2349 `@objc public let style: CYLSearchBarItemStyle` — How the item looks (icon, divider or text); set when the item is created.
- L2354 `@objc public var title: String? { didSet { itemChanged() } }` — The text of a text item, and the VoiceOver label of an icon item without `accessibilityLabel`.
- L2359 `@objc public var image: UIImage? { didSet { itemChanged() } }` — The icon (a template image is tinted with `tintColor`).
- L2364 `@objc public var selectedImage: UIImage? { didSet { itemChanged() } }` — The icon while `selected` is YES; nil uses `image`.
- L2369 `@objc public var animatedImage: UIImage? { didSet { itemChanged() } }` — An animated icon (`+[UIImage animatedImageWithImages:duration:]`), drawn instead of `image` when set.
- L2377 `@objc public var animationURL: URL? { didSet { itemChanged() } }` — An animated icon file (Lottie .json, .pag, .riv, .svga, .gif), drawn by the item's `CYLTagButton` (a `CYLAnimatedItemView`) when the app adds the engine of its type (`CYLAnimatedItem/<Type>`; the core adds none) and played on each tap. Otherwise `image` shows,
- L2382 `@objc public var animationLoops = false { didSet { itemChanged() } }` — Whether `animationURL` plays again after each pass; NO plays once on each tap. The same on every platform.
- L2388 `@objc public var animationSpeed: CGFloat = 1 { didSet { itemChanged() } }` — The playback speed of `animationURL`; 1 is the file's own. An engine without speed ignores it. The same on every platform.
- L2394 `@objc public func restartAnimation()` — Plays `animationURL` again from the start, as a tap does. Does nothing without an animation. The same on every platform.
- L2403 `@objc public var imageSize: CGSize = .zero { didSet { itemChanged() } }` — The icon size; zero uses 20 x 20 pt.
- L2408 `@objc public var itemAccessibilityLabel: String? { didSet { itemChanged() } }` — What VoiceOver reads; nil reads `title`.
- L2413 `@objc public var itemAccessibilityIdentifier: String? { didSet { itemChanged() } }` — A test identifier for the item view.
- L2418 `@objc public var isEnabled = true { didSet { itemChanged() } }` — NO dims the item and ignores taps. YES by default.
- L2423 `@objc public var isSelectable = false` — YES makes each tap toggle `selected` (a filter that stays on). NO by default.
- L2428 `@objc public var isSelected = false { didSet { itemChanged() } }` — The selected state (drawn with `selectedImage`, `selectedBackgroundColor` and the selected title attributes).
- L2433 `@objc public var tintColor: UIColor? { didSet { itemChanged() } }` — The icon and title color; nil uses the bar's `itemTintColor`.
- L2438 `@objc public var backgroundColor: UIColor? { didSet { itemChanged() } }` — The item background; nil is clear.
- L2443 `@objc public var selectedBackgroundColor: UIColor? { didSet { itemChanged() } }` — The item background while selected; nil uses `backgroundColor`.
- L2448 `@objc public var contentInsets: UIEdgeInsets = .zero { didSet { itemChanged() } }` — Space around the icon and title inside the item; `UIEdgeInsetsZero` uses the style's default.
- L2453 `@objc public static let automaticCornerRadius: CGFloat = -1` — `cornerRadius` that follows the item: 10 pt with a background, square without one.
- L2460 `@objc public var cornerRadius: CGFloat = CYLSearchBarItem.automaticCornerRadius { didSet { itemChanged() } }` — The corner radius of the item's background and border, in points: 0 is square, `CYLAnimatedItemCornerRadiusCapsule` a capsule, `automaticCornerRadius` (the default) 10 pt with a background and square without one. The icon, the background and the border are one
- L2465 `@objc public var borderColor: UIColor? { didSet { itemChanged() } }` — The border color of the item's own outline; nil (the default) draws none.
- L2470 `@objc public var borderWidth: CGFloat = 0 { didSet { itemChanged() } }` — The width of the item's own outline, in points; 0 by default.
- L2475 `@objc public var itemHeight: CGFloat = 0 { didSet { itemChanged() } }` — The height of the item in points; 0 (the default) is the 36 pt touch size.
- L2480 `@objc public var imagePositionAdjustment: UIOffset = .zero { didSet { itemChanged() } }` — Moves the icon without changing the item's size.
- L2485 `@objc public var titlePositionAdjustment: UIOffset = .zero { didSet { itemChanged() } }` — Moves the title without changing the item's size.
- L2490 `@objc public var badgeValue: String? { didSet { itemChanged() } }` — The badge text; nil hides the badge, an empty string draws a dot.
- L2495 `@objc public var badgeColor: UIColor? { didSet { itemChanged() } }` — The badge background; nil is system red.
- L2500 `@objc public var badgeSize: CGSize = .zero { didSet { itemChanged() } }` — The smallest badge size; zero uses 16 x 16 pt (a dot is 8 x 8 pt).
- L2505 `@objc public var badgeContentInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4) { didSet { itemChanged() } }` — Space around the badge text.
- L2510 `@objc public var badgePositionAdjustment: UIOffset = .zero { didSet { itemChanged() } }` — Moves the badge from the icon's top trailing corner.
- L2515 `@objc public var handler: ((CYLSearchBarItem) -> Void)?` — Called on each tap, after `-searchBarView:didSelectItem:`.
- L2520 `@objc public internal(set) weak var searchBarView: CYLSearchBarView?` — The bar the item was appended to; nil before `-addItem:` and after `-removeItem:`.
- L2525 `@objc public var index: Int` — The item's position in its bar's `items`; `NSNotFound` when it is in no bar.
- L2533 `@objc public var itemView: CYLTagButton` — The item's view, a `CYLTagButton` (CollectionViewClassifyMenu) created on first use. The bar adds it inside its field and sends its taps to `-searchBarView:didSelectItem:` and `handler`.
- L2548 `public init(style: CYLSearchBarItemStyle, title: String?, image: UIImage?)` — An item of the given style with a title and an icon.
- L2559 `public convenience init(title: String?, image: UIImage?)` — An icon item, or a text item when the title is set and the image is nil.
- L2567 `public convenience init(title: String?, image: UIImage?, selectedImage: UIImage?)` — Like `-initWithTitle:image:`, with an icon for the selected state.
- L2576 `public static func iconItem(image: UIImage?, title: String?, handler: ((CYLSearchBarItem) -> Void)?) -> CYLSearchBarItem` — An icon item: the title is what VoiceOver reads.
- L2586 `public static func textItem(title: String, handler: ((CYLSearchBarItem) -> Void)?) -> CYLSearchBarItem` — A text item (a "Search" button).
- L2596 `public static func divider() -> CYLSearchBarItem` — A divider between two items.
- L2606 `public static func item(dictionary: [String: Any]) -> CYLSearchBarItem` — An item from plain values, for the cross-platform wrappers (Flutter, React Native): `style` (`icon`, `divider`, `text`), `title`, `image` (`camera`, `mic`, `search`, `back`, else an asset or SF Symbol name), `accessibilityIdentifier`, `isEnabled`, `isSelectabl
- L2656 `public func setTitleTextAttributes(_ attributes: [NSAttributedString.Key: Any]?, for state: UIControl.State)` — The title attributes for a state (`UIControlStateNormal`, `UIControlStateSelected`, `UIControlStateDisabled`).
- L2665 `public func titleTextAttributes(for state: UIControl.State) -> [NSAttributedString.Key: Any]?` — The title attributes set for a state, or nil.
- L2673 `public func setBadgeTextAttributes(_ attributes: [NSAttributedString.Key: Any]?, for state: UIControl.State)` — The badge text attributes for a state.
- L2682 `public func badgeTextAttributes(for state: UIControl.State) -> [NSAttributedString.Key: Any]?` — The badge text attributes set for a state, or nil.
- L2689 `@objc public func actualBadgeSuperView() -> UIView` — The view the badge is drawn in (the item view).

## `Sources/CYLSearchBar/CYLSearchController.swift`

Tencent is pleased to support the open source community by making QMUI_iOS available. Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved. Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://opensource.org/licenses/MIT Unless required by applicable law or agreed t

- L32 `public protocol CYLSearchControllerDelegate: UITableViewDataSource, UITableViewDelegate` — What a `CYLSearchController` asks of its owner (QMUI `QMthe system search controllerDelegate`): the search results (called on every text change) and the data source and delegate of the results table view, plus optional life cycle callbacks.
- L83 `open class CYLSearchController: UIViewController, CYLSearchBarViewDelegate` — A search over `contentsViewController`: the core's search field `searchBar` (`CYLSearchBarView`), and, while the search is active, a page below the field with the launch view (recent searches or suggestions) while the text is empty, the results view controller
- L91 `@objc public weak var searchResultsDelegate: CYLSearchControllerDelegate?` — The owner of the results: its data source and delegate drive the results table view, and it is told about the text and the life cycle. Held weakly.
- L99 `@objc public let searchResultsController: UIViewController` — The view controller that shows the results: a table view controller unless the controller was created with `init(contentsViewController:resultsViewController:)`.
- L104 `@objc public let searchBar = CYLSearchBarView(frame: .zero)` — The search field, the core's `CYLSearchBarView`; use it as a table header or in a navigation item.
- L109 `@objc public var tableView: UITableView? { (searchResultsController as? UITableViewController)?.tableView }` — The results table view; `nil` unless the results controller is a `UITableViewController`.
- L124 `@objc public var highlightsResultMatches: Bool` — Gives the first match of the search text in each row of the results table `resultMatchHighlightColor` (the tint color by default), after `searchResultsDelegate` configured the row. While it is on, the table's `dataSource` is a forwarding proxy of `searchResult
- L132 `@objc public var resultMatchHighlightColor: UIColor?` — The color of the highlighted match; nil uses the tint color.
- L141 `@objc public var launchView: UIView?` — A view shown over the contents below the field while the search is active and the text is empty (QMUI `launchView`); nil shows none.
- L151 `@objc public var showsSuggestionsLaunchView: Bool` — Whether `launchView` is the built-in one (the recent searches of `historyStore`, else `suggestions`, as tags).
- L165 `@objc public var suggestions: [String] = []` — The suggestions of the built-in launch view.
- L173 `@objc public var dimmingColor: UIColor?` — The color of a dimming view over the contents while the search is active and the text is empty (no launch view); a tap on it leaves the search. nil shows none.
- L184 `@objc public var isActive: Bool` — Whether the search is active; setting it does not animate.
- L193 `@objc public var alwaysShowsSearchResultsController = false` — Shows the results view controller even while the text is empty (QMUI `qmui_alwaysShowsSearchResultsController`); the launch view is dropped.
- L203 `@objc public var supportsSwipeToDismissSearch = false` — Whether a swipe from the left screen edge leaves the search while it is active. NO by default.
- L210 `@objc public private(set) var swipeGestureRecognizer: UIScreenEdgePanGestureRecognizer?` — The recognizer of the swipe; nil until the search was first active with `supportsSwipeToDismissSearch`.
- L215 `@objc public var searchBarMaxY: CGFloat` — The bottom edge of the search field in the coordinates of its window; 0 while it is not in a window.
- L223 `@objc public var isEmptyViewShowing: Bool { emptyViewSlot.isShowing }` — Whether an empty view is showing.
- L229 `@objc public var noResultsText: String?` — The text of the empty view `CYLSearchController` shows by itself when the text is not empty and the results table has no row; nil shows none.
- L246 `@objc public var historyStore: CYLSearchSuggestionCache?` — The history of submitted queries the built-in launch view shows; a return key or a tapped tag submits.
- L253 `@objc public static let historyDidChangeNotification = Notification.Name("CYLSearchControllerHistoryDidChange")` — Posted when a submitted query is added to `historyStore`; `userInfo["query"]` is the query.
- L290 `@objc public init(contentsViewController: UIViewController, resultsViewController: UIViewController)` — Creates a search controller for `contentsViewController` that shows its results in `resultsViewController` (QMUI `initWithContentsViewController:resultsViewController:`).
- L329 `@objc public convenience init(contentsViewController: UIViewController, resultsTableViewStyle: UITableView.Style)` — Creates a search controller whose results are a table view of `resultsTableViewStyle` (QMUI `initWithContentsViewController:resultsTableViewStyle:`).
- L338 `@objc public convenience init(contentsViewController: UIViewController)` — Creates a search controller with a plain results table view (QMUI `initWithContentsViewController:`).
- L345 `@objc public required init?(coder: NSCoder)` — Not available: create the controller with its contents view controller.
- L375 `@objc public func setActive(_ active: Bool, animated: Bool)` — Enters or leaves the search (QMUI `setActive:animated:`).
- L382 `@objc(isSearchOpen) public var searchOpen: Bool { isActive }` — Whether the search is active (`CYLSearchView.searchOpen`); the same as `isActive`.
- L388 `public func showSearch(animated: Bool)` — Starts the search with animation (`CYLSearchView.showSearch(animated:)`); `setActive(true, animated:)`.
- L396 `public func closeSearch(animated: Bool)` — Leaves the search (`CYLSearchView.closeSearch(animated:)`); `setActive(false, animated:)`.
- L571 `@objc public func installSearchBar(asHeaderOf tableView: UITableView)` — Shows the search field as the table view's header (QMUI `qmui_usedAsTableHeaderView`) and keeps this controller alive as long as the table view lives. It also sets the table's estimated row, header and footer heights to 0, adds the bottom inset the header need
- L590 `public func install(in navigationItem: UINavigationItem)` — Puts the search field into `navigationItem` as its title view (`embedInNavigationBar(of:)` of the core), and keeps this controller alive with the contents view controller (a caller who drops its own reference does not crash on the first search, #1229).
- L602 `@objc public var snapsHeaderSearchBar = true` — Whether a header search field settles fully shown or fully hidden when a drag ends. YES by default.
- L619 `@objc public func showEmptyView(text: String?, detailText: String?, buttonTitle: String?,` — Shows an empty view with a text, a detail text and a button over the results (QMUI `showEmptyViewWithText:detailText:buttonTitle:buttonAction:`); nothing happens while the text is empty.
- L629 `@objc public func showEmptyView(scenario: CYLPlaceholderScenario)` — Shows one of CYLTableViewPlaceHolder's scenarios over the results; nothing happens while the text is empty.
- L637 `@objc public func hideEmptyView()` — Removes the empty view.
- L668 `public func searchBarViewDidBeginEditing(_ searchBarView: CYLSearchBarView)` — The field began editing: the search becomes active.
- L675 `public func searchBarView(_ searchBarView: CYLSearchBarView, textDidChange text: String)` — The text changed: the results update.
- L682 `public func searchBarViewCancelButtonClicked(_ searchBarView: CYLSearchBarView)` — Cancel was tapped: the search ends.
- L743 `@objc public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool` — The swipe begins only while the search is active.
- L750 `@objc public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,` — The navigation controller's pop gestures wait for the search swipe to fail.

## `Sources/CYLSearchBar/CYLSearchHeaderSnapper.swift`

CYLSearchHeaderSnapper.swift CYLSearchViewController The #1160 / #1207 handling of a search bar that is a table view's header (docs/qmui-search-controller.md, rows I4 and B10): UIKit's header can stay half visible and, with short content, cannot be scrolled out of sight. This object keeps the header scrollable out of sight and settles it fully shown or fully hidden when a drag ends. It uses public

## `Sources/CYLSearchBar/CYLSearchNavigationBar.swift`

CYLSearchNavigationBar.swift CYLSearchViewController The search bar in a navigation bar, always: `CYLSearchBarView.embedInNavigationBar(of:)` puts the bar into the navigation bar of a view controller, and creates one, a `CYLSearchNavigationBar`, when the view controller has none (docs/animated-icon-component.md, "Refresh, hot data and navigation bar contract", part C).

- L17 `public final class CYLSearchNavigationBar: UINavigationBar, UINavigationBarDelegate` — A navigation bar the core creates for a view controller that has none, holding the search bar as its title view, attached to the top edge so its background reaches under the status bar.
- L22 `@objc public static let standardHeight: CGFloat = 44` — The height of a navigation bar below the status bar, 44 pt.
- L24 `override public init(frame: CGRect)`
- L38 `@objc public var backHandler: (() -> Void)?` — Called when the back button is tapped (a bar made with `showsBackButton`); the bar itself never pops, the host decides (a Flutter route pops, a React Native screen closes).
- L45 `public static func holding(_ searchBar: CYLSearchBarView) -> CYLSearchNavigationBar` — A navigation bar holding `searchBar` as its title view, with the bar set up for it (36 pt field, no side inset of its own, `isEmbeddedInNavigationBar`). The bridges use it as the content of their native view.
- L55 `public static func holding(_ searchBar: CYLSearchBarView, showsBackButton: Bool) -> CYLSearchNavigationBar` — As `holding(_:)`, and with `showsBackButton` the bar has the back button of a second-level page on its leading side (a root item titled "Back" below the item of the search bar); the search bar takes the width that is left. A tap on it calls `backHandler`.
- L75 `public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool` — The back button was tapped: the host's `backHandler` runs, the bar keeps its items.
- L83 `public func position(for bar: any UIBarPositioning) -> UIBarPosition` — Attached to the top edge: the background extends under the status bar.
- L101 `public func embedInNavigationBar(of viewController: UIViewController) -> UINavigationBar` — Puts this bar into the navigation bar of `viewController` and returns that navigation bar; a navigation bar always exists afterwards. With a `navigationController` the bar becomes the `navigationItem`'s title view and the controller's own navigation bar is ret
- L137 `public func applyNavigationFieldStyle()` — The look of the input box of a navigation bar, the one every screen uses: a bordered capsule (`.bordered`, corner radius 18) with a soft shadow, an opaque white (light) or black (dark) fill, no magnifier, 16 pt text that scales with Dynamic Type. The border, t
- L153 `public enum CYLSearchBarPreset: Int` — The looks of a search bar the core ships, one per tab of the example (`CYLSearchBarView.applyPreset(_:)`); the same names on every platform.
- L183 `public func applyPreset(_ preset: CYLSearchBarPreset)` — Applies one of the core's looks. Every preset starts from the plain look, so applying another one replaces the first. Call it before `addItem(_:)` and `embedInNavigationBar(of:)`.

## `Sources/CYLSearchBar/CYLSearchPresentationState.swift`

Tencent is pleased to support the open source community by making QMUI_iOS available. Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved. Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://opensource.org/licenses/MIT Unless required by applicable law or agreed t

## `Sources/CYLSearchBar/CYLSearchResources.swift`

CYLSearchResources.swift CYLSearchViewController The pod's resources (images and localized strings of CYLSearchViewController.bundle) and the cache of submitted queries that the suggestion list shows (docs/core-todo.md). The cache rules come from the legacy CYLSearchController's search history (newest first, no duplicates, saved after every search, NSUserDefaults); the database store is new and is

- L18 `public final class CYLSearchResources: NSObject` — Images and localized strings of `CYLSearchViewController.bundle`, the resource bundle of this pod.
- L25 `@objc public static let resourceBundle: Bundle? =` — The resource bundle, found next to this class's framework or in the main bundle; nil when it is missing.
- L42 `@objc public static let historyDidChangeNotification = Notification.Name("CYLSearchSuggestionStoreDidChange")` — Posted after a built-in history store changed (a query was added or removed, or the history cleared), whoever changed it: the object is the store, and `userInfo` holds `"policy"` (the raw value of `CYLSearchSuggestionCachePolicy`) and `"name"` of that history,
- L49 `public static func suggestionCache(policy: CYLSearchSuggestionCachePolicy, name: String) -> CYLSearchSuggestionCache?` — The built-in store of submitted queries (database, `NSUserDefaults` or file, newest first, no duplicates) that `CYLSearchView` uses, for other search screens such as `CYLSearchController.historyStore`; nil for the policy none.
- L57 `public static func image(named name: String) -> UIImage?` — An image of the resource bundle, or nil (logged) when it is missing.
- L70 `public static func localizedString(forKey key: String) -> String` — The text of `key` in the language the app shows (the preferred languages), English when the key has no translation, or the key itself (logged) when it is missing everywhere.
- L78 `public static func localizedString(forKey key: String, language: String?) -> String` — The text of `key` in `language` (for example "zh-Hans"), or in the preferred languages when `language` is nil.
- L100 `@objc public enum CYLSearchSuggestionCachePolicy: Int` — Where the suggestion cache keeps the submitted queries. More policies can be added later; an app can also plug in its own store through `CYLSearchSuggestionCache`.
- L123 `@objc public protocol CYLSearchSuggestionCache: NSObjectProtocol` — A store of submitted queries, newest first. `CYLSearchView` makes the built-in store of its `suggestionCachePolicy`; implement this protocol and set `CYLSearchView.suggestionCache` to use another store.

## `Sources/CYLSearchBar/CYLSearchResultsComponent.swift`

Tencent is pleased to support the open source community by making QMUI_iOS available. Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved. Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://opensource.org/licenses/MIT Unless required by applicable law or agreed t

## `Sources/CYLSearchBar/CYLSearchSuggestionArea.swift`

CYLSearchSuggestionArea.swift CYLSearchViewController The suggestion area of the search core, written once (docs/qmui-search-controller.md, "Merge design", row `launchView`, and "Merge phase 2 log"): the tags of CollectionViewClassifyMenu's `CYLTagListView` folded with a trailing fold control, and the header above cached queries with its title and clear button. `CYLSearchView` installs these views



_Continues in [part 2](01-ios-core-part2.md)._

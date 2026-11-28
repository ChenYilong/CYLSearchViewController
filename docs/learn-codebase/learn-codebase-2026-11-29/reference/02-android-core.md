> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Script-generated index of declarations, comments and test names; comments are quoted, not verified.

# Android core: files and declarations

> **Generated mechanically** (regex extraction) from the source text read in the 2026-11-29 learn-codebase pass: HEAD `ad32984` plus the uncommitted working-tree changes. It is an index, not a review: a regex can miss or mis-pick a declaration, and "doc" is the comment found above it. Every line number was matched against the working tree with `git grep` on 2026-11-29. A declaration the regex missed is simply absent. Check the file before relying on a line.

| File | Lines |
|:---|---:|
| `android/merged/cylsearch/build.gradle.kts` | 109 |
| `android/merged/cylsearch/src/main/AndroidManifest.xml` | 4 |
| `android/merged/cylsearch/src/main/kotlin/com/cyl/search/CYLOutsideTouchWindowCallback.kt` | 22 |
| `android/merged/cylsearch/src/main/kotlin/com/cyl/search/CYLSearchBarAppearance.kt` | 179 |
| `android/merged/cylsearch/src/main/kotlin/com/cyl/search/CYLSearchBarView.kt` | 3915 |
| `android/merged/cylsearch/src/main/kotlin/com/cyl/search/CYLSearchHeaderSnapper.kt` | 114 |
| `android/merged/cylsearch/src/main/kotlin/com/cyl/search/CYLSearchListView.kt` | 338 |
| `android/merged/cylsearch/src/main/kotlin/com/cyl/search/CYLSearchNavigationBar.kt` | 84 |
| `android/merged/cylsearch/src/main/kotlin/com/cyl/search/CYLSearchResources.kt` | 296 |
| `android/merged/cylsearch/src/main/kotlin/com/cyl/search/CYLSearchResultsComponent.kt` | 122 |
| `android/merged/cylsearch/src/main/kotlin/com/cyl/search/CYLSearchTagListHeader.kt` | 50 |
| `android/merged/cylsearch/src/main/kotlin/com/cyl/search/CYLSearchTagListStyle.kt` | 201 |
| `android/merged/cylsearch/src/main/kotlin/com/cyl/search/CYLSearchView.kt` | 1991 |

## `android/merged/cylsearch/build.gradle.kts`

The CYL search API that matches the iOS library (docs/android-api-alignment.md, docs/search-core-merge.md).

## `android/merged/cylsearch/src/main/AndroidManifest.xml`

Merged module manifest (the upstream manifest sets a package attribute, which AGP 8 rejects).

## `android/merged/cylsearch/src/main/kotlin/com/cyl/search/CYLOutsideTouchWindowCallback.kt`

The activity window's callback while a search field is editing (`CYLSearchBarView.dismissesKeyboardOnOutsideTouch`): it sees every touch before any view does, reports it, and passes everything to the callback it wraps. Inactive, it only passes on.

- L11 `val wrapped: Window.Callback,`
- L16 `var isActive = true` — False once the bar stopped observing; a wrapper still above this one keeps passing events through it.
- L18 `override fun dispatchTouchEvent(event: MotionEvent): Boolean`

## `android/merged/cylsearch/src/main/kotlin/com/cyl/search/CYLSearchBarAppearance.kt`

Ported from QMUI_iOS (Tencent, MIT): the style values QMUI's qmui_styledAsQMUISearchBar took from its configuration table, merged with the defaults of the legacy iOS CYLSearchBar. See META-INF/cylsearch/NOTICE.

- L18 `class CYLSearchBarAppearance` — The merged default style of a `CYLSearchBarView` (iOS `CYLSearchBarAppearance`): colors, placeholder and Cancel texts, icons and the field's background. Set it as `CYLSearchBarView.appearanceStyle`; a null value leaves the bar's own default for that property.
- L23 `var font: Typeface? = null` — The typeface of the text, the placeholder and Cancel.
- L28 `var fontSize: Float? = null` — The text size in sp.
- L33 `var textColor: Int? = null` — The text color.
- L38 `var placeholderColor: Int? = null` — The placeholder color.
- L43 `var placeholder: String? = null` — The placeholder text.
- L48 `var cancelTitle: String? = null` — The Cancel button's title.
- L53 `var tintColor: Int? = null` — The color of Cancel and of the cursor.
- L58 `var searchIcon: Drawable? = null` — The magnifier.
- L63 `var clearIcon: Drawable? = null` — The clear button's icon.
- L68 `var fieldBackgroundColor: Int? = null` — The field's background color.
- L73 `var fieldBorderColor: Int? = null` — The field's border color.
- L78 `var fieldCornerRadius: Float = -1f` — The field's corner radius in dp; negative makes a capsule.
- L84 `var textFieldBackgroundImage: Drawable? = null` — The background image of the text field (QMUI `SearchBarTextFieldBackgroundImage`); wins over `fieldBackgroundColor`. Build one from a color with `CYLSearchBarView.textFieldBackgroundImage`.
- L90 `var barBackgroundImage: Drawable? = null` — The background image of the whole bar (QMUI `SearchBarBackgroundImage`); wins over `barBackgroundColor` and `barBorderColor`. Build one from colors with `CYLSearchBarView.backgroundImage`.
- L95 `var barBackgroundColor: Int? = null` — The color behind the whole bar; null leaves it transparent.
- L100 `var barBorderColor: Int? = null` — The color of the bar's bottom border, one pixel wide; null draws none.
- L106 `var hidesBarBackground: Boolean = true` — Whether a bar without a background image, color or border draws no background at all (the bar stays transparent, as the legacy iOS CYLSearchBar did). False gives it the theme's window background. True by default.
- L111 `fun copy(): CYLSearchBarAppearance = CYLSearchBarAppearance().also` — A copy that can change without changing this one (iOS `copy`).
- L134 `fun applyTo(bar: CYLSearchBarView)` — Sets every value that is not null on `bar` (what `CYLSearchBarView.appearanceStyle` calls).
- L169 `fun defaultAppearance(context: Context): CYLSearchBarAppearance` — The default style for the night mode of `context`: the legacy field RGB(187, 186, 193), in the dark RGB(58, 58, 60), tint RGB(0, 104, 248), the localized placeholder and Cancel (iOS `CYLSearchBarAppearance.default`).

## `android/merged/cylsearch/src/main/kotlin/com/cyl/search/CYLSearchBarView.kt`

- L66 `enum class CYLSearchBarNavigationIcon` — The icon of the navigation button before the field (lapism `NavigationIconCompat`).
- L86 `enum class CYLSearchBarIconPosition` — Where the search button sits while the bar is iconified.
- L106 `enum class CYLSearchBarExpansionAnimation` — How the field opens and closes when `iconified` changes with animation.
- L121 `enum class CYLSearchBarMode` — Whether a `CYLSearchBarView` edits one query or several searches side by side.
- L137 `enum class CYLTextAutocapitalizationType` — Automatic capitalization of the typed text (iOS `UITextAutocapitalizationType`).
- L162 `enum class CYLTextAutocorrectionType` — Automatic correction of the typed text (iOS `UITextAutocorrectionType`).
- L182 `interface CYLSearchBarViewDelegate` — Events of a `CYLSearchBarView`. Every method is optional.
- L188 `fun searchBarViewShouldBeginEditing(searchBarView: CYLSearchBarView): Boolean = true` — Asks whether a tap may start editing. Return false to use the bar as a button that opens another search page (lapism `MaterialSearchBar.setOnClickListener`); `searchBarViewDidTapWhileNotEditable` is called instead.
- L193 `fun searchBarViewDidTapWhileNotEditable(searchBarView: CYLSearchBarView) {}` — The bar was tapped while `searchBarViewShouldBeginEditing` refused editing.
- L198 `fun searchBarViewDidBeginEditing(searchBarView: CYLSearchBarView) {}` — Editing started.
- L203 `fun searchBarViewDidEndEditing(searchBarView: CYLSearchBarView) {}` — Editing ended.
- L208 `fun searchBarViewTextDidChange(searchBarView: CYLSearchBarView, text: String) {}` — The text changed (typing, the clear button, Cancel with `clearsTextOnCancel`).
- L213 `fun searchBarViewSearchButtonClicked(searchBarView: CYLSearchBarView) {}` — The keyboard's search key.
- L218 `fun searchBarViewCancelButtonClicked(searchBarView: CYLSearchBarView) {}` — Cancel was tapped.
- L223 `fun searchBarViewNavigationButtonClicked(searchBarView: CYLSearchBarView) {}` — The navigation button before the field (`navigationIcon`, `navigationImage`).
- L229 `fun searchBarViewVoiceButtonClicked(searchBarView: CYLSearchBarView) {}` — The voice button (`showsVoiceButton`). Start speech recognition here and pass the result to `setText(text, submit)`.
- L235 `fun searchBarViewShouldSubmitText(searchBarView: CYLSearchBarView, text: String): Boolean = true` — Asks whether the query may be submitted (the search key, the submit button or `setText(text, true)`). Return false to keep it. By default every non-empty query is submitted.
- L240 `fun searchBarViewDidChangeIconified(searchBarView: CYLSearchBarView, iconified: Boolean) {}` — The field opened or closed (`isIconified`).
- L246 `fun searchBarViewDidSelectItem(searchBarView: CYLSearchBarView, item: CYLSearchBarItem) {}` — An appended item was tapped (`CYLSearchBarView.addItem`), like `-tabBar:didSelectItem:` (iOS `-searchBarView:didSelectItem:`).
- L252 `fun searchBarViewTextDidChange(searchBarView: CYLSearchBarView, text: String, index: Int) {}` — `Multiple` mode: the text of the search being typed changed (MultiSearchView `onTextChanged`). `Single` mode calls `searchBarViewTextDidChange(searchBarView, text)` instead.
- L257 `fun searchBarViewDidCompleteSearch(searchBarView: CYLSearchBarView, text: String, index: Int) {}` — `Multiple` mode: a search was completed and became an entry (MultiSearchView `onSearchComplete`).
- L262 `fun searchBarViewDidRemoveSearchAtIndex(searchBarView: CYLSearchBarView, index: Int) {}` — `Multiple` mode: a search was removed (MultiSearchView `onSearchItemRemoved`).
- L267 `fun searchBarViewDidSelectSearch(searchBarView: CYLSearchBarView, text: String, index: Int) {}` — `Multiple` mode: a search was selected by a tap (MultiSearchView `onItemSelected`).
- L276 `class CYLSearchBarView @JvmOverloads constructor(` — A configurable search bar (iOS `CYLSearchBarView`): a rounded field with a magnifier, text and clear button, views of the host inside the field after the text (a camera, a "Search" button) or before the field (a back button), and an optional Cancel button. `mo
- L295 `var delegate: CYLSearchBarViewDelegate? = null` — Receives the events.
- L300 `val textField: EditText = object : EditText(context)` — The text field inside the field.
- L303 `override fun requestFocus(direction: Int, previouslyFocusedRect: Rect?): Boolean =` — A bar whose delegate refuses editing never takes the focus, also not when the window gives the focus back to the first focusable view after another view cleared it (that would loop: take it, refuse it, clear it).
- L310 `val fieldView: LinearLayout = CYLFieldLayout(context)` — The rounded field that holds the magnifier, the text and `trailingAccessoryViews`.
- L315 `val searchIconView: ImageView = ImageView(context)` — The magnifier at the start of the field (decorative: hidden from TalkBack).
- L320 `val cancelButton: TextView = TextView(context)` — The Cancel button after the field (`showsCancelButton`).
- L325 `val placeholderLabel: TextView = TextView(context)` — Draws the placeholder, cut off with an ellipsis when it does not fit.
- L331 `val navigationButton: ImageButton = iconButton()` — The button before the field. It is shown when `navigationIcon` is not `None` or `navigationImage` is set, and `leadingView` is null; taps call `searchBarViewNavigationButtonClicked` and `navigationHandler`.
- L336 `val voiceButton: ImageButton = iconButton()` — A microphone inside the field, shown while the text is empty; it calls `searchBarViewVoiceButtonClicked`.
- L341 `val submitButton: ImageButton = iconButton()` — A submit button inside the field, shown while there is text; it submits the query like the search key.
- L346 `val iconButton: ImageButton = iconButton()` — The button shown while `isIconified` is true. TalkBack reads it as "Search".
- L353 `var text: String?` — The text of the field. Setting it does not call `searchBarViewTextDidChange`, as on iOS.
- L366 `var placeholder: String? = null` — The placeholder, drawn by `placeholderLabel` and kept as the field's content description for TalkBack.
- L377 `var font: Typeface? = null` — The typeface of the text, the placeholder and Cancel. The default typeface when null.
- L386 `var fontSize: Float = 17f` — The text size in sp (the iOS font's point size). 17 by default (iOS body).
- L395 `var textColor: Int? = null` — The text color. The theme's primary text color when null.
- L404 `var placeholderColor: Int? = null` — The placeholder color. The theme's hint color when null.
- L414 `var cursorColor: Int? = null` — The color of the text cursor (MaterialSearchView `setCursorDrawable`). The accent color when null; needs API 29.
- L425 `var fieldHeight: Float = 36f` — The height of the field in dp; it grows when the text needs more. 36 by default.
- L434 `var contentInsets: Rect = Rect(12, 6, 12, 6)` — The space around the field in dp (left, top, right, bottom). (12, 6, 12, 6) by default.
- L443 `var fieldBackgroundColor: Int? = null` — The field's background. A light gray fill (iOS `tertiarySystemFillColor`) when null.
- L452 `var fieldCornerRadius: Float = -1f` — The field's corner radius in dp; negative makes a capsule. -1 by default.
- L461 `var fieldBorderColor: Int? = null` — The field's border color; null draws no border.
- L470 `var fieldBorderWidth: Float = 0f` — The field's border width in dp, used with `fieldBorderColor`. 0 by default.
- L479 `var fieldShadowOpacity: Float = 0f` — The field's shadow, 0 to 1 (drawn as elevation). 0 by default.
- L488 `var searchIcon: Drawable? = ContextCompat.getDrawable(context, R.drawable.cyl_search_ic_search)` — The magnifier; null shows none. A magnifier by default.
- L497 `var searchIconTintColor: Int? = null` — The magnifier's tint. The theme's secondary text color when null.
- L508 `var trailingAccessoryViews: List<View> = emptyList()` — Views of yours inside the field after the text.
- L522 `val items: List<CYLSearchBarItem>` — The appended items, in order, after the text and after `trailingAccessoryViews` (like the FlatDesign tab bar's `items`). The field stays; only items are appended.
- L528 `val itemViews: List<CYLTagButton>` — The views of `items` (`CYLTagButton`s), in the same order.
- L534 `var itemTintColor: Int? = null` — The icon and title color of every item without its own `tintColor`; null uses the primary text color.
- L543 `var searchBarStyle: CYLSearchBarStyle = CYLSearchBarStyle.Plain` — The fixed look of the bar. `Bordered` draws the field and its items inside one capsule outline.
- L552 `var fieldBackgroundImage: Drawable? = null` — An image drawn behind the field's content, clipped to its corners.
- L562 `val selectedItem: CYLSearchBarItem?` — The first selected item (a `isSelectable` item that is on), or null.
- L568 `val selectedIndex: Int` — The index of `selectedItem`, or -1.
- L574 `fun addItem(item: CYLSearchBarItem)` — Appends an item after the others.
- L581 `fun insertItem(item: CYLSearchBarItem, index: Int)` — Inserts an item at an index (clamped to `items`); an item already in a bar moves here.
- L595 `fun addItem(` — Creates an item and inserts it at an index; -1 or a larger index appends it. Mirrors `-addItemWithTitle:tabBarItemImage:tabBarItemSelectedImage:index:`.
- L611 `fun removeItem(item: CYLSearchBarItem)` — Removes an item from the bar.
- L624 `fun removeAllItems()` — Removes every item.
- L633 `fun setItems(maps: List<Map<String, Any?>>)` — Replaces the items with the ones the maps describe (`CYLSearchBarItem.fromMap`), as the cross-platform bridges send them. When only `animationLoops` and `animationSpeed` differ from the last call, the items stay and take the two values, so the animation is not
- L654 `fun hasItem(style: CYLSearchBarItemStyle): Boolean = mutableItems.any { it.style == style }` — True when an item of the style was appended (a text "Search" button), like `-hasPlusButton`.
- L663 `var showsSearchButton: Boolean = true` — Whether the bar shows its default search button after the field and the items: true by default (an editing bar and a bar in `Multiple` mode never show it). A tap calls `searchButtonHandler`, else submits the text (`submit()`), and tells the delegate `searchBar
- L674 `var searchButtonStyle: CYLSearchBarSearchButtonStyle = CYLSearchBarSearchButtonStyle.Icon` — Whether the default search button shows an icon (`Icon`, the default: a filled capsule 28 dp high in the inverse color) or a title (`Text`, opt-in; iOS `searchButtonStyle`).
- L684 `var searchButtonTitle: String? = null` — The title of the default search button (also its TalkBack label in the icon style); null is the localized "Search".
- L694 `var searchButtonImage: Drawable? = null` — The icon of the default search button in the `Icon` style; null is the core's built-in magnifier.
- L704 `var searchButtonHandler: ((CYLSearchBarView) -> Unit)? = null` — Called instead of the default action when the default search button is tapped.
- L710 `var searchButtonItem: CYLSearchBarItem = makeSearchButtonItem()` — The default search button as an item, for its tint, badge or accessibility identifier. It is not in `items`; it is replaced (the identifier kept) when the style, title or icon changes.
- L804 `fun applyNavigationFieldStyle()` — The navigation field preset (the Discover look), the one look of every search or text field in a navigation bar or page header on every platform (iOS `applyNavigationFieldStyle()`): a bordered capsule (corner radius 18 dp), a soft shadow (opacity 0.06), no mag
- L817 `fun applyPreset(preset: CYLSearchBarPreset)` — Applies one of the core's looks (iOS `applyPreset(_:)`). Every preset starts from the plain look, so applying another one replaces the first. Call it before `addItem` and `embedInToolbar`.
- L854 `var leadingView: View? = null` — A view of yours before the field (a back button); it wins over the navigation button.
- L867 `var showsCancelButton: Boolean = false` — Shows the Cancel button after the field. False by default.
- L876 `var cancelButtonTitle: String? = null` — The Cancel title. The localized "Cancel" when null.
- L886 `var cancelButtonEndsEditing: Boolean = true` — Taps on Cancel also end editing. True by default.
- L891 `var clearsTextOnCancel: Boolean = false` — Taps on Cancel also clear the text (lapism `setTextClearOnBackPressed`). False by default.
- L897 `var isEditingBar: Boolean = false` — Whether the bar is an editing bar (`editingBar`): an edit field in the search bar's look, whose trailing button submits instead of cancelling (iOS `isEditingBar`).
- L908 `var editingSubmitHandler: ((CYLSearchBarView, String) -> Unit)? = null` — An editing bar's submit: the trimmed text, when its action button or the action key is tapped (after `searchBarViewShouldSubmitText` and `searchBarViewSearchButtonClicked`). Empty text submits nothing (iOS `editingSubmitHandler`).
- L928 `var keyboardOverlapHandler: ((Int) -> Unit)? = null` — After `pinToKeyboard`: how far the keyboard covers the container's bottom, in pixels (0 while it is down), on every change; a host uses it to keep its own content above the keyboard (iOS: the keyboard layout guide).
- L930 `fun pinToKeyboard(container: ViewGroup)`
- L956 `var clearsTextOnEndEditing: Boolean = false` — Ending editing also clears the text (lapism `setTextClearOnClearFocus`). False by default.
- L963 `var navigationIcon: CYLSearchBarNavigationIcon = CYLSearchBarNavigationIcon.None` — A built-in navigation icon. `None` by default.
- L972 `var navigationImage: Drawable? = null` — A custom navigation icon; it wins over `navigationIcon`.
- L981 `var navigationAccessibilityLabel: String? = null` — What TalkBack reads for the navigation button. "Back" for the arrow and "Search" for the magnifier when null.
- L994 `var navigationBackgroundColor: Int? = null` — A circle drawn behind the navigation icon. Null (none) by default.
- L1003 `var navigationShadowOpacity: Float = 0f` — The shadow of that circle, 0 to 1 (lapism `setNavigationElevation`). 0 by default.
- L1012 `var navigationHandler: ((CYLSearchBarView) -> Unit)? = null` — Called on taps on the navigation button, after the delegate.
- L1019 `var showsVoiceButton: Boolean = false` — Shows `voiceButton` while the text is empty. False by default.
- L1028 `var voiceImage: Drawable? = null` — The voice button's icon. A microphone when null.
- L1038 `var showsSubmitButton: Boolean = false` — Shows `submitButton` while there is text (Android `isSubmitButtonEnabled`). False by default.
- L1047 `var submitImage: Drawable? = null` — The submit button's icon. An arrow in a circle when null.
- L1057 `var clearImage: Drawable? = null` — The clear button's icon, shown while editing with text. A cross in a circle when null.
- L1068 `var keyboardType: Int = InputType.TYPE_CLASS_TEXT` — The keyboard (an `InputType` class, iOS `keyboardType`). `InputType.TYPE_CLASS_TEXT` by default.
- L1077 `var returnKeyType: Int = EditorInfo.IME_ACTION_SEARCH` — The action key (an `EditorInfo.IME_ACTION_*`, iOS `returnKeyType`). `IME_ACTION_SEARCH` by default.
- L1087 `var autocapitalizationType: CYLTextAutocapitalizationType = CYLTextAutocapitalizationType.Sentences` — Automatic capitalization. `Sentences` by default.
- L1096 `var autocorrectionType: CYLTextAutocorrectionType = CYLTextAutocorrectionType.Default` — Automatic correction. `Default` by default.
- L1105 `var isSecureTextEntry: Boolean = false` — Hides the typed characters (Android `inputType="textPassword"`). False by default.
- L1114 `var maximumTextLength: Int = 0` — The longest text a person can type (Android `maxLength`); 0 means no limit. 0 by default.
- L1134 `var isIconified: Boolean` — Shows only a search button instead of the field (Android `SearchView.isIconified`). Tapping the button opens the field and starts editing. False by default.
- L1142 `var iconifiedByDefault: Boolean = false` — When true, the field closes back to its icon when editing ends with no text (Android `setIconifiedByDefault`). False by default.
- L1153 `var expansionAnimation: CYLSearchBarExpansionAnimation = CYLSearchBarExpansionAnimation.Fade` — How the field opens and closes. `Fade` by default.
- L1158 `var iconPosition: CYLSearchBarIconPosition = CYLSearchBarIconPosition.Trailing` — Where `iconButton` sits while iconified; the field opens from there. `Trailing` by default.
- L1167 `var animationDuration: Double = 0.3` — The length of the opening and closing animations, in seconds. 0.3 by default.
- L1174 `var mode: CYLSearchBarMode = CYLSearchBarMode.Single` — Whether the bar edits one query (`Single`, the default) or several searches side by side (`Multiple`).
- L1183 `val newSearchButton: ImageButton = ImageButton(context)` — In `Multiple` mode, the button at the end: it starts a new search, or completes the one being typed.
- L1189 `override fun handleOnBackPressed() = completeSearch()`
- L1195 `val searches: List<String>` — The texts of the searches in `Multiple` mode, completed searches first, then the one being typed.
- L1201 `val selectedSearchIndex: Int` — The selected search in `Multiple` mode, or -1 (iOS `NSNotFound`) when there is none.
- L1207 `val isEditingNewSearch: Boolean` — True while a new search is being typed in `Multiple` mode.
- L1213 `var minimumTextLength: Int = 3` — A search shorter than this is dropped by `completeSearch`. 3 by default, as in MultiSearchView.
- L1218 `var searchIndicatorColor: Int? = null` — The color of the indicator under the selected search and of `newSearchButton`. The accent color when null.
- L1227 `var unselectedSearchAlpha: Float = 0.5f` — The opacity of the searches that are not selected. 0.5 by default.
- L1236 `var searchFieldWidth: Float = 160f` — The width of the field of a new search, in dp. 160 by default.
- L1245 `var newSearchImage: Drawable? = null` — The icon of `newSearchButton`. A magnifier when null.
- L1255 `var removeSearchImage: Drawable? = null` — The icon of the remove button on the selected search. A cross in a circle when null.
- L1265 `fun beginNewSearch() = multiSearchContent.search()` — Starts a new search and shows the keyboard (MultiSearchView `search`). Does nothing while a search is typed.
- L1271 `fun completeSearch() = multiSearchContent.completeSearch()` — Completes the search being typed: it becomes the selected search, or is dropped when shorter than `minimumTextLength`.
- L1276 `fun addSearch(text: String) = multiSearchContent.addSearchText(text)` — Adds a completed search without typing it and selects it.
- L1281 `fun selectSearch(index: Int) = multiSearchContent.selectItemAtIndex(index)` — Selects a search, like a tap on it.
- L1286 `fun removeSearch(index: Int) = multiSearchContent.removeItemAtIndex(index)` — Removes a search, like a tap on its remove button.
- L1297 `override fun onConfigurationChanged(newConfig: android.content.res.Configuration)` — A live light/dark switch re-resolves every default color: the placeholder, the items, the dividers and a bordered field.
- L1306 `override fun onAttachedToWindow()`
- L1325 `var dismissesKeyboardOnOutsideTouch: Boolean = true` — Whether a touch anywhere in the window outside this bar (a tap, or the start of a scroll or drag in any container) hides the keyboard while the field is editing (iOS `dismissesKeyboardOnOutsideTouch`). True by default; an editing bar (`isEditingBar`) drives it
- L1361 `override fun onDetachedFromWindow()`
- L1382 `var focusesOnAppear: Boolean = false` — Whether the field takes focus (and the soft keyboard shows) every time the bar appears on screen, like a `viewDidAppear`: the first time its page is entered, after a tab switch or a push and pop (the view is attached again or becomes visible), when the window 
- L1398 `override fun onResume(owner: LifecycleOwner)`
- L1426 `var pageDepth: Int? = null` — The depth of the page that holds the bar: 0 is a first-level page (a root tab, the first page of a stack), 1 or more a second-level or deeper page. A host that knows its navigation sets it (a Flutter route, a React Native navigator, a custom stack). Null (defa
- L1429 `val isOnSecondLevelOrDeeperPage: Boolean` — True on a second-level or deeper page: `pageDepth` above 0, else the fragment back stack has entries.
- L1454 `override fun onWindowFocusChanged(hasWindowFocus: Boolean)`
- L1459 `override fun onVisibilityChanged(changedView: View, visibility: Int)`
- L1485 `val isActive: Boolean` — Whether the bar is being edited (the field has the focus): the "active" state of `textFieldMarginsProvider`, `cancelButtonMarginsProvider` and `centersPlaceholder` (iOS: the search controller is active).
- L1492 `var centersPlaceholder: Boolean = false` — Draws the placeholder (and the magnifier) in the middle of the field while the bar is not being edited and the text is empty, and at the start otherwise (QMUI `qmui_centerPlaceholder`). False by default.
- L1502 `var textFieldMargins: Rect = Rect()` — The space around the field in dp (left, top, right, bottom) on top of `contentInsets`, in both states. Zero by default; `textFieldMarginsProvider` wins when it is set.
- L1512 `var textFieldMarginsProvider: ((CYLSearchBarView, Boolean) -> Rect)? = null` — The field's margins in dp for each state: the bar and whether it is active (iOS `textFieldMarginsProvider`). Null uses `textFieldMargins`.
- L1523 `var cancelButtonMargins: Rect = Rect()` — The space around the Cancel button in dp (left, top, right, bottom) on top of the 8 dp gap. A negative left value pulls Cancel toward the field, at most until it touches it: Cancel never covers the field. Zero by default; `cancelButtonMarginsProvider` wins whe
- L1533 `var cancelButtonMarginsProvider: ((CYLSearchBarView, Boolean) -> Rect)? = null` — Cancel's margins in dp for each state (iOS `cancelButtonMarginsProvider`), see `cancelButtonMargins`. Null uses `cancelButtonMargins`.
- L1542 `var cancelButtonFont: Typeface? = null` — The typeface of the Cancel button. `font` when null.
- L1552 `var cancelButtonFontSize: Float? = null` — The text size of the Cancel button in sp, the size half of iOS `cancelButtonFont` (a `UIFont` has both). `fontSize` when null.
- L1562 `var showsCancelButtonWhenEditing: Boolean = false` — Shows Cancel while the bar is being edited, as a `UISearchBar` does in a search (also when `showsCancelButton` is false). False by default.
- L1571 `var tintColor: Int? = null` — The color of Cancel and of the cursor (iOS `tintColor`). The accent color when null.
- L1581 `var showsLeadingView: Boolean` — Whether the view before the field (`leadingView`, or the navigation button) is shown (iOS `showsLeadingView`). True by default; a hidden view gives its room to the field. `setShowsLeadingView` animates it.
- L1589 `var showsTrailingAccessoryViews: Boolean` — Whether `trailingAccessoryViews` are shown (iOS `showsTrailingAccessoryViews`). True by default; hidden views give their room to the text. `setShowsTrailingAccessoryViews` animates them.
- L1597 `var leadingAccessoryView: View?` — The same view as `leadingView` (QMUI `qmui_leftAccessoryView`).
- L1607 `var showsLeadingAccessoryView: Boolean` — The same flag as `showsLeadingView`.
- L1617 `var leadingAccessoryViewMargins: Rect = Rect()` — The space around the view before the field in dp (left, top, right, bottom), as padding of its slot. Zero by default.
- L1627 `var trailingAccessoryView: View?` — The first of `trailingAccessoryViews` (QMUI `qmui_rightAccessoryView`); setting it makes it the only one.
- L1637 `var showsTrailingAccessoryView: Boolean` — The same flag as `showsTrailingAccessoryViews`.
- L1648 `var trailingAccessoryViewMargins: Rect = Rect()` — The space around each of `trailingAccessoryViews` in dp (left, top, right, bottom), on top of the 8 dp gap. Zero by default.
- L1658 `var usedAsTableHeaderView: Boolean = false` — Whether the bar is a list's header item (QMUI `qmui_usedAsTableHeaderView`). Set by the screens that install the bar as the first item of a list (`CYLSearchListView`, `CYLSearchView.installSearchBar`); false by default.
- L1664 `var alwaysEnablesCancelButton: Boolean = true` — Whether the Cancel button stays enabled while the field is not being edited (QMUI `qmui_alwaysEnableCancelButton`). False disables it until the field has the focus. True by default.
- L1674 `val backgroundView: View?` — The view that draws the bar's background (QMUI `qmui_backgroundView`): the bar itself, whose `background` is the bar's image, color and border (`CYLSearchBarAppearance.barBackgroundImage`, `barBackgroundColor`, `barBorderColor`).
- L1681 `var scopeButtonTitles: List<String> = emptyList()` — The titles of the scope bar under the field (iOS `UISearchBar.scopeButtonTitles`); empty (the default) has none. The first title is selected; read the selection from `segmentedControl`.
- L1691 `val segmentedControl: RadioGroup?` — The scope bar, a segmented `RadioGroup` under the field (QMUI `qmui_segmentedControl`); null without `scopeButtonTitles`. One button per title; `checkedRadioButtonId` and `setOnCheckedChangeListener` read the selection.
- L1733 `var appearanceStyle: CYLSearchBarAppearance? = null` — The merged default style (iOS `appearanceStyle`): applying it sets the properties it covers; a property set after it wins. Null until set; `applyDefaultAppearance` sets the default.
- L1742 `fun applyDefaultAppearance()` — Applies `CYLSearchBarAppearance.defaultAppearance` (iOS `applyDefaultAppearance`).
- L1750 `fun setShowsLeadingView(shows: Boolean, animated: Boolean)` — Shows or hides the view before the field, with an animation when `animated` is true (iOS `setShowsLeadingView(_:animated:)`). The last call decides: two quick calls end in the state of the second.
- L1759 `fun setShowsTrailingAccessoryViews(shows: Boolean, animated: Boolean)` — Shows or hides `trailingAccessoryViews`, with an animation when `animated` is true (iOS `setShowsTrailingAccessoryViews(_:animated:)`). The last call decides.
- L1768 `fun setShowsLeadingAccessoryView(shows: Boolean, animated: Boolean) = setShowsLeadingView(shows, animated)` — The same as `setShowsLeadingView`.
- L1774 `fun setShowsTrailingAccessoryView(shows: Boolean, animated: Boolean) = setShowsTrailingAccessoryViews(shows, animated)` — The same as `setShowsTrailingAccessoryViews`.
- L1779 `fun setShowsCancelButton(shows: Boolean, animated: Boolean)` — Shows or hides Cancel, with an animation when `animated` is true (iOS `setShowsCancelButton(_:animated:)`).
- L1844 `fun set(shows: Boolean, animated: Boolean)`
- L2019 `fun setText(text: String?, submit: Boolean)` — Sets the text and, when `submit` is true and the text is not empty, submits it as if the search key were tapped (MaterialSearchView `setQuery`, lapism `setTextQuery`).
- L2030 `fun submit(): Boolean` — Submits the current text: asks `searchBarViewShouldSubmitText`, then calls `searchBarViewSearchButtonClicked`. Returns false when the text is empty or the delegate refused it.
- L2045 `fun showKeyboard()` — Starts editing and shows the keyboard. When `searchBarViewShouldBeginEditing` refuses, reports a tap instead.
- L2060 `fun hideKeyboard()` — Ends editing and hides the keyboard.
- L2169 `fun setIconified(iconified: Boolean, animated: Boolean)` — Opens or closes the field, with `expansionAnimation` when `animated` is true. Opening also starts editing.
- L2251 `override fun onSaveInstanceState(): Parcelable = Bundle().apply`
- L2259 `override fun onRestoreInstanceState(state: Parcelable?)`
- L2272 `override fun dispatchSaveInstanceState(container: android.util.SparseArray<Parcelable>) = dispatchFreezeSelfOnly(container)`
- L2274 `override fun dispatchRestoreInstanceState(container: android.util.SparseArray<Parcelable>) = dispatchThawSelfOnly(container)`
- L2320 `override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int)` — The field never gets taller than the bar: a host that is shorter than the field plus `contentInsets` (a 44 dp toolbar slot of a Flutter or React Native page) first takes the space from the insets above and below the field, then from the field; before, the fiel
- L2478 `override fun requestFocus(direction: Int, previouslyFocusedRect: Rect?): Boolean = textField.requestFocus(direction, previouslyFocusedRect)` — Starts editing in the text field (iOS `becomeFirstResponder`).
- L2483 `override fun clearFocus()` — Ends editing in the text field and hides the keyboard (iOS `resignFirstResponder`).
- L2539 `fun applyStyle()`
- L2631 `fun search()`
- L2652 `fun completeSearch()`
- L2671 `fun addSearchText(text: String)`
- L2688 `fun selectItemAtIndex(index: Int)`
- L2704 `fun removeItemAtIndex(index: Int)`
- L2754 `fun embedInToolbar(toolbar: androidx.appcompat.widget.Toolbar): androidx.appcompat.widget.Toolbar` — Puts this bar into `toolbar` as a custom view that FILLS the space between the navigation icon (the back arrow) and the end of the toolbar: the core sizes it (match parent width inside the Toolbar, which measures a custom view in what the navigation button and
- L2794 `fun embedInToolbar(activity: Activity, content: ViewGroup): androidx.appcompat.widget.Toolbar` — Same, for an activity: the existing action bar's toolbar (the AppCompat decor toolbar) when there is one, otherwise a toolbar the core creates and inserts at the top of `content` (a vertical LinearLayout or any other ViewGroup, index 0). After the call the bar
- L2815 `var backButtonProgress: Float = 0f` — How far the back button is in, 0 (first-level page: no back button, the bar fills the whole width) to 1 (second-level page: the back button at the start, the bar narrowed). Set by `showBackButton`, `hideBackButton` and `setBackButtonProgress`; the core lays th
- L2821 `val isBackButtonShown: Boolean get() = backButtonProgress >= 1f` — True while the back button is fully in (`backButtonProgress` is 1).
- L2827 `var backButtonHandler: (() -> Unit)? = null` — Called when the back button is tapped. Null (default): the bar asks the host activity's back dispatcher, the same as the system back gesture.
- L2832 `var backButtonDrawable: Drawable? = null` — The back button's drawable. Null (default): the core's arrow in the primary text color.
- L2841 `var onFirstLevelTap: (() -> Unit)? = null` — Makes this bar the push trigger of a first-level page (the default behaviour of a navigation-embedded bar, iOS `onFirstLevelTap`): a tap on the field (not on its items or the search button) does not edit; the core calls `showBackButton(true)` (the back button 
- L2846 `val pushesOnTap: Boolean get() = onFirstLevelTap != null && !isBackButtonShown` — True when `onFirstLevelTap` is set and no back button is shown, so a tap on the field pushes.
- L2852 `var respectsSafeArea: Boolean = true` — Follows the system safe area (system bars and display cutout at the left and right) with the toolbar's padding when the bar is in a toolbar, so the whole bar fills the width inside it. True by default; read by `embedInToolbar`.
- L2867 `fun showBackButton(animated: Boolean = true)` — Brings the back button in (iOS `showBackButton(animated:)`): the navigation icon fades and slides in at the start of the toolbar while the bar's start inset and width follow, 0.25 s. Without animation the final state at once. Does nothing when the bar is not i
- L2877 `fun hideBackButton(animated: Boolean = true, completion: (() -> Unit)? = null)` — Takes the back button out (iOS `hideBackButton(animated:)`), the reverse of `showBackButton`: the bar's width back to full. `completion` runs when it is out (at once without animation).
- L2885 `fun setBackButtonProgress(progress: Float)` — Sets the back button's progress by hand, 0 to 1, for an interactive gesture (predictive back drives it with the gesture's progress); `showBackButton` / `hideBackButton` finish it.
- L2895 `fun backPressedCallback(onBack: () -> Unit): OnBackPressedCallback = object : OnBackPressedCallback(true)` — A back-press callback for the second-level page of this bar (iOS: the interactive pop): with predictive back the back button and the bar's width follow the gesture, a cancel brings them in again, a commit runs `hideBackButton` and then `onBack` (the page pops)
- L2896 `override fun handleOnBackProgressed(backEvent: androidx.activity.BackEventCompat)`
- L2900 `override fun handleOnBackCancelled() = showBackButton(true)`
- L2902 `override fun handleOnBackPressed() = hideBackButton(true) { onBack() }`
- L2979 `fun contains(view: View): Boolean`
- L2991 `override fun onInterceptTouchEvent(event: MotionEvent): Boolean`
- L2999 `override fun onTouchEvent(event: MotionEvent): Boolean`
- L3017 `fun performFirstLevelTap()` — What a tap on the first-level field does (also for a test or an accessibility action): `showBackButton(true)`, then `onFirstLevelTap`. Does nothing without `onFirstLevelTap` or when the back button is already in.
- L3027 `var embedsInToolbar: Boolean = false` — True once `embedInToolbar` put this bar into a toolbar.
- L3112 `fun textFieldBackgroundImage(color: Int?): Drawable? = color?.let { ColorDrawable(it) }` — A drawable of a text field in `color`, for `fieldBackgroundImage` and `CYLSearchBarAppearance.textFieldBackgroundImage` (QMUI `qmui_generateTextFieldBackgroundImageWithColor:`); null for a null color. The field clips its corners.
- L3119 `fun backgroundImage(color: Int?, borderColor: Int?): Drawable?` — A drawable for the bar's `background`: `color` (white by default) with a one pixel bottom border in `borderColor`, or null when both are null (QMUI `qmui_generateBackgroundImageWithColor:borderColor:`).
- L3140 `fun editingBar(context: Context, placeholder: String?, actionTitle: String): CYLSearchBarView =` — An editing bar (iOS `editingBar(placeholder:actionTitle:)`): the search bar's field and look for editing a name (a tag, a title), without the magnifier, with `actionTitle` ("Add", "Done") as its trailing button, which submits through `editingSubmitHandler`, as
- L3160 `enum class CYLSearchBarItemStyle` — How an item appended to a search bar looks (iOS `CYLSearchBarItemStyle`).
- L3180 `enum class CYLSearchBarSearchButtonStyle` — What the default search button of a bar shows (iOS `CYLSearchBarSearchButtonStyle`).
- L3195 `enum class CYLSearchBarStyle` — The fixed look of the whole bar (iOS `CYLSearchBarStyle`): the field stays, the items are appended after its text.
- L3210 `enum class CYLSearchBarItemState` — The item states for text attributes (iOS `UIControlState`).
- L3230 `data class CYLSearchBarItemTextAttributes(` — Title or badge text attributes (iOS `NSAttributedString` attributes): a color in ARGB, a size in sp, a typeface.
- L3231 `val color: Int? = null,`
- L3232 `val sizeSp: Float? = null,`
- L3233 `val typeface: Typeface? = null,`
- L3240 `class CYLSearchBarItem @JvmOverloads constructor(` — One element after the text of a `CYLSearchBarView`: a model independent of its view (iOS `CYLSearchBarItem`, like `CYLFlatDesignTabBarItem`). Append it with `CYLSearchBarView.addItem`; its view is `itemView`.
- L3244 `val style: CYLSearchBarItemStyle,` — How the item looks (icon, divider or text); set when the item is created.
- L3252 `var title: String? = title` — The text of a text item, and the TalkBack label of an icon item without `itemAccessibilityLabel`.
- L3258 `var image: Drawable? = image` — The icon (tinted with `tintColor`).
- L3264 `var selectedImage: Drawable? = null` — The icon while `isSelected` is true; null uses `image`.
- L3270 `var animatedImage: Drawable? = null` — An animated icon (an `AnimatedVectorDrawable` or `AnimationDrawable`), started when shown; it wins over `image`.
- L3278 `var animationURL: Uri? = null` — An animated icon file (Lottie .json, .pag, .riv, .svga, .gif), drawn by the item's `CYLTagButton` (a `CYLAnimatedItemView`) when the app adds the file's animation library (the core adds none) and played on each tap. Otherwise `image` shows, or the component's 
- L3284 `var animationLoops: Boolean = false` — Whether `animationURL` plays again after each pass; false plays once on each tap. The same on every platform.
- L3291 `var animationSpeed: Float = 1f` — The playback speed of `animationURL`; 1 is the file's own. An engine without speed ignores it. The same on every platform.
- L3298 `fun restartAnimation()` — Plays `animationURL` again from the start, as a tap does. Does nothing without an animation. The same on every platform.
- L3307 `var imageSize: SizeF? = null` — The icon size in dp; null uses 20 x 20 dp.
- L3313 `var itemAccessibilityLabel: String? = null` — What TalkBack reads; null reads `title`.
- L3319 `var itemAccessibilityIdentifier: String? = null` — A test tag for the item view (its content description stays `itemAccessibilityLabel`).
- L3325 `var isEnabled: Boolean = true` — False dims the item and ignores taps. True by default.
- L3331 `var isSelectable: Boolean = false` — True makes each tap toggle `isSelected` (a filter that stays on). False by default.
- L3336 `var isSelected: Boolean = false` — The selected state (drawn with `selectedImage`, `selectedBackgroundColor` and the selected text attributes).
- L3342 `var tintColor: Int? = null` — The icon and title color; null uses the bar's `itemTintColor`.
- L3348 `var backgroundColor: Int? = null` — The item background; null is transparent.
- L3355 `var cornerRadius: Float = AUTOMATIC_CORNER_RADIUS` — The corner radius of the item's background and border in dp: 0 is square, `CAPSULE_CORNER_RADIUS` a capsule, `AUTOMATIC_CORNER_RADIUS` (the default) 10 dp with a background and square without one (iOS `cornerRadius`).
- L3361 `var borderColor: Int? = null` — The border color of the item's own outline; null (the default) draws none.
- L3367 `var borderWidth: Float = 0f` — The width of the item's own outline in dp; 0 by default.
- L3373 `var itemHeight: Float = 0f` — The height of the item in dp; 0 (the default) is the 36 dp touch size.
- L3379 `var selectedBackgroundColor: Int? = null` — The item background while selected; null uses `backgroundColor`.
- L3385 `var contentInsets: FloatArray? = null` — Padding around the icon and title, in dp (start, top, end, bottom); null uses the style's default.
- L3391 `var imagePositionAdjustment: FloatArray = floatArrayOf(0f, 0f)` — Moves the icon, in dp (x, y), without changing the item's size.
- L3397 `var titlePositionAdjustment: FloatArray = floatArrayOf(0f, 0f)` — Moves the title, in dp (x, y), without changing the item's size.
- L3403 `var badgeValue: String? = null` — The badge text; null hides the badge, an empty string draws a dot.
- L3409 `var badgeColor: Int? = null` — The badge background; null is red.
- L3415 `var badgeSize: Float = 0f` — The smallest badge size in dp; 0 uses 16 dp (a dot is 8 dp).
- L3421 `var badgeContentInsets: FloatArray = floatArrayOf(4f, 0f, 4f, 0f)` — Padding around the badge text, in dp (start, top, end, bottom).
- L3427 `var badgePositionAdjustment: FloatArray = floatArrayOf(0f, 0f)` — Moves the badge from the icon's top end corner, in dp (x, y).
- L3433 `var handler: ((CYLSearchBarItem) -> Unit)? = null` — Called on each tap, after `CYLSearchBarViewDelegate.searchBarViewDidSelectItem`.
- L3438 `var searchBarView: CYLSearchBarView? = null` — The bar the item was appended to; null before `addItem` and after `removeItem`.
- L3444 `val index: Int` — The item's position in its bar's `items`; -1 when it is in no bar.
- L3468 `fun itemView(context: Context): CYLTagButton = loadItemView(context)` — The item's view, a `CYLTagButton` (CollectionViewClassifyMenu), created on first use with the bar's context (or the given one).
- L3473 `val itemView: CYLTagButton?` — The item's view once created, or null.
- L3485 `fun setTitleTextAttributes(attributes: CYLSearchBarItemTextAttributes?, state: CYLSearchBarItemState)` — The title attributes for a state.
- L3493 `fun titleTextAttributes(state: CYLSearchBarItemState): CYLSearchBarItemTextAttributes? = titleAttributes[state]` — The title attributes set for a state, or null.
- L3498 `fun setBadgeTextAttributes(attributes: CYLSearchBarItemTextAttributes?, state: CYLSearchBarItemState)` — The badge text attributes for a state.
- L3506 `fun badgeTextAttributes(state: CYLSearchBarItemState): CYLSearchBarItemTextAttributes? = badgeAttributes[state]` — The badge text attributes set for a state, or null.
- L3511 `fun actualBadgeSuperView(): View? = view` — The view the badge is drawn in (the item view), or null before it exists.
- L3540 `fun iconItem(image: Drawable?, title: String?, handler: ((CYLSearchBarItem) -> Unit)?): CYLSearchBarItem =` — An icon item: the title is what TalkBack reads.
- L3547 `fun textItem(title: String, handler: ((CYLSearchBarItem) -> Unit)?): CYLSearchBarItem =` — A text item (a "Search" button).
- L3554 `fun divider(): CYLSearchBarItem = CYLSearchBarItem(CYLSearchBarItemStyle.Divider)` — A divider between two items.
- L3563 `fun fromMap(context: Context, map: Map<String, Any?>): CYLSearchBarItem` — An item from plain values, for the cross-platform wrappers (Flutter, React Native): `style` (`icon`, `divider`, `text`), `title`, `image` (`camera`, `mic`, `search`, `back`, else a drawable name of the app), `accessibilityIdentifier`, `isEnabled`, `isSelectabl
- L3612 `val item: CYLSearchBarItem = item` — The item this view draws.
- L3629 `fun actualBadgeSuperView(): View = this` — The view the badge is drawn in (this view).
- L3635 `override fun accessibilityText(): CharSequence` — What TalkBack reads (CYLAnimatedItemView's hook, which sets the content description on every state change): the item's accessibility label or its title, also for an icon item that shows no title.
- L3757 `override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int)`
- L3789 `override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int)`
- L3872 `override fun dispatchTouchEvent(event: MotionEvent): Boolean`
- L3896 `var trailingGroup: CYLTrailingGroup? = null`
- L3899 `override fun dispatchTouchEvent(event: MotionEvent): Boolean`

## `android/merged/cylsearch/src/main/kotlin/com/cyl/search/CYLSearchHeaderSnapper.kt`

Keeps a header search bar scrollable and settles it (iOS `CYLSearchHeaderSnapper`). `header` is the first item of `recyclerView`. It adds room below the last item so that the header can scroll out of sight even above a list shorter than the screen (a list of three rows is shorter than the screen), and settles the header fully shown or fully hidden when the scrolling ends (QMUI issues #1160 and #12

- L17 `val header: View,`
- L26 `var isEnabled: Boolean = true` — False takes the room and the settling away.
- L36 `override fun onScrollStateChanged(recyclerView: RecyclerView, newState: Int)`
- L44 `override fun getItemOffsets(outRect: Rect, view: View, parent: RecyclerView, state: RecyclerView.State)`
- L62 `fun detach()` — Removes what the snapper added to the list.
- L74 `fun settle()` — When the header is half scrolled out, scrolls the list until it is fully shown, or fully hidden once more than half of it is out. Does nothing while disabled or while the search is open.
- L89 `fun refresh()` — Reads the room below the last item again; the list is laid out again when it changed.

## `android/merged/cylsearch/src/main/kotlin/com/cyl/search/CYLSearchListView.kt`

Ported from QMUI_iOS (Tencent, MIT): QMUICommonTableViewController (Search) and the header snapping of docs/qmui-search-controller.md, row I4.

- L23 `open class CYLSearchListView @JvmOverloads constructor(` — A list screen with a built-in search bar (iOS `CYLSearchTableViewController`; QMUI `QMUICommonTableViewController` with `shouldShowSearchBar`): a `RecyclerView` whose first item is `searchBarView`, so the bar scrolls with the list and never covers a row. By de
- L41 `val recyclerView: RecyclerView = RecyclerView(context)` — The list (iOS `tableView`). Its first item is the search bar and its last item is the room that lets the bar scroll out; `adapter` is what is between them.
- L46 `val searchBarView: CYLSearchBarView = CYLSearchBarView(context)` — The search bar, the first item of the list (iOS `searchBar`). Style it directly.
- L51 `val searchView: CYLSearchView = CYLSearchView(context)` — The search page that opens over the list when the bar is tapped (iOS `searchController`).
- L56 `var adapter: RecyclerView.Adapter<*>?` — The rows between the bar and the room below them. Setting it replaces the previous one.
- L72 `var showsSearchBar: Boolean = true` — Shows the bar as the first item of the list (iOS `showsSearchBar`). True by default.
- L83 `var hidesSearchBarInitially: Boolean = false` — Scrolls the bar out when the list first shows rows, and again after `hideEmptyView` (iOS `hidesSearchBarInitially`); a pull down or a drag reveals it. False by default.
- L94 `var hidesSearchBarWhenEmptyViewShowing: Boolean = true` — Removes the bar from the list while `showEmptyView`'s placeholder shows, and puts it back after (iOS `hidesSearchBarWhenEmptyViewShowing`, QMUI #128). True by default.
- L103 `var opensSearchViewOnTap: Boolean = true` — A tap on the bar opens `searchView` instead of editing the bar in place. True by default.
- L109 `var snapsHeaderSearchBar: Boolean = true` — Settles the bar fully shown or fully hidden when scrolling ends, and keeps room below the last row so a short list can scroll the bar out (iOS `snapsHeaderSearchBar`, I4). True by default.
- L118 `val isEmptyViewShowing: Boolean` — True while `showEmptyView` has its placeholder over the list (iOS `isEmptyViewShowing`).
- L124 `val footerHeight: Int` — The height of the room below the last row, in pixels: the part of the bar that a short list could not scroll out.
- L130 `val searchBarHiddenHeight: Int` — The part of the bar that is out of sight above the list, in pixels: 0 fully shown, the bar's height fully hidden.
- L137 `override fun onChanged() = changed()`
- L138 `override fun onItemRangeInserted(positionStart: Int, itemCount: Int) = changed()`
- L139 `override fun onItemRangeRemoved(positionStart: Int, itemCount: Int) = changed()`
- L140 `override fun onItemRangeChanged(positionStart: Int, itemCount: Int) = changed()`
- L194 `open fun setUpSearchBar() {}` — Called once, when the list is first attached to a window, after the default setup of `searchBarView` (appearance, Cancel, tap to open `searchView`): override it to configure the bar (iOS `setUpSearchBar()`, QMUI `initSearchController`, which subclasses extend)
- L201 `open fun updateResultsForSearchString(searchString: String) {}` — Called on every text change of `searchView`, also with "" (iOS `searchController(_:updateResultsFor:)`, QMUI `searchController:updateResultsForSearchString:`): override it to fill the results of `searchView`. Does nothing by default; `searchView.delegate` repl
- L203 `override fun onAttachedToWindow()`
- L222 `fun settleSearchBar()` — Settles the bar: when it is half scrolled out, scrolls the list until it is fully shown, or fully hidden once more than half of it is out (QMUI #1160). The list calls it when scrolling ends; `snapsHeaderSearchBar` false turns it off.
- L239 `fun showEmptyView(text: String?, detailText: String? = null, buttonTitle: String? = null, buttonAction: (() -> Unit)? = null)` — Puts CYLTableViewPlaceHolder's "no results" placeholder over the list, with a title, an optional detail and an optional button (iOS `showEmptyView`); the bar leaves the list when `hidesSearchBarWhenEmptyViewShowing` is true.
- L248 `fun hideEmptyView()` — Removes the placeholder; the bar comes back hidden when `hidesSearchBarInitially` is true.
- L291 `fun refresh()`
- L300 `override fun getItemCount(): Int = if (shown) 1 else 0`
- L302 `override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder`
- L310 `override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) = Unit`
- L317 `fun update(newHeight: Int)`
- L325 `override fun getItemCount(): Int = 1`
- L327 `override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder`
- L334 `override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int)`

## `android/merged/cylsearch/src/main/kotlin/com/cyl/search/CYLSearchNavigationBar.kt`

A toolbar the core creates for a screen that has none, holding the search bar in the space the navigation icon leaves (iOS `CYLSearchNavigationBar`, a `UINavigationBar` holding the search bar as its title view). `CYLSearchBarView.embedInToolbar` makes one when the activity has no action bar; the cross-platform bridges use `holding` as the content of their native view.

- L15 `class CYLSearchNavigationBar @JvmOverloads constructor(` — A toolbar the core creates for a screen that has none, holding the search bar in the space the navigation icon leaves (iOS `CYLSearchNavigationBar`, a `UINavigationBar` holding the search bar as its title view). `CYLSearchBarView.embedInToolbar` makes one when
- L24 `var backHandler: (() -> Unit)? = null` — Called when the back button is tapped (a bar made with `showsBackButton`); the bar itself never navigates, the host decides (a Flutter route pops, a React Native screen closes).
- L43 `fun holding(searchBar: CYLSearchBarView): CYLSearchNavigationBar = holding(searchBar, false)` — A toolbar holding `searchBar`, with the bar set up for it (36 dp field, 4 dp above and below, `embedsInToolbar`). The bridges use it as the content of their native view.
- L50 `fun holding(searchBar: CYLSearchBarView, showsBackButton: Boolean): CYLSearchNavigationBar` — As `holding(searchBar)`, and with `showsBackButton` the toolbar has the back arrow of a second-level page at its start (the search bar takes the width that is left). A tap on it calls `backHandler`.
- L69 `enum class CYLSearchBarPreset` — The looks of a search bar the core ships, one per tab of the example (`CYLSearchBarView.applyPreset`); the same names on every platform (iOS `CYLSearchBarPreset`).



_Continues in [part 2](02-android-core-part2.md)._

> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Script-generated index of declarations, comments and test names; comments are quoted, not verified.

# HarmonyOS core: files and declarations

> **Generated mechanically** (regex extraction) from the source text read in the 2026-11-29 learn-codebase pass: HEAD `ad32984` plus the uncommitted working-tree changes. It is an index, not a review: a regex can miss or mis-pick a declaration, and "doc" is the comment found above it. Every line number was matched against the working tree with `git grep` on 2026-11-29. A declaration the regex missed is simply absent. Check the file before relying on a line.

| File | Lines |
|:---|---:|
| `harmonyos/cylsearch/build-profile.json5` | 13 |
| `harmonyos/cylsearch/hvigorfile.ts` | 6 |
| `harmonyos/cylsearch/Index.ets` | 57 |
| `harmonyos/cylsearch/oh-package.json5` | 12 |
| `harmonyos/cylsearch/src/main/ets/CYLSearchBar.ets` | 241 |
| `harmonyos/cylsearch/src/main/ets/CYLSearchBarView.ets` | 3485 |
| `harmonyos/cylsearch/src/main/ets/CYLSearchController.ets` | 655 |
| `harmonyos/cylsearch/src/main/ets/CYLSearchNavigationBar.ets` | 126 |
| `harmonyos/cylsearch/src/main/ets/CYLSearchResources.ets` | 513 |
| `harmonyos/cylsearch/src/main/ets/CYLSearchTableViewController.ets` | 177 |
| `harmonyos/cylsearch/src/main/ets/CYLSearchTagListStyle.ets` | 242 |
| `harmonyos/cylsearch/src/main/ets/CYLSearchView.ets` | 2236 |
| `harmonyos/cylsearch/src/main/module.json5` | 7 |

## `harmonyos/cylsearch/Index.ets`

cylsearch: the search core of CYLSearchViewController in ArkTS, with the iOS names (docs/search-core-merge.md, "Target design"): the merged classes (CYLSearchBarView, CYLSearchBarItem, CYLSearchView, CYLSearchResources), the components that draw them, the QMUI-shaped fronts of the iOS UIKit classes (CYLSearchBar, CYLSearchController, CYLSearchTableViewController, CYLSearchNavigationBar) and the ta

## `harmonyos/cylsearch/src/main/ets/CYLSearchBar.ets`

A search bar that is styled by `CYLSearchBarAppearance` and adds what QMUI's `QMUISearchBar` adds to a platform search bar: a centered placeholder, placeholder and text colors and fonts, margins of the text field and the Cancel button, accessory views and a Cancel button that stays enabled (iOS `CYLSearchBar`, a `UISearchBar`). On HarmonyOS the bar is the model `CYLSearchBarView` that `CYLSearchBa

- L10 `export class CYLSearchBar` — A search bar that is styled by `CYLSearchBarAppearance` and adds what QMUI's `QMUISearchBar` adds to a platform search bar: a centered placeholder, placeholder and text colors and fonts, margins of the text field and the Cancel button, accessory views and a Ca
- L37 `get appearanceStyle(): CYLSearchBarAppearance` — The style applied to the bar (a copy of `CYLSearchBarAppearance.defaultAppearance` when the bar is created). Assigning a style applies it.
- L41 `set appearanceStyle(value: CYLSearchBarAppearance)`
- L49 `get centersPlaceholder(): boolean` — Whether the magnifier and the placeholder are centered in the field while the bar is not editing and has no text (QMUI `qmui_centerPlaceholder`). Default false.
- L53 `set centersPlaceholder(value: boolean)`
- L60 `get placeholderColor(): ResourceColor | undefined` — The placeholder's color (QMUI `qmui_placeholderColor`).
- L64 `set placeholderColor(value: ResourceColor | undefined)`
- L71 `get textColor(): ResourceColor | undefined` — The color of the typed text (QMUI `qmui_textColor`).
- L75 `set textColor(value: ResourceColor | undefined)`
- L82 `get font(): number` — The font size, in fp, of the typed text and of the placeholder (QMUI `qmui_font`).
- L86 `set font(value: number)`
- L94 `get textFieldMargins(): CYLSearchEdgeInsets` — The margins added to the text field's frame (QMUI `qmui_textFieldMargins`). A positive value shrinks the field, a negative one grows it.
- L98 `set textFieldMargins(value: CYLSearchEdgeInsets)`
- L106 `get textFieldMarginsProvider(): ((active: boolean) => CYLSearchEdgeInsets) | undefined` — Returns the margins of the text field for the bar's state (true while searching); wins over `textFieldMargins` (QMUI `qmui_textFieldMarginsBlock`).
- L110 `set textFieldMarginsProvider(value: ((active: boolean) => CYLSearchEdgeInsets) | undefined)`
- L119 `get cancelButtonFont(): number | undefined` — The font size of the Cancel button's title, in fp (QMUI `qmui_cancelButtonFont`); undefined uses `font`.
- L123 `set cancelButtonFont(value: number | undefined)`
- L131 `get cancelButtonMarginsProvider(): ((active: boolean) => CYLSearchEdgeInsets) | undefined` — Returns the margins applied to the Cancel button for the bar's state (true while searching); a negative left value moves it left and widens it (QMUI `qmui_cancelButtonMarginsBlock`).
- L135 `set cancelButtonMarginsProvider(value: ((active: boolean) => CYLSearchEdgeInsets) | undefined)`
- L145 `get alwaysEnablesCancelButton(): boolean` — Whether the Cancel button stays enabled although the field is not being edited (QMUI `qmui_alwaysEnableCancelButton`). Default true.
- L149 `set alwaysEnablesCancelButton(value: boolean)`
- L156 `get leadingAccessoryView(): WrappedBuilder<[]> | undefined` — The view left of the text field (QMUI `qmui_leftAccessoryView`).
- L160 `set leadingAccessoryView(value: WrappedBuilder<[]> | undefined)`
- L167 `get showsLeadingAccessoryView(): boolean` — Whether the leading accessory view is shown (QMUI `qmui_showsLeftAccessoryView`), without animation. Default true.
- L171 `set showsLeadingAccessoryView(value: boolean)`
- L178 `get leadingAccessoryViewMargins(): CYLSearchEdgeInsets` — The space around the leading accessory view; `right` is the gap to the text field.
- L182 `set leadingAccessoryViewMargins(value: CYLSearchEdgeInsets)`
- L189 `get trailingAccessoryView(): WrappedBuilder<[]> | undefined` — The view right of the text field (QMUI `qmui_rightAccessoryView`).
- L193 `set trailingAccessoryView(value: WrappedBuilder<[]> | undefined)`
- L200 `get showsTrailingAccessoryView(): boolean` — Whether the trailing accessory view is shown (QMUI `qmui_showsRightAccessoryView`), without animation. Default true.
- L204 `set showsTrailingAccessoryView(value: boolean)`
- L211 `get trailingAccessoryViewMargins(): CYLSearchEdgeInsets` — The space around the trailing accessory view; `left` is the gap to the text field.
- L215 `set trailingAccessoryViewMargins(value: CYLSearchEdgeInsets)`
- L222 `applyDefaultAppearance(): void` — Applies `CYLSearchBarAppearance.defaultAppearance` (QMUI `qmui_styledAsQMUISearchBar`).
- L230 `setShowsLeadingAccessoryView(shows: boolean, animated: boolean): void` — Shows or hides the leading accessory view, optionally sliding it (QMUI `qmui_setShowsLeftAccessoryView:animated:`). Toggling quickly ends in the last requested state.
- L238 `setShowsTrailingAccessoryView(shows: boolean, animated: boolean): void` — Shows or hides the trailing accessory view, optionally sliding it (QMUI `qmui_setShowsRightAccessoryView:animated:`). Toggling quickly ends in the last requested state.

## `harmonyos/cylsearch/src/main/ets/CYLSearchBarView.ets`

- L16 `function cylSearchTextLimited(text: string, maximumTextLength: number): string` — The text cut to `maximumTextLength` characters; unchanged when the limit is 0 or less (Android `CYLMultiSearchView` text limit).
- L24 `function cylSearchTextCompletes(text: string, minimumTextLength: number): boolean` — Whether a typed search becomes a search of `searches` when completed: not empty and at least `minimumTextLength` characters, the text as typed, not trimmed (Android `CYLMultiSearchView.completeSearch`).
- L33 `function cylSelectionAfterRemoval(selectedIndex: number, removedIndex: number, countAfter: number): number` — The selected index after the search at `removedIndex` was removed, with `countAfter` searches left: the next one when the selected one (or none) was removed, the previous one when the last went away, the same one shifted when an earlier one went away, -1 when 
- L50 `function cylSearchTextSubmittable(text: string): boolean` — Whether the search bar submits `text`: anything but blank text (Android `CYLSearchBarView.submit`; the delegate still receives the text untrimmed).
- L59 `interface CYLSearchNavigationFieldPreset` — The navigation field preset, the Discover look every screen uses (iOS `applyNavigationFieldStyle()`): a bordered capsule (corner radius 18) with a soft shadow (opacity 0.06), no magnifier, 16 fp text (fp scales with the system font size). The fill is opaque wh
- L67 `function cylSearchNavigationFieldPreset(): CYLSearchNavigationFieldPreset`
- L74 `interface CYLSearchBarItemButtonContent<T>` — What the `CYLTagButton` of a search bar item shows (iOS `CYLSearchBarItemButton.reload()`).
- L87 `function cylSearchBarItemButtonContent<T>(style: number, title: string | undefined, image: T | undefined,` — The content of an item's `CYLTagButton` for an item of `style` (0 icon, 1 divider, 2 text, as `CYLSearchBarItemStyle`): a text item shows its title (and its icon before it), an icon item only its icon (its title is what screen readers read), a divider nothing.
- L104 `const CYLSearchBarDividerHeight = 20;` — The built-in divider's height in vp (its width is 1).
- L110 `const CYLSearchBarSecondaryLabel: Resource = $r('app.color.cyl_search_secondary_label');` — The secondary label color (light rgba(60,60,67,0.60), dark rgba(235,235,245,0.60)): the resource has a dark qualifier, so the system re-resolves it when the appearance changes, with no listener.
- L117 `function cylSearchBarItemInsets(style: number, contentInsets: number, hasShape: boolean): number` — The horizontal padding of an item in vp: its own when 0 or more, else 0 for the divider (style 1: the group's spacing alone puts the gaps beside it), 4 for a text item (style 2) that draws a shape of its own and 0 for the others (a plain text item hugs its tit
- L127 `interface CYLSearchTouchRegion` — A touch region in vp, relative to a view.
- L138 `function cylSearchTouchRegion(width: number, height: number, minimum: number): CYLSearchTouchRegion` — The touch region of a view of `width` x `height`: the view grown around its center to at least `minimum` on each side (44 vp, the screen reader touch target), so a small icon stays easy to tap without changing the layout.
- L153 `export interface CYLSearchEdgeInsets` — Space around a view in vp (iOS `UIEdgeInsets`).
- L177 `function cylSearchPlaceholderCentered(centers: boolean, editing: boolean, text: string, hasPlaceholder: boolean): boolean` — Whether the placeholder is drawn centered with the magnifier: only at rest (not editing), with no text, a placeholder and `centersPlaceholder` on (iOS `CYLSearchBar.centersPlaceholder`: centered at rest, leading while editing).
- L185 `function cylSearchResolvedInsets(provided: CYLSearchEdgeInsets | undefined, fixed: CYLSearchEdgeInsets): CYLSearchEdgeInsets` — The margins to apply: what the provider answers for the state (iOS `textFieldMarginsProvider(bar, active)`, which wins), else the fixed margins.
- L193 `function cylSearchCancelVisible(shows: boolean, automatic: boolean, active: boolean): boolean` — Whether Cancel is drawn: asked for with `showsCancelButton`, or automatically while the bar is active (iOS `automaticallyShowsCancelButton`).
- L200 `const CYL_SEARCH_PLAYBACK_KEYS: string[] = ['animationLoops', 'animationSpeed'];` — The keys of an item dictionary that only change how its animation plays (iOS `CYLSearchBarView.playbackKeys`).
- L206 `function cylSearchItemShape(dictionary: Record<string, Object>): string` — The shape of an item dictionary: its keys and values without the playback keys, in key order, so two dictionaries that differ only in playback have the same shape (iOS `setItems(dictionaries:)`'s `shapes`).
- L215 `function cylSearchItemShapesMatch(previous: string[] | undefined, next: string[], itemCount: number): boolean` — Whether the items of the last `setItems` call can stay: the shapes are the same and no item was added or removed in another way since (the bar still has one item per shape).
- L226 `function cylSearchCancelEnabled(always: boolean, editing: boolean): boolean` — Whether Cancel is enabled: always with `alwaysEnablesCancelButton` (iOS `CYLSearchBar.alwaysEnablesCancelButton`, QMUI `qmui_alwaysEnableCancelButton`), else only while the field is being edited (UIKit disables Cancel when editing ends).
- L235 `function cylSearchShouldFocusOnAppear(focusesOnAppear: boolean, isOnSecondLevelOrDeeperPage: boolean,` — Whether the bar takes focus when it appears (iOS `focusIfAppearing`): `focusesOnAppear` is on, the bar's page is a SECOND-LEVEL OR DEEPER page (Navigation stack depth above 1; a first-level page, a root tab or the first page of a stack, never auto-focuses), th
- L244 `function cylSearchVisibilityAppeared(wasVisible: boolean, ratio: number): boolean` — Whether a visible-area change is an appearance: the bar was hidden (ratio 0) and now shows (ratio above 0). A change between two visible ratios is not (the bar stayed on screen).
- L254 `const CYL_SEARCH_BACK_SLOT_WIDTH: number = 32;` — The width of the back button's slot in the navigation title bar when it is fully shown, in vp.
- L260 `const CYL_SEARCH_TITLE_INSET_HIDDEN: number = 16;` — The side inset of the title bar: 16 vp (the page margin) without a back button, 6 vp with one (the button brings its own touch padding).
- L261 `const CYL_SEARCH_TITLE_INSET_SHOWN: number = 6;`
- L268 `function cylSearchBackButtonRequest(currentlyShown: boolean, wantsShown: boolean, animated: boolean): number` — What a request to show or hide the back button does: 0 nothing (the button is already as requested), 1 applies at once, 2 applies animated. Asking for the state the button has is a no-op, so a push and a stack callback that both ask do not run the animation tw
- L278 `function cylSearchBackButtonProgress(progress: number): number` — The progress (0 hidden, 1 shown) clamped to its range; a NaN is 0.
- L288 `function cylSearchBackSlotWidth(progress: number): number` — The width of the back button's slot at `progress`: the slot grows from 0 to 32 vp, and the bar takes what is left.
- L295 `function cylSearchTitleLeadingInset(progress: number): number` — The leading inset of the title bar at `progress`: 16 vp hidden, 6 vp shown.
- L305 `function cylSearchBarWidth(containerWidth: number, progress: number): number` — The width the search bar gets in a title bar of `containerWidth` (the width inside the safe area) at `progress`: the whole bar width at 0, narrower by the back slot and the smaller inset at 1. Pages never compute it, the title bar lays the bar out with it.
- L316 `function cylSearchFirstLevelTapAction(pushesOnTap: boolean, backButtonShown: boolean): number` — What a tap on the bar does: 0 the bar edits as usual (not a first-level bar), 1 the tap is a push (the back button comes in and `onFirstLevelTap` runs), 2 nothing (a first-level bar whose back button is already shown: the push is under way, a second tap must n
- L327 `function cylSearchBackButtonWantedFor(targetIsRootPage: boolean): boolean` — Whether the back button belongs to the page a `Navigation` is about to show: the root (first-level) page has none, any pushed page has one. The system back gesture and the back button both end in this question.
- L335 `interface CYLSearchBarPresetSpec` — The look of a bar preset, one per tab of the example (`CYLSearchBarPreset`): 0 navigationField (the Discover look), 1 pill, 2 rounded, 3 outlined, 4 centeredCapsule. `cornerRadius` -1 is a full capsule.
- L345 `function cylSearchBarPresetSpec(preset: number): CYLSearchBarPresetSpec`
- L368 `const CYL_SEARCH_ITEM_CORNER_RADIUS_AUTOMATIC = -1;` — The item corner radius that means "automatic" (10 with a background, else square; iOS `automaticCornerRadius`).
- L374 `const CYL_SEARCH_ITEM_CORNER_RADIUS_CAPSULE = 1000;` — The item corner radius that makes a capsule (iOS `CYLAnimatedItemCornerRadiusCapsule`, the same 1000 as `CYLSearchTagListStyle.capsuleCornerRadius`).
- L379 `const CYL_SEARCH_ITEM_MINIMUM_SIDE = 36;` — The side of an item's smallest size and touch target, in vp.
- L384 `const CYL_SEARCH_BUTTON_ICON_HEIGHT = 28;` — The height of the `icon` style of the default search button (a filled capsule), in vp.
- L389 `const CYL_SEARCH_BUTTON_ICON_INSETS = 16;` — The side insets of the `icon` style of the default search button, in vp.
- L394 `function cylSearchItemResolvedCornerRadius(cornerRadius: number, hasBackground: boolean): number` — The corner radius an item is drawn with: its own unless automatic, which is 10 with a background and square without.
- L404 `function cylSearchItemResolvedHeight(itemHeight: number): number` — The height of an item's view: its own `itemHeight` when above 0, else the 36 vp minimum.
- L412 `const CYL_SEARCH_TRAILING_SPACING = 8;` — The space between two elements of the trailing group (camera, divider, search button), and before the first one, in vp: the only space the group has (the `Row` spacing of the bar's field).
- L417 `const CYL_SEARCH_TOUCH_WIDTH = 36;` — The touch width of a plain item in vp: widened by `responseRegion`, never by empty room around the glyph.
- L424 `function cylSearchItemHugsContent(style: number, hasShape: boolean, itemHeight: number): boolean` — Whether an item hugs its content (owner, 2026-11-26): a plain icon or text item (no background, no outline, no custom height) is as wide as its glyph or title; an item with a shape of its own (the icon search capsule) keeps its size. A divider never hugs.
- L438 `interface CYLSearchTrailingElement` — One element of the trailing group, for `cylSearchTrailingGroupLayout`: `style` 0 icon, 1 divider, 2 text; `contentWidth` is the glyph or title width in vp.
- L448 `interface CYLSearchTrailingPlacement` — Where an element sits in the group and where it takes touches, in vp from the group's left edge.
- L462 `function cylSearchTrailingGroupLayout(elements: CYLSearchTrailingElement[], spacing: number): CYLSearchTrailingPlacement[]` — The layout of the trailing group: `elements` from the left; the group puts `spacing` before each element and nothing else (no empty room inside an item). A hugging item is as wide as its content and its hit area is widened to 36 vp about its center; an item wi
- L485 `function cylSearchButtonVisible(showsSearchButton: boolean, isEditingBar: boolean, isMultiple: boolean): boolean` — Whether a bar draws the default search button: `showsSearchButton`, never for an editing bar or in multiple mode.
- L492 `function cylSearchButtonHasDivider(ownerItemCount: number): boolean` — Whether a divider precedes the search button: only when an owner's item comes before it.
- L501 `interface CYLSearchButtonLook` — The look of the default search button: `style` 0 text, 1 icon. Text: a text item with the custom title or the localized default and no fill. Icon: an icon item (the custom image, else the built-in magnifier) as a filled capsule 28 high with 16 side insets; its
- L511 `function cylSearchButtonLook(style: number, customTitle: string | undefined, defaultTitle: string,`
- L528 `function cylSearchButtonTrailingInset(fieldHeight: number, itemHeight: number, usualInset: number,` — The trailing inset of the field's content in vp: with the filled `icon` style as the last element the pill sits concentric in the field, so the gap at its right equals the gap above and below, (fieldHeight - itemHeight) / 2 (4 for a 36 vp field and a 28 vp pil
- L537 `function cylSearchButtonTapAction(text: string | undefined): number` — What a tap on the search button does with the bar's text: 1 submit it (not empty), 0 only tell the listener (empty text: `searchButtonClicked` fires too).
- L548 `function cylAnimate(uiContext: UIContext | undefined, param: AnimateParam, change: () => void): void` — Animates `change` with the UI context of the component that draws the model (`UIContext.animateTo`). Before any component has drawn the model there is nothing on screen to animate: the change is applied at once and `onFinish` is called.
- L560 `const CYLSearchBarItemMinimumSide: number = 36;` — The smallest side of an item's view in vp (iOS `CYLSearchBarItemButton.minimumTouchSide`).
- L565 `export const CYLSearchBarItemCornerRadiusAutomatic: number = -1;` — `CYLSearchBarItem.cornerRadius` automatic: 10 with a background, square without (iOS `automaticCornerRadius`).
- L570 `export const CYLSearchBarItemCornerRadiusCapsule: number = 1000;` — `CYLSearchBarItem.cornerRadius` capsule (iOS `CYLAnimatedItemCornerRadiusCapsule`).
- L575 `const CYLSearchTouchTargetSide: number = 44;` — The smallest touch target in vp: an item's touch region grows to it.
- L580 `function cylLength(length: Length | undefined): number` — A `Length` of a `Position` in vp: a number as it is, anything else (a percentage, a resource) 0.
- L587 `export enum CYLSearchBarMode` — What a `CYLSearchBarView` edits (iOS `CYLSearchBarMode`).
- L602 `export enum CYLSearchBarItemStyle` — How an item appended to a search bar looks (iOS `CYLSearchBarItemStyle`).
- L620 `export enum CYLSearchBarSearchButtonStyle` — How the default search button looks (iOS `CYLSearchBarSearchButtonStyle`).
- L635 `export enum CYLSearchBarStyle` — The fixed look of the whole bar (iOS `CYLSearchBarStyle`): the field stays, the items are appended after its text.
- L649 `export enum CYLSearchBarPreset` — The looks of a search bar the core ships, one per tab of the example (`CYLSearchBarView.applyPreset`).
- L675 `export enum CYLSearchBarItemState` — The item states for text attributes (iOS `UIControlState`).
- L693 `export class CYLSearchBarItemTextAttributes` — Title or badge text attributes (iOS `NSAttributedString` attributes).
- L713 `export class CYLSearchBarItem` — One element after the text of a `CYLSearchBarView`: a model independent of its view (iOS `CYLSearchBarItem`, like `CYLFlatDesignTabBarItem`). Append it with `CYLSearchBarView.addItem`; the bar draws it.
- L866 `get itemView(): CYLTagButton` — The item's view, a `CYLTagButton` (CollectionViewClassifyMenu, the one icon + title + animated icon component), created on first use and styled from the item; `CYLSearchBarComponent` draws it and sends its taps to `CYLSearchBarViewDelegate.searchBarViewDidSele
- L878 `restartAnimation(): void` — Plays `animationURL` again from the start, as a tap does. Does nothing without an animation. The same on every platform.
- L889 `reloadItemView(barTint: ResourceColor | undefined): CYLTagButton` — Styles `itemView` from the item for its current state (iOS `CYLSearchBarItemButton.reload()`): no border, the item's background (transparent by default), its tint (`barTint` when it has none) for the title and the icon, its title attributes, icon size, insets,
- L956 `get drawsShape(): boolean` — Whether the item draws a shape of its own (a background or an outline): it keeps its size (iOS item with a background).
- L964 `get hugsContent(): boolean` — Whether the item hugs its content in the trailing group (`cylSearchItemHugsContent`).
- L974 `static resolvedTint(hostTint: ResourceColor | undefined, selected: boolean): ResourceColor` — The icon and title color of an item in a state: the host's tint (the item's `tintColor`, else the bar's `itemTintColor`) overrides everything; with none, normal is the label color (black in light, white in dark), selected the accent. Both are system resources,
- L984 `get index(): number` — The item's position in its bar's `items`; -1 when it is in no bar.
- L991 `get currentState(): CYLSearchBarItemState` — The state the item is drawn in.
- L1011 `static textItem(title: string, handler?: (item: CYLSearchBarItem) => void): CYLSearchBarItem` — A text item, a "Search" button (iOS `+textItemWithTitle:handler:`).
- L1020 `static divider(): CYLSearchBarItem` — A divider between two items (iOS `+dividerItem`).
- L1029 `static item(dictionary: Record<string, Object>): CYLSearchBarItem` — An item from plain values, as the cross-platform wrappers send them (iOS `+itemWithDictionary:`): `style` (`icon`, `divider`, `text`), `title`, `image` (`camera`, `mic`, `search`, `back`), `accessibilityIdentifier`, `isEnabled`, `isSelectable`, `isSelected`, `
- L1069 `setTitleTextAttributes(attributes: CYLSearchBarItemTextAttributes | undefined, state: CYLSearchBarItemState): void` — The title attributes for a state (iOS `-setTitleTextAttributes:forState:`).
- L1081 `titleTextAttributes(state: CYLSearchBarItemState): CYLSearchBarItemTextAttributes | undefined` — The title attributes set for a state, or undefined (iOS `-titleTextAttributesForState:`).
- L1088 `setBadgeTextAttributes(attributes: CYLSearchBarItemTextAttributes | undefined, state: CYLSearchBarItemState): void` — The badge text attributes for a state (iOS `-setBadgeTextAttributes:forState:`).
- L1100 `badgeTextAttributes(state: CYLSearchBarItemState): CYLSearchBarItemTextAttributes | undefined` — The badge text attributes set for a state, or undefined (iOS `-badgeTextAttributesForState:`).
- L1108 `export enum CYLSearchBarNavigationIcon` — The icon of the button before the field (iOS `CYLSearchBarNavigationIcon`).
- L1126 `export enum CYLSearchBarIconPosition` — Where the search button sits while the bar is iconified (iOS `CYLSearchBarIconPosition`).
- L1144 `export enum CYLSearchBarExpansionAnimation` — How the field opens from the search button (iOS `CYLSearchBarExpansionAnimation`).
- L1159 `export interface CYLSearchBarViewDelegate` — The events of a `CYLSearchBarView` (iOS `CYLSearchBarViewDelegate`); every method is optional.
- L1233 `export class CYLSearchBarAppearance` — The style of a search bar as one value (iOS `CYLSearchBarAppearance`): fonts, colors, the field's and the bar's backgrounds and the icons. `CYLSearchBarAppearance.defaultAppearance` is the merged default style (the grey field, the blue tint, "Search" and "Canc
- L1307 `copy(): CYLSearchBarAppearance` — A copy with the same values.
- L1336 `export class CYLSearchBarView` — A configurable search bar (iOS `CYLSearchBarView`): a rounded field with a magnifier, text and clear button, appended items after the text, a button before the field and an optional Cancel button. With `mode` set to `multiple` it edits several searches side by
- L1595 `get hasSearchButton(): boolean` — Whether the bar draws the search button now (`showsSearchButton`, not an editing bar, not `multiple` mode).
- L1604 `get searchButtonItem(): CYLSearchBarItem` — The item the bar draws as its search button (iOS `searchButtonItem`): not in `items`; it follows `searchButtonStyle`, `searchButtonTitle` and `searchButtonImage`, and a change of one of them builds it again. Customize it (a tint, a badge) after setting those.
- L1635 `searchButtonTapped(): void` — The search button was tapped: submits the text (`submit()`); an empty text only tells the delegate (`searchBarViewSearchButtonClicked`); then `searchButtonHandler` runs (iOS `searchButtonTapped`).
- L1828 `performFirstLevelTap(): void` — The tap of a first-level bar, also callable from code (iOS `performFirstLevelTap()`): back button in, then `onFirstLevelTap`. Does nothing without `pushesOnTap` or when the back button is already in.
- L1835 `get searchBarStyle(): CYLSearchBarStyle` — The fixed look of the bar. `bordered` draws the field and its items inside one capsule outline.
- L1839 `set searchBarStyle(value: CYLSearchBarStyle)`
- L1856 `applyNavigationFieldStyle(): void` — The look of the input box of a navigation bar, the one every screen uses: a bordered capsule (corner radius 18) with a soft shadow (opacity 0.06), an opaque white (light) or black (dark) fill, no magnifier, 16 fp text. Call it before `addItem()` and `CYLSearch
- L1874 `get isActive(): boolean` — Whether the bar is active: being edited, or its host (an open `CYLSearchView`) says so (iOS: the search controller is active).
- L1881 `get cancelButtonVisible(): boolean` — Whether Cancel is drawn (`showsCancelButton`, or `automaticallyShowsCancelButton` while active).
- L1888 `get cancelButtonEnabled(): boolean` — Whether Cancel can be tapped now (`alwaysEnablesCancelButton`, or the field is being edited).
- L1895 `get placeholderCentered(): boolean` — Whether the placeholder is drawn centered now.
- L1902 `get resolvedTextFieldMargins(): CYLSearchEdgeInsets` — The field's margins for the current state.
- L1909 `get resolvedCancelButtonMargins(): CYLSearchEdgeInsets` — Cancel's margins for the current state (zero without a provider).
- L1917 `get appearanceStyle(): CYLSearchBarAppearance` — The style values as last applied with `appearanceStyle` (a copy).
- L1925 `set appearanceStyle(value: CYLSearchBarAppearance)` — Applies a style to the bar in one step (iOS `appearanceStyle`): fonts, colors, field and bar backgrounds, icons. A value left undefined keeps the bar's own.
- L1956 `get leadingAccessoryView(): WrappedBuilder<[]> | undefined` — The same view as `leadingView`. @deprecated Use `leadingView`.
- L1960 `set leadingAccessoryView(value: WrappedBuilder<[]> | undefined)`
- L1968 `get showsLeadingAccessoryView(): boolean` — The same flag as `showsLeadingView`. @deprecated Use `showsLeadingView`.
- L1972 `set showsLeadingAccessoryView(value: boolean)`
- L1980 `get trailingAccessoryView(): WrappedBuilder<[]> | undefined` — The same view as `trailingAccessoryViews`. @deprecated Use `trailingAccessoryViews`.
- L1984 `set trailingAccessoryView(value: WrappedBuilder<[]> | undefined)`
- L1992 `get showsTrailingAccessoryView(): boolean` — The same flag as `showsTrailingAccessoryViews`. @deprecated Use `showsTrailingAccessoryViews`.
- L1996 `set showsTrailingAccessoryView(value: boolean)`
- L2004 `setShowsCancelButton(shows: boolean, animated: boolean): void` — Shows or hides Cancel, animated over `animationDuration` when `animated` is true (iOS `setShowsCancelButton(_:animated:)`).
- L2019 `setShowsLeadingView(shows: boolean, animated: boolean): void` — Shows or hides `leadingView`, animated when `animated` is true (iOS `setShowsLeadingView(_:animated:)`). The state is a flag, so fast toggling ends in the last request.
- L2034 `setShowsTrailingAccessoryViews(shows: boolean, animated: boolean): void` — Shows or hides `trailingAccessoryViews`, animated when `animated` is true (iOS `setShowsTrailingAccessoryViews(_:animated:)`).
- L2049 `setShowsLeadingAccessoryView(shows: boolean, animated: boolean): void` — The same as `setShowsLeadingView(_:animated:)`. @deprecated Use `setShowsLeadingView`.
- L2057 `setShowsTrailingAccessoryView(shows: boolean, animated: boolean): void` — The same as `setShowsTrailingAccessoryViews(_:animated:)`. @deprecated Use `setShowsTrailingAccessoryViews`.
- L2064 `get isIconified(): boolean` — Whether the bar shows only its search button.
- L2071 `get itemViews(): CYLTagButton[]` — The views of `items` (`CYLTagButton`s, CollectionViewClassifyMenu), in the same order (iOS `itemViews`).
- L2078 `get selectedItem(): CYLSearchBarItem | undefined` — The first selected item (a `isSelectable` item that is on), or undefined.
- L2085 `get selectedIndex(): number` — The index of `selectedItem`, or -1.
- L2092 `addItem(item: CYLSearchBarItem): void` — Appends an item after the others (iOS `-addItem:`).
- L2099 `insertItem(item: CYLSearchBarItem, index: number): void` — Inserts an item at an index, clamped to `items` (iOS `-insertItem:atIndex:`).
- L2124 `removeItem(item: CYLSearchBarItem): void` — Removes an item from the bar (iOS `-removeItem:`).
- L2137 `removeAllItems(): void` — Removes every item.
- L2150 `setItems(dictionaries: Record<string, Object>[]): void` — Replaces the items with the ones the dictionaries describe (iOS `-setItemsWithDictionaries:`, `CYLSearchBarItem.item`), as the cross-platform bridges send them. When only `animationLoops` and `animationSpeed` differ from the last call, the items stay and take 
- L2170 `applyDefaultAppearance(): void` — Applies `CYLSearchBarAppearance.defaultAppearance` (the same method as `CYLSearchBar`).
- L2177 `hasItem(style: CYLSearchBarItemStyle): boolean` — True when an item of the style was appended (iOS `-hasItemOfStyle:`).
- L2184 `itemTapped(item: CYLSearchBarItem): void` — An item was tapped: a selectable item toggles, then the delegate and the item's handler are told.
- L2198 `setText(text: string | undefined, submit: boolean): void` — Sets the text and, when `submit` is true, submits it (iOS `-setText:submit:`).
- L2226 `static editingBar(placeholder: ResourceStr | undefined, actionTitle: ResourceStr): CYLSearchBarView` — An editing bar (iOS `editingBar(placeholder:actionTitle:)`): the search bar's field and look for editing a name (a tag, a title), without the magnifier, with `actionTitle` ("Add", "Done") as its trailing button, which submits through `editingSubmitHandler`, as
- L2244 `pinToKeyboard(context: UIContext): void` — Pins the bar to the top of the keyboard (iOS `pinToKeyboard(in:)`): the page resizes for the keyboard (`KeyboardAvoidMode.RESIZE`), so a bar placed at the bottom of the page rides on the keyboard while it is up and stays at the bottom while it is down.
- L2251 `enterKeyTapped(): void` — The enter key: an editing bar submits through `editingSubmitHandler`, a search bar submits its text.
- L2273 `submit(): boolean` — Submits the text like the search key; false when the text is empty or the delegate refuses it.
- L2288 `showKeyboard(): void` — Focuses the field, which raises the keyboard.
- L2318 `get isOnSecondLevelOrDeeperPage(): boolean` — True when the bar's page is a second-level or deeper page (`pageDepth` above 1); iOS `isOnSecondLevelOrDeeperPage`.
- L2344 `get isBackButtonShown(): boolean` — Whether the back button is shown (or coming in).
- L2352 `showBackButton(animated: boolean = true): void` — Brings the back button in on the left; the bar narrows to make room. With `animated` the change animates, with the bar's `animationDuration` (default 0.25 s). Asking twice is a no-op (iOS mirrors the name).
- L2359 `hideBackButton(animated: boolean = true): void` — Takes the back button out; the bar grows back to its full width. The reverse of `showBackButton`.
- L2384 `firstLevelTapped(): void` — The tap of a first-level bar (the title bar calls it): back button in, then `onFirstLevelTap`. Does nothing for a bar that is not first-level, or when the push is already under way.
- L2396 `syncBackButton(targetIsRootPage: boolean, animated: boolean): void` — Keeps the back button in step with the page a `Navigation` shows: a pushed page has it, the first-level (root) page has not. Called by the title bar from the stack's interception, also for the system back gesture.
- L2403 `applyPreset(preset: CYLSearchBarPreset): void` — Applies one of the looks the core ships (`CYLSearchBarPreset`); call it before `addItem()` on a new bar.
- L2428 `barDidAppear(): void` — The bar appeared on screen: focuses the field when `focusesOnAppear` is on. Called by the component; a host calls it from `onPageShow`.
- L2454 `becomeFirstResponder(): boolean` — Focuses the field and returns true (iOS `-becomeFirstResponder`).
- L2462 `resignFirstResponder(): boolean` — Ends editing and returns true (iOS `-resignFirstResponder`).
- L2470 `hideKeyboard(): void` — Ends editing, which lowers the keyboard.
- L2478 `setIconified(iconified: boolean, animated: boolean): void` — Opens or closes the field, animated over `animationDuration` when `animated` is true (iOS `-setIconified:animated:`). Opening also starts editing.
- L2506 `encodeRestorableState(): Record<string, Object>` — The state to keep across a restart: the text and whether the bar is iconified (iOS `-encodeRestorableStateWithCoder:`).
- L2514 `decodeRestorableState(state: Record<string, Object>): void` — Restores what `encodeRestorableState` returned (iOS `-decodeRestorableStateWithCoder:`).
- L2522 `get searches(): string[]` — `multiple` mode: the searches, the completed ones first, then the new one while it is typed (iOS `searches`).
- L2529 `get completedSearchTexts(): string[]` — `multiple` mode: the completed searches, as the bar draws them.
- L2536 `get isEditingNewSearch(): boolean` — `multiple` mode: true while a new search is being typed (iOS `isEditingNewSearch`).
- L2544 `beginNewSearch(): void` — `multiple` mode: starts a new search and shows the keyboard, like the new-search button (iOS `-beginNewSearch`). Does nothing in `single` mode or while a new search is being typed.
- L2559 `completeSearch(): void` — `multiple` mode: completes the new search: it joins `searches` and is selected, or is dropped when shorter than `minimumTextLength` (iOS `-completeSearch`).
- L2580 `addSearch(text: string): void` — `multiple` mode: adds a completed search without typing it and selects it (iOS `-addSearch:`). A search being typed is completed first; the added search is not reported.
- L2594 `selectSearch(index: number): void` — `multiple` mode: selects a search, like a tap on it (iOS `-selectSearchAtIndex:`).
- L2609 `removeSearch(index: number): void` — `multiple` mode: removes a search, like a tap on its remove button (iOS `-removeSearchAtIndex:`).
- L2624 `handleBackPress(): boolean` — The system Back gesture: in `multiple` mode, completes the new search being typed and returns true; false otherwise. Call it from the page's `onBackPress()` and return its result.
- L2636 `get intrinsicContentSize(): number` — The bar's height: the field and the insets above and below it; one row of searches in `multiple` mode (iOS `intrinsicContentSize`).
- L2647 `textChanged(text: string): void` — The component reports a new text; the delegate is told when it differs (`searchBarViewTextDidChange`, or `searchBarViewTextDidChangeAtIndex` in `multiple` mode).
- L2663 `editingChanged(editing: boolean): void` — The component reports that editing started or ended.
- L2687 `cancelTapped(): void` — Cancel was tapped.
- L2705 `navigationTapped(): void` — The button before the field was tapped.
- L2713 `voiceTapped(): void` — The microphone was tapped.
- L2720 `get navigationSymbol(): Resource | undefined` — The symbol of the button before the field, or undefined when it is hidden.
- L2740 `struct CYLSearchBarItemView` — The view of a `CYLSearchBarItem` (was the public `CYLSearchBarItemView`; like `CYLFlatDesignTabBarButton`): the item's `itemView`, CollectionViewClassifyMenu's `CYLTagButton` (drawn through `CYLTagButtonHost`, its V1 bridge), styled from the item; a divider is
- L2782 `build()`
- L2817 `struct CYLSearchBarSearchesView` — Draws a `CYLSearchBarView` in `multiple` mode (was `CYLMultiSearchComponent`): the searches in a row that scrolls, the field of the new search, and the new-search button at the trailing end.
- L2837 `build()`
- L2937 `export struct CYLSearchBarComponent` — Draws a `CYLSearchBarView`: the button before the field, the field (magnifier, text, clear button, voice or submit button, appended items) and Cancel; while iconified, only the search button; in `multiple` mode, the searches side by side with the field of a ne
- L2952 `emptyBuilder()`
- L2993 `aboutToAppear(): void`
- L3005 `aboutToDisappear(): void`
- L3048 `accessory(builder: WrappedBuilder<[]>, insets: CYLSearchEdgeInsets)`
- L3057 `field()`
- L3212 `build()`
- L3221 `singleBar()`
- L3314 `export const CYL_SEARCH_NAVIGATION_FIELD_HEIGHT: number = 36;` — The height of the search field embedded in a navigation bar: a standard bar is 44, the field is 36. `CYLSearchNavigationPage` sets it on the bar it hosts; the bar's `fieldHeight` is the value to read. The title bar itself is `CYL_SEARCH_NAVIGATION_BAR_HEIGHT` 
- L3319 `export const CYL_SEARCH_NAVIGATION_BAR_HEIGHT: number = 56;` — The height of the navigation bar that holds the search bar (vp), below the status bar.
- L3327 `export struct CYLSearchRefreshButton` — The refresh button of a tag list header (iOS `CYLSearchTagListHeader.applyRefreshIcon(to:)`): the system refresh symbol (`sys.symbol.arrow_clockwise`, `CYLSearchResources.imageNamed('refresh')`), never three dots or text, labelled with the localized `tagList.r
- L3338 `build()`
- L3358 `export struct CYLSearchNavigationTitleBar` — The title bar that holds a search bar (the navigation bar's content): the back button's slot, then the whole search bar filling the width inside the safe area. The slot animates from 0 to 32 vp with `searchBarView.backButtonProgress`, so the bar's width follow
- L3373 `aboutToAppear(): void`
- L3388 `build()`
- L3421 `export struct CYLSearchNavigationPage` — A page whose search bar is always in a navigation bar: the bar is the title builder of a `NavDestination` (`isDestination`, a page pushed on a `Navigation`), or the page is wrapped in a `Navigation` created here, so a page without one gets one. The page lays n
- L3450 `aboutToAppear(): void`
- L3459 `emptyContent()`
- L3463 `titleBar()`
- L3467 `build()`

## `harmonyos/cylsearch/src/main/ets/CYLSearchController.ets`

- L20 `function cylSearchSwipeShouldBegin(isSwipe: boolean, touchedInsideSearch: boolean): boolean` — Whether a swipe from the left edge may begin: a touch that is not the swipe's always may; the swipe itself only when the touch is inside the search view, because the gesture lives on the window and would otherwise fire over a toast or a presented screen (iOS `
- L27 `function cylSearchNavigationBarHidden(hides: boolean, active: boolean): boolean` — Whether the page's navigation bar is pushed away: it is while searching and `hidesNavigationBarDuringPresentation`.
- L35 `function cylSearchStatusBarHidden(active: boolean, provider: (() => boolean) | undefined): boolean` — Whether the status bar is hidden: only while searching, and as the provider says (iOS `prefersStatusBarHiddenProvider`).
- L42 `function cylSearchStatusBarStyle(active: boolean, provider: (() => number) | undefined, fallback: number): number` — The status bar style while searching, as the provider says; `fallback` while not searching or without a provider.
- L50 `function cylSearchAppearanceForwarded(forwards: boolean, active: boolean): boolean` — Whether the contents' appearance changes are passed on: only while searching, and only when asked for (iOS `forwardsAppearanceFromContentsViewController`).
- L58 `function cylSearchBarMaxY(active: boolean, reported: number): number` — The bottom edge of the search bar in the page: what the page reported while searching, 0 while the bar is not there (iOS `searchBarMaxY`).
- L67 `export enum CYLSearchStatusBarStyle` — The style of the status bar (iOS `UIStatusBarStyle`).
- L87 `export interface CYLSearchControllerDelegate` — What a `CYLSearchController` asks of its owner (iOS `CYLSearchControllerDelegate`, QMUI `QMUISearchControllerDelegate`): the search results (called on every text change), the results and their row texts, plus optional life cycle callbacks. Every member is opti
- L135 `class CYLSearchControllerEvents implements CYLSearchViewDelegate` — Connects the events of a `CYLSearchView` to the controller that owns it.
- L165 `class CYLSearchControllerResults implements CYLSearchViewDataSource` — Gives a `CYLSearchView` the results of the controller's delegate.
- L187 `export class CYLSearchController` — A search controller with the shape of QMUI's `QMUISearchController` (iOS `CYLSearchController`): it wraps the search page `CYLSearchView` (the counterpart of iOS's `UISearchController`, whose bar is a `CYLSearchBar`) and adds a launch view while the text is em
- L240 `get searchResultsDelegate(): CYLSearchControllerDelegate | undefined` — The owner of the results: its callbacks drive the results list, and it is told about the text and the life cycle.
- L244 `set searchResultsDelegate(value: CYLSearchControllerDelegate | undefined)`
- L252 `get searchController(): CYLSearchView` — The search page inside, which `CYLSearchComponent` draws (iOS: the system `UISearchController`).
- L260 `get searchResultsController(): CYLSearchView | undefined` — The view that shows the results (iOS `searchResultsController`): the search page, once the delegate gives results; undefined before.
- L267 `get tableView(): Scroller | undefined` — The results list's scroller (iOS `tableView`).
- L275 `get highlightsResultMatches(): boolean` — Gives the first match of the search text in each result row `resultMatchHighlightColor` (the brand color by default). False by default; `CYLSearchView` has the same option.
- L279 `set highlightsResultMatches(value: boolean)`
- L286 `get resultMatchHighlightColor(): ResourceColor | undefined` — The color of the highlighted match; undefined (the default) uses the brand color.
- L290 `set resultMatchHighlightColor(value: ResourceColor | undefined)`
- L298 `get launchView(): WrappedBuilder<[CYLSearchView]> | undefined` — A view shown while the text is empty, for example the recent searches; it fills the space under the search bar (QMUI `launchView`).
- L302 `set launchView(value: WrappedBuilder<[CYLSearchView]> | undefined)`
- L311 `get showsSuggestionsLaunchView(): boolean` — Whether the built-in launch view is `launchView`: the suggestion area of `CYLSearchView` (tags folded to two rows and, over the submitted queries of `historyStore`, the title "Recent searches" with a clear button). Default false. Setting a `launchView` of your
- L315 `set showsSuggestionsLaunchView(value: boolean)`
- L322 `get suggestions(): string[]` — The tags of the built-in launch view while `historyStore` is empty or undefined. Empty by default.
- L326 `set suggestions(value: string[])`
- L334 `get dimmingColor(): ResourceColor | undefined` — The color over the contents while the keyboard is up and the text is empty; undefined keeps the default. Ignored when a `launchView` is set (QMUI `dimmingColor`).
- L338 `set dimmingColor(value: ResourceColor | undefined)`
- L345 `get isActive(): boolean` — Whether the search is active, changed without animation (QMUI `active`).
- L349 `set isActive(value: boolean)`
- L357 `get navigationBarHidden(): boolean` — Whether the page's navigation bar is pushed away now: while searching, with `hidesNavigationBarDuringPresentation`.
- L365 `get alwaysShowsSearchResultsController(): boolean` — Whether the results are shown even while the text is empty (QMUI `alwaysShowSearchResultsController`). Turning it on clears `launchView`.
- L369 `set alwaysShowsSearchResultsController(value: boolean)`
- L380 `get supportsSwipeToDismissSearch(): boolean` — Whether a swipe from the left screen edge leaves the search while the results or the launch view show (QMUI `supportsSwipeToDismissSearch`). Default false.
- L384 `set supportsSwipeToDismissSearch(value: boolean)`
- L392 `get searchBarMaxY(): number` — The bottom edge of the search bar in the page, in vp; 0 while the search is not active. The page reports it with `searchBarLayoutChanged`.
- L399 `get prefersStatusBarHidden(): boolean` — Whether the status bar is hidden now (`prefersStatusBarHiddenProvider`, only while searching).
- L406 `get preferredStatusBarStyle(): number` — The status bar style now, a `CYLSearchStatusBarStyle` (`preferredStatusBarStyleProvider`, only while searching).
- L414 `get isEmptyViewShowing(): boolean` — Whether the empty view is on screen.
- L423 `get noResultsText(): string | undefined` — The text of the "no results" empty view that the controller manages itself: it shows the empty view with this text while the text is not empty and the results have no row, and hides it otherwise. Undefined (the default) leaves `showEmptyView` and `hideEmptyVie
- L427 `set noResultsText(value: string | undefined)`
- L435 `get historyStore(): CYLSearchSuggestionCache | undefined` — Where the queries the person submits are kept, newest first and without duplicates; undefined keeps none. The built-in store of `CYLSearchView` comes from `CYLSearchResources`, so the history is shared code, not a copy.
- L439 `set historyStore(value: CYLSearchSuggestionCache | undefined)`
- L447 `get snapsHeaderSearchBar(): boolean` — Whether a header search bar (`installSearchBar`) is kept scrollable out of sight, even above a short list, and settles fully shown or fully hidden when scrolling stops (QMUI issues #1160 and #1207). Default true.
- L451 `set snapsHeaderSearchBar(value: boolean)`
- L461 `setActive(active: boolean, animated: boolean): void` — Enters or leaves the search (QMUI `setActive:animated:`).
- L468 `get isSearchOpen(): boolean` — Whether the search is presented; the same as `isActive` (`CYLSearchView.isSearchOpen`).
- L475 `showSearch(animated: boolean = true): void` — Presents the search (`setActive(true, animated)`).
- L482 `closeSearch(animated: boolean = true): void` — Leaves the search (`setActive(false, animated)`).
- L491 `installSearchBar(table: CYLSearchTableView): void` — Shows the search bar as the header of `table` (QMUI `qmui_usedAsTableHeaderView`): the bar is the list's first row, a tap on it opens the search, and `snapsHeaderSearchBar` settles it fully shown or fully hidden. The header bar takes the style of `searchBar`.
- L505 `removeSearchBarHeader(table: CYLSearchTableView): void` — Takes the bar out of `table`'s header (`CYLSearchTableViewController` does this when `showsSearchBar` is turned off).
- L518 `installInView(context: common.Context): void` — Gives the search page the app's context without opening it (iOS `install(in:)`, which installs the search on a navigation item); put a `CYLSearchComponent` for `searchController` over the page.
- L529 `showEmptyView(text: string, detailText?: string, buttonTitle?: string, buttonAction?: () => void): void` — Shows CYLTableViewPlaceHolder's placeholder with a title, an optional detail and an optional button in the results (QMUI `showEmptyViewWithText:detailText:buttonTitle:buttonAction:`). Does nothing while the search text is empty: the dimming view or the launch 
- L538 `showEmptyViewScenario(scenario: CYLPlaceholderScenario): void` — Shows one of CYLTableViewPlaceHolder's scenarios in the results (iOS `showEmptyView(scenario:)`). Does nothing while the search text is empty.
- L546 `hideEmptyView(): void` — Removes the empty view (the search leaving always does).
- L553 `updateSearchResults(searchString: string): void` — Passes the search bar's text (also "") to the delegate (iOS `updateSearchResults(for:)`).
- L560 `willPresentSearchController(): void` — The search is about to be presented: tells the delegate.
- L567 `didPresentSearchController(): void` — The search was presented: tells the delegate.
- L574 `willDismissSearchController(): void` — The search is about to be dismissed: tells the delegate.
- L581 `didDismissSearchController(): void` — The search was dismissed: hides the empty view (leaving the search always does) and tells the delegate.
- L590 `gestureRecognizerShouldBegin(isSwipe: boolean, touchedInsideSearch: boolean): boolean` — Whether the swipe from the left edge, or another gesture, may begin (iOS `gestureRecognizerShouldBegin(_:)`): the swipe only when the touch is inside the search view.
- L597 `searchBarLayoutChanged(maxY: number): void` — The page reports where the search bar ends (`searchBarMaxY`).
- L606 `contentsAppearanceChanged(isAppearing: boolean): boolean` — The contents page appeared or disappeared (the page's `onPageShow` and `onPageHide`); with `forwardsAppearanceFromContentsViewController` and an active search, the delegate hears it. Returns whether it was passed on.
- L618 `observeHistoryDidChange(listener: (query: string) => void): () => void` — Calls `listener` with each query that went into `historyStore` after it was submitted (iOS `historyDidChangeNotification`); the returned function stops listening.
- L631 `historyChanged(query: string): void` — A submitted query went into the history: tells the listeners.

## `harmonyos/cylsearch/src/main/ets/CYLSearchNavigationBar.ets`

MARK: - Pure logic (begin): no ArkUI, no kit; harmonyos/scripts/host-logic-test.mjs runs it with Node. The insets of a search bar that sits in a navigation bar: 4 above and below the field, none at the sides (the page's 16 vp margin is the inset that lines the bar up with the tag lists; iOS `holding(_:)`).

- L9 `function cylSearchNavigationContentInsets(): number[]` — The insets of a search bar that sits in a navigation bar: 4 above and below the field, none at the sides (the page's 16 vp margin is the inset that lines the bar up with the tag lists; iOS `holding(_:)`).
- L17 `function cylSearchNavigationShouldPop(): boolean` — Whether the navigation bar pops its page when the back button is tapped: never, the host decides (iOS `navigationBar(_:shouldPop:)`).
- L26 `export enum CYLSearchBarPosition` — Where a bar sits (iOS `UIBarPosition`).
- L50 `export class CYLSearchNavigationBar` — The navigation bar the core makes for a page that has none, holding the search bar as its title (iOS `CYLSearchNavigationBar`). `CYLSearchNavigationPage` draws it: it is the page's title bar, `standardHeight` high, with the back button before the bar when `sho
- L88 `static holding(searchBarView: CYLSearchBarView, showsBackButton: boolean = false): CYLSearchNavigationBar` — A navigation bar holding `searchBarView` as its title, with the bar set up for it (a 36 vp field, no side inset of its own). With `showsBackButton` the bar has the back button of a second-level page before it; a tap calls `backHandler`. The bridges use it as t
- L97 `navigationBar(): boolean` — The back button was tapped: the host's `backHandler` runs and the bar stays; returns false, the answer of `navigationBar(_:shouldPop:)`.
- L105 `position(): CYLSearchBarPosition` — Attached to the top edge: the background extends under the status bar (iOS `position(for:)`).
- L116 `static embedInNavigationBar(searchBarView: CYLSearchBarView, hostsNavigationBar: boolean): CYLSearchNavigationBar` — Puts `searchBarView` into the navigation bar of its page and returns that bar; a navigation bar always exists afterwards. With `hostsNavigationBar` (the page has its own, such as a `NavDestination` title) the bar becomes its title and `createdByCore` is false.



_Continues in [part 2](03-harmony-core-part2.md)._

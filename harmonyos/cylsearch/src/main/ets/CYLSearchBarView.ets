import { KeyboardAvoidMode } from '@kit.ArkUI';
import { UIContext } from '@kit.ArkUI';
import { common, ApplicationStateChangeCallback } from '@kit.AbilityKit';
import {
  CYLControlState, CYLEdgeInsets, CYLFont, CYLMenuLocalizedString, CYLMenuStyle, CYLOffset, CYLSize, CYLTagButton,
  CYLTagButtonHost
} from '@cyl/classifymenu';
import { CYLSearchResources } from './CYLSearchResources';

// MARK: - Pure logic (begin): no ArkUI, no kit; harmonyos/scripts/host-logic-test.mjs runs it with Node.

/**
 * The text cut to `maximumTextLength` characters; unchanged when the limit is 0 or less (Android
 * `CYLMultiSearchView` text limit).
 */
function cylSearchTextLimited(text: string, maximumTextLength: number): string {
  return maximumTextLength > 0 && text.length > maximumTextLength ? text.substring(0, maximumTextLength) : text;
}

/**
 * Whether a typed search becomes a search of `searches` when completed: not empty and at least `minimumTextLength`
 * characters, the text as typed, not trimmed (Android `CYLMultiSearchView.completeSearch`).
 */
function cylSearchTextCompletes(text: string, minimumTextLength: number): boolean {
  return text.length > 0 && text.length >= minimumTextLength;
}

/**
 * The selected index after the search at `removedIndex` was removed, with `countAfter` searches left: the next one
 * when the selected one (or none) was removed, the previous one when the last went away, the same one shifted when an
 * earlier one went away, -1 when none is left (Android `CYLMultiSearchView.remove`).
 */
function cylSelectionAfterRemoval(selectedIndex: number, removedIndex: number, countAfter: number): number {
  if (countAfter <= 0) {
    return -1;
  }
  if (selectedIndex === removedIndex || selectedIndex === -1) {
    return Math.min(removedIndex, countAfter - 1);
  }
  if (selectedIndex > removedIndex) {
    return selectedIndex - 1;
  }
  return selectedIndex;
}

/**
 * Whether the search bar submits `text`: anything but blank text (Android `CYLSearchBarView.submit`; the delegate
 * still receives the text untrimmed).
 */
function cylSearchTextSubmittable(text: string): boolean {
  return text.trim().length > 0;
}

/**
 * The navigation field preset, the Discover look every screen uses (iOS `applyNavigationFieldStyle()`): a bordered capsule
 * (corner radius 18) with a soft shadow (opacity 0.06), no magnifier, 16 fp text (fp scales with the system font size).
 * The fill is opaque white (light) or black (dark), see `cyl_search_navigation_field_fill`.
 */
interface CYLSearchNavigationFieldPreset {
  cornerRadius: number;
  shadowOpacity: number;
  fontSize: number;
  showsSearchIcon: boolean;
  bordered: boolean;
}

function cylSearchNavigationFieldPreset(): CYLSearchNavigationFieldPreset {
  return { cornerRadius: 18, shadowOpacity: 0.06, fontSize: 16, showsSearchIcon: false, bordered: true };
}

/**
 * What the `CYLTagButton` of a search bar item shows (iOS `CYLSearchBarItemButton.reload()`).
 */
interface CYLSearchBarItemButtonContent<T> {
  title: string | undefined;
  image: T | undefined;
  selectedImage: T | undefined;
  animationURL: string | undefined;
  badgeValue: string | undefined;
}

/**
 * The content of an item's `CYLTagButton` for an item of `style` (0 icon, 1 divider, 2 text, as
 * `CYLSearchBarItemStyle`): a text item shows its title (and its icon before it), an icon item only its icon (its title
 * is what screen readers read), a divider nothing. An animated image replaces the icon and the selected icon.
 */
function cylSearchBarItemButtonContent<T>(style: number, title: string | undefined, image: T | undefined,
  selectedImage: T | undefined, animatedImage: T | undefined, animationURL: string | undefined,
  badgeValue: string | undefined): CYLSearchBarItemButtonContent<T> {
  const divider = style === 1;
  const content: CYLSearchBarItemButtonContent<T> = {
    title: style === 2 ? title : undefined,
    image: divider ? undefined : (animatedImage ?? image),
    selectedImage: divider || animatedImage !== undefined ? undefined : selectedImage,
    animationURL: divider ? undefined : animationURL,
    badgeValue: divider ? undefined : badgeValue
  };
  return content;
}

/**
 * The built-in divider's height in vp (its width is 1).
 */
const CYLSearchBarDividerHeight = 20;

/**
 * The secondary label color (light rgba(60,60,67,0.60), dark rgba(235,235,245,0.60)): the resource has a dark
 * qualifier, so the system re-resolves it when the appearance changes, with no listener.
 */
const CYLSearchBarSecondaryLabel: Resource = $r('app.color.cyl_search_secondary_label');

/**
 * The horizontal padding of an item in vp: its own when 0 or more, else 0 for the divider (style 1: the group's spacing alone
 * puts the gaps beside it), 4 for a text item (style 2) that draws a shape of its own and 0 for the others (a plain text
 * item hugs its title; iOS `CYLSearchBarItemButton.resolvedInsets`).
 */
function cylSearchBarItemInsets(style: number, contentInsets: number, hasShape: boolean): number {
  if (contentInsets >= 0) {
    return contentInsets;
  }
  return style === 2 && hasShape ? 4 : 0;
}

/**
 * A touch region in vp, relative to a view.
 */
interface CYLSearchTouchRegion {
  x: number;
  y: number;
  width: number;
  height: number;
}

/**
 * The touch region of a view of `width` x `height`: the view grown around its center to at least `minimum` on each
 * side (44 vp, the screen reader touch target), so a small icon stays easy to tap without changing the layout.
 */
function cylSearchTouchRegion(width: number, height: number, minimum: number): CYLSearchTouchRegion {
  const regionWidth = Math.max(width, minimum);
  const regionHeight = Math.max(height, minimum);
  const region: CYLSearchTouchRegion = {
    x: (width - regionWidth) / 2,
    y: (height - regionHeight) / 2,
    width: regionWidth,
    height: regionHeight
  };
  return region;
}

/**
 * Space around a view in vp (iOS `UIEdgeInsets`).
 */
export interface CYLSearchEdgeInsets {
  /**
   * The space above.
   */
  top: number;
  /**
   * The space before (the left in a left-to-right layout).
   */
  left: number;
  /**
   * The space below.
   */
  bottom: number;
  /**
   * The space after.
   */
  right: number;
}

/**
 * Whether the placeholder is drawn centered with the magnifier: only at rest (not editing), with no text, a
 * placeholder and `centersPlaceholder` on (iOS `CYLSearchBar.centersPlaceholder`: centered at rest, leading while
 * editing).
 */
function cylSearchPlaceholderCentered(centers: boolean, editing: boolean, text: string, hasPlaceholder: boolean): boolean {
  return centers && !editing && text.length === 0 && hasPlaceholder;
}

/**
 * The margins to apply: what the provider answers for the state (iOS `textFieldMarginsProvider(bar, active)`, which
 * wins), else the fixed margins.
 */
function cylSearchResolvedInsets(provided: CYLSearchEdgeInsets | undefined, fixed: CYLSearchEdgeInsets): CYLSearchEdgeInsets {
  return provided ?? fixed;
}

/**
 * Whether Cancel is drawn: asked for with `showsCancelButton`, or automatically while the bar is active (iOS
 * `automaticallyShowsCancelButton`).
 */
function cylSearchCancelVisible(shows: boolean, automatic: boolean, active: boolean): boolean {
  return shows || (automatic && active);
}

/**
 * The keys of an item dictionary that only change how its animation plays (iOS `CYLSearchBarView.playbackKeys`).
 */
const CYL_SEARCH_PLAYBACK_KEYS: string[] = ['animationLoops', 'animationSpeed'];

/**
 * The shape of an item dictionary: its keys and values without the playback keys, in key order, so two dictionaries
 * that differ only in playback have the same shape (iOS `setItems(dictionaries:)`'s `shapes`).
 */
function cylSearchItemShape(dictionary: Record<string, Object>): string {
  const keys: string[] = Object.keys(dictionary).filter((key: string) => !CYL_SEARCH_PLAYBACK_KEYS.includes(key)).sort();
  return keys.map((key: string) => key + '=' + JSON.stringify(dictionary[key])).join('&');
}

/**
 * Whether the items of the last `setItems` call can stay: the shapes are the same and no item was added or removed
 * in another way since (the bar still has one item per shape).
 */
function cylSearchItemShapesMatch(previous: string[] | undefined, next: string[], itemCount: number): boolean {
  if (previous === undefined || previous.length !== next.length || itemCount !== next.length) {
    return false;
  }
  return previous.every((shape: string, index: number) => shape === next[index]);
}

/**
 * Whether Cancel is enabled: always with `alwaysEnablesCancelButton` (iOS `CYLSearchBar.alwaysEnablesCancelButton`, QMUI
 * `qmui_alwaysEnableCancelButton`), else only while the field is being edited (UIKit disables Cancel when editing ends).
 */
function cylSearchCancelEnabled(always: boolean, editing: boolean): boolean {
  return always || editing;
}

/**
 * Whether the bar takes focus when it appears (iOS `focusIfAppearing`): `focusesOnAppear` is on, the bar's page is a
 * SECOND-LEVEL OR DEEPER page (Navigation stack depth above 1; a first-level page, a root tab or the first page of a
 * stack, never auto-focuses), the field is drawn (not iconified) and not being edited already.
 */
function cylSearchShouldFocusOnAppear(focusesOnAppear: boolean, isOnSecondLevelOrDeeperPage: boolean,
  iconified: boolean, editing: boolean): boolean {
  return focusesOnAppear && isOnSecondLevelOrDeeperPage && !iconified && !editing;
}

/**
 * Whether a visible-area change is an appearance: the bar was hidden (ratio 0) and now shows (ratio above 0). A change
 * between two visible ratios is not (the bar stayed on screen).
 */
function cylSearchVisibilityAppeared(wasVisible: boolean, ratio: number): boolean {
  return !wasVisible && ratio > 0;
}

// First-level navigation bar (owner directive 2026-11-26, docs/instructions/example-demos.md rule 10): the pure state
// machine of the back button and the bar width. The names are the cross-platform ones (iOS mirrors them).

/**
 * The width of the back button's slot in the navigation title bar when it is fully shown, in vp.
 */
const CYL_SEARCH_BACK_SLOT_WIDTH: number = 32;

/**
 * The side inset of the title bar: 16 vp (the page margin) without a back button, 6 vp with one (the button brings its
 * own touch padding).
 */
const CYL_SEARCH_TITLE_INSET_HIDDEN: number = 16;
const CYL_SEARCH_TITLE_INSET_SHOWN: number = 6;

/**
 * What a request to show or hide the back button does: 0 nothing (the button is already as requested), 1 applies at
 * once, 2 applies animated. Asking for the state the button has is a no-op, so a push and a stack callback that both
 * ask do not run the animation twice.
 */
function cylSearchBackButtonRequest(currentlyShown: boolean, wantsShown: boolean, animated: boolean): number {
  if (currentlyShown === wantsShown) {
    return 0;
  }
  return animated ? 2 : 1;
}

/**
 * The progress (0 hidden, 1 shown) clamped to its range; a NaN is 0.
 */
function cylSearchBackButtonProgress(progress: number): number {
  if (!(progress > 0)) {
    return 0;
  }
  return progress > 1 ? 1 : progress;
}

/**
 * The width of the back button's slot at `progress`: the slot grows from 0 to 32 vp, and the bar takes what is left.
 */
function cylSearchBackSlotWidth(progress: number): number {
  return CYL_SEARCH_BACK_SLOT_WIDTH * cylSearchBackButtonProgress(progress);
}

/**
 * The leading inset of the title bar at `progress`: 16 vp hidden, 6 vp shown.
 */
function cylSearchTitleLeadingInset(progress: number): number {
  const p = cylSearchBackButtonProgress(progress);
  return CYL_SEARCH_TITLE_INSET_HIDDEN + (CYL_SEARCH_TITLE_INSET_SHOWN - CYL_SEARCH_TITLE_INSET_HIDDEN) * p;
}

/**
 * The width the search bar gets in a title bar of `containerWidth` (the width inside the safe area) at `progress`:
 * the whole bar width at 0, narrower by the back slot and the smaller inset at 1. Pages never compute it, the title bar
 * lays the bar out with it.
 */
function cylSearchBarWidth(containerWidth: number, progress: number): number {
  const width = containerWidth - cylSearchTitleLeadingInset(progress) - CYL_SEARCH_TITLE_INSET_HIDDEN -
    cylSearchBackSlotWidth(progress);
  return width > 0 ? width : 0;
}

/**
 * What a tap on the bar does: 0 the bar edits as usual (not a first-level bar), 1 the tap is a push (the back button
 * comes in and `onFirstLevelTap` runs), 2 nothing (a first-level bar whose back button is already shown: the push is
 * under way, a second tap must not push twice).
 */
function cylSearchFirstLevelTapAction(pushesOnTap: boolean, backButtonShown: boolean): number {
  if (!pushesOnTap) {
    return 0;
  }
  return backButtonShown ? 2 : 1;
}

/**
 * Whether the back button belongs to the page a `Navigation` is about to show: the root (first-level) page has none,
 * any pushed page has one. The system back gesture and the back button both end in this question.
 */
function cylSearchBackButtonWantedFor(targetIsRootPage: boolean): boolean {
  return !targetIsRootPage;
}

/**
 * The look of a bar preset, one per tab of the example (`CYLSearchBarPreset`): 0 navigationField (the Discover look),
 * 1 pill, 2 rounded, 3 outlined, 4 centeredCapsule. `cornerRadius` -1 is a full capsule.
 */
interface CYLSearchBarPresetSpec {
  bordered: boolean;
  cornerRadius: number;
  shadowOpacity: number;
  fontSize: number;
  showsSearchIcon: boolean;
  centersPlaceholder: boolean;
  usesNavigationFill: boolean;
}

function cylSearchBarPresetSpec(preset: number): CYLSearchBarPresetSpec {
  const navigation = cylSearchNavigationFieldPreset();
  if (preset === 1) {
    return { bordered: false, cornerRadius: -1, shadowOpacity: 0, fontSize: 16, showsSearchIcon: true,
      centersPlaceholder: false, usesNavigationFill: false };
  } else if (preset === 2) {
    return { bordered: false, cornerRadius: 10, shadowOpacity: 0, fontSize: 16, showsSearchIcon: true,
      centersPlaceholder: false, usesNavigationFill: false };
  } else if (preset === 3) {
    return { bordered: true, cornerRadius: 8, shadowOpacity: 0, fontSize: 16, showsSearchIcon: true,
      centersPlaceholder: false, usesNavigationFill: true };
  } else if (preset === 4) {
    return { bordered: true, cornerRadius: -1, shadowOpacity: 0.06, fontSize: 16, showsSearchIcon: true,
      centersPlaceholder: true, usesNavigationFill: true };
  }
  return { bordered: navigation.bordered, cornerRadius: navigation.cornerRadius, shadowOpacity: navigation.shadowOpacity,
    fontSize: navigation.fontSize, showsSearchIcon: navigation.showsSearchIcon, centersPlaceholder: false,
    usesNavigationFill: true };
}

/**
 * The item corner radius that means "automatic" (10 with a background, else square; iOS `automaticCornerRadius`).
 */
const CYL_SEARCH_ITEM_CORNER_RADIUS_AUTOMATIC = -1;

/**
 * The item corner radius that makes a capsule (iOS `CYLAnimatedItemCornerRadiusCapsule`, the same 1000 as
 * `CYLSearchTagListStyle.capsuleCornerRadius`).
 */
const CYL_SEARCH_ITEM_CORNER_RADIUS_CAPSULE = 1000;

/**
 * The side of an item's smallest size and touch target, in vp.
 */
const CYL_SEARCH_ITEM_MINIMUM_SIDE = 36;

/**
 * The height of the `icon` style of the default search button (a filled capsule), in vp.
 */
const CYL_SEARCH_BUTTON_ICON_HEIGHT = 28;

/**
 * The side insets of the `icon` style of the default search button, in vp.
 */
const CYL_SEARCH_BUTTON_ICON_INSETS = 16;

/**
 * The corner radius an item is drawn with: its own unless automatic, which is 10 with a background and square without.
 */
function cylSearchItemResolvedCornerRadius(cornerRadius: number, hasBackground: boolean): number {
  if (cornerRadius !== CYL_SEARCH_ITEM_CORNER_RADIUS_AUTOMATIC && cornerRadius >= 0) {
    return cornerRadius;
  }
  return hasBackground ? 10 : 0;
}

/**
 * The height of an item's view: its own `itemHeight` when above 0, else the 36 vp minimum.
 */
function cylSearchItemResolvedHeight(itemHeight: number): number {
  return itemHeight > 0 ? itemHeight : CYL_SEARCH_ITEM_MINIMUM_SIDE;
}

/**
 * The space between two elements of the trailing group (camera, divider, search button), and before the first one, in vp: the
 * only space the group has (the `Row` spacing of the bar's field).
 */
const CYL_SEARCH_TRAILING_SPACING = 8;

/**
 * The touch width of a plain item in vp: widened by `responseRegion`, never by empty room around the glyph.
 */
const CYL_SEARCH_TOUCH_WIDTH = 36;

/**
 * Whether an item hugs its content (owner, 2026-11-26): a plain icon or text item (no background, no outline, no custom
 * height) is as wide as its glyph or title; an item with a shape of its own (the icon search capsule) keeps its size. A
 * divider never hugs.
 */
function cylSearchItemHugsContent(style: number, hasShape: boolean, itemHeight: number): boolean {
  if (style === 1) {
    return false;
  }
  if (style === 0) {
    return !hasShape && !(itemHeight > 0);
  }
  return !hasShape;
}

/**
 * One element of the trailing group, for `cylSearchTrailingGroupLayout`: `style` 0 icon, 1 divider, 2 text; `contentWidth`
 * is the glyph or title width in vp.
 */
interface CYLSearchTrailingElement {
  style: number;
  hasShape: boolean;
  itemHeight: number;
  contentWidth: number;
}

/**
 * Where an element sits in the group and where it takes touches, in vp from the group's left edge.
 */
interface CYLSearchTrailingPlacement {
  left: number;
  right: number;
  width: number;
  hugs: boolean;
  touchLeft: number;
  touchRight: number;
}

/**
 * The layout of the trailing group: `elements` from the left; the group puts `spacing` before each element and nothing else
 * (no empty room inside an item). A hugging item is as wide as its content and its hit area is widened to 36 vp about its
 * center; an item with a shape keeps at least its height (36 when it has none) as width; a divider is 1 wide.
 */
function cylSearchTrailingGroupLayout(elements: CYLSearchTrailingElement[], spacing: number): CYLSearchTrailingPlacement[] {
  const result: CYLSearchTrailingPlacement[] = [];
  let x = 0;
  for (const element of elements) {
    const hugs = cylSearchItemHugsContent(element.style, element.hasShape, element.itemHeight);
    let width = element.contentWidth;
    if (element.style === 1) {
      width = 1;
    } else if (!hugs) {
      width = Math.max(width, cylSearchItemResolvedHeight(element.itemHeight));
    }
    const left = x + spacing;
    const right = left + width;
    const extra = hugs ? Math.max(0, (CYL_SEARCH_TOUCH_WIDTH - width) / 2) : 0;
    x = right;
    result.push({ left: left, right: right, width: width, hugs: hugs, touchLeft: left - extra, touchRight: right + extra });
  }
  return result;
}

/**
 * Whether a bar draws the default search button: `showsSearchButton`, never for an editing bar or in multiple mode.
 */
function cylSearchButtonVisible(showsSearchButton: boolean, isEditingBar: boolean, isMultiple: boolean): boolean {
  return showsSearchButton && !isEditingBar && !isMultiple;
}

/**
 * Whether a divider precedes the search button: only when an owner's item comes before it.
 */
function cylSearchButtonHasDivider(ownerItemCount: number): boolean {
  return ownerItemCount > 0;
}

/**
 * The look of the default search button: `style` 0 text, 1 icon. Text: a text item with the custom title or the localized
 * default and no fill. Icon: an icon item (the custom image, else the built-in magnifier) as a filled capsule 28 high
 * with 16 side insets; its title is what screen readers read.
 */
interface CYLSearchButtonLook {
  itemStyle: number;
  title: string;
  usesBuiltInImage: boolean;
  filled: boolean;
  cornerRadius: number;
  itemHeight: number;
  contentInsets: number;
}

function cylSearchButtonLook(style: number, customTitle: string | undefined, defaultTitle: string,
  hasCustomImage: boolean): CYLSearchButtonLook {
  const title = customTitle !== undefined && customTitle.length > 0 ? customTitle : defaultTitle;
  if (style === 1) {
    return { itemStyle: 0, title: title, usesBuiltInImage: !hasCustomImage, filled: true,
      cornerRadius: CYL_SEARCH_ITEM_CORNER_RADIUS_CAPSULE, itemHeight: CYL_SEARCH_BUTTON_ICON_HEIGHT,
      contentInsets: CYL_SEARCH_BUTTON_ICON_INSETS };
  }
  return { itemStyle: 2, title: title, usesBuiltInImage: false, filled: false,
    cornerRadius: CYL_SEARCH_ITEM_CORNER_RADIUS_AUTOMATIC, itemHeight: 0, contentInsets: -1 };
}

/**
 * The trailing inset of the field's content in vp: with the filled `icon` style as the last element the pill sits concentric
 * in the field, so the gap at its right equals the gap above and below, (fieldHeight - itemHeight) / 2 (4 for a 36 vp
 * field and a 28 vp pill); otherwise the usual inset.
 */
function cylSearchButtonTrailingInset(fieldHeight: number, itemHeight: number, usualInset: number,
  isFilledIcon: boolean): number {
  return isFilledIcon ? Math.max(0, (fieldHeight - itemHeight) / 2) : usualInset;
}

/**
 * What a tap on the search button does with the bar's text: 1 submit it (not empty), 0 only tell the listener (empty
 * text: `searchButtonClicked` fires too).
 */
function cylSearchButtonTapAction(text: string | undefined): number {
  return text !== undefined && text.trim().length > 0 ? 1 : 0;
}

// MARK: - Pure logic (end)

/**
 * Animates `change` with the UI context of the component that draws the model (`UIContext.animateTo`). Before any
 * component has drawn the model there is nothing on screen to animate: the change is applied at once and `onFinish`
 * is called.
 */
function cylAnimate(uiContext: UIContext | undefined, param: AnimateParam, change: () => void): void {
  if (uiContext === undefined) {
    change();
    param.onFinish?.();
    return;
  }
  uiContext.animateTo(param, change);
}

/**
 * The smallest side of an item's view in vp (iOS `CYLSearchBarItemButton.minimumTouchSide`).
 */
const CYLSearchBarItemMinimumSide: number = 36;

/**
 * `CYLSearchBarItem.cornerRadius` automatic: 10 with a background, square without (iOS `automaticCornerRadius`).
 */
export const CYLSearchBarItemCornerRadiusAutomatic: number = -1;

/**
 * `CYLSearchBarItem.cornerRadius` capsule (iOS `CYLAnimatedItemCornerRadiusCapsule`).
 */
export const CYLSearchBarItemCornerRadiusCapsule: number = 1000;

/**
 * The smallest touch target in vp: an item's touch region grows to it.
 */
const CYLSearchTouchTargetSide: number = 44;

/**
 * A `Length` of a `Position` in vp: a number as it is, anything else (a percentage, a resource) 0.
 */
function cylLength(length: Length | undefined): number {
  return typeof length === 'number' ? length as number : 0;
}

/**
 * What a `CYLSearchBarView` edits (iOS `CYLSearchBarMode`).
 */
export enum CYLSearchBarMode {
  /**
   * One search field (the default).
   */
  single = 0,
  /**
   * Several searches side by side (was `CYLMultiSearchView`): the new-search button starts a search; a completed
   * search joins `searches`; a tap selects a search and its remove button removes it.
   */
  multiple = 1
}

/**
 * How an item appended to a search bar looks (iOS `CYLSearchBarItemStyle`).
 */
export enum CYLSearchBarItemStyle {
  /**
   * An icon button with a 36 vp touch area (a camera, a filter).
   */
  icon = 0,
  /**
   * A thin vertical line between two items; it takes no taps and screen readers skip it.
   */
  divider = 1,
  /**
   * A text button (a "Search" button); an image, when set, comes before the title.
   */
  text = 2
}

/**
 * How the default search button looks (iOS `CYLSearchBarSearchButtonStyle`).
 */
export enum CYLSearchBarSearchButtonStyle {
  /**
   * The localized "Search" (or `searchButtonTitle`) as text (opt-in).
   */
  text = 0,
  /**
   * The default: a filled capsule (28 vp high, 16 vp side insets) with the magnifier (or `searchButtonImage`) in the inverse color:
   * black with a white magnifier in light mode, white with a black one in dark mode.
   */
  icon = 1
}

/**
 * The fixed look of the whole bar (iOS `CYLSearchBarStyle`): the field stays, the items are appended after its text.
 */
export enum CYLSearchBarStyle {
  /**
   * The field as configured by its own properties (the default; nothing is changed).
   */
  plain = 0,
  /**
   * A capsule with a 1 vp outline: the field and its items inside one outline.
   */
  bordered = 1
}

/**
 * The looks of a search bar the core ships, one per tab of the example (`CYLSearchBarView.applyPreset`).
 */
export enum CYLSearchBarPreset {
  /**
   * The navigation field, the Discover look (bordered capsule radius 18, soft shadow, no magnifier).
   */
  navigationField = 0,
  /**
   * A borderless full capsule with a magnifier.
   */
  pill = 1,
  /**
   * A borderless rounded rectangle (radius 10) with a magnifier.
   */
  rounded = 2,
  /**
   * A bordered rounded rectangle (radius 8) with a magnifier.
   */
  outlined = 3,
  /**
   * A bordered full capsule with a magnifier and a centered placeholder.
   */
  centeredCapsule = 4
}

/**
 * The item states for text attributes (iOS `UIControlState`).
 */
export enum CYLSearchBarItemState {
  /**
   * Enabled and not selected.
   */
  normal = 0,
  /**
   * Selected (`isSelected`).
   */
  selected = 1,
  /**
   * Disabled (`isEnabled` false).
   */
  disabled = 2
}

/**
 * Title or badge text attributes (iOS `NSAttributedString` attributes).
 */
export class CYLSearchBarItemTextAttributes {
  /**
   * The text color.
   */
  color?: ResourceColor;
  /**
   * The font size in fp.
   */
  size?: number;
  /**
   * The font weight.
   */
  weight?: FontWeight;
}

/**
 * One element after the text of a `CYLSearchBarView`: a model independent of its view (iOS `CYLSearchBarItem`, like
 * `CYLFlatDesignTabBarItem`). Append it with `CYLSearchBarView.addItem`; the bar draws it.
 */
@ObservedV2
export class CYLSearchBarItem {
  /**
   * How the item looks (icon, divider or text); set when the item is created.
   */
  readonly style: CYLSearchBarItemStyle;
  /**
   * The text of a text item, and the screen reader label of an icon item without `itemAccessibilityLabel`.
   */
  @Trace title: string | undefined = undefined;
  /**
   * The icon: a system symbol (`$r('sys.symbol.camera')`), tinted with `tintColor`.
   */
  @Trace image: Resource | undefined = undefined;
  /**
   * The icon while `isSelected` is true; undefined uses `image`.
   */
  @Trace selectedImage: Resource | undefined = undefined;
  /**
   * An animated icon (a GIF or animated WebP as an image source), drawn instead of `image` when set.
   */
  @Trace animatedImage: ResourceStr | undefined = undefined;
  /**
   * An animated icon file (`asset:<rawfile>`: Lottie .json, .pag, .riv, .svga, .gif), drawn by the item's
   * `CYLTagButton` (CollectionViewClassifyMenu) and played on each tap; `image` is shown until it is loaded.
   */
  @Trace animationURL: string | undefined = undefined;
  /**
   * Whether `animationURL` plays again after each pass; false plays once on each tap. The same on every platform.
   */
  @Trace animationLoops: boolean = false;
  /**
   * The playback speed of `animationURL`; 1 is the file's own. An engine without speed ignores it. The same on every
   * platform.
   */
  @Trace animationSpeed: number = 1;
  /**
   * The icon side in vp; 0 uses 20.
   */
  @Trace imageSize: number = 0;
  /**
   * What screen readers read; undefined reads `title`.
   */
  @Trace itemAccessibilityLabel: string | undefined = undefined;
  /**
   * A test identifier for the item view (its component id).
   */
  @Trace itemAccessibilityIdentifier: string | undefined = undefined;
  /**
   * False dims the item and ignores taps. True by default.
   */
  @Trace isEnabled: boolean = true;
  /**
   * True makes each tap toggle `isSelected` (a filter that stays on). False by default.
   */
  isSelectable: boolean = false;
  /**
   * The selected state (drawn with `selectedImage`, `selectedBackgroundColor` and the selected title attributes).
   */
  @Trace isSelected: boolean = false;
  /**
   * The icon and title color; undefined uses the bar's `itemTintColor`.
   */
  @Trace tintColor: ResourceColor | undefined = undefined;
  /**
   * The item background; undefined is transparent.
   */
  @Trace backgroundColor: ResourceColor | undefined = undefined;
  /**
   * The item background while selected; undefined uses `backgroundColor`.
   */
  @Trace selectedBackgroundColor: ResourceColor | undefined = undefined;
  /**
   * The corner radius in vp: `CYLSearchBarItemCornerRadiusAutomatic` (-1, the default) is 10 with a background and square
   * without; 0 is square; `CYLSearchBarItemCornerRadiusCapsule` makes a capsule (iOS `cornerRadius`).
   */
  @Trace cornerRadius: number = CYLSearchBarItemCornerRadiusAutomatic;
  /**
   * The border color; undefined draws none (iOS `borderColor`).
   */
  @Trace borderColor: ResourceColor | undefined = undefined;
  /**
   * The border width in vp; 0 draws none (iOS `borderWidth`).
   */
  @Trace borderWidth: number = 0;
  /**
   * The height of the item's view in vp; 0 uses the 36 vp minimum (iOS `itemHeight`).
   */
  @Trace itemHeight: number = 0;
  /**
   * Horizontal padding around the icon and title, in vp; negative uses the style's default (4 for text, 0 else).
   */
  @Trace contentInsets: number = -1;
  /**
   * Moves the icon, in vp, without changing the item's size.
   */
  @Trace imagePositionAdjustment: Position = { x: 0, y: 0 };
  /**
   * Moves the title, in vp, without changing the item's size.
   */
  @Trace titlePositionAdjustment: Position = { x: 0, y: 0 };
  /**
   * The badge text; undefined hides the badge, an empty string draws a dot.
   */
  @Trace badgeValue: string | undefined = undefined;
  /**
   * The badge background; undefined is red.
   */
  @Trace badgeColor: ResourceColor | undefined = undefined;
  /**
   * The smallest badge side in vp; 0 uses 16 (a dot is 8).
   */
  @Trace badgeSize: number = 0;
  /**
   * Horizontal padding around the badge text, in vp.
   */
  @Trace badgeContentInsets: number = 4;
  /**
   * Moves the badge from the icon's top end corner, in vp.
   */
  @Trace badgePositionAdjustment: Position = { x: 0, y: 0 };
  /**
   * Called on each tap, after `CYLSearchBarViewDelegate.searchBarViewDidSelectItem`.
   */
  handler: ((item: CYLSearchBarItem) => void) | undefined = undefined;
  /**
   * The bar the item was appended to; undefined before `addItem` and after `removeItem`.
   */
  searchBarView: CYLSearchBarView | undefined = undefined;

  @Trace private attributesVersion: number = 0;
  private itemButton: CYLTagButton | undefined = undefined;
  private itemViewTint: ResourceColor | undefined = undefined;
  private titleAttributes: Map<CYLSearchBarItemState, CYLSearchBarItemTextAttributes> = new Map();
  private badgeAttributes: Map<CYLSearchBarItemState, CYLSearchBarItemTextAttributes> = new Map();

  /**
   * An item of the given style with a title and an icon (iOS `-initWithStyle:title:image:`).
   */
  constructor(style: CYLSearchBarItemStyle, title?: string, image?: Resource) {
    this.style = style;
    this.title = title;
    this.image = image;
  }

  /**
   * The item's view, a `CYLTagButton` (CollectionViewClassifyMenu, the one icon + title + animated icon component),
   * created on first use and styled from the item; `CYLSearchBarComponent` draws it and sends its taps to
   * `CYLSearchBarViewDelegate.searchBarViewDidSelectItem` and `handler`.
   */
  get itemView(): CYLTagButton {
    if (this.itemButton === undefined) {
      this.itemButton = new CYLTagButton();
      this.reloadItemView(this.itemViewTint);
    }
    return this.itemButton;
  }

  /**
   * Plays `animationURL` again from the start, as a tap does. Does nothing without an animation. The same on every
   * platform.
   */
  restartAnimation(): void {
    if (this.animationURL !== undefined) {
      this.itemView.playAnimation();
    }
  }

  /**
   * Styles `itemView` from the item for its current state (iOS `CYLSearchBarItemButton.reload()`): no border, the
   * item's background (transparent by default), its tint (`barTint` when it has none) for the title and the icon, its
   * title attributes, icon size, insets, position adjustments and badge; at least 36 x 36 vp. Returns the view.
   */
  reloadItemView(barTint: ResourceColor | undefined): CYLTagButton {
    this.itemViewTint = barTint;
    const button = this.itemButton ?? this.itemView;
    const content = cylSearchBarItemButtonContent<ResourceStr>(this.style, this.title, this.image, this.selectedImage,
      this.animatedImage, this.animationURL, this.badgeValue);
    button.style = this.itemStyle(this.tintColor ?? barTint);
    // A hugging item is as wide as its glyph or title (its 36 vp touch width comes from the hit area, not from room).
    button.minimumSize = new CYLSize(this.hugsContent ? 0 : CYLSearchBarItemMinimumSide,
      cylSearchItemResolvedHeight(this.itemHeight));
    button.title = content.title;
    button.image = content.image;
    button.selectedImage = content.selectedImage;
    button.animationURL = content.animationURL;
    button.animationLoops = this.animationLoops;
    button.animationSpeed = this.animationSpeed;
    button.isSelected = this.isSelected;
    const badge = this.badgeTextAttributes(this.currentState) ?? this.badgeTextAttributes(CYLSearchBarItemState.normal);
    button.badgeColor = this.badgeColor;
    button.badgeTextColor = badge?.color;
    button.badgeFont = badge?.size !== undefined || badge?.weight !== undefined ?
      new CYLFont(badge?.size ?? 11, badge?.weight ?? FontWeight.Medium) : undefined;
    button.badgeMinimumSize = this.badgeSize > 0 ? new CYLSize(this.badgeSize, this.badgeSize) : CYLSize.ZERO;
    button.badgeContentInsets = new CYLEdgeInsets(0, this.badgeContentInsets, 0, this.badgeContentInsets);
    button.badgePositionAdjustment = new CYLOffset(cylLength(this.badgePositionAdjustment.x),
      cylLength(this.badgePositionAdjustment.y));
    button.badgeValue = content.badgeValue;
    button.accessibilityLabel = this.itemAccessibilityLabel ?? this.title;
    return button;
  }

  // Every state is drawn with the item's current look (its title attributes for that state): the view dims itself
  // while disabled, so the tag stays enabled and its animated icon is not dimmed a second time.
  private itemStyle(hostTint: ResourceColor | undefined): CYLMenuStyle {
    const style = new CYLMenuStyle();
    const side = this.imageSize > 0 ? this.imageSize : 20;
    const insets = cylSearchBarItemInsets(this.style, this.contentInsets, this.drawsShape);
    const background =this.isSelected ? (this.selectedBackgroundColor ?? this.backgroundColor) : this.backgroundColor;
    const hasBackground = this.backgroundColor !== undefined || this.selectedBackgroundColor !== undefined;
    const attributes = this.titleTextAttributes(this.currentState) ??
    this.titleTextAttributes(CYLSearchBarItemState.normal);
    style.imageSize = new CYLSize(side, side);
    style.animationSize = new CYLSize(side, side);
    style.imageTitleSpacing = 4;
    style.itemHeight = cylSearchItemResolvedHeight(this.itemHeight);
    style.imagePositionAdjustment = new CYLOffset(cylLength(this.imagePositionAdjustment.x),
      cylLength(this.imagePositionAdjustment.y));
    style.titlePositionAdjustment = new CYLOffset(cylLength(this.titlePositionAdjustment.x),
      cylLength(this.titlePositionAdjustment.y));
    [CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED].forEach((state: number) => {
      const appearance = style.appearance(state);
      const tint = CYLSearchBarItem.resolvedTint(hostTint, state === CYLControlState.SELECTED);
      appearance.font = new CYLFont(attributes?.size ?? 17, attributes?.weight ?? FontWeight.Bold);
      appearance.textColor = attributes?.color ?? tint;
      appearance.iconColor = tint;
      appearance.backgroundColor = background ?? Color.Transparent;
      appearance.borderColor = this.borderWidth > 0 ? this.borderColor : undefined;
      appearance.borderWidth = this.borderColor !== undefined ? this.borderWidth : 0;
      appearance.contentInsets = new CYLEdgeInsets(0, insets, 0, insets);
      // Square: 0 is square (item 8b, docs/animated-icon-component.md).
      appearance.cornerRadius = cylSearchItemResolvedCornerRadius(this.cornerRadius, hasBackground);
    });
    return style;
  }

  /**
   * Whether the item draws a shape of its own (a background or an outline): it keeps its size (iOS item with a background).
   */
  get drawsShape(): boolean {
    return this.backgroundColor !== undefined || this.selectedBackgroundColor !== undefined ||
      (this.borderColor !== undefined && this.borderWidth > 0);
  }

  /**
   * Whether the item hugs its content in the trailing group (`cylSearchItemHugsContent`).
   */
  get hugsContent(): boolean {
    return cylSearchItemHugsContent(this.style, this.drawsShape, this.itemHeight);
  }

  /**
   * The icon and title color of an item in a state: the host's tint (the item's `tintColor`, else the bar's
   * `itemTintColor`) overrides everything; with none, normal is the label color (black in light, white in dark),
   * selected the accent. Both are system resources, re-resolved when the appearance changes. A disabled item is
   * dimmed by its view, so it keeps the normal color.
   */
  static resolvedTint(hostTint: ResourceColor | undefined, selected: boolean): ResourceColor {
    if (hostTint !== undefined) {
      return hostTint;
    }
    return selected ? $r('sys.color.brand') : $r('sys.color.font_primary');
  }

  /**
   * The item's position in its bar's `items`; -1 when it is in no bar.
   */
  get index(): number {
    return this.searchBarView === undefined ? -1 : this.searchBarView.items.indexOf(this);
  }

  /**
   * The state the item is drawn in.
   */
  get currentState(): CYLSearchBarItemState {
    if (!this.isEnabled) {
      return CYLSearchBarItemState.disabled;
    }
    return this.isSelected ? CYLSearchBarItemState.selected : CYLSearchBarItemState.normal;
  }

  /**
   * An icon item: the title is what screen readers read (iOS `+iconItemWithImage:title:handler:`).
   */
  static iconItem(image: Resource | undefined, title: string | undefined,
    handler?: (item: CYLSearchBarItem) => void): CYLSearchBarItem {
    const item = new CYLSearchBarItem(CYLSearchBarItemStyle.icon, title, image);
    item.handler = handler;
    return item;
  }

  /**
   * A text item, a "Search" button (iOS `+textItemWithTitle:handler:`).
   */
  static textItem(title: string, handler?: (item: CYLSearchBarItem) => void): CYLSearchBarItem {
    const item = new CYLSearchBarItem(CYLSearchBarItemStyle.text, title);
    item.handler = handler;
    return item;
  }

  /**
   * A divider between two items (iOS `+dividerItem`).
   */
  static divider(): CYLSearchBarItem {
    return new CYLSearchBarItem(CYLSearchBarItemStyle.divider);
  }

  /**
   * An item from plain values, as the cross-platform wrappers send them (iOS `+itemWithDictionary:`): `style`
   * (`icon`, `divider`, `text`), `title`, `image` (`camera`, `mic`, `search`, `back`), `accessibilityIdentifier`,
   * `isEnabled`, `isSelectable`, `isSelected`, `badgeValue`.
   */
  static item(dictionary: Record<string, Object>): CYLSearchBarItem {
    const styleName = dictionary['style'] as string | undefined;
    let style = CYLSearchBarItemStyle.icon;
    if (styleName === 'divider') {
      style = CYLSearchBarItemStyle.divider;
    } else if (styleName === 'text') {
      style = CYLSearchBarItemStyle.text;
    }
    const item = new CYLSearchBarItem(style, dictionary['title'] as string | undefined,
      CYLSearchBarItem.namedImage(dictionary['image'] as string | undefined));
    item.itemAccessibilityIdentifier = dictionary['accessibilityIdentifier'] as string | undefined;
    item.isEnabled = (dictionary['isEnabled'] as boolean | undefined) ?? true;
    item.isSelectable = (dictionary['isSelectable'] as boolean | undefined) ?? false;
    item.isSelected = (dictionary['isSelected'] as boolean | undefined) ?? false;
    item.badgeValue = dictionary['badgeValue'] as string | undefined;
    if (style === CYLSearchBarItemStyle.icon) {
      item.imageSize = 22;
    }
    return item;
  }

  private static namedImage(name: string | undefined): Resource | undefined {
    if (name === 'camera') {
      return $r('sys.symbol.camera');
    }
    if (name === 'mic') {
      return $r('sys.symbol.mic');
    }
    if (name === 'search') {
      return $r('sys.symbol.magnifyingglass');
    }
    if (name === 'back') {
      return $r('sys.symbol.chevron_backward');
    }
    return undefined;
  }

  /**
   * The title attributes for a state (iOS `-setTitleTextAttributes:forState:`).
   */
  setTitleTextAttributes(attributes: CYLSearchBarItemTextAttributes | undefined, state: CYLSearchBarItemState): void {
    if (attributes === undefined) {
      this.titleAttributes.delete(state);
    } else {
      this.titleAttributes.set(state, attributes);
    }
    this.attributesVersion += 1;
  }

  /**
   * The title attributes set for a state, or undefined (iOS `-titleTextAttributesForState:`).
   */
  titleTextAttributes(state: CYLSearchBarItemState): CYLSearchBarItemTextAttributes | undefined {
    return this.attributesVersion >= 0 ? this.titleAttributes.get(state) : undefined;
  }

  /**
   * The badge text attributes for a state (iOS `-setBadgeTextAttributes:forState:`).
   */
  setBadgeTextAttributes(attributes: CYLSearchBarItemTextAttributes | undefined, state: CYLSearchBarItemState): void {
    if (attributes === undefined) {
      this.badgeAttributes.delete(state);
    } else {
      this.badgeAttributes.set(state, attributes);
    }
    this.attributesVersion += 1;
  }

  /**
   * The badge text attributes set for a state, or undefined (iOS `-badgeTextAttributesForState:`).
   */
  badgeTextAttributes(state: CYLSearchBarItemState): CYLSearchBarItemTextAttributes | undefined {
    return this.attributesVersion >= 0 ? this.badgeAttributes.get(state) : undefined;
  }
}

/**
 * The icon of the button before the field (iOS `CYLSearchBarNavigationIcon`).
 */
export enum CYLSearchBarNavigationIcon {
  /**
   * No button.
   */
  none = 0,
  /**
   * A back arrow.
   */
  arrow = 1,
  /**
   * A magnifier.
   */
  search = 2
}

/**
 * Where the search button sits while the bar is iconified (iOS `CYLSearchBarIconPosition`).
 */
export enum CYLSearchBarIconPosition {
  /**
   * At the end.
   */
  trailing = 0,
  /**
   * In the middle.
   */
  center = 1,
  /**
   * At the start.
   */
  leading = 2
}

/**
 * How the field opens from the search button (iOS `CYLSearchBarExpansionAnimation`).
 */
export enum CYLSearchBarExpansionAnimation {
  /**
   * The field fades in.
   */
  fade = 0,
  /**
   * The field grows from the button, as one animated fraction from an icon circle to the full bar (the technique
   * of Applib-HarmonyOS/FlexibleSearchBar's `startOpen` / `startClose`).
   */
  circularReveal = 1
}

/**
 * The events of a `CYLSearchBarView` (iOS `CYLSearchBarViewDelegate`); every method is optional.
 */
export interface CYLSearchBarViewDelegate {
  /**
   * Asks whether editing may start; false reports `searchBarViewDidTapWhileNotEditable` instead.
   */
  searchBarViewShouldBeginEditing?: (searchBarView: CYLSearchBarView) => boolean;
  /**
   * The field was tapped while it may not be edited.
   */
  searchBarViewDidTapWhileNotEditable?: (searchBarView: CYLSearchBarView) => void;
  /**
   * Editing started.
   */
  searchBarViewDidBeginEditing?: (searchBarView: CYLSearchBarView) => void;
  /**
   * Editing ended.
   */
  searchBarViewDidEndEditing?: (searchBarView: CYLSearchBarView) => void;
  /**
   * The text changed (iOS `-searchBarView:textDidChange:`).
   */
  searchBarViewTextDidChange?: (searchBarView: CYLSearchBarView, text: string) => void;
  /**
   * The search key or the submit button.
   */
  searchBarViewSearchButtonClicked?: (searchBarView: CYLSearchBarView) => void;
  /**
   * Cancel was tapped.
   */
  searchBarViewCancelButtonClicked?: (searchBarView: CYLSearchBarView) => void;
  /**
   * The button before the field was tapped.
   */
  searchBarViewNavigationButtonClicked?: (searchBarView: CYLSearchBarView) => void;
  /**
   * The microphone was tapped.
   */
  searchBarViewVoiceButtonClicked?: (searchBarView: CYLSearchBarView) => void;
  /**
   * Asks whether the text may be submitted (iOS `-searchBarView:shouldSubmitText:`).
   */
  searchBarViewShouldSubmitText?: (searchBarView: CYLSearchBarView, text: string) => boolean;
  /**
   * The field opened or closed (iOS `-searchBarView:didChangeIconified:`).
   */
  searchBarViewDidChangeIconified?: (searchBarView: CYLSearchBarView, iconified: boolean) => void;
  /**
   * An appended item was tapped (iOS `-searchBarView:didSelectItem:`).
   */
  searchBarViewDidSelectItem?: (searchBarView: CYLSearchBarView, item: CYLSearchBarItem) => void;
  /**
   * `multiple` mode: the text of the new search changed; `index` is its place in `searches` (iOS
   * `-searchBarView:textDidChange:atIndex:`). The `single` mode reports `searchBarViewTextDidChange` instead.
   */
  searchBarViewTextDidChangeAtIndex?: (searchBarView: CYLSearchBarView, text: string, index: number) => void;
  /**
   * `multiple` mode: a search was completed and joined `searches` at `index` (iOS
   * `-searchBarView:didCompleteSearch:atIndex:`).
   */
  searchBarViewDidCompleteSearch?: (searchBarView: CYLSearchBarView, text: string, index: number) => void;
  /**
   * `multiple` mode: the search at `index` was removed (iOS `-searchBarView:didRemoveSearchAtIndex:`).
   */
  searchBarViewDidRemoveSearchAtIndex?: (searchBarView: CYLSearchBarView, index: number) => void;
  /**
   * `multiple` mode: the search at `index` was selected by a tap (iOS `-searchBarView:didSelectSearch:atIndex:`).
   */
  searchBarViewDidSelectSearch?: (searchBarView: CYLSearchBarView, text: string, index: number) => void;
}

/**
 * The style of a search bar as one value (iOS `CYLSearchBarAppearance`): fonts, colors, the field's and the bar's
 * backgrounds and the icons. `CYLSearchBarAppearance.defaultAppearance` is the merged default style (the grey field,
 * the blue tint, "Search" and "Cancel" in the language the app shows); `CYLSearchBarView.appearanceStyle` applies one.
 */
export class CYLSearchBarAppearance {
  /**
   * The font size of the text and the placeholder in fp; undefined keeps the bar's.
   */
  font: number | undefined = undefined;
  /**
   * The text color.
   */
  textColor: ResourceColor | undefined = undefined;
  /**
   * The placeholder color.
   */
  placeholderColor: ResourceColor | undefined = $r('app.color.cyl_search_secondary_label');
  /**
   * The placeholder.
   */
  placeholder: ResourceStr | undefined = $r('app.string.cyl_search_field');
  /**
   * The title of Cancel.
   */
  cancelTitle: ResourceStr | undefined = $r('app.string.cyl_search_cancel');
  /**
   * The color of Cancel and the caret.
   */
  tintColor: ResourceColor | undefined = '#0068F8';
  /**
   * The magnifier.
   */
  searchIconImage: Resource | undefined = undefined;
  /**
   * The clear button's symbol.
   */
  clearIconImage: Resource | undefined = undefined;
  /**
   * The field's fill; light and dark grey by default.
   */
  textFieldBackgroundColor: ResourceColor | undefined = $r('app.color.cyl_search_field_background');
  /**
   * An image behind the field.
   */
  textFieldBackgroundImage: ResourceStr | undefined = undefined;
  /**
   * The color of the field's border.
   */
  textFieldBorderColor: ResourceColor | undefined = undefined;
  /**
   * The field's corner radius; negative makes a capsule.
   */
  textFieldCornerRadius: number = -1;
  /**
   * An image behind the whole bar.
   */
  barBackgroundImage: ResourceStr | undefined = undefined;
  /**
   * The color behind the whole bar.
   */
  barBackgroundColor: ResourceColor | undefined = undefined;
  /**
   * The color of the line under the bar.
   */
  barBorderColor: ResourceColor | undefined = undefined;
  /**
   * The bar has no background of its own unless a color or an image is set. True by default.
   */
  hidesBarBackground: boolean = true;

  /**
   * The shared default style; change its values to change the default of every bar that applies it.
   */
  static readonly defaultAppearance: CYLSearchBarAppearance = new CYLSearchBarAppearance();

  /**
   * A copy with the same values.
   */
  copy(): CYLSearchBarAppearance {
    const result = new CYLSearchBarAppearance();
    result.font = this.font;
    result.textColor = this.textColor;
    result.placeholderColor = this.placeholderColor;
    result.placeholder = this.placeholder;
    result.cancelTitle = this.cancelTitle;
    result.tintColor = this.tintColor;
    result.searchIconImage = this.searchIconImage;
    result.clearIconImage = this.clearIconImage;
    result.textFieldBackgroundColor = this.textFieldBackgroundColor;
    result.textFieldBackgroundImage = this.textFieldBackgroundImage;
    result.textFieldBorderColor = this.textFieldBorderColor;
    result.textFieldCornerRadius = this.textFieldCornerRadius;
    result.barBackgroundImage = this.barBackgroundImage;
    result.barBackgroundColor = this.barBackgroundColor;
    result.barBorderColor = this.barBorderColor;
    result.hidesBarBackground = this.hidesBarBackground;
    return result;
  }
}

/**
 * A configurable search bar (iOS `CYLSearchBarView`): a rounded field with a magnifier, text and clear button,
 * appended items after the text, a button before the field and an optional Cancel button. With `mode` set to
 * `multiple` it edits several searches side by side instead (was `CYLMultiSearchView`). This class is the bar's
 * state and API; `CYLSearchBarComponent` draws it. Sizes are in vp, durations in seconds, as on iOS.
 */
@ObservedV2
export class CYLSearchBarView {
  /**
   * The UI context of the component that draws it, set by that component; animations use it.
   */
  uiContext: UIContext | undefined = undefined;
  private static nextIdentifier: number = 0;
  /**
   * Receives the events.
   */
  delegate: CYLSearchBarViewDelegate | undefined = undefined;
  /**
   * The id of the text input, for focus (`showKeyboard`) and tests.
   */
  readonly textFieldId: string;
  /**
   * The text input's controller (caret and editing).
   */
  readonly textField: TextInputController = new TextInputController();
  /**
   * What the bar edits: one field (`single`, the default) or several searches (`multiple`).
   */
  @Trace mode: CYLSearchBarMode = CYLSearchBarMode.single;
  /**
   * The text of the field; in `multiple` mode, the text of the new search being typed.
   */
  @Trace text: string = '';
  /**
   * The placeholder; undefined shows none in `single` mode and "Filter results" (iOS `search.placeholder`) for a new
   * search in `multiple` mode.
   */
  @Trace placeholder: ResourceStr | undefined = undefined;
  /**
   * The font size in fp. 17 by default.
   */
  @Trace font: number = 17;
  /**
   * The text color; undefined uses the primary text color.
   */
  @Trace textColor: ResourceColor | undefined = undefined;
  /**
   * The placeholder color; undefined uses the tertiary text color.
   */
  @Trace placeholderColor: ResourceColor | undefined = undefined;
  /**
   * The caret color; undefined uses the system accent.
   */
  @Trace cursorColor: ResourceColor | undefined = undefined;
  /**
   * The field's height. 36 by default.
   */
  @Trace fieldHeight: number = 36;
  /**
   * The space around the field inside the bar.
   */
  @Trace contentInsets: Padding = { top: 6, left: 12, bottom: 6, right: 12 };
  /**
   * The field's background; undefined uses a light fill.
   */
  @Trace fieldBackgroundColor: ResourceColor | undefined = undefined;
  /**
   * The field's corner radius; negative makes a capsule. -1 by default.
   */
  @Trace fieldCornerRadius: number = -1;
  /**
   * The field's border color; undefined draws no border.
   */
  @Trace fieldBorderColor: ResourceColor | undefined = undefined;
  /**
   * The field's border width, used with `fieldBorderColor`. 0 by default.
   */
  @Trace fieldBorderWidth: number = 0;
  /**
   * The field's shadow, 0 to 1. 0 by default.
   */
  @Trace fieldShadowOpacity: number = 0;
  /**
   * An image drawn behind the field's content, clipped to its corners.
   */
  @Trace fieldBackgroundImage: ResourceStr | undefined = undefined;
  /**
   * The magnifier at the start of the field; undefined hides it.
   */
  @Trace searchIcon: Resource | undefined = $r('sys.symbol.magnifyingglass');
  /**
   * The magnifier's color; undefined uses the secondary text color.
   */
  @Trace searchIconTintColor: ResourceColor | undefined = undefined;
  /**
   * Shows the Cancel button after the field. False by default.
   */
  @Trace showsCancelButton: boolean = false;
  /**
   * The Cancel button's title; "Cancel" in the language the app shows by default (iOS `search.cancel`).
   */
  @Trace cancelButtonTitle: ResourceStr = $r('app.string.cyl_search_cancel');
  /**
   * Cancel also ends editing. True by default.
   */
  cancelButtonEndsEditing: boolean = true;
  /**
   * Cancel also clears the text. False by default.
   */
  clearsTextOnCancel: boolean = false;
  /**
   * Ending editing clears the text. False by default.
   */
  clearsTextOnEndEditing: boolean = false;
  /**
   * The icon of the button before the field; `none` hides it unless `navigationImage` is set.
   */
  @Trace navigationIcon: CYLSearchBarNavigationIcon = CYLSearchBarNavigationIcon.none;
  /**
   * A symbol of yours for the button before the field; it wins over `navigationIcon`.
   */
  @Trace navigationImage: Resource | undefined = undefined;
  /**
   * What screen readers read for the button before the field; "Back" in the language the app shows by default (iOS
   * `search.back`).
   */
  @Trace navigationAccessibilityLabel: ResourceStr = $r('app.string.cyl_navigationBar_back');
  /**
   * A round background behind the button before the field; undefined draws none.
   */
  @Trace navigationBackgroundColor: ResourceColor | undefined = undefined;
  /**
   * The shadow of the button before the field, 0 to 1.
   */
  @Trace navigationShadowOpacity: number = 0;
  /**
   * Called when the button before the field is tapped, after the delegate.
   */
  navigationHandler: ((searchBarView: CYLSearchBarView) => void) | undefined = undefined;
  /**
   * Shows a microphone inside the field while the text is empty. False by default.
   */
  @Trace showsVoiceButton: boolean = false;
  /**
   * The microphone's symbol.
   */
  @Trace voiceImage: Resource = $r('sys.symbol.mic');
  /**
   * Shows a submit button inside the field while there is text. False by default.
   */
  @Trace showsSubmitButton: boolean = false;
  /**
   * The submit button's symbol.
   */
  @Trace submitImage: Resource = $r('sys.symbol.arrow_right');
  /**
   * The clear button's symbol.
   */
  @Trace clearImage: Resource = $r('sys.symbol.xmark_circle_fill');
  /**
   * The keyboard (iOS `keyboardType`).
   */
  @Trace keyboardType: InputType = InputType.Normal;
  /**
   * The return key (iOS `returnKeyType`). Search by default.
   */
  @Trace returnKeyType: EnterKeyType = EnterKeyType.Search;
  /**
   * Hides the typed text (iOS `isSecureTextEntry`).
   */
  @Trace isSecureTextEntry: boolean = false;
  /**
   * The longest text allowed; 0 is no limit.
   */
  @Trace maximumTextLength: number = 0;
  /**
   * `multiple` mode: a new search shorter than this is dropped by `completeSearch()`. 3 by default.
   */
  minimumTextLength: number = 3;
  /**
   * `multiple` mode: the selected search of `searches`, or -1 when none is selected (iOS `NSNotFound`).
   */
  @Trace selectedSearchIndex: number = -1;
  /**
   * `multiple` mode: the color of the line under the selected search and of the buttons; undefined uses the system
   * accent.
   */
  @Trace searchIndicatorColor: ResourceColor | undefined = undefined;
  /**
   * `multiple` mode: the opacity of the searches that are not selected. 0.5 by default.
   */
  @Trace unselectedSearchAlpha: number = 0.5;
  /**
   * `multiple` mode: the width of the field of a new search, in vp. 160 by default.
   */
  @Trace searchFieldWidth: number = 160;
  /**
   * `multiple` mode: the symbol of the new-search button. A magnifier by default.
   */
  @Trace newSearchImage: Resource = $r('sys.symbol.magnifyingglass');
  /**
   * `multiple` mode: the symbol of the remove button of the selected search.
   */
  @Trace removeSearchImage: Resource = $r('sys.symbol.xmark_circle_fill');
  /**
   * The bar shows only its search button until it is tapped. False by default.
   */
  @Trace iconifiedByDefault: boolean = false;
  /**
   * How the field opens from the search button.
   */
  expansionAnimation: CYLSearchBarExpansionAnimation = CYLSearchBarExpansionAnimation.fade;
  /**
   * Where the search button sits while iconified.
   */
  @Trace iconPosition: CYLSearchBarIconPosition = CYLSearchBarIconPosition.trailing;
  /**
   * The duration of the open and close animation, in seconds. 0.3 by default.
   */
  animationDuration: number = 0.3;
  /**
   * The fill of the search button shown while iconified; undefined draws no fill (iOS `iconButton.configuration`
   * `baseBackgroundColor`, a filled capsule).
   */
  @Trace iconButtonBackgroundColor: ResourceColor | undefined = undefined;
  /**
   * The magnifier color of that button; undefined uses `searchIconTintColor` (iOS `baseForegroundColor`).
   */
  @Trace iconButtonTintColor: ResourceColor | undefined = undefined;
  /**
   * The appended items, in order, after the text (like the FlatDesign tab bar's `items`). The field stays; only
   * items are appended.
   */
  @Trace items: CYLSearchBarItem[] = [];
  /**
   * Whether the bar keeps its built-in search button after the field and the owner's items (a divider before it when an
   * item precedes it). True by default; always off for an editing bar and in `multiple` mode (iOS `showsSearchButton`).
   */
  @Trace showsSearchButton: boolean = true;
  /**
   * `icon` (the default) or `text` (iOS `searchButtonStyle`).
   */
  @Trace searchButtonStyle: CYLSearchBarSearchButtonStyle = CYLSearchBarSearchButtonStyle.icon;
  /**
   * The text of the button; undefined is the localized "Search" (Search, 搜索, 搜尋, 検索). With the `icon` style it is the
   * screen reader label (iOS `searchButtonTitle`).
   */
  @Trace searchButtonTitle: string | undefined = undefined;
  /**
   * The icon of the `icon` style; undefined is the core's built-in magnifier (iOS `searchButtonImage`).
   */
  @Trace searchButtonImage: Resource | undefined = undefined;
  /**
   * Called on each tap of the search button, after the text was submitted (iOS `searchButtonHandler`).
   */
  searchButtonHandler: ((searchBarView: CYLSearchBarView) => void) | undefined = undefined;
  /**
   * The localized "Search", set by `CYLSearchBarComponent` from the string resources.
   */
  @Trace defaultSearchButtonTitle: string = 'Search';
  private searchButtonModel: CYLSearchBarItem | undefined = undefined;
  private searchButtonSignature: string = '';

  /**
   * Whether the bar draws the search button now (`showsSearchButton`, not an editing bar, not `multiple` mode).
   */
  get hasSearchButton(): boolean {
    return cylSearchButtonVisible(this.showsSearchButton, this.isEditingBar, this.mode === CYLSearchBarMode.multiple);
  }

  /**
   * The item the bar draws as its search button (iOS `searchButtonItem`): not in `items`; it follows `searchButtonStyle`,
   * `searchButtonTitle` and `searchButtonImage`, and a change of one of them builds it again. Customize it (a tint, a
   * badge) after setting those.
   */
  get searchButtonItem(): CYLSearchBarItem {
    const signature = `${this.searchButtonStyle}|${this.searchButtonTitle ?? ''}|${this.defaultSearchButtonTitle}|` +
      `${this.searchButtonImage === undefined ? 0 : 1}`;
    if (this.searchButtonModel === undefined || signature !== this.searchButtonSignature) {
      this.searchButtonSignature = signature;
      this.searchButtonModel = this.makeSearchButtonItem();
    }
    return this.searchButtonModel;
  }

  private makeSearchButtonItem(): CYLSearchBarItem {
    const look = cylSearchButtonLook(this.searchButtonStyle, this.searchButtonTitle, this.defaultSearchButtonTitle,
      this.searchButtonImage !== undefined);
    const item = new CYLSearchBarItem(look.itemStyle, look.title,
      look.usesBuiltInImage ? $r('sys.symbol.magnifyingglass') : this.searchButtonImage);
    item.itemAccessibilityIdentifier = 'CYLSearchBarSearchButton';
    item.cornerRadius = look.cornerRadius;
    item.itemHeight = look.itemHeight;
    item.contentInsets = look.contentInsets;
    if (look.filled) {
      item.backgroundColor = $r('app.color.cyl_search_button_fill');
      item.tintColor = $r('app.color.cyl_search_button_glyph');
      item.imageSize = 16;
    }
    return item;
  }

  /**
   * The search button was tapped: submits the text (`submit()`); an empty text only tells the delegate
   * (`searchBarViewSearchButtonClicked`); then `searchButtonHandler` runs (iOS `searchButtonTapped`).
   */
  searchButtonTapped(): void {
    if (cylSearchButtonTapAction(this.text) === 1) {
      this.submit();
    } else {
      this.delegate?.searchBarViewSearchButtonClicked?.(this);
    }
    this.searchButtonHandler?.(this);
  }
  /**
   * The icon and title color of every item without its own `tintColor`; undefined uses the label color (the accent
   * while selected).
   */
  @Trace itemTintColor: ResourceColor | undefined = undefined;

  /**
   * The placeholder (with the magnifier) is centered while the field rests and goes to the leading edge while it is
   * edited (iOS `centersPlaceholder`). False by default.
   */
  @Trace centersPlaceholder: boolean = false;
  /**
   * The space around the field on top of the bar's `contentInsets` (iOS `textFieldMargins`). Zero by default.
   */
  @Trace textFieldMargins: CYLSearchEdgeInsets = { top: 0, left: 0, bottom: 0, right: 0 };
  /**
   * Answers the field's margins for each state (`active` is true while the bar is active), and wins over
   * `textFieldMargins` (iOS `textFieldMarginsProvider`).
   */
  @Trace textFieldMarginsProvider: ((searchBarView: CYLSearchBarView, active: boolean) => CYLSearchEdgeInsets) | undefined =
    undefined;
  /**
   * Answers Cancel's margins for each state; a negative `left` moves it toward the field (iOS
   * `cancelButtonMarginsProvider`).
   */
  @Trace cancelButtonMarginsProvider: ((searchBarView: CYLSearchBarView, active: boolean) => CYLSearchEdgeInsets) | undefined =
    undefined;
  /**
   * The font size of Cancel in fp; undefined uses `font` (iOS `cancelButtonFont`).
   */
  @Trace cancelButtonFont: number | undefined = undefined;
  /**
   * Cancel shows while the bar is active even when `showsCancelButton` is false (iOS `automaticallyShowsCancelButton`).
   * False by default.
   */
  @Trace automaticallyShowsCancelButton: boolean = false;
  /**
   * The bar is active because its host (a `CYLSearchView` that is open) says so; it adds to editing.
   */
  @Trace hostIsActive: boolean = false;
  /**
   * The color of Cancel and the caret; undefined uses the system accent (iOS `tintColor`).
   */
  @Trace tintColor: ResourceColor | undefined = undefined;
  /**
   * The color behind the whole bar; undefined draws none (iOS `barBackgroundColor`).
   */
  @Trace barBackgroundColor: ResourceColor | undefined = undefined;
  /**
   * An image behind the whole bar (iOS `barBackgroundImage`).
   */
  @Trace barBackgroundImage: ResourceStr | undefined = undefined;
  /**
   * The color of the line under the bar; undefined draws none (iOS `barBorderColor`).
   */
  @Trace barBorderColor: ResourceColor | undefined = undefined;
  /**
   * A view of yours before the field, inside the bar; it replaces the navigation button (iOS `leadingView`).
   */
  @Trace leadingView: WrappedBuilder<[]> | undefined = undefined;
  /**
   * Whether `leadingView` is shown. True by default (iOS `showsLeadingView`).
   */
  @Trace showsLeadingView: boolean = true;
  /**
   * The space around `leadingView`; `right` is the gap to the field (iOS `leadingAccessoryViewMargins`).
   */
  @Trace leadingAccessoryViewMargins: CYLSearchEdgeInsets = { top: 0, left: 0, bottom: 0, right: 0 };
  /**
   * A view of yours inside the field after the text, before the voice button and the items (iOS
   * `trailingAccessoryViews`).
   */
  @Trace trailingAccessoryViews: WrappedBuilder<[]> | undefined = undefined;
  /**
   * Whether `trailingAccessoryViews` is shown. True by default (iOS `showsTrailingAccessoryViews`).
   */
  @Trace showsTrailingAccessoryViews: boolean = true;
  /**
   * The space around `trailingAccessoryViews`; `left` is the gap to the text (iOS `trailingAccessoryViewMargins`).
   */
  @Trace trailingAccessoryViewMargins: CYLSearchEdgeInsets = { top: 0, left: 0, bottom: 0, right: 0 };
  private appearance: CYLSearchBarAppearance = CYLSearchBarAppearance.defaultAppearance.copy();
  /**
   * Whether Cancel stays enabled while the field is not being edited (iOS `CYLSearchBar.alwaysEnablesCancelButton`).
   * True by default.
   */
  @Trace alwaysEnablesCancelButton: boolean = true;
  // The shapes of the items of the last `setItems` call; undefined once an item was added or removed in another way.
  private itemShapes: string[] | undefined = undefined;

  @Trace private style: CYLSearchBarStyle = CYLSearchBarStyle.plain;
  @Trace private iconified: boolean = false;
  /**
   * 0 while iconified, 1 while open; animated between the two (FlexibleSearchBar's single fraction).
   */
  @Trace expansionFraction: number = 1;
  /**
   * Whether the field is being edited.
   */
  @Trace isEditing: boolean = false;

  @Trace private completedSearches: string[] = [];
  @Trace private editingNewSearch: boolean = false;

  /**
   * A bar with the default look (iOS `-initWithFrame:`).
   */
  constructor() {
    CYLSearchBarView.nextIdentifier += 1;
    this.textFieldId = `CYLSearchBarTextField${CYLSearchBarView.nextIdentifier}`;
  }

  /**
   * The fixed look of the bar. `bordered` draws the field and its items inside one capsule outline.
   */
  get searchBarStyle(): CYLSearchBarStyle {
    return this.style;
  }

  set searchBarStyle(value: CYLSearchBarStyle) {
    this.style = value;
    if (value === CYLSearchBarStyle.bordered) {
      // A visible line on every platform: the secondary text color (60% alpha, light and dark), iOS `.secondaryLabel`; the divider color was a faint 1.3:1 line.
      this.fieldBorderColor = $r('sys.color.font_secondary');
      this.fieldBorderWidth = 1;
      this.fieldBackgroundColor = $r('sys.color.comp_background_primary');
      this.fieldCornerRadius = -1;
    }
  }

  /**
   * The look of the input box of a navigation bar, the one every screen uses: a bordered capsule (corner radius 18) with
   * a soft shadow (opacity 0.06), an opaque white (light) or black (dark) fill, no magnifier, 16 fp text. Call it before
   * `addItem()` and `CYLSearchNavigationBar.embedInNavigationBar()`; items, text and delegate stay the caller's. Examples
   * call it and never set these values (iOS `applyNavigationFieldStyle()`).
   */
  applyNavigationFieldStyle(): void {
    const preset = cylSearchNavigationFieldPreset();
    if (!preset.showsSearchIcon) {
      this.searchIcon = undefined;
    }
    if (preset.bordered) {
      this.searchBarStyle = CYLSearchBarStyle.bordered;
    }
    this.fieldCornerRadius = preset.cornerRadius;
    this.fieldShadowOpacity = preset.shadowOpacity;
    this.fieldBackgroundColor = $r('app.color.cyl_search_navigation_field_fill');
    this.font = preset.fontSize;
  }

  /**
   * Whether the bar is active: being edited, or its host (an open `CYLSearchView`) says so (iOS: the search
   * controller is active).
   */
  get isActive(): boolean {
    return this.isEditing || this.hostIsActive;
  }

  /**
   * Whether Cancel is drawn (`showsCancelButton`, or `automaticallyShowsCancelButton` while active).
   */
  get cancelButtonVisible(): boolean {
    return cylSearchCancelVisible(this.showsCancelButton, this.automaticallyShowsCancelButton, this.isActive);
  }

  /**
   * Whether Cancel can be tapped now (`alwaysEnablesCancelButton`, or the field is being edited).
   */
  get cancelButtonEnabled(): boolean {
    return cylSearchCancelEnabled(this.alwaysEnablesCancelButton, this.isEditing);
  }

  /**
   * Whether the placeholder is drawn centered now.
   */
  get placeholderCentered(): boolean {
    return cylSearchPlaceholderCentered(this.centersPlaceholder, this.isEditing, this.text, this.placeholder !== undefined);
  }

  /**
   * The field's margins for the current state.
   */
  get resolvedTextFieldMargins(): CYLSearchEdgeInsets {
    return cylSearchResolvedInsets(this.textFieldMarginsProvider?.(this, this.isActive), this.textFieldMargins);
  }

  /**
   * Cancel's margins for the current state (zero without a provider).
   */
  get resolvedCancelButtonMargins(): CYLSearchEdgeInsets {
    const none: CYLSearchEdgeInsets = { top: 0, left: 0, bottom: 0, right: 0 };
    return cylSearchResolvedInsets(this.cancelButtonMarginsProvider?.(this, this.isActive), none);
  }

  /**
   * The style values as last applied with `appearanceStyle` (a copy).
   */
  get appearanceStyle(): CYLSearchBarAppearance {
    return this.appearance.copy();
  }

  /**
   * Applies a style to the bar in one step (iOS `appearanceStyle`): fonts, colors, field and bar backgrounds, icons.
   * A value left undefined keeps the bar's own.
   */
  set appearanceStyle(value: CYLSearchBarAppearance) {
    this.appearance = value.copy();
    const style = this.appearance;
    if (style.font !== undefined) {
      this.font = style.font;
    }
    this.textColor = style.textColor ?? this.textColor;
    this.placeholderColor = style.placeholderColor ?? this.placeholderColor;
    this.placeholder = style.placeholder ?? this.placeholder;
    this.cancelButtonTitle = style.cancelTitle ?? this.cancelButtonTitle;
    this.tintColor = style.tintColor ?? this.tintColor;
    this.cursorColor = style.tintColor ?? this.cursorColor;
    this.searchIcon = style.searchIconImage ?? this.searchIcon;
    this.clearImage = style.clearIconImage ?? this.clearImage;
    this.fieldBackgroundColor = style.textFieldBackgroundColor ?? this.fieldBackgroundColor;
    this.fieldBackgroundImage = style.textFieldBackgroundImage ?? this.fieldBackgroundImage;
    if (style.textFieldBorderColor !== undefined) {
      this.fieldBorderColor = style.textFieldBorderColor;
      this.fieldBorderWidth = 1;
    }
    this.fieldCornerRadius = style.textFieldCornerRadius;
    this.barBackgroundColor = style.barBackgroundColor ?? (style.hidesBarBackground ? undefined :
    $r('sys.color.background_primary'));
    this.barBackgroundImage = style.barBackgroundImage;
    this.barBorderColor = style.barBorderColor;
  }

  /**
   * The same view as `leadingView`.
   * @deprecated Use `leadingView`.
   */
  get leadingAccessoryView(): WrappedBuilder<[]> | undefined {
    return this.leadingView;
  }

  set leadingAccessoryView(value: WrappedBuilder<[]> | undefined) {
    this.leadingView = value;
  }

  /**
   * The same flag as `showsLeadingView`.
   * @deprecated Use `showsLeadingView`.
   */
  get showsLeadingAccessoryView(): boolean {
    return this.showsLeadingView;
  }

  set showsLeadingAccessoryView(value: boolean) {
    this.showsLeadingView = value;
  }

  /**
   * The same view as `trailingAccessoryViews`.
   * @deprecated Use `trailingAccessoryViews`.
   */
  get trailingAccessoryView(): WrappedBuilder<[]> | undefined {
    return this.trailingAccessoryViews;
  }

  set trailingAccessoryView(value: WrappedBuilder<[]> | undefined) {
    this.trailingAccessoryViews = value;
  }

  /**
   * The same flag as `showsTrailingAccessoryViews`.
   * @deprecated Use `showsTrailingAccessoryViews`.
   */
  get showsTrailingAccessoryView(): boolean {
    return this.showsTrailingAccessoryViews;
  }

  set showsTrailingAccessoryView(value: boolean) {
    this.showsTrailingAccessoryViews = value;
  }

  /**
   * Shows or hides Cancel, animated over `animationDuration` when `animated` is true (iOS
   * `setShowsCancelButton(_:animated:)`).
   */
  setShowsCancelButton(shows: boolean, animated: boolean): void {
    const apply = () => {
      this.showsCancelButton = shows;
    };
    if (animated && this.animationDuration > 0) {
      cylAnimate(this.uiContext, { duration: this.animationDuration * 1000, curve: Curve.EaseInOut }, apply);
    } else {
      apply();
    }
  }

  /**
   * Shows or hides `leadingView`, animated when `animated` is true (iOS `setShowsLeadingView(_:animated:)`). The state
   * is a flag, so fast toggling ends in the last request.
   */
  setShowsLeadingView(shows: boolean, animated: boolean): void {
    const apply = () => {
      this.showsLeadingView = shows;
    };
    if (animated && this.animationDuration > 0) {
      cylAnimate(this.uiContext, { duration: this.animationDuration * 1000, curve: Curve.EaseInOut }, apply);
    } else {
      apply();
    }
  }

  /**
   * Shows or hides `trailingAccessoryViews`, animated when `animated` is true (iOS
   * `setShowsTrailingAccessoryViews(_:animated:)`).
   */
  setShowsTrailingAccessoryViews(shows: boolean, animated: boolean): void {
    const apply = () => {
      this.showsTrailingAccessoryViews = shows;
    };
    if (animated && this.animationDuration > 0) {
      cylAnimate(this.uiContext, { duration: this.animationDuration * 1000, curve: Curve.EaseInOut }, apply);
    } else {
      apply();
    }
  }

  /**
   * The same as `setShowsLeadingView(_:animated:)`.
   * @deprecated Use `setShowsLeadingView`.
   */
  setShowsLeadingAccessoryView(shows: boolean, animated: boolean): void {
    this.setShowsLeadingView(shows, animated);
  }

  /**
   * The same as `setShowsTrailingAccessoryViews(_:animated:)`.
   * @deprecated Use `setShowsTrailingAccessoryViews`.
   */
  setShowsTrailingAccessoryView(shows: boolean, animated: boolean): void {
    this.setShowsTrailingAccessoryViews(shows, animated);
  }

  /**
   * Whether the bar shows only its search button.
   */
  get isIconified(): boolean {
    return this.iconified;
  }

  /**
   * The views of `items` (`CYLTagButton`s, CollectionViewClassifyMenu), in the same order (iOS `itemViews`).
   */
  get itemViews(): CYLTagButton[] {
    return this.items.map((item: CYLSearchBarItem) => item.itemView);
  }

  /**
   * The first selected item (a `isSelectable` item that is on), or undefined.
   */
  get selectedItem(): CYLSearchBarItem | undefined {
    return this.items.find((item: CYLSearchBarItem) => item.isSelected);
  }

  /**
   * The index of `selectedItem`, or -1.
   */
  get selectedIndex(): number {
    return this.items.findIndex((item: CYLSearchBarItem) => item.isSelected);
  }

  /**
   * Appends an item after the others (iOS `-addItem:`).
   */
  addItem(item: CYLSearchBarItem): void {
    this.insertItem(item, this.items.length);
  }

  /**
   * Inserts an item at an index, clamped to `items` (iOS `-insertItem:atIndex:`).
   */
  insertItem(item: CYLSearchBarItem, index: number): void {
    if (item.searchBarView !== undefined) {
      item.searchBarView.removeItem(item);
    }
    const position = Math.min(Math.max(0, index), this.items.length);
    this.items.splice(position, 0, item);
    item.searchBarView = this;
    this.itemShapes = undefined;
  }

  /**
   * Creates an item and inserts it at an index; a negative or larger index appends it (iOS
   * `-addItemWithStyle:title:image:index:handler:`).
   */
  addItemWithStyle(style: CYLSearchBarItemStyle, title: string | undefined, image: Resource | undefined,
    index: number = -1, handler?: (item: CYLSearchBarItem) => void): CYLSearchBarItem {
    const item = new CYLSearchBarItem(style, title, image);
    item.handler = handler;
    this.insertItem(item, index < 0 ? this.items.length : index);
    return item;
  }

  /**
   * Removes an item from the bar (iOS `-removeItem:`).
   */
  removeItem(item: CYLSearchBarItem): void {
    const index = this.items.indexOf(item);
    if (index < 0) {
      return;
    }
    this.items.splice(index, 1);
    item.searchBarView = undefined;
    this.itemShapes = undefined;
  }

  /**
   * Removes every item.
   */
  removeAllItems(): void {
    this.items.forEach((item: CYLSearchBarItem) => {
      item.searchBarView = undefined;
    });
    this.items = [];
    this.itemShapes = undefined;
  }

  /**
   * Replaces the items with the ones the dictionaries describe (iOS `-setItemsWithDictionaries:`, `CYLSearchBarItem.item`),
   * as the cross-platform bridges send them. When only `animationLoops` and `animationSpeed` differ from the last call,
   * the items stay and take the two values, so the animation is not reloaded; any other difference rebuilds the items.
   */
  setItems(dictionaries: Record<string, Object>[]): void {
    const shapes: string[] = dictionaries.map((dictionary: Record<string, Object>) => cylSearchItemShape(dictionary));
    if (cylSearchItemShapesMatch(this.itemShapes, shapes, this.items.length)) {
      this.items.forEach((item: CYLSearchBarItem, index: number) => {
        const dictionary = dictionaries[index];
        item.animationLoops = (dictionary['animationLoops'] as boolean | undefined) ?? false;
        item.animationSpeed = (dictionary['animationSpeed'] as number | undefined) ?? 1;
      });
      return;
    }
    this.removeAllItems();
    dictionaries.forEach((dictionary: Record<string, Object>) => {
      this.addItem(CYLSearchBarItem.item(dictionary));
    });
    this.itemShapes = shapes;
  }

  /**
   * Applies `CYLSearchBarAppearance.defaultAppearance` (the same method as `CYLSearchBar`).
   */
  applyDefaultAppearance(): void {
    this.appearanceStyle = CYLSearchBarAppearance.defaultAppearance;
  }

  /**
   * True when an item of the style was appended (iOS `-hasItemOfStyle:`).
   */
  hasItem(style: CYLSearchBarItemStyle): boolean {
    return this.items.some((item: CYLSearchBarItem) => item.style === style);
  }

  /**
   * An item was tapped: a selectable item toggles, then the delegate and the item's handler are told.
   */
  itemTapped(item: CYLSearchBarItem): void {
    if (!item.isEnabled) {
      return;
    }
    if (item.isSelectable) {
      item.isSelected = !item.isSelected;
    }
    this.delegate?.searchBarViewDidSelectItem?.(this, item);
    item.handler?.(item);
  }

  /**
   * Sets the text and, when `submit` is true, submits it (iOS `-setText:submit:`).
   */
  setText(text: string | undefined, submit: boolean): void {
    // Set silently: only typing reports `searchBarViewTextDidChange` (Android `text` / `setText`).
    this.text = cylSearchTextLimited(text ?? '', this.maximumTextLength);
    if (submit) {
      this.submit();
    }
  }

  /**
   * Whether the bar is an editing bar (`editingBar`): an edit field in the search bar's look, whose trailing button
   * submits instead of cancelling (iOS `isEditingBar`).
   */
  @Trace isEditingBar: boolean = false;

  /**
   * An editing bar's submit: the trimmed text, when its action button or the enter key is tapped (after
   * `searchBarViewShouldSubmitText` and `searchBarViewSearchButtonClicked`). Empty text submits nothing (iOS
   * `editingSubmitHandler`).
   */
  editingSubmitHandler?: (searchBarView: CYLSearchBarView, text: string) => void;

  /**
   * An editing bar (iOS `editingBar(placeholder:actionTitle:)`): the search bar's field and look for editing a name (a
   * tag, a title), without the magnifier, with `actionTitle` ("Add", "Done") as its trailing button, which submits
   * through `editingSubmitHandler`, as the enter key does. Pin it above the keyboard with `pinToKeyboard` and put it at the
   * bottom of the page; change `cancelButtonTitle` to change the action. (ArkUI's TextInput has no capitalization
   * setting, so words are not capitalized automatically.)
   */
  static editingBar(placeholder: ResourceStr | undefined, actionTitle: ResourceStr): CYLSearchBarView {
    const bar = new CYLSearchBarView();
    bar.isEditingBar = true;
    bar.showsSearchButton = false;
    bar.searchIcon = undefined;
    bar.placeholder = placeholder;
    bar.showsCancelButton = true;
    bar.cancelButtonTitle = actionTitle;
    bar.cancelButtonEndsEditing = false;
    bar.returnKeyType = EnterKeyType.Done;
    return bar;
  }

  /**
   * Pins the bar to the top of the keyboard (iOS `pinToKeyboard(in:)`): the page resizes for the keyboard
   * (`KeyboardAvoidMode.RESIZE`), so a bar placed at the bottom of the page rides on the keyboard while it is up and
   * stays at the bottom while it is down.
   */
  pinToKeyboard(context: UIContext): void {
    context.setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE);
  }

  /**
   * The enter key: an editing bar submits through `editingSubmitHandler`, a search bar submits its text.
   */
  enterKeyTapped(): void {
    if (this.isEditingBar) {
      this.submitEditing();
    } else {
      this.submit();
    }
  }

  /**
   * An editing bar's submit (iOS `submitEditing`): the delegate's checks (`submit()`), then `editingSubmitHandler`.
   */
  private submitEditing(): void {
    const trimmed = (this.text ?? '').trim();
    if (trimmed.length === 0 || !this.submit()) {
      return;
    }
    this.editingSubmitHandler?.(this, trimmed);
  }

  /**
   * Submits the text like the search key; false when the text is empty or the delegate refuses it.
   */
  submit(): boolean {
    if (!cylSearchTextSubmittable(this.text)) {
      return false;
    }
    const allowed = this.delegate?.searchBarViewShouldSubmitText?.(this, this.text) ?? true;
    if (!allowed) {
      return false;
    }
    this.delegate?.searchBarViewSearchButtonClicked?.(this);
    return true;
  }

  /**
   * Focuses the field, which raises the keyboard.
   */
  showKeyboard(): void {
    focusControl.requestFocus(this.textFieldId);
  }

  /**
   * Whether the field takes focus (and the keyboard shows) every time the bar appears on screen, like a `viewDidAppear`:
   * the first time its page is entered, after a tab switch or a push and pop (the component's `aboutToAppear` and
   * visible area), and after the app returns from the background (application foreground). A page that stays alive
   * may also call `barDidAppear()` from its `onPageShow`. False by default (iOS `focusesOnAppear`).
   * TODO: iOS takes its moments from CYLDeallocBlockExecutor; no such dependency here until the unified pin pair is
   * announced (the library's foreground event is not shipped yet).
   */
  focusesOnAppear: boolean = false;

  /**
   * Whether the navigation bar the bar sits in shows a back button; `CYLSearchNavigationPage` sets it from its
   * `showsBack`. It only drives the back button, no longer the auto-focus (see `pageDepth`).
   */
  showsBackButton: boolean = false;

  /**
   * The depth of the bar's page in its `Navigation` (1 = first-level page: a root tab or the first page of a stack).
   * `CYLSearchNavigationPage` / `CYLSearchNavigationTitleBar` feed it from the `NavPathStack` (stack size + 1); a host
   * without a stack may set it. Only a second-level or deeper page auto-focuses (`focusesOnAppear`).
   */
  pageDepth: number = 1;

  /**
   * True when the bar's page is a second-level or deeper page (`pageDepth` above 1); iOS `isOnSecondLevelOrDeeperPage`.
   */
  get isOnSecondLevelOrDeeperPage(): boolean {
    return this.pageDepth > 1;
  }

  /**
   * First-level behaviour (owner directive 2026-11-26): true on the bar of a first-level page. The bar is shown whole in
   * the navigation bar, a tap on it does not edit but plays one push: the back button comes in (the bar narrows by
   * itself), then `onFirstLevelTap` runs, which pushes the second-level search page. False by default.
   */
  pushesOnTap: boolean = false;

  /**
   * Called after the back button started to come in, when a first-level bar (`pushesOnTap`) is tapped: push the
   * second-level page here. The page never animates the back button or the bar width.
   */
  onFirstLevelTap: (() => void) | undefined = undefined;

  /**
   * How far the back button is shown, 0 hidden to 1 shown; the title bar derives the back slot and the bar width from
   * it, so animating it re-lays the bar out smoothly.
   */
  @Trace backButtonProgress: number = 0;

  /**
   * Whether the back button is shown (or coming in).
   */
  get isBackButtonShown(): boolean {
    return this.showsBackButton;
  }

  /**
   * Brings the back button in on the left; the bar narrows to make room. With `animated` the change animates, with the
   * bar's `animationDuration` (default 0.25 s). Asking twice is a no-op (iOS mirrors the name).
   */
  showBackButton(animated: boolean = true): void {
    this.setBackButton(true, animated);
  }

  /**
   * Takes the back button out; the bar grows back to its full width. The reverse of `showBackButton`.
   */
  hideBackButton(animated: boolean = true): void {
    this.setBackButton(false, animated);
  }

  private setBackButton(shown: boolean, animated: boolean): void {
    const request = cylSearchBackButtonRequest(this.showsBackButton, shown, animated);
    if (request === 0) {
      return;
    }
    this.showsBackButton = shown;
    const apply = () => {
      this.backButtonProgress = shown ? 1 : 0;
    };
    if (request === 2) {
      const seconds = this.animationDuration > 0 ? this.animationDuration : 0.25;
      cylAnimate(this.uiContext, { duration: seconds * 1000, curve: Curve.EaseInOut }, apply);
    } else {
      apply();
    }
  }

  /**
   * The tap of a first-level bar (the title bar calls it): back button in, then `onFirstLevelTap`. Does nothing for a bar
   * that is not first-level, or when the push is already under way.
   */
  firstLevelTapped(): void {
    if (cylSearchFirstLevelTapAction(this.pushesOnTap, this.showsBackButton) !== 1) {
      return;
    }
    this.showBackButton(true);
    this.onFirstLevelTap?.();
  }

  /**
   * Keeps the back button in step with the page a `Navigation` shows: a pushed page has it, the first-level (root) page
   * has not. Called by the title bar from the stack's interception, also for the system back gesture.
   */
  syncBackButton(targetIsRootPage: boolean, animated: boolean): void {
    this.setBackButton(cylSearchBackButtonWantedFor(targetIsRootPage), animated);
  }

  /**
   * Applies one of the looks the core ships (`CYLSearchBarPreset`); call it before `addItem()` on a new bar.
   */
  applyPreset(preset: CYLSearchBarPreset): void {
    if (preset === CYLSearchBarPreset.navigationField) {
      this.applyNavigationFieldStyle();
      return;
    }
    const spec = cylSearchBarPresetSpec(preset);
    if (spec.bordered) {
      this.searchBarStyle = CYLSearchBarStyle.bordered;
    }
    this.fieldCornerRadius = spec.cornerRadius;
    this.fieldShadowOpacity = spec.shadowOpacity;
    if (spec.usesNavigationFill) {
      this.fieldBackgroundColor = $r('app.color.cyl_search_navigation_field_fill');
    }
    if (!spec.showsSearchIcon) {
      this.searchIcon = undefined;
    }
    this.centersPlaceholder = spec.centersPlaceholder;
    this.font = spec.fontSize;
  }

  /**
   * The bar appeared on screen: focuses the field when `focusesOnAppear` is on. Called by the component; a host calls
   * it from `onPageShow`.
   */
  barDidAppear(): void {
    if (cylSearchShouldFocusOnAppear(this.focusesOnAppear, this.isOnSecondLevelOrDeeperPage, this.iconified,
      this.isEditing)) {
      this.showKeyboardWhenDrawn();
    }
  }

  /**
   * Focuses the field as soon as it is drawn: tries again each frame (up to 30 frames, about half a second) while the
   * text input does not exist yet, and stops when the bar was iconified again meanwhile.
   */
  private showKeyboardWhenDrawn(attempt: number = 0): void {
    if (this.iconified) {
      return;
    }
    if (focusControl.requestFocus(this.textFieldId) || attempt >= 30) {
      return;
    }
    setTimeout(() => {
      this.showKeyboardWhenDrawn(attempt + 1);
    }, 16);
  }

  /**
   * Focuses the field and returns true (iOS `-becomeFirstResponder`).
   */
  becomeFirstResponder(): boolean {
    this.showKeyboard();
    return true;
  }

  /**
   * Ends editing and returns true (iOS `-resignFirstResponder`).
   */
  resignFirstResponder(): boolean {
    this.hideKeyboard();
    return true;
  }

  /**
   * Ends editing, which lowers the keyboard.
   */
  hideKeyboard(): void {
    this.textField.stopEditing();
  }

  /**
   * Opens or closes the field, animated over `animationDuration` when `animated` is true (iOS
   * `-setIconified:animated:`). Opening also starts editing.
   */
  setIconified(iconified: boolean, animated: boolean): void {
    if (this.iconified === iconified) {
      return;
    }
    if (iconified) {
      this.hideKeyboard();
    }
    const apply = () => {
      this.iconified = iconified;
      this.expansionFraction = iconified ? 0 : 1;
    };
    if (animated && this.animationDuration > 0) {
      cylAnimate(this.uiContext, { duration: this.animationDuration * 1000, curve: Curve.EaseInOut }, apply);
    } else {
      apply();
    }
    if (!iconified) {
      // While iconified the text input is not built; it exists once the open state is drawn (Android posts the
      // keyboard to the field for the same reason).
      this.showKeyboardWhenDrawn();
    }
    this.delegate?.searchBarViewDidChangeIconified?.(this, iconified);
  }

  /**
   * The state to keep across a restart: the text and whether the bar is iconified (iOS
   * `-encodeRestorableStateWithCoder:`).
   */
  encodeRestorableState(): Record<string, Object> {
    const state: Record<string, Object> = { 'text': this.text, 'iconified': this.iconified };
    return state;
  }

  /**
   * Restores what `encodeRestorableState` returned (iOS `-decodeRestorableStateWithCoder:`).
   */
  decodeRestorableState(state: Record<string, Object>): void {
    this.textChanged((state['text'] as string | undefined) ?? '');
    this.setIconified((state['iconified'] as boolean | undefined) ?? false, false);
  }

  /**
   * `multiple` mode: the searches, the completed ones first, then the new one while it is typed (iOS `searches`).
   */
  get searches(): string[] {
    return this.editingNewSearch ? this.completedSearches.concat([this.text]) : this.completedSearches.slice();
  }

  /**
   * `multiple` mode: the completed searches, as the bar draws them.
   */
  get completedSearchTexts(): string[] {
    return this.completedSearches;
  }

  /**
   * `multiple` mode: true while a new search is being typed (iOS `isEditingNewSearch`).
   */
  get isEditingNewSearch(): boolean {
    return this.editingNewSearch;
  }

  /**
   * `multiple` mode: starts a new search and shows the keyboard, like the new-search button (iOS `-beginNewSearch`).
   * Does nothing in `single` mode or while a new search is being typed.
   */
  beginNewSearch(): void {
    if (this.mode !== CYLSearchBarMode.multiple || this.editingNewSearch) {
      return;
    }
    this.text = '';
    this.editingNewSearch = true;
    // Nothing is selected while a search is typed (Android `selectedIndex = NO_SELECTION`).
    this.selectedSearchIndex = -1;
    this.showKeyboardWhenDrawn();
  }

  /**
   * `multiple` mode: completes the new search: it joins `searches` and is selected, or is dropped when shorter than
   * `minimumTextLength` (iOS `-completeSearch`).
   */
  completeSearch(): void {
    if (!this.editingNewSearch) {
      return;
    }
    // The text as typed, not trimmed (Android `completeSearch`).
    const text = this.text;
    this.editingNewSearch = false;
    this.text = '';
    if (!cylSearchTextCompletes(text, this.minimumTextLength)) {
      this.selectedSearchIndex = this.completedSearches.length > 0 ? this.completedSearches.length - 1 : -1;
      return;
    }
    this.completedSearches.push(text);
    this.selectedSearchIndex = this.completedSearches.length - 1;
    this.delegate?.searchBarViewDidCompleteSearch?.(this, text, this.selectedSearchIndex);
  }

  /**
   * `multiple` mode: adds a completed search without typing it and selects it (iOS `-addSearch:`). A search being
   * typed is completed first; the added search is not reported.
   */
  addSearch(text: string): void {
    if (text.length === 0) {
      return;
    }
    if (this.editingNewSearch) {
      this.completeSearch();
    }
    this.completedSearches.push(cylSearchTextLimited(text, this.maximumTextLength));
    this.selectedSearchIndex = this.completedSearches.length - 1;
  }

  /**
   * `multiple` mode: selects a search, like a tap on it (iOS `-selectSearchAtIndex:`).
   */
  selectSearch(index: number): void {
    if (index < 0 || index >= this.completedSearches.length) {
      return;
    }
    if (this.editingNewSearch) {
      this.completeSearch();
    }
    this.selectedSearchIndex = Math.min(index, this.completedSearches.length - 1);
    this.delegate?.searchBarViewDidSelectSearch?.(this, this.completedSearches[this.selectedSearchIndex],
      this.selectedSearchIndex);
  }

  /**
   * `multiple` mode: removes a search, like a tap on its remove button (iOS `-removeSearchAtIndex:`).
   */
  removeSearch(index: number): void {
    if (index < 0 || index >= this.completedSearches.length) {
      return;
    }
    this.completedSearches.splice(index, 1);
    // The next search is selected, or the previous one when the last went away (Android `remove`).
    this.selectedSearchIndex = cylSelectionAfterRemoval(this.selectedSearchIndex, index,
      this.completedSearches.length);
    this.delegate?.searchBarViewDidRemoveSearchAtIndex?.(this, index);
  }

  /**
   * The system Back gesture: in `multiple` mode, completes the new search being typed and returns true; false
   * otherwise. Call it from the page's `onBackPress()` and return its result.
   */
  handleBackPress(): boolean {
    if (!this.editingNewSearch) {
      return false;
    }
    this.completeSearch();
    return true;
  }

  /**
   * The bar's height: the field and the insets above and below it; one row of searches in `multiple` mode (iOS
   * `intrinsicContentSize`).
   */
  get intrinsicContentSize(): number {
    if (this.mode === CYLSearchBarMode.multiple) {
      return 48;
    }
    return this.fieldHeight + Number(this.contentInsets.top ?? 0) + Number(this.contentInsets.bottom ?? 0);
  }

  /**
   * The component reports a new text; the delegate is told when it differs (`searchBarViewTextDidChange`, or
   * `searchBarViewTextDidChangeAtIndex` in `multiple` mode).
   */
  textChanged(text: string): void {
    const next = cylSearchTextLimited(text, this.maximumTextLength);
    if (next === this.text) {
      return;
    }
    this.text = next;
    if (this.mode === CYLSearchBarMode.multiple) {
      this.delegate?.searchBarViewTextDidChangeAtIndex?.(this, next, this.completedSearches.length);
    } else {
      this.delegate?.searchBarViewTextDidChange?.(this, next);
    }
  }

  /**
   * The component reports that editing started or ended.
   */
  editingChanged(editing: boolean): void {
    if (this.isEditing === editing) {
      return;
    }
    this.isEditing = editing;
    if (editing) {
      this.delegate?.searchBarViewDidBeginEditing?.(this);
    } else {
      if (this.clearsTextOnEndEditing) {
        this.textChanged('');
      }
      // With `iconifiedByDefault`, an empty field folds back to the search button (Android).
      if (this.iconifiedByDefault && this.text.length === 0) {
        this.setIconified(true, true);
      }
      this.delegate?.searchBarViewDidEndEditing?.(this);
    }
  }

  /**
   * Cancel was tapped.
   */
  cancelTapped(): void {
    if (this.isEditingBar) {
      // An editing bar's trailing button is its action, not a cancel (iOS `cancelTapped`).
      this.submitEditing();
      return;
    }
    if (this.clearsTextOnCancel) {
      this.textChanged('');
    }
    if (this.cancelButtonEndsEditing) {
      this.hideKeyboard();
    }
    this.delegate?.searchBarViewCancelButtonClicked?.(this);
  }

  /**
   * The button before the field was tapped.
   */
  navigationTapped(): void {
    this.delegate?.searchBarViewNavigationButtonClicked?.(this);
    this.navigationHandler?.(this);
  }

  /**
   * The microphone was tapped.
   */
  voiceTapped(): void {
    this.delegate?.searchBarViewVoiceButtonClicked?.(this);
  }

  /**
   * The symbol of the button before the field, or undefined when it is hidden.
   */
  get navigationSymbol(): Resource | undefined {
    if (this.navigationImage !== undefined) {
      return this.navigationImage;
    }
    if (this.navigationIcon === CYLSearchBarNavigationIcon.arrow) {
      return $r('sys.symbol.chevron_backward');
    }
    if (this.navigationIcon === CYLSearchBarNavigationIcon.search) {
      return $r('sys.symbol.magnifyingglass');
    }
    return undefined;
  }
}

/**
 * The view of a `CYLSearchBarItem` (was the public `CYLSearchBarItemView`; like `CYLFlatDesignTabBarButton`): the item's
 * `itemView`, CollectionViewClassifyMenu's `CYLTagButton` (drawn through `CYLTagButtonHost`, its V1 bridge), styled from
 * the item; a divider is a thin line. The touch region grows to 44 vp around the item.
 */
@ComponentV2
struct CYLSearchBarItemView {
  /**
   * The item this view draws.
   */
  @Require @Param item: CYLSearchBarItem;
  /**
   * The bar's tint, for an item without its own.
   */
  @Param itemTintColor: ResourceColor | undefined = undefined;
  /**
   * The item was tapped (the bar toggles a selectable item, then tells its delegate and the item's handler).
   */
  @Event onSelect: (item: CYLSearchBarItem) => void = () => {
  };

  // Restyles the item's tag from the item; reading the item's properties here redraws this view when one changes.
  private itemButton(): CYLTagButton {
    return this.item.reloadItemView(this.itemTintColor);
  }

  private touchRegion(): Rectangle {
    const size = this.itemButton().intrinsicSize();
    // A hugging item takes touches within 36 vp across (the hit area, not empty room); another keeps the 44 vp target.
    const region = cylSearchTouchRegion(size.width, size.height,
      this.item.hugsContent ? CYL_SEARCH_TOUCH_WIDTH : CYLSearchTouchTargetSide);
    const rectangle: Rectangle = { x: region.x, y: region.y, width: region.width, height: region.height };
    return rectangle;
  }

  private insets(): number {
    return cylSearchBarItemInsets(this.item.style, this.item.contentInsets, this.item.drawsShape);
  }

  // The badge as the screen reader reads it: its text, or "New" (CollectionViewClassifyMenu's string) for a dot.
  private badgeDescription(): string {
    const badge = this.item.badgeValue;
    if (badge === undefined) {
      return '';
    }
    return badge.length === 0 ? CYLMenuLocalizedString('CYLTagBadgeDot') : badge;
  }

  build() {
    if (this.item.style === CYLSearchBarItemStyle.divider) {
      Divider()
        .vertical(true)
        .height(CYLSearchBarDividerHeight)
        .strokeWidth(1)
        .color(CYLSearchBarSecondaryLabel)
        .margin({ left: this.insets(), right: this.insets() })
        .accessibilityLevel('no')
    } else {
      Stack() {
        CYLTagButtonHost({ button: this.itemButton(), interactive: false })
      }
      .responseRegion(this.touchRegion())
      .opacity(this.item.isEnabled ? 1 : 0.4)
      .enabled(this.item.isEnabled)
      .id(this.item.itemAccessibilityIdentifier ?? '')
      .accessibilityGroup(true)
      .accessibilityText(this.item.itemAccessibilityLabel ?? this.item.title ?? '')
      .accessibilityDescription(this.badgeDescription())
      .onClick(() => {
        if (this.item.animationURL !== undefined) {
          this.item.itemView.playAnimation();
        }
        this.onSelect(this.item);
      })
    }
  }
}

/**
 * Draws a `CYLSearchBarView` in `multiple` mode (was `CYLMultiSearchComponent`): the searches in a row that scrolls,
 * the field of the new search, and the new-search button at the trailing end.
 */
@ComponentV2
struct CYLSearchBarSearchesView {
  /**
   * The bar to draw.
   */
  @Require @Param searchBarView: CYLSearchBarView;

  // "Search 2 of 3" in the language the app shows (iOS `multisearch.item`).
  private positionText(position: number, count: number): string {
    try {
      return this.getUIContext().getHostContext()?.resourceManager
        .getStringSync($r('app.string.cyl_multisearch_item').id, position, count) ?? '';
    } catch (error) {
      return '';
    }
  }

  private accent(): ResourceColor {
    return this.searchBarView.searchIndicatorColor ?? $r('sys.color.brand');
  }

  build() {
    Row({ space: 8 }) {
      Scroll() {
        Row({ space: 16 }) {
          ForEach(this.searchBarView.completedSearchTexts, (text: string, index: number) => {
            Column({ space: 4 }) {
              Row({ space: 4 }) {
                Text(text)
                  .fontSize(this.searchBarView.font)
                  .fontColor(this.searchBarView.textColor ?? $r('sys.color.font_primary'))
                  .maxLines(1)
                if (index === this.searchBarView.selectedSearchIndex) {
                  SymbolGlyph(this.searchBarView.removeSearchImage)
                    .fontSize(18)
                    .fontColor([this.accent()])
                    .accessibilityText($r('app.string.cyl_multisearch_remove'))
                    // A 44 vp touch area around the 18 vp icon, without changing the layout.
                    .responseRegion({ x: -13, y: -13, width: 44, height: 44 })
                    .onClick(() => {
                      this.searchBarView.removeSearch(index);
                    })
                }
              }
              Divider()
                .strokeWidth(2)
                .color(this.accent())
                .opacity(index === this.searchBarView.selectedSearchIndex ? 1 : 0)
            }
            .opacity(index === this.searchBarView.selectedSearchIndex ? 1 : this.searchBarView.unselectedSearchAlpha)
            // Screen readers hear the position and whether it is selected (iOS `multisearch.item`).
            .accessibilityDescription(this.positionText(index + 1, this.searchBarView.completedSearchTexts.length))
            .accessibilitySelected(index === this.searchBarView.selectedSearchIndex)
            .onClick(() => {
              this.searchBarView.selectSearch(index);
            })
          }, (text: string, index: number) => `${index}-${text}`)
          if (this.searchBarView.isEditingNewSearch) {
            TextInput({
              text: this.searchBarView.text,
              placeholder: this.searchBarView.placeholder ?? $r('app.string.cyl_search_placeholder'),
              controller: this.searchBarView.textField
            })
              .id(this.searchBarView.textFieldId)
              .width(this.searchBarView.searchFieldWidth)
              .height(36)
              .padding(0)
              .backgroundColor(Color.Transparent)
              .borderRadius(0)
              .fontSize(this.searchBarView.font)
              .fontColor(this.searchBarView.textColor ?? $r('sys.color.font_primary'))
              .placeholderColor(this.searchBarView.placeholderColor ?? $r('app.color.cyl_search_secondary_label'))
              .caretColor(this.searchBarView.cursorColor ?? $r('sys.color.brand'))
              .type(this.searchBarView.keyboardType)
              .enterKeyType(this.searchBarView.returnKeyType)
              .maxLength(this.searchBarView.maximumTextLength > 0 ? this.searchBarView.maximumTextLength : 100000)
              .onChange((value: string) => {
                this.searchBarView.textChanged(value);
              })
              .onSubmit(() => {
                this.searchBarView.completeSearch();
              })
          }
        }
        .padding({ left: 16, right: 8 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .align(Alignment.Start)

      Row() {
        SymbolGlyph(this.searchBarView.newSearchImage)
          .fontSize(22)
          .fontColor([this.accent()])
      }
      .width(44)
      .height(44)
      .justifyContent(FlexAlign.Center)
      .accessibilityGroup(true)
      .accessibilityText($r('app.string.cyl_multisearch_add'))
      .id('CYLSearchBarNewSearch')
      .onClick(() => {
        if (this.searchBarView.isEditingNewSearch) {
          this.searchBarView.completeSearch();
        } else {
          this.searchBarView.beginNewSearch();
        }
      })
    }
    .width('100%')
    .height(this.searchBarView.intrinsicContentSize)
  }
}

/**
 * Draws a `CYLSearchBarView`: the button before the field, the field (magnifier, text, clear button, voice or
 * submit button, appended items) and Cancel; while iconified, only the search button; in `multiple` mode, the
 * searches side by side with the field of a new search and the new-search button.
 */
@ComponentV2
export struct CYLSearchBarComponent {
  /**
   * The bar to draw.
   */
  @Require @Param searchBarView: CYLSearchBarView;
  /**
   * A view of yours before the field (a back button); it wins over the navigation button (iOS `leadingView`).
   */
  @BuilderParam leadingView: () => void = this.emptyBuilder;
  /**
   * Views of yours inside the field after the text, before the items (iOS `trailingAccessoryViews`).
   */
  @BuilderParam trailingAccessoryViews: () => void = this.emptyBuilder;

  @Builder
  emptyBuilder() {
  }

  private secondary(): ResourceColor {
    return this.searchBarView.searchIconTintColor ?? $r('sys.color.font_secondary');
  }

  private radius(): number {
    return this.searchBarView.fieldCornerRadius < 0 ? this.searchBarView.fieldHeight / 2 :
    this.searchBarView.fieldCornerRadius;
  }

  private iconAlignment(): FlexAlign {
    if (this.searchBarView.iconPosition === CYLSearchBarIconPosition.center) {
      return FlexAlign.Center;
    }
    return this.searchBarView.iconPosition === CYLSearchBarIconPosition.leading ? FlexAlign.Start : FlexAlign.End;
  }

  // The field's trailing inset: 12, or the concentric gap with the filled icon style as the last element.
  private fieldTrailingInset(): number {
    const bar = this.searchBarView;
    const icon = bar.hasSearchButton && bar.searchButtonStyle === CYLSearchBarSearchButtonStyle.icon;
    return cylSearchButtonTrailingInset(bar.fieldHeight, CYL_SEARCH_BUTTON_ICON_HEIGHT, 12, icon);
  }

  // A string as is, a resource in the language the app shows (for screen-reader labels).
  private resolvedText(value: ResourceStr): string {
    if (typeof value === 'string') {
      return value;
    }
    try {
      return this.getUIContext().getHostContext()?.resourceManager.getStringSync((value as Resource).id) ?? '';
    } catch (error) {
      return '';
    }
  }

  private barVisible: boolean = false;
  private foregroundCallback: ApplicationStateChangeCallback | undefined = undefined;

  aboutToAppear(): void {
    this.searchBarView.uiContext = this.getUIContext();
    this.searchBarView.defaultSearchButtonTitle = this.resolvedText($r('app.string.cyl_search_button')) || 'Search';
    if (this.searchBarView.iconifiedByDefault) {
      this.searchBarView.setIconified(true, false);
    }
    if (this.searchBarView.focusesOnAppear) {
      this.searchBarView.barDidAppear();
      this.listenForForeground();
    }
  }

  aboutToDisappear(): void {
    this.barVisible = false;
    if (this.foregroundCallback !== undefined) {
      try {
        const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
        context.getApplicationContext().off('applicationStateChange', this.foregroundCallback);
      } catch (error) {
        // The listener goes away with the application.
      }
      this.foregroundCallback = undefined;
    }
  }

  // Return from the background: the bar appears again (viewDidAppear after the app becomes active).
  private listenForForeground(): void {
    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const callback: ApplicationStateChangeCallback = {
        onApplicationForeground: () => {
          if (this.barVisible) {
            this.searchBarView.barDidAppear();
          }
        },
        onApplicationBackground: () => {
        }
      };
      context.getApplicationContext().on('applicationStateChange', callback);
      this.foregroundCallback = callback;
    } catch (error) {
      this.foregroundCallback = undefined;
    }
  }

  private insetsMargin(insets: CYLSearchEdgeInsets): Margin {
    const result: Margin = { top: insets.top, left: insets.left, bottom: insets.bottom, right: insets.right };
    return result;
  }

  private tint(): ResourceColor {
    return this.searchBarView.tintColor ?? $r('sys.color.brand');
  }

  @Builder
  accessory(builder: WrappedBuilder<[]>, insets: CYLSearchEdgeInsets) {
    Row() {
      builder.builder()
    }
    .margin(this.insetsMargin(insets))
    .transition(TransitionEffect.OPACITY)
  }

  @Builder
  field() {
    Stack({ alignContent: Alignment.Center }) {
    Row({ space: CYL_SEARCH_TRAILING_SPACING }) {
      if (this.searchBarView.searchIcon !== undefined && !this.searchBarView.placeholderCentered) {
        SymbolGlyph(this.searchBarView.searchIcon)
          .fontSize(18)
          .fontColor([this.secondary()])
          .accessibilityLevel('no')
      }
      TextInput({
        text: this.searchBarView.text,
        placeholder: this.searchBarView.placeholder,
        controller: this.searchBarView.textField
      })
        .id(this.searchBarView.textFieldId)
        .layoutWeight(1)
        .height('100%')
        .padding(0)
        .backgroundColor(Color.Transparent)
        .borderRadius(0)
        .fontSize(this.searchBarView.font)
        .fontColor(this.searchBarView.textColor ?? $r('sys.color.font_primary'))
        .placeholderColor(this.searchBarView.placeholderCentered ? Color.Transparent :
          (this.searchBarView.placeholderColor ?? $r('app.color.cyl_search_secondary_label')))
        .placeholderFont({ size: this.searchBarView.font })
        .caretColor(this.searchBarView.cursorColor ?? this.tint())
        .type(this.searchBarView.isSecureTextEntry ? InputType.Password : this.searchBarView.keyboardType)
        .enterKeyType(this.searchBarView.returnKeyType)
        .maxLength(this.searchBarView.maximumTextLength > 0 ? this.searchBarView.maximumTextLength : 100000)
        .cancelButton({ style: CancelButtonStyle.INPUT, icon: { color: this.secondary() } })
        .onChange((value: string) => {
          this.searchBarView.textChanged(value);
        })
        .onEditChange((editing: boolean) => {
          this.searchBarView.editingChanged(editing);
        })
        .onSubmit(() => {
          this.searchBarView.enterKeyTapped();
        })
        // A first-level bar (pushesOnTap): a tap on the field is the push, so the input does not take it.
        .hitTestBehavior(this.searchBarView.pushesOnTap ? HitTestMode.None : HitTestMode.Default)
        .onWillInsert(() => {
          const allowed = this.searchBarView.delegate?.searchBarViewShouldBeginEditing?.(this.searchBarView) ?? true;
          if (!allowed) {
            this.searchBarView.delegate?.searchBarViewDidTapWhileNotEditable?.(this.searchBarView);
          }
          return allowed;
        })
      if (this.searchBarView.showsTrailingAccessoryViews && this.searchBarView.trailingAccessoryViews !== undefined) {
        this.accessory(this.searchBarView.trailingAccessoryViews, this.searchBarView.trailingAccessoryViewMargins)
      }
      this.trailingAccessoryViews()
      if (this.searchBarView.showsVoiceButton && this.searchBarView.text.length === 0) {
        Row() {
          SymbolGlyph(this.searchBarView.voiceImage)
            .fontSize(20)
            .fontColor([this.secondary()])
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .accessibilityGroup(true)
        .accessibilityText($r('app.string.cyl_search_voice'))
        .onClick(() => {
          this.searchBarView.voiceTapped();
        })
      }
      if (this.searchBarView.showsSubmitButton && this.searchBarView.text.length > 0) {
        Row() {
          SymbolGlyph(this.searchBarView.submitImage)
            .fontSize(20)
            .fontColor([this.secondary()])
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .accessibilityGroup(true)
        .accessibilityText($r('app.string.cyl_search_submit'))
        .onClick(() => {
          this.searchBarView.submit();
        })
      }
      ForEach(this.searchBarView.items, (item: CYLSearchBarItem) => {
        CYLSearchBarItemView({
          item: item,
          itemTintColor: this.searchBarView.itemTintColor,
          onSelect: (selected: CYLSearchBarItem) => {
            this.searchBarView.itemTapped(selected);
          }
        })
      }, (item: CYLSearchBarItem, index: number) => `${index}-${item.style}-${item.title ?? ''}`)
      if (this.searchBarView.hasSearchButton) {
        if (cylSearchButtonHasDivider(this.searchBarView.items.length)) {
          CYLSearchBarItemView({ item: CYLSearchBarItem.divider() })
        }
        CYLSearchBarItemView({
          item: this.searchBarView.searchButtonItem,
          itemTintColor: this.searchBarView.itemTintColor,
          onSelect: () => {
            this.searchBarView.searchButtonTapped();
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 12, right: this.fieldTrailingInset() })
    // At rest, the magnifier and the placeholder are centered together; a tap goes through to the text input.
    if (this.searchBarView.placeholderCentered) {
      Row({ space: 8 }) {
        if (this.searchBarView.searchIcon !== undefined) {
          SymbolGlyph(this.searchBarView.searchIcon)
            .fontSize(18)
            .fontColor([this.secondary()])
        }
        Text(this.searchBarView.placeholder)
          .fontSize(this.searchBarView.font)
          .fontColor(this.searchBarView.placeholderColor ?? $r('app.color.cyl_search_secondary_label'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .flexShrink(1)
      }
      .padding({ left: 12, right: 12 })
      .hitTestBehavior(HitTestMode.None)
      .accessibilityLevel('no')
    }
    }
    .layoutWeight(1)
    .height(this.searchBarView.fieldHeight)
    // The field (not the items and the search button, which take their own taps) plays the first-level push.
    .onClick(() => {
      if (this.searchBarView.pushesOnTap) {
        this.searchBarView.firstLevelTapped();
      }
    })
    .margin(this.insetsMargin(this.searchBarView.resolvedTextFieldMargins))
    .backgroundColor(this.searchBarView.fieldBackgroundColor ?? $r('sys.color.comp_background_tertiary'))
    .backgroundImage(this.searchBarView.fieldBackgroundImage)
    .backgroundImageSize(ImageSize.Cover)
    .borderRadius(this.radius())
    .border({
      width: this.searchBarView.fieldBorderColor !== undefined ? this.searchBarView.fieldBorderWidth : 0,
      color: this.searchBarView.fieldBorderColor ?? Color.Transparent
    })
    .shadow({
      radius: this.searchBarView.fieldShadowOpacity > 0 ? 8 : 0,
      color: `rgba(0,0,0,${this.searchBarView.fieldShadowOpacity * 0.3})`,
      offsetY: this.searchBarView.fieldShadowOpacity > 0 ? 2 : 0
    })
    .clip(this.searchBarView.fieldBackgroundImage !== undefined)
    .opacity(this.searchBarView.expansionFraction)
    .scale(this.searchBarView.expansionAnimation === CYLSearchBarExpansionAnimation.circularReveal ?
      { x: 0.1 + 0.9 * this.searchBarView.expansionFraction, y: 1 } : { x: 1, y: 1 })
  }

  build() {
    if (this.searchBarView.mode === CYLSearchBarMode.multiple) {
      CYLSearchBarSearchesView({ searchBarView: this.searchBarView })
    } else {
      this.singleBar()
    }
  }

  @Builder
  singleBar() {
    Row({ space: 8 }) {
      if (this.searchBarView.isIconified) {
        Row() {
          SymbolGlyph($r('sys.symbol.magnifyingglass'))
            .fontSize(22)
            .fontColor([this.searchBarView.iconButtonTintColor ?? this.secondary()])
        }
        .width(this.searchBarView.iconButtonBackgroundColor !== undefined ? 56 : 44)
        .height(this.searchBarView.iconButtonBackgroundColor !== undefined ? 56 : 44)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.searchBarView.iconButtonBackgroundColor ?? Color.Transparent)
        .borderRadius(28)
        .shadow({ radius: this.searchBarView.iconButtonBackgroundColor !== undefined ? 6 : 0, color: 'rgba(0,0,0,0.2)', offsetY: 2 })
        .accessibilityGroup(true)
        .accessibilityText($r('app.string.cyl_search_field'))
        .onClick(() => {
          this.searchBarView.setIconified(false, true);
        })
      } else {
        // One slot before the field: the bar's `leadingView` (it replaces the navigation button), else the component's.
        if (this.searchBarView.leadingView !== undefined) {
          if (this.searchBarView.showsLeadingView) {
            this.accessory(this.searchBarView.leadingView, this.searchBarView.leadingAccessoryViewMargins)
          }
        } else {
          this.leadingView()
        }
        if (this.searchBarView.navigationSymbol !== undefined && this.searchBarView.leadingView === undefined) {
          Row() {
            SymbolGlyph(this.searchBarView.navigationSymbol)
              .fontSize(22)
              .fontColor([this.searchBarView.textColor ?? $r('sys.color.font_primary')])
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(this.searchBarView.navigationBackgroundColor ?? Color.Transparent)
          .borderRadius(22)
          .shadow({
            radius: this.searchBarView.navigationShadowOpacity > 0 ? 6 : 0,
            color: `rgba(0,0,0,${this.searchBarView.navigationShadowOpacity * 0.3})`
          })
          .accessibilityGroup(true)
          .accessibilityText(this.resolvedText(this.searchBarView.navigationAccessibilityLabel))
          .onClick(() => {
            this.searchBarView.navigationTapped();
          })
        }
        this.field()
        if (this.searchBarView.cancelButtonVisible) {
          Text(this.searchBarView.cancelButtonTitle)
            .fontSize(this.searchBarView.cancelButtonFont ?? this.searchBarView.font)
            .fontColor(this.tint())
            .maxLines(1)
            .constraintSize({ minWidth: 44, minHeight: 44 })
            .textAlign(TextAlign.Center)
            .enabled(this.searchBarView.cancelButtonEnabled)
            .margin(this.insetsMargin(this.searchBarView.resolvedCancelButtonMargins))
            .transition(TransitionEffect.OPACITY)
            .accessibilityText(this.resolvedText(this.searchBarView.cancelButtonTitle))
            .onClick(() => {
              this.searchBarView.cancelTapped();
            })
        }
      }
    }
    .width('100%')
    .onVisibleAreaChange([0.0, 0.01], (isExpanding: boolean, ratio: number) => {
      const appeared = cylSearchVisibilityAppeared(this.barVisible, ratio);
      this.barVisible = ratio > 0;
      if (appeared && this.searchBarView.focusesOnAppear) {
        this.searchBarView.barDidAppear();
      }
    })
    .justifyContent(this.searchBarView.isIconified ? this.iconAlignment() : FlexAlign.Start)
    .padding(this.searchBarView.contentInsets)
    .backgroundColor(this.searchBarView.barBackgroundColor ?? Color.Transparent)
    .backgroundImage(this.searchBarView.barBackgroundImage)
    .backgroundImageSize(ImageSize.Cover)
    .border({
      width: { bottom: this.searchBarView.barBorderColor !== undefined ? 0.5 : 0 },
      color: this.searchBarView.barBorderColor ?? Color.Transparent
    })
  }
}

/**
 * The height of the search field embedded in a navigation bar: a standard bar is 44, the field is 36.
 * `CYLSearchNavigationPage` sets it on the bar it hosts; the bar's `fieldHeight` is the value to read.
 * The title bar itself is `CYL_SEARCH_NAVIGATION_BAR_HEIGHT` high, ArkUI's default title height.
 */
export const CYL_SEARCH_NAVIGATION_FIELD_HEIGHT: number = 36;

/**
 * The height of the navigation bar that holds the search bar (vp), below the status bar.
 */
export const CYL_SEARCH_NAVIGATION_BAR_HEIGHT: number = 56;

/**
 * The refresh button of a tag list header (iOS `CYLSearchTagListHeader.applyRefreshIcon(to:)`): the system refresh
 * symbol (`sys.symbol.arrow_clockwise`, `CYLSearchResources.imageNamed('refresh')`), never three dots or text,
 * labelled with the localized `tagList.refresh` (Refresh, 更新, 刷新, 重新整理) for screen readers.
 */
@ComponentV2
export struct CYLSearchRefreshButton {
  /**
   * The accessibility identifier of the button.
   */
  @Param identifier: string = 'CYLSearchRefreshButton';
  /**
   * Called when the button is tapped.
   */
  @Event onRefresh: () => void = () => {
  };

  build() {
    SymbolGlyph(CYLSearchResources.imageNamed('refresh'))
      .fontSize(18)
      .fontColor([$r('sys.color.font_secondary')])
      .padding(8)
      .accessibilityText($r('app.string.cyl_tagList_refresh'))
      .id(this.identifier)
      .onClick(() => this.onRefresh())
  }
}

/**
 * The title bar that holds a search bar (the navigation bar's content): the back button's slot, then the whole search bar
 * filling the width inside the safe area. The slot animates from 0 to 32 vp with `searchBarView.backButtonProgress`, so the
 * bar's width follows by itself; a page never sets a width. On a first-level bar (`pushesOnTap`) the field takes
 * the tap and plays the push (`firstLevelTapped()`); the items and the search button keep their own taps. With `stack` (the `NavPathStack` of the `Navigation` that holds the
 * first-level page) the back button follows the stack: in with a push, out with a pop, the back button and the system back
 * gesture alike (the stack's interception; one interception per stack).
 */
@ComponentV2
export struct CYLSearchNavigationTitleBar {
  /**
   * The bar to show.
   */
  @Require @Param searchBarView: CYLSearchBarView;
  /**
   * The stack the first-level page pushes onto; the back button follows it. Undefined: the page drives the button.
   */
  @Param stack: NavPathStack | undefined = undefined;
  /**
   * Called when the back button is tapped.
   */
  @Event onBack: () => void = () => {
  };

  aboutToAppear(): void {
    this.searchBarView.fieldHeight = CYL_SEARCH_NAVIGATION_FIELD_HEIGHT;
    this.searchBarView.uiContext = this.getUIContext();
    const bar = this.searchBarView;
    this.stack?.setInterception({
      willShow: (from: NavDestinationContext | NavBar, to: NavDestinationContext | NavBar,
        operation: NavigationOperation, isAnimated: boolean) => {
        if (operation === NavigationOperation.PUSH || operation === NavigationOperation.POP) {
          bar.pageDepth = to === 'navBar' ? 1 : Math.max(2, (this.stack?.size() ?? 1) + 1);
          bar.syncBackButton(to === 'navBar', isAnimated);
        }
      }
    });
  }

  build() {
    Row() {
      Row() {
        if (this.searchBarView.backButtonProgress > 0) {
          SymbolGlyph(CYLSearchResources.imageNamed('back'))
            .fontSize(20)
            .fontColor([$r('sys.color.font_primary')])
            .width(32)
            .height(44)
            .accessibilityText($r('app.string.cyl_navigationBar_back'))
            .onClick(() => this.onBack())
        }
      }
      .width(cylSearchBackSlotWidth(this.searchBarView.backButtonProgress))
      .opacity(this.searchBarView.backButtonProgress)
      .clip(true)
      Stack() {
        CYLSearchBarComponent({ searchBarView: this.searchBarView })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height(CYL_SEARCH_NAVIGATION_BAR_HEIGHT)
    .padding({ left: cylSearchTitleLeadingInset(this.searchBarView.backButtonProgress), right: 16 })
  }
}

/**
 * A page whose search bar is always in a navigation bar: the bar is the title builder of a `NavDestination`
 * (`isDestination`, a page pushed on a `Navigation`), or the page is wrapped in a `Navigation` created here, so a page
 * without one gets one. The page lays nothing out: its content is the trailing closure.
 */
@ComponentV2
export struct CYLSearchNavigationPage {
  /**
   * The search bar shown in the navigation bar; its `fieldHeight` becomes `CYL_SEARCH_NAVIGATION_FIELD_HEIGHT`.
   */
  @Require @Param searchBarView: CYLSearchBarView;
  /**
   * Whether a back button precedes the bar.
   */
  @Param showsBack: boolean = false;
  /**
   * The `NavPathStack` of the `Navigation` that holds the page; the bar's `pageDepth` is its size + 1 (the root
   * `NavBar` is level 1). Undefined: `showsBack` decides (a page with a back button is second-level).
   */
  @Param stack: NavPathStack | undefined = undefined;
  /**
   * True when the page is pushed on a `Navigation` (a `NavDestination` hosts it); false wraps it in a `Navigation`.
   */
  @Param isDestination: boolean = false;
  /**
   * Called when the back button is tapped.
   */
  @Event onBack: () => void = () => {
  };
  /**
   * The content below the navigation bar.
   */
  @BuilderParam content: () => void = this.emptyContent;
  private ownStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    this.searchBarView.fieldHeight = CYL_SEARCH_NAVIGATION_FIELD_HEIGHT;
    this.searchBarView.pageDepth = this.stack !== undefined ? this.stack.size() + 1 : (this.showsBack ? 2 : 1);
    if (this.showsBack) {
      this.searchBarView.showBackButton(false);
    }
  }

  @Builder
  emptyContent() {
  }

  @Builder
  titleBar() {
    CYLSearchNavigationTitleBar({ searchBarView: this.searchBarView, onBack: () => this.onBack() })
  }

  build() {
    if (this.isDestination) {
      NavDestination() {
        this.content()
      }
      .title({ builder: this.titleBar, height: CYL_SEARCH_NAVIGATION_BAR_HEIGHT })
      .hideTitleBar(false)
      .hideBackButton(true)
    } else {
      Navigation(this.ownStack) {
        this.content()
      }
      .title({ builder: this.titleBar, height: CYL_SEARCH_NAVIGATION_BAR_HEIGHT })
      .titleMode(NavigationTitleMode.Mini)
      .hideBackButton(true)
      .mode(NavigationMode.Stack)
    }
  }
}

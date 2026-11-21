import { KeyboardAvoidMode } from '@kit.ArkUI';
import { UIContext } from '@kit.ArkUI';
import {
  CYLControlState, CYLEdgeInsets, CYLFont, CYLMenuLocalizedString, CYLMenuStyle, CYLOffset, CYLSize, CYLTagButton,
  CYLTagButtonHost, CYLTagCornerRadiusSquare
} from '@cyl/classifymenu';

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
 * The horizontal padding of an item in vp: its own when 0 or more, else 4 for a text item (style 2) and 0 for the
 * others (iOS `CYLSearchBarItemButton.resolvedInsets`).
 */
function cylSearchBarItemInsets(style: number, contentInsets: number): number {
  if (contentInsets >= 0) {
    return contentInsets;
  }
  return style === 2 ? 4 : 0;
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
   * Styles `itemView` from the item for its current state (iOS `CYLSearchBarItemButton.reload()`): no border, the
   * item's background (transparent by default), its tint (`barTint` when it has none) for the title and the icon, its
   * title attributes, icon size, insets, position adjustments and badge; at least 36 x 36 vp. Returns the view.
   */
  reloadItemView(barTint: ResourceColor | undefined): CYLTagButton {
    this.itemViewTint = barTint;
    const button = this.itemButton ?? this.itemView;
    const content = cylSearchBarItemButtonContent<ResourceStr>(this.style, this.title, this.image, this.selectedImage,
      this.animatedImage, this.animationURL, this.badgeValue);
    button.style = this.itemStyle(this.tintColor ?? barTint ?? $r('sys.color.font_primary'));
    button.minimumSize = new CYLSize(CYLSearchBarItemMinimumSide, CYLSearchBarItemMinimumSide);
    button.title = content.title;
    button.image = content.image;
    button.selectedImage = content.selectedImage;
    button.animationURL = content.animationURL;
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
  private itemStyle(tint: ResourceColor): CYLMenuStyle {
    const style = new CYLMenuStyle();
    const side = this.imageSize > 0 ? this.imageSize : 20;
    const insets = cylSearchBarItemInsets(this.style, this.contentInsets);
    const background = this.isSelected ? (this.selectedBackgroundColor ?? this.backgroundColor) : this.backgroundColor;
    const hasBackground = this.backgroundColor !== undefined || this.selectedBackgroundColor !== undefined;
    const attributes = this.titleTextAttributes(this.currentState) ??
    this.titleTextAttributes(CYLSearchBarItemState.normal);
    style.imageSize = new CYLSize(side, side);
    style.animationSize = new CYLSize(side, side);
    style.imageTitleSpacing = 4;
    style.itemHeight = CYLSearchBarItemMinimumSide;
    style.imagePositionAdjustment = new CYLOffset(cylLength(this.imagePositionAdjustment.x),
      cylLength(this.imagePositionAdjustment.y));
    style.titlePositionAdjustment = new CYLOffset(cylLength(this.titlePositionAdjustment.x),
      cylLength(this.titlePositionAdjustment.y));
    [CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED].forEach((state: number) => {
      const appearance = style.appearance(state);
      appearance.font = new CYLFont(attributes?.size ?? 17, attributes?.weight ?? FontWeight.Bold);
      appearance.textColor = attributes?.color ?? tint;
      appearance.iconColor = tint;
      appearance.backgroundColor = background ?? Color.Transparent;
      appearance.borderColor = undefined;
      appearance.borderWidth = 0;
      appearance.contentInsets = new CYLEdgeInsets(0, insets, 0, insets);
      appearance.cornerRadius = hasBackground ? 10 : CYLTagCornerRadiusSquare;
    });
    return style;
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
  placeholderColor: ResourceColor | undefined = $r('sys.color.font_tertiary');
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
  @Trace navigationAccessibilityLabel: ResourceStr = $r('app.string.cyl_search_back');
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
   * The icon and title color of every item without its own `tintColor`; undefined uses the primary text color.
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
   * A view of yours before the field, inside the bar (iOS `leadingAccessoryView`).
   */
  @Trace leadingAccessoryView: WrappedBuilder<[]> | undefined = undefined;
  /**
   * Whether the leading accessory view is shown. True by default.
   */
  @Trace showsLeadingAccessoryView: boolean = true;
  /**
   * The space around the leading accessory view; `right` is the gap to the field (iOS `leadingAccessoryViewMargins`).
   */
  @Trace leadingAccessoryViewMargins: CYLSearchEdgeInsets = { top: 0, left: 0, bottom: 0, right: 0 };
  /**
   * A view of yours after the field, before Cancel (iOS `trailingAccessoryView`).
   */
  @Trace trailingAccessoryView: WrappedBuilder<[]> | undefined = undefined;
  /**
   * Whether the trailing accessory view is shown. True by default.
   */
  @Trace showsTrailingAccessoryView: boolean = true;
  /**
   * The space around the trailing accessory view; `left` is the gap to the field (iOS `trailingAccessoryViewMargins`).
   */
  @Trace trailingAccessoryViewMargins: CYLSearchEdgeInsets = { top: 0, left: 0, bottom: 0, right: 0 };
  private appearance: CYLSearchBarAppearance = CYLSearchBarAppearance.defaultAppearance.copy();

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
      this.fieldBorderColor = $r('sys.color.comp_divider');
      this.fieldBorderWidth = 1;
      this.fieldBackgroundColor = $r('sys.color.comp_background_primary');
      this.fieldCornerRadius = -1;
    }
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
   * Shows or hides the leading accessory view, animated when `animated` is true (iOS
   * `setShowsLeadingAccessoryView(_:animated:)`). The state is a flag, so fast toggling ends in the last request.
   */
  setShowsLeadingAccessoryView(shows: boolean, animated: boolean): void {
    const apply = () => {
      this.showsLeadingAccessoryView = shows;
    };
    if (animated && this.animationDuration > 0) {
      cylAnimate(this.uiContext, { duration: this.animationDuration * 1000, curve: Curve.EaseInOut }, apply);
    } else {
      apply();
    }
  }

  /**
   * Shows or hides the trailing accessory view, animated when `animated` is true (iOS
   * `setShowsTrailingAccessoryView(_:animated:)`).
   */
  setShowsTrailingAccessoryView(shows: boolean, animated: boolean): void {
    const apply = () => {
      this.showsTrailingAccessoryView = shows;
    };
    if (animated && this.animationDuration > 0) {
      cylAnimate(this.uiContext, { duration: this.animationDuration * 1000, curve: Curve.EaseInOut }, apply);
    } else {
      apply();
    }
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
  }

  /**
   * Removes every item.
   */
  removeAllItems(): void {
    this.items.forEach((item: CYLSearchBarItem) => {
      item.searchBarView = undefined;
    });
    this.items = [];
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
    const region = cylSearchTouchRegion(size.width, size.height, CYLSearchTouchTargetSide);
    const rectangle: Rectangle = { x: region.x, y: region.y, width: region.width, height: region.height };
    return rectangle;
  }

  private insets(): number {
    return cylSearchBarItemInsets(this.item.style, this.item.contentInsets);
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
        .height(18)
        .strokeWidth(1)
        .color($r('sys.color.comp_divider'))
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
              .placeholderColor(this.searchBarView.placeholderColor ?? $r('sys.color.font_tertiary'))
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

  aboutToAppear(): void {
    this.searchBarView.uiContext = this.getUIContext();
    if (this.searchBarView.iconifiedByDefault) {
      this.searchBarView.setIconified(true, false);
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
    Row({ space: 8 }) {
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
          (this.searchBarView.placeholderColor ?? $r('sys.color.font_tertiary')))
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
        .onWillInsert(() => {
          const allowed = this.searchBarView.delegate?.searchBarViewShouldBeginEditing?.(this.searchBarView) ?? true;
          if (!allowed) {
            this.searchBarView.delegate?.searchBarViewDidTapWhileNotEditable?.(this.searchBarView);
          }
          return allowed;
        })
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
    }
    .width('100%')
    .height('100%')
    .padding({ left: 12, right: 12 })
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
          .fontColor(this.searchBarView.placeholderColor ?? $r('sys.color.font_tertiary'))
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
        this.leadingView()
        if (this.searchBarView.navigationSymbol !== undefined) {
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
        if (this.searchBarView.showsLeadingAccessoryView && this.searchBarView.leadingAccessoryView !== undefined) {
          this.accessory(this.searchBarView.leadingAccessoryView, this.searchBarView.leadingAccessoryViewMargins)
        }
        this.field()
        if (this.searchBarView.showsTrailingAccessoryView && this.searchBarView.trailingAccessoryView !== undefined) {
          this.accessory(this.searchBarView.trailingAccessoryView, this.searchBarView.trailingAccessoryViewMargins)
        }
        if (this.searchBarView.cancelButtonVisible) {
          Text(this.searchBarView.cancelButtonTitle)
            .fontSize(this.searchBarView.cancelButtonFont ?? this.searchBarView.font)
            .fontColor(this.tint())
            .maxLines(1)
            .constraintSize({ minWidth: 44, minHeight: 44 })
            .textAlign(TextAlign.Center)
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

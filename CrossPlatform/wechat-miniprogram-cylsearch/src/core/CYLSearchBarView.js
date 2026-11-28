// The search bar module of cyl-search-miniprogram (iOS `CYLSearchBarView.swift`): `CYLSearchBarView` (one search, or
// several searches side by side with `mode` "multiple", which was `CYLMultiSearchView`), `CYLSearchBarItem` (the
// appended items, which `<cyl-search-bar>` draws itself; was `CYLSearchBarItemView`), the delegate and the enums.
// The `<cyl-search-bar>` component draws a `CYLSearchBarView`. Merged from CYLSearchBarView.js, CYLSearchBarItem.js,
// CYLMultiSearchView.js and the component helper cyl_search_bar_item.js.
'use strict';

const { $r, animateTo, Curve, InputType, EnterKeyType, CYLSearchResources } = require('./CYLSearchResources');

/**
 * What the bar edits (iOS `CYLSearchBarMode`): one search (the default), or several searches side by side.
 */
const CYLSearchBarMode = Object.freeze({
  single: 'single',
  multiple: 'multiple',
});

/**
 * How an item appended to a search bar looks (iOS `CYLSearchBarItemStyle`): an icon button, a divider or a text
 * button.
 */
/**
 * How the default search button looks (iOS `CYLSearchBarSearchButtonStyle`): a filled capsule with the magnifier (the default),
 * or the localized "Search" as text.
 */
const CYLSearchBarSearchButtonStyle = Object.freeze({
  text: 'text',
  icon: 'icon',
});

/** `CYLSearchBarItem.cornerRadius` automatic: 10 with a background, square without (iOS `automaticCornerRadius`). */
const CYLSearchBarItemCornerRadiusAutomatic = -1;

/** `CYLSearchBarItem.cornerRadius` capsule (iOS `CYLAnimatedItemCornerRadiusCapsule`). */
const CYLSearchBarItemCornerRadiusCapsule = 1000;

/** The smallest height of an item's view, in px. */
const CYL_SEARCH_ITEM_MINIMUM_SIDE = 36;

/**
 * The corner radius an item is drawn with: its own unless automatic, which is 10 with a background and square without.
 */
function cylSearchItemResolvedCornerRadius(cornerRadius, hasBackground) {
  if (cornerRadius !== CYLSearchBarItemCornerRadiusAutomatic && cornerRadius >= 0) return cornerRadius;
  return hasBackground ? 10 : 0;
}

/** The height of an item's view: its own `itemHeight` when above 0, else the 36 px minimum. */
function cylSearchItemResolvedHeight(itemHeight) {
  return itemHeight > 0 ? itemHeight : CYL_SEARCH_ITEM_MINIMUM_SIDE;
}

/** The space between two elements of the trailing group (camera, divider, search button), and before the first one, in px. */
const CYL_SEARCH_TRAILING_SPACING = 8;

/** The touch width of a plain item, in px: widened by the hit area, never by empty room around the glyph. */
const CYL_SEARCH_TOUCH_WIDTH = 36;

/**
 * Whether an item hugs its content (owner, 2026-11-26): a plain icon or text item (no background, no outline, no custom height)
 * is as wide as its glyph or title; an item with a shape of its own (the icon search capsule) keeps its size. A divider never hugs.
 */
function cylSearchItemHugsContent(style, hasShape, itemHeight) {
  if (style === 'divider') return false;
  if (style === 'icon') return !hasShape && !(itemHeight > 0);
  return !hasShape;
}

/**
 * The layout model of the trailing group: `elements` are `{ style, hasShape, itemHeight, contentWidth }` from the left; the group
 * puts `spacing` before each element and nothing else (no empty room inside an item). Returns each element's `left`, `right`,
 * `width` and the `touchLeft` / `touchRight` of its hit area (a hugging item's is widened to 36 px about its center).
 */
function cylSearchTrailingGroupLayout(elements, spacing) {
  const gap = spacing === undefined ? CYL_SEARCH_TRAILING_SPACING : spacing;
  let x = 0;
  return elements.map((element) => {
    const hugs = cylSearchItemHugsContent(element.style, element.hasShape === true, element.itemHeight || 0);
    let width = element.contentWidth;
    if (element.style === 'divider') width = 1;
    else if (!hugs) width = Math.max(width, element.itemHeight > 0 ? element.itemHeight : CYL_SEARCH_ITEM_MINIMUM_SIDE);
    const left = x + gap;
    const right = left + width;
    const extra = hugs ? Math.max(0, (CYL_SEARCH_TOUCH_WIDTH - width) / 2) : 0;
    x = right;
    return { left, right, width, hugs, touchLeft: left - extra, touchRight: right + extra };
  });
}

/** Whether a bar draws the default search button: `showsSearchButton`, never for an editing bar or in multiple mode. */
function cylSearchButtonVisible(showsSearchButton, isEditingBar, isMultiple) {
  return showsSearchButton === true && !isEditingBar && !isMultiple;
}

/** Whether a divider precedes the search button: only when an owner's item comes before it. */
function cylSearchButtonHasDivider(ownerItemCount) {
  return ownerItemCount > 0;
}

/**
 * The look of the default search button. Text: a text item with the custom title or the localized default and no fill.
 * Icon: an icon item (the custom image, else the built-in magnifier) as a filled capsule 28 high with 16 side insets
 * (`cylSearchButtonColors` gives the inverse colors); its title is what screen readers read.
 */
function cylSearchButtonLook(style, customTitle, defaultTitle, hasCustomImage) {
  const title = customTitle ? customTitle : defaultTitle;
  if (style === CYLSearchBarSearchButtonStyle.icon) {
    return { itemStyle: 'icon', title, usesBuiltInImage: !hasCustomImage, filled: true,
      cornerRadius: CYLSearchBarItemCornerRadiusCapsule, itemHeight: 28, contentInsets: 16 };
  }
  return { itemStyle: 'text', title, usesBuiltInImage: false, filled: false,
    cornerRadius: CYLSearchBarItemCornerRadiusAutomatic, itemHeight: 0, contentInsets: -1 };
}

/**
 * The trailing inset of the field's content: with the filled icon style as the last element, the pill sits concentric in the
 * field, so the gap at its right equals the gap above and below, (fieldHeight - itemHeight) / 2 (4 for a 36 field and a 28 pill);
 * otherwise the usual inset.
 */
function cylSearchButtonTrailingInset(fieldHeight, itemHeight, usualInset, isFilledIcon) {
  return isFilledIcon ? Math.max(0, (fieldHeight - itemHeight) / 2) : usualInset;
}

/** What a tap on the search button does with the text: 1 submit it (not empty), 0 only tell the listener (empty text). */
function cylSearchButtonTapAction(text) {
  return typeof text === 'string' && text.trim().length > 0 ? 1 : 0;
}

/** The colors of the filled icon style, inverse of the color mode: black with a white magnifier, white with black in dark. */
function cylSearchButtonColors(dark) {
  return dark === true ? { fill: '#FFFFFF', glyph: '#000000' } : { fill: '#000000', glyph: '#FFFFFF' };
}

const CYLSearchBarItemStyle = Object.freeze({
  icon: 'icon',
  divider: 'divider',
  text: 'text',
});

/**
 * The fixed look of the whole bar (iOS `CYLSearchBarStyle`): the field as configured, or a capsule with an outline.
 */
const CYLSearchBarStyle = Object.freeze({
  plain: 'plain',
  bordered: 'bordered',
});

/**
 * The icon of the button before the field (iOS `CYLSearchBarNavigationIcon`).
 */
const CYLSearchBarNavigationIcon = Object.freeze({
  none: 'none',
  arrow: 'arrow',
  search: 'search',
});

/**
 * Where the search button sits while the bar is iconified (iOS `CYLSearchBarIconPosition`).
 */
const CYLSearchBarIconPosition = Object.freeze({
  trailing: 'trailing',
  center: 'center',
  leading: 'leading',
});

/**
 * How the field opens from the search button (iOS `CYLSearchBarExpansionAnimation`).
 */
const CYLSearchBarExpansionAnimation = Object.freeze({
  fade: 'fade',
  circularReveal: 'circularReveal',
});

/**
 * The item states for text attributes (iOS `UIControlState`).
 */
const CYLSearchBarItemState = Object.freeze({
  normal: 'normal',
  selected: 'selected',
  disabled: 'disabled',
});

/**
 * The merged default style of a bar (iOS `CYLSearchBarAppearance`): QMUI's template merged with the legacy CYLSearchBar
 * (field RGB 187, 186, 193 in light mode and 58, 58, 60 in dark mode, tint RGB 0, 104, 248, a pill field). The keys are the
 * iOS names (`font` is a size in px, the images are paths or URLs); `<cyl-search-bar appearance>` takes the plain values of
 * `CYLSearchBarAppearance.default()` and applies them only to what the bar does not set itself.
 */
/**
 * The navigation field preset (the Discover look), the one set of values behind `CYLSearchBarView.applyNavigationFieldStyle()`
 * and the component property `navigationFieldStyle`: a bordered capsule (radius 18), a soft shadow (0.06), no magnifier,
 * 16 text; the fill is opaque white (light) or black (dark), see `cylNavigationFieldFill`.
 */
function cylNavigationFieldStyle() {
  return { cornerRadius: 18, shadowOpacity: 0.06, fontSize: 16, showsSearchIcon: false, bordered: true };
}

/**
 * The looks of a search bar the core ships, one per tab of the example (`CYLSearchBarView.applyPreset(name)`, the
 * component property `preset`): "navigationField" (the Discover look), "pill" (a borderless full capsule with a magnifier),
 * "rounded" (borderless, radius 10), "outlined" (bordered, radius 8) and "centeredCapsule" (bordered full capsule, the
 * placeholder centered). `cornerRadius` -1 is a full capsule. An unknown name is the navigation field.
 */
const CYLSearchBarPreset = Object.freeze({
  navigationField: 'navigationField',
  pill: 'pill',
  rounded: 'rounded',
  outlined: 'outlined',
  centeredCapsule: 'centeredCapsule',
});

function cylSearchBarPresetSpec(name) {
  switch (name) {
    case CYLSearchBarPreset.pill:
      return { bordered: false, cornerRadius: -1, shadowOpacity: 0, fontSize: 16, showsSearchIcon: true, centersPlaceholder: false, usesNavigationFill: false };
    case CYLSearchBarPreset.rounded:
      return { bordered: false, cornerRadius: 10, shadowOpacity: 0, fontSize: 16, showsSearchIcon: true, centersPlaceholder: false, usesNavigationFill: false };
    case CYLSearchBarPreset.outlined:
      return { bordered: true, cornerRadius: 8, shadowOpacity: 0, fontSize: 16, showsSearchIcon: true, centersPlaceholder: false, usesNavigationFill: true };
    case CYLSearchBarPreset.centeredCapsule:
      return { bordered: true, cornerRadius: -1, shadowOpacity: 0.06, fontSize: 16, showsSearchIcon: true, centersPlaceholder: true, usesNavigationFill: true };
    default:
      return Object.assign({ centersPlaceholder: false, usesNavigationFill: true }, cylNavigationFieldStyle());
  }
}

/**
 * The opaque fill of the navigation field: white in light mode, black in dark mode.
 */
function cylNavigationFieldFill(dark) {
  return dark ? '#000000' : '#FFFFFF';
}

/**
 * Whether the bar takes focus when it appears (iOS `focusIfAppearing`, property `focusesOnAppear`): the option is on,
 * the page is a SECOND-LEVEL OR DEEPER page (`getCurrentPages().length > 1`; a first-level page, a root tab or the
 * first page of the stack, never auto-focuses), the field is drawn (not iconified) and it may be edited.
 */
function cylSearchShouldFocusOnAppear(focusesOnAppear, isOnSecondLevelOrDeeperPage, iconified, editable) {
  return Boolean(focusesOnAppear) && Boolean(isOnSecondLevelOrDeeperPage) && !iconified && editable !== false;
}

/**
 * Whether the page is a second-level or deeper page: more than one page in the page stack
 * (`getCurrentPages().length > 1`); iOS `isOnSecondLevelOrDeeperPage`.
 */
function cylSearchIsOnSecondLevelOrDeeperPage(pageCount) {
  return pageCount > 1;
}

class CYLSearchBarAppearance {
  /**
   * A style with the merged defaults (iOS `CYLSearchBarAppearance()`).
   */
  constructor() {
    /** The font size of the text and of the placeholder, in px. */
    this.font = 17;
    /** The color of the typed text; empty keeps the page's. */
    this.textColor = '';
    /** The color of the placeholder. */
    this.placeholderColor = 'rgba(60, 60, 67, 0.3)';
    /** The placeholder; empty is the core's localized "Search". */
    this.placeholder = '';
    /** The title of the Cancel button; empty is the core's localized "Cancel". */
    this.cancelTitle = '';
    /** The tint of the bar and the controls on it. */
    this.tintColor = '#0068F8';
    /** The magnifier icon (a path); empty keeps the core's. */
    this.searchIconImage = '';
    /** The clear button icon (a path); empty keeps the core's. */
    this.clearIconImage = '';
    /** The color of the text field in light mode. */
    this.textFieldBackgroundColor = '#BBBAC1';
    /** The color of the text field in dark mode. */
    this.textFieldBackgroundColorDark = '#3A3A3C';
    /** The background image of the text field (a path); wins over the color. */
    this.textFieldBackgroundImage = '';
    /** The border color of the text field, one px wide; empty is no border. */
    this.textFieldBorderColor = '';
    /** The corner radius of the text field: a negative value is half of its height. */
    this.textFieldCornerRadius = -1;
    /** The background image of the whole bar (a path); wins over the color and the border. */
    this.barBackgroundImage = '';
    /** The background color of the bar. */
    this.barBackgroundColor = '';
    /** The color of the bar's bottom border, one px wide. */
    this.barBorderColor = '';
    /** Whether a bar without any background image, color or border draws no background at all. */
    this.hidesBarBackground = true;
  }

  /**
   * A fresh plain copy of the merged defaults, to change and pass to the bar.
   */
  static default() {
    return Object.assign({}, new CYLSearchBarAppearance());
  }

  /**
   * The default style as a shared getter (iOS `CYLSearchBarAppearance.defaultAppearance`): a fresh copy each time.
   */
  static get defaultAppearance() {
    return CYLSearchBarAppearance.default();
  }

  /**
   * An independent copy of this style (iOS `copy(with:)`).
   */
  copy() {
    return Object.assign(new CYLSearchBarAppearance(), this);
  }

  /**
   * The CSS of a style (`dark` picks the dark field color): the bar, the field, the input and the Cancel button.
   */
  static styles(values, dark) {
    const a = Object.assign(CYLSearchBarAppearance.default(), values || {});
    const field = [`background: ${dark ? a.textFieldBackgroundColorDark : a.textFieldBackgroundColor}`];
    // The background image wins over the color (QMUI `SearchBarTextFieldBackgroundImage`).
    if (a.textFieldBackgroundImage) field.push(`background: url(${a.textFieldBackgroundImage}) center / 100% 100% no-repeat`);
    if (a.textFieldBorderColor) field.push(`border: 1px solid ${a.textFieldBorderColor}`);
    const bar = [];
    if (a.barBackgroundImage) bar.push(`background: url(${a.barBackgroundImage}) center / 100% 100% no-repeat`);
    else if (a.barBackgroundColor) bar.push(`background: ${a.barBackgroundColor}`);
    else if (!a.hidesBarBackground && !a.barBorderColor) bar.push(`background: ${dark ? '#1C1C1E' : '#F7F7F7'}`);
    if (a.barBorderColor) bar.push(`border-bottom: 1px solid ${a.barBorderColor}`);
    return {
      bar: bar.join('; '),
      field: field.join('; '),
      radius: a.textFieldCornerRadius,
      fontSize: a.font,
      textColor: a.textColor,
      placeholderColor: a.placeholderColor,
      placeholder: a.placeholder,
      cancelTitle: a.cancelTitle,
      tintColor: a.tintColor,
      searchIcon: a.searchIconImage,
      clearIcon: a.clearIconImage,
      cancel: a.tintColor ? `color: ${a.tintColor}` : '',
    };
  }

  /**
   * The CSS background of a text field in `color` (iOS `CYLSearchBar.textFieldBackgroundImage(color:)`): CSS draws it, so
   * it has no bitmap; undefined without a color.
   */
  static textFieldBackgroundCSS(color) {
    return color ? `background: ${color}` : undefined;
  }

  /**
   * The CSS background of a bar (iOS `CYLSearchBar.backgroundImage(color:borderColor:)`): `color` (white by default) with a
   * 1 px bottom border in `borderColor`; undefined when both are missing.
   */
  static backgroundCSS(color, borderColor) {
    if (!color && !borderColor) return undefined;
    const css = [`background: ${color || '#FFFFFF'}`];
    if (borderColor) css.push(`border-bottom: 1px solid ${borderColor}`);
    return css.join('; ');
  }
}

/**
 * The insets of a state as CSS (`top right bottom left` in px) from `{ top, left, bottom, right }`; empty for nothing.
 */
function cylInsetsCSS(insets) {
  if (!insets) return '';
  const n = (value) => `${Number(value) || 0}px`;
  return `${n(insets.top)} ${n(insets.right)} ${n(insets.bottom)} ${n(insets.left)}`;
}

/**
 * The events of a `CYLSearchBarView` (iOS `CYLSearchBarViewDelegate`); every method is optional. The four
 * `...AtIndex` methods are the events of the "multiple" mode.
 */
class CYLSearchBarViewDelegate {
  /**
   * An empty delegate: set the methods you need.
   */
  constructor() {
    this.searchBarViewShouldBeginEditing = undefined;
    this.searchBarViewDidTapWhileNotEditable = undefined;
    this.searchBarViewDidBeginEditing = undefined;
    this.searchBarViewDidEndEditing = undefined;
    this.searchBarViewTextDidChange = undefined;
    this.searchBarViewSearchButtonClicked = undefined;
    this.searchBarViewCancelButtonClicked = undefined;
    this.searchBarViewNavigationButtonClicked = undefined;
    this.searchBarViewVoiceButtonClicked = undefined;
    this.searchBarViewShouldSubmitText = undefined;
    this.searchBarViewDidChangeIconified = undefined;
    this.searchBarViewDidSelectItem = undefined;
    this.searchBarViewTextDidChangeAtIndex = undefined;
    this.searchBarViewDidCompleteSearch = undefined;
    this.searchBarViewDidRemoveSearchAtIndex = undefined;
    this.searchBarViewDidSelectSearch = undefined;
  }
}

// Calls an optional delegate method.
function tell(delegate, method, ...args) {
  if (delegate && typeof delegate[method] === 'function') return delegate[method](...args);
  return undefined;
}

/**
 * A font weight of the title attributes (a number such as 600, or a name) as CollectionViewClassifyMenu names it
 * (`semibold`); undefined is `semibold`, the iOS default of a bar item's title.
 */
function cylFontWeightName(weight) {
  const names = { 100: 'ultralight', 200: 'thin', 300: 'light', 400: 'regular', 500: 'medium', 600: 'semibold',
    700: 'bold', 800: 'heavy', 900: 'black' };
  if (typeof weight === 'number') return names[Math.min(900, Math.max(100, Math.round(weight / 100) * 100))];
  if (typeof weight === 'string' && weight) return /^\d+$/.test(weight) ? cylFontWeightName(Number(weight)) : weight.toLowerCase();
  return 'semibold';
}

// The names `CYLSearchBarItem.item` maps to the package's images.
const NAMED_IMAGES = { camera: 'camera', mic: 'mic', search: 'magnifyingglass', back: 'chevron_backward' };

/**
 * One element after the text of a `CYLSearchBarView`: a model independent of its view (iOS `CYLSearchBarItem`, like
 * `CYLFlatDesignTabBarItem`). Append it with `CYLSearchBarView.addItem`; `<cyl-search-bar>` draws its `items`.
 */
class CYLSearchBarItem {
  /**
   * An item of the given style with a title and an icon path (iOS `-initWithStyle:title:image:`).
   */
  constructor(style, title, image) {
    this.style = style;
    this.title = title;
    this.image = image;
    this.selectedImage = undefined;
    this.animatedImage = undefined;
    /**
     * An animated icon file (Lottie .json, .pag, .riv, .svga, .gif, a key of the app's animation registry), drawn by
     * the item's `cyl-tag-button` (CollectionViewClassifyMenu) and played on each tap; `image` is shown without it.
     */
    this.animationURL = undefined;
    /**
     * A GIF `animationURL`'s still frames (image paths): the first one rests while it does not play, the last one
     * after it played; and its length of one pass in milliseconds (0: the registered GIF's, else 1000). Passed on to
     * `cyl-tag-button`'s `gifFirstFrame`, `gifLastFrame`, `gifDuration` (CYLTabBarController's `cyl-animated-item`).
     */
    this.gifFirstFrame = undefined;
    this.gifLastFrame = undefined;
    this.gifDuration = 0;
    /**
     * Whether the animated icon plays once when it appears (`cyl-tag-button` `autoplay`). Default false: an animated
     * icon rests on its resting frame until it is tapped or played, as iOS `CYLTagButton` (CollectionViewClassifyMenu
     * 27e17e7, the owner's rule).
     */
    this.animationAutoplay = false;
    /** Whether the animated icon is drawn without its own frame, inside the item (`cyl-tag-button` `embedded`). */
    this.animationEmbedded = false;
    /**
     * Whether `animationURL` plays again after each pass; false plays once on each tap. The same on every platform.
     */
    this.animationLoops = false;
    /**
     * The playback speed of `animationURL`; 1 is the file's own. An engine without speed ignores it. The same on every
     * platform.
     */
    this.animationSpeed = 1;
    this.imageSize = 0;
    this.itemAccessibilityLabel = undefined;
    this.itemAccessibilityIdentifier = undefined;
    this.isEnabled = true;
    this.isSelectable = false;
    this.isSelected = false;
    this.tintColor = undefined;
    this.backgroundColor = undefined;
    this.selectedBackgroundColor = undefined;
    /** The corner radius in px: `CYLSearchBarItemCornerRadiusAutomatic` (-1), 0 square, `CYLSearchBarItemCornerRadiusCapsule` (iOS `cornerRadius`). */
    this.cornerRadius = CYLSearchBarItemCornerRadiusAutomatic;
    /** The border color; undefined draws none (iOS `borderColor`). */
    this.borderColor = undefined;
    /** The border width in px; 0 draws none (iOS `borderWidth`). */
    this.borderWidth = 0;
    /** The height of the item's view in px; 0 uses the 36 px minimum (iOS `itemHeight`). */
    this.itemHeight = 0;
    this.contentInsets = -1;
    this.imagePositionAdjustment = { x: 0, y: 0 };
    this.titlePositionAdjustment = { x: 0, y: 0 };
    this.badgeValue = undefined;
    this.badgeColor = undefined;
    this.badgeSize = 0;
    this.badgeContentInsets = 4;
    this.badgePositionAdjustment = { x: 0, y: 0 };
    this.handler = undefined;
    this.searchBarView = undefined;
    this.titleAttributes = new Map();
    this.badgeAttributes = new Map();
  }

  /**
   * Plays `animationURL` again from the start, as a tap does. Does nothing without an animation or a bar. The same on
   * every platform.
   */
  restartAnimation() {
    const view = this.searchBarView;
    if (this.animationURL && view !== undefined && typeof view.itemAnimationHandler === 'function') {
      view.itemAnimationHandler(this);
    }
  }

  /**
   * The item's position in its bar's `items`; -1 when it is in no bar.
   */
  get index() {
    return this.searchBarView === undefined ? -1 : this.searchBarView.items.indexOf(this);
  }

  /**
   * The state the item is drawn in.
   */
  get currentState() {
    if (!this.isEnabled) return CYLSearchBarItemState.disabled;
    return this.isSelected ? CYLSearchBarItemState.selected : CYLSearchBarItemState.normal;
  }

  /**
   * An icon item: the title is what screen readers read (iOS `+iconItemWithImage:title:handler:`).
   */
  static iconItem(image, title, handler) {
    const item = new CYLSearchBarItem(CYLSearchBarItemStyle.icon, title, image);
    item.handler = handler;
    return item;
  }

  /**
   * A text item, a "Search" button (iOS `+textItemWithTitle:handler:`).
   */
  static textItem(title, handler) {
    const item = new CYLSearchBarItem(CYLSearchBarItemStyle.text, title);
    item.handler = handler;
    return item;
  }

  /**
   * A divider between two items (iOS `+dividerItem`).
   */
  static divider() {
    return new CYLSearchBarItem(CYLSearchBarItemStyle.divider);
  }

  /**
   * An item from plain values, as `<cyl-search-bar items>` takes them (iOS `+itemWithDictionary:`): `style` (`icon`,
   * `divider`, `text`), `title`, `image` (a path, or `camera`, `mic`, `search`, `back`), `selectedImage`,
   * `animationURL`, `gifFirstFrame`, `gifLastFrame`, `gifDuration`, `animationAutoplay`, `animationEmbedded`, `animationLoops`, `animationSpeed`, `accessibilityLabel`, `accessibilityIdentifier`, `isEnabled`, `isSelectable`, `isSelected`,
   * `badgeValue`, `badgeColor`.
   */
  static item(values) {
    const dictionary = values || {};
    const style = [CYLSearchBarItemStyle.divider, CYLSearchBarItemStyle.text].includes(dictionary.style)
      ? dictionary.style : CYLSearchBarItemStyle.icon;
    const named = NAMED_IMAGES[dictionary.image];
    const item = new CYLSearchBarItem(style, dictionary.title, named ? $r(`sys.symbol.${named}`) : dictionary.image);
    item.selectedImage = dictionary.selectedImage;
    item.animationURL = dictionary.animationURL || undefined;
    item.gifFirstFrame = dictionary.gifFirstFrame || undefined;
    item.gifLastFrame = dictionary.gifLastFrame || undefined;
    item.gifDuration = Number(dictionary.gifDuration) || 0;
    item.animationAutoplay = dictionary.animationAutoplay === true;
    item.animationEmbedded = dictionary.animationEmbedded === true;
    item.animationLoops = dictionary.animationLoops === true;
    item.animationSpeed = Number(dictionary.animationSpeed) > 0 ? Number(dictionary.animationSpeed) : 1;
    item.badgeColor = dictionary.badgeColor || undefined;
    item.itemAccessibilityLabel = dictionary.accessibilityLabel || dictionary.itemAccessibilityLabel;
    item.itemAccessibilityIdentifier = dictionary.accessibilityIdentifier;
    item.isEnabled = dictionary.isEnabled !== false;
    item.isSelectable = dictionary.isSelectable === true;
    item.isSelected = dictionary.isSelected === true;
    item.badgeValue = dictionary.badgeValue;
    if (style === CYLSearchBarItemStyle.icon) item.imageSize = 22;
    return item;
  }

  /** Whether the item draws a shape of its own (a background or an outline): it keeps its size (iOS item with a background). */
  get drawsShape() {
    return Boolean(this.backgroundColor || this.selectedBackgroundColor || (this.borderColor && this.borderWidth > 0));
  }

  /** Whether the item hugs its content in the trailing group (`cylSearchItemHugsContent`). */
  get hugsContent() {
    return cylSearchItemHugsContent(this.style, this.drawsShape, this.itemHeight);
  }

  /**
   * The plain values of the item, the inverse of `CYLSearchBarItem.item` (what `<cyl-search-bar items>` takes).
   */
  itemDictionary() {
    return {
      style: this.style,
      title: this.title,
      image: this.image,
      selectedImage: this.selectedImage,
      animationURL: this.animationURL,
      gifFirstFrame: this.gifFirstFrame,
      gifLastFrame: this.gifLastFrame,
      gifDuration: this.gifDuration,
      animationAutoplay: this.animationAutoplay,
      animationEmbedded: this.animationEmbedded,
      animationLoops: this.animationLoops,
      animationSpeed: this.animationSpeed,
      accessibilityLabel: this.itemAccessibilityLabel,
      accessibilityIdentifier: this.itemAccessibilityIdentifier,
      isEnabled: this.isEnabled,
      isSelectable: this.isSelectable,
      isSelected: this.isSelected,
      badgeValue: this.badgeValue,
      badgeColor: this.badgeColor,
    };
  }

  /**
   * The properties of the item's `<cyl-tag-button>` (CollectionViewClassifyMenu's `CYLTagButton`, the one icon + title +
   * animated icon component; iOS `CYLSearchBarItemButton.reload()`): a text item shows its title (and its icon before
   * it), an icon item only its icon (its title is what screen readers read), a divider nothing; an animated image
   * replaces the icon. The `tagStyle` has no border, the item's background (transparent by default, through
   * `allowsTransparentBackground`), its tint (`barTint` when it has none) for the title and the icon, the title
   * attributes of the current state, its icon size, insets and position adjustments. The view dims a disabled item
   * itself, so the tag stays enabled.
   */
  tagButtonProperties(barTint, dark) {
    const divider = this.style === CYLSearchBarItemStyle.divider;
    const tint = this.tintColor || barTint || CYLSearchBarColors.itemTint(this.isSelected, dark === true);
    const side = this.imageSize > 0 ? this.imageSize : 20;
    const insets = this.contentInsets >= 0 ? this.contentInsets : (this.style === CYLSearchBarItemStyle.text && this.drawsShape ? 4 : 0);
    const attributes = this.titleTextAttributes(this.currentState) || this.titleTextAttributes(CYLSearchBarItemState.normal) || {};
    const background = (this.isSelected ? (this.selectedBackgroundColor || this.backgroundColor) : this.backgroundColor) || 'transparent';
    const hasBackground = Boolean(this.backgroundColor || this.selectedBackgroundColor);
    const appearance = {
      backgroundColor: background,
      borderWidth: this.borderColor && this.borderWidth > 0 ? this.borderWidth : 0,
      borderColor: this.borderColor && this.borderWidth > 0 ? this.borderColor : undefined,
      textColor: attributes.color || tint,
      iconColor: tint,
      font: { size: attributes.size || 17, weight: cylFontWeightName(attributes.weight) },
      contentInsets: { top: 0, left: insets, bottom: 0, right: insets },
      // Square: 0 is square (item 8b, docs/animated-icon-component.md).
      cornerRadius: cylSearchItemResolvedCornerRadius(this.cornerRadius, hasBackground),
    };
    const offset = (position) => ({ horizontal: Number(position && position.x) || 0, vertical: Number(position && position.y) || 0 });
    return {
      title: this.style === CYLSearchBarItemStyle.text ? (this.title || '') : '',
      image: divider ? '' : (this.animatedImage || this.image || ''),
      selectedImage: divider || this.animatedImage ? '' : (this.selectedImage || ''),
      animationURL: divider ? '' : (this.animationURL || ''),
      gifFirstFrame: divider ? '' : (this.gifFirstFrame || ''),
      gifLastFrame: divider ? '' : (this.gifLastFrame || ''),
      gifDuration: Number(this.gifDuration) || 0,
      autoplay: this.animationAutoplay === true,
      embedded: this.animationEmbedded === true,
      animationLoops: this.animationLoops === true,
      animationSpeed: Number(this.animationSpeed) > 0 ? Number(this.animationSpeed) : 1,
      badgeValue: divider || this.badgeValue === undefined ? null : this.badgeValue,
      badgeColor: this.badgeColor || '',
      accessibilityLabel: this.itemAccessibilityLabel || this.title || '',
      selected: this.isSelected,
      tagStyle: {
        allowsTransparentBackground: true,
        imageSize: { width: side, height: side },
        animationSize: { width: side, height: side },
        imageTitleSpacing: 4,
        itemHeight: cylSearchItemResolvedHeight(this.itemHeight),
        imagePositionAdjustment: offset(this.imagePositionAdjustment),
        titlePositionAdjustment: offset(this.titlePositionAdjustment),
        normal: appearance,
        selected: appearance,
        disabled: appearance,
      },
    };
  }

  /**
   * What screen readers read for the item: its label (or title) and its badge, in one string.
   */
  get accessibilityText() {
    const title = this.itemAccessibilityLabel || this.title || '';
    const badge = this.badgeValue ? `, ${this.badgeValue}` : '';
    return title + badge;
  }

  /**
   * The title attributes for a state (iOS `-setTitleTextAttributes:forState:`).
   */
  setTitleTextAttributes(attributes, state) {
    if (attributes === undefined) this.titleAttributes.delete(state);
    else this.titleAttributes.set(state, attributes);
  }

  /**
   * The title attributes set for a state, or undefined (iOS `-titleTextAttributesForState:`).
   */
  titleTextAttributes(state) {
    return this.titleAttributes.get(state);
  }

  /**
   * The badge text attributes for a state (iOS `-setBadgeTextAttributes:forState:`).
   */
  setBadgeTextAttributes(attributes, state) {
    if (attributes === undefined) this.badgeAttributes.delete(state);
    else this.badgeAttributes.set(state, attributes);
  }

  /**
   * The badge text attributes set for a state, or undefined (iOS `-badgeTextAttributesForState:`).
   */
  badgeTextAttributes(state) {
    return this.badgeAttributes.get(state);
  }
}

/**
 * A configurable search bar (iOS `CYLSearchBarView`): a rounded field with a magnifier, text and clear button,
 * appended items after the text, a button before the field and an optional Cancel button; with `mode` "multiple",
 * several searches side by side (the completed ones as items, the selected one underlined, each with a remove
 * button, and the new-search button at the end). This class is the bar's state and API; `<cyl-search-bar>` draws it.
 * Sizes are in px, durations in seconds, as points and seconds on iOS.
 */
class CYLSearchBarView {
  /**
   * A bar with the default look (iOS `-initWithFrame:`).
   */
  constructor() {
    this.delegate = undefined;
    this.mode = CYLSearchBarMode.single;
    this.text = '';
    this.placeholder = undefined;
    this.font = 17;
    this.textColor = undefined;
    this.placeholderColor = undefined;
    this.cursorColor = undefined;
    this.fieldHeight = 36;
    this.contentInsets = { top: 6, left: 12, bottom: 6, right: 12 };
    this.fieldBackgroundColor = undefined;
    this.fieldCornerRadius = -1;
    this.fieldBorderColor = undefined;
    this.fieldBorderWidth = 0;
    this.fieldShadowOpacity = 0;
    this.fieldBackgroundImage = undefined;
    this.searchIcon = $r('sys.symbol.magnifyingglass');
    this.searchIconTintColor = undefined;
    this.showsCancelButton = false;
    // iOS CYLSearchBar (QMUI): the placeholder centred at rest, the field and Cancel margins per state (a provider
    // `(bar, active) => insets` wins over the plain insets), the Cancel font, the accessory views beside the field.
    this.centersPlaceholder = false;
    this.textFieldMargins = undefined;
    this.textFieldMarginsProvider = undefined;
    this.cancelButtonMargins = undefined;
    this.cancelButtonMarginsProvider = undefined;
    this.cancelButtonFont = undefined;
    // The space around the leading view and the trailing accessory views (`<cyl-search-bar>` takes the properties
    // `leadingAccessoryMargins` and `trailingAccessoryMargins` first).
    this.leadingAccessoryMargins = undefined;
    this.trailingAccessoryMargins = undefined;
    // The existing leading view and trailing accessory views, shown by default (iOS `showsLeadingView`,
    // `showsTrailingAccessoryViews`); showing and hiding them animates the width.
    this.showsLeadingView = true;
    this.showsTrailingAccessoryViews = true;
    this.cancelButtonTitle = $r('app.string.cyl_search_cancel');
    this.cancelButtonEndsEditing = true;
    this.clearsTextOnCancel = false;
    this.clearsTextOnEndEditing = false;
    this.navigationIcon = CYLSearchBarNavigationIcon.none;
    this.navigationImage = undefined;
    this.navigationAccessibilityLabel = $r('app.string.cyl_search_back');
    this.navigationBackgroundColor = undefined;
    this.navigationShadowOpacity = 0;
    this.navigationHandler = undefined;
    this.showsVoiceButton = false;
    this.voiceImage = $r('sys.symbol.mic');
    this.showsSubmitButton = false;
    this.submitImage = $r('sys.symbol.arrow_right');
    this.clearImage = $r('sys.symbol.xmark_circle_fill');
    this.keyboardType = InputType.Normal;
    this.returnKeyType = EnterKeyType.Search;
    this.autocapitalizationType = 'none';
    this.isSecureTextEntry = false;
    this.maximumTextLength = 0;
    this.minimumTextLength = 3;
    this.iconifiedByDefault = false;
    this.expansionAnimation = CYLSearchBarExpansionAnimation.fade;
    this.iconPosition = CYLSearchBarIconPosition.trailing;
    this.animationDuration = 0.3;
    this.items = [];
    /** Whether the bar keeps its built-in search button after the field and the owner's items (iOS `showsSearchButton`). */
    this.showsSearchButton = true;
    /** `icon` (default) or `text` (iOS `searchButtonStyle`). */
    this.searchButtonStyle = CYLSearchBarSearchButtonStyle.icon;
    /** The text of the button; undefined is the localized "Search" (iOS `searchButtonTitle`). */
    this.searchButtonTitle = undefined;
    /** The icon of the `icon` style (an image path); undefined is the core's built-in magnifier (iOS `searchButtonImage`). */
    this.searchButtonImage = undefined;
    /** Called on each tap of the search button, after the text was submitted (iOS `searchButtonHandler`). */
    this.searchButtonHandler = undefined;
    /** The localized "Search", set by `<cyl-search-bar>`. */
    this.defaultSearchButtonTitle = CYLSearchResources.localizedString(undefined, 'search.button');
    this.searchButtonModel = undefined;
    this.searchButtonSignature = '';
    this.itemShapes = undefined;
    this.appearanceValues = undefined;
    this.itemTintColor = undefined;
    this.searchIndicatorColor = undefined;
    this.unselectedSearchAlpha = 0.5;
    this.searchFieldWidth = 160;
    this.newSearchImage = $r('sys.symbol.magnifyingglass');
    this.removeSearchImage = $r('sys.symbol.xmark_circle_fill');
    this.selectedSearchIndex = -1;
    this.expansionFraction = 1;
    this.isEditing = false;
    this.isKeyboardRequested = false;
    /** Whether the bar is an editing bar (`CYLSearchBarView.editingBar`): the trailing button submits (iOS `isEditingBar`). */
    this.isEditingBar = false;
    /** An editing bar's submit, with the trimmed text (iOS `editingSubmitHandler`). */
    this.editingSubmitHandler = undefined;
    this.keyboardHandler = undefined;
    this.style = CYLSearchBarStyle.plain;
    this.iconified = false;
    this.completed = [];
    this.editingNewSearch = false;
  }

  /**
   * The fixed look of the bar. `bordered` draws the field and its items inside one capsule outline.
   */
  get searchBarStyle() {
    return this.style;
  }

  set searchBarStyle(value) {
    this.style = value;
    if (value === CYLSearchBarStyle.bordered) {
      this.fieldBorderColor = $r('sys.color.comp_divider');
      this.fieldBorderWidth = 1;
      this.fieldBackgroundColor = $r('sys.color.comp_background_primary');
      this.fieldCornerRadius = -1;
    }
  }

  /**
   * The look of the input box of a navigation bar, the one every screen uses (iOS `applyNavigationFieldStyle()`): a
   * bordered capsule (corner radius 18) with a soft shadow (opacity 0.06), an opaque white (light) or black (dark) fill,
   * no magnifier, 16 text. Call it before `addItem()`; examples call it and never set these values.
   */
  applyNavigationFieldStyle() {
    const preset = cylNavigationFieldStyle();
    this.searchIcon = undefined;
    this.searchBarStyle = CYLSearchBarStyle.bordered;
    this.fieldCornerRadius = preset.cornerRadius;
    this.fieldShadowOpacity = preset.shadowOpacity;
    this.fieldBackgroundColor = $r('app.color.cyl_search_navigation_field_fill');
    this.font = preset.fontSize;
  }

  /**
   * Applies one of the looks the core ships (`CYLSearchBarPreset`); call it on a new bar before `addItem()`.
   */
  applyPreset(name) {
    if (!name || name === CYLSearchBarPreset.navigationField) {
      this.applyNavigationFieldStyle();
      return;
    }
    const spec = cylSearchBarPresetSpec(name);
    if (spec.bordered) this.searchBarStyle = CYLSearchBarStyle.bordered;
    this.fieldCornerRadius = spec.cornerRadius;
    this.fieldShadowOpacity = spec.shadowOpacity;
    if (spec.usesNavigationFill) this.fieldBackgroundColor = $r('app.color.cyl_search_navigation_field_fill');
    if (!spec.showsSearchIcon) this.searchIcon = undefined;
    this.centersPlaceholder = spec.centersPlaceholder;
    this.font = spec.fontSize;
  }

  /**
   * Whether the bar shows only its search button.
   */
  get isIconified() {
    return this.iconified;
  }

  /**
   * The first selected item (an `isSelectable` item that is on), or undefined.
   */
  get selectedItem() {
    return this.items.find((item) => item.isSelected);
  }

  /**
   * The index of `selectedItem`, or -1.
   */
  get selectedIndex() {
    return this.items.findIndex((item) => item.isSelected);
  }

  /**
   * Appends an item after the others (iOS `-addItem:`).
   */
  addItem(item) {
    this.insertItem(item, this.items.length);
  }

  /**
   * Inserts an item at an index, clamped to `items` (iOS `-insertItem:atIndex:`).
   */
  insertItem(item, index) {
    if (item.searchBarView !== undefined) item.searchBarView.removeItem(item);
    this.items.splice(Math.min(Math.max(0, index), this.items.length), 0, item);
    item.searchBarView = this;
  }

  /**
   * Creates an item and inserts it at an index; a negative or larger index appends it (iOS
   * `-addItemWithStyle:title:image:index:handler:`).
   */
  addItemWithStyle(style, title, image, index = -1, handler = undefined) {
    const item = new CYLSearchBarItem(style, title, image);
    item.handler = handler;
    this.insertItem(item, index < 0 ? this.items.length : index);
    return item;
  }

  /**
   * Removes an item from the bar (iOS `-removeItem:`).
   */
  removeItem(item) {
    const index = this.items.indexOf(item);
    if (index < 0) return;
    this.items.splice(index, 1);
    item.searchBarView = undefined;
    this.itemShapes = undefined;
  }

  /**
   * Removes every item (iOS `-removeAllItems`).
   */
  removeAllItems() {
    this.items.forEach((item) => {
      item.searchBarView = undefined;
    });
    this.items = [];
    this.itemShapes = undefined;
  }

  /**
   * True when an item of the style was appended (iOS `-hasItemOfStyle:`).
   */
  hasItem(style) {
    return this.items.some((item) => item.style === style);
  }

  /**
   * The style of the field (iOS `appearanceStyle`, one `CYLSearchBarAppearance` for this bar and `CYLSearchBar`);
   * undefined by default (the bar keeps its own look). Assigning plain values of `CYLSearchBarAppearance.default()`
   * maps them onto `font`, `textColor`, `placeholderColor`, `placeholder`, `cancelButtonTitle`, the field's background,
   * border and corner radius, the cursor color and the icons; an empty value changes nothing.
   */
  get appearanceStyle() {
    return this.appearanceValues;
  }

  set appearanceStyle(value) {
    this.appearanceValues = value || undefined;
    if (!value) return;
    const a = Object.assign(CYLSearchBarAppearance.default(), value);
    this.font = a.font;
    if (a.textColor) this.textColor = a.textColor;
    if (a.placeholderColor) this.placeholderColor = a.placeholderColor;
    if (a.placeholder) this.placeholder = a.placeholder;
    if (a.cancelTitle) this.cancelButtonTitle = a.cancelTitle;
    if (a.tintColor) this.cursorColor = a.tintColor;
    if (a.searchIconImage) this.searchIcon = a.searchIconImage;
    if (a.clearIconImage) this.clearImage = a.clearIconImage;
    if (a.textFieldBackgroundColor) this.fieldBackgroundColor = a.textFieldBackgroundColor;
    if (a.textFieldBackgroundImage) this.fieldBackgroundImage = a.textFieldBackgroundImage;
    if (a.textFieldBorderColor) {
      this.fieldBorderColor = a.textFieldBorderColor;
      this.fieldBorderWidth = 1;
    }
    this.fieldCornerRadius = a.textFieldCornerRadius;
  }

  /**
   * Applies `CYLSearchBarAppearance.default()` (iOS `applyDefaultAppearance()`, the same method as `CYLSearchBar`).
   */
  applyDefaultAppearance() {
    this.appearanceStyle = CYLSearchBarAppearance.default();
  }

  /**
   * Replaces the items with the ones the dictionaries describe (iOS `setItems(dictionaries:)`, `CYLSearchBarItem.item`).
   * When only `animationLoops` and `animationSpeed` differ from the last call, the items stay and take the two values,
   * so the animation is not reloaded; any other difference rebuilds the items.
   */
  setItems(dictionaries) {
    const list = Array.isArray(dictionaries) ? dictionaries : [];
    const shapes = list.map((dictionary) => {
      const shape = Object.assign({}, dictionary);
      delete shape.animationLoops;
      delete shape.animationSpeed;
      return JSON.stringify(shape);
    });
    if (this.itemShapes && this.itemShapes.length === shapes.length && this.itemShapes.every((shape, i) => shape === shapes[i])
      && this.items.length === shapes.length) {
      this.items.forEach((item, i) => {
        item.animationLoops = list[i].animationLoops === true;
        item.animationSpeed = Number(list[i].animationSpeed) > 0 ? Number(list[i].animationSpeed) : 1;
      });
      return;
    }
    this.removeAllItems();
    this.itemShapes = shapes;
    list.forEach((dictionary) => this.addItem(CYLSearchBarItem.item(dictionary)));
  }

  /**
   * The field's margins in a state (iOS `textFieldMarginsProvider`, else `textFieldMargins`); `active` is true while
   * the bar is searching (editing).
   */
  textFieldMarginsFor(active) {
    if (typeof this.textFieldMarginsProvider === 'function') return this.textFieldMarginsProvider(this, !!active);
    return this.textFieldMargins;
  }

  /**
   * The Cancel button's margins in a state (iOS `cancelButtonMarginsProvider`, else `cancelButtonMargins`).
   */
  cancelButtonMarginsFor(active) {
    if (typeof this.cancelButtonMarginsProvider === 'function') return this.cancelButtonMarginsProvider(this, !!active);
    return this.cancelButtonMargins;
  }

  /**
   * Shows or hides Cancel, animated or not (iOS `setShowsCancelButton(_:animated:)`); the component draws the change
   * through `accessoryHandler`.
   */
  setShowsCancelButton(shows, animated = false) {
    this.showsCancelButton = !!shows;
    if (this.accessoryHandler) this.accessoryHandler('cancel', this.showsCancelButton, !!animated);
  }

  /**
   * Shows or hides the leading view before the field (iOS `setShowsLeadingView(_:animated:)`). The request is a state
   * flag, so fast toggling ends in the last request.
   */
  setShowsLeadingView(shows, animated = false) {
    this.showsLeadingView = !!shows;
    if (this.accessoryHandler) this.accessoryHandler('leading', this.showsLeadingView, !!animated);
  }

  /**
   * Shows or hides the trailing accessory views of the field (iOS `setShowsTrailingAccessoryViews(_:animated:)`).
   */
  setShowsTrailingAccessoryViews(shows, animated = false) {
    this.showsTrailingAccessoryViews = !!shows;
    if (this.accessoryHandler) this.accessoryHandler('trailing', this.showsTrailingAccessoryViews, !!animated);
  }

  /**
   * Deprecated: `setShowsLeadingView` (iOS `CYLSearchBar.setShowsLeadingAccessoryView`).
   */
  setShowsLeadingAccessoryView(shows, animated = false) {
    this.setShowsLeadingView(shows, animated);
  }

  /**
   * Deprecated: `setShowsTrailingAccessoryViews` (iOS `CYLSearchBar.setShowsTrailingAccessoryView`).
   */
  setShowsTrailingAccessoryView(shows, animated = false) {
    this.setShowsTrailingAccessoryViews(shows, animated);
  }

  /**
   * Deprecated: `showsLeadingView`.
   */
  get showsLeadingAccessoryView() {
    return this.showsLeadingView;
  }

  set showsLeadingAccessoryView(value) {
    this.showsLeadingView = !!value;
  }

  /**
   * Deprecated: `showsTrailingAccessoryViews`.
   */
  get showsTrailingAccessoryView() {
    return this.showsTrailingAccessoryViews;
  }

  set showsTrailingAccessoryView(value) {
    this.showsTrailingAccessoryViews = !!value;
  }

  /**
   * Whether the bar draws the search button now (`showsSearchButton`, not an editing bar, not "multiple" mode).
   */
  get hasSearchButton() {
    return cylSearchButtonVisible(this.showsSearchButton, this.isEditingBar, this.mode === CYLSearchBarMode.multiple);
  }

  /**
   * The item the bar draws as its search button (iOS `searchButtonItem`): not in `items`; it follows `searchButtonStyle`,
   * `searchButtonTitle` and `searchButtonImage`, and a change of one of them builds it again. Customize it after setting those.
   */
  get searchButtonItem() {
    const signature = [this.searchButtonStyle, this.searchButtonTitle || '', this.defaultSearchButtonTitle,
      this.searchButtonImage ? 1 : 0].join('|');
    if (!this.searchButtonModel || signature !== this.searchButtonSignature) {
      this.searchButtonSignature = signature;
      this.searchButtonModel = this.makeSearchButtonItem();
    }
    return this.searchButtonModel;
  }

  makeSearchButtonItem() {
    const look = cylSearchButtonLook(this.searchButtonStyle, this.searchButtonTitle, this.defaultSearchButtonTitle,
      Boolean(this.searchButtonImage));
    const item = new CYLSearchBarItem(look.itemStyle, look.title,
      look.usesBuiltInImage ? $r('sys.symbol.magnifyingglass') : this.searchButtonImage);
    item.itemAccessibilityIdentifier = 'CYLSearchBarSearchButton';
    item.cornerRadius = look.cornerRadius;
    item.itemHeight = look.itemHeight;
    item.contentInsets = look.contentInsets;
    if (look.filled) item.imageSize = 16;
    return item;
  }

  /**
   * The search button was tapped: submits the text (`submit()`); an empty text only tells the delegate
   * (`searchBarViewSearchButtonClicked`); then `searchButtonHandler` runs (iOS `searchButtonTapped`).
   */
  searchButtonTapped() {
    if (cylSearchButtonTapAction(this.text) === 1) this.submit();
    else tell(this.delegate, 'searchBarViewSearchButtonClicked', this);
    if (this.searchButtonHandler) this.searchButtonHandler(this);
  }

  /**
   * An item was tapped: a selectable item toggles, then the delegate and the item's handler are told. A disabled item
   * and a divider ignore taps.
   */
  itemTapped(item) {
    if (!item.isEnabled || item.style === CYLSearchBarItemStyle.divider) return;
    if (item.isSelectable) item.isSelected = !item.isSelected;
    tell(this.delegate, 'searchBarViewDidSelectItem', this, item);
    if (item.handler) item.handler(item);
  }

  /**
   * Sets the text and, when `submit` is true, submits it (iOS `-setText:submit:`).
   */
  setText(text, submit = false) {
    this.textChanged(text === null || text === undefined ? '' : String(text));
    if (submit) this.submit();
  }

  /**
   * Submits the text like the search key; false when the text is empty or the delegate refuses it. In the
   * "multiple" mode the search key completes the search being typed instead (`completeSearch()`).
   */
  submit() {
    if (this.isEditingBar) return this.submitEditing();
    if (this.mode === CYLSearchBarMode.multiple) return this.completeSearch();
    if (this.text.length === 0) return false;
    if (tell(this.delegate, 'searchBarViewShouldSubmitText', this, this.text) === false) return false;
    tell(this.delegate, 'searchBarViewSearchButtonClicked', this);
    return true;
  }

  /**
   * An editing bar (iOS `editingBar(placeholder:actionTitle:)`): the search bar's field and look for editing a name (a
   * tag, a title), without the magnifier, with `actionTitle` ("Add", "Done") as its trailing button, which submits the
   * trimmed text through `editingSubmitHandler`, as the confirm key does (after `searchBarViewShouldSubmitText` and
   * `searchBarViewSearchButtonClicked`). The cyl-search-bar component's `editingBar` and `pinsToKeyboard` properties use it.
   */
  static editingBar(placeholder, actionTitle) {
    const bar = new CYLSearchBarView();
    bar.isEditingBar = true;
    bar.showsSearchButton = false;
    bar.searchIcon = null;
    bar.placeholder = placeholder || '';
    bar.showsCancelButton = true;
    bar.cancelButtonTitle = actionTitle || '';
    bar.cancelButtonEndsEditing = false;
    bar.returnKeyType = 'done';
    return bar;
  }

  /**
   * An editing bar's submit (iOS `submitEditing`): empty text submits nothing; the delegate may refuse it; then
   * `editingSubmitHandler` gets the trimmed text. Returns whether it was submitted.
   */
  submitEditing() {
    const trimmed = (this.text || '').trim();
    if (trimmed.length === 0) return false;
    if (tell(this.delegate, 'searchBarViewShouldSubmitText', this, trimmed) === false) return false;
    tell(this.delegate, 'searchBarViewSearchButtonClicked', this);
    if (this.editingSubmitHandler) this.editingSubmitHandler(this, trimmed);
    return true;
  }

  /**
   * Focuses the field, which raises the keyboard (the component reads `isKeyboardRequested`).
   */
  showKeyboard() {
    this.isKeyboardRequested = true;
    if (this.keyboardHandler) this.keyboardHandler(true);
  }

  /**
   * Ends editing, which lowers the keyboard.
   */
  hideKeyboard() {
    this.isKeyboardRequested = false;
    if (this.keyboardHandler) this.keyboardHandler(false);
  }

  /**
   * Focuses the field and returns true (iOS `-becomeFirstResponder`).
   */
  becomeFirstResponder() {
    this.showKeyboard();
    return true;
  }

  /**
   * Ends editing and returns true (iOS `-resignFirstResponder`).
   */
  resignFirstResponder() {
    this.hideKeyboard();
    return true;
  }

  /**
   * Opens or closes the field, animated over `animationDuration` when `animated` is true (iOS
   * `-setIconified:animated:`). Opening also starts editing.
   */
  setIconified(iconified, animated = true) {
    if (this.iconified === iconified) return;
    if (iconified) this.hideKeyboard();
    const apply = () => {
      this.iconified = iconified;
      this.expansionFraction = iconified ? 0 : 1;
    };
    if (animated && this.animationDuration > 0) animateTo({ duration: this.animationDuration * 1000, curve: Curve.EaseInOut }, apply);
    else apply();
    if (!iconified) this.showKeyboard();
    tell(this.delegate, 'searchBarViewDidChangeIconified', this, iconified);
  }

  /**
   * The state to keep across a restart: the text, whether the bar is iconified and the searches (iOS
   * `-encodeRestorableStateWithCoder:`).
   */
  encodeRestorableState() {
    return { text: this.text, iconified: this.iconified, searches: this.completed.slice(), selectedSearchIndex: this.selectedSearchIndex };
  }

  /**
   * Restores what `encodeRestorableState` returned (iOS `-decodeRestorableStateWithCoder:`).
   */
  decodeRestorableState(state) {
    const values = state || {};
    if (Array.isArray(values.searches)) {
      this.completed = values.searches.filter((value) => typeof value === 'string');
      this.selectedSearchIndex = typeof values.selectedSearchIndex === 'number' && values.selectedSearchIndex < this.completed.length
        ? values.selectedSearchIndex : this.completed.length - 1;
    }
    this.textChanged(values.text || '');
    this.setIconified(values.iconified === true, false);
  }

  /**
   * The bar's height: the field and the insets above and below it, or one row of searches (iOS
   * `intrinsicContentSize`).
   */
  get intrinsicContentSize() {
    if (this.mode === CYLSearchBarMode.multiple) return 48;
    return this.fieldHeight + Number(this.contentInsets.top || 0) + Number(this.contentInsets.bottom || 0);
  }

  /**
   * The searches of the "multiple" mode: the completed ones, then the one being typed (iOS `searches`).
   */
  get searches() {
    return this.editingNewSearch ? this.completed.concat([this.text]) : this.completed.slice();
  }

  /**
   * The completed searches of the "multiple" mode, as the component lists them.
   */
  get completedSearches() {
    return this.completed.slice();
  }

  /**
   * True while a new search is being typed in the "multiple" mode (iOS `isEditingNewSearch`).
   */
  get isEditingNewSearch() {
    return this.editingNewSearch;
  }

  /**
   * Starts a new search and shows the keyboard (iOS `beginNewSearch()`). Does nothing while a search is being typed.
   */
  beginNewSearch() {
    if (this.editingNewSearch) return;
    this.text = '';
    this.editingNewSearch = true;
    this.selectedSearchIndex = this.completed.length;
    this.showKeyboard();
  }

  /**
   * Completes the search being typed: it becomes the selected search, or is dropped when shorter than
   * `minimumTextLength` (iOS `completeSearch()`). True when a search was added.
   */
  completeSearch() {
    if (!this.editingNewSearch) return false;
    const value = this.text.trim();
    this.editingNewSearch = false;
    this.text = '';
    this.hideKeyboard();
    if (value.length < this.minimumTextLength) {
      this.selectedSearchIndex = this.completed.length - 1;
      return false;
    }
    this.completed.push(value);
    this.selectedSearchIndex = this.completed.length - 1;
    tell(this.delegate, 'searchBarViewDidCompleteSearch', this, value, this.selectedSearchIndex);
    return true;
  }

  /**
   * Adds a completed search without typing it and selects it (iOS `addSearch(_:)`).
   */
  addSearch(text) {
    const value = String(text || '').trim();
    if (value.length === 0) return;
    if (this.editingNewSearch) {
      this.editingNewSearch = false;
      this.text = '';
    }
    this.completed.push(value);
    this.selectedSearchIndex = this.completed.length - 1;
    tell(this.delegate, 'searchBarViewDidCompleteSearch', this, value, this.selectedSearchIndex);
  }

  /**
   * Selects a search, like a tap on it (iOS `selectSearch(at:)`).
   */
  selectSearch(index) {
    if (index < 0 || index >= this.completed.length) return;
    if (this.editingNewSearch) this.completeSearch();
    this.selectedSearchIndex = Math.min(index, this.completed.length - 1);
    tell(this.delegate, 'searchBarViewDidSelectSearch', this, this.completed[this.selectedSearchIndex], this.selectedSearchIndex);
  }

  /**
   * Removes a search, like a tap on its remove button (iOS `removeSearch(at:)`).
   */
  removeSearch(index) {
    if (index < 0 || index >= this.completed.length) return;
    this.completed.splice(index, 1);
    if (this.completed.length === 0) {
      this.selectedSearchIndex = -1;
    } else if (this.selectedSearchIndex >= this.completed.length || this.selectedSearchIndex > index) {
      this.selectedSearchIndex = Math.max(0, this.selectedSearchIndex - 1);
    }
    tell(this.delegate, 'searchBarViewDidRemoveSearchAtIndex', this, index);
  }

  /**
   * The component reports a new text; the delegate is told when it differs (`searchBarViewTextDidChange`, or
   * `searchBarViewTextDidChangeAtIndex` with the index of the search being typed in the "multiple" mode).
   */
  textChanged(text) {
    let next = String(text === null || text === undefined ? '' : text);
    if (this.maximumTextLength > 0 && next.length > this.maximumTextLength) next = next.substring(0, this.maximumTextLength);
    if (next === this.text) return;
    this.text = next;
    if (this.mode === CYLSearchBarMode.multiple) {
      tell(this.delegate, 'searchBarViewTextDidChangeAtIndex', this, next, this.completed.length);
    } else {
      tell(this.delegate, 'searchBarViewTextDidChange', this, next);
    }
  }

  /**
   * The component reports that editing started or ended.
   */
  editingChanged(editing) {
    if (this.isEditing === editing) return;
    this.isEditing = editing;
    if (editing) {
      tell(this.delegate, 'searchBarViewDidBeginEditing', this);
      return;
    }
    if (this.clearsTextOnEndEditing) this.textChanged('');
    tell(this.delegate, 'searchBarViewDidEndEditing', this);
  }

  /**
   * Asks the delegate whether editing may start; false reports `searchBarViewDidTapWhileNotEditable` instead.
   */
  shouldBeginEditing() {
    if (tell(this.delegate, 'searchBarViewShouldBeginEditing', this) === false) {
      tell(this.delegate, 'searchBarViewDidTapWhileNotEditable', this);
      return false;
    }
    return true;
  }

  /**
   * Cancel was tapped.
   */
  cancelTapped() {
    // An editing bar's trailing button is its action, not a cancel (iOS `cancelTapped`).
    if (this.isEditingBar) {
      this.submitEditing();
      return;
    }
    if (this.clearsTextOnCancel) this.textChanged('');
    if (this.cancelButtonEndsEditing) this.hideKeyboard();
    tell(this.delegate, 'searchBarViewCancelButtonClicked', this);
  }

  /**
   * The button before the field was tapped.
   */
  navigationTapped() {
    tell(this.delegate, 'searchBarViewNavigationButtonClicked', this);
    if (this.navigationHandler) this.navigationHandler(this);
  }

  /**
   * The microphone was tapped.
   */
  voiceTapped() {
    tell(this.delegate, 'searchBarViewVoiceButtonClicked', this);
  }

  /**
   * The image of the button before the field, or undefined when it is hidden.
   */
  get navigationSymbol() {
    if (this.navigationImage !== undefined) return this.navigationImage;
    if (this.navigationIcon === CYLSearchBarNavigationIcon.arrow) return $r('sys.symbol.chevron_backward');
    if (this.navigationIcon === CYLSearchBarNavigationIcon.search) return $r('sys.symbol.magnifyingglass');
    return undefined;
  }
}

/**
 * The default colors (iOS `.label`, `.secondaryLabel`, accent), light and dark. The bar's own CSS follows
 * `prefers-color-scheme`; these serve the values CSS cannot reach (an input's `placeholder-style`, the tag buttons'
 * properties), which the component recomputes on `wx.onThemeChange`. A host tint overrides every one.
 */
const CYLSearchBarColors = {
  /** The placeholder and divider color: secondary label, 60% alpha. */
  secondaryLabel(dark) { return dark ? 'rgba(235, 235, 245, 0.6)' : 'rgba(60, 60, 67, 0.6)'; },
  /** The label color: black in light, white in dark. */
  label(dark) { return dark ? '#FFFFFF' : '#000000'; },
  /** The accent: the selected item's color. */
  accent(dark) { return dark ? '#0A84FF' : '#007AFF'; },
  /** An item's icon and title color with no host tint: the accent while selected, else the label color. */
  itemTint(selected, dark) { return selected ? CYLSearchBarColors.accent(dark) : CYLSearchBarColors.label(dark); },
};

module.exports = {
  CYLSearchBarColors,
  CYLSearchBarMode,
  CYLSearchBarItemStyle,
  CYLSearchBarSearchButtonStyle,
  CYLSearchBarItemCornerRadiusAutomatic,
  CYLSearchBarItemCornerRadiusCapsule,
  cylSearchItemResolvedCornerRadius,
  cylSearchItemResolvedHeight,
  cylSearchButtonVisible,
  cylSearchButtonHasDivider,
  cylSearchItemHugsContent,
  cylSearchTrailingGroupLayout,
  CYL_SEARCH_TRAILING_SPACING,
  CYL_SEARCH_TOUCH_WIDTH,
  cylSearchButtonLook,
  cylSearchButtonTapAction,
  cylSearchButtonTrailingInset,
  cylSearchButtonColors,
  CYLSearchBarStyle,
  CYLSearchBarNavigationIcon,
  CYLSearchBarIconPosition,
  CYLSearchBarExpansionAnimation,
  CYLSearchBarItemState,
  CYLSearchBarViewDelegate,
  CYLSearchBarAppearance,
  cylInsetsCSS,
  cylNavigationFieldStyle,
  CYLSearchBarPreset,
  cylSearchBarPresetSpec,
  cylNavigationFieldFill,
  cylSearchShouldFocusOnAppear,
  cylSearchIsOnSecondLevelOrDeeperPage,
  CYLSearchBarItem,
  CYLSearchBarView,
};

// The search bar module of cyl-search-miniprogram (iOS `CYLSearchBarView.swift`): `CYLSearchBarView` (one search, or
// several searches side by side with `mode` "multiple", which was `CYLMultiSearchView`), `CYLSearchBarItem` (the
// appended items, which `<cyl-search-bar>` draws itself; was `CYLSearchBarItemView`), the delegate and the enums.
// The `<cyl-search-bar>` component draws a `CYLSearchBarView`. Merged from CYLSearchBarView.js, CYLSearchBarItem.js,
// CYLMultiSearchView.js and the component helper cyl_search_bar_item.js.
'use strict';

const { $r, animateTo, Curve, InputType, EnterKeyType } = require('./CYLSearchResources');

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
    this.imageSize = 0;
    this.itemAccessibilityLabel = undefined;
    this.itemAccessibilityIdentifier = undefined;
    this.isEnabled = true;
    this.isSelectable = false;
    this.isSelected = false;
    this.tintColor = undefined;
    this.backgroundColor = undefined;
    this.selectedBackgroundColor = undefined;
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
   * `animationURL`, `gifFirstFrame`, `gifLastFrame`, `gifDuration`, `animationAutoplay`, `animationEmbedded`, `accessibilityLabel`, `accessibilityIdentifier`, `isEnabled`, `isSelectable`, `isSelected`,
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
  tagButtonProperties(barTint) {
    const divider = this.style === CYLSearchBarItemStyle.divider;
    const tint = this.tintColor || barTint || '#000000';
    const side = this.imageSize > 0 ? this.imageSize : 20;
    const insets = this.contentInsets >= 0 ? this.contentInsets : (this.style === CYLSearchBarItemStyle.text ? 4 : 0);
    const attributes = this.titleTextAttributes(this.currentState) || this.titleTextAttributes(CYLSearchBarItemState.normal) || {};
    const background = (this.isSelected ? (this.selectedBackgroundColor || this.backgroundColor) : this.backgroundColor) || 'transparent';
    const hasBackground = Boolean(this.backgroundColor || this.selectedBackgroundColor);
    const appearance = {
      backgroundColor: background,
      borderWidth: 0,
      textColor: attributes.color || tint,
      iconColor: tint,
      font: { size: attributes.size || 17, weight: cylFontWeightName(attributes.weight) },
      contentInsets: { top: 0, left: insets, bottom: 0, right: insets },
      cornerRadius: hasBackground ? 10 : 0.001,
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
      badgeValue: divider || this.badgeValue === undefined ? null : this.badgeValue,
      badgeColor: this.badgeColor || '',
      accessibilityLabel: this.itemAccessibilityLabel || this.title || '',
      selected: this.isSelected,
      tagStyle: {
        allowsTransparentBackground: true,
        imageSize: { width: side, height: side },
        animationSize: { width: side, height: side },
        imageTitleSpacing: 4,
        itemHeight: 36,
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
  }

  /**
   * Removes every item (iOS `-removeAllItems`).
   */
  removeAllItems() {
    this.items.forEach((item) => {
      item.searchBarView = undefined;
    });
    this.items = [];
  }

  /**
   * True when an item of the style was appended (iOS `-hasItemOfStyle:`).
   */
  hasItem(style) {
    return this.items.some((item) => item.style === style);
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
    if (this.mode === CYLSearchBarMode.multiple) return this.completeSearch();
    if (this.text.length === 0) return false;
    if (tell(this.delegate, 'searchBarViewShouldSubmitText', this, this.text) === false) return false;
    tell(this.delegate, 'searchBarViewSearchButtonClicked', this);
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

module.exports = {
  CYLSearchBarMode,
  CYLSearchBarItemStyle,
  CYLSearchBarStyle,
  CYLSearchBarNavigationIcon,
  CYLSearchBarIconPosition,
  CYLSearchBarExpansionAnimation,
  CYLSearchBarItemState,
  CYLSearchBarViewDelegate,
  CYLSearchBarItem,
  CYLSearchBarView,
};

/**
 * How an item appended to a search bar looks (iOS `CYLSearchBarItemStyle`).
 */
const CYLSearchBarItemStyle = Object.freeze({ icon: 'icon', divider: 'divider', text: 'text' });

/**
 * The fixed look of the whole bar (iOS `CYLSearchBarStyle`).
 */
const CYLSearchBarStyle = Object.freeze({ plain: 'plain', bordered: 'bordered' });

/**
 * One element after the text of a search bar: a plain model (iOS `CYLSearchBarItem`, like
 * `CYLFlatDesignTabBarItem`). The `cyl-search-bar` component draws a list of them; the field stays and only items are
 * appended.
 */
class CYLSearchBarItem {
  /**
   * An item of a style with a title and an icon (iOS `-initWithStyle:title:image:`); `image` is an image path.
   */
  constructor(style, title, image) {
    this.style = style;
    this.title = title;
    this.image = image;
    this.selectedImage = undefined;
    this.itemAccessibilityLabel = undefined;
    this.itemAccessibilityIdentifier = undefined;
    this.isEnabled = true;
    this.isSelectable = false;
    this.isSelected = false;
    this.tintColor = undefined;
    this.backgroundColor = undefined;
    this.selectedBackgroundColor = undefined;
    this.badgeValue = undefined;
    this.badgeColor = undefined;
    this.handler = undefined;
  }

  /** An icon item; the title is what screen readers read (iOS `+iconItemWithImage:title:handler:`). */
  static iconItem(image, title, handler) {
    const item = new CYLSearchBarItem(CYLSearchBarItemStyle.icon, title, image);
    item.handler = handler;
    return item;
  }

  /** A text item, a "Search" button (iOS `+textItemWithTitle:handler:`). */
  static textItem(title, handler) {
    const item = new CYLSearchBarItem(CYLSearchBarItemStyle.text, title);
    item.handler = handler;
    return item;
  }

  /** A divider between two items (iOS `+dividerItem`). */
  static divider() {
    return new CYLSearchBarItem(CYLSearchBarItemStyle.divider);
  }

  /**
   * An item from plain values, as the cross-platform wrappers send them (iOS `+itemWithDictionary:`): `style`,
   * `title`, `image`, `accessibilityIdentifier`, `isEnabled`, `isSelectable`, `isSelected`, `badgeValue`.
   */
  static item(values) {
    const style = [CYLSearchBarItemStyle.divider, CYLSearchBarItemStyle.text].includes(values.style)
      ? values.style
      : CYLSearchBarItemStyle.icon;
    const item = new CYLSearchBarItem(style, values.title, values.image);
    item.itemAccessibilityIdentifier = values.accessibilityIdentifier;
    item.isEnabled = values.isEnabled !== false;
    item.isSelectable = values.isSelectable === true;
    item.isSelected = values.isSelected === true;
    item.badgeValue = values.badgeValue;
    return item;
  }
}

/**
 * The items of a bar (iOS `CYLSearchBarView.items` and its calls): append, insert, remove, select.
 */
class CYLSearchBarItems {
  constructor() {
    this.items = [];
    this.onSelect = undefined;
  }

  /** Appends an item after the others (iOS `-addItem:`). */
  addItem(item) {
    this.insertItem(item, this.items.length);
  }

  /** Inserts an item at an index, clamped (iOS `-insertItem:atIndex:`). */
  insertItem(item, index) {
    this.removeItem(item);
    this.items.splice(Math.min(Math.max(0, index), this.items.length), 0, item);
  }

  /** Removes an item (iOS `-removeItem:`). */
  removeItem(item) {
    const index = this.items.indexOf(item);
    if (index >= 0) this.items.splice(index, 1);
  }

  /** Removes every item (iOS `-removeAllItems`). */
  removeAllItems() {
    this.items = [];
  }

  /** The index of an item, or -1 (iOS `index`). */
  indexOf(item) {
    return this.items.indexOf(item);
  }

  /** True when an item of the style exists (iOS `-hasItemOfStyle:`). */
  hasItem(style) {
    return this.items.some((item) => item.style === style);
  }

  /** The first selected item, or undefined (iOS `selectedItem`). */
  get selectedItem() {
    return this.items.find((item) => item.isSelected);
  }

  /** The index of `selectedItem`, or -1 (iOS `selectedIndex`). */
  get selectedIndex() {
    return this.items.findIndex((item) => item.isSelected);
  }

  /**
   * An item was tapped: a selectable item toggles, then `onSelect` (the delegate) and the item's handler are called.
   * A disabled item and a divider ignore taps.
   */
  itemTapped(item) {
    if (!item.isEnabled || item.style === CYLSearchBarItemStyle.divider) return;
    if (item.isSelectable) item.isSelected = !item.isSelected;
    if (this.onSelect) this.onSelect(item, this.items.indexOf(item));
    if (item.handler) item.handler(item);
  }
}

module.exports = { CYLSearchBarItemStyle, CYLSearchBarStyle, CYLSearchBarItem, CYLSearchBarItems };

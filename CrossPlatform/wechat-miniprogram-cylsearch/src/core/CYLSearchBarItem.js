"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.CYLSearchBarItem = exports.CYLSearchBarItemOwner = exports.CYLSearchBarItemTextAttributes = exports.CYLSearchBarItemState = exports.CYLSearchBarStyle = exports.CYLSearchBarItemStyle = void 0;
const { $r } = require("./CYLSearchResourceReference");
/**
 * How an item appended to a search bar looks (iOS `CYLSearchBarItemStyle`).
 */
var CYLSearchBarItemStyle;
(function (CYLSearchBarItemStyle) {
    /**
     * An icon button with a 36 vp touch area (a camera, a filter).
     */
    CYLSearchBarItemStyle[CYLSearchBarItemStyle["icon"] = 0] = "icon";
    /**
     * A thin vertical line between two items; it takes no taps and screen readers skip it.
     */
    CYLSearchBarItemStyle[CYLSearchBarItemStyle["divider"] = 1] = "divider";
    /**
     * A text button (a "Search" button); an image, when set, comes before the title.
     */
    CYLSearchBarItemStyle[CYLSearchBarItemStyle["text"] = 2] = "text";
})(CYLSearchBarItemStyle || (exports.CYLSearchBarItemStyle = CYLSearchBarItemStyle = {}));
/**
 * The fixed look of the whole bar (iOS `CYLSearchBarStyle`): the field stays, the items are appended after its text.
 */
var CYLSearchBarStyle;
(function (CYLSearchBarStyle) {
    /**
     * The field as configured by its own properties (the default; nothing is changed).
     */
    CYLSearchBarStyle[CYLSearchBarStyle["plain"] = 0] = "plain";
    /**
     * A capsule with a 1 vp outline: the field and its items inside one outline.
     */
    CYLSearchBarStyle[CYLSearchBarStyle["bordered"] = 1] = "bordered";
})(CYLSearchBarStyle || (exports.CYLSearchBarStyle = CYLSearchBarStyle = {}));
/**
 * The item states for text attributes (iOS `UIControlState`).
 */
var CYLSearchBarItemState;
(function (CYLSearchBarItemState) {
    /**
     * Enabled and not selected.
     */
    CYLSearchBarItemState[CYLSearchBarItemState["normal"] = 0] = "normal";
    /**
     * Selected (`isSelected`).
     */
    CYLSearchBarItemState[CYLSearchBarItemState["selected"] = 1] = "selected";
    /**
     * Disabled (`isEnabled` false).
     */
    CYLSearchBarItemState[CYLSearchBarItemState["disabled"] = 2] = "disabled";
})(CYLSearchBarItemState || (exports.CYLSearchBarItemState = CYLSearchBarItemState = {}));
/**
 * Title or badge text attributes (iOS `NSAttributedString` attributes).
 */
class CYLSearchBarItemTextAttributes {
}
exports.CYLSearchBarItemTextAttributes = CYLSearchBarItemTextAttributes;
/**
 * What an item needs from its bar: the item list (for `index`) and the shared tint.
 */
class CYLSearchBarItemOwner {
    constructor() {
        /**
         * The appended items, in order.
         */
        this.items = undefined;
        /**
         * The icon and title color of every item without its own `tintColor`.
         */
        this.itemTintColor = undefined;
    }
}
exports.CYLSearchBarItemOwner = CYLSearchBarItemOwner;
/**
 * One element after the text of a `CYLSearchBarView`: a model independent of its view (iOS `CYLSearchBarItem`, like
 * `CYLFlatDesignTabBarItem`). Append it with `CYLSearchBarView.addItem`; `CYLSearchBarItemView` draws it.
 */
class CYLSearchBarItem {
    /**
     * An item of the given style with a title and an icon (iOS `-initWithStyle:title:image:`).
     */
    constructor(style, title, image) {
        /**
         * The text of a text item, and the screen reader label of an icon item without `itemAccessibilityLabel`.
         */
        this.title = undefined;
        /**
         * The icon: a system symbol (`$r('sys.symbol.camera')`), tinted with `tintColor`.
         */
        this.image = undefined;
        /**
         * The icon while `isSelected` is true; undefined uses `image`.
         */
        this.selectedImage = undefined;
        /**
         * An animated icon (a GIF or animated WebP as an image source), drawn instead of `image` when set.
         */
        this.animatedImage = undefined;
        /**
         * The icon side in vp; 0 uses 20.
         */
        this.imageSize = 0;
        /**
         * What screen readers read; undefined reads `title`.
         */
        this.itemAccessibilityLabel = undefined;
        /**
         * A test identifier for the item view (its component id).
         */
        this.itemAccessibilityIdentifier = undefined;
        /**
         * False dims the item and ignores taps. True by default.
         */
        this.isEnabled = true;
        /**
         * True makes each tap toggle `isSelected` (a filter that stays on). False by default.
         */
        this.isSelectable = false;
        /**
         * The selected state (drawn with `selectedImage`, `selectedBackgroundColor` and the selected title attributes).
         */
        this.isSelected = false;
        /**
         * The icon and title color; undefined uses the bar's `itemTintColor`.
         */
        this.tintColor = undefined;
        /**
         * The item background; undefined is transparent.
         */
        this.backgroundColor = undefined;
        /**
         * The item background while selected; undefined uses `backgroundColor`.
         */
        this.selectedBackgroundColor = undefined;
        /**
         * Horizontal padding around the icon and title, in vp; negative uses the style's default (4 for text, 0 else).
         */
        this.contentInsets = -1;
        /**
         * Moves the icon, in vp, without changing the item's size.
         */
        this.imagePositionAdjustment = { x: 0, y: 0 };
        /**
         * Moves the title, in vp, without changing the item's size.
         */
        this.titlePositionAdjustment = { x: 0, y: 0 };
        /**
         * The badge text; undefined hides the badge, an empty string draws a dot.
         */
        this.badgeValue = undefined;
        /**
         * The badge background; undefined is red.
         */
        this.badgeColor = undefined;
        /**
         * The smallest badge side in vp; 0 uses 16 (a dot is 8).
         */
        this.badgeSize = 0;
        /**
         * Horizontal padding around the badge text, in vp.
         */
        this.badgeContentInsets = 4;
        /**
         * Moves the badge from the icon's top end corner, in vp.
         */
        this.badgePositionAdjustment = { x: 0, y: 0 };
        /**
         * Called on each tap, after `CYLSearchBarViewDelegate.searchBarViewDidSelectItem`.
         */
        this.handler = undefined;
        /**
         * The bar the item was appended to; undefined before `addItem` and after `removeItem`.
         */
        this.searchBarView = undefined;
        this.attributesVersion = 0;
        this.titleAttributes = new Map();
        this.badgeAttributes = new Map();
        this.style = style;
        this.title = title;
        this.image = image;
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
        if (!this.isEnabled) {
            return CYLSearchBarItemState.disabled;
        }
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
     * An item from plain values, as the cross-platform wrappers send them (iOS `+itemWithDictionary:`): `style`
     * (`icon`, `divider`, `text`), `title`, `image` (`camera`, `mic`, `search`, `back`), `accessibilityIdentifier`,
     * `isEnabled`, `isSelectable`, `isSelected`, `badgeValue`.
     */
    static item(dictionary) {
        var _a, _b, _c;
        const styleName = dictionary['style'];
        let style = CYLSearchBarItemStyle.icon;
        if (styleName === 'divider') {
            style = CYLSearchBarItemStyle.divider;
        }
        else if (styleName === 'text') {
            style = CYLSearchBarItemStyle.text;
        }
        const item = new CYLSearchBarItem(style, dictionary['title'], CYLSearchBarItem.namedImage(dictionary['image']));
        item.itemAccessibilityIdentifier = dictionary['accessibilityIdentifier'];
        item.isEnabled = (_a = dictionary['isEnabled']) !== null && _a !== void 0 ? _a : true;
        item.isSelectable = (_b = dictionary['isSelectable']) !== null && _b !== void 0 ? _b : false;
        item.isSelected = (_c = dictionary['isSelected']) !== null && _c !== void 0 ? _c : false;
        item.badgeValue = dictionary['badgeValue'];
        if (style === CYLSearchBarItemStyle.icon) {
            item.imageSize = 22;
        }
        return item;
    }
    static namedImage(name) {
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
    setTitleTextAttributes(attributes, state) {
        if (attributes === undefined) {
            this.titleAttributes.delete(state);
        }
        else {
            this.titleAttributes.set(state, attributes);
        }
        this.attributesVersion += 1;
    }
    /**
     * The title attributes set for a state, or undefined (iOS `-titleTextAttributesForState:`).
     */
    titleTextAttributes(state) {
        return this.attributesVersion >= 0 ? this.titleAttributes.get(state) : undefined;
    }
    /**
     * The badge text attributes for a state (iOS `-setBadgeTextAttributes:forState:`).
     */
    setBadgeTextAttributes(attributes, state) {
        if (attributes === undefined) {
            this.badgeAttributes.delete(state);
        }
        else {
            this.badgeAttributes.set(state, attributes);
        }
        this.attributesVersion += 1;
    }
    /**
     * The badge text attributes set for a state, or undefined (iOS `-badgeTextAttributesForState:`).
     */
    badgeTextAttributes(state) {
        return this.attributesVersion >= 0 ? this.badgeAttributes.get(state) : undefined;
    }
}
exports.CYLSearchBarItem = CYLSearchBarItem;

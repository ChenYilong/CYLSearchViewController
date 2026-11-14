"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.CYLSearchBarView = exports.CYLSearchBarViewDelegate = exports.CYLSearchBarExpansionAnimation = exports.CYLSearchBarIconPosition = exports.CYLSearchBarNavigationIcon = void 0;
const { InputType, EnterKeyType, TextOverflow } = require("./CYLSearchPlatform");
const { $r } = require("./CYLSearchResourceReference");
const { animateTo, Curve, TextInputController, focusControl } = require("./CYLSearchPlatform");
const CYLSearchBarItem_1 = require("./CYLSearchBarItem");
/**
 * The icon of the button before the field (iOS `CYLSearchBarNavigationIcon`).
 */
var CYLSearchBarNavigationIcon;
(function (CYLSearchBarNavigationIcon) {
    /**
     * No button.
     */
    CYLSearchBarNavigationIcon[CYLSearchBarNavigationIcon["none"] = 0] = "none";
    /**
     * A back arrow.
     */
    CYLSearchBarNavigationIcon[CYLSearchBarNavigationIcon["arrow"] = 1] = "arrow";
    /**
     * A magnifier.
     */
    CYLSearchBarNavigationIcon[CYLSearchBarNavigationIcon["search"] = 2] = "search";
})(CYLSearchBarNavigationIcon || (exports.CYLSearchBarNavigationIcon = CYLSearchBarNavigationIcon = {}));
/**
 * Where the search button sits while the bar is iconified (iOS `CYLSearchBarIconPosition`).
 */
var CYLSearchBarIconPosition;
(function (CYLSearchBarIconPosition) {
    /**
     * At the end.
     */
    CYLSearchBarIconPosition[CYLSearchBarIconPosition["trailing"] = 0] = "trailing";
    /**
     * In the middle.
     */
    CYLSearchBarIconPosition[CYLSearchBarIconPosition["center"] = 1] = "center";
    /**
     * At the start.
     */
    CYLSearchBarIconPosition[CYLSearchBarIconPosition["leading"] = 2] = "leading";
})(CYLSearchBarIconPosition || (exports.CYLSearchBarIconPosition = CYLSearchBarIconPosition = {}));
/**
 * How the field opens from the search button (iOS `CYLSearchBarExpansionAnimation`).
 */
var CYLSearchBarExpansionAnimation;
(function (CYLSearchBarExpansionAnimation) {
    /**
     * The field fades in.
     */
    CYLSearchBarExpansionAnimation[CYLSearchBarExpansionAnimation["fade"] = 0] = "fade";
    /**
     * The field grows from the button, as one animated fraction from an icon circle to the full bar (the technique
     * of Applib-HarmonyOS/FlexibleSearchBar's `startOpen` / `startClose`).
     */
    CYLSearchBarExpansionAnimation[CYLSearchBarExpansionAnimation["circularReveal"] = 1] = "circularReveal";
})(CYLSearchBarExpansionAnimation || (exports.CYLSearchBarExpansionAnimation = CYLSearchBarExpansionAnimation = {}));
/**
 * The events of a `CYLSearchBarView` (iOS `CYLSearchBarViewDelegate`); every method is optional.
 */
class CYLSearchBarViewDelegate {
    constructor() {
        /**
         * Asks whether editing may start; false reports `searchBarViewDidTapWhileNotEditable` instead.
         */
        this.searchBarViewShouldBeginEditing = undefined;
        /**
         * The field was tapped while it may not be edited.
         */
        this.searchBarViewDidTapWhileNotEditable = undefined;
        /**
         * Editing started.
         */
        this.searchBarViewDidBeginEditing = undefined;
        /**
         * Editing ended.
         */
        this.searchBarViewDidEndEditing = undefined;
        /**
         * The text changed (iOS `-searchBarView:textDidChange:`).
         */
        this.searchBarViewTextDidChange = undefined;
        /**
         * The search key or the submit button.
         */
        this.searchBarViewSearchButtonClicked = undefined;
        /**
         * Cancel was tapped.
         */
        this.searchBarViewCancelButtonClicked = undefined;
        /**
         * The button before the field was tapped.
         */
        this.searchBarViewNavigationButtonClicked = undefined;
        /**
         * The microphone was tapped.
         */
        this.searchBarViewVoiceButtonClicked = undefined;
        /**
         * Asks whether the text may be submitted (iOS `-searchBarView:shouldSubmitText:`).
         */
        this.searchBarViewShouldSubmitText = undefined;
        /**
         * The field opened or closed (iOS `-searchBarView:didChangeIconified:`).
         */
        this.searchBarViewDidChangeIconified = undefined;
        /**
         * An appended item was tapped (iOS `-searchBarView:didSelectItem:`).
         */
        this.searchBarViewDidSelectItem = undefined;
    }
}
exports.CYLSearchBarViewDelegate = CYLSearchBarViewDelegate;
/**
 * A configurable search bar (iOS `CYLSearchBarView`): a rounded field with a magnifier, text and clear button,
 * appended items after the text, a button before the field and an optional Cancel button. This class is the bar's
 * state and API; `CYLSearchBarComponent` draws it. Sizes are in vp, durations in seconds, as on iOS.
 */
class CYLSearchBarView {
    /**
     * A bar with the default look (iOS `-initWithFrame:`).
     */
    constructor() {
        /**
         * Receives the events.
         */
        this.delegate = undefined;
        /**
         * The text input's controller (caret and editing).
         */
        this.textField = new TextInputController();
        /**
         * The text of the field.
         */
        this.text = '';
        /**
         * The placeholder.
         */
        this.placeholder = undefined;
        /**
         * The font size in fp. 17 by default.
         */
        this.font = 17;
        /**
         * The text color; undefined uses the primary text color.
         */
        this.textColor = undefined;
        /**
         * The placeholder color; undefined uses the tertiary text color.
         */
        this.placeholderColor = undefined;
        /**
         * The caret color; undefined uses the system accent.
         */
        this.cursorColor = undefined;
        /**
         * The field's height. 36 by default.
         */
        this.fieldHeight = 36;
        /**
         * The space around the field inside the bar.
         */
        this.contentInsets = { top: 6, left: 12, bottom: 6, right: 12 };
        /**
         * The field's background; undefined uses a light fill.
         */
        this.fieldBackgroundColor = undefined;
        /**
         * The field's corner radius; negative makes a capsule. -1 by default.
         */
        this.fieldCornerRadius = -1;
        /**
         * The field's border color; undefined draws no border.
         */
        this.fieldBorderColor = undefined;
        /**
         * The field's border width, used with `fieldBorderColor`. 0 by default.
         */
        this.fieldBorderWidth = 0;
        /**
         * The field's shadow, 0 to 1. 0 by default.
         */
        this.fieldShadowOpacity = 0;
        /**
         * An image drawn behind the field's content, clipped to its corners.
         */
        this.fieldBackgroundImage = undefined;
        /**
         * The magnifier at the start of the field; undefined hides it.
         */
        this.searchIcon = $r('sys.symbol.magnifyingglass');
        /**
         * The magnifier's color; undefined uses the secondary text color.
         */
        this.searchIconTintColor = undefined;
        /**
         * Shows the Cancel button after the field. False by default.
         */
        this.showsCancelButton = false;
        /**
         * The Cancel button's title.
         */
        this.cancelButtonTitle = 'Cancel';
        /**
         * Cancel also ends editing. True by default.
         */
        this.cancelButtonEndsEditing = true;
        /**
         * Cancel also clears the text. False by default.
         */
        this.clearsTextOnCancel = false;
        /**
         * Ending editing clears the text. False by default.
         */
        this.clearsTextOnEndEditing = false;
        /**
         * The icon of the button before the field; `none` hides it unless `navigationImage` is set.
         */
        this.navigationIcon = CYLSearchBarNavigationIcon.none;
        /**
         * A symbol of yours for the button before the field; it wins over `navigationIcon`.
         */
        this.navigationImage = undefined;
        /**
         * What screen readers read for the button before the field.
         */
        this.navigationAccessibilityLabel = 'Back';
        /**
         * A round background behind the button before the field; undefined draws none.
         */
        this.navigationBackgroundColor = undefined;
        /**
         * The shadow of the button before the field, 0 to 1.
         */
        this.navigationShadowOpacity = 0;
        /**
         * Called when the button before the field is tapped, after the delegate.
         */
        this.navigationHandler = undefined;
        /**
         * Shows a microphone inside the field while the text is empty. False by default.
         */
        this.showsVoiceButton = false;
        /**
         * The microphone's symbol.
         */
        this.voiceImage = $r('sys.symbol.mic');
        /**
         * Shows a submit button inside the field while there is text. False by default.
         */
        this.showsSubmitButton = false;
        /**
         * The submit button's symbol.
         */
        this.submitImage = $r('sys.symbol.arrow_right');
        /**
         * The clear button's symbol.
         */
        this.clearImage = $r('sys.symbol.xmark_circle_fill');
        /**
         * The keyboard (iOS `keyboardType`).
         */
        this.keyboardType = InputType.Normal;
        /**
         * The return key (iOS `returnKeyType`). Search by default.
         */
        this.returnKeyType = EnterKeyType.Search;
        /**
         * Hides the typed text (iOS `isSecureTextEntry`).
         */
        this.isSecureTextEntry = false;
        /**
         * The longest text allowed; 0 is no limit.
         */
        this.maximumTextLength = 0;
        /**
         * The bar shows only its search button until it is tapped. False by default.
         */
        this.iconifiedByDefault = false;
        /**
         * How the field opens from the search button.
         */
        this.expansionAnimation = CYLSearchBarExpansionAnimation.fade;
        /**
         * Where the search button sits while iconified.
         */
        this.iconPosition = CYLSearchBarIconPosition.trailing;
        /**
         * The duration of the open and close animation, in seconds. 0.3 by default.
         */
        this.animationDuration = 0.3;
        /**
         * The appended items, in order, after the text (like the FlatDesign tab bar's `items`). The field stays; only
         * items are appended.
         */
        this.items = [];
        /**
         * The icon and title color of every item without its own `tintColor`; undefined uses the primary text color.
         */
        this.itemTintColor = undefined;
        this.style = CYLSearchBarItem_1.CYLSearchBarStyle.plain;
        this.iconified = false;
        /**
         * 0 while iconified, 1 while open; animated between the two (FlexibleSearchBar's single fraction).
         */
        this.expansionFraction = 1;
        /**
         * Whether the field is being edited.
         */
        this.isEditing = false;
        CYLSearchBarView.nextIdentifier += 1;
        this.textFieldId = `CYLSearchBarTextField${CYLSearchBarView.nextIdentifier}`;
    }
    /**
     * The fixed look of the bar. `bordered` draws the field and its items inside one capsule outline.
     */
    get searchBarStyle() {
        return this.style;
    }
    set searchBarStyle(value) {
        this.style = value;
        if (value === CYLSearchBarItem_1.CYLSearchBarStyle.bordered) {
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
     * The views of `items` are drawn by `CYLSearchBarItemView`; this is the list they draw, in order.
     */
    get itemViews() {
        return this.items;
    }
    /**
     * The first selected item (a `isSelectable` item that is on), or undefined.
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
        if (item.searchBarView !== undefined) {
            const owner = item.searchBarView;
            owner.removeItem(item);
        }
        const position = Math.min(Math.max(0, index), this.items.length);
        this.items.splice(position, 0, item);
        item.searchBarView = this;
    }
    /**
     * Creates an item and inserts it at an index; a negative or larger index appends it (iOS
     * `-addItemWithStyle:title:image:index:handler:`).
     */
    addItemWithStyle(style, title, image, index = -1, handler) {
        const item = new CYLSearchBarItem_1.CYLSearchBarItem(style, title, image);
        item.handler = handler;
        this.insertItem(item, index < 0 ? this.items.length : index);
        return item;
    }
    /**
     * Removes an item from the bar (iOS `-removeItem:`).
     */
    removeItem(item) {
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
     * An item was tapped: a selectable item toggles, then the delegate and the item's handler are told.
     */
    itemTapped(item) {
        var _a, _b, _c;
        if (!item.isEnabled) {
            return;
        }
        if (item.isSelectable) {
            item.isSelected = !item.isSelected;
        }
        (_b = (_a = this.delegate) === null || _a === void 0 ? void 0 : _a.searchBarViewDidSelectItem) === null || _b === void 0 ? void 0 : _b.call(_a, this, item);
        (_c = item.handler) === null || _c === void 0 ? void 0 : _c.call(item, item);
    }
    /**
     * Sets the text and, when `submit` is true, submits it (iOS `-setText:submit:`).
     */
    setText(text, submit) {
        this.textChanged(text !== null && text !== void 0 ? text : '');
        if (submit) {
            this.submit();
        }
    }
    /**
     * Submits the text like the search key; false when the text is empty or the delegate refuses it.
     */
    submit() {
        var _a, _b, _c, _d, _e;
        if (this.text.length === 0) {
            return false;
        }
        const allowed = (_c = (_b = (_a = this.delegate) === null || _a === void 0 ? void 0 : _a.searchBarViewShouldSubmitText) === null || _b === void 0 ? void 0 : _b.call(_a, this, this.text)) !== null && _c !== void 0 ? _c : true;
        if (!allowed) {
            return false;
        }
        (_e = (_d = this.delegate) === null || _d === void 0 ? void 0 : _d.searchBarViewSearchButtonClicked) === null || _e === void 0 ? void 0 : _e.call(_d, this);
        return true;
    }
    /**
     * Focuses the field, which raises the keyboard.
     */
    showKeyboard() {
        focusControl.requestFocus(this.textFieldId);
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
     * Ends editing, which lowers the keyboard.
     */
    hideKeyboard() {
        this.textField.stopEditing();
    }
    /**
     * Opens or closes the field, animated over `animationDuration` when `animated` is true (iOS
     * `-setIconified:animated:`). Opening also starts editing.
     */
    setIconified(iconified, animated) {
        var _a, _b;
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
            animateTo({ duration: this.animationDuration * 1000, curve: Curve.EaseInOut }, apply);
        }
        else {
            apply();
        }
        if (!iconified) {
            this.showKeyboard();
        }
        (_b = (_a = this.delegate) === null || _a === void 0 ? void 0 : _a.searchBarViewDidChangeIconified) === null || _b === void 0 ? void 0 : _b.call(_a, this, iconified);
    }
    /**
     * The state to keep across a restart: the text and whether the bar is iconified (iOS
     * `-encodeRestorableStateWithCoder:`).
     */
    encodeRestorableState() {
        const state = { 'text': this.text, 'iconified': this.iconified };
        return state;
    }
    /**
     * Restores what `encodeRestorableState` returned (iOS `-decodeRestorableStateWithCoder:`).
     */
    decodeRestorableState(state) {
        var _a, _b;
        this.textChanged((_a = state['text']) !== null && _a !== void 0 ? _a : '');
        this.setIconified((_b = state['iconified']) !== null && _b !== void 0 ? _b : false, false);
    }
    /**
     * The bar's height: the field and the insets above and below it (iOS `intrinsicContentSize`).
     */
    get intrinsicContentSize() {
        var _a, _b;
        return this.fieldHeight + Number((_a = this.contentInsets.top) !== null && _a !== void 0 ? _a : 0) + Number((_b = this.contentInsets.bottom) !== null && _b !== void 0 ? _b : 0);
    }
    /**
     * The component reports a new text; the delegate is told when it differs.
     */
    textChanged(text) {
        var _a, _b;
        let next = text;
        if (this.maximumTextLength > 0 && next.length > this.maximumTextLength) {
            next = next.substring(0, this.maximumTextLength);
        }
        if (next === this.text) {
            return;
        }
        this.text = next;
        (_b = (_a = this.delegate) === null || _a === void 0 ? void 0 : _a.searchBarViewTextDidChange) === null || _b === void 0 ? void 0 : _b.call(_a, this, next);
    }
    /**
     * The component reports that editing started or ended.
     */
    editingChanged(editing) {
        var _a, _b, _c, _d;
        if (this.isEditing === editing) {
            return;
        }
        this.isEditing = editing;
        if (editing) {
            (_b = (_a = this.delegate) === null || _a === void 0 ? void 0 : _a.searchBarViewDidBeginEditing) === null || _b === void 0 ? void 0 : _b.call(_a, this);
        }
        else {
            if (this.clearsTextOnEndEditing) {
                this.textChanged('');
            }
            (_d = (_c = this.delegate) === null || _c === void 0 ? void 0 : _c.searchBarViewDidEndEditing) === null || _d === void 0 ? void 0 : _d.call(_c, this);
        }
    }
    /**
     * Cancel was tapped.
     */
    cancelTapped() {
        var _a, _b;
        if (this.clearsTextOnCancel) {
            this.textChanged('');
        }
        if (this.cancelButtonEndsEditing) {
            this.hideKeyboard();
        }
        (_b = (_a = this.delegate) === null || _a === void 0 ? void 0 : _a.searchBarViewCancelButtonClicked) === null || _b === void 0 ? void 0 : _b.call(_a, this);
    }
    /**
     * The button before the field was tapped.
     */
    navigationTapped() {
        var _a, _b, _c;
        (_b = (_a = this.delegate) === null || _a === void 0 ? void 0 : _a.searchBarViewNavigationButtonClicked) === null || _b === void 0 ? void 0 : _b.call(_a, this);
        (_c = this.navigationHandler) === null || _c === void 0 ? void 0 : _c.call(this, this);
    }
    /**
     * The microphone was tapped.
     */
    voiceTapped() {
        var _a, _b;
        (_b = (_a = this.delegate) === null || _a === void 0 ? void 0 : _a.searchBarViewVoiceButtonClicked) === null || _b === void 0 ? void 0 : _b.call(_a, this);
    }
    /**
     * The symbol of the button before the field, or undefined when it is hidden.
     */
    get navigationSymbol() {
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
exports.CYLSearchBarView = CYLSearchBarView;
CYLSearchBarView.nextIdentifier = 0;

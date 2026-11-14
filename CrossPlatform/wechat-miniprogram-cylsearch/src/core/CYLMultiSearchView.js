"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.CYLMultiSearchView = exports.CYLMultiSearchViewDelegate = void 0;
const { InputType, EnterKeyType, TextOverflow } = require("./CYLSearchPlatform");
const { $r } = require("./CYLSearchResourceReference");
const { focusControl } = require("./CYLSearchPlatform");
/**
 * Events of a `CYLMultiSearchView` (iOS `CYLMultiSearchViewDelegate`); every method is optional.
 */
class CYLMultiSearchViewDelegate {
    constructor() {
        /**
         * The text of the search being typed changed (iOS `-multiSearchView:textDidChange:atIndex:`).
         */
        this.multiSearchViewTextDidChange = undefined;
        /**
         * A search was completed and became an item (iOS `-multiSearchView:didCompleteSearch:atIndex:`).
         */
        this.multiSearchViewDidCompleteSearch = undefined;
        /**
         * An item was removed (iOS `-multiSearchView:didRemoveItemAtIndex:`).
         */
        this.multiSearchViewDidRemoveItemAtIndex = undefined;
        /**
         * An item was selected by a tap (iOS `-multiSearchView:didSelectItem:atIndex:`).
         */
        this.multiSearchViewDidSelectItem = undefined;
    }
}
exports.CYLMultiSearchViewDelegate = CYLMultiSearchViewDelegate;
/**
 * Several searches side by side (iOS `CYLMultiSearchView`): the search button starts a new search; a completed
 * search becomes an item; a tap selects an item and its remove button removes it. This class is the state and API;
 * `CYLMultiSearchComponent` draws it.
 */
class CYLMultiSearchView {
    /**
     * An empty multi search view (iOS `-initWithFrame:`).
     */
    constructor() {
        /**
         * Receives the events.
         */
        this.delegate = undefined;
        /**
         * The selected item, or -1 when there is none.
         */
        this.selectedIndex = -1;
        /**
         * The placeholder of a new search. "Search" by default.
         */
        this.placeholder = $r('app.string.cyl_search_placeholder');
        /**
         * The font size of the items, in fp. 17 by default.
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
         * The longest search a person can type; 0 means no limit.
         */
        this.maximumTextLength = 0;
        /**
         * A search shorter than this is dropped when it is completed. 3 by default.
         */
        this.minimumTextLength = 3;
        /**
         * The return key. Search by default.
         */
        this.returnKeyType = EnterKeyType.Search;
        /**
         * The keyboard.
         */
        this.keyboardType = InputType.Normal;
        /**
         * The color of the indicator under the selected item and of the buttons; undefined uses the system accent.
         */
        this.indicatorColor = undefined;
        /**
         * The opacity of items that are not selected. 0.5 by default.
         */
        this.unselectedItemAlpha = 0.5;
        /**
         * The width of the field for a new search, in vp. 160 by default.
         */
        this.searchFieldWidth = 160;
        /**
         * The length of the animations, in seconds. 0.25 by default.
         */
        this.animationDuration = 0.25;
        /**
         * The search button's symbol. A magnifier by default.
         */
        this.searchImage = $r('sys.symbol.magnifyingglass');
        /**
         * The remove button's symbol.
         */
        this.removeImage = $r('sys.symbol.xmark_circle_fill');
        /**
         * The text of the search being typed.
         */
        this.typedText = '';
        this.completed = [];
        this.typing = false;
        CYLMultiSearchView.nextIdentifier += 1;
        this.textFieldId = `CYLMultiSearchTextField${CYLMultiSearchView.nextIdentifier}`;
    }
    /**
     * True while a new search is being typed (iOS `inSearchMode`).
     */
    get isInSearchMode() {
        return this.typing;
    }
    /**
     * The texts of the items, completed searches first, then the one being typed.
     */
    get searchTexts() {
        return this.typing ? this.completed.concat([this.typedText]) : this.completed.slice();
    }
    /**
     * The completed searches, as the component lists them.
     */
    get completedSearchTexts() {
        return this.completed;
    }
    /**
     * The view's height: one row of items (iOS `intrinsicContentSize`).
     */
    get intrinsicContentSize() {
        return 48;
    }
    /**
     * Starts a new search and shows the keyboard. Does nothing while a search is being typed.
     */
    search() {
        if (this.typing) {
            return;
        }
        this.typedText = '';
        this.typing = true;
        this.selectedIndex = this.completed.length;
        setTimeout(() => {
            focusControl.requestFocus(this.textFieldId);
        }, 50);
    }
    /**
     * Completes the search being typed: it becomes the selected item, or is dropped when shorter than
     * `minimumTextLength`.
     */
    completeSearch() {
        var _a, _b;
        if (!this.typing) {
            return;
        }
        const text = this.typedText.trim();
        this.typing = false;
        this.typedText = '';
        if (text.length < this.minimumTextLength) {
            this.selectedIndex = this.completed.length > 0 ? this.completed.length - 1 : -1;
            return;
        }
        this.completed.push(text);
        this.selectedIndex = this.completed.length - 1;
        (_b = (_a = this.delegate) === null || _a === void 0 ? void 0 : _a.multiSearchViewDidCompleteSearch) === null || _b === void 0 ? void 0 : _b.call(_a, this, text, this.selectedIndex);
    }
    /**
     * Adds a completed search without typing it and selects it.
     */
    addSearchText(text) {
        var _a, _b;
        const value = text.trim();
        if (value.length === 0) {
            return;
        }
        if (this.typing) {
            this.typing = false;
            this.typedText = '';
        }
        this.completed.push(value);
        this.selectedIndex = this.completed.length - 1;
        (_b = (_a = this.delegate) === null || _a === void 0 ? void 0 : _a.multiSearchViewDidCompleteSearch) === null || _b === void 0 ? void 0 : _b.call(_a, this, value, this.selectedIndex);
    }
    /**
     * Selects an item, like a tap on it (iOS `-selectItemAtIndex:`).
     */
    selectItemAtIndex(index) {
        var _a, _b;
        if (index < 0 || index >= this.completed.length) {
            return;
        }
        if (this.typing) {
            this.completeSearch();
        }
        this.selectedIndex = Math.min(index, this.completed.length - 1);
        (_b = (_a = this.delegate) === null || _a === void 0 ? void 0 : _a.multiSearchViewDidSelectItem) === null || _b === void 0 ? void 0 : _b.call(_a, this, this.completed[this.selectedIndex], this.selectedIndex);
    }
    /**
     * Removes an item, like a tap on its remove button (iOS `-removeItemAtIndex:`).
     */
    removeItemAtIndex(index) {
        var _a, _b;
        if (index < 0 || index >= this.completed.length) {
            return;
        }
        this.completed.splice(index, 1);
        if (this.completed.length === 0) {
            this.selectedIndex = -1;
        }
        else if (this.selectedIndex >= this.completed.length || this.selectedIndex > index) {
            this.selectedIndex = Math.max(0, this.selectedIndex - 1);
        }
        (_b = (_a = this.delegate) === null || _a === void 0 ? void 0 : _a.multiSearchViewDidRemoveItemAtIndex) === null || _b === void 0 ? void 0 : _b.call(_a, this, index);
    }
    /**
     * The component reports the text being typed.
     */
    textChanged(text) {
        var _a, _b;
        let next = text;
        if (this.maximumTextLength > 0 && next.length > this.maximumTextLength) {
            next = next.substring(0, this.maximumTextLength);
        }
        if (next === this.typedText) {
            return;
        }
        this.typedText = next;
        (_b = (_a = this.delegate) === null || _a === void 0 ? void 0 : _a.multiSearchViewTextDidChange) === null || _b === void 0 ? void 0 : _b.call(_a, this, next, this.completed.length);
    }
}
exports.CYLMultiSearchView = CYLMultiSearchView;
CYLMultiSearchView.nextIdentifier = 0;

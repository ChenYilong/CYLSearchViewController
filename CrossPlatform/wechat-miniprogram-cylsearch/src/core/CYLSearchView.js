"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.CYLSearchView = exports.CYLSearchViewDelegate = exports.CYLMenuFoldControl = exports.CYLMenuFoldControlContent = exports.CYLMenuFoldControlPosition = exports.CYLSearchSuggestionStyle = void 0;
const { InputType, EnterKeyType, TextOverflow } = require("./CYLSearchPlatform");
const { $r } = require("./CYLSearchResourceReference");
const { animateTo, Curve } = require("./CYLSearchPlatform");
const CYLSearchBarView_1 = require("./CYLSearchBarView");
const CYLSearchPlaceholderView_1 = require("./CYLSearchPlaceholderView");
const CYLSearchSuggestionCache_1 = require("./CYLSearchSuggestionCache");
/**
 * How the suggestions are shown under the search bar (iOS `CYLSearchSuggestionStyle`).
 */
var CYLSearchSuggestionStyle;
(function (CYLSearchSuggestionStyle) {
    /**
     * One suggestion per row with its icon.
     */
    CYLSearchSuggestionStyle[CYLSearchSuggestionStyle["list"] = 0] = "list";
    /**
     * Tags that wrap like words.
     */
    CYLSearchSuggestionStyle[CYLSearchSuggestionStyle["tags"] = 1] = "tags";
})(CYLSearchSuggestionStyle || (exports.CYLSearchSuggestionStyle = CYLSearchSuggestionStyle = {}));
/**
 * Where the fold control of the tag suggestions sits (CollectionViewClassifyMenu's `CYLMenuFoldControlPosition`).
 */
var CYLMenuFoldControlPosition;
(function (CYLMenuFoldControlPosition) {
    /**
     * After the last visible tag.
     */
    CYLMenuFoldControlPosition[CYLMenuFoldControlPosition["inline"] = 0] = "inline";
    /**
     * On a row of its own under the tags.
     */
    CYLMenuFoldControlPosition[CYLMenuFoldControlPosition["bottom"] = 1] = "bottom";
})(CYLMenuFoldControlPosition || (exports.CYLMenuFoldControlPosition = CYLMenuFoldControlPosition = {}));
/**
 * What the fold control shows (CollectionViewClassifyMenu's `CYLMenuFoldControlContent`).
 */
var CYLMenuFoldControlContent;
(function (CYLMenuFoldControlContent) {
    /**
     * A chevron.
     */
    CYLMenuFoldControlContent[CYLMenuFoldControlContent["icon"] = 0] = "icon";
    /**
     * "More" / "Less".
     */
    CYLMenuFoldControlContent[CYLMenuFoldControlContent["title"] = 1] = "title";
})(CYLMenuFoldControlContent || (exports.CYLMenuFoldControlContent = CYLMenuFoldControlContent = {}));
/**
 * The fold control of the tag suggestions (CollectionViewClassifyMenu's `CYLMenuFoldControl`).
 */
class CYLMenuFoldControl {
    /**
     * A fold control (iOS `+foldControlWithPosition:content:`).
     */
    constructor(position = CYLMenuFoldControlPosition.inline, content = CYLMenuFoldControlContent.icon) {
        this.position = position;
        this.content = content;
    }
}
exports.CYLMenuFoldControl = CYLMenuFoldControl;
/**
 * Events of a `CYLSearchView` (iOS `CYLSearchViewDelegate`); every method is optional.
 */
class CYLSearchViewDelegate {
    constructor() {
        /**
         * The search view finished opening.
         */
        this.searchViewDidShow = undefined;
        /**
         * The search view finished closing.
         */
        this.searchViewDidClose = undefined;
        /**
         * The query changed (iOS `-searchView:textDidChange:`).
         */
        this.searchViewTextDidChange = undefined;
        /**
         * The query was submitted (iOS `-searchView:didSubmitText:`). Return true when you handled it and the search view
         * stays open; false lets `closesOnSubmit` close it.
         */
        this.searchViewDidSubmitText = undefined;
        /**
         * The field started or stopped editing (iOS `-searchView:didChangeFocus:`).
         */
        this.searchViewDidChangeFocus = undefined;
        /**
         * A suggestion was tapped (iOS `-searchView:didSelectSuggestion:atIndex:`).
         */
        this.searchViewDidSelectSuggestion = undefined;
        /**
         * The voice button was tapped.
         */
        this.searchViewVoiceButtonClicked = undefined;
        /**
         * The navigation button (the back arrow by default) was tapped. Without this method it closes the search view.
         */
        this.searchViewNavigationButtonClicked = undefined;
    }
}
exports.CYLSearchViewDelegate = CYLSearchViewDelegate;
/**
 * A search page that opens over its host (iOS `CYLSearchView`): a `CYLSearchBarView` at the top, a divider, then the
 * suggestions as a list or as tags, the cached queries first, and placeholders for an empty cache and for no
 * results. This class is the page's state and API; `CYLSearchComponent` draws it.
 *
 * Core behavior rule 1: focusing the field alone changes nothing below the search bar; that area changes only when
 * the text or the data changes.
 */
class CYLSearchView {
    /**
     * A closed search view with the default look (iOS `-initWithFrame:`).
     */
    constructor() {
        /**
         * Receives the events of the search view.
         */
        this.delegate = undefined;
        /**
         * The search bar at the top. Style it directly (placeholder, colors, icons, keyboard, voice button, items).
         */
        this.searchBarView = new CYLSearchBarView_1.CYLSearchBarView();
        /**
         * How the suggestions are shown: a list (the default) or tags.
         */
        this.suggestionStyle = CYLSearchSuggestionStyle.list;
        /**
         * The fold control of the tag suggestions. An inline chevron by default.
         */
        this.suggestionsFoldControl = new CYLMenuFoldControl();
        /**
         * The rows of tag suggestions shown while folded. 2 by default; 0 shows every row.
         */
        this.suggestionsFoldedRowCount = 2;
        /**
         * Shows a placeholder under the search bar while a non-empty query matches no suggestion. False by default.
         */
        this.showsEmptyResultsPlaceholder = false;
        /**
         * The kind of that placeholder. `noResults` by default.
         */
        this.emptyResultsScenario = CYLSearchPlaceholderView_1.CYLSearchPlaceholderKind.noResults;
        /**
         * The color of the line under the search bar; undefined uses the system divider color.
         */
        this.dividerColor = undefined;
        /**
         * A view of yours shown under the divider, behind the suggestions: a results list, a history.
         */
        this.contentView = undefined;
        /**
         * The color behind the page while it is open; undefined draws none.
         */
        this.scrimColor = undefined;
        /**
         * The page background; undefined uses the system background.
         */
        this.backgroundColor = undefined;
        /**
         * Decides whether a suggestion matches the query. Undefined uses a case-insensitive "contains" test.
         */
        this.suggestionFilter = undefined;
        /**
         * The suggestions that match the current query: cached queries first, then `suggestions`, without repeats.
         */
        this.filteredSuggestions = [];
        /**
         * The icon before each suggestion; undefined shows none. A magnifier by default.
         */
        this.suggestionImage = $r('sys.symbol.magnifyingglass');
        /**
         * The tint of `suggestionImage`; undefined uses the secondary text color.
         */
        this.suggestionImageTintColor = undefined;
        /**
         * The background of the suggestion rows; undefined keeps the page background.
         */
        this.suggestionBackgroundColor = undefined;
        /**
         * The color of the suggestion text; undefined uses the primary text color.
         */
        this.suggestionTextColor = undefined;
        /**
         * How a long suggestion is cut. `TextOverflow.None` (whole text, wrapped) by default.
         */
        this.suggestionLineBreakMode = TextOverflow.None;
        /**
         * Submits a suggestion as soon as it is tapped. False by default: the field shows it and waits.
         */
        this.submitsOnSuggestionSelection = false;
        /**
         * Draws each suggestion row yourself, from the suggestion and its index (iOS `suggestionCellConfiguration`).
         */
        this.suggestionCellConfiguration = undefined;
        /**
         * The cache in use: the built-in store of `suggestionCachePolicy`, or a store of yours (set it after the policy).
         */
        this.suggestionCache = undefined;
        /**
         * The title of the header above the cached queries ("Recent searches").
         */
        this.suggestionCacheTitle = $r('app.string.cyl_search_recent');
        /**
         * Shows a placeholder while the query is empty and there is nothing to list. True by default.
         */
        this.showsEmptySuggestionsPlaceholder = true;
        /**
         * The kind of that placeholder. `empty` by default.
         */
        this.emptySuggestionsScenario = CYLSearchPlaceholderView_1.CYLSearchPlaceholderKind.empty;
        /**
         * Focuses the search field when the search opens, which raises the keyboard. True by default. False opens the
         * search with the suggestion list only; the field is focused when the user taps it.
         */
        this.focusesSearchFieldOnShow = true;
        /**
         * The length of the open and close animations, in seconds. 0.25 by default.
         */
        this.animationDuration = 0.25;
        /**
         * Closes the search view after a submitted query that the delegate did not handle. True by default.
         */
        this.closesOnSubmit = true;
        /**
         * Whether the list currently shows cached queries (it then has the "Recent searches" header).
         */
        this.showsCachedQueries = false;
        /**
         * Whether the tag suggestions are folded.
         */
        this.suggestionsFolded = true;
        this.open = false;
        this.suggestionsShown = true;
        this.allSuggestions = [];
        this.showsAllForEmptyQuery = false;
        this.cachePolicy = CYLSearchSuggestionCache_1.CYLSearchSuggestionCachePolicy.database;
        this.cacheName = 'CYLSearchView';
        this.context = undefined;
        this.emptyResults = undefined;
        this.emptySuggestions = undefined;
        this.searchBarView.navigationIcon = CYLSearchBarView_1.CYLSearchBarNavigationIcon.arrow;
        const barDelegate = {
            searchBarViewTextDidChange: (_, text) => {
                var _a, _b;
                this.refilter();
                (_b = (_a = this.delegate) === null || _a === void 0 ? void 0 : _a.searchViewTextDidChange) === null || _b === void 0 ? void 0 : _b.call(_a, this, text);
            },
            searchBarViewSearchButtonClicked: (_) => {
                this.submitted();
            },
            searchBarViewDidBeginEditing: (_) => {
                var _a, _b;
                (_b = (_a = this.delegate) === null || _a === void 0 ? void 0 : _a.searchViewDidChangeFocus) === null || _b === void 0 ? void 0 : _b.call(_a, this, true);
            },
            searchBarViewDidEndEditing: (_) => {
                var _a, _b;
                (_b = (_a = this.delegate) === null || _a === void 0 ? void 0 : _a.searchViewDidChangeFocus) === null || _b === void 0 ? void 0 : _b.call(_a, this, false);
            },
            searchBarViewVoiceButtonClicked: (_) => {
                var _a, _b;
                (_b = (_a = this.delegate) === null || _a === void 0 ? void 0 : _a.searchViewVoiceButtonClicked) === null || _b === void 0 ? void 0 : _b.call(_a, this);
            },
            searchBarViewNavigationButtonClicked: (_) => {
                var _a;
                if (((_a = this.delegate) === null || _a === void 0 ? void 0 : _a.searchViewNavigationButtonClicked) !== undefined) {
                    this.delegate.searchViewNavigationButtonClicked(this);
                }
                else {
                    this.closeSearch(true);
                }
            }
        };
        this.searchBarView.delegate = barDelegate;
    }
    /**
     * The suggestions to filter as the text changes.
     */
    get suggestions() {
        return this.allSuggestions;
    }
    set suggestions(value) {
        this.allSuggestions = value;
        this.refilter();
    }
    /**
     * Lists every suggestion while the query is empty. False by default.
     */
    get showsSuggestionsForEmptyQuery() {
        return this.showsAllForEmptyQuery;
    }
    set showsSuggestionsForEmptyQuery(value) {
        this.showsAllForEmptyQuery = value;
        this.refilter();
    }
    /**
     * Where submitted queries are cached for the suggestion list. `database` by default.
     */
    get suggestionCachePolicy() {
        return this.cachePolicy;
    }
    set suggestionCachePolicy(value) {
        this.cachePolicy = value;
        this.rebuildCache();
    }
    /**
     * Separates the caches of different search screens. "CYLSearchView" by default.
     */
    get suggestionCacheName() {
        return this.cacheName;
    }
    set suggestionCacheName(value) {
        this.cacheName = value;
        this.rebuildCache();
    }
    /**
     * The placeholder shown for empty results, created the first time it is needed; undefined before.
     */
    get emptyResultsView() {
        return this.emptyResults;
    }
    /**
     * The placeholder shown for an empty cache, created the first time it is needed; undefined before.
     */
    get emptySuggestionsView() {
        return this.emptySuggestions;
    }
    /**
     * True while the search view is open (iOS `searchOpen`).
     */
    get isSearchOpen() {
        return this.open;
    }
    /**
     * The current query.
     */
    get query() {
        return this.searchBarView.text;
    }
    set query(value) {
        this.setQuery(value, false);
    }
    /**
     * True while the suggestions are listed (`showSuggestions` / `dismissSuggestions`).
     */
    get suggestionsVisible() {
        return this.suggestionsShown;
    }
    /**
     * True while the query is not empty, nothing matches it and the empty results placeholder is on.
     */
    get showsEmptyResults() {
        return this.showsEmptyResultsPlaceholder && this.query.length > 0 && this.filteredSuggestions.length === 0;
    }
    /**
     * True while the query is empty, there is nothing to list and the empty suggestions placeholder is on.
     */
    get showsEmptySuggestions() {
        return this.showsEmptySuggestionsPlaceholder && this.query.length === 0 &&
            this.filteredSuggestions.length === 0 && this.suggestionCache !== undefined;
    }
    /**
     * Gives the search view the app's context (for the suggestion cache) without opening it (iOS `-installInView:`).
     * Put a `CYLSearchComponent` for this search view over the page it covers.
     */
    installInView(context) {
        this.context = context;
        this.rebuildCache();
    }
    /**
     * Opens the search view and, with `focusesSearchFieldOnShow`, starts editing (iOS `-showSearch:`).
     */
    showSearch(animated = true) {
        var _a, _b;
        if (this.open) {
            return;
        }
        this.refilter();
        if (animated && this.animationDuration > 0) {
            animateTo({ duration: this.animationDuration * 1000, curve: Curve.EaseOut }, () => {
                this.open = true;
            });
        }
        else {
            this.open = true;
        }
        if (this.focusesSearchFieldOnShow) {
            setTimeout(() => {
                this.searchBarView.showKeyboard();
            }, animated ? this.animationDuration * 1000 : 0);
        }
        (_b = (_a = this.delegate) === null || _a === void 0 ? void 0 : _a.searchViewDidShow) === null || _b === void 0 ? void 0 : _b.call(_a, this);
    }
    /**
     * Closes the search view and ends editing (iOS `-closeSearch:`).
     */
    closeSearch(animated = true) {
        var _a, _b;
        if (!this.open) {
            return;
        }
        this.searchBarView.hideKeyboard();
        if (animated && this.animationDuration > 0) {
            animateTo({ duration: this.animationDuration * 1000, curve: Curve.EaseIn }, () => {
                this.open = false;
            });
        }
        else {
            this.open = false;
        }
        (_b = (_a = this.delegate) === null || _a === void 0 ? void 0 : _a.searchViewDidClose) === null || _b === void 0 ? void 0 : _b.call(_a, this);
    }
    /**
     * The state to keep across a restart: whether the search view is open and its query.
     */
    encodeRestorableState() {
        const state = { 'open': this.open, 'query': this.query };
        return state;
    }
    /**
     * Restores the query and reopens the search view when it was open.
     */
    decodeRestorableState(state) {
        var _a, _b;
        this.setQuery((_a = state['query']) !== null && _a !== void 0 ? _a : '', false);
        if ((_b = state['open']) !== null && _b !== void 0 ? _b : false) {
            this.showSearch(false);
        }
    }
    /**
     * The back gesture or key: closes an open search view and returns true (iOS `-accessibilityPerformEscape`).
     */
    accessibilityPerformEscape() {
        if (!this.open) {
            return false;
        }
        this.closeSearch(true);
        return true;
    }
    /**
     * A click handler that opens the search view, for a menu item or a button (iOS `-attachToBarButtonItem:`).
     */
    attachToMenuItem() {
        return () => {
            this.showSearch(true);
        };
    }
    /**
     * Sets the query and submits it when `submit` is true (iOS `-setQuery:submit:`).
     */
    setQuery(text, submit) {
        this.searchBarView.setText(text, false);
        this.refilter();
        if (submit) {
            this.submitted();
        }
    }
    /**
     * Lists the suggestions that match the current query.
     */
    showSuggestions() {
        this.suggestionsShown = true;
        this.refilter();
    }
    /**
     * Hides the suggestions.
     */
    dismissSuggestions() {
        this.suggestionsShown = false;
    }
    /**
     * Clears the whole cache, as the trash button of the header does (iOS `-clearSuggestionCache`).
     */
    clearSuggestionCache() {
        var _a;
        (_a = this.suggestionCache) === null || _a === void 0 ? void 0 : _a.removeAllQueries();
        this.refilter();
    }
    /**
     * A suggestion was tapped: the field shows it, the delegate is told, and it is submitted with
     * `submitsOnSuggestionSelection`.
     */
    suggestionSelected(suggestion, index) {
        var _a, _b;
        this.searchBarView.setText(suggestion, false);
        this.refilter();
        (_b = (_a = this.delegate) === null || _a === void 0 ? void 0 : _a.searchViewDidSelectSuggestion) === null || _b === void 0 ? void 0 : _b.call(_a, this, suggestion, index);
        if (this.submitsOnSuggestionSelection) {
            this.submitted();
        }
    }
    submitted() {
        var _a, _b, _c, _d;
        const text = this.query.trim();
        if (text.length === 0) {
            return;
        }
        (_a = this.suggestionCache) === null || _a === void 0 ? void 0 : _a.addQuery(text);
        this.searchBarView.hideKeyboard();
        const handled = (_d = (_c = (_b = this.delegate) === null || _b === void 0 ? void 0 : _b.searchViewDidSubmitText) === null || _c === void 0 ? void 0 : _c.call(_b, this, text)) !== null && _d !== void 0 ? _d : false;
        if (!handled && this.closesOnSubmit) {
            this.closeSearch(true);
        }
        this.refilter();
    }
    rebuildCache() {
        if (this.context === undefined) {
            return;
        }
        this.suggestionCache = CYLSearchSuggestionCache_1.CYLSearchSuggestionStore.cache(this.context, this.cachePolicy, this.cacheName);
        this.refilter();
    }
    matches(suggestion, query) {
        if (this.suggestionFilter !== undefined) {
            return this.suggestionFilter(suggestion, query);
        }
        return suggestion.toLocaleLowerCase().includes(query.toLocaleLowerCase());
    }
    refilter() {
        var _a, _b;
        const query = this.query;
        const cached = (_b = (_a = this.suggestionCache) === null || _a === void 0 ? void 0 : _a.cachedQueries()) !== null && _b !== void 0 ? _b : [];
        let result = [];
        if (query.length === 0) {
            if (cached.length > 0) {
                result = cached;
                this.showsCachedQueries = true;
            }
            else {
                result = this.showsAllForEmptyQuery ? this.allSuggestions.slice() : [];
                this.showsCachedQueries = false;
            }
        }
        else {
            this.showsCachedQueries = false;
            cached.forEach((value) => {
                if (this.matches(value, query)) {
                    result.push(value);
                }
            });
            this.allSuggestions.forEach((value) => {
                if (this.matches(value, query) && !result.includes(value)) {
                    result.push(value);
                }
            });
        }
        this.filteredSuggestions = result;
        if (this.showsEmptyResults && this.emptyResults === undefined) {
            this.emptyResults = CYLSearchPlaceholderView_1.CYLSearchPlaceholderView.withKind(this.emptyResultsScenario);
        }
        if (this.showsEmptySuggestions && this.emptySuggestions === undefined) {
            this.emptySuggestions = CYLSearchPlaceholderView_1.CYLSearchPlaceholderView.withKind(this.emptySuggestionsScenario);
        }
    }
}
exports.CYLSearchView = CYLSearchView;

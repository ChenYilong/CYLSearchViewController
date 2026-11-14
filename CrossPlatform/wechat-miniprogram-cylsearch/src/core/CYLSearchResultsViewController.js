"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.CYLSearchResultsViewController = exports.CYLSearchResultsDataSource = void 0;
const CYLSearchBarView_1 = require("./CYLSearchBarView");
const CYLSearchPlaceholderView_1 = require("./CYLSearchPlaceholderView");
/**
 * Supplies the results of a `CYLSearchResultsViewController` and draws their rows (iOS
 * `CYLSearchResultsDataSource`).
 */
class CYLSearchResultsDataSource {
    constructor() {
        /**
         * The results for a query, an empty string while nothing is typed (iOS
         * `-searchResultsViewController:resultsForQuery:`).
         */
        this.searchResultsViewControllerResultsForQuery = undefined;
        /**
         * The text a result shows in its row (iOS `-searchResultsViewController:configureCell:withResult:`).
         */
        this.searchResultsViewControllerConfigureCell = undefined;
        /**
         * A result was tapped (iOS `-searchResultsViewController:didSelectResult:`). Optional.
         */
        this.searchResultsViewControllerDidSelectResult = undefined;
    }
}
exports.CYLSearchResultsDataSource = CYLSearchResultsDataSource;
/**
 * A list of search results under a search bar, driven by a `CYLSearchResultsDataSource` (iOS
 * `CYLSearchResultsViewController`). This class is the state and API; `CYLSearchResultsComponent` draws it. The
 * search bar is laid out above the list, never on top of it.
 */
class CYLSearchResultsViewController {
    /**
     * Creates the controller with its data source (iOS `-initWithSearchDataSource:`).
     */
    constructor(searchDataSource) {
        /**
         * The search bar above the results (iOS `searchController.searchBar`).
         */
        this.searchController = new CYLSearchBarView_1.CYLSearchBarView();
        /**
         * The results of the last query.
         */
        this.searchResults = [];
        /**
         * The placeholder shown while there are no results; undefined shows an empty list.
         */
        this.placeholderView = CYLSearchPlaceholderView_1.CYLSearchPlaceholderView.withKind(CYLSearchPlaceholderView_1.CYLSearchPlaceholderKind.noResults);
        /**
         * Called after each reload, to integrate your own reload (iOS `-reloadResultsTableView`, overridden there).
         */
        this.reloadResultsHandler = undefined;
        this.searchDataSource = searchDataSource;
        const barDelegate = {
            searchBarViewTextDidChange: (_, text) => {
                this.updateSearchResults(text);
            }
        };
        this.searchController.delegate = barDelegate;
        this.reloadSearchResults();
    }
    /**
     * Requeries the data source using the current search text and reloads the list.
     */
    reloadSearchResults() {
        this.updateSearchResults(this.searchController.text);
    }
    /**
     * Reloads the list; set `reloadResultsHandler` to integrate a custom reload, such as an empty-state provider.
     */
    reloadResultsTableView() {
        var _a;
        (_a = this.reloadResultsHandler) === null || _a === void 0 ? void 0 : _a.call(this, this);
    }
    /**
     * Requeries the results when the search text changes (iOS `-updateSearchResultsForSearchController:`).
     */
    updateSearchResults(query) {
        this.searchResults = this.searchDataSource.searchResultsViewControllerResultsForQuery(this, query);
        this.reloadResultsTableView();
    }
    /**
     * A result was tapped.
     */
    resultSelected(result) {
        var _a, _b;
        (_b = (_a = this.searchDataSource).searchResultsViewControllerDidSelectResult) === null || _b === void 0 ? void 0 : _b.call(_a, this, result);
    }
}
exports.CYLSearchResultsViewController = CYLSearchResultsViewController;

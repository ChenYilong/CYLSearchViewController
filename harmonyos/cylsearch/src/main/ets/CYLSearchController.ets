import { common } from '@kit.AbilityKit';
import { CYLPlaceholderScenario } from 'cylplaceholder';
import { CYLSearchBar } from './CYLSearchBar';
import { CYLSearchSuggestionCache } from './CYLSearchResources';
import {
  CYLSearchEmptyView,
  CYLSearchTableView,
  CYLSearchView,
  CYLSearchViewDataSource,
  CYLSearchViewDelegate
} from './CYLSearchView';

// MARK: - Pure logic (begin): no ArkUI, no kit; harmonyos/scripts/host-logic-test.mjs runs it with Node.

/**
 * Whether a swipe from the left edge may begin: a touch that is not the swipe's always may; the swipe itself only when
 * the touch is inside the search view, because the gesture lives on the window and would otherwise fire over a toast or
 * a presented screen (iOS `gestureRecognizerShouldBegin(_:)` and `swipeMayBegin(from:)`).
 */
function cylSearchSwipeShouldBegin(isSwipe: boolean, touchedInsideSearch: boolean): boolean {
  return !isSwipe || touchedInsideSearch;
}

/**
 * Whether the page's navigation bar is pushed away: it is while searching and `hidesNavigationBarDuringPresentation`.
 */
function cylSearchNavigationBarHidden(hides: boolean, active: boolean): boolean {
  return hides && active;
}

/**
 * Whether the status bar is hidden: only while searching, and as the provider says (iOS
 * `prefersStatusBarHiddenProvider`).
 */
function cylSearchStatusBarHidden(active: boolean, provider: (() => boolean) | undefined): boolean {
  return active && provider !== undefined && provider();
}

/**
 * The status bar style while searching, as the provider says; `fallback` while not searching or without a provider.
 */
function cylSearchStatusBarStyle(active: boolean, provider: (() => number) | undefined, fallback: number): number {
  return active && provider !== undefined ? provider() : fallback;
}

/**
 * Whether the contents' appearance changes are passed on: only while searching, and only when asked for (iOS
 * `forwardsAppearanceFromContentsViewController`).
 */
function cylSearchAppearanceForwarded(forwards: boolean, active: boolean): boolean {
  return forwards && active;
}

/**
 * The bottom edge of the search bar in the page: what the page reported while searching, 0 while the bar is not there
 * (iOS `searchBarMaxY`).
 */
function cylSearchBarMaxY(active: boolean, reported: number): number {
  return active ? Math.max(0, reported) : 0;
}

// MARK: - Pure logic (end)

/**
 * The style of the status bar (iOS `UIStatusBarStyle`).
 */
export enum CYLSearchStatusBarStyle {
  /**
   * The system's choice.
   */
  defaultStyle = 0,
  /**
   * Light content, for a dark background.
   */
  lightContent = 1,
  /**
   * Dark content, for a light background.
   */
  darkContent = 3
}

/**
 * What a `CYLSearchController` asks of its owner (iOS `CYLSearchControllerDelegate`, QMUI
 * `QMUISearchControllerDelegate`): the search results (called on every text change), the results and their row texts,
 * plus optional life cycle callbacks. Every member is optional.
 */
export interface CYLSearchControllerDelegate {
  /**
   * Called when the text of the search bar changes, also with "" (the first activation, all text deleted, the clear
   * button). Reload the results here.
   */
  searchControllerUpdateResultsForSearchString?: (searchController: CYLSearchController, searchString: string) => void;
  /**
   * Called before the search is presented.
   */
  willPresentSearchController?: (searchController: CYLSearchController) => void;
  /**
   * Called after the search is presented.
   */
  didPresentSearchController?: (searchController: CYLSearchController) => void;
  /**
   * Called before the search is dismissed.
   */
  willDismissSearchController?: (searchController: CYLSearchController) => void;
  /**
   * Called after the search is dismissed.
   */
  didDismissSearchController?: (searchController: CYLSearchController) => void;
  /**
   * Called once when the results list is connected, to configure its scroller.
   */
  searchControllerDidLoadSearchResultsTableView?: (searchController: CYLSearchController, tableView: Scroller) => void;
  /**
   * Called after the empty view was shown, to change its look.
   */
  searchControllerWillShowEmptyView?: (searchController: CYLSearchController, emptyView: CYLSearchEmptyView) => void;
  /**
   * The results for a query that is not empty (the data source of the results list).
   */
  searchControllerResultsForQuery?: (searchController: CYLSearchController, query: string) => Object[];
  /**
   * The text a result shows in its row.
   */
  searchControllerConfigureResultCell?: (searchController: CYLSearchController, result: Object) => string;
  /**
   * Called when the contents page appears or disappears while searching, with
   * `forwardsAppearanceFromContentsViewController` on.
   */
  searchControllerContentsAppearanceChanged?: (searchController: CYLSearchController, isAppearing: boolean) => void;
}

/**
 * Connects the events of a `CYLSearchView` to the controller that owns it.
 */
class CYLSearchControllerEvents implements CYLSearchViewDelegate {
  private controller: CYLSearchController;

  constructor(controller: CYLSearchController) {
    this.controller = controller;
  }

  searchViewWillShow = (searchView: CYLSearchView): void => {
    this.controller.willPresentSearchController();
  };
  searchViewDidShow = (searchView: CYLSearchView): void => {
    this.controller.didPresentSearchController();
  };
  searchViewWillClose = (searchView: CYLSearchView): void => {
    this.controller.willDismissSearchController();
  };
  searchViewDidClose = (searchView: CYLSearchView): void => {
    this.controller.didDismissSearchController();
  };
  searchViewUpdateResults = (searchView: CYLSearchView, searchString: string): void => {
    this.controller.updateSearchResults(searchString);
  };
  searchViewHistoryDidChange = (searchView: CYLSearchView, query: string): void => {
    this.controller.historyChanged(query);
  };
}

/**
 * Gives a `CYLSearchView` the results of the controller's delegate.
 */
class CYLSearchControllerResults implements CYLSearchViewDataSource {
  private controller: CYLSearchController;

  constructor(controller: CYLSearchController) {
    this.controller = controller;
  }

  searchViewResultsForQuery = (searchView: CYLSearchView, query: string): Object[] => {
    return this.controller.searchResultsDelegate?.searchControllerResultsForQuery?.(this.controller, query) ?? [];
  };
  searchViewConfigureResultCell = (searchView: CYLSearchView, result: Object): string => {
    return this.controller.searchResultsDelegate?.searchControllerConfigureResultCell?.(this.controller, result) ?? '';
  };
}

/**
 * A search controller with the shape of QMUI's `QMUISearchController` (iOS `CYLSearchController`): it wraps the search
 * page `CYLSearchView` (the counterpart of iOS's `UISearchController`, whose bar is a `CYLSearchBar`) and adds a launch
 * view while the text is empty (recent searches), a dimming color, an empty view, swipe to dismiss and the delegate
 * callbacks of QMUI. Keep a reference to the controller, as a property of the page, and put a `CYLSearchComponent` for
 * `searchController` over the page.
 */
export class CYLSearchController {
  /**
   * The name of the signal that a submitted query went into `historyStore` (iOS `historyDidChangeNotification`);
   * `observeHistoryDidChange` is the listener API that delivers it.
   */
  static readonly historyDidChangeNotification: string = 'CYLSearchControllerHistoryDidChange';
  /**
   * The search bar, a `CYLSearchBar`; use it in a navigation bar or as a list header.
   */
  readonly searchBar: CYLSearchBar;
  /**
   * Whether the page's navigation bar is pushed away while searching (read `navigationBarHidden`). Default true.
   */
  hidesNavigationBarDuringPresentation: boolean = true;
  /**
   * Whether the appearance changes of the contents page are passed on to the delegate while searching, so a results
   * view hears when the contents push a screen and when it returns (`contentsAppearanceChanged`). Default false.
   */
  forwardsAppearanceFromContentsViewController: boolean = false;
  /**
   * Returns whether the status bar is hidden while searching (QMUI `qmui_prefersStatusBarHiddenBlock`); read
   * `prefersStatusBarHidden`.
   */
  prefersStatusBarHiddenProvider: (() => boolean) | undefined = undefined;
  /**
   * Returns the status bar style while searching, a `CYLSearchStatusBarStyle` (QMUI
   * `qmui_preferredStatusBarStyleBlock`); read `preferredStatusBarStyle`.
   */
  preferredStatusBarStyleProvider: (() => number) | undefined = undefined;
  private readonly view: CYLSearchView;
  private delegateStore: CYLSearchControllerDelegate | undefined = undefined;
  private readonly events: CYLSearchControllerEvents = new CYLSearchControllerEvents(this);
  private readonly results: CYLSearchControllerResults = new CYLSearchControllerResults(this);
  private alwaysShowsResults: boolean = false;
  private snaps: boolean = true;
  private installedTable: CYLSearchTableView | undefined = undefined;
  private reportedSearchBarMaxY: number = 0;
  private historyListeners: ((query: string) => void)[] = [];

  /**
   * A controller for `searchView`, or for a new search page (iOS `init(contentsViewController:resultsViewController:)`,
   * `init(contentsViewController:resultsTableViewStyle:)` and `init(contentsViewController:)`: the contents are the
   * page that hosts the component, the results are drawn by the search view).
   */
  constructor(searchView?: CYLSearchView) {
    this.view = searchView ?? new CYLSearchView();
    this.searchBar = new CYLSearchBar(this.view.searchBarView);
    this.view.delegate = this.events;
  }

  /**
   * The owner of the results: its callbacks drive the results list, and it is told about the text and the life cycle.
   */
  get searchResultsDelegate(): CYLSearchControllerDelegate | undefined {
    return this.delegateStore;
  }

  set searchResultsDelegate(value: CYLSearchControllerDelegate | undefined) {
    this.delegateStore = value;
    this.connectResults();
  }

  /**
   * The search page inside, which `CYLSearchComponent` draws (iOS: the system `UISearchController`).
   */
  get searchController(): CYLSearchView {
    return this.view;
  }

  /**
   * The view that shows the results (iOS `searchResultsController`): the search page, once the delegate gives results;
   * undefined before.
   */
  get searchResultsController(): CYLSearchView | undefined {
    return this.view.resultsDataSource !== undefined ? this.view : undefined;
  }

  /**
   * The results list's scroller (iOS `tableView`).
   */
  get tableView(): Scroller | undefined {
    return this.view.resultsTableView;
  }

  /**
   * Gives the first match of the search text in each result row `resultMatchHighlightColor` (the brand color by
   * default). False by default; `CYLSearchView` has the same option.
   */
  get highlightsResultMatches(): boolean {
    return this.view.highlightsResultMatches;
  }

  set highlightsResultMatches(value: boolean) {
    this.view.highlightsResultMatches = value;
  }

  /**
   * The color of the highlighted match; undefined (the default) uses the brand color.
   */
  get resultMatchHighlightColor(): ResourceColor | undefined {
    return this.view.resultMatchHighlightColor;
  }

  set resultMatchHighlightColor(value: ResourceColor | undefined) {
    this.view.resultMatchHighlightColor = value;
  }

  /**
   * A view shown while the text is empty, for example the recent searches; it fills the space under the search bar
   * (QMUI `launchView`).
   */
  get launchView(): WrappedBuilder<[CYLSearchView]> | undefined {
    return this.view.launchView;
  }

  set launchView(value: WrappedBuilder<[CYLSearchView]> | undefined) {
    this.view.launchView = value;
  }

  /**
   * Whether the built-in launch view is `launchView`: the suggestion area of `CYLSearchView` (tags folded to two rows
   * and, over the submitted queries of `historyStore`, the title "Recent searches" with a clear button). Default
   * false. Setting a `launchView` of your own turns it off.
   */
  get showsSuggestionsLaunchView(): boolean {
    return this.view.showsSuggestionsLaunchView;
  }

  set showsSuggestionsLaunchView(value: boolean) {
    this.view.showsSuggestionsLaunchView = value;
  }

  /**
   * The tags of the built-in launch view while `historyStore` is empty or undefined. Empty by default.
   */
  get suggestions(): string[] {
    return this.view.suggestions;
  }

  set suggestions(value: string[]) {
    this.view.suggestions = value;
  }

  /**
   * The color over the contents while the keyboard is up and the text is empty; undefined keeps the default. Ignored
   * when a `launchView` is set (QMUI `dimmingColor`).
   */
  get dimmingColor(): ResourceColor | undefined {
    return this.view.dimmingColor;
  }

  set dimmingColor(value: ResourceColor | undefined) {
    this.view.dimmingColor = value;
  }

  /**
   * Whether the search is active, changed without animation (QMUI `active`).
   */
  get isActive(): boolean {
    return this.view.isActive;
  }

  set isActive(value: boolean) {
    this.setActive(value, false);
  }

  /**
   * Whether the page's navigation bar is pushed away now: while searching, with
   * `hidesNavigationBarDuringPresentation`.
   */
  get navigationBarHidden(): boolean {
    return cylSearchNavigationBarHidden(this.hidesNavigationBarDuringPresentation, this.view.isActive);
  }

  /**
   * Whether the results are shown even while the text is empty (QMUI `alwaysShowSearchResultsController`). Turning it
   * on clears `launchView`.
   */
  get alwaysShowsSearchResultsController(): boolean {
    return this.alwaysShowsResults;
  }

  set alwaysShowsSearchResultsController(value: boolean) {
    if (value) {
      this.view.launchView = undefined;
    }
    this.alwaysShowsResults = value;
  }

  /**
   * Whether a swipe from the left screen edge leaves the search while the results or the launch view show (QMUI
   * `supportsSwipeToDismissSearch`). Default false.
   */
  get supportsSwipeToDismissSearch(): boolean {
    return this.view.supportsSwipeToDismissSearch;
  }

  set supportsSwipeToDismissSearch(value: boolean) {
    this.view.supportsSwipeToDismissSearch = value;
  }

  /**
   * The bottom edge of the search bar in the page, in vp; 0 while the search is not active. The page reports it with
   * `searchBarLayoutChanged`.
   */
  get searchBarMaxY(): number {
    return cylSearchBarMaxY(this.view.isActive, this.reportedSearchBarMaxY);
  }

  /**
   * Whether the status bar is hidden now (`prefersStatusBarHiddenProvider`, only while searching).
   */
  get prefersStatusBarHidden(): boolean {
    return cylSearchStatusBarHidden(this.view.isActive, this.prefersStatusBarHiddenProvider);
  }

  /**
   * The status bar style now, a `CYLSearchStatusBarStyle` (`preferredStatusBarStyleProvider`, only while searching).
   */
  get preferredStatusBarStyle(): number {
    return cylSearchStatusBarStyle(this.view.isActive, this.preferredStatusBarStyleProvider,
      CYLSearchStatusBarStyle.defaultStyle);
  }

  /**
   * Whether the empty view is on screen.
   */
  get isEmptyViewShowing(): boolean {
    return this.view.isEmptyViewShowing;
  }

  /**
   * The text of the "no results" empty view that the controller manages itself: it shows the empty view with this text
   * while the text is not empty and the results have no row, and hides it otherwise. Undefined (the default) leaves
   * `showEmptyView` and `hideEmptyView` to the delegate.
   */
  get noResultsText(): string | undefined {
    return this.view.noResultsText;
  }

  set noResultsText(value: string | undefined) {
    this.view.noResultsText = value;
  }

  /**
   * Where the queries the person submits are kept, newest first and without duplicates; undefined keeps none. The
   * built-in store of `CYLSearchView` comes from `CYLSearchResources`, so the history is shared code, not a copy.
   */
  get historyStore(): CYLSearchSuggestionCache | undefined {
    return this.view.historyStore;
  }

  set historyStore(value: CYLSearchSuggestionCache | undefined) {
    this.view.historyStore = value;
  }

  /**
   * Whether a header search bar (`installSearchBar`) is kept scrollable out of sight, even above a short list, and
   * settles fully shown or fully hidden when scrolling stops (QMUI issues #1160 and #1207). Default true.
   */
  get snapsHeaderSearchBar(): boolean {
    return this.snaps;
  }

  set snapsHeaderSearchBar(value: boolean) {
    this.snaps = value;
    if (this.installedTable !== undefined) {
      this.view.setSnapsHeader(value, this.installedTable);
    }
  }

  /**
   * Enters or leaves the search (QMUI `setActive:animated:`).
   */
  setActive(active: boolean, animated: boolean): void {
    this.view.setActive(active, animated);
  }

  /**
   * Whether the search is presented; the same as `isActive` (`CYLSearchView.isSearchOpen`).
   */
  get isSearchOpen(): boolean {
    return this.view.isSearchOpen;
  }

  /**
   * Presents the search (`setActive(true, animated)`).
   */
  showSearch(animated: boolean = true): void {
    this.setActive(true, animated);
  }

  /**
   * Leaves the search (`setActive(false, animated)`).
   */
  closeSearch(animated: boolean = true): void {
    this.setActive(false, animated);
  }

  /**
   * Shows the search bar as the header of `table` (QMUI `qmui_usedAsTableHeaderView`): the bar is the list's first row,
   * a tap on it opens the search, and `snapsHeaderSearchBar` settles it fully shown or fully hidden. The header bar takes
   * the style of `searchBar`.
   */
  installSearchBar(table: CYLSearchTableView): void {
    this.searchBar.usedAsTableHeaderView = true;
    table.searchBarView.appearanceStyle = this.view.searchBarView.appearanceStyle;
    table.searchBarView.centersPlaceholder = this.view.searchBarView.centersPlaceholder;
    table.searchBarView.textFieldMargins = this.view.searchBarView.textFieldMargins;
    table.searchView = this.view;
    table.showsSearchBar = true;
    this.installedTable = table;
    this.view.setSnapsHeader(this.snaps, table);
  }

  /**
   * Takes the bar out of `table`'s header (`CYLSearchTableViewController` does this when `showsSearchBar` is turned off).
   */
  removeSearchBarHeader(table: CYLSearchTableView): void {
    if (this.installedTable === table) {
      this.installedTable = undefined;
    }
    table.searchView = undefined;
    table.showsSearchBar = false;
    this.searchBar.usedAsTableHeaderView = false;
  }

  /**
   * Gives the search page the app's context without opening it (iOS `install(in:)`, which installs the search on a
   * navigation item); put a `CYLSearchComponent` for `searchController` over the page.
   */
  installInView(context: common.Context): void {
    this.searchBar.usedAsTableHeaderView = false;
    this.view.installInView(context);
  }

  /**
   * Shows CYLTableViewPlaceHolder's placeholder with a title, an optional detail and an optional button in the results
   * (QMUI `showEmptyViewWithText:detailText:buttonTitle:buttonAction:`). Does nothing while the search text is empty:
   * the dimming view or the launch view is there then. The delegate's `searchControllerWillShowEmptyView` is called with
   * the empty view.
   */
  showEmptyView(text: string, detailText?: string, buttonTitle?: string, buttonAction?: () => void): void {
    this.view.showEmptyView(text, detailText, buttonTitle, buttonAction);
    this.announceEmptyView();
  }

  /**
   * Shows one of CYLTableViewPlaceHolder's scenarios in the results (iOS `showEmptyView(scenario:)`). Does nothing
   * while the search text is empty.
   */
  showEmptyViewScenario(scenario: CYLPlaceholderScenario): void {
    this.view.showEmptyViewScenario(scenario);
    this.announceEmptyView();
  }

  /**
   * Removes the empty view (the search leaving always does).
   */
  hideEmptyView(): void {
    this.view.hideEmptyView();
  }

  /**
   * Passes the search bar's text (also "") to the delegate (iOS `updateSearchResults(for:)`).
   */
  updateSearchResults(searchString: string): void {
    this.delegateStore?.searchControllerUpdateResultsForSearchString?.(this, searchString);
  }

  /**
   * The search is about to be presented: tells the delegate.
   */
  willPresentSearchController(): void {
    this.delegateStore?.willPresentSearchController?.(this);
  }

  /**
   * The search was presented: tells the delegate.
   */
  didPresentSearchController(): void {
    this.delegateStore?.didPresentSearchController?.(this);
  }

  /**
   * The search is about to be dismissed: tells the delegate.
   */
  willDismissSearchController(): void {
    this.delegateStore?.willDismissSearchController?.(this);
  }

  /**
   * The search was dismissed: hides the empty view (leaving the search always does) and tells the delegate.
   */
  didDismissSearchController(): void {
    this.hideEmptyView();
    this.delegateStore?.didDismissSearchController?.(this);
  }

  /**
   * Whether the swipe from the left edge, or another gesture, may begin (iOS `gestureRecognizerShouldBegin(_:)`): the
   * swipe only when the touch is inside the search view.
   */
  gestureRecognizerShouldBegin(isSwipe: boolean, touchedInsideSearch: boolean): boolean {
    return cylSearchSwipeShouldBegin(isSwipe, touchedInsideSearch);
  }

  /**
   * The page reports where the search bar ends (`searchBarMaxY`).
   */
  searchBarLayoutChanged(maxY: number): void {
    this.reportedSearchBarMaxY = maxY;
  }

  /**
   * The contents page appeared or disappeared (the page's `onPageShow` and `onPageHide`); with
   * `forwardsAppearanceFromContentsViewController` and an active search, the delegate hears it. Returns whether it was
   * passed on.
   */
  contentsAppearanceChanged(isAppearing: boolean): boolean {
    if (!cylSearchAppearanceForwarded(this.forwardsAppearanceFromContentsViewController, this.view.isActive)) {
      return false;
    }
    this.delegateStore?.searchControllerContentsAppearanceChanged?.(this, isAppearing);
    return true;
  }

  /**
   * Calls `listener` with each query that went into `historyStore` after it was submitted (iOS
   * `historyDidChangeNotification`); the returned function stops listening.
   */
  observeHistoryDidChange(listener: (query: string) => void): () => void {
    this.historyListeners.push(listener);
    return () => {
      const index = this.historyListeners.indexOf(listener);
      if (index >= 0) {
        this.historyListeners.splice(index, 1);
      }
    };
  }

  /**
   * A submitted query went into the history: tells the listeners.
   */
  historyChanged(query: string): void {
    this.historyListeners.slice().forEach((listener: (query: string) => void) => {
      listener(query);
    });
  }

  private announceEmptyView(): void {
    if (this.view.emptyView.isShowing) {
      this.delegateStore?.searchControllerWillShowEmptyView?.(this, this.view.emptyView);
    }
  }

  // The results list takes the owner's results; the results come from the delegate while it gives them.
  private connectResults(): void {
    const delegate = this.delegateStore;
    if (delegate?.searchControllerResultsForQuery !== undefined) {
      this.view.resultsDataSource = this.results;
    } else if (this.view.resultsDataSource === this.results) {
      this.view.resultsDataSource = undefined;
    }
    if (delegate !== undefined) {
      delegate.searchControllerDidLoadSearchResultsTableView?.(this, this.view.resultsTableView);
    }
  }
}

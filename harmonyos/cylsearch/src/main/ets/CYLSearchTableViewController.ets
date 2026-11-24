import { CYLPlaceholderScenario } from 'cylplaceholder';
import { CYLSearchBar } from './CYLSearchBar';
import { CYLSearchController, CYLSearchControllerDelegate } from './CYLSearchController';
import { CYLSearchTableView } from './CYLSearchView';

/**
 * Passes the text of the search to the table controller that owns the search controller.
 */
class CYLSearchTableViewControllerDelegate implements CYLSearchControllerDelegate {
  private owner: CYLSearchTableViewController;

  constructor(owner: CYLSearchTableViewController) {
    this.owner = owner;
  }

  searchControllerUpdateResultsForSearchString = (searchController: CYLSearchController, searchString: string): void => {
    this.owner.searchControllerUpdateResultsForSearchString(searchController, searchString);
  };
}

/**
 * A list that can show a `CYLSearchBar` as its header, with the `CYLSearchController` that drives it (iOS
 * `CYLSearchTableViewController`, QMUI's `QMUICommonTableViewController (Search)`). Set `showsSearchBar`; configure the
 * bar in `setUpSearchBar()`; override `searchControllerUpdateResultsForSearchString`. `table` is the list model that
 * `CYLSearchTableComponent` draws (the counterpart of iOS's table view).
 */
export class CYLSearchTableViewController {
  /**
   * The list model: pass it to `CYLSearchTableComponent`.
   */
  readonly table: CYLSearchTableView = new CYLSearchTableView();
  private searchControllerStore: CYLSearchController | undefined = undefined;
  private searchBarStore: CYLSearchBar | undefined = undefined;
  private showsBar: boolean = false;
  private loaded: boolean = false;

  /**
   * Whether the search bar is shown as the list header (QMUI `shouldShowSearchBar`, default false). The controller and
   * the bar are created, or removed, once the page is loaded (`viewDidLoad`): a value set before takes effect there.
   * Turning it off removes the header, the bar and the controller (`searchController` and `searchBar` are undefined
   * again).
   */
  get showsSearchBar(): boolean {
    return this.showsBar;
  }

  set showsSearchBar(value: boolean) {
    if (value === this.showsBar) {
      return;
    }
    this.showsBar = value;
    if (value) {
      this.installSearchController();
    } else {
      this.removeSearchController();
    }
  }

  /**
   * The search controller, undefined while `showsSearchBar` is off or the page is not loaded (QMUI
   * `searchController`).
   */
  get searchController(): CYLSearchController | undefined {
    return this.searchControllerStore;
  }

  /**
   * The search bar that is the list header, undefined while `showsSearchBar` is off or the page is not loaded (QMUI
   * `searchBar`).
   */
  get searchBar(): CYLSearchBar | undefined {
    return this.searchBarStore;
  }

  /**
   * Whether the search bar leaves the header while an empty view shows and returns when it is hidden (QMUI
   * `shouldHideSearchBarWhenEmptyViewShowing`, default false).
   */
  get hidesSearchBarWhenEmptyViewShowing(): boolean {
    return this.table.hidesSearchBarWhenEmptyViewShowing;
  }

  set hidesSearchBarWhenEmptyViewShowing(value: boolean) {
    this.table.hidesSearchBarWhenEmptyViewShowing = value;
  }

  /**
   * Whether the list is scrolled so that the search bar is out of sight when it is first shown (QMUI
   * `shouldHideTableHeaderViewInitial`, default false), and again each time the bar returns after an empty view.
   */
  get hidesSearchBarInitially(): boolean {
    return this.table.hidesSearchBarInitially;
  }

  set hidesSearchBarInitially(value: boolean) {
    this.table.hidesSearchBarInitially = value;
  }

  /**
   * Whether the empty view is on screen.
   */
  get isEmptyViewShowing(): boolean {
    return this.table.isEmptyViewShowing;
  }

  /**
   * The page is loaded (call it from `aboutToAppear`): the search controller of a `showsSearchBar` set before is
   * created now.
   */
  viewDidLoad(): void {
    this.loaded = true;
    this.installSearchController();
  }

  /**
   * Called once after the search controller and the bar are created and before the bar becomes the list header: set the
   * bar's style, margins and accessory views here (QMUI `initSearchController`, which subclasses extend). Does nothing by
   * default.
   */
  setUpSearchBar(): void {
  }

  /**
   * Called with every text change of the search, also with "" (QMUI `searchController:updateResultsForSearchString:`);
   * does nothing by default. Override it to reload the results.
   */
  searchControllerUpdateResultsForSearchString(searchController: CYLSearchController, searchString: string): void {
  }

  /**
   * Shows CYLTableViewPlaceHolder's placeholder with a title and an optional detail in place of the rows (QMUI
   * `showEmptyViewWithText:detailText:buttonTitle:buttonAction:`, without the button). With
   * `hidesSearchBarWhenEmptyViewShowing` the search bar leaves the header.
   */
  showEmptyView(text: string, detailText?: string): void {
    this.table.showEmptyView(text, detailText);
  }

  /**
   * Shows one of CYLTableViewPlaceHolder's scenarios in place of the rows (the placeholder `CYLSearchView` shows for
   * empty results).
   */
  showEmptyViewScenario(scenario: CYLPlaceholderScenario): void {
    this.table.showEmptyViewScenario(scenario);
  }

  /**
   * Removes the empty view; with `hidesSearchBarWhenEmptyViewShowing` the search bar returns to the header, hidden
   * again if `hidesSearchBarInitially` is on (QMUI issue #128).
   */
  hideEmptyView(): void {
    this.table.hideEmptyView();
  }

  private installSearchController(): void {
    if (!this.loaded || !this.showsBar || this.searchControllerStore !== undefined) {
      return;
    }
    const controller = new CYLSearchController();
    controller.searchResultsDelegate = new CYLSearchTableViewControllerDelegate(this);
    this.searchControllerStore = controller;
    this.searchBarStore = controller.searchBar;
    this.setUpSearchBar();
    controller.installSearchBar(this.table);
  }

  private removeSearchController(): void {
    const controller = this.searchControllerStore;
    if (controller === undefined) {
      return;
    }
    controller.removeSearchBarHeader(this.table);
    controller.searchResultsDelegate = undefined;
    this.searchBarStore = undefined;
    this.searchControllerStore = undefined;
  }
}

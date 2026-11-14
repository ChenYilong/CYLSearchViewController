import { CYLSearchBarComponent, CYLSearchBarView, CYLSearchBarViewDelegate } from './CYLSearchBarView';
import { CYLSearchPlaceholderComponent, CYLSearchPlaceholderKind, CYLSearchPlaceholderView } from './CYLSearchPlaceholderView';

/**
 * Supplies the results of a `CYLSearchResultsViewController` and draws their rows (iOS
 * `CYLSearchResultsDataSource`).
 */
export interface CYLSearchResultsDataSource {
  /**
   * The results for a query, an empty string while nothing is typed (iOS
   * `-searchResultsViewController:resultsForQuery:`).
   */
  searchResultsViewControllerResultsForQuery: (controller: CYLSearchResultsViewController, query: string) => Object[];
  /**
   * The text a result shows in its row (iOS `-searchResultsViewController:configureCell:withResult:`).
   */
  searchResultsViewControllerConfigureCell: (controller: CYLSearchResultsViewController, result: Object) => string;
  /**
   * A result was tapped (iOS `-searchResultsViewController:didSelectResult:`). Optional.
   */
  searchResultsViewControllerDidSelectResult?: (controller: CYLSearchResultsViewController, result: Object) => void;
}

/**
 * A list of search results under a search bar, driven by a `CYLSearchResultsDataSource` (iOS
 * `CYLSearchResultsViewController`). This class is the state and API; `CYLSearchResultsComponent` draws it. The
 * search bar is laid out above the list, never on top of it.
 */
@ObservedV2
export class CYLSearchResultsViewController {
  /**
   * The data source given at creation.
   */
  readonly searchDataSource: CYLSearchResultsDataSource;
  /**
   * The search bar above the results (iOS `searchController.searchBar`).
   */
  readonly searchController: CYLSearchBarView = new CYLSearchBarView();
  /**
   * The results of the last query.
   */
  @Trace searchResults: Object[] = [];
  /**
   * The placeholder shown while there are no results; undefined shows an empty list.
   */
  @Trace placeholderView: CYLSearchPlaceholderView | undefined =
    CYLSearchPlaceholderView.withKind(CYLSearchPlaceholderKind.noResults);
  /**
   * Called after each reload, to integrate your own reload (iOS `-reloadResultsTableView`, overridden there).
   */
  reloadResultsHandler: ((controller: CYLSearchResultsViewController) => void) | undefined = undefined;

  /**
   * Creates the controller with its data source (iOS `-initWithSearchDataSource:`).
   */
  constructor(searchDataSource: CYLSearchResultsDataSource) {
    this.searchDataSource = searchDataSource;
    const barDelegate: CYLSearchBarViewDelegate = {
      searchBarViewTextDidChange: (_: CYLSearchBarView, text: string) => {
        this.updateSearchResults(text);
      }
    };
    this.searchController.delegate = barDelegate;
    this.reloadSearchResults();
  }

  /**
   * Requeries the data source using the current search text and reloads the list.
   */
  reloadSearchResults(): void {
    this.updateSearchResults(this.searchController.text);
  }

  /**
   * Reloads the list; set `reloadResultsHandler` to integrate a custom reload, such as an empty-state provider.
   */
  reloadResultsTableView(): void {
    this.reloadResultsHandler?.(this);
  }

  /**
   * Requeries the results when the search text changes (iOS `-updateSearchResultsForSearchController:`).
   */
  updateSearchResults(query: string): void {
    this.searchResults = this.searchDataSource.searchResultsViewControllerResultsForQuery(this, query);
    this.reloadResultsTableView();
  }

  /**
   * A result was tapped.
   */
  resultSelected(result: Object): void {
    this.searchDataSource.searchResultsViewControllerDidSelectResult?.(this, result);
  }
}

/**
 * Draws a `CYLSearchResultsViewController`: its search bar, then its results (or its placeholder) below the bar.
 */
@ComponentV2
export struct CYLSearchResultsComponent {
  /**
   * The controller to draw.
   */
  @Require @Param controller: CYLSearchResultsViewController;

  build() {
    Column() {
      CYLSearchBarComponent({ searchBarView: this.controller.searchController })
      if (this.controller.searchResults.length === 0 && this.controller.placeholderView !== undefined) {
        CYLSearchPlaceholderComponent({ placeholderView: this.controller.placeholderView })
          .layoutWeight(1)
      } else {
        List() {
          ForEach(this.controller.searchResults, (result: Object) => {
            ListItem() {
              Text(this.controller.searchDataSource.searchResultsViewControllerConfigureCell(this.controller, result))
                .fontSize(17)
                .fontColor($r('sys.color.font_primary'))
                .width('100%')
                .constraintSize({ minHeight: 44 })
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            }
            .onClick(() => {
              this.controller.resultSelected(result);
            })
          }, (result: Object, index: number) => `${index}`)
        }
        .width('100%')
        .layoutWeight(1)
        .divider({ strokeWidth: 0.5, color: $r('sys.color.comp_divider'), startMargin: 16 })
      }
    }
    .width('100%')
    .height('100%')
  }
}

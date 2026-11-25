import { common } from '@kit.AbilityKit';
import {
  CYLSearchBarComponent,
  CYLSearchBarView,
  CYLSearchComponent,
  CYLSearchRefreshComponent,
  CYLSearchSuggestionCachePolicy,
  CYLSearchView,
  CYLSearchViewDataSource
} from 'cylsearch';
import { cylDemoText, CYLDemoNavBar, CYLDemoPlaceholderStack, CYL_PLUS_OVERHANG } from '../common/DemoCommon';

/**
 * Forty localized sample results, filtered by the query; also the example's refresh provider (iOS
 * `CYLSearchExampleDataSource`).
 */
export class CYLSearchExampleDataSource implements CYLSearchViewDataSource {
  private items: string[] = [];

  constructor(context: common.Context) {
    for (let i = 1; i <= 40; i++) {
      this.items.push(cylDemoText(context, 'sample.result', i));
    }
  }

  /**
   * All items for an empty query, else the items that contain the query (case-insensitive).
   */
  results(query: string): string[] {
    const lower = query.toLocaleLowerCase();
    return query.length === 0 ? this.items : this.items.filter((item: string) => item.toLocaleLowerCase().includes(lower));
  }

  // The results of the overlay's CYLSearchView.
  searchViewResultsForQuery = (_: CYLSearchView, query: string): Object[] => {
    return this.results(query);
  };

  // Shows the result's text.
  searchViewConfigureResultCell = (_: CYLSearchView, result: Object): string => {
    return result as string;
  };

  /**
   * Finishes after 0.4 seconds without an error.
   */
  reload(completion: (error?: Error) => void): void {
    setTimeout(() => completion(), 400);
  }
}

/**
 * The Issue #1317 reproduction (iOS `CYLSearchExampleViewController`): a search bar under the navigation bar over a
 * list with the core's pull to refresh (`CYLSearchView.setRefreshHandler` on the list's scroller, drawn by
 * `CYLSearchRefreshComponent`) and CYLTableViewPlaceHolder's "No matching results" placeholder. "Repro" switches
 * `hidesSearchBarWhenScrolling` (the bar scrolls away with the list); "Overlay" opens a `CYLSearchView` whose results
 * come from the same data source, with the same refresh on its results (`refreshHandler`).
 */
@ComponentV2
export struct SearchExampleView {
  @Param showsBack: boolean = false;
  @Event onBack: () => void = () => {
  };
  @Local hidesSearchBarWhenScrolling: boolean = false;
  @Local results: string[] = [];
  private scroller: Scroller = new Scroller();
  private context: common.Context = this.getUIContext().getHostContext() as common.Context;
  private source: CYLSearchExampleDataSource = new CYLSearchExampleDataSource(this.context);
  private searchBar: CYLSearchBarView = new CYLSearchBarView();
  private overlaySearchView: CYLSearchView = new CYLSearchView();

  aboutToAppear(): void {
    this.searchBar.placeholder = cylDemoText(this.context, 'search.placeholder');
    this.searchBar.focusesOnAppear = true; // the field focuses itself every time the bar appears
    this.searchBar.cancelButtonTitle = cylDemoText(this.context, 'search.cancel');
    this.searchBar.delegate = {
      searchBarViewTextDidChange: (_: CYLSearchBarView, text: string) => {
        this.results = this.source.results(text);
      }
    };
    this.results = this.source.results('');
    // The core's refresh API only (no CYLTableViewPlaceHolder call in the example). The handler is kept by the
    // scroller's entry, which goes away with the scroller.
    CYLSearchView.setRefreshHandler(() => this.refresh(() => CYLSearchView.endRefreshingIn(this.scroller)),
      this.scroller);

    this.overlaySearchView.suggestionCachePolicy = CYLSearchSuggestionCachePolicy.none;
    this.overlaySearchView.showsEmptyResultsPlaceholder = true;
    this.overlaySearchView.searchBarView.placeholder = cylDemoText(this.context, 'search.placeholder');
    this.overlaySearchView.resultsDataSource = this.source;
    this.overlaySearchView.refreshHandler = () => this.refresh(() => this.overlaySearchView.endRefreshing());
  }

  aboutToDisappear(): void {
    CYLSearchView.setRefreshHandler(undefined, this.scroller);
    this.overlaySearchView.refreshHandler = undefined;
  }

  // Reloads the data source; `finish` stops the refresh on every path, before the results or the error are shown.
  private refresh(finish: () => void): void {
    this.source.reload((error?: Error) => {
      finish();
      if (error !== undefined) {
        this.getUIContext().showAlertDialog({
          title: cylDemoText(this.context, 'refresh.error'),
          message: error.message,
          confirm: { value: cylDemoText(this.context, 'action.ok'), action: () => {
          } }
        });
      } else {
        this.results = this.source.results(this.searchBar.text);
        this.overlaySearchView.reloadResults();
      }
    });
  }

  @Builder
  bar() {
    CYLSearchBarComponent({ searchBarView: this.searchBar })
  }

  build() {
    Stack() {
      Column() {
        CYLDemoNavBar({
          title: cylDemoText(this.context, 'search.title'),
          showsBack: this.showsBack,
          leftTitle: cylDemoText(this.context, 'action.overlay'),
          rightTitle: cylDemoText(this.context, this.hidesSearchBarWhenScrolling ? 'repro.on' : 'repro.off'),
          rightId: 'CYLIssueReproductionToggle',
          onBack: () => this.onBack(),
          onLeft: () => this.overlaySearchView.showSearchIn(this.context),
          onRight: () => {
            this.hidesSearchBarWhenScrolling = !this.hidesSearchBarWhenScrolling;
          }
        })
        if (!this.hidesSearchBarWhenScrolling) {
          this.bar()
        }
        Column() {
          CYLSearchRefreshComponent({ scroller: this.scroller }) {
            List({ scroller: this.scroller }) {
              if (this.hidesSearchBarWhenScrolling) {
                ListItem() {
                  this.bar()
                }
              }
              if (this.results.length === 0) {
                ListItem() {
                  CYLDemoPlaceholderStack()
                    .height(360)
                    .id('CYLSearchEmptyState')
                }
              }
              ForEach(this.results, (result: string) => {
                ListItem() {
                  Text(result)
                    .fontSize(17)
                    .fontColor($r('sys.color.font_primary'))
                    .width('100%')
                    .constraintSize({ minHeight: 44 })
                    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                }
              }, (result: string) => result)
            }
            .contentEndOffset(CYL_PLUS_OVERHANG)
            .width('100%')
            .height('100%')
            .divider({ strokeWidth: 0.5, color: $r('sys.color.comp_divider'), startMargin: 16 })
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
          }
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.background_primary'))

      CYLSearchComponent({ searchView: this.overlaySearchView })
    }
    .width('100%')
    .height('100%')
  }
}

/**
 * The reproduction pushed from the Examples menu ("Search and refresh").
 */
@ComponentV2
export struct SearchExamplePage {
  @Require @Param stack: NavPathStack;

  build() {
    NavDestination() {
      SearchExampleView({ showsBack: true, onBack: () => this.stack.pop() })
    }
    .hideTitleBar(true)
  }
}

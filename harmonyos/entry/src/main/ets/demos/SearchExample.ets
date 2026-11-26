import { common } from '@kit.AbilityKit';
import {
  CYLSearchBarComponent,
  CYLSearchBarPreset,
  CYLSearchBarSearchButtonStyle,
  CYLSearchBarView,
  CYLSearchNavigationTitleBar,
  CYLSearchComponent,
  CYLSearchRefreshComponent,
  CYLSearchSuggestionCachePolicy,
  CYLSearchView,
  CYLSearchViewDataSource
} from 'cylsearch';
import { cylFirstLevelBar } from './FirstLevel';
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
  // The stack of the Search tab: given when the view is the tab root, a first-level page (the whole pill bar in the
  // navigation bar, a tap pushes the search page); the pushed Examples row has none and keeps the bar under the title.
  @Param stack: NavPathStack | undefined = undefined;
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
  private firstLevelBar: CYLSearchBarView | undefined = undefined;

  aboutToAppear(): void {
    const stack = this.stack;
    if (stack !== undefined) {
      // The Search tab shows the icon style of the default search button (the round black button of the recording).
      this.firstLevelBar = cylFirstLevelBar(CYLSearchBarPreset.pill, cylDemoText(this.context, 'search.placeholder'),
        stack, CYLSearchBarSearchButtonStyle.icon);
    }
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
  navButtons() {
    Row() {
      Text(cylDemoText(this.context, 'action.overlay'))
        .fontSize(17).fontColor($r('sys.color.brand')).height(44).padding({ left: 12, right: 12 })
        .onClick(() => this.overlaySearchView.showSearchIn(this.context))
      Text(cylDemoText(this.context, this.hidesSearchBarWhenScrolling ? 'repro.on' : 'repro.off'))
        .fontSize(17).fontColor($r('sys.color.brand')).height(44).padding({ left: 12, right: 16 })
        .id('CYLIssueReproductionToggle')
        .onClick(() => {
          this.hidesSearchBarWhenScrolling = !this.hidesSearchBarWhenScrolling;
        })
    }
  }

  @Builder
  bar() {
    CYLSearchBarComponent({ searchBarView: this.searchBar })
  }

  build() {
    Stack() {
      Column() {
        if (this.firstLevelBar !== undefined) {
          CYLSearchNavigationTitleBar({ searchBarView: this.firstLevelBar, stack: this.stack })
        } else {
          // Pushed from the Examples tab the back button takes the left slot, so the overlay button sits beside the
          // reproduction toggle on the right (without it the overlay demo would have no way in).
          CYLDemoNavBar({
            title: cylDemoText(this.context, 'search.title'),
            showsBack: this.showsBack,
            leftTitle: cylDemoText(this.context, 'action.overlay'),
            rightTitle: cylDemoText(this.context, this.hidesSearchBarWhenScrolling ? 'repro.on' : 'repro.off'),
            rightId: 'CYLIssueReproductionToggle',
            hasRightView: this.showsBack,
            rightView: () => {
              this.navButtons()
            },
            onBack: () => this.onBack(),
            onLeft: () => this.overlaySearchView.showSearchIn(this.context),
            onRight: () => {
              this.hidesSearchBarWhenScrolling = !this.hidesSearchBarWhenScrolling;
            }
          })
        }
        if (this.firstLevelBar === undefined && !this.hidesSearchBarWhenScrolling) {
          this.bar()
        }
        Column() {
          CYLSearchRefreshComponent({ scroller: this.scroller }) {
            List({ scroller: this.scroller }) {
              if (this.firstLevelBar === undefined && this.hidesSearchBarWhenScrolling) {
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

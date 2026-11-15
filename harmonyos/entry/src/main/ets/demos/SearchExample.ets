import { common } from '@kit.AbilityKit';
import {
  CYLSearchBarComponent,
  CYLSearchController,
  CYLSearchOverlayComponent,
  CYLSearchPlaceholderComponent,
  CYLSearchPlaceholderKind,
  CYLSearchPlaceholderView,
  CYLSearchResultsDataSource,
  CYLSearchResultsViewController
} from 'cylsearch';
import { cylDemoText, CYLDemoNavBar } from '../common/DemoCommon';
import { CYLRefreshContainer, CYLRefreshNormalHeaderModel, CYLRefreshScrollViewModel } from 'cylplaceholder';

/**
 * Forty localized sample results, filtered by the query; also the example's refresh provider (iOS
 * `CYLSearchExampleDataSource`).
 */
export class CYLSearchExampleDataSource implements CYLSearchResultsDataSource {
  private items: string[] = [];

  constructor(context: common.Context) {
    for (let i = 1; i <= 40; i++) {
      this.items.push(cylDemoText(context, 'sample.result', i));
    }
  }

  // All items for an empty query, else the items that contain the query (case-insensitive).
  searchResultsViewControllerResultsForQuery = (_: CYLSearchResultsViewController, query: string): Object[] => {
    const lower = query.toLocaleLowerCase();
    return query.length === 0 ? this.items : this.items.filter((item: string) => item.toLocaleLowerCase().includes(lower));
  };

  // Shows the result's text.
  searchResultsViewControllerConfigureCell = (_: CYLSearchResultsViewController, result: Object): string => {
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
 * list with pull to refresh (CYLTableViewPlaceHolder's `CYLRefreshNormalHeader`) and the empty state
 * CYLSearchPlaceholderView "No matching results". "Repro" switches `hidesSearchBarWhenScrolling` (the bar scrolls away
 * with the list); "Overlay" opens `CYLSearchController`.
 */
@ComponentV2
export struct SearchExampleView {
  @Param showsBack: boolean = false;
  @Event onBack: () => void = () => {
  };
  @Local hidesSearchBarWhenScrolling: boolean = false;
  // CYLTableViewPlaceHolder's CYLRefreshNormalHeader (its HarmonyOS library `cylplaceholder`), as `tableView.cyl_header`.
  private scrollView: CYLRefreshScrollViewModel = new CYLRefreshScrollViewModel();
  private header: CYLRefreshNormalHeaderModel = new CYLRefreshNormalHeaderModel();
  private scroller: Scroller = new Scroller();
  private context: common.Context = this.getUIContext().getHostContext() as common.Context;
  private source: CYLSearchExampleDataSource = new CYLSearchExampleDataSource(this.context);
  private controller: CYLSearchResultsViewController = new CYLSearchResultsViewController(this.source);
  private overlayController: CYLSearchController | undefined = undefined;
  @Local overlayReady: boolean = false;
  private empty: CYLSearchPlaceholderView = CYLSearchPlaceholderView.withKind(CYLSearchPlaceholderKind.noResults);

  aboutToAppear(): void {
    this.controller.searchController.placeholder = cylDemoText(this.context, 'search.placeholder');
    this.controller.searchController.cancelButtonTitle = cylDemoText(this.context, 'search.cancel');
    this.header.refreshingBlock = () => this.refresh();
    this.scrollView.cyl_header = this.header;
  }

  private showOverlay(): void {
    if (this.overlayController === undefined) {
      this.overlayController = new CYLSearchController(this.source);
      this.overlayController.resultsViewController.searchController.cancelButtonTitle = cylDemoText(this.context, 'search.cancel');
      this.overlayReady = true;
    }
    this.overlayController.showInViewController();
  }

  private refresh(): void {
    this.source.reload((error?: Error) => {
      this.header.endRefreshing();
      if (error !== undefined) {
        this.getUIContext().showAlertDialog({
          title: cylDemoText(this.context, 'refresh.error'),
          message: error.message,
          confirm: { value: cylDemoText(this.context, 'action.ok'), action: () => {
          } }
        });
      } else {
        this.controller.reloadSearchResults();
      }
    });
  }

  @Builder
  bar() {
    CYLSearchBarComponent({ searchBarView: this.controller.searchController })
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
          onLeft: () => this.showOverlay(),
          onRight: () => {
            this.hidesSearchBarWhenScrolling = !this.hidesSearchBarWhenScrolling;
          }
        })
        if (!this.hidesSearchBarWhenScrolling) {
          this.bar()
        }
        Column() {
        CYLRefreshContainer({ scrollView: this.scrollView, scroller: this.scroller }) {
          List({ scroller: this.scroller }) {
            if (this.hidesSearchBarWhenScrolling) {
              ListItem() {
                this.bar()
              }
            }
            if (this.controller.searchResults.length === 0) {
              ListItem() {
                CYLSearchPlaceholderComponent({ placeholderView: this.empty })
                  .height(360)
                  .id('CYLSearchEmptyState')
              }
            }
            ForEach(this.controller.searchResults, (result: Object) => {
              ListItem() {
                Text(result as string)
                  .fontSize(17)
                  .fontColor($r('sys.color.font_primary'))
                  .width('100%')
                  .constraintSize({ minHeight: 44 })
                  .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              }
            }, (result: Object) => result as string)
          }
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

      if (this.overlayReady && this.overlayController !== undefined) {
        CYLSearchOverlayComponent({ controller: this.overlayController })
      }
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


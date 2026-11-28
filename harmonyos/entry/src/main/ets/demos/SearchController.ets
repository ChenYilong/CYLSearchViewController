import { common } from '@kit.AbilityKit';
import {
  CYLSearchBarAppearance,
  CYLSearchBarNavigationIcon,
  CYLSearchBarView,
  CYLSearchComponent,
  CYLSearchEdgeInsets,
  CYLSearchSuggestionCachePolicy,
  CYLSearchTableComponent,
  CYLSearchTableView,
  CYLSearchView,
  CYLSearchViewDataSource
} from 'cylsearch';
import { CYLDemoNavBar, cylDemoText, cylFormat } from '../common/DemoCommon';

/**
 * The keywords of QMUI's `QDSearchViewController` (iOS `CYLSearchControllerDemoViewController.keywords`).
 */
const CYL_KEYWORDS: string[] = ['Helps', 'Maintain', 'Liver', 'Health', 'Function', 'Supports', 'Healthy', 'Fat',
  'Metabolism', 'Nuturally'];

/**
 * The suggestions of the launch area while there is no history (iOS `CYLSearchControllerDemoViewController.suggestions`).
 */
const CYL_LAUNCH_SUGGESTIONS: string[] = ['Helps', 'Maintain', 'Liver', 'Health', 'Function', 'Supports', 'Healthy',
  'Fat'];

/**
 * Each matching keyword appears this many times in the results (QMUI's demo shows 20 rows per match).
 */
const CYL_RESULT_REPEAT: number = 20;

/**
 * The results of the Search controller screen: the matching keywords, each repeated 20 times.
 */
class CYLKeywordResults implements CYLSearchViewDataSource {
  searchViewResultsForQuery = (_: CYLSearchView, query: string): Object[] => {
    const results: Object[] = [];
    CYL_KEYWORDS.filter((keyword: string) => keyword.includes(query)).forEach((keyword: string) => {
      for (let i = 0; i < CYL_RESULT_REPEAT; i++) {
        results.push(keyword);
      }
    });
    return results;
  };

  searchViewConfigureResultCell = (_: CYLSearchView, result: Object): string => {
    return result as string;
  };
}

/**
 * The Search controller screen (iOS `CYLSearchControllerDemoViewController`, QMUI's `QDSearchViewController`): a list
 * of ten keywords whose first row is the search bar; a tap on it opens the search with the recent searches as the
 * launch view, the history kept when a query is submitted, results of 20 rows per matching keyword with the match
 * highlighted, and "No matching results" when nothing matches. The system back gesture ends the search first.
 */
@ComponentV2
export struct SearchControllerView {
  @Param showsBack: boolean = false;
  @Event onBack: () => void = () => {
  };
  private context: common.Context = this.getUIContext().getHostContext() as common.Context;
  @Require @Param searchView: CYLSearchView;
  private table: CYLSearchTableView = new CYLSearchTableView();

  aboutToAppear(): void {
    const search = this.searchView;
    // Everything below the bar is the core's: the history and the eight suggestions as tags of the tag list (a tapped tag
    // submits), the highlighted results and the empty view (iOS `CYLSearchControllerDemoViewController`).
    search.supportsSwipeToDismissSearch = true;
    search.highlightsResultMatches = true;
    search.noResultsText = cylDemoText(this.context, 'controller.noResults');
    search.closesOnSubmit = false;
    search.searchBarView.appearanceStyle = CYLSearchBarAppearance.defaultAppearance;
    search.searchBarView.navigationIcon = CYLSearchBarNavigationIcon.none;
    search.searchBarView.showsCancelButton = true;
    search.searchBarView.clearsTextOnCancel = true;
    search.suggestionCachePolicy = CYLSearchSuggestionCachePolicy.userDefaults;
    search.suggestionCacheName = 'CYLSearchControllerDemo';
    search.suggestions = CYL_LAUNCH_SUGGESTIONS;
    search.showsSuggestionsLaunchView = true;
    search.resultsDataSource = new CYLKeywordResults();
    this.table.showsSearchBar = true;
    this.table.searchView = search;
  }

  @Builder
  rows() {
    ForEach(CYL_KEYWORDS, (keyword: string) => {
      ListItem() {
        Text(keyword)
          .fontSize(17)
          .fontColor($r('sys.color.font_primary'))
          .width('100%')
          .constraintSize({ minHeight: 44 })
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      }
      .accessibilityGroup(true)
    }, (keyword: string) => keyword)
  }

  build() {
    Stack() {
      Column() {
        CYLDemoNavBar({
          title: cylDemoText(this.context, 'demo.searchController'),
          showsBack: this.showsBack,
          onBack: () => this.onBack()
        })
        CYLSearchTableComponent({ searchTable: this.table, rows: () => {
          this.rows();
        } })
          .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.background_primary'))

      CYLSearchComponent({ searchView: this.searchView })
    }
    .width('100%')
    .height('100%')
  }
}

/**
 * The Search controller page pushed from the Examples menu.
 */
@ComponentV2
export struct SearchControllerPage {
  @Require @Param stack: NavPathStack;
  private searchView: CYLSearchView = new CYLSearchView();

  build() {
    NavDestination() {
      SearchControllerView({ searchView: this.searchView, showsBack: true, onBack: () => this.stack.pop() })
    }
    .hideTitleBar(true)
    // The system back gesture ends the search first (iOS: the edge swipe, `supportsSwipeToDismissSearch`).
    .onBackPressed(() => this.searchView.handleBackPress())
  }
}

/**
 * A 30 x 30 rounded square with a 3 vp stroke, the accessory view of the styles screen (iOS `accessoryView()`).
 */
@Builder
function cylLeadingAccessory() {
  Row()
    .width(30)
    .height(30)
    .borderRadius(6)
    .border({ width: 3, color: '#FF3B30' })
    .accessibilityText($r('app.string.cyl_styles_accessory_label'))
}

@Builder
function cylTrailingAccessory() {
  Row()
    .width(30)
    .height(30)
    .borderRadius(6)
    .border({ width: 3, color: '#007AFF' })
    .accessibilityText($r('app.string.cyl_styles_accessory_label'))
}

/**
 * The rows of the Search bar styles screen (iOS `CYLSearchBarStylesViewController.Row`).
 */
enum CYLStylesRow {
  centerPlaceholder = 0,
  changePlaceholder = 1,
  adjustField = 2,
  adjustCancel = 3,
  animated = 4,
  toggleCancel = 5,
  toggleLeading = 6,
  toggleTrailing = 7
}

/**
 * The Search bar styles screen (iOS `CYLSearchBarStylesViewController`, QMUI's `QDSearchBarViewController`): a list
 * with a built-in bar (`CYLSearchTableView`) and the sections Placeholder (center it, change it), Layout (field margins
 * 0 / 32 at rest, Cancel margin -16 while searching) and Accessory view (animated switch; show or hide Cancel, the
 * leading and the trailing 30 x 30 accessory view).
 */
@ComponentV2
export struct SearchBarStylesView {
  @Param showsBack: boolean = false;
  @Event onBack: () => void = () => {
  };
  @Local animated: boolean = true;
  @Local centersPlaceholder: boolean = false;
  @Local showsCancel: boolean = false;
  @Local showsLeading: boolean = false;
  @Local showsTrailing: boolean = false;
  private context: common.Context = this.getUIContext().getHostContext() as common.Context;
  private table: CYLSearchTableView = new CYLSearchTableView();
  private sections: CYLStylesRow[][] = [
    [CYLStylesRow.centerPlaceholder, CYLStylesRow.changePlaceholder],
    [CYLStylesRow.adjustField, CYLStylesRow.adjustCancel],
    [CYLStylesRow.animated, CYLStylesRow.toggleCancel, CYLStylesRow.toggleLeading, CYLStylesRow.toggleTrailing]
  ];
  private sectionKeys: string[] = ['styles.section.placeholder', 'styles.section.layout', 'styles.section.accessory'];

  aboutToAppear(): void {
    const bar = this.table.searchBarView;
    this.table.showsSearchBar = true;
    bar.leadingView = wrapBuilder(cylLeadingAccessory);
    bar.trailingAccessoryViews = wrapBuilder(cylTrailingAccessory);
    bar.leadingAccessoryViewMargins = { top: 0, left: 8, bottom: 0, right: 0 };
    bar.trailingAccessoryViewMargins = { top: 0, left: 0, bottom: 0, right: 8 };
    bar.showsLeadingView = false;
    bar.showsTrailingAccessoryViews = false;
  }

  private title(row: CYLStylesRow): string {
    const toggle = (shown: boolean, nameKey: string): string =>
    cylFormat(cylDemoText(this.context, shown ? 'styles.hide' : 'styles.show'), cylDemoText(this.context, nameKey));
    if (row === CYLStylesRow.centerPlaceholder) {
      return cylDemoText(this.context, 'styles.centerPlaceholder');
    } else if (row === CYLStylesRow.changePlaceholder) {
      return cylDemoText(this.context, 'styles.changePlaceholder');
    } else if (row === CYLStylesRow.adjustField) {
      return cylDemoText(this.context, 'styles.adjustField');
    } else if (row === CYLStylesRow.adjustCancel) {
      return cylDemoText(this.context, 'styles.adjustCancel');
    } else if (row === CYLStylesRow.animated) {
      return cylDemoText(this.context, 'styles.animated');
    } else if (row === CYLStylesRow.toggleCancel) {
      return toggle(this.showsCancel, 'styles.cancel');
    } else if (row === CYLStylesRow.toggleLeading) {
      return toggle(this.showsLeading, 'styles.leading');
    }
    return toggle(this.showsTrailing, 'styles.trailing');
  }

  private select(row: CYLStylesRow): void {
    const bar: CYLSearchBarView = this.table.searchBarView;
    if (row === CYLStylesRow.changePlaceholder) {
      bar.placeholder = cylDemoText(this.context, 'styles.longPlaceholder');
    } else if (row === CYLStylesRow.adjustField) {
      bar.textFieldMarginsProvider = (_: CYLSearchBarView, active: boolean): CYLSearchEdgeInsets => {
        const insets: CYLSearchEdgeInsets = active ? { top: 0, left: 0, bottom: 0, right: 0 } :
          { top: 0, left: 32, bottom: 0, right: 32 };
        return insets;
      };
    } else if (row === CYLStylesRow.adjustCancel) {
      bar.cancelButtonMarginsProvider = (_: CYLSearchBarView, active: boolean): CYLSearchEdgeInsets => {
        const insets: CYLSearchEdgeInsets = active ? { top: 0, left: -16, bottom: 0, right: 0 } :
          { top: 0, left: 0, bottom: 0, right: 0 };
        return insets;
      };
      if (!bar.isActive) {
        bar.becomeFirstResponder();
      }
    } else if (row === CYLStylesRow.toggleCancel) {
      this.showsCancel = !this.showsCancel;
      bar.setShowsCancelButton(this.showsCancel, this.animated);
    } else if (row === CYLStylesRow.toggleLeading) {
      this.showsLeading = !this.showsLeading;
      bar.setShowsLeadingView(this.showsLeading, this.animated);
    } else if (row === CYLStylesRow.toggleTrailing) {
      this.showsTrailing = !this.showsTrailing;
      bar.setShowsTrailingAccessoryViews(this.showsTrailing, this.animated);
    }
  }

  @Builder
  sectionHeader(key: string) {
    Text(cylDemoText(this.context, key))
      .fontSize(13)
      .fontColor($r('sys.color.font_secondary'))
      .width('100%')
      .padding({ left: 32, right: 32, top: 18, bottom: 6 })
      .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  rows() {
    ForEach(this.sections, (section: CYLStylesRow[], sectionIndex: number) => {
      ListItemGroup({ header: this.sectionHeader(this.sectionKeys[sectionIndex]) }) {
        ForEach(section, (row: CYLStylesRow) => {
          ListItem() {
            Row() {
              Text(this.title(row))
                .fontSize(17)
                .fontColor($r('sys.color.font_primary'))
                .layoutWeight(1)
              if (row === CYLStylesRow.centerPlaceholder || row === CYLStylesRow.animated) {
                Toggle({ type: ToggleType.Switch,
                  isOn: row === CYLStylesRow.animated ? this.animated : this.centersPlaceholder })
                  .accessibilityText(this.title(row))
                  .onChange((isOn: boolean) => {
                    if (row === CYLStylesRow.animated) {
                      this.animated = isOn;
                    } else {
                      this.centersPlaceholder = isOn;
                      this.table.searchBarView.centersPlaceholder = isOn;
                    }
                  })
              }
            }
            .width('100%')
            .constraintSize({ minHeight: 44 })
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor($r('sys.color.background_primary'))
          }
          .margin({ left: 16, right: 16 })
          .accessibilityGroup(true)
          .accessibilityText(this.title(row))
          .accessibilityDescription(cylDemoText(this.context, 'styles.row.hint'))
          .id(`CYLSearchBarStylesRow${row}`)
          .onClick(() => {
            this.select(row);
          })
        }, (row: CYLStylesRow) => `${row}`)
      }
      .divider({ strokeWidth: 0.5, color: $r('sys.color.comp_divider'), startMargin: 32, endMargin: 16 })
    }, (section: CYLStylesRow[], sectionIndex: number) => `${sectionIndex}`)
  }

  build() {
    Column() {
      CYLDemoNavBar({
        title: cylDemoText(this.context, 'demo.searchBarStyles'),
        showsBack: this.showsBack,
        barColor: $r('sys.color.background_secondary'),
        onBack: () => this.onBack()
      })
      CYLSearchTableComponent({ searchTable: this.table, rows: () => {
          this.rows();
        } })
        .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
  }
}

/**
 * The Search bar styles page pushed from the Examples menu.
 */
@ComponentV2
export struct SearchBarStylesPage {
  @Require @Param stack: NavPathStack;

  build() {
    NavDestination() {
      SearchBarStylesView({ showsBack: true, onBack: () => this.stack.pop() })
    }
    .hideTitleBar(true)
  }
}

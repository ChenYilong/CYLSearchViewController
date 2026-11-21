import { common } from '@kit.AbilityKit';
import { LengthMetrics } from '@kit.ArkUI';
import {
  CYLSearchBarAppearance,
  CYLSearchBarNavigationIcon,
  CYLSearchBarView,
  CYLSearchComponent,
  CYLSearchEdgeInsets,
  CYLSearchResources,
  CYLSearchSuggestionCachePolicy,
  CYLSearchTableComponent,
  CYLSearchTableView,
  CYLSearchView,
  CYLSearchViewDataSource,
  CYLSearchViewDelegate
} from 'cylsearch';
import { CYLDemoNavBar, cylDemoText, cylFormat } from '../common/DemoCommon';

/**
 * The keywords of QMUI's `QDSearchViewController` (iOS `CYLSearchControllerDemoViewController.keywords`).
 */
const CYL_KEYWORDS: string[] = ['Helps', 'Maintain', 'Liver', 'Health', 'Function', 'Supports', 'Healthy', 'Fat',
  'Metabolism', 'Nuturally'];

/**
 * The suggestions of the launch view while there is no history (iOS `CYLRecentSearchLaunchView.suggestions`).
 */
const CYL_LAUNCH_SUGGESTIONS: string[] = ['Helps', 'Maintain', 'Liver', 'Health', 'Function', 'Supports', 'Healthy',
  'Fat'];

/**
 * Each matching keyword appears this many times in the results (QMUI's demo shows 20 rows per match).
 */
const CYL_RESULT_REPEAT: number = 20;

/**
 * A piece of a result: the text and whether it is the match.
 */
class CYLResultPart {
  text: string;
  matches: boolean;

  constructor(text: string, matches: boolean) {
    this.text = text;
    this.matches = matches;
  }
}

/**
 * Splits `keyword` around the first (case-sensitive) occurrence of `search`, as iOS's `range(of:)` does; one piece
 * without a match when `search` is empty or not found.
 */
function cylSplitMatch(keyword: string, search: string): CYLResultPart[] {
  const index = search.length === 0 ? -1 : keyword.indexOf(search);
  if (index < 0) {
    return [new CYLResultPart(keyword, false)];
  }
  const parts: CYLResultPart[] = [];
  if (index > 0) {
    parts.push(new CYLResultPart(keyword.substring(0, index), false));
  }
  parts.push(new CYLResultPart(search, true));
  if (index + search.length < keyword.length) {
    parts.push(new CYLResultPart(keyword.substring(index + search.length), false));
  }
  return parts;
}

/**
 * A result row: the keyword with the match in the tint color (iOS `cellForRowAt` of the results table).
 */
@Builder
function cylHighlightedResult(searchView: CYLSearchView, result: Object, index: number) {
  Text() {
    ForEach(cylSplitMatch(result as string, searchView.query), (part: CYLResultPart, partIndex: number) => {
      Span(part.text)
        .fontColor(part.matches ? $r('sys.color.brand') : $r('sys.color.font_primary'))
    }, (part: CYLResultPart, partIndex: number) => `${partIndex}`)
  }
  .fontSize(17)
  .width('100%')
  .constraintSize({ minHeight: 44 })
  .padding({ left: 16, right: 16, top: 8, bottom: 8 })
}

/**
 * The launch view: the recent searches under the bar while the query is empty (iOS `CYLRecentSearchLaunchView`): a
 * title with a bottom border and a clear button, then the history as tags (the 8 suggestions while there is none). It
 * reads the history again each time the search view reports a submitted query (`historyRevision`).
 */
@ComponentV2
struct CYLRecentSearchLaunchView {
  @Require @Param searchView: CYLSearchView;
  private context: common.Context = this.getUIContext().getHostContext() as common.Context;

  private history(): string[] {
    // Reading the revision makes this view read the store again after every submitted query.
    if (this.searchView.historyRevision < 0) {
      return [];
    }
    return this.searchView.historyStore?.cachedQueries() ?? [];
  }

  private queries(): string[] {
    const history = this.history();
    return history.length === 0 ? CYL_LAUNCH_SUGGESTIONS : history;
  }

  build() {
    Column() {
      Row() {
        Text(cylDemoText(this.context, 'controller.recent'))
          .fontSize(14)
          .fontColor($r('sys.color.font_primary'))
          .layoutWeight(1)
          .accessibilityRole(AccessibilityRoleType.TITLE_BAR)
        if (this.history().length > 0) {
          Row() {
            SymbolGlyph($r('sys.symbol.trash'))
              .fontSize(20)
              .fontColor([$r('sys.color.font_secondary')])
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .accessibilityGroup(true)
          .accessibilityText($r('app.string.cyl_search_clearRecent'))
          .id('CYLRecentSearchClearButton')
          .onClick(() => {
            this.searchView.clearSuggestionCache();
          })
        }
      }
      .width('100%')
      .padding({ bottom: 8 })
      Divider()
        .strokeWidth(0.5)
        .color($r('sys.color.comp_divider'))
        .margin({ bottom: 20 })
      Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(10), cross: LengthMetrics.vp(10) } }) {
        ForEach(this.queries(), (query: string) => {
          Text(query)
            .fontSize(14)
            .fontColor($r('sys.color.brand'))
            .height(29)
            .constraintSize({ minWidth: 69 })
            .padding({ left: 10, right: 10 })
            .textAlign(TextAlign.Center)
            .border({ width: 1, color: $r('sys.color.brand'), radius: 4 })
            .accessibilityText(query)
            .onClick(() => {
              this.searchView.setQuery(query, true);
            })
        }, (query: string) => query)
      }
      .width('100%')
      .accessibilityDescription(cylDemoText(this.context, 'controller.launch.label'))
    }
    .width('100%')
    .height('100%')
    .padding(26)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('sys.color.background_primary'))
    .id('CYLRecentSearchLaunchView')
  }
}

@Builder
function cylLaunchViewBuilder(searchView: CYLSearchView) {
  CYLRecentSearchLaunchView({ searchView: searchView })
}

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
    search.suggestionCachePolicy = CYLSearchSuggestionCachePolicy.userDefaults;
    search.suggestionCacheName = 'CYLSearchControllerDemo';
    search.closesOnSubmit = false;
    search.showsSuggestionCacheHeader = false;
    search.searchBarView.appearanceStyle = CYLSearchBarAppearance.defaultAppearance;
    search.searchBarView.navigationIcon = CYLSearchBarNavigationIcon.none;
    search.searchBarView.showsCancelButton = true;
    search.searchBarView.clearsTextOnCancel = true;
    search.resultsDataSource = new CYLKeywordResults();
    search.resultCellConfiguration = wrapBuilder(cylHighlightedResult);
    search.launchView = wrapBuilder(cylLaunchViewBuilder);
    const delegate: CYLSearchViewDelegate = {
      searchViewUpdateResults: (view: CYLSearchView, _: string) => {
        if (view.searchResults.length === 0) {
          view.showEmptyView(cylDemoText(this.context, 'controller.noResults'));
        } else {
          view.hideEmptyView();
        }
      }
    };
    search.delegate = delegate;
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
    bar.leadingAccessoryView = wrapBuilder(cylLeadingAccessory);
    bar.trailingAccessoryView = wrapBuilder(cylTrailingAccessory);
    bar.leadingAccessoryViewMargins = { top: 0, left: 8, bottom: 0, right: 0 };
    bar.trailingAccessoryViewMargins = { top: 0, left: 0, bottom: 0, right: 8 };
    bar.showsLeadingAccessoryView = false;
    bar.showsTrailingAccessoryView = false;
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
      bar.setShowsLeadingAccessoryView(this.showsLeading, this.animated);
    } else if (row === CYLStylesRow.toggleTrailing) {
      this.showsTrailing = !this.showsTrailing;
      bar.setShowsTrailingAccessoryView(this.showsTrailing, this.animated);
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

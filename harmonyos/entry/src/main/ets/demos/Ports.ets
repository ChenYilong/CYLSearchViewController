import { common } from '@kit.AbilityKit';
import { display } from '@kit.ArkUI';
import {
  CYLSearchBarComponent,
  CYLSearchBarExpansionAnimation,
  CYLSearchBarIconPosition,
  CYLSearchBarMode,
  CYLSearchBarNavigationIcon,
  CYLSearchBarView,
  CYLSearchComponent,
  CYLSearchView
} from 'cylsearch';
import { CYLDemoNavBar, cylDemoText, CYLSnackbar, CYLSnackbarView, CYL_PLUS_OVERHANG } from '../common/DemoCommon';

/**
 * The filtered list shown inside the lapism search view (the README's adapter); a global builder draws it as the
 * search view's `contentView`.
 */
@ObservedV2
class CYLLapismModel {
  @Trace filteredItems: string[] = [];
}

const lapismModel: CYLLapismModel = new CYLLapismModel();

@ComponentV2
struct CYLLapismResults {
  @Require @Param model: CYLLapismModel;

  build() {
    List() {
      ForEach(this.model.filteredItems, (item: string) => {
        ListItem() {
          Text(item).fontSize(17).width('100%').constraintSize({ minHeight: 44 }).padding({ left: 16, right: 16 })
        }
      }, (item: string) => item)
    }
    .contentEndOffset(CYL_PLUS_OVERHANG)
    .width('100%')
    .height('100%')
    .divider({ strokeWidth: 0.5, color: $r('sys.color.comp_divider'), startMargin: 16 })
  }
}

@Builder
function lapismResults() {
  CYLLapismResults({ model: lapismModel })
}

/**
 * Port of lapism/search's README usage (iOS `CYLLapismSearchViewController`): a `MaterialSearchBar` (magnifier
 * navigation icon, hint, taps open the search) over a list, and a `MaterialSearchView` (arrow navigation icon, a
 * filtered list added as its content, query and focus listeners).
 */
@ComponentV2
export struct LapismPage {
  @Require @Param stack: NavPathStack;
  private context: common.Context = this.getUIContext().getHostContext() as common.Context;
  private items: string[] = [];
  private searchBar: CYLSearchBarView = new CYLSearchBarView();
  private searchView: CYLSearchView = new CYLSearchView();

  aboutToAppear(): void {
    for (let i = 1; i <= 40; i++) {
      this.items.push(cylDemoText(this.context, 'demo.port.item', i));
    }
    lapismModel.filteredItems = this.items;
    // MaterialSearchBar: navigationIconCompat = SEARCH, setHint, setOnClickListener / setNavigationOnClickListener.
    this.searchBar.navigationIcon = CYLSearchBarNavigationIcon.search;
    this.searchBar.searchIcon = undefined;
    this.searchBar.placeholder = cylDemoText(this.context, 'search.field');
    this.searchBar.fieldCornerRadius = -1;
    this.searchBar.fieldShadowOpacity = 0.15;
    this.searchBar.fieldBackgroundColor = $r('sys.color.background_secondary');
    this.searchBar.navigationHandler = () => this.searchView.showSearch();
    this.searchBar.delegate = {
      searchBarViewShouldBeginEditing: () => false,
      searchBarViewDidTapWhileNotEditable: () => this.searchView.showSearch()
    };
    // MaterialSearchView: addView(recyclerView), navigationIconCompat = ARROW, setHint, listeners.
    this.searchView.installInView(this.context);
    this.searchView.contentView = wrapBuilder(lapismResults);
    this.searchView.searchBarView.navigationIcon = CYLSearchBarNavigationIcon.arrow;
    this.searchView.searchBarView.searchIcon = undefined;
    this.searchView.searchBarView.placeholder = cylDemoText(this.context, 'search.field');
    this.searchView.delegate = {
      searchViewTextDidChange: (_: CYLSearchView, text: string) => {
        const lower = text.toLocaleLowerCase();
        lapismModel.filteredItems = text.length === 0 ? this.items :
        this.items.filter((item: string) => item.toLocaleLowerCase().includes(lower));
      },
      searchViewDidSubmitText: () => true,
      searchViewDidChangeFocus: (view: CYLSearchView) => {
        this.searchBar.text = view.query;
      }
    };
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          CYLDemoNavBar({ title: 'lapism/search', showsBack: true, onBack: () => this.stack.pop() })
          CYLSearchBarComponent({ searchBarView: this.searchBar })
          List() {
            ForEach(this.items, (item: string) => {
              ListItem() {
                Text(item).fontSize(17).width('100%').constraintSize({ minHeight: 44 }).padding({ left: 16, right: 16 })
              }
            }, (item: string) => item)
          }
          .contentEndOffset(CYL_PLUS_OVERHANG)
          .layoutWeight(1)
          .divider({ strokeWidth: 0.5, color: $r('sys.color.comp_divider'), startMargin: 16 })
        }
        .width('100%')
        .height('100%')
        CYLSearchComponent({ searchView: this.searchView })
      }
      .backgroundColor($r('sys.color.background_primary'))
    }
    .hideTitleBar(true)
    .onBackPressed(() => this.searchView.handleBackPress())
  }
}

/**
 * Port of yechaoa/MaterialDesign's `SearchViewActivity` (iOS `CYLYechaoaSearchViewController`): an iconified search
 * view in the toolbar with a submit button, the Search return key, a hint and custom colors; a submitted query shows a
 * snackbar and a search result, and clearing the text hides the result again.
 */
@ComponentV2
export struct YechaoaPage {
  @Require @Param stack: NavPathStack;
  @Local showsResult: boolean = false;
  @Local barWidth: number = 44;
  private context: common.Context = this.getUIContext().getHostContext() as common.Context;
  private searchBar: CYLSearchBarView = new CYLSearchBarView();
  private snackbar: CYLSnackbar = new CYLSnackbar();

  aboutToAppear(): void {
    // setIconifiedByDefault(true), isSubmitButtonEnabled, imeOptions, isIconified, queryHint, text colors.
    this.searchBar.contentInsets = { top: 0, left: 0, bottom: 0, right: 0 };
    this.searchBar.iconifiedByDefault = true;
    this.searchBar.showsSubmitButton = true;
    this.searchBar.returnKeyType = EnterKeyType.Search;
    this.searchBar.placeholder = cylDemoText(this.context, 'demo.port.keyword');
    this.searchBar.placeholderColor = '#DCDCDC';
    this.searchBar.textColor = $r('sys.color.font_primary');
    this.searchBar.delegate = {
      searchBarViewSearchButtonClicked: (bar: CYLSearchBarView) => {
        this.snackbar.show(cylDemoText(this.context, 'demo.port.searched', bar.text));
        this.showsResult = true;
      },
      searchBarViewTextDidChange: (_: CYLSearchBarView, text: string) => {
        if (text.length === 0) {
          this.showsResult = false;
        }
      },
      // The opened field takes the room of the title, like an expanded SearchView in the toolbar.
      searchBarViewDidChangeIconified: (_: CYLSearchBarView, iconified: boolean) => {
        const width = this.getUIContext().px2vp(display.getDefaultDisplaySync().width);
        this.barWidth = iconified ? 44 : Math.max(200, width - 120);
      }
    };
    this.searchBar.setIconified(true, false);
  }

  @Builder
  searchItem() {
    CYLSearchBarComponent({ searchBarView: this.searchBar })
      .width(this.barWidth)
      .height(44)
      .margin({ right: 8 })
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          CYLDemoNavBar({
            title: this.barWidth > 44 ? '' : 'SearchView',
            showsBack: true,
            hasRightView: true,
            rightView: () => {
              this.searchItem()
            },
            onBack: () => this.stack.pop()
          })
          Stack() {
            if (this.showsResult) {
              Text(cylDemoText(this.context, 'demo.port.result')).fontSize(22)
            }
          }
          .layoutWeight(1)
          .width('100%')
        }
        .width('100%')
        .height('100%')
        CYLSnackbarView({ snackbar: this.snackbar })
      }
      .backgroundColor($r('sys.color.background_primary'))
    }
    .hideTitleBar(true)
  }
}

/**
 * Port of android-cjj/MaterialSearchView's sample (iOS `CYLRevealSearchViewController`): on the primary color, a round
 * search button opens a light search card with a one-second circular reveal; the magnifier in the card closes it.
 */
@ComponentV2
export struct RevealPage {
  @Require @Param stack: NavPathStack;
  private context: common.Context = this.getUIContext().getHostContext() as common.Context;
  private searchBar: CYLSearchBarView = new CYLSearchBarView();

  aboutToAppear(): void {
    // CardView: background #f2f2f2, corner radius 2; EditText: hint "search", text color #ffd46c, single line.
    this.searchBar.fieldBackgroundColor = '#F2F2F2';
    this.searchBar.fieldCornerRadius = 2;
    this.searchBar.fieldHeight = 60;
    this.searchBar.fieldShadowOpacity = 0.2;
    this.searchBar.placeholder = 'search';
    this.searchBar.textColor = '#FFD46C';
    this.searchBar.searchIcon = undefined;
    // The floating action button and the reveal (ViewAnimationUtils.createCircularReveal, 1000 ms).
    this.searchBar.expansionAnimation = CYLSearchBarExpansionAnimation.circularReveal;
    this.searchBar.animationDuration = 1;
    this.searchBar.iconButtonBackgroundColor = Color.White;
    this.searchBar.iconButtonTintColor = $r('app.color.system_indigo');
    this.searchBar.iconPosition = CYLSearchBarIconPosition.center;
    this.searchBar.iconifiedByDefault = true;
  }

  @Builder
  close() {
    SymbolGlyph($r('sys.symbol.magnifyingglass'))
      .fontSize(20)
      .fontColor([$r('sys.color.font_secondary')])
      .accessibilityText(cylDemoText(this.context, 'search.field'))
      .onClick(() => this.searchBar.setIconified(true, true))
  }

  build() {
    NavDestination() {
      Column() {
        CYLDemoNavBar({
          title: 'MaterialSearchView (cjj)',
          showsBack: true,
          barColor: $r('app.color.system_indigo'),
          tint: Color.White,
          titleColor: Color.White,
          onBack: () => this.stack.pop()
        })
        Column() {
          CYLSearchBarComponent({ searchBarView: this.searchBar, trailingAccessoryViews: () => {
            this.close()
          } })
            .padding({ left: 4, right: 4 })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.system_indigo'))
    }
    .hideTitleBar(true)
  }
}

/**
 * Port of iammert/MultiSearchView's sample `MainActivity` (iOS `CYLMultiSearchDemoViewController`): a search bar in
 * `multiple` mode styled like the README's `SearchTextStyle` (hint "Search", 18 vp text, at most 15 characters, the Search key,
 * gray hint, primary text), 16 vp from the top, with every event logged (the sample's `Log.v`).
 */
@ComponentV2
export struct MultiSearchDemoPage {
  @Require @Param stack: NavPathStack;
  @Local log: string = '';
  private context: common.Context = this.getUIContext().getHostContext() as common.Context;
  private searchBar: CYLSearchBarView = new CYLSearchBarView();

  aboutToAppear(): void {
    this.searchBar.mode = CYLSearchBarMode.multiple;
    this.searchBar.placeholder = cylDemoText(this.context, 'search.field');
    this.searchBar.font = 18;
    this.searchBar.maximumTextLength = 15;
    this.searchBar.returnKeyType = EnterKeyType.Search;
    this.searchBar.placeholderColor = 'rgba(153, 153, 153, 0.5)';
    this.searchBar.textColor = $r('sys.color.font_primary');
    this.searchBar.delegate = {
      searchBarViewDidSelectSearch: (_: CYLSearchBarView, text: string, index: number) =>
      this.append(`onItemSelected: index: ${index}, query: ${text}`),
      searchBarViewTextDidChangeAt: (_: CYLSearchBarView, text: string, index: number) =>
      this.append(`changed: index: ${index}, query: ${text}`),
      searchBarViewDidCompleteSearch: (_: CYLSearchBarView, text: string, index: number) =>
      this.append(`complete: index: ${index}, query: ${text}`),
      searchBarViewDidRemoveSearchAt: (_: CYLSearchBarView, index: number) => this.append(`remove: index: ${index}`)
    };
  }

  private append(line: string): void {
    this.log = line + '\n' + this.log;
  }

  build() {
    NavDestination() {
      Column() {
        CYLDemoNavBar({ title: 'MultiSearchView', showsBack: true, onBack: () => this.stack.pop() })
        CYLSearchBarComponent({ searchBarView: this.searchBar })
          .margin({ left: 8, right: 8, top: 16 })
        Scroll() {
          Text(this.log)
            .fontSize(13)
            .fontFamily('monospace')
            .width('100%')
            .accessibilityText(cylDemoText(this.context, 'demo.port.events'))
        }
        .layoutWeight(1)
        .align(Alignment.TopStart)
        .padding({ left: 16, right: 16, top: 16, bottom: CYL_PLUS_OVERHANG })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.background_primary'))
    }
    .hideTitleBar(true)
    .onBackPressed(() => this.searchBar.handleBackPress())
  }
}

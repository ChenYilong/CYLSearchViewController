import { common } from '@kit.AbilityKit';
import { cylAppText, CYLDemoRoute, CYLMaterialSampleParam, CYLPlaceholderDetailParam } from '../common/DemoCommon';
import { SearchExamplePage, SearchExampleView } from '../demos/SearchExample';
import { ExamplesMenuView, PlaceholderDetailPage, PlaceholderGalleryPage } from '../demos/ExamplesMenu';
import { PortsMenuPage, SearchBarDemoPage, SearchBarDemoView } from '../demos/SearchBarDemo';
import { MaterialMenuPage, MaterialMenuView, MaterialSamplePage } from '../demos/MaterialSearch';
import { LapismPage, MultiSearchDemoPage, RevealPage, YechaoaPage } from '../demos/Ports';
import { DiscoverView } from '../demos/Discover';

interface CYLTabItem {
  title: string;
  symbol: Resource;
  selectedSymbol: Resource;
}

/**
 * The example app (iOS `CYLSearchExampleAppDelegate` with CYLTabBarConfiguration.json): CYLTabBarController's tab bar
 * with Search, Examples, the plus button (Search bar), Tag style and Discover; each tab keeps its own navigation
 * stack. CYLTabBarController has no HarmonyOS library yet, so the example draws the same tab bar with ArkUI `Tabs`.
 */
@Entry
@ComponentV2
struct Index {
  @Local selected: number = 0;
  private context: common.Context = this.getUIContext().getHostContext() as common.Context;
  private stacks: NavPathStack[] = [new NavPathStack(), new NavPathStack(), new NavPathStack(), new NavPathStack(),
    new NavPathStack()];
  private tabs: CYLTabItem[] = [
    { title: 'tab_search', symbol: $r('sys.symbol.magnifyingglass'), selectedSymbol: $r('sys.symbol.magnifyingglass') },
    { title: 'tab_examples', symbol: $r('sys.symbol.list_bullet'), selectedSymbol: $r('sys.symbol.list_bullet') },
    { title: 'tab_searchBar', symbol: $r('sys.symbol.plus_circle_fill'), selectedSymbol: $r('sys.symbol.plus_circle_fill') },
    { title: 'tab_tagStyle', symbol: $r('sys.symbol.bookmark'), selectedSymbol: $r('sys.symbol.bookmark_fill') },
    { title: 'tab_discover', symbol: $r('sys.symbol.star'), selectedSymbol: $r('sys.symbol.star_fill') }
  ];

  aboutToAppear(): void {
    // `aa start ... --pi CYLDemoTab 1` selects that tab, for screenshots (iOS `-CYLDemoTab 1`).
    const tab = AppStorage.get<number>('CYLDemoTab');
    if (tab !== undefined && tab >= 0 && tab < this.tabs.length) {
      this.selected = tab;
    }
  }

  @Builder
  route(name: string, param: Object) {
    if (name === CYLDemoRoute.reproduction) {
      SearchExamplePage({ stack: this.stacks[this.selected] })
    } else if (name === CYLDemoRoute.styles) {
      PlaceholderGalleryPage({ stack: this.stacks[this.selected] })
    } else if (name === CYLDemoRoute.placeholderDetail) {
      PlaceholderDetailPage({ stack: this.stacks[this.selected], param: param as CYLPlaceholderDetailParam })
    } else if (name === CYLDemoRoute.searchBar) {
      SearchBarDemoPage({ stack: this.stacks[this.selected] })
    } else if (name === CYLDemoRoute.ports) {
      PortsMenuPage({ stack: this.stacks[this.selected] })
    } else if (name === CYLDemoRoute.materialMenu) {
      MaterialMenuPage({ stack: this.stacks[this.selected] })
    } else if (name === CYLDemoRoute.materialSample) {
      MaterialSamplePage({ stack: this.stacks[this.selected], param: param as CYLMaterialSampleParam })
    } else if (name === CYLDemoRoute.lapism) {
      LapismPage({ stack: this.stacks[this.selected] })
    } else if (name === CYLDemoRoute.yechaoa) {
      YechaoaPage({ stack: this.stacks[this.selected] })
    } else if (name === CYLDemoRoute.reveal) {
      RevealPage({ stack: this.stacks[this.selected] })
    } else if (name === CYLDemoRoute.multiSearch) {
      MultiSearchDemoPage({ stack: this.stacks[this.selected] })
    }
  }

  @Builder
  tabBarItem(index: number) {
    Column({ space: 2 }) {
      SymbolGlyph(this.selected === index ? this.tabs[index].selectedSymbol : this.tabs[index].symbol)
        .fontSize(index === 2 ? 34 : 24)
        .fontColor([this.selected === index ? $r('sys.color.brand') : $r('sys.color.font_secondary')])
      Text(cylAppText(this.context, this.tabs[index].title))
        .fontSize(10)
        .fontColor(this.selected === index ? $r('sys.color.brand') : $r('sys.color.font_secondary'))
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 2 })
    .id(`CYLTab${index}`)
    .accessibilityText(cylAppText(this.context, this.tabs[index].title))
  }

  @Builder
  tabContent(index: number) {
    if (index === 0) {
      SearchExampleView()
    } else if (index === 1) {
      ExamplesMenuView({ stack: this.stacks[1] })
    } else if (index === 2) {
      SearchBarDemoView()
    } else if (index === 3) {
      MaterialMenuView({ stack: this.stacks[3], tags: true })
    } else {
      DiscoverView()
    }
  }

  build() {
    Tabs({ barPosition: BarPosition.End, index: this.selected }) {
      ForEach(this.tabs, (_: CYLTabItem, index: number) => {
        TabContent() {
          Navigation(this.stacks[index]) {
            this.tabContent(index)
          }
          .hideTitleBar(true)
          .hideToolBar(true)
          .mode(NavigationMode.Stack)
          .navDestination(this.route)
        }
        .tabBar(this.tabBarItem(index))
      }, (item: CYLTabItem) => item.title)
    }
    .barHeight(56)
    .scrollable(false)
    .animationDuration(0)
    .barBackgroundColor($r('sys.color.background_primary'))
    .divider({ strokeWidth: 0.5, color: $r('sys.color.comp_divider') })
    .onChange((index: number) => {
      this.selected = index;
    })
  }

  // The system Back gesture: a search page closes first (each page handles it), then the tab's stack pops.
  onBackPress(): boolean {
    const stack = this.stacks[this.selected];
    if (stack.size() > 0) {
      stack.pop();
      return true;
    }
    return false;
  }
}

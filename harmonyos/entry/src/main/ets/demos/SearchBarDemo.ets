import { common } from '@kit.AbilityKit';
import { CYLSearchBarComponent, CYLSearchBarView } from 'cylsearch';
import { CYLDemoCell, CYLDemoNavBar, cylDemoText, CYLDemoRoute, CYL_PLUS_OVERHANG } from '../common/DemoCommon';

/**
 * The Search bar page (iOS `CYLSearchBarDemoViewController`), the plus button's page and a row of the Examples menu:
 * a `CYLSearchBarView` with Cancel, a soft shadow and a camera button inside the field; the label shows the text as
 * it is typed and the submitted query.
 */
@ComponentV2
export struct SearchBarDemoView {
  @Param showsBack: boolean = false;
  @Event onBack: () => void = () => {
  };
  @Local status: string = '';
  private context: common.Context = this.getUIContext().getHostContext() as common.Context;
  private bar: CYLSearchBarView = new CYLSearchBarView();

  aboutToAppear(): void {
    this.bar.placeholder = cylDemoText(this.context, 'demo.searchBar.placeholder');
    this.bar.showsCancelButton = true;
    this.bar.cancelButtonTitle = cylDemoText(this.context, 'search.cancel');
    this.bar.fieldShadowOpacity = 0.12;
    this.showText('');
    this.bar.delegate = {
      searchBarViewTextDidChange: (_: CYLSearchBarView, text: string) => this.showText(text),
      searchBarViewSearchButtonClicked: (bar: CYLSearchBarView) => {
        this.status = cylDemoText(this.context, 'demo.searchBar.searched', bar.text);
      },
      searchBarViewCancelButtonClicked: (bar: CYLSearchBarView) => {
        bar.text = '';
        this.showText('');
      }
    };
  }

  private showText(text: string): void {
    this.status = cylDemoText(this.context, 'demo.searchBar.text', text);
  }

  @Builder
  camera() {
    SymbolGlyph($r('sys.symbol.camera'))
      .fontSize(20)
      .fontColor([$r('sys.color.brand')])
      .accessibilityText(cylDemoText(this.context, 'demo.searchBar.camera'))
  }

  build() {
    Column() {
      CYLDemoNavBar({ title: cylDemoText(this.context, 'demo.searchBar'), showsBack: this.showsBack, onBack: () => this.onBack() })
      CYLSearchBarComponent({ searchBarView: this.bar, trailingAccessoryViews: () => {
        this.camera()
      } })
      Text(this.status)
        .fontSize(17)
        .fontColor($r('sys.color.font_secondary'))
        .width('100%')
        .padding({ left: 16, right: 16, top: 16 })
        .id('CYLSearchBarDemoStatus')
      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_primary'))
  }
}

/**
 * The Search bar page pushed from the Examples menu.
 */
@ComponentV2
export struct SearchBarDemoPage {
  @Require @Param stack: NavPathStack;

  build() {
    NavDestination() {
      SearchBarDemoView({ showsBack: true, onBack: () => this.stack.pop() })
    }
    .hideTitleBar(true)
  }
}

interface CYLPortRow {
  title: string;
  subtitle: string;
  route: string;
}

/**
 * The ports of the examples of five search libraries (iOS `CYLSearchPortsViewController`).
 */
@ComponentV2
export struct PortsMenuPage {
  @Require @Param stack: NavPathStack;
  private context: common.Context = this.getUIContext().getHostContext() as common.Context;
  private rows: CYLPortRow[] = [
    { title: 'lapism/search', subtitle: 'MaterialSearchBar + MaterialSearchView', route: CYLDemoRoute.lapism },
    { title: 'MiguelCatalan/MaterialSearchView', subtitle: 'Default, Themed, Voice, Sticky, Tabs, Input type',
      route: CYLDemoRoute.materialMenu },
    { title: 'yechaoa/MaterialDesign', subtitle: 'SearchViewActivity', route: CYLDemoRoute.yechaoa },
    { title: 'android-cjj/MaterialSearchView', subtitle: 'Circular reveal', route: CYLDemoRoute.reveal },
    { title: 'iammert/MultiSearchView', subtitle: 'MultiSearchView', route: CYLDemoRoute.multiSearch }
  ];

  build() {
    NavDestination() {
      Column() {
        CYLDemoNavBar({
          title: cylDemoText(this.context, 'demo.ports'),
          showsBack: true,
          barColor: $r('sys.color.background_secondary'),
          onBack: () => this.stack.pop()
        })
        List() {
          ForEach(this.rows, (row: CYLPortRow, index: number) => {
            ListItem() {
              CYLDemoCell({ text: row.title, subtitle: row.subtitle, showsDivider: index < this.rows.length - 1 })
            }
            .accessibilityGroup(true)
            .accessibilityText(`${row.title}, ${row.subtitle}`)
            .onClick(() => this.stack.pushPath({ name: row.route }))
          }, (row: CYLPortRow) => row.title)
        }
        .contentEndOffset(CYL_PLUS_OVERHANG)
        .backgroundColor($r('sys.color.background_primary'))
        .borderRadius(10)
        .margin({ left: 16, right: 16, top: 20 })
        .height('auto')
        Blank()
      }
      .height('100%')
      .backgroundColor($r('sys.color.background_secondary'))
    }
    .hideTitleBar(true)
  }
}

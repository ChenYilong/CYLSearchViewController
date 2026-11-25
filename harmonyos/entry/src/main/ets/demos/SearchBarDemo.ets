import { common } from '@kit.AbilityKit';
import { CYLSearchBarComponent, CYLSearchBarPreset, CYLSearchBarView, CYLSearchNavigationTitleBar } from 'cylsearch';
import { cylFirstLevelBar } from './FirstLevel';
import { CYLDemoNavBar, cylDemoText, CYLDemoRoute, CYL_PLUS_OVERHANG } from '../common/DemoCommon';
import { CYLDemoTagMenuView, CYLDemoTagRow, CYLDemoTagSection } from '../common/DemoTagMenu';

/**
 * The Search bar page (iOS `CYLSearchBarDemoViewController`), the plus button's page and a row of the Examples menu:
 * a `CYLSearchBarView` with Cancel, a soft shadow and a camera button inside the field; the label shows the text as
 * it is typed and the submitted query.
 */
@ComponentV2
export struct SearchBarDemoView {
  // The stack of the plus tab: given when the view is the tab root, a first-level page (the whole outlined bar in the
  // navigation bar, a tap pushes the search page); the pushed Examples row has none.
  @Param stack: NavPathStack | undefined = undefined;
  @Param showsBack: boolean = false;
  @Event onBack: () => void = () => {
  };
  @Local status: string = '';
  private context: common.Context = this.getUIContext().getHostContext() as common.Context;
  private bar: CYLSearchBarView = new CYLSearchBarView();
  private firstLevelBar: CYLSearchBarView | undefined = undefined;

  aboutToAppear(): void {
    const stack = this.stack;
    if (stack !== undefined) {
      this.firstLevelBar = cylFirstLevelBar(CYLSearchBarPreset.outlined, cylDemoText(this.context, 'demo.searchBar.placeholder'),
        stack);
    }
    this.bar.placeholder = cylDemoText(this.context, 'demo.searchBar.placeholder');
    this.bar.showsCancelButton = true;
    this.bar.cancelButtonTitle = cylDemoText(this.context, 'search.cancel');
    this.bar.applyNavigationFieldStyle();
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
      if (this.firstLevelBar !== undefined) {
        CYLSearchNavigationTitleBar({ searchBarView: this.firstLevelBar, stack: this.stack })
      } else {
        CYLDemoNavBar({ title: cylDemoText(this.context, 'demo.searchBar'), showsBack: this.showsBack, onBack: () => this.onBack() })
        CYLSearchBarComponent({ searchBarView: this.bar, trailingAccessoryViews: () => {
          this.camera()
        } })
      }
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

  // One titled section, a glass tag per port with its subtitle (docs/instructions/example-demos.md).
  private tagSections(): CYLDemoTagSection[] {
    const tagRows: CYLDemoTagRow[] = this.rows.map((row: CYLPortRow): CYLDemoTagRow => {
      const tagRow: CYLDemoTagRow = { title: row.title, subtitle: row.subtitle, image: undefined };
      return tagRow;
    });
    return [new CYLDemoTagSection(cylDemoText(this.context, 'demo.ports'), tagRows)];
  }

  build() {
    NavDestination() {
      Column() {
        CYLDemoNavBar({
          title: cylDemoText(this.context, 'demo.ports'),
          showsBack: true,
          barColor: Color.Transparent,
          onBack: () => this.stack.pop()
        })
        Scroll() {
          CYLDemoTagMenuView({
            sections: this.tagSections(),
            tagId: 'CYLDemoPortsTags',
            onSelect: (section: number, item: number) => this.stack.pushPath({ name: this.rows[item].route })
          })
        }
        .margin({ bottom: CYL_PLUS_OVERHANG })
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .height('100%')
      // A gradient page (docs/instructions/example-demos.md rule 7); the tag list draws no background, so the glass sits on it.
      .linearGradient({ angle: 135, colors: [['#7FB7FF', 0.0], ['#FF9EC7', 0.5], ['#FFC27A', 1.0]] })
    }
    .hideTitleBar(true)
  }
}

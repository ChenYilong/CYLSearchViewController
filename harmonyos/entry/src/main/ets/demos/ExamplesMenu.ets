import { common } from '@kit.AbilityKit';
import {
  CYLSearchPlaceholderComponent,
  CYLSearchPlaceholderMessage,
  CYLSearchPlaceholderStyle,
  CYLSearchPlaceholderView
} from 'cylsearch';
import { CYLSVGAView } from 'cyltabbar';
import {
  cylAppText,
  CYLDemoCell,
  CYLDemoNavBar,
  cylDemoText,
  CYLDemoRoute,
  CYLPlaceholderDetailParam,
  cylSetTabIconSource,
  CYL_TAB_ICON_SOURCE_KEY
} from '../common/DemoCommon';

/**
 * The number of placeholder styles (iOS `CYLSearchPlaceholderStyleCount`).
 */
const STYLE_COUNT: number = 41;
const MESSAGE_KEYS: string[] = ['placeholder.empty', 'placeholder.search', 'placeholder.error', 'placeholder.network'];
const CUSTOM_KEYS: string[] = ['demo.custom.textOnly', 'demo.custom.imageOnly', 'demo.custom.both'];

/**
 * The Examples tab (iOS `CYLSearchDemoMenuViewController`): Search and refresh, Placeholder styles, Search bar, and
 * the other libraries' examples.
 */
@ComponentV2
export struct ExamplesMenuView {
  @Require @Param stack: NavPathStack;
  private context: common.Context = this.getUIContext().getHostContext() as common.Context;
  // The SVGA demo above the list (iOS `CYLSVGADemoHeaderView`): a tap plays it again.
  @Local svgaReplay: number = 0;
  // Where the tab icons come from (iOS `CYLDemoTabIconSource`): 0 symbols, 1 SVGA keys, 2 SVGA configuration file.
  @Local iconSource: number = AppStorage.get<number>(CYL_TAB_ICON_SOURCE_KEY) ?? 0;

  private sourceName(): string {
    const names: string[] = ['svga_source_symbols', 'svga_source_keys', 'svga_source_file'];
    return cylAppText(this.context, names[Math.max(0, Math.min(this.iconSource, 2))]);
  }

  // "Tab icons: …": the next source; the tab bar changes at once (pages/Index.ets watches it) and Examples stays selected.
  private switchSource(): void {
    this.iconSource = (this.iconSource + 1) % 3;
    cylSetTabIconSource(this.context, this.iconSource);
  }

  // As iOS `CYLSVGADemoHeaderView`: the 64 vp animation (tab_activity.svga, played once) and its label, the source button
  // below.
  @Builder
  svgaHeader() {
    Column() {
      Row({ space: 12 }) {
        CYLSVGAView({ path: 'svga/tab_activity.svga', iconSize: 64, selected: true, replayToken: this.svgaReplay })
          .width(64)
          .height(64)
        Text(cylAppText(this.context, 'svga_demo'))
          .fontSize(15)
          .fontColor($r('sys.color.font_primary'))
          .layoutWeight(1)
      }
      .width('100%')
      .height(64)
      .accessibilityGroup(true)
      .accessibilityText(cylAppText(this.context, 'svga_demo'))
      .accessibilityDescription(cylAppText(this.context, 'svga_demo_hint'))
      .id('CYLSVGADemoHeader')
      .onClick(() => {
        this.svgaReplay++;
      })
      Text(cylAppText(this.context, 'svga_source', this.sourceName()))
        .fontSize(17)
        .fontColor($r('sys.color.brand'))
        .width('100%')
        .constraintSize({ minHeight: 44 })
        .accessibilityDescription(cylAppText(this.context, 'svga_source_hint'))
        .id('CYLSVGADemoSourceButton')
        .onClick(() => this.switchSource())
    }
    .padding({ left: 16, right: 16, top: 12 })
    .width('100%')
  }
  private rows: string[] = ['demo.reproduction', 'demo.styles', 'demo.searchBar', 'demo.ports'];
  private routes: string[] = [CYLDemoRoute.reproduction, CYLDemoRoute.styles, CYLDemoRoute.searchBar, CYLDemoRoute.ports];

  build() {
    Column() {
      CYLDemoNavBar({ title: cylDemoText(this.context, 'demo.title'), barColor: $r('sys.color.background_secondary') })
      this.svgaHeader()
      List() {
        ForEach(this.rows, (key: string, index: number) => {
          ListItem() {
            CYLDemoCell({ text: cylDemoText(this.context, key), showsDivider: index < this.rows.length - 1 })
          }
          // Read as one element with its title as the label; UI tests find it by that label.
          .accessibilityGroup(true)
          .accessibilityText(cylDemoText(this.context, key))
          .id(`CYLDemoRow${index}`)
          .onClick(() => this.stack.pushPath({ name: this.routes[index] }))
        }, (key: string) => key)
      }
      .backgroundColor($r('sys.color.background_primary'))
      .borderRadius(10)
      .margin({ left: 16, right: 16, top: 20 })
      // As iOS's inset grouped list: the card ends after its last row (it shrinks and scrolls only when the rows do
      // not fit).
      .height('auto')
      .flexShrink(1)
      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
  }
}

/**
 * The placeholder of a row of the Placeholder styles page (iOS `-tableView:didSelectRowAtIndexPath:`).
 */
export function cylPlaceholderForRow(context: common.Context, section: number, row: number): CYLSearchPlaceholderView {
  if (section < STYLE_COUNT) {
    return CYLSearchPlaceholderView.withStyleMessage(section as CYLSearchPlaceholderStyle, row as CYLSearchPlaceholderMessage);
  }
  if (row === 0) {
    return CYLSearchPlaceholderView.withStyleText(CYLSearchPlaceholderStyle.noResults, cylDemoText(context, 'demo.custom.text'));
  }
  const heart = $r('sys.symbol.heart_fill');
  const placeholder = row === 1 ? CYLSearchPlaceholderView.withImageMessage(heart, CYLSearchPlaceholderMessage.network) :
    new CYLSearchPlaceholderView(heart, cylDemoText(context, 'demo.custom.text'));
  placeholder.imageTintColor = '#FF2D55';
  return placeholder;
}

/**
 * Placeholder styles (iOS `CYLSearchPlaceholderGalleryViewController`): one section per style, named after its image,
 * with its four messages; then the Custom section (built-in image with custom text, custom image with a built-in
 * message, both custom).
 */
@ComponentV2
export struct PlaceholderGalleryPage {
  @Require @Param stack: NavPathStack;
  private context: common.Context = this.getUIContext().getHostContext() as common.Context;
  private sections: number[] = Array.from<number, number>({ length: STYLE_COUNT + 1 }, (_: number, i: number) => i);

  private rowsOf(section: number): number[] {
    return section === STYLE_COUNT ? [0, 1, 2] : [0, 1, 2, 3];
  }

  private textOf(section: number, row: number): string {
    return cylDemoText(this.context, section === STYLE_COUNT ? CUSTOM_KEYS[row] : MESSAGE_KEYS[row]);
  }

  private imageOf(section: number, row: number): Resource {
    if (section === STYLE_COUNT) {
      return row === 0 ? CYLSearchPlaceholderView.imageForStyle(CYLSearchPlaceholderStyle.noResults) :
      $r('sys.symbol.heart_fill');
    }
    return CYLSearchPlaceholderView.imageForStyle(section as CYLSearchPlaceholderStyle);
  }

  @Builder
  sectionHeader(section: number) {
    Text(section === STYLE_COUNT ? cylDemoText(this.context, 'demo.custom') :
    CYLSearchPlaceholderView.imageNameForStyle(section as CYLSearchPlaceholderStyle))
      .fontSize(13)
      .fontColor($r('sys.color.font_secondary'))
      .width('100%')
      .padding({ left: 32, right: 32, top: 18, bottom: 6 })
      .backgroundColor($r('sys.color.background_secondary'))
  }

  build() {
    NavDestination() {
      Column() {
        CYLDemoNavBar({
          title: cylDemoText(this.context, 'demo.styles'),
          showsBack: true,
          barColor: $r('sys.color.background_secondary'),
          onBack: () => this.stack.pop()
        })
        List() {
          ForEach(this.sections, (section: number) => {
            ListItemGroup({ header: this.sectionHeader(section) }) {
              ForEach(this.rowsOf(section), (row: number) => {
                ListItem() {
                  CYLDemoCell({
                    text: this.textOf(section, row),
                    image: this.imageOf(section, row),
                    tintsImage: section !== CYLSearchPlaceholderStyle.empty,
                    showsDivider: row < this.rowsOf(section).length - 1
                  })
                }
                .backgroundColor($r('sys.color.background_primary'))
                .margin({ left: 16, right: 16 })
                .accessibilityGroup(true)
                .accessibilityText(this.textOf(section, row))
                .onClick(() => {
                  const param: CYLPlaceholderDetailParam = { title: this.textOf(section, row), section: section, row: row };
                  this.stack.pushPath({ name: CYLDemoRoute.placeholderDetail, param: param });
                })
              }, (row: number) => `${section}-${row}`)
            }
          }, (section: number) => `${section}`)
        }
        .layoutWeight(1)
        .cachedCount(4)
      }
      .backgroundColor($r('sys.color.background_secondary'))
    }
    .hideTitleBar(true)
  }
}

/**
 * The detail page of a row: one CYLSearchPlaceholderView filling the page.
 */
@ComponentV2
export struct PlaceholderDetailPage {
  @Require @Param stack: NavPathStack;
  @Require @Param param: CYLPlaceholderDetailParam;
  private context: common.Context = this.getUIContext().getHostContext() as common.Context;
  private placeholder: CYLSearchPlaceholderView | undefined = undefined;

  aboutToAppear(): void {
    this.placeholder = cylPlaceholderForRow(this.context, this.param.section, this.param.row);
  }

  build() {
    NavDestination() {
      Column() {
        CYLDemoNavBar({ title: this.param.title, showsBack: true, onBack: () => this.stack.pop() })
        if (this.placeholder !== undefined) {
          CYLSearchPlaceholderComponent({ placeholderView: this.placeholder }).layoutWeight(1)
        }
      }
      .backgroundColor($r('sys.color.background_primary'))
    }
    .hideTitleBar(true)
  }
}

import { common } from '@kit.AbilityKit';
import { CYLPlaceholderMessage, CYLPlaceholderStyle, CYLPlaceholderViewModel } from 'cylplaceholder';
import {
  CYLControlState, CYLEdgeInsets, CYLFont, CYLMenuStyle, CYLSize, CYLTagButton, CYLTagButtonHost, CYLTagContentAlignment
} from '@cyl/classifymenu';
import {
  cylAppText,
  CYLDemoNavBar,
  CYLDemoPlaceholderItem,
  cylDemoText,
  CYLDemoRoute,
  CYLPlaceholderDetailParam,
  cylSetTabIconSource,
  CYL_TAB_ICON_SOURCE_KEY,
  CYL_PLUS_OVERHANG
} from '../common/DemoCommon';
import { CYLDemoTagMenuView, CYLDemoTagRow, CYLDemoTagSection } from '../common/DemoTagMenu';
import { cylGalleryNextChunkCount, cylGalleryRange } from './CYLGalleryChunks';

/**
 * The number of placeholder styles shown: the 41 styles the search placeholder had, the first 41 of
 * CYLTableViewPlaceHolder's `CYLPlaceholderStyle`, in the same order.
 */
const STYLE_COUNT: number = 41;
const MESSAGE_KEYS: string[] = ['placeholder.empty', 'placeholder.search', 'placeholder.error', 'placeholder.network'];
/**
 * The CYLTableViewPlaceHolder messages of the four rows of a style.
 */
const MESSAGES: CYLPlaceholderMessage[] = [CYLPlaceholderMessage.Empty, CYLPlaceholderMessage.NoResults,
  CYLPlaceholderMessage.Error, CYLPlaceholderMessage.NoInternet];
const CUSTOM_KEYS: string[] = ['demo.custom.textOnly', 'demo.custom.imageOnly', 'demo.custom.both'];

/**
 * The side of the SVGA demo's animated icon in vp (iOS `CYLSVGADemoTagButton.iconSide`).
 */
const SVGA_ICON_SIDE: number = 64;

/**
 * The SVGA demo above the Examples list (iOS `CYLSVGADemoTagButton`): a `CYLTagButton` (CollectionViewClassifyMenu, the
 * one icon + title + animated icon component) whose `animationURL` is an `.svga` rawfile, drawn by its animation
 * engine, so the example uses no SVGA player itself. The icon comes before the title, at the leading edge, without a
 * border or background.
 */
function cylSVGADemoTagButton(title: string, animationURL: string): CYLTagButton {
  const button = new CYLTagButton(title, undefined, animationURL);
  const style = new CYLMenuStyle();
  style.imageSize = new CYLSize(SVGA_ICON_SIDE, SVGA_ICON_SIDE);
  style.animationSize = new CYLSize(SVGA_ICON_SIDE, SVGA_ICON_SIDE);
  style.imageTitleSpacing = 12;
  style.contentAlignment = CYLTagContentAlignment.leading;
  style.itemHeight = SVGA_ICON_SIDE;
  [CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED].forEach((state: number) => {
    const appearance = style.appearance(state);
    appearance.backgroundColor = Color.Transparent;
    appearance.borderColor = undefined;
    appearance.borderWidth = 0;
    appearance.contentInsets = new CYLEdgeInsets(0, 0, 0, 0);
    // Square: 0 is square (item 8b, docs/animated-icon-component.md).
    appearance.cornerRadius = 0;
    appearance.textColor = $r('sys.color.font_secondary');
    appearance.font = CYLFont.systemFont(13);
  });
  button.style = style;
  return button;
}

/**
 * The Examples tab (iOS `CYLSearchDemoMenuViewController`): Search and refresh, Placeholder styles, Search bar, and
 * the other libraries' examples.
 */
@ComponentV2
export struct ExamplesMenuView {
  @Require @Param stack: NavPathStack;
  private context: common.Context = this.getUIContext().getHostContext() as common.Context;
  // The SVGA demo above the list (iOS `CYLSVGADemoHeaderView`): played once when shown, again on each tap.
  private svgaButton: CYLTagButton = cylSVGADemoTagButton(cylAppText(this.context, 'svga_demo'),
    'asset:svga/tab_activity.svga');
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

  aboutToAppear(): void {
    // Plays once when shown, as the tab icons do when selected (iOS `didMoveToWindow`).
    this.svgaButton.playAnimation();
    // `--pi CYLContactTags 1` opens the contact tags example at launch (iOS `-CYLDemoRow 5`), for screenshots.
    if ((AppStorage.get<number>('CYLContactTags') ?? 0) === 1) {
      setTimeout(() => this.stack.pushPath({ name: CYLDemoRoute.contactTags }), 300);
    }
  }

  // As iOS `CYLSVGADemoHeaderView`: the tag button with the 64 vp animation (tab_activity.svga) and its title, the
  // source button below.
  @Builder
  svgaHeader() {
    Column() {
      Row() {
        CYLTagButtonHost({ button: this.svgaButton, interactive: false })
      }
      .width('100%')
      .height(SVGA_ICON_SIDE)
      .accessibilityGroup(true)
      .accessibilityText(cylAppText(this.context, 'svga_demo'))
      .accessibilityDescription(cylAppText(this.context, 'svga_demo_hint'))
      .id('CYLSVGADemoHeader')
      .onClick(() => {
        this.svgaButton.playAnimation();
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
  // Row 5 (iOS row 6, `-CYLDemoRow 5`): CollectionViewClassifyMenu's contact tags example on CYLSearchViewController.
  private rows: string[] = ['demo.reproduction', 'demo.styles', 'demo.searchBar', 'demo.ports', 'contactTags_row',
    'demo.searchController', 'demo.searchBarStyles'];
  private routes: string[] = [CYLDemoRoute.reproduction, CYLDemoRoute.styles, CYLDemoRoute.searchBar, CYLDemoRoute.ports,
    CYLDemoRoute.contactTags, CYLDemoRoute.searchController, CYLDemoRoute.searchBarStyles];

  // One titled section, a tag per row (docs/instructions/example-demos.md).
  private menuSections(): CYLDemoTagSection[] {
    const rows: CYLDemoTagRow[] = this.rows.map((key: string): CYLDemoTagRow => {
      const row: CYLDemoTagRow = { title: this.rowText(key), subtitle: '', image: undefined };
      return row;
    });
    return [new CYLDemoTagSection(cylDemoText(this.context, 'demo.title'), rows)];
  }

  // The library's `demo.*` texts, or the example's own (`contactTags_row`).
  private rowText(key: string): string {
    return key.startsWith('contactTags_') ? cylAppText(this.context, key) : cylDemoText(this.context, key);
  }

  build() {
    Column() {
      CYLDemoNavBar({ title: cylDemoText(this.context, 'demo.title'), barColor: Color.Transparent })
      this.svgaHeader()
      Scroll() {
        CYLDemoTagMenuView({
          sections: this.menuSections(),
          tagId: 'CYLDemoExamplesTags',
          onSelect: (section: number, item: number) => {
            this.stack.pushPath({ name: this.routes[item] });
          }
        })
      }
      .margin({ bottom: CYL_PLUS_OVERHANG })
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    // A gradient page (docs/instructions/example-demos.md rule 7); the tag list draws no background, so the glass tags sit on it.
    .linearGradient({ angle: 135, colors: [['#7FB7FF', 0.0], ['#FF9EC7', 0.5], ['#FFC27A', 1.0]] })
  }
}

/**
 * The placeholder of a row of the Placeholder styles page (iOS `-tableView:didSelectRowAtIndexPath:`).
 */
export function cylPlaceholderForRow(context: common.Context, section: number, row: number): CYLPlaceholderViewModel {
  if (section < STYLE_COUNT) {
    return CYLPlaceholderViewModel.initWithStyleMessage(section as CYLPlaceholderStyle, MESSAGES[row]);
  }
  if (row === 0) {
    return CYLPlaceholderViewModel.initWithStyleText(CYLPlaceholderStyle.NoResults,
      cylDemoText(context, 'demo.custom.text'));
  }
  const heart = CYLPlaceholderViewModel.imageForStyle(CYLPlaceholderStyle.Favorite);
  const placeholder = CYLPlaceholderViewModel.initWithImageText(heart, row === 1 ?
    CYLPlaceholderViewModel.localizedTextForMessage(CYLPlaceholderMessage.NoInternet) :
    cylDemoText(context, 'demo.custom.text'));
  placeholder.defaultIconColor = '#FF2D55';
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
  // The tag lists are built chunk by chunk (CYLGalleryChunks.ets): all 42 at once froze the main thread.
  @Local chunks: number = 1;

  private rowsOf(section: number): number[] {
    return section === STYLE_COUNT ? [0, 1, 2] : [0, 1, 2, 3];
  }

  private textOf(section: number, row: number): string {
    return cylDemoText(this.context, section === STYLE_COUNT ? CUSTOM_KEYS[row] : MESSAGE_KEYS[row]);
  }

  private imageOf(section: number, row: number): Resource | undefined {
    if (section === STYLE_COUNT) {
      return row === 0 ? (CYLPlaceholderViewModel.imageForStyle(CYLPlaceholderStyle.NoResults) ?? undefined) :
      (CYLPlaceholderViewModel.imageForStyle(CYLPlaceholderStyle.Favorite) ?? undefined);
    }
    return CYLPlaceholderViewModel.imageForStyle(section as CYLPlaceholderStyle) ?? undefined;
  }

  // One section per style, a glass tag per message with the style's image (docs/instructions/example-demos.md).
  private tagSections(): CYLDemoTagSection[] {
    return this.sections.map((section: number): CYLDemoTagSection => {
      const rows: CYLDemoTagRow[] = this.rowsOf(section).map((row: number): CYLDemoTagRow => {
        const tagRow: CYLDemoTagRow = { title: this.textOf(section, row), subtitle: '', image: this.imageOf(section, row) };
        return tagRow;
      });
      const header: string = section === STYLE_COUNT ? cylDemoText(this.context, 'demo.custom') :
        (CYLPlaceholderViewModel.imageNameForStyle(section as CYLPlaceholderStyle) ?? '');
      return new CYLDemoTagSection(header, rows);
    });
  }

  // The sections of one chunk of the page.
  private chunkSections(chunk: number): CYLDemoTagSection[] {
    const range: number[] = cylGalleryRange(chunk, this.sections.length);
    return this.tagSections().slice(range[0], range[0] + range[1]);
  }

  build() {
    NavDestination() {
      Column() {
        CYLDemoNavBar({
          title: cylDemoText(this.context, 'demo.styles'),
          showsBack: true,
          barColor: Color.Transparent,
          onBack: () => this.stack.pop()
        })
        Scroll() {
          Column() {
            ForEach(Array.from<number, number>({ length: this.chunks }, (_: number, i: number) => i), (chunk: number) => {
              CYLDemoTagMenuView({
                sections: this.chunkSections(chunk),
                tagId: chunk === 0 ? 'CYLDemoPlaceholderTags' : 'CYLDemoPlaceholderTags' + chunk,
                onSelect: (section: number, item: number) => {
                  const first: number = cylGalleryRange(chunk, this.sections.length)[0];
                  const param: CYLPlaceholderDetailParam = { title: this.textOf(first + section, item), section: first + section, row: item };
                  this.stack.pushPath({ name: CYLDemoRoute.placeholderDetail, param: param });
                }
              })
            }, (chunk: number) => 'chunk' + chunk)
          }
        }
        .onReachEnd(() => {
          this.chunks = cylGalleryNextChunkCount(this.chunks, this.sections.length);
        })
        .margin({ bottom: CYL_PLUS_OVERHANG })
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      // A gradient page (docs/instructions/example-demos.md rule 7); the tag list draws no background, so the glass sits on it.
      .linearGradient({ angle: 135, colors: [['#7FB7FF', 0.0], ['#FF9EC7', 0.5], ['#FFC27A', 1.0]] })
    }
    .hideTitleBar(true)
  }
}

/**
 * The detail page of a row: one CYLTableViewPlaceHolder placeholder view (`CYLPlaceholderView`) filling the page.
 */
@ComponentV2
export struct PlaceholderDetailPage {
  @Require @Param stack: NavPathStack;
  @Require @Param param: CYLPlaceholderDetailParam;
  private context: common.Context = this.getUIContext().getHostContext() as common.Context;
  private placeholder: CYLPlaceholderViewModel | undefined = undefined;

  aboutToAppear(): void {
    this.placeholder = cylPlaceholderForRow(this.context, this.param.section, this.param.row);
  }

  build() {
    NavDestination() {
      Column() {
        CYLDemoNavBar({ title: this.param.title, showsBack: true, onBack: () => this.stack.pop() })
        if (this.placeholder !== undefined) {
          CYLDemoPlaceholderItem({ placeholder: this.placeholder }).layoutWeight(1)
        }
      }
      .backgroundColor($r('sys.color.background_primary'))
    }
    .hideTitleBar(true)
  }
}

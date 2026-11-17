import { common } from '@kit.AbilityKit';
import { LengthMetrics } from '@kit.ArkUI';
import { util } from '@kit.ArkTS';
import {
  CYLSearchBarComponent,
  CYLSearchBarItem,
  CYLSearchBarStyle,
  CYLSearchBarView
} from 'cylsearch';
import { cylAppText, CYL_PLUS_OVERHANG } from '../common/DemoCommon';

/**
 * How many tags (`widths`, in vp) fit in `rows` rows of `width`, leaving room for a control of `controlWidth` after
 * the last visible tag; all of them when they fit without it (the folding of the recent searches, as iOS's
 * CYLSearchDiscoverViewController; the core's own folding is private to CYLSearchView).
 */
function cylFoldedTagCount(widths: number[], width: number, rows: number, spacing: number,
  controlWidth: number): number {
  if (rows <= 0 || width <= 0) {
    return widths.length;
  }
  const fits = (count: number, extra: number): boolean => {
    let row = 1;
    let x = 0;
    const items = widths.slice(0, count).map((w: number) => Math.min(w, width));
    if (extra > 0) {
      items.push(Math.min(extra, width));
    }
    for (const w of items) {
      if (x > 0 && x + spacing + w > width) {
        row++;
        x = w;
      } else {
        x = x > 0 ? x + spacing + w : w;
      }
      if (row > rows) {
        return false;
      }
    }
    return true;
  };
  if (fits(widths.length, 0)) {
    return widths.length;
  }
  for (let count = widths.length - 1; count >= 0; count--) {
    if (fits(count, controlWidth)) {
      return count;
    }
  }
  return 0;
}

/**
 * A discover topic of search-discover.json; `icon` "hot" adds the localized hot icon after the title.
 */
interface CYLDiscoverTopic {
  title: string;
  icon?: string;
}

/**
 * The demo's data (iOS `CYLSearchDiscoverData`): one rawfile per language, the same topics in the same order.
 */
interface CYLSearchDiscoverData {
  version: number;
  discoverCount: number;
  recentSearches: string[];
  discover: CYLDiscoverTopic[];
}

const TAG_HEIGHT: number = 36;
const TAG_SPACING: number = 12;
const TAG_MARGIN: number = 14;
const CHEVRON_WIDTH: number = 44;


/**
 * The Discover tab (iOS `CYLSearchDiscoverViewController`, copied from CollectionViewClassifyMenu's CYLMenuExample):
 * the bordered search bar with the camera, a divider and Search appended inside it; "Recent searches" as tags folded
 * to two rows with the chevron as the last tag, and a trash button; "Discover" as a grid of two titles per row with
 * the hot icon and the More button that picks other topics; and the hold-to-ask mic button on a curved area.
 */
@ComponentV2
export struct DiscoverView {
  @Param showsBack: boolean = false;
  @Event onBack: () => void = () => {
  };
  @Local recent: string[] = [];
  @Local topics: CYLDiscoverTopic[] = [];
  @Local recentFolded: boolean = true;
  // The width of the curved area under the mic button, in px (Path commands are in px).
  @Local curveWidth: number = 0;
  @Local listWidth: number = 0;
  @Local hint: string = '';
  private context: common.Context = this.getUIContext().getHostContext() as common.Context;
  private data: CYLSearchDiscoverData = { version: 1, discoverCount: 6, recentSearches: [], discover: [] };
  private searchBar: CYLSearchBarView = new CYLSearchBarView();

  private text(name: string, ...args: string[]): string {
    return cylAppText(this.context, name, ...args);
  }

  aboutToAppear(): void {
    this.data = this.loadData();
    this.recent = this.data.recentSearches;
    this.topics = this.data.discover.slice(0, Math.max(0, this.data.discoverCount));
    this.hint = this.text('discover_askHint');
    // A capsule with a soft shadow, no magnifier: the camera and the Search button sit inside it.
    const bar = this.searchBar;
    bar.searchIcon = undefined;
    bar.contentInsets = { top: 0, left: 0, bottom: 0, right: 0 };
    bar.fieldHeight = 46;
    bar.searchBarStyle = CYLSearchBarStyle.bordered;
    bar.fieldCornerRadius = 22;
    bar.fieldShadowOpacity = 0.06;
    bar.font = 16;
    bar.fieldBorderColor = $r('sys.color.comp_divider');
    bar.fieldBorderWidth = 1;
    bar.itemTintColor = $r('sys.color.font_primary');
    const camera = CYLSearchBarItem.iconItem($r('sys.symbol.camera'), this.text('discover_imageSearch'),
      () => this.searchByImage());
    camera.imageSize = 22;
    const search = CYLSearchBarItem.textItem(this.text('discover_search'), () => this.searchTapped());
    search.itemAccessibilityIdentifier = 'CYLSearchDiscoverSearchButton';
    bar.addItem(camera);
    bar.addItem(CYLSearchBarItem.divider());
    bar.addItem(search);
    bar.delegate = {
      searchBarViewSearchButtonClicked: (view: CYLSearchBarView) => {
        this.searchTapped();
        view.hideKeyboard();
      }
    };
    this.reloadLists();
  }

  private loadData(): CYLSearchDiscoverData {
    const names = ['zh_TW', 'zh_CN', 'ja_JP'];
    const language = this.context.resourceManager.getConfigurationSync().locale ?? '';
    let file = 'base';
    if (language.startsWith('zh')) {
      file = language.includes('Hant') || language.includes('TW') || language.includes('HK') ? names[0] : names[1];
    } else if (language.startsWith('ja')) {
      file = names[2];
    }
    try {
      const bytes = this.context.resourceManager.getRawFileContentSync(`discover/${file}.json`);
      return JSON.parse(new util.TextDecoder('utf-8').decodeToString(bytes)) as CYLSearchDiscoverData;
    } catch (error) {
      return { version: 1, discoverCount: 6, recentSearches: [], discover: [] };
    }
  }

  // The search field's placeholder is the first discover topic.
  private reloadLists(): void {
    this.searchBar.placeholder = this.topics.length > 0 ? this.topics[0].title : this.text('discover_search');
  }

  // The More button: another random selection of topics, different from the shown ones whenever the pool allows.
  private refreshDiscover(): void {
    const count = Math.min(Math.max(0, this.data.discoverCount), this.data.discover.length);
    const shown = this.topics.map((topic: CYLDiscoverTopic) => topic.title);
    const shuffle = (items: CYLDiscoverTopic[]) => items.map((t: CYLDiscoverTopic) => [Math.random(), t] as [number, CYLDiscoverTopic])
      .sort((a: [number, CYLDiscoverTopic], b: [number, CYLDiscoverTopic]) => a[0] - b[0])
      .map((pair: [number, CYLDiscoverTopic]) => pair[1]);
    let picked = shuffle(this.data.discover.filter((t: CYLDiscoverTopic) => !shown.includes(t.title))).slice(0, count);
    if (picked.length < count) {
      const titles = picked.map((t: CYLDiscoverTopic) => t.title);
      picked = picked.concat(shuffle(this.data.discover.filter((t: CYLDiscoverTopic) => !titles.includes(t.title)))
        .slice(0, count - picked.length));
    }
    this.topics = picked;
    this.reloadLists();
  }

  // Searches `text`: shows it in the field and moves it to the front of the recent searches.
  private search(text: string): void {
    const query = text.trim();
    if (query.length === 0) {
      return;
    }
    this.searchBar.text = query;
    this.recent = [query].concat(this.recent.filter((item: string) => item !== query));
    this.reloadLists();
  }

  // The Search button and the keyboard's search key: the typed text, else the placeholder topic.
  private searchTapped(): void {
    this.search(this.searchBar.text.length > 0 ? this.searchBar.text : (this.searchBar.placeholder ?? ''));
  }

  // The camera button: not part of this demo, which says so instead of ignoring the tap.
  private searchByImage(): void {
    this.getUIContext().showAlertDialog({
      title: this.text('discover_imageSearch'),
      message: this.text('discover_imageSearchUnavailable'),
      confirm: { value: this.text('discover_ok'), action: () => {
      } }
    });
  }

  // The light curved area: a bump up in the middle, as on iOS, scaled to the measured width (px).
  private curveCommands(): string {
    const w = this.curveWidth;
    const h = this.getUIContext().vp2px(110);
    const edge = h * 0.25;
    return `M0 ${edge} Q ${w / 2} ${-edge} ${w} ${edge} L ${w} ${h} L 0 ${h} Z`;
  }

  private tagWidth(title: string): number {
    const size = this.getUIContext().getMeasureUtils().measureTextSize({ textContent: title, fontSize: 17 });
    return this.getUIContext().px2vp(Number(size.width)) + TAG_MARGIN * 2 + 2;
  }

  private visibleRecent(): string[] {
    if (!this.recentFolded || this.listWidth <= 0) {
      return this.recent;
    }
    const count = cylFoldedTagCount(this.recent.map((title: string) => this.tagWidth(title)), this.listWidth, 2, TAG_SPACING,
      CHEVRON_WIDTH);
    return this.recent.slice(0, count);
  }

  private showsChevron(): boolean {
    return this.listWidth > 0 && (cylFoldedTagCount(this.recent.map((t: string) => this.tagWidth(t)), this.listWidth, 2, TAG_SPACING,
      CHEVRON_WIDTH) <
    this.recent.length || !this.recentFolded);
  }

  @Builder
  header(title: string, accessory: number) {
    Row() {
      Text(title).fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('sys.color.font_primary')).layoutWeight(1)
      if (accessory === 1) {
        SymbolGlyph($r('sys.symbol.trash'))
          .fontSize(18)
          .fontColor([$r('sys.color.font_secondary')])
          .padding(8)
          .accessibilityText(this.text('discover_clear'))
          .id('CYLSearchDiscoverClear')
          .onClick(() => {
            this.recent = [];
          })
      } else if (accessory === 2) {
        SymbolGlyph($r('sys.symbol.arrow_clockwise'))
          .fontSize(18)
          .fontColor([$r('sys.color.font_secondary')])
          .padding(8)
          .accessibilityText(this.text('discover_refresh'))
          .id('CYLSearchDiscoverMore')
          .onClick(() => this.refreshDiscover())
      }
    }
    .width('100%')
    .height(44)
    .padding({ left: 16, right: 8 })
  }

  @Builder
  recentTag(title: string) {
    Text(title)
      .fontSize(17)
      .fontColor($r('sys.color.font_primary'))
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .constraintSize({ maxWidth: '100%' })
      .height(TAG_HEIGHT)
      .padding({ left: TAG_MARGIN, right: TAG_MARGIN })
      .backgroundColor($r('sys.color.background_primary'))
      .border({ width: 1, color: $r('sys.color.comp_divider') })
      .accessibilityDescription(this.text('discover_tapToSearch'))
      .onClick(() => this.search(title))
  }

  build() {
    Column() {
      Row({ space: 2 }) {
        if (this.showsBack) {
          SymbolGlyph($r('sys.symbol.chevron_backward'))
            .fontSize(20)
            .fontColor([$r('sys.color.font_primary')])
            .width(32)
            .height(44)
            .accessibilityText(this.text('discover_back'))
            .onClick(() => this.onBack())
        }
        CYLSearchBarComponent({ searchBarView: this.searchBar }).layoutWeight(1)
      }
      .padding({ left: this.showsBack ? 6 : 14, right: 14, top: 8 })

      Scroll() {
        Column({ space: 4 }) {
          if (this.recent.length > 0) {
            this.header(this.text('discover_recent'), 1)
            Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(TAG_SPACING), cross: LengthMetrics.vp(TAG_SPACING) } }) {
              ForEach(this.visibleRecent(), (title: string) => {
                this.recentTag(title)
              }, (title: string) => title)
              if (this.showsChevron()) {
                Row() {
                  SymbolGlyph($r('sys.symbol.chevron_down'))
                    .fontSize(16)
                    .fontColor([$r('sys.color.font_primary')])
                    .rotate({ angle: this.recentFolded ? 0 : 180 })
                }
                .width(CHEVRON_WIDTH)
                .height(TAG_HEIGHT)
                .justifyContent(FlexAlign.Center)
                .backgroundColor($r('sys.color.background_primary'))
                .border({ width: 1, color: $r('sys.color.comp_divider') })
                .accessibilityGroup(true)
                .accessibilityText(this.recentFolded ? $r('app.string.cyl_search_showMore') : $r('app.string.cyl_search_showLess'))
                .id('CYLSearchDiscoverFold')
                .onClick(() => {
                  this.recentFolded = !this.recentFolded;
                })
              }
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 4, bottom: 24 })
            .onAreaChange((_: Area, area: Area) => {
              this.listWidth = Number(area.width) - 32;
            })
          }
          this.header(this.text('discover_title'), 2)
          Grid() {
            ForEach(this.topics, (topic: CYLDiscoverTopic) => {
              GridItem() {
                Row({ space: 4 }) {
                  Text(topic.title)
                    .fontSize(17)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .flexShrink(1)
                  if (topic.icon === 'hot') {
                    Image($r('app.media.discover_hot')).height(18).objectFit(ImageFit.Contain)
                      .accessibilityText(this.text('discover_hot'))
                  }
                }
                .height(TAG_HEIGHT)
                .width('100%')
                .accessibilityGroup(true)
                .accessibilityDescription(this.text('discover_tapToSearch'))
                .onClick(() => this.search(topic.title))
              }
            }, (topic: CYLDiscoverTopic) => topic.title)
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(16)
          .rowsGap(16)
          .maxCount(2)
          .layoutDirection(GridDirection.Row)
          .height(Math.ceil(this.topics.length / 2) * (TAG_HEIGHT + 16))
          .padding({ left: 16, right: 16, top: 4, bottom: 16 })
        }
      }
      .layoutWeight(1)
      .align(Alignment.Top)
      .margin({ top: 10 })

      // The hint and the hold-to-ask mic button on a light curved area.
      Stack({ alignContent: Alignment.Bottom }) {
        // Path commands are in px and are not scaled to the component: the curve is built from the measured width, so it
        // spans the whole page instead of a 360 px shape at the left edge.
        Path()
          .commands(this.curveCommands())
          .fill($r('sys.color.background_secondary'))
          .width('100%')
          .height(110)
          .accessibilityLevel('no')
          .onAreaChange((_: Area, area: Area) => {
            this.curveWidth = this.getUIContext().vp2px(Number(area.width));
          })
          // No outline: Path draws a black 1 px stroke unless told otherwise.
          .stroke(Color.Transparent)
          .strokeWidth(0)
        Column({ space: 20 }) {
          Text(this.hint + ' ✨')
            .fontSize(20)
            .fontColor($r('sys.color.font_secondary'))
            .textAlign(TextAlign.Center)
            .accessibilityText(this.hint)
          Row() {
            SymbolGlyph($r('sys.symbol.mic_fill')).fontSize(22).fontColor([Color.Red])
          }
          .width(68)
          .height(52)
          .justifyContent(FlexAlign.Center)
          .borderRadius(26)
          .backgroundColor($r('sys.color.background_primary'))
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.08)', offsetY: 2 })
          .accessibilityGroup(true)
          .accessibilityText(this.text('discover_ask'))
          .accessibilityDescription(this.text('discover_askAccessibilityHint'))
          .id('CYLSearchDiscoverMicButton')
          .gesture(LongPressGesture({ duration: 200 })
            .onAction(() => {
              this.hint = this.text('discover_listening');
            })
            .onActionEnd(() => {
              this.hint = this.text('discover_askHint');
            })
            .onActionCancel(() => {
              this.hint = this.text('discover_askHint');
            }))
        }
        .padding({ bottom: 16 })
      }
      .width('100%')

      // The mic button stays above the raised plus button: the space under it continues the curved area's color, so
      // no white strip shows between the curve and the tab bar (seen on the emulator, 2026-11-17).
      Row()
        .width('100%')
        .height(CYL_PLUS_OVERHANG)
        .backgroundColor($r('sys.color.background_secondary'))
        .accessibilityLevel('no')
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_primary'))
  }
}

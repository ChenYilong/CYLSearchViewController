import { common } from '@kit.AbilityKit';
import { LengthMetrics } from '@kit.ArkUI';
import { util } from '@kit.ArkTS';
import {
  CYLSearchBarItem,
  CYLSearchBarStyle,
  CYLSearchBarView,
  CYLSearchNavigationPage,
  CYLSearchRefreshButton
} from 'cylsearch';
import { cylAppText, CYLDemoRoute, CYL_PLUS_OVERHANG } from '../common/DemoCommon';

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

// MARK: - Pure logic (begin): no ArkUI, no kit; harmonyos/scripts/host-logic-test.mjs runs it with Node.

/**
 * A discover topic of search-discover.json; `icon` "hot" adds the localized hot icon after the title.
 */
interface CYLDiscoverTopic {
  title: string;
  icon?: string;
}

/**
 * One page of topics and its number.
 */
interface CYLDiscoverPage {
  page: number;
  topics: CYLDiscoverTopic[];
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

/**
 * The topics of page `page` of `pool`: whole pages of `count` records, the page number taken modulo the number of
 * pages (a negative page counts from the end). Refresh shows the next page, cyclically, with no random pick.
 */
function cylDiscoverPage(pool: CYLDiscoverTopic[], count: number, page: number): CYLDiscoverPage {
  const size = Math.max(1, Math.min(Math.max(0, count), pool.length));
  const pages = Math.max(1, Math.floor(pool.length / size));
  const index = ((page % pages) + pages) % pages;
  return { page: index, topics: pool.slice(index * size, (index + 1) * size) };
}

// MARK: - Pure logic (end)

const TAG_HEIGHT: number = 36;
const TAG_SPACING: number = 12;
const TAG_MARGIN: number = 14;
const CHEVRON_WIDTH: number = 44;


/**
 * The Discover tab (iOS `CYLSearchDiscoverViewController`, copied from CollectionViewClassifyMenu's CYLMenuExample):
 * the bordered search bar with the camera, a divider and Search appended inside it; "Recent searches" as tags folded
 * to two rows with the chevron as the last tag, and a trash button; "Discover" as a grid of two titles per row with
 * the hot icon and the core's refresh button that shows the next page of topics; and the hold-to-ask mic button on a curved area.
 */
@ComponentV2
export struct DiscoverView {
  @Param showsBack: boolean = false;
  // True when the page is pushed on a Navigation stack (a NavDestination hosts it).
  @Param isDestination: boolean = false;
  @Event onBack: () => void = () => {
  };
  @Local recent: string[] = [];
  @Local topics: CYLDiscoverTopic[] = [];
  @Local recentFolded: boolean = true;
  // The width of the curved area under the mic button, in px (Path commands are in px).
  @Local curveWidth: number = 0;
  @Local listWidth: number = 0;
  @Local hint: string = '';
  // Playback of the animated search bar item (index 1): the loop switch and the speed slider write to the item.
  @Local animationLoops: boolean = false;
  @Local animationSpeed: number = 1;
  private context: common.Context = this.getUIContext().getHostContext() as common.Context;
  private data: CYLSearchDiscoverData = { version: 1, discoverCount: 6, recentSearches: [], discover: [] };
  private searchBar: CYLSearchBarView = new CYLSearchBarView();
  private animatedItem: CYLSearchBarItem | undefined = undefined;
  private topicPage: number = 0;

  private text(name: string, ...args: string[]): string {
    return cylAppText(this.context, name, ...args);
  }

  aboutToAppear(): void {
    this.data = this.loadData();
    this.recent = this.data.recentSearches;
    this.topics = cylDiscoverPage(this.data.discover, this.data.discoverCount, 0).topics;
    this.hint = this.text('discover_askHint');
    // A capsule with a soft shadow, no magnifier: the camera and the Search button sit inside it.
    const bar = this.searchBar;
    bar.searchIcon = undefined;
    bar.contentInsets = { top: 0, left: 0, bottom: 0, right: 0 };
    bar.searchBarStyle = CYLSearchBarStyle.bordered;
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
    // The animated item (index 1): the same still image as the camera, with the SVGA file from the rawfile folder.
    const animated = CYLSearchBarItem.iconItem($r('sys.symbol.camera'), this.text('discover_animationItem'));
    animated.imageSize = 22;
    animated.animationURL = 'asset:svga/tab_activity.svga';
    animated.animationLoops = this.animationLoops;
    animated.animationSpeed = this.animationSpeed;
    this.animatedItem = animated;
    bar.addItem(camera);
    bar.addItem(animated);
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

  // The refresh button: the next page of topics, cyclically (page = (page + 1) mod pages).
  private refreshDiscover(): void {
    const next = cylDiscoverPage(this.data.discover, this.data.discoverCount, this.topicPage + 1);
    this.topicPage = next.page;
    this.topics = next.topics;
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
    this.search(this.searchBar.text.length > 0 ? this.searchBar.text : this.placeholderText());
  }

  // The search bar's placeholder as text: a string, or a string resource resolved in the device's language.
  private placeholderText(): string {
    const placeholder: ResourceStr | undefined = this.searchBar.placeholder;
    if (placeholder === undefined) {
      return '';
    }
    if (typeof placeholder === 'string') {
      return placeholder;
    }
    return this.getUIContext().getHostContext()?.resourceManager.getStringSync(placeholder as Resource) ?? '';
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
    // The area reaches down to the tab bar: 110 vp of curve plus the raised plus button's overhang.
    const h = this.getUIContext().vp2px(110 + CYL_PLUS_OVERHANG);
    const edge = this.getUIContext().vp2px(110) * 0.25;
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
        CYLSearchRefreshButton({ identifier: 'CYLSearchDiscoverMore', onRefresh: () => this.refreshDiscover() })
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
    // The core's navigation page holds the search bar in the navigation bar; the page lays the bar out by no hand.
    CYLSearchNavigationPage({ searchBarView: this.searchBar, showsBack: this.showsBack, isDestination: this.isDestination,
      onBack: () => this.onBack() }) {
      this.discoverContent()
    }
  }

  @Builder
  discoverContent() {
    Column() {
      // Playback of the animated item: loop switch, speed slider (0.25 to 3) with its value, and Play again.
      Row({ space: 8 }) {
        Toggle({ type: ToggleType.Switch, isOn: this.animationLoops })
          .constraintSize({ minWidth: 44, minHeight: 44 })
          .accessibilityText(this.text('discover_animationLoops'))
          .id('CYLSearchDiscoverAnimationLoops')
          .onChange((isOn: boolean) => {
            this.animationLoops = isOn;
            if (this.animatedItem !== undefined) {
              this.animatedItem.animationLoops = isOn;
            }
          })
        Slider({ value: this.animationSpeed, min: 0.25, max: 3, step: 0.25, style: SliderStyle.OutSet })
          .layoutWeight(1)
          .height(44)
          .accessibilityText(this.text('discover_animationSpeed'))
          // The current speed, read after the label (ArkUI's Slider has no accessibilityValue).
          .accessibilityDescription(`${this.animationSpeed.toFixed(2)}x`)
          .id('CYLSearchDiscoverAnimationSpeed')
          .onChange((value: number) => {
            this.animationSpeed = value;
            if (this.animatedItem !== undefined) {
              this.animatedItem.animationSpeed = value;
            }
          })
        Text(`${this.animationSpeed.toFixed(2)}x`)
          .fontSize(14)
          .fontColor($r('sys.color.font_secondary'))
          .accessibilityLevel('no')
        Button(this.text('discover_animationPlay'), { type: ButtonType.Capsule })
          .fontSize(14)
          .constraintSize({ minWidth: 44, minHeight: 44 })
          .accessibilityText(this.text('discover_animationPlay'))
          .id('CYLSearchDiscoverAnimationPlay')
          .onClick(() => this.animatedItem?.restartAnimation())
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 4 })

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
          .height(110 + CYL_PLUS_OVERHANG)
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
        // Above the raised plus button (CYL_PLUS_OVERHANG), inside the grey area so no white band shows under it.
        .padding({ bottom: 16 + CYL_PLUS_OVERHANG })
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

// Whether the entry page already opened the Discover page once (the first time it appears it opens it by itself).
let cylDiscoverOpenedOnce: boolean = false;

/**
 * The root of the Discover tab: a small entry page. The Discover page is always pushed on top of it (also at once, the
 * first time), so its navigation bar always has a back button on the left, as the iOS example's second-level page.
 */
@ComponentV2
export struct DiscoverEntryView {
  @Require @Param stack: NavPathStack;
  private context: common.Context = this.getUIContext().getHostContext() as common.Context;

  aboutToAppear(): void {
    if (!cylDiscoverOpenedOnce) {
      cylDiscoverOpenedOnce = true;
      this.stack.pushPath({ name: CYLDemoRoute.discover }, false);
    }
  }

  build() {
    Column({ space: 16 }) {
      Text(cylAppText(this.context, 'tab_discover')).fontSize(20).fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
      Button(cylAppText(this.context, 'tab_discover'), { type: ButtonType.Capsule })
        .constraintSize({ minWidth: 44, minHeight: 44 })
        .id('CYLSearchDiscoverOpen')
        .onClick(() => this.stack.pushPath({ name: CYLDemoRoute.discover }))
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('sys.color.background_primary'))
  }
}

/**
 * The Discover page pushed from the entry page: back button on the left, the search bar in the navigation bar.
 */
@ComponentV2
export struct DiscoverPage {
  @Require @Param stack: NavPathStack;

  build() {
    DiscoverView({ showsBack: true, isDestination: true, onBack: () => this.stack.pop() })
  }
}

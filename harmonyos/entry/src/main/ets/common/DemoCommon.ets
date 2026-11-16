import { common } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import { CYLSearchResources } from 'cylsearch';
import { cyl_plusButtonOverhang } from 'cyltabbar';

/**
 * Fills `%s`, `%d` and positional `%1$d` / `%1$s` in `format` with `args`, in order.
 */
export function cylFormat(format: string, ...args: (string | number)[]): string {
  let next = 0;
  return format.replace(new RegExp('%(\\d+\\$)?[sd]', 'g'), (match: string, position?: string) => {
    const index = position !== undefined && position.length > 0 ? Number.parseInt(position) - 1 : next++;
    return index < args.length ? `${args[index]}` : match;
  });
}

/**
 * A text of the library (`demo.port.item`, the `demo.*` keys of iOS CYLSearchViewController.bundle), filled with
 * `args` (iOS `cylDemoText` and `String.localizedStringWithFormat`).
 */
export function cylDemoText(context: common.Context, key: string, ...args: (string | number)[]): string {
  return cylFormat(CYLSearchResources.localizedString(context, key), ...args);
}

/**
 * A text of the example (`tab_search`, `discover_recent`, `refresh_idle`), filled with `args`.
 */
export function cylAppText(context: common.Context, name: string, ...args: (string | number)[]): string {
  try {
    return cylFormat(context.resourceManager.getStringByNameSync(name), ...args);
  } catch (error) {
    return name;
  }
}

/**
 * The routes of the example's pages, pushed on the tab's NavPathStack.
 */
export class CYLDemoRoute {
  static readonly reproduction: string = 'reproduction';
  static readonly styles: string = 'styles';
  static readonly placeholderDetail: string = 'placeholderDetail';
  static readonly searchBar: string = 'searchBar';
  static readonly ports: string = 'ports';
  static readonly lapism: string = 'lapism';
  static readonly materialMenu: string = 'materialMenu';
  static readonly materialSample: string = 'materialSample';
  static readonly yechaoa: string = 'yechaoa';
  static readonly reveal: string = 'reveal';
  static readonly multiSearch: string = 'multiSearch';
}

/**
 * What a placeholder detail page shows: a row of the Placeholder styles page.
 */
export interface CYLPlaceholderDetailParam {
  title: string;
  section: number;
  row: number;
}

/**
 * What a MaterialSearchView sample page gets from its menu.
 */
export interface CYLMaterialSampleParam {
  sample: number;
  tags: boolean;
  focusesSearchFieldOnShow: boolean;
}

/**
 * A short message at the bottom of a page, like Android's `Snackbar.make(...).show()` (iOS `CYLSnackbar`): the
 * page draws `CYLSnackbarView` with it.
 */
@ObservedV2
export class CYLSnackbar {
  @Trace text: string = '';
  @Trace opacity: number = 0;
  private timer: number = -1;

  /**
   * Shows `text` for a few seconds, then fades it out.
   */
  show(text: string): void {
    this.text = text;
    this.opacity = 1;
    clearTimeout(this.timer);
    this.timer = setTimeout(() => {
      this.opacity = 0;
    }, 2750);
  }
}

/**
 * Draws a `CYLSnackbar` above the bottom of its page: white text on a dark rounded bar.
 */
@ComponentV2
export struct CYLSnackbarView {
  @Require @Param snackbar: CYLSnackbar;

  build() {
    Column() {
      Blank()
      if (this.snackbar.text.length > 0) {
        Text(this.snackbar.text)
          .fontSize(15)
          .fontColor(Color.White)
          .width('100%')
          .padding({ left: 16, right: 16, top: 14, bottom: 14 })
          .backgroundColor('rgba(51, 51, 51, 0.95)')
          .borderRadius(8)
          .opacity(this.snackbar.opacity)
          .animation({ duration: 250 })
          .accessibilityLevel('yes')
          .id('CYLSnackbar')
      }
    }
    .width('100%')
    .height('100%')
    .padding(8)
    .hitTestBehavior(HitTestMode.Transparent)
  }
}

/**
 * The navigation bar of a page (UINavigationBar): an optional back button or left button, the title, and an
 * optional right button.
 */
@ComponentV2
export struct CYLDemoNavBar {
  @Param title: string = '';
  @Param showsBack: boolean = false;
  @Param leftTitle: string = '';
  @Param rightTitle: string = '';
  @Param rightSymbol: Resource | undefined = undefined;
  @Param rightLabel: string = '';
  @Param rightId: string = '';
  @Param barColor: ResourceColor = $r('sys.color.background_primary');
  @Param tint: ResourceColor = $r('sys.color.brand');
  @Param titleColor: ResourceColor = $r('sys.color.font_primary');
  @Event onBack: () => void = () => {
  };
  @Event onLeft: () => void = () => {
  };
  @Event onRight: () => void = () => {
  };
  @BuilderParam rightView: () => void = this.noView;
  @Param hasRightView: boolean = false;

  @Builder
  noView() {
  }

  build() {
    Stack() {
      Text(this.title)
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.titleColor)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .padding({ left: 96, right: 96 })
        .accessibilityRole(AccessibilityRoleType.TITLE_BAR)
      Row() {
        if (this.showsBack) {
          Row() {
            SymbolGlyph($r('sys.symbol.chevron_backward')).fontSize(22).fontColor([this.tint])
          }
          .height(44)
          .padding({ left: 8, right: 12 })
          .accessibilityText($r('app.string.discover_back'))
          .onClick(() => this.onBack())
        } else if (this.leftTitle.length > 0) {
          Text(this.leftTitle).fontSize(17).fontColor(this.tint).height(44).padding({ left: 16, right: 12 })
            .onClick(() => this.onLeft())
        }
        Blank()
        if (this.hasRightView) {
          this.rightView()
        } else if (this.rightSymbol !== undefined) {
          Row() {
            SymbolGlyph(this.rightSymbol).fontSize(22).fontColor([this.tint])
          }
          .height(44)
          .padding({ left: 12, right: 16 })
          .accessibilityText(this.rightLabel)
          .id(this.rightId)
          .onClick(() => this.onRight())
        } else if (this.rightTitle.length > 0) {
          Text(this.rightTitle).fontSize(17).fontColor(this.tint).height(44).padding({ left: 12, right: 16 })
            .id(this.rightId)
            .onClick(() => this.onRight())
        }
      }
      .width('100%')
    }
    .width('100%')
    .height(44)
    .backgroundColor(this.barColor)
  }
}

/**
 * A row of a grouped list (UITableViewCell): an optional image, the text, an optional subtitle and the disclosure
 * chevron.
 */
@ComponentV2
export struct CYLDemoCell {
  @Param text: string = '';
  @Param subtitle: string = '';
  @Param image: Resource | undefined = undefined;
  @Param tintsImage: boolean = true;
  @Param imageTint: ResourceColor = $r('sys.color.font_secondary');
  @Param showsDivider: boolean = true;

  build() {
    Column() {
      Row({ space: 12 }) {
        if (this.image !== undefined && this.image.type === 20000) {
          if (this.tintsImage) {
            // fillColor tints SVG images only; the PNG placeholder images (CYLSearch<Name>@2x.png) get the same secondary grey
            // (iOS `secondaryLabelColor`, #8E8E93) through a color filter that keeps their alpha.
            Image(this.image).width(28).height(28).fillColor(this.imageTint)
              .colorFilter(new ColorFilter([0, 0, 0, 0, 0.557, 0, 0, 0, 0, 0.557, 0, 0, 0, 0, 0.576, 0, 0, 0, 1, 0]))
          } else {
            Image(this.image).width(28).height(28)
          }
        } else if (this.image !== undefined) {
          SymbolGlyph(this.image).fontSize(24).fontColor([this.imageTint])
        }
        Column({ space: 2 }) {
          Text(this.text).fontSize(17).fontColor($r('sys.color.font_primary'))
          if (this.subtitle.length > 0) {
            Text(this.subtitle).fontSize(13).fontColor($r('sys.color.font_secondary'))
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        SymbolGlyph($r('sys.symbol.chevron_right')).fontSize(16).fontColor([$r('sys.color.font_tertiary')])
      }
      .width('100%')
      .constraintSize({ minHeight: 44 })
      .padding({ left: 16, right: 16, top: 10, bottom: 10 })
      if (this.showsDivider) {
        Divider().strokeWidth(0.5).color($r('sys.color.comp_divider')).margin({ left: 16 })
      }
    }
    .accessibilityGroup(true)
    .accessibilityRole(AccessibilityRoleType.BUTTON)
  }
}

/**
 * Where the tab icons come from (iOS `CYLDemoTabIconSource`, a user default and a launch argument): 0 the symbols of
 * CYLTabBarConfiguration.json, 1 SVGA files set in code (the initialization keys), 2 SVGA files of
 * CYLTabBarConfiguration_svga.json. Kept in AppStorage (`pages/Index.ets` watches it) and in preferences (kept across
 * launches, as NSUserDefaults).
 */
export const CYL_TAB_ICON_SOURCE_KEY: string = 'CYLDemoTabIconSource';

const CYL_DEMO_PREFERENCES: string = 'CYLSearchExample';

/**
 * The stored tab icon source, 0 when none was chosen.
 */
export function cylStoredTabIconSource(context: common.Context): number {
  try {
    const store = preferences.getPreferencesSync(context, { name: CYL_DEMO_PREFERENCES });
    const value = store.getSync(CYL_TAB_ICON_SOURCE_KEY, 0) as number;
    return value >= 0 && value <= 2 ? value : 0;
  } catch (error) {
    return 0;
  }
}

/**
 * Chooses the tab icon source: stored for the next launch and set in AppStorage, so the tab bar changes now.
 */
export function cylSetTabIconSource(context: common.Context, source: number): void {
  AppStorage.setOrCreate<number>(CYL_TAB_ICON_SOURCE_KEY, source);
  try {
    const store = preferences.getPreferencesSync(context, { name: CYL_DEMO_PREFERENCES });
    store.putSync(CYL_TAB_ICON_SOURCE_KEY, source);
    store.flush();
  } catch (error) {
    // Kept for this run only.
  }
}

/**
 * The image size of the example's raised plus button (vp), as the iOS example (AGENTS.md, "Example layer, raised plus
 * button").
 */
export const CYL_PLUS_IMAGE_SIZE: number = 56;

/**
 * How far the raised plus button rises above the tab bar (vp), from cyltabbar's `cyl_plusButtonOverhang` (24 for the
 * 56 vp image above an aligned title in the 49 vp bar). Scrolling lists end this much lower (`contentEndOffset`), so
 * their last rows can scroll clear of the plus button, which never covers content at rest. The layout lives in the
 * library (CYLTabBarController PR #812, rule "Fix issues in the core first"); the example only applies it.
 */
export const CYL_PLUS_OVERHANG: number = cyl_plusButtonOverhang({ imageSize: CYL_PLUS_IMAGE_SIZE, title: '+' });

import {
  CYLControlState,
  CYLEdgeInsets,
  CYLFont,
  CYLMenuStyle,
  CYLSize,
  CYLTagBackgroundStyle,
  CYLTagListState
} from '@cyl/classifymenu';
import { CYLSearchResources } from './CYLSearchResources';

// MARK: - Pure logic (begin): no ArkUI, no kit; harmonyos/scripts/host-logic-test.mjs runs it with Node.

/**
 * Whether a background style name asks for the glass material: "liquidGlass", case-insensitive; anything else, "" or
 * "flat" is flat (iOS `applyBackgroundStyle(named:to:)`).
 */
function cylSearchTagIsLiquidGlass(name: string): boolean {
  return name.toLowerCase() === 'liquidglass';
}

/**
 * Whether a grid of `columns` titles per row can be applied: 0 or less leaves the list as it is (iOS
 * `applyGrid(columns:to:)`).
 */
function cylSearchTagGridApplies(columns: number): boolean {
  return columns > 0;
}

/**
 * The default look of a tag that does not depend on the theme, in vp and fp (iOS `applyDefaults(to:)`).
 */
interface CYLSearchTagMetrics {
  /**
   * The horizontal space between a tag's border and its title.
   */
  margin: number;
  /**
   * The title's font size.
   */
  fontSize: number;
  /**
   * The tag's height.
   */
  itemHeight: number;
  /**
   * The space between two tags of a row.
   */
  interitemSpacing: number;
  /**
   * The space between two rows.
   */
  lineSpacing: number;
  /**
   * The section's insets: top, left, bottom, right.
   */
  sectionInsets: number[];
  /**
   * The height of a section header.
   */
  headerHeight: number;
  /**
   * The header title's font size.
   */
  headerFontSize: number;
  /**
   * The space before and after the header title.
   */
  headerHorizontalInset: number;
}

/**
 * The metrics of the default tag look (iOS `applyDefaults(to:)`): 14 margin, 17 text, 36 high, 12 apart, a 16 inset and
 * a 44 high header with a 20 title.
 */
function cylSearchTagDefaultMetrics(): CYLSearchTagMetrics {
  return {
    margin: 14,
    fontSize: 17,
    itemHeight: 36,
    interitemSpacing: 12,
    lineSpacing: 12,
    sectionInsets: [4, 16, 24, 16],
    headerHeight: 44,
    headerFontSize: 20,
    headerHorizontalInset: 16
  };
}

/**
 * The metrics of the grid look (iOS `applyGrid(columns:to:)`): 17 medium titles, 36 high rows 16 apart, a 16 inset.
 */
function cylSearchTagGridMetrics(): CYLSearchTagMetrics {
  return {
    margin: 0,
    fontSize: 17,
    itemHeight: 36,
    interitemSpacing: 12,
    lineSpacing: 16,
    sectionInsets: [4, 16, 16, 16],
    headerHeight: 44,
    headerFontSize: 20,
    headerHorizontalInset: 16
  };
}

// MARK: - Pure logic (end)

/**
 * The refresh icon and text of a tag list's section header, one place for every page (iOS `CYLSearchTagListHeader`).
 * The header of a tag list is drawn by the page (title and `CYLSearchRefreshButton`), so there is no More button to
 * change: the page uses these two values.
 */
export class CYLSearchTagListHeader {
  /**
   * The refresh icon, the system symbol "arrow.clockwise": the icon is the default, not a text button.
   */
  static readonly refreshImage: Resource | undefined = CYLSearchResources.imageNamed('refresh');
  /**
   * The accessibility label of the refresh icon, in the language the app shows ("Refresh", 更新, 刷新, 重新整理).
   */
  static readonly refreshAccessibilityLabel: ResourceStr = $r('app.string.cyl_tagList_refresh');
}

/**
 * The search core's default style of a tag list, the look of the iOS example's recent searches (iOS
 * `CYLSearchTagListStyle`).
 */
export class CYLSearchTagListStyle {
  /**
   * The corner radius that makes a capsule: the corners are as round as the tag's height allows. The one named constant
   * for it (the same as `CYLAnimatedItemCornerRadiusCapsule`): pass it, never the literal 1000.
   */
  static readonly capsuleCornerRadius: number = 1000;
  /**
   * The corner radius of every tag, in vp. The default `capsuleCornerRadius` is a capsule, as in the iOS example's recent
   * searches; 0 is square corners; another value is a rounded rectangle.
   */
  static tagCornerRadius: number = CYLSearchTagListStyle.capsuleCornerRadius;
  /**
   * The background of every tag, handed to the style's `backgroundStyle`: flat by default (the tag's own colors),
   * `liquidGlass` for the glass material.
   */
  static tagBackgroundStyle: CYLTagBackgroundStyle = CYLTagBackgroundStyle.flat;
  /**
   * Called with the style after the defaults are set, to change any value of it. Undefined by default.
   */
  static styleCustomizer: ((style: CYLMenuStyle) => void) | undefined = undefined;

  /**
   * Sets the defaults on `style`: white tags with a 1 vp separator border and `tagCornerRadius`, 17 fp text, 36 vp high,
   * 12 vp apart, a 16 vp section inset and a bold 20 fp section header, then calls `styleCustomizer`. Values the defaults
   * do not name (for example the clear background) stay as they are.
   */
  static applyDefaults(style: CYLMenuStyle): void {
    const metrics = cylSearchTagDefaultMetrics();
    const flat = CYLSearchTagListStyle.tagBackgroundStyle === CYLTagBackgroundStyle.flat;
    [CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED].forEach((state: number) => {
      const appearance = style.appearance(state);
      // A glass tag is a tint on the material, no border; a flat tag is white with a light border.
      if (flat) {
        appearance.backgroundColor = $r('sys.color.background_primary');
        appearance.borderColor = $r('sys.color.comp_divider');
        appearance.borderWidth = 1;
      } else {
        // The glass tint is translucent: a plain page shows glass only through it.
        appearance.backgroundColor = state === CYLControlState.SELECTED ? '#4D0A59F7' :
          $r('sys.color.comp_background_tertiary');
        appearance.borderWidth = 0;
      }
      appearance.cornerRadius = CYLSearchTagListStyle.tagCornerRadius;
      appearance.contentInsets = new CYLEdgeInsets(0, metrics.margin, 0, metrics.margin);
      appearance.font = new CYLFont(metrics.fontSize, FontWeight.Normal);
      appearance.textColor = $r('sys.color.font_primary');
    });
    style.backgroundStyle = CYLSearchTagListStyle.tagBackgroundStyle;
    style.itemHeight = metrics.itemHeight;
    style.interitemSpacing = metrics.interitemSpacing;
    style.lineSpacing = metrics.lineSpacing;
    style.sectionInsets = new CYLEdgeInsets(metrics.sectionInsets[0], metrics.sectionInsets[1],
      metrics.sectionInsets[2], metrics.sectionInsets[3]);
    CYLSearchTagListStyle.applyHeaderLook(style, metrics);
    CYLSearchTagListStyle.styleCustomizer?.(style);
  }

  /**
   * Sets the defaults on `list`'s style (the list's other values stay).
   */
  static applyDefaultStyle(list: CYLTagListState): void {
    const style = list.style;
    CYLSearchTagListStyle.applyDefaults(style);
    list.style = style;
  }

  /**
   * Turns `list` into a grid of `columns` plain titles per row (the style's `gridStyle`, 17 fp medium text, 36 vp rows
   * 16 vp apart, a tag's own image at its own size), the look of the iOS example's discover topics, with the section
   * header of `applyDefaultStyle`; 0 or less leaves the list as it is. Then calls `styleCustomizer`.
   */
  static applyGrid(columns: number, list: CYLTagListState): void {
    if (!cylSearchTagGridApplies(columns)) {
      return;
    }
    const metrics = cylSearchTagGridMetrics();
    const style = CYLMenuStyle.gridStyle(columns);
    [CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED].forEach((state: number) => {
      style.appearance(state).font = new CYLFont(metrics.fontSize, FontWeight.Medium);
    });
    style.imageSize = new CYLSize(0, 0);
    style.itemHeight = metrics.itemHeight;
    style.lineSpacing = metrics.lineSpacing;
    style.sectionInsets = new CYLEdgeInsets(metrics.sectionInsets[0], metrics.sectionInsets[1],
      metrics.sectionInsets[2], metrics.sectionInsets[3]);
    style.backgroundColor = '#00000000';
    CYLSearchTagListStyle.applyHeaderLook(style, metrics);
    CYLSearchTagListStyle.styleCustomizer?.(style);
    list.style = style;
  }

  /**
   * Sets the background of every tag of `list` by name, the one parameter of a Liquid Glass list: "liquidGlass"
   * (case-insensitive) is the glass material, anything else, "" or "flat" is flat. The list's other style values stay.
   */
  static applyBackgroundStyle(name: string, list: CYLTagListState): void {
    const style = list.style;
    style.backgroundStyle = cylSearchTagIsLiquidGlass(name) ? CYLTagBackgroundStyle.liquidGlass :
    CYLTagBackgroundStyle.flat;
    list.style = style;
  }

  private static applyHeaderLook(style: CYLMenuStyle, metrics: CYLSearchTagMetrics): void {
    style.headerHeight = metrics.headerHeight;
    style.headerFont = new CYLFont(metrics.headerFontSize, FontWeight.Bold);
    style.headerTextColor = $r('sys.color.font_primary');
    style.headerHorizontalInset = metrics.headerHorizontalInset;
  }
}

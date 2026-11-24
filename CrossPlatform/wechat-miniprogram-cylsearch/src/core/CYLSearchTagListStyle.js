// CYLSearchTagListStyle.swift and CYLSearchTagListHeader.swift for the mini program: the default look of the tag lists that
// sit with a search bar, as the style of CollectionViewClassifyMenu's `<cyl-tag-list configuration>` (the keys are those of
// iOS `CYLMenuStyle`; sizes in px). The style is a plain object that these functions change in place.
'use strict';

const { CYLSearchResources } = require('./CYLSearchResources');

/**
 * The capsule corner radius of CYLAnimatedItem (`CYLAnimatedItemCornerRadiusCapsule`): pass it, never the literal.
 */
const CYL_ANIMATED_ITEM_CORNER_RADIUS_CAPSULE = 1000;

/**
 * The refresh icon and text of a tag list's section header (iOS `CYLSearchTagListHeader`).
 */
class CYLSearchTagListHeader {
  /**
   * The refresh icon (`images/refresh.svg` of this package): the icon is the default, not a text button.
   */
  static get refreshImage() {
    return CYLSearchResources.imageNamed('refresh');
  }

  /**
   * The label of the refresh icon for screen readers, in the language of the app ("Refresh", 更新, 刷新, 重新整理).
   */
  static get refreshAccessibilityLabel() {
    return CYLSearchResources.localizedString(undefined, 'tagList.refresh');
  }

  /**
   * Sets the refresh icon as the icon of the header More button of `configuration.style`, in place of the three dots.
   */
  static applyRefreshIcon(configuration) {
    configuration.style = Object.assign({}, configuration.style, { moreButtonImage: CYLSearchTagListHeader.refreshImage });
  }
}

let tagCornerRadius = CYL_ANIMATED_ITEM_CORNER_RADIUS_CAPSULE;
let tagBackgroundStyle = 'flat';
let styleCustomizer;

/**
 * The search bar core's default style of a tag list, the look of the iOS example's recent searches (iOS
 * `CYLSearchTagListStyle`).
 */
class CYLSearchTagListStyle {
  /**
   * The corner radius of every tag, in px; the default is the capsule (1000), 0 is square corners.
   */
  static get tagCornerRadius() {
    return tagCornerRadius;
  }

  static set tagCornerRadius(value) {
    tagCornerRadius = Number(value);
  }

  /**
   * The background of every tag: "flat" (the tag's own colors, default) or "liquidGlass" (the glass material).
   */
  static get tagBackgroundStyle() {
    return tagBackgroundStyle;
  }

  static set tagBackgroundStyle(value) {
    tagBackgroundStyle = String(value).toLowerCase() === 'liquidglass' ? 'liquidGlass' : 'flat';
  }

  /**
   * Called with the style after the defaults are set, to change any value of it; undefined by default.
   */
  static get styleCustomizer() {
    return styleCustomizer;
  }

  static set styleCustomizer(value) {
    styleCustomizer = typeof value === 'function' ? value : undefined;
  }

  /**
   * Sets the defaults on `style`: white tags with a 1 px border and `tagCornerRadius`, 17 px text, 36 px high, 12 px apart,
   * a 16 px section inset and a bold 20 px section header, then calls `styleCustomizer`. `dark` picks the dark colors.
   * Returns `style`.
   */
  static applyDefaults(style, dark = false) {
    const flat = tagBackgroundStyle === 'flat';
    ['normal', 'selected', 'disabled'].forEach((state) => {
      const appearance = style[state] || (style[state] = {});
      if (flat) {
        Object.assign(appearance, { backgroundColor: dark ? '#1C1C1E' : '#FFFFFF', borderColor: dark ? '#38383A' : '#C6C6C8', borderWidth: 1 });
      } else {
        // The glass tint is translucent: a plain page shows glass only through it.
        Object.assign(appearance, {
          backgroundColor: state === 'selected' ? 'rgba(0, 104, 248, 0.3)' : (dark ? '#2C2C2E' : '#E5E5EA'),
          borderWidth: 0,
        });
      }
      Object.assign(appearance, { cornerRadius: tagCornerRadius, contentInsets: { top: 0, left: 14, bottom: 0, right: 14 }, fontSize: 17, textColor: dark ? '#FFFFFF' : '#000000' });
    });
    Object.assign(style, {
      backgroundStyle: tagBackgroundStyle,
      itemHeight: 36,
      interitemSpacing: 12,
      lineSpacing: 12,
      sectionInsets: { top: 4, left: 16, bottom: 24, right: 16 },
      headerHeight: 44,
      headerFontSize: 20,
      headerFontWeight: 'bold',
      headerTextColor: dark ? '#FFFFFF' : '#000000',
      headerHorizontalInset: 16,
    });
    if (typeof styleCustomizer === 'function') styleCustomizer(style);
    return style;
  }

  /**
   * Sets the defaults on a copy of the style of `configuration` (a tag list configuration; its other values stay), and
   * the refresh icon of its header (`CYLSearchTagListHeader`).
   */
  static applyDefaultStyle(configuration, dark = false) {
    configuration.style = CYLSearchTagListStyle.applyDefaults(JSON.parse(JSON.stringify(configuration.style || {})), dark);
    CYLSearchTagListHeader.applyRefreshIcon(configuration);
  }

  /**
   * Turns `configuration` into a grid of `columns` plain titles per row (17 px medium text, 36 px rows 16 px apart, no
   * image), the look of the iOS example's discover topics, with the section header and the refresh icon as in
   * `applyDefaultStyle`; 0 or less leaves it as it is.
   */
  static applyGrid(columns, configuration, dark = false) {
    if (!(columns > 0)) return;
    const style = {
      itemsPerRow: Math.floor(columns),
      imageSize: 0,
      itemHeight: 36,
      lineSpacing: 16,
      sectionInsets: { top: 4, left: 16, bottom: 16, right: 16 },
      backgroundColor: 'transparent',
      headerHeight: 44,
      headerFontSize: 20,
      headerFontWeight: 'bold',
      headerTextColor: dark ? '#FFFFFF' : '#000000',
      headerHorizontalInset: 16,
      moreButtonImage: CYLSearchTagListHeader.refreshImage,
    };
    ['normal', 'selected', 'disabled'].forEach((state) => {
      style[state] = { fontSize: 17, fontWeight: 'medium', textColor: dark ? '#FFFFFF' : '#000000' };
    });
    configuration.style = style;
  }

  /**
   * Sets the background of every tag of `configuration` by name: "liquidGlass" (case-insensitive) is the glass
   * material, anything else, "" or "flat" is flat; the other style values stay.
   */
  static applyBackgroundStyle(name, configuration) {
    configuration.style = Object.assign({}, configuration.style, { backgroundStyle: String(name).toLowerCase() === 'liquidglass' ? 'liquidGlass' : 'flat' });
    CYLSearchTagListHeader.applyRefreshIcon(configuration);
  }
}

module.exports = { CYLSearchTagListHeader, CYLSearchTagListStyle, CYL_ANIMATED_ITEM_CORNER_RADIUS_CAPSULE };

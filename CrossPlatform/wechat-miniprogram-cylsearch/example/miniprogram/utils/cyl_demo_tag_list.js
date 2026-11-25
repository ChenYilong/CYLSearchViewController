// The tag list configuration of a grouped demo list (docs/instructions/example-demos.md): sections with a titled header, the shared
// style (CYLSearchTagListStyle: glass tags and glass board), wrapping titles, a 3-row fold whose control is the last tag with the
// chevron icon only (set explicitly), no selection, a long press shows the subtitle in a callout.
const { CYLSearchTagListStyle } = require('../components/core/CYLSearchTagListStyle');

/**
 * `sections`: [{ title, items: [{ title, subtitle }] }]; returns the `configuration` of a `<cyl-tag-list>`.
 */
function cylDemoTagConfiguration(sections) {
  let dark = false;
  try {
    dark = (wx.getAppBaseInfo ? wx.getAppBaseInfo() : wx.getSystemInfoSync()).theme === 'dark';
  } catch (error) {
    dark = false;
  }
  const configuration = {
    selectionMode: 'none',
    defaultVisibleRows: 3,
    foldControl: { position: 'tail', content: 'icon' },
    longPressAction: 'callout',
    style: { titleMaxLines: 'unlimited' },
    sections,
  };
  CYLSearchTagListStyle.tagBackgroundStyle = 'liquidGlass';
  CYLSearchTagListStyle.applyDefaultStyle(configuration, dark);
  CYLSearchTagListStyle.applyBackgroundStyle('liquidGlass', configuration);
  return configuration;
}

module.exports = { cylDemoTagConfiguration };

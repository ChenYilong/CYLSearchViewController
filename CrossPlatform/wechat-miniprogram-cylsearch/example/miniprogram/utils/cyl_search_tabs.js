// The example's tab bar: the iOS example's CYLTabBarConfiguration.json (four tabs and the plus button, whose "plus"
// page is a tab of its own), read by cyl-tab-bar of CYLTabBarController's mini program package. The titles are the
// iOS CYLSearchTabs.strings (utils/cyl_demo_resources.js). The plus button keeps the mini program sizes of the raised
// button; the tab pages are the five pages of app.json "tabBar".
const { cylDemoText } = require('./cyl_demo_text');

const configuration = {
  CYLTabBarControllerContext: 'CYLSearchExample',
  CYLTabBarControllerTitlePositionAdjustment: '{0, -2}',
  CYLTabBarControllerTabBarItemsAttributes: [
    { CYLTabBarItemTitle: 'tab.search', CYLTabBarItemImage: 'system:magnifyingglass',
      CYLTabBarItemSelectedImage: 'system:magnifyingglass', CYLTabBarItemIdentifier: 'search',
      CYLTabBarItemPageIdentifier: 'search' },
    { CYLTabBarItemTitle: 'tab.examples', CYLTabBarItemImage: 'system:list.bullet',
      CYLTabBarItemSelectedImage: 'system:list.bullet', CYLTabBarItemIdentifier: 'examples',
      CYLTabBarItemPageIdentifier: 'examples' },
    { CYLTabBarItemTitle: 'tab.tagStyle', CYLTabBarItemImage: 'system:tag',
      CYLTabBarItemSelectedImage: 'system:tag.fill', CYLTabBarItemIdentifier: 'tagStyle',
      CYLTabBarItemPageIdentifier: 'tagStyle' },
    { CYLTabBarItemTitle: 'tab.discover', CYLTabBarItemImage: 'system:sparkle.magnifyingglass',
      CYLTabBarItemSelectedImage: 'system:sparkle.magnifyingglass', CYLTabBarItemIdentifier: 'discover',
      CYLTabBarItemPageIdentifier: 'discover' },
  ],
  CYLTabBarControllerPlusButton: {
    CYLTabBarItemTitle: 'tab.searchBar',
    CYLTabBarItemImage: 'system:plus.circle.fill',
    CYLTabBarItemIdentifier: 'plus',
    CYLTabBarItemPageIdentifier: 'plus',
    CYLPlusButtonSize: '{56, 56}',
    CYLPlusButtonCenterYMultiplier: 0.3,
    CYLPlusButtonIndexInTabBar: 2,
  },
};

const symbols = {
  magnifyingglass: '/assets/tab/search.svg',
  'list.bullet': '/assets/tab/examples.svg',
  tag: '/assets/tab/tag.svg',
  'tag.fill': '/assets/tab/tag-fill.svg',
  'sparkle.magnifyingglass': '/assets/tab/discover.svg',
  'plus.circle.fill': '/assets/tab/plus.svg',
};

/** The tab titles in the WeChat language (en, ja, zh-Hans, zh-Hant, as on iOS). */
function cylTabStrings() {
  const keys = ['tab.search', 'tab.examples', 'tab.searchBar', 'tab.tagStyle', 'tab.discover'];
  const strings = {};
  keys.forEach((key) => { strings[key] = cylDemoText(key); });
  return strings;
}

module.exports = { configuration, symbols, cylTabStrings };

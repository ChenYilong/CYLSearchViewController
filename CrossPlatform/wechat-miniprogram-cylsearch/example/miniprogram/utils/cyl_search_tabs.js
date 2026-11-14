// The example's tab bar: the same configuration keys as the iOS and Android examples (CYLTabBarConfiguration.json),
// read by cyl-tab-bar of CYLTabBarController's mini program package. Tab pages are limited to five, so the plus button
// opens its page (pages/plus, the search bar samples) with wx.navigateTo.
const configuration = {
  "CYLTabBarControllerContext": "CYLSearchExampleMiniProgram",
  "CYLTabBarControllerTabBarItemsAttributes": [
    {
      "CYLTabBarItemTitle": "tab.search",
      "CYLTabBarItemImage": "system:magnifyingglass",
      "CYLTabBarItemIdentifier": "search",
      "CYLTabBarItemPageIdentifier": "search"
    },
    {
      "CYLTabBarItemTitle": "tab.examples",
      "CYLTabBarItemImage": "system:list.bullet",
      "CYLTabBarItemIdentifier": "examples",
      "CYLTabBarItemPageIdentifier": "examples"
    },
    {
      "CYLTabBarItemTitle": "tab.listStyle",
      "CYLTabBarItemImage": "system:list.style",
      "CYLTabBarItemIdentifier": "listStyle",
      "CYLTabBarItemPageIdentifier": "listStyle"
    },
    {
      "CYLTabBarItemTitle": "tab.tagStyle",
      "CYLTabBarItemImage": "system:tag",
      "CYLTabBarItemIdentifier": "tagStyle",
      "CYLTabBarItemPageIdentifier": "tagStyle"
    },
    {
      "CYLTabBarItemTitle": "tab.discover",
      "CYLTabBarItemImage": "system:discover",
      "CYLTabBarItemIdentifier": "discover",
      "CYLTabBarItemPageIdentifier": "discover"
    }
  ],
  "CYLTabBarControllerPlusButton": {
    "CYLTabBarItemTitle": "tab.searchBar",
    "CYLTabBarItemImage": "system:plus.circle.fill",
    "CYLTabBarItemIdentifier": "plus",
    "CYLTabBarItemPageIdentifier": "plus",
    "CYLPlusButtonSize": "{56, 56}",
    "CYLPlusButtonCenterYMultiplier": 0.3,
    "CYLPlusButtonIndexInTabBar": 2
  }
};
const strings = {
  "en": {
    "tab.search": "Search",
    "tab.examples": "Examples",
    "tab.listStyle": "List style",
    "tab.tagStyle": "Tag style",
    "tab.discover": "Discover",
    "tab.searchBar": "Search bar"
  },
  "zh-Hans": {
    "tab.search": "搜索",
    "tab.examples": "示例",
    "tab.listStyle": "列表样式",
    "tab.tagStyle": "标签样式",
    "tab.discover": "发现",
    "tab.searchBar": "搜索栏"
  }
};
const symbols = {
  magnifyingglass: '/assets/tab/search.svg',
  'list.bullet': '/assets/tab/examples.svg',
  'list.style': '/assets/tab/list-style.svg',
  tag: '/assets/tab/tag.svg',
  discover: '/assets/tab/discover.svg',
  'plus.circle.fill': '/assets/tab/plus.svg',
};
function cylTabStrings() {
  let language = 'en';
  try { language = (wx.getAppBaseInfo ? wx.getAppBaseInfo() : wx.getSystemInfoSync()).language || 'en'; } catch (e) {}
  return /^zh/.test(language) ? strings['zh-Hans'] : strings.en;
}
module.exports = { configuration, symbols, cylTabStrings };

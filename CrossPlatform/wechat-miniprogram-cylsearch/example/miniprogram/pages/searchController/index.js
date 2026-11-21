// "Search controller" (iOS CYLSearchControllerDemoViewController, a replica of QMUI's QDSearchViewController): ten keywords with a
// search bar as the header of the list; the search shows a launch view of recent searches while the text is empty (the
// history, or the eight suggestions without one, with a trash button), then the matching keywords (twenty rows each) with the
// match in the tint color, "No matching results" when nothing matches, and a swipe from the left edge ends the search.
const { cylDemoText } = require('../../utils/cyl_demo_text');
const { cylHostHeight } = require('../../utils/cyl_search_page');
const { tagCloud } = require('cyl-tag-list-miniprogram');

const KEYWORDS = ['Helps', 'Maintain', 'Liver', 'Health', 'Function', 'Supports', 'Healthy', 'Fat', 'Metabolism', 'Nuturally'];
// The eight suggestions of QDRecentSearchView, shown while there is no history.
const SUGGESTIONS = ['Helps', 'Maintain', 'Liver', 'Health', 'Function', 'Supports', 'Healthy', 'Fat'];
const TINT = '#007aff';

// The recent searches as tags: height 29, spacing 10, 14 pt, 4 pt corners and a 1 pt outline in the tint color.
function tagStyle() {
  const style = JSON.parse(JSON.stringify(tagCloud.defaultStyle()));
  ['normal', 'selected', 'disabled'].forEach((state) => {
    Object.assign(style[state], { fontSize: 14, cornerRadius: 4, borderWidth: 1, borderColor: TINT, textColor: TINT,
      backgroundColor: 'transparent', contentInsets: { top: 0, left: 20, bottom: 0, right: 20 } });
  });
  Object.assign(style, { itemHeight: 29, interitemSpacing: 10, lineSpacing: 10, sectionInsets: { top: 0, left: 0, bottom: 0, right: 0 } });
  return style;
}

Page({
  data: {
    title: '', hostHeight: 600, keywords: KEYWORDS, results: [], tags: [], hasHistory: false, tagStyle: tagStyle(), texts: {},
    placeholder: '',
  },
  onLoad() {
    this.setData({
      title: cylDemoText('demo.searchController'),
      hostHeight: cylHostHeight(),
      placeholder: cylDemoText('search.field'),
      texts: { recent: cylDemoText('controller.recent'), clear: cylDemoText('search.clearRecent'), launch: cylDemoText('controller.launch.label') },
    });
  },
  onReady() {
    this.reloadHistory();
  },
  // The launch view lists the history newest first, or the suggestions without one.
  reloadHistory() {
    const search = this.selectComponent('#search');
    const history = search ? search.history() : [];
    this.setData({
      hasHistory: history.length > 0,
      tags: (history.length ? history : SUGGESTIONS).map((title) => ({ identifier: title, title, isEnabled: true, isDeletable: false })),
    });
  },
  // iOS: the controller posts historyDidChangeNotification after a submitted query; the launch view reads the history again
  // while it stays on screen.
  onHistoryChange() {
    this.reloadHistory();
  },
  onWillPresent() {
    this.reloadHistory();
  },
  onClearHistory() {
    this.selectComponent('#search').clearHistory();
    this.reloadHistory();
  },
  // QDSearchViewController updateResultsForSearchString: the matching keywords, twenty rows each; the empty view when none.
  onUpdateResults(event) {
    const text = event.detail.text;
    const matches = text ? KEYWORDS.filter((keyword) => keyword.includes(text)) : [];
    const results = [];
    matches.forEach((keyword) => { for (let i = 0; i < 20; i += 1) results.push(keyword); });
    this.setData({ results });
    const search = this.selectComponent('#search');
    if (matches.length === 0) search.showEmptyView(cylDemoText('controller.noResults'));
    else search.hideEmptyView();
  },
});

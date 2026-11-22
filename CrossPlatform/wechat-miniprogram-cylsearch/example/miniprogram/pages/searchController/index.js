// "Search controller" (iOS CYLSearchControllerDemoViewController, a replica of QMUI's QDSearchViewController): ten keywords with a
// search bar as the header of the list. The core does the rest through its API: the launch view (the history, or the eight
// suggestions without one, as CollectionViewClassifyMenu's tag list with the trash button; a tapped tag submits), the
// matching keywords (twenty rows each) with the match in the tint color, "No matching results" when nothing matches, and a
// swipe from the left edge that ends the search. The page only answers updateresults with the rows.
const { cylDemoText } = require('../../utils/cyl_demo_text');
const { cylHostHeight } = require('../../utils/cyl_search_page');

const KEYWORDS = ['Helps', 'Maintain', 'Liver', 'Health', 'Function', 'Supports', 'Healthy', 'Fat', 'Metabolism', 'Nuturally'];
// The eight suggestions of QDRecentSearchView, shown while there is no history.
const SUGGESTIONS = ['Helps', 'Maintain', 'Liver', 'Health', 'Function', 'Supports', 'Healthy', 'Fat'];

Page({
  data: { title: '', hostHeight: 600, keywords: KEYWORDS, suggestions: SUGGESTIONS, results: [], placeholder: '', noResultsText: '' },
  onLoad() {
    this.setData({
      title: cylDemoText('demo.searchController'),
      hostHeight: cylHostHeight(),
      placeholder: cylDemoText('search.field'),
      noResultsText: cylDemoText('controller.noResults'),
    });
  },
  // QDSearchViewController updateResultsForSearchString: the matching keywords, twenty rows each.
  onUpdateResults(event) {
    const text = event.detail.text;
    const matches = text ? KEYWORDS.filter((keyword) => keyword.includes(text)) : [];
    const results = [];
    matches.forEach((keyword) => { for (let i = 0; i < 20; i += 1) results.push(keyword); });
    this.setData({ results });
  },
});

// The second-level search page that every first-level bar pushes (owner directive 2026-11-26): the bar of the tab's preset
// (the `preset` query) with the back button, the keyboard up (focusesOnAppear), and the recent and popular tag lists of the
// example data. The core's navigation bar brings the back button in on the first-level page; this page only shows it at once.
const { cylNavigationMetrics } = require('../../components/core/CYLSearchResources');
const { cylDemoText, cylDiscoverData } = require('../../utils/cyl_demo_text');
const { cylSearchedRecent } = require('../../utils/cyl_discover_logic');

Page({
  data: { preset: 'navigationField', searchButtonStyle: 'text', query: '', placeholder: '', fieldHeight: 36, recent: [], topics: [], texts: {} },
  onLoad(options) {
    const data = cylDiscoverData();
    const topics = data.discover.map((topic) => topic.title);
    this.setData({
      preset: (options && options.preset) || 'navigationField',
      searchButtonStyle: (options && options.searchButtonStyle) === 'icon' ? 'icon' : 'text',
      fieldHeight: cylNavigationMetrics().fieldHeight,
      placeholder: topics[0] || cylDemoText('discover.search'),
      recent: data.recentSearches.slice(),
      topics,
      texts: { recent: cylDemoText('discover.recent'), popular: cylDemoText('discover.title') },
    });
  },
  onTextChange(event) {
    this.setData({ query: event.detail.text });
  },
  onTagTap(event) {
    const title = event.currentTarget.dataset.title;
    this.setData({ query: title, recent: cylSearchedRecent(this.data.recent, title) });
  },
});

// The "Search" tab, a first-level page (iOS CYLSearchExampleViewController in a navigation controller): the navigation bar holds
// the whole search bar (pill preset); a tap on it pushes the second-level search page (pages/searchSecond). Below it the
// forty sample results of the example.
const { cylSelectTab } = require('../../utils/cyl_tab_page');
const { cylDemoText } = require('../../utils/cyl_demo_text');

Page({
  data: { placeholder: '', results: [] },
  onLoad() {
    this.setData({
      placeholder: cylDemoText('search.placeholder'),
      results: Array.from({ length: 40 }, (_, index) => cylDemoText('sample.result', index + 1)),
    });
  },
  onShow() {
    cylSelectTab(this, 'search');
  },
});

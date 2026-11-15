// The "Examples" tab (iOS CYLSearchDemoMenuViewController): the reproduction, the placeholder styles, the search bar
// and the other libraries' examples.
const { cylSelectTab } = require('../../utils/cyl_tab_page');
const { cylDemoText } = require('../../utils/cyl_demo_text');

const ROWS = [
  { key: 'demo.reproduction', url: '/pages/reproduction/index' },
  { key: 'demo.styles', url: '/pages/styles/index' },
  { key: 'demo.searchBar', url: '/pages/searchBar/index' },
  { key: 'demo.ports', url: '/pages/ports/index' },
];

Page({
  data: { title: '', rows: [] },
  onLoad() {
    this.setData({ title: cylDemoText('demo.title'), rows: ROWS.map((row) => ({ title: cylDemoText(row.key), url: row.url })) });
  },
  onShow() {
    cylSelectTab(this, 'examples');
  },
  onRow(event) {
    wx.navigateTo({ url: event.currentTarget.dataset.url });
  },
});

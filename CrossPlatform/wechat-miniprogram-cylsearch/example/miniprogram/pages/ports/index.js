// The ports of the examples of five search libraries (iOS CYLSearchPortsViewController).
const { cylDemoText } = require('../../utils/cyl_demo_text');

Page({
  data: {
    title: '',
    rows: [
      { title: 'lapism/search', subtitle: 'MaterialSearchBar + MaterialSearchView', url: '/pages/lapism/index' },
      { title: 'MiguelCatalan/MaterialSearchView', subtitle: 'Default, Themed, Voice, Sticky, Tabs, Input type', url: '/pages/materialMenu/index' },
      { title: 'yechaoa/MaterialDesign', subtitle: 'SearchViewActivity', url: '/pages/yechaoa/index' },
      { title: 'android-cjj/MaterialSearchView', subtitle: 'Circular reveal', url: '/pages/reveal/index' },
      { title: 'iammert/MultiSearchView', subtitle: 'MultiSearchView', url: '/pages/multiSearch/index' },
    ],
  },
  onLoad() {
    this.setData({ title: cylDemoText('demo.ports') });
  },
  onRow(event) {
    wx.navigateTo({ url: event.currentTarget.dataset.url });
  },
});

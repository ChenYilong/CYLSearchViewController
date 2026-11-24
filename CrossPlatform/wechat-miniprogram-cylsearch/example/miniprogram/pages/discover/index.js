// The "Discover" tab: a small entry page. The Discover page (pages/discoverSearch) is always pushed on top of it with
// wx.navigateTo (also at once, the first time), so its navigation bar always has a back button on the left, as the iOS
// example's second-level page.
const { cylSelectTab } = require('../../utils/cyl_tab_page');
const { cylDemoText } = require('../../utils/cyl_demo_text');

const DISCOVER_PAGE = '/pages/discoverSearch/index';
// Whether the Discover page was already opened once by itself (the first time this page shows).
let openedOnce = false;

Page({
  data: { title: '' },
  onLoad() {
    this.setData({ title: cylDemoText('tab.discover') });
  },
  onReady() {
    if (!openedOnce) {
      openedOnce = true;
      this.openDiscover();
    }
  },
  onShow() {
    cylSelectTab(this, 'discover');
  },
  openDiscover() {
    wx.navigateTo({ url: DISCOVER_PAGE });
  },
});

// The "Search" tab: the Issue #1317 reproduction (iOS CYLSearchExampleViewController in a navigation controller).
const { cylSelectTab } = require('../../utils/cyl_tab_page');

Page({
  onShow() {
    cylSelectTab(this, 'search');
  },
});

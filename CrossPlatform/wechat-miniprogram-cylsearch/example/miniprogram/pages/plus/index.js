// The plus button's page (iOS: the "plus" page of CYLTabBarConfiguration.json, a tab of its own): the search bar demo.
const { cylSelectTab } = require('../../utils/cyl_tab_page');

Page({
  onShow() {
    cylSelectTab(this, 'plus');
  },
});

// Switches tab pages on `select` and opens the plus button's page on `plustap`. Tab pages call
// this.getTabBar().cylSelect('<identifier>') in onShow so the selection follows the page.
const { configuration, symbols, cylTabStrings } = require('../utils/cyl_search_tabs');

Component({
  data: { configuration, symbolsByTheme: { default: symbols }, strings: {}, selectedIdentifier: 'search' },
  lifetimes: {
    attached() {
      this.setData({ strings: cylTabStrings() });
    },
  },
  methods: {
    cylSelect(identifier) {
      this.setData({ selectedIdentifier: identifier });
    },
    onSelect(event) {
      const { pageIdentifier, isPlusButton } = event.detail;
      if (isPlusButton) {
        this.onPlusTap();
        return;
      }
      wx.switchTab({ url: `/pages/${pageIdentifier}/index` });
    },
    onPlusTap() {
      wx.navigateTo({ url: '/pages/plus/index' });
    },
  },
});

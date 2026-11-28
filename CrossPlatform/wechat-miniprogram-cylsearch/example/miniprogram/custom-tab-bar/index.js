// Switches tab pages on `select`, the plus button's page included (iOS: the plus button selects its "plus" page).
// Tab pages call this.getTabBar().cylSelect('<identifier>') in onShow so the selection follows the page.
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
      wx.switchTab({ url: `/pages/${isPlusButton ? 'plus' : pageIdentifier}/index` });
    },
    onPlusTap() {
      wx.switchTab({ url: '/pages/plus/index' });
    },
  },
});

// The placeholder gallery: every scenario of CYLTableViewPlaceHolder's CYLPlaceholderScenarioCatalog, the placeholders
// the core's <cyl-search> shows (its emptyResultsScenario / emptySuggestionsScenario). The search core's own
// CYLSearchPlaceholderView and its 41 styles were removed as a duplicate of these (docs/search-core-merge.md). A row
// opens the scenario full screen.
const { cylDemoText } = require('../../utils/cyl_demo_text');
// The sub-dependency synced by scripts/sync-example.js (miniprogram_npm), named by its path: a mini program resolves
// no folder to its index.js.
const { CYLPlaceholderScenarioCatalog } = require('../../miniprogram_npm/cyl-placeholder-miniprogram/cyl-placeholder/cyl_scenario_catalog');

Page({
  data: { title: '', rows: [] },
  onLoad() {
    const rows = CYLPlaceholderScenarioCatalog.allScenarios.map((scenario) => ({
      scenario,
      text: CYLPlaceholderScenarioCatalog.localizedNameForScenario(scenario),
      url: `/pages/placeholderDetail/index?scenario=${scenario}`,
    }));
    this.setData({ title: cylDemoText('demo.styles'), rows });
  },
  onRow(event) {
    wx.navigateTo({ url: event.currentTarget.dataset.url });
  },
});

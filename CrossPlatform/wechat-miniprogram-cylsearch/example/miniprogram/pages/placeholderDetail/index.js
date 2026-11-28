// One placeholder full screen (iOS: a plain view controller titled with the row's text, the placeholder filling it):
// a CYLTableViewPlaceHolder scenario (option `scenario`), drawn by the example's empty view (cyl-placeholder with
// the Lottie player), as the core's <cyl-search> draws its empty placeholders.
const { CYLPlaceholderScenarioCatalog } = require('../../miniprogram_npm/cyl-placeholder-miniprogram/cyl-placeholder/cyl_scenario_catalog');

Page({
  data: { title: '', scenario: 'NoContent' },
  onLoad(options) {
    const scenario = CYLPlaceholderScenarioCatalog.scenarioNamed(options.scenario) || 'NoContent';
    this.setData({ scenario, title: CYLPlaceholderScenarioCatalog.localizedNameForScenario(scenario) });
  },
});

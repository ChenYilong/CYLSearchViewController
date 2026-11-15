// Port of yechaoa/MaterialDesign's SearchViewActivity (iOS CYLYechaoaSearchViewController): an iconified search view in
// the toolbar with a submit button, the Search return key, a hint and custom colors; a submitted query shows a snackbar
// and a search result, and clearing the text hides the result again.
const { cylDemoText } = require('../../utils/cyl_demo_text');
const { cylNavigationMetrics } = require('../../components/cyl-search/cyl_navigation_metrics');

Page({
  data: { keyword: '', result: '', showsResult: false, expanded: false, expandedWidth: 200 },
  onLoad() {
    const metrics = cylNavigationMetrics();
    this.setData({
      keyword: cylDemoText('demo.port.keyword'),
      result: cylDemoText('demo.port.result'),
      // The opened field takes the room of the title, like an expanded SearchView in the toolbar.
      expandedWidth: Math.max(200, metrics.windowWidth - metrics.trailingInset - 120),
    });
  },
  onSubmit(event) {
    this.selectComponent('#snackbar').show(cylDemoText('demo.port.searched', event.detail.text));
    this.setData({ showsResult: true });
  },
  onTextChange(event) {
    if (!event.detail.text) this.setData({ showsResult: false });
  },
  onIconifiedChange(event) {
    this.setData({ expanded: !event.detail.iconified });
  },
});

const { cylSelectTab } = require('../../utils/cyl_tab_page');
Page({
  data: { suggestions: ['Swift', 'Objective-C', 'Kotlin', 'Java', 'Dart', 'ArkTS', 'TypeScript', 'JavaScript', 'Rust', 'Go', 'C++', 'Python'], lastEvent: '' },
  onShow() {
    cylSelectTab(this, 'search');
  },
  openSearch() {
    const search = this.selectComponent('#search');
    if (search) search.show();
  },
  onSubmit(event) {
    this.setData({ lastEvent: `submit: ${event.detail.text}` });
  },
});

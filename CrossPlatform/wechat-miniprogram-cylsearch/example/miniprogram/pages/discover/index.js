const { cylSelectTab } = require('../../utils/cyl_tab_page');
Page({
  data: { suggestions: ['Swift', 'Objective-C', 'Kotlin', 'Java', 'Dart', 'ArkTS', 'TypeScript', 'JavaScript', 'Rust', 'Go', 'C++', 'Python'], lastEvent: '', items: [{ style: 'icon', title: 'Camera', image: '/components/images/camera.svg', accessibilityIdentifier: 'camera' }, { style: 'divider' }, { style: 'text', title: 'Search', accessibilityIdentifier: 'search' }] },
  onShow() {
    cylSelectTab(this, 'discover');
  },
  openSearch() {
    const search = this.selectComponent('#search');
    if (search) search.show();
  },
  onSubmit(event) {
    this.setData({ lastEvent: `submit: ${event.detail.text}` });
  },
  onItemSelect(event) {
    const title = event.detail.item ? event.detail.item.title : '';
    this.setData({ lastEvent: `itemselect: ${title}` });
    if (title === 'Search') this.openSearch();
  },
});

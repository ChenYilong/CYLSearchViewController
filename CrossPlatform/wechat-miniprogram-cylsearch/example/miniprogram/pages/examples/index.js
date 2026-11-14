const { cylSelectTab } = require('../../utils/cyl_tab_page');
Page({
  data: { suggestions: ['Swift', 'Objective-C', 'Kotlin', 'Java', 'Dart', 'ArkTS', 'TypeScript', 'JavaScript', 'Rust', 'Go', 'C++', 'Python'], lastEvent: '', rows: [{ title: 'List style', detail: 'Suggestions as a list, keyboard up', path: '/pages/listStyle/index' }, { title: 'Tag style', detail: 'Suggestions as tags, keyboard down', path: '/pages/tagStyle/index' }, { title: 'Discover', detail: 'Search bar with items', path: '/pages/discover/index' }, { title: 'Search bar', detail: 'Plain, bordered, leading and trailing slots', path: '/pages/plus/index' }] },
  onShow() {
    cylSelectTab(this, 'examples');
  },
  openSearch() {
    const search = this.selectComponent('#search');
    if (search) search.show();
  },
  onSubmit(event) {
    this.setData({ lastEvent: `submit: ${event.detail.text}` });
  },
  onRow(event) {
    const path = event.currentTarget.dataset.path;
    if (path === '/pages/plus/index') wx.navigateTo({ url: path });
    else wx.switchTab({ url: path });
  },
});

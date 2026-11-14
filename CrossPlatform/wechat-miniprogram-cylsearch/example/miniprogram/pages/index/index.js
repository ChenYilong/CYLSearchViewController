// The example page: the search bar with items (iOS Discover page), and the search page with tags, focus off.
Page({
  data: {
    items: [
      { style: 'divider' },
      { style: 'text', title: 'Search', accessibilityIdentifier: 'search' },
    ],
    suggestions: ['Swift', 'Objective-C', 'Kotlin', 'Dart', 'ArkTS', 'TypeScript', 'Rust', 'Go'],
    lastEvent: '',
  },
  onShow() {
    const tab = wx.getLaunchOptionsSync().query.open;
    if (tab === 'search') this.openSearch();
  },
  openSearch() {
    this.selectComponent('#search').show();
  },
  onItemSelect(event) {
    this.setData({ lastEvent: `itemselect: ${event.detail.item ? event.detail.item.title : ''}` });
    this.openSearch();
  },
  onSubmit(event) {
    this.setData({ lastEvent: `submit: ${event.detail.text}` });
  },
});

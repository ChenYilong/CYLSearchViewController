Page({
  data: { suggestions: ['Swift', 'Objective-C', 'Kotlin', 'Java', 'Dart', 'ArkTS', 'TypeScript', 'JavaScript', 'Rust', 'Go', 'C++', 'Python'], lastEvent: '', items: [{ style: 'icon', title: 'Voice', image: '/components/images/mic.svg' }, { style: 'divider' }, { style: 'text', title: 'Go' }] },
  openSearch() {
    const search = this.selectComponent('#search');
    if (search) search.show();
  },
  onSubmit(event) {
    this.setData({ lastEvent: `submit: ${event.detail.text}` });
  },
});

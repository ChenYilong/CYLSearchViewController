const { cylSelectTab } = require('../../utils/cyl_tab_page');
const { cylAnimationControls } = require('../../utils/cyl_animation_controls');

const { initialData, ...playbackHandlers } = cylAnimationControls('#search');

Page({
  ...playbackHandlers,
  data: { suggestions: ['Swift', 'Objective-C', 'Kotlin', 'Java', 'Dart', 'ArkTS', 'TypeScript', 'JavaScript', 'Rust', 'Go', 'C++', 'Python'], lastEvent: '', ...initialData },
  onShow() {
    cylSelectTab(this, 'listStyle');
  },
  openSearch() {
    const search = this.selectComponent('#search');
    if (search) search.show();
  },
  onSubmit(event) {
    this.setData({ lastEvent: `submit: ${event.detail.text}` });
  },
});

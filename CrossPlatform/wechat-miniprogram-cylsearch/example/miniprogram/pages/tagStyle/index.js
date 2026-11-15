// The "Tag style" tab (iOS CYLSuggestionDemoPages.tagStyleViewController): MaterialSearchView's six samples, the same
// suggestions and parameters as the list-style ports, shown as tags, the keyboard down until the field is tapped.
const { cylSelectTab } = require('../../utils/cyl_tab_page');

Page({
  onShow() {
    cylSelectTab(this, 'tagStyle');
  },
});

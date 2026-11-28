// The "Discover" tab, a first-level page: the navigation bar holds the whole search bar of the reference look; a tap on it
// pushes the Discover page (pages/discoverSearch) (the core navigates). The core brings the back button in and narrows the
// bar, the swipe back or the back button return to this page and the core takes the back button out again.
const { cylSelectTab } = require('../../utils/cyl_tab_page');
const { cylDemoText, cylDiscoverData } = require('../../utils/cyl_demo_text');

Page({
  data: { title: '', placeholder: '' },
  onLoad() {
    const first = cylDiscoverData().discover[0];
    this.setData({ title: cylDemoText('tab.discover'), placeholder: first ? first.title : cylDemoText('discover.search') });
  },
  onShow() {
    cylSelectTab(this, 'discover');
  },
});

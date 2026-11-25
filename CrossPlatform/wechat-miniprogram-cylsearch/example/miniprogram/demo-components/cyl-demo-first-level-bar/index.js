// The first-level search bar of a tab page: `preset` (a CYLSearchBarPreset name, one per tab), `placeholder`, and
// `pushUrl` (the second-level page; by default pages/searchSecond with the same preset). With `withItems` the bar of the
// reference look gets the camera inside it, then the core's default search button (the Discover tab).
const { cylNavigationMetrics } = require('../../components/core/CYLSearchResources');
const { cylDemoText } = require('../../utils/cyl_demo_text');

const CAMERA_IMAGE = '/assets/discover/camera.viewfinder.svg';

Component({
  properties: {
    preset: { type: String, value: 'navigationField' },
    placeholder: { type: String, value: '' },
    pushUrl: { type: String, value: '' },
    withItems: { type: Boolean, value: false },
    // The core's default search button style: "text" (the default) or "icon" (the Search tab).
    searchButtonStyle: { type: String, value: 'text' },
  },
  data: { url: '', fieldHeight: 36, items: [] },
  lifetimes: {
    attached() {
      const p = this.properties;
      this.setData({
        url: p.pushUrl || `/pages/searchSecond/index?preset=${p.preset}&searchButtonStyle=${p.searchButtonStyle}`,
        fieldHeight: cylNavigationMetrics().fieldHeight,
        items: p.withItems ? [
          { style: 'icon', title: cylDemoText('discover.imageSearch'), image: CAMERA_IMAGE, accessibilityIdentifier: 'camera' },
        ] : [],
      });
    },
  },
  methods: {
    // The bar's field was tapped (the items and the core's default search button take their own taps): the core's push.
    onFieldTap() {
      const navigation = this.selectComponent('#nav');
      if (navigation) navigation.firstLevelTapped();
    },
  },
});

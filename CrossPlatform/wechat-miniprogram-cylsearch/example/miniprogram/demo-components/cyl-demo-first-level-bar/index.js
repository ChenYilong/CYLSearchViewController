// The first-level search bar of a tab page: `preset` (a CYLSearchBarPreset name, one per tab), `placeholder`, and
// `pushUrl` (the second-level page; by default pages/searchSecond with the same preset). With `withItems` the bar of the
// reference look gets the camera, a divider and the Search button inside it (the Discover tab).
const { cylNavigationMetrics } = require('../../components/core/CYLSearchResources');
const { cylDemoText } = require('../../utils/cyl_demo_text');

const CAMERA_IMAGE = '/assets/discover/camera.viewfinder.svg';

Component({
  properties: {
    preset: { type: String, value: 'navigationField' },
    placeholder: { type: String, value: '' },
    pushUrl: { type: String, value: '' },
    withItems: { type: Boolean, value: false },
  },
  data: { url: '', fieldHeight: 36, items: [] },
  lifetimes: {
    attached() {
      const p = this.properties;
      this.setData({
        url: p.pushUrl || `/pages/searchSecond/index?preset=${p.preset}`,
        fieldHeight: cylNavigationMetrics().fieldHeight,
        items: p.withItems ? [
          { style: 'icon', title: cylDemoText('discover.imageSearch'), image: CAMERA_IMAGE, accessibilityIdentifier: 'camera' },
          { style: 'divider' },
          { style: 'text', title: cylDemoText('discover.search'), accessibilityIdentifier: 'CYLSearchDiscoverSearchButton' },
        ] : [],
      });
    },
  },
});

// The navigation bar of the example's pages ("navigationStyle": "custom"), like a UINavigationBar: the back button
// when the page was pushed, an optional leading text button, the title, then trailing text or icon buttons, clear of
// WeChat's menu button. It reserves its own height, so the page content starts below it.
const { cylNavigationMetrics } = require('../../components/core/CYLSearchResources');
const { cylDemoText } = require('../../utils/cyl_demo_text');

Component({
  options: { multipleSlots: true },
  properties: {
    title: { type: String, value: '' },
    leftTitle: { type: String, value: '' },
    rightTitle: { type: String, value: '' },
    // A trailing icon button: "search" (iOS UIBarButtonItem .search).
    rightIcon: { type: String, value: '' },
    rightLabel: { type: String, value: '' },
    rightIdentifier: { type: String, value: '' },
    // An inline style for the bar (a background color).
    barStyle: { type: String, value: '' },
    tintColor: { type: String, value: '' },
    // NO hides the bar (iOS setNavigationBarHidden), keeping nothing of its height.
    shown: { type: Boolean, value: true },
  },
  // A leading text button replaces the back button, as UIKit does with leftBarButtonItem.
  data: { statusBarHeight: 20, navigationBarHeight: 44, trailingInset: 0, showsBack: false, backLabel: '' },
  lifetimes: {
    attached() {
      const metrics = cylNavigationMetrics();
      this.setData({
        statusBarHeight: metrics.statusBarHeight,
        navigationBarHeight: metrics.navigationBarHeight,
        trailingInset: metrics.trailingInset,
        showsBack: getCurrentPages().length > 1,
        backLabel: cylDemoText('search.back'),
      });
    },
  },
  methods: {
    onBack() {
      wx.navigateBack();
    },
    onLeft() {
      this.triggerEvent('lefttap');
    },
    onRight() {
      this.triggerEvent('righttap');
    },
  },
});

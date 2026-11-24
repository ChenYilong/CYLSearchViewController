const { CYLSearchResources, cylNavigationMetrics } = require('../core/CYLSearchResources');

/**
 * The navigation bar of a page with `"navigationStyle": "custom"` that always holds the search bar (docs/
 * animated-icon-component.md, "The search bar is always in a navigation bar"): it sits below the status bar, is as high
 * as WeChat's navigation bar and keeps clear of the capsule menu button (`wx.getMenuButtonBoundingClientRect`, through
 * `cylNavigationMetrics`). Put the search bar in the default slot, with `fieldHeight` of `metrics.fieldHeight` (36);
 * the page needs no layout of its own: the bar is the first block of the page and the content follows it.
 *
 * Properties: `showsBack` (a back button before the slot, default `false`), `backLabel` (default the localized "Back"), `autoBack` (default `true`: the arrow also calls `wx.navigateBack()`).
 * Event: `back`. The measured values are in `data.metrics` (and in `cylNavigationMetrics()`).
 */
Component({
  options: { multipleSlots: true },
  properties: {
    showsBack: { type: Boolean, value: false },
    backLabel: { type: String, value: '' },
    autoBack: { type: Boolean, value: true },
  },
  data: { metrics: {}, barStyle: '', back: '' },
  lifetimes: {
    attached() {
      const metrics = cylNavigationMetrics();
      // 16 pt layout margins (the tag inset), the trailing side ends before the menu button.
      const trailing = Math.max(16, metrics.trailingInset);
      this.setData({
        metrics,
        barStyle: `padding: ${metrics.statusBarHeight}px ${trailing}px 0 16px; height: ${metrics.navigationBarHeight}px;`,
        back: this.properties.backLabel || CYLSearchResources.localizedString(undefined, 'search.back'),
      });
    },
  },
  methods: {
    // The back arrow: `back` first (the page may act), then `wx.navigateBack()` unless `autoBack` is false.
    onBack() {
      this.triggerEvent('back', {});
      if (this.properties.autoBack && typeof wx !== 'undefined' && wx.navigateBack) wx.navigateBack();
    },
  },
});

const { CYLSearchResources, cylNavigationMetrics, cylNavigationBarWidthsFrom } = require('../core/CYLSearchResources');
const { cylBackButtonRequest, cylFirstLevelTapAction, cylBackButtonWantedFor } = require('../core/CYLSearchNavigationBar');

/**
 * The navigation bar of a page with `"navigationStyle": "custom"` that always holds the search bar (docs/
 * animated-icon-component.md, "The search bar is always in a navigation bar"): it sits below the status bar, is as high
 * as WeChat's navigation bar and keeps clear of the capsule menu button (`wx.getMenuButtonBoundingClientRect`, through
 * `cylNavigationMetrics`). Put the search bar in the default slot, with `fieldHeight` of `metrics.fieldHeight` (36);
 * the page needs no layout of its own: the bar is the first block of the page and the content follows it.
 *
 * Properties: `showsBack` (a back button before the slot, default `false`), `backLabel` (default the localized "Back"), `autoBack` (default `true`: the arrow also calls `wx.navigateBack()`).
 * Event: `back`. The measured values are in `data.metrics` (and in `cylNavigationMetrics()`).
 *
 * First level (owner directive 2026-11-26): with `pushesOnTap` the bar is a first-level page's bar, shown whole at the full
 * width inside the safe area. A tap on it (a transparent layer over the slot) brings the back button in with a CSS
 * transition, the bar narrows by itself (the slot is flex, a page never sets a width), then `firstleveltap` is
 * triggered and, when `pushUrl` is set, `wx.navigateTo({ url: pushUrl })` pushes the second-level page. The native swipe
 * back and the back button return to the page: its `onShow` (the component's page lifetime) takes the back button out
 * again, animated. Methods: `showBackButton(animated = true)`, `hideBackButton(animated = true)` (iOS mirrors the names).
 * `showsBack` is the initial state of a second-level page: its back button is shown at once, without animation.
 */
Component({
  options: { multipleSlots: true },
  properties: {
    showsBack: { type: Boolean, value: false },
    backLabel: { type: String, value: '' },
    autoBack: { type: Boolean, value: true },
    pushesOnTap: { type: Boolean, value: false },
    pushUrl: { type: String, value: '' },
  },
  data: { metrics: {}, barStyle: '', contentStyle: '', back: '', backShown: false, backAnimated: false },
  lifetimes: {
    attached() {
      const metrics = cylNavigationMetrics();
      let window = {};
      let menuButton = null;
      try {
        window = wx.getWindowInfo ? wx.getWindowInfo() : wx.getSystemInfoSync();
        menuButton = wx.getMenuButtonBoundingClientRect ? wx.getMenuButtonBoundingClientRect() : null;
      } catch (error) {
        menuButton = null;
      }
      // 16 pt layout margins (the tag inset), the trailing side ends before the menu button, the search bar gets the
      // width that is left beside the back button (measured here, never by the page).
      const widths = cylNavigationBarWidthsFrom(window, menuButton, this.properties.showsBack);
      this.setData({
        metrics,
        barStyle: `padding: ${metrics.statusBarHeight}px ${widths.trailing}px 0 ${widths.leading}px; height: ${metrics.navigationBarHeight}px;`,
        // The bar takes what the back slot leaves (flex: 1), so its width follows the slot's transition.
        contentStyle: '',
        backShown: !!this.properties.showsBack,
        back: this.properties.backLabel || CYLSearchResources.localizedString(undefined, 'search.back'),
      });
    },
  },
  pageLifetimes: {
    // The page is shown again (returned from the second-level page by the back button or the swipe back, or shown first):
    // a first-level bar takes the back button out, animated; no-op when it is not shown.
    show() {
      if (this.properties.pushesOnTap) this.setBackButton(cylBackButtonWantedFor(true), true);
    },
  },
  methods: {
    /** Brings the back button in on the left; the bar narrows to make room. Asking twice is a no-op. */
    showBackButton(animated = true) {
      this.setBackButton(true, animated);
    },
    /** Takes the back button out; the bar grows back to its full width. */
    hideBackButton(animated = true) {
      this.setBackButton(false, animated);
    },
    setBackButton(shown, animated) {
      const request = cylBackButtonRequest(this.data.backShown, shown, animated);
      if (request === 0) return;
      this.setData({ backShown: shown, backAnimated: request === 2 });
    },
    // The tap of a first-level bar: the back button comes in, then `firstleveltap` and the push.
    onFirstLevelTap() {
      if (cylFirstLevelTapAction(this.properties.pushesOnTap, this.data.backShown) !== 1) return;
      this.showBackButton(true);
      this.triggerEvent('firstleveltap', {});
      if (this.properties.pushUrl && typeof wx !== 'undefined' && wx.navigateTo) wx.navigateTo({ url: this.properties.pushUrl });
    },
    // The back arrow: `back` first (the page may act), then `wx.navigateBack()` unless `autoBack` is false.
    onBack() {
      this.triggerEvent('back', {});
      if (this.properties.autoBack && typeof wx !== 'undefined' && wx.navigateBack) wx.navigateBack();
    },
  },
});

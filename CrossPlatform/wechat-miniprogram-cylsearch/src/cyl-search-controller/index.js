const { CYLSearchResources } = require('../core/CYLSearchResources');
const { cylNavigationMetrics } = require('../cyl-search/cyl_navigation_metrics');

const text = (key) => CYLSearchResources.localizedString(undefined, key);

/**
 * The animated search overlay (iOS `CYLSearchController`): it slides up 44 px and fades in over 0.25 s, with Cancel
 * at the top leading edge, the search field pinned under it and the results below (iOS
 * `CYLSearchResultsViewController`). A mini program cannot pass a data source object, so the results come from the
 * page: on `querychange` `{ text }` set `results` to the results of that query (all of them for an empty query).
 *
 * Events: `querychange` `{ text }`, `select` `{ result, index }`, `cancel` (iOS `-searchControllerDidCancel:`, after
 * the overlay is gone). Methods: `show()`, `hide()`. Property `presented` mirrors iOS `isPresented`.
 */
Component({
  properties: {
    results: { type: Array, value: [] },
    placeholder: { type: String, value: '' },
    // YES puts Cancel where the navigation bar of a "navigationStyle": "custom" page is, clear of the menu button.
    coversNavigationBar: { type: Boolean, value: false },
  },
  data: { visible: false, entered: false, query: '', focus: false, labels: {}, topStyle: '', presented: false },
  lifetimes: {
    attached() {
      let topStyle = '';
      if (this.properties.coversNavigationBar) {
        const metrics = cylNavigationMetrics();
        topStyle = `padding-top: ${metrics.statusBarHeight}px; height: ${metrics.navigationBarHeight}px; padding-right: ${metrics.trailingInset}px;`;
      }
      this.setData({ topStyle, labels: { cancel: text('search.cancel'), placeholder: text('search.field') } });
    },
  },
  methods: {
    /** Shows the overlay (iOS `-showInViewController:`); does nothing while it is presented. */
    show() {
      if (this.data.presented) return;
      this.setData({ visible: true, entered: false, presented: true, query: '' });
      this.triggerEvent('querychange', { text: '' });
      setTimeout(() => this.setData({ entered: true }), 30);
    },
    /** Hides the overlay (iOS `-hide:`); `completion` runs after it is gone, also when it was not presented. */
    hide(completion) {
      if (!this.data.presented) {
        if (completion) completion();
        return;
      }
      this.setData({ entered: false, focus: false });
      setTimeout(() => {
        this.setData({ visible: false, presented: false });
        if (completion) completion();
      }, 250);
    },
    onCancel() {
      this.hide(() => this.triggerEvent('cancel'));
    },
    onTextChange(event) {
      this.setData({ query: event.detail.text });
      this.triggerEvent('querychange', { text: event.detail.text });
    },
    onResultTap(event) {
      const index = Number(event.currentTarget.dataset.index);
      this.triggerEvent('select', { result: this.properties.results[index], index });
    },
  },
});

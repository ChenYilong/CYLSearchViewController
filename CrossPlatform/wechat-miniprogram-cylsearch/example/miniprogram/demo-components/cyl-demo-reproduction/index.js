// The Issue #1317 reproduction (iOS CYLSearchExampleViewController): a search field pinned under the navigation bar
// over forty localized sample results with pull to refresh and the "No matching results" placeholder. "Repro"
// switches hidesSearchBarWhenScrolling (the field then scrolls away with the list); "Overlay" opens the
// CYLSearchController overlay with the same results.
const { cylDemoText } = require('../../utils/cyl_demo_text');

/** iOS CYLSearchExampleDataSource: forty "Sample result N", filtered by the query (case-insensitive contains). */
const items = Array.from({ length: 40 }, (_, index) => cylDemoText('sample.result', index + 1));

function results(query) {
  const text = String(query || '').toLowerCase();
  return text ? items.filter((item) => item.toLowerCase().includes(text)) : items.slice();
}

Component({
  properties: {
    // The page sits in the tab bar: the list keeps room for it.
    inTabBar: { type: Boolean, value: false },
  },
  data: {
    query: '', shown: items, overlayResults: items, refreshing: false, hidesSearchBarWhenScrolling: false,
    texts: {
      title: cylDemoText('search.title'),
      placeholder: cylDemoText('search.placeholder'),
      overlay: cylDemoText('action.overlay'),
      reproOn: cylDemoText('repro.on'),
      reproOff: cylDemoText('repro.off'),
    },
  },
  methods: {
    onQuery(event) {
      const query = event.detail.text;
      this.setData({ query, shown: results(query) });
    },
    // Pull to refresh: the data source reloads in 0.4 s without an error, then the results reload.
    onRefresh() {
      this.setData({ refreshing: true });
      setTimeout(() => {
        this.setData({ refreshing: false, shown: results(this.data.query) });
      }, 400);
    },
    onToggleReproduction() {
      this.setData({ hidesSearchBarWhenScrolling: !this.data.hidesSearchBarWhenScrolling });
    },
    onShowOverlay() {
      this.selectComponent('#overlay').show();
    },
    onOverlayQuery(event) {
      this.setData({ overlayResults: results(event.detail.text) });
    },
  },
});

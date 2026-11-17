// The Issue #1317 reproduction (iOS CYLSearchExampleViewController): a search field pinned under the navigation bar
// over forty localized sample results with pull to refresh and the "No matching results" placeholder. "Repro"
// switches hidesSearchBarWhenScrolling (the field then scrolls away with the list); "Overlay" opens a search view
// with the same results. Both are the core's <cyl-search>: the refresh goes only through its refresh API
// (refresherEnabled, the refresh event, endRefreshing()), never through CYLTableViewPlaceHolder directly.
const { cylDemoText } = require('../../utils/cyl_demo_text');

/**
 * iOS CYLSearchExampleDataSource: forty "Sample result N", filtered by the query (case-insensitive contains).
 */
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
    query: '', shown: items, overlayResults: items, hidesSearchBarWhenScrolling: false,
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
    // Pull to refresh: the data source reloads in 0.4 s without an error, then the refresh ends and the results reload
    // (iOS: endRefreshing, then reloadResults; an error would show the "Refresh Failed" alert). The timer holds no
    // reference to the page beyond the component, and endRefreshing runs on every path.
    onRefresh() {
      setTimeout(() => {
        const search = this.selectComponent('#search');
        if (search) search.endRefreshing();
        this.setData({ shown: results(this.data.query) });
      }, 400);
    },
    onToggleReproduction() {
      this.setData({ hidesSearchBarWhenScrolling: !this.data.hidesSearchBarWhenScrolling });
    },
    onShowOverlay() {
      this.selectComponent('#overlay').showSearch();
    },
    onOverlayQuery(event) {
      this.setData({ overlayResults: results(event.detail.text) });
    },
  },
});

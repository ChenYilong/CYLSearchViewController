// Port of lapism/search's README usage (iOS CYLLapismSearchViewController): a MaterialSearchBar (magnifier navigation
// icon, hint, taps open the search) over a list, and a MaterialSearchView (arrow navigation icon, a filtered list added
// with addView, query and focus listeners).
const { cylDemoText } = require('../../utils/cyl_demo_text');

const items = Array.from({ length: 40 }, (_, index) => cylDemoText('demo.port.item', index + 1));

Page({
  data: { items, filteredItems: items, hint: '', barText: '', query: '' },
  onLoad() {
    this.setData({ hint: cylDemoText('search.field') });
  },
  openSearch() {
    this.selectComponent('#search').show();
  },
  // adapter.filter(newText)
  onTextChange(event) {
    const text = event.detail.text;
    const lower = text.toLowerCase();
    this.setData({ query: text, filteredItems: text ? items.filter((item) => item.toLowerCase().includes(lower)) : items });
  },
  // The bar shows the search view's query when the focus changes.
  onFocusChange() {
    this.setData({ barText: this.data.query });
  },
});

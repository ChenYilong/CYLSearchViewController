// "Short list" (iOS CYLSearchShortListDemoViewController, QMUI issue #1160 and #1207, row I4): three rows under a header search bar.
// The core's content page lets the bar scroll out even above so short a list and settles it fully shown or fully hidden when
// the scrolling ends (cyl-search snapsHeaderSearchBar).
const { cylDemoText } = require('../../utils/cyl_demo_text');
const { cylHostHeight } = require('../../utils/cyl_search_page');

Page({
  data: { title: '', hostHeight: 600, rows: [], results: [], placeholder: '' },
  onLoad() {
    this.setData({
      title: cylDemoText('demo.shortList'),
      hostHeight: cylHostHeight(),
      placeholder: cylDemoText('search.field'),
      rows: [1, 2, 3].map((number) => cylDemoText('issue.row', number)),
    });
  },
  onUpdateResults(event) {
    const text = event.detail.text.toLowerCase();
    const matches = text ? this.data.rows.filter((row) => row.toLowerCase().includes(text)) : [];
    this.setData({ results: matches });
    const search = this.selectComponent('#search');
    if (matches.length === 0 && text) search.showEmptyView(cylDemoText('controller.noResults'));
    else search.hideEmptyView();
  },
});

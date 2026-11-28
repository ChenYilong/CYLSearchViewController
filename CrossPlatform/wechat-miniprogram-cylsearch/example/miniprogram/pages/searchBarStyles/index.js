// "Search bar styles" (iOS CYLSearchBarStylesViewController, a replica of QMUI's QDSearchBarViewController): the sections
// Placeholder, Layout and Accessory view drive the bar of one <cyl-search> list screen (showsSearchBar). Texts come from the
// iOS strings (utils/cyl_demo_resources.js).
const { cylDemoText } = require('../../utils/cyl_demo_text');
const { CYLSearchBarAppearance } = require('../../components/core/CYLSearchBarView');
const { cylHostHeight, ACCESSORY_COLORS } = require('../../utils/cyl_search_page');

const pick = () => ACCESSORY_COLORS[Math.floor(Math.random() * ACCESSORY_COLORS.length)];

Page({
  data: {
    title: '', hostHeight: 600, centersPlaceholder: false, animated: true, placeholder: '',
    leadingMargins: { top: 0, left: 8, bottom: 0, right: 0 }, trailingMargins: { top: 0, left: 0, bottom: 0, right: 8 },
    appearance: CYLSearchBarAppearance.default(), showsCancel: false, showsLeading: false, showsTrailing: false, leadingColor: '', trailingColor: '',
    sections: [], texts: {},
  },
  onLoad() {
    this.setData({
      title: cylDemoText('demo.searchBarStyles'),
      hostHeight: cylHostHeight(),
      placeholder: cylDemoText('search.field'),
      leadingColor: pick(),
      trailingColor: pick(),
      texts: { accessory: cylDemoText('styles.accessory.label'), hint: cylDemoText('styles.row.hint') },
    });
    this.refresh();
  },
  // The titles of the rows: Show / Hide follow the state, as the iOS rows reload.
  refresh() {
    const d = this.data;
    const toggle = (shown, key) => cylDemoText(shown ? 'styles.hide' : 'styles.show', cylDemoText(key));
    this.setData({
      sections: [
        { title: cylDemoText('styles.section.placeholder'), rows: [
          { id: 'center', text: cylDemoText('styles.centerPlaceholder'), switch: true, on: d.centersPlaceholder },
          { id: 'change', text: cylDemoText('styles.changePlaceholder') },
        ] },
        { title: cylDemoText('styles.section.layout'), rows: [
          { id: 'field', text: cylDemoText('styles.adjustField') },
          { id: 'cancelMargins', text: cylDemoText('styles.adjustCancel') },
        ] },
        { title: cylDemoText('styles.section.accessory'), rows: [
          { id: 'animated', text: cylDemoText('styles.animated'), switch: true, on: d.animated },
          { id: 'cancel', text: toggle(d.showsCancel, 'styles.cancel') },
          { id: 'leading', text: toggle(d.showsLeading, 'styles.leading') },
          { id: 'trailing', text: toggle(d.showsTrailing, 'styles.trailing') },
        ] },
      ],
    });
  },
  noop() {},
  onSwitch(event) {
    const id = event.currentTarget.dataset.id;
    const on = event.detail.value;
    if (id === 'center') this.setData({ centersPlaceholder: on });
    if (id === 'animated') this.setData({ animated: on });
  },
  onRow(event) {
    const search = this.selectComponent('#search');
    const animated = this.data.animated;
    switch (event.currentTarget.dataset.id) {
      case 'change':
        this.setData({ placeholder: cylDemoText('styles.longPlaceholder') });
        break;
      case 'field':
        // iOS textFieldMarginsProvider: (0, 32, 0, 32) at rest, none while searching.
        search.setTextFieldMarginsProvider((bar, active) => (active ? { top: 0, left: 0, bottom: 0, right: 0 } : { top: 0, left: 32, bottom: 0, right: 32 }));
        break;
      case 'cancelMargins':
        // iOS cancelButtonMarginsProvider: (0, -16, 0, 0) while searching; it also starts the search.
        search.setCancelButtonMarginsProvider((bar, active) => (active ? { top: 0, left: -16, bottom: 0, right: 0 } : { top: 0, left: 0, bottom: 0, right: 0 }));
        if (!search.isActive()) search.setActive(true, true);
        break;
      case 'cancel':
        this.setData({ showsCancel: !this.data.showsCancel });
        search.setShowsCancelButton(this.data.showsCancel, animated);
        break;
      case 'leading':
        this.setData({ showsLeading: !this.data.showsLeading });
        search.setShowsLeadingView(this.data.showsLeading, animated);
        break;
      case 'trailing':
        this.setData({ showsTrailing: !this.data.showsTrailing });
        search.setShowsTrailingAccessoryViews(this.data.showsTrailing, animated);
        break;
      default:
        break;
    }
    this.refresh();
  },
});

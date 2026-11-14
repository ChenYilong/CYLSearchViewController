const { CYLSearchBarItem, CYLSearchBarItems } = require('../cyl-search/cyl_search_bar_item');

/**
 * The search bar component (iOS `CYLSearchBarView`): the field, then the appended `items` inside one outline with
 * `searchBarStyle: 'bordered'`. `items` is a list of plain values (see `CYLSearchBarItem.item`); a tap on one triggers
 * `itemselect` with `{ item, index }` and toggles a selectable item.
 */
Component({
  properties: {
    value: { type: String, value: '' },
    placeholder: { type: String, value: '' },
    focus: { type: Boolean, value: false },
    searchBarStyle: { type: String, value: 'plain' },
    searchIcon: { type: String, value: '' },
    showsSearchIcon: { type: Boolean, value: true },
    showsCancelButton: { type: Boolean, value: false },
    cancelButtonTitle: { type: String, value: 'Cancel' },
    items: { type: Array, value: [] },
  },
  methods: {
    onInput(event) {
      this.triggerEvent('textchange', { text: event.detail.value });
    },
    onConfirm(event) {
      this.triggerEvent('submit', { text: event.detail.value });
    },
    onFocus() {
      this.triggerEvent('focuschange', { focused: true });
    },
    onBlur() {
      this.triggerEvent('focuschange', { focused: false });
    },
    onCancel() {
      this.triggerEvent('cancel');
    },
    onItemTap(event) {
      const index = Number(event.currentTarget.dataset.index);
      const values = this.data.items[index];
      if (!values || values.isEnabled === false) return;
      const bar = new CYLSearchBarItems();
      const item = CYLSearchBarItem.item(values);
      bar.addItem(item);
      bar.itemTapped(item);
      if (item.isSelectable) this.setData({ [`items[${index}].isSelected`]: item.isSelected });
      this.triggerEvent('itemselect', { item: values, index, selected: item.isSelected });
    },
  },
});

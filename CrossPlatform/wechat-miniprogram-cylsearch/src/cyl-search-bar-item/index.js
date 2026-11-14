/**
 * One appended item of `cyl-search-bar` (iOS `CYLSearchBarItemView`). `item` is the plain values of a
 * `CYLSearchBarItem` (`style`, `title`, `image`, `selectedImage`, `accessibilityIdentifier`, `isEnabled`,
 * `isSelected`, `badgeValue`). Event: `itemtap`. Screen readers read the title and the badge in one label.
 */
Component({
  properties: {
    item: { type: Object, value: {}, observer: 'updateLabel' },
  },
  data: { label: '' },
  methods: {
    updateLabel(item) {
      const title = (item && (item.itemAccessibilityLabel || item.title)) || '';
      const badge = item && item.badgeValue ? `, ${item.badgeValue}` : '';
      this.setData({ label: title + badge });
    },
    onTap() {
      if (this.properties.item.isEnabled === false) return;
      this.triggerEvent('itemtap', { item: this.properties.item });
    },
  },
});

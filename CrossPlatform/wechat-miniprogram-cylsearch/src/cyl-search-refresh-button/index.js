const { CYLSearchResources } = require('../core/CYLSearchResources');

/**
 * The refresh button of a tag list header (iOS `CYLSearchTagListHeader.applyRefreshIcon(to:)`): the built-in refresh
 * icon (`images/refresh.svg` of this package, never three dots or text) with the localized label `tagList.refresh`
 * (Refresh, 更新, 刷新, 重新整理) as its accessibility label. Event: `tap`. Property `label` overrides the label.
 */
Component({
  properties: {
    label: { type: String, value: '' },
  },
  data: { icon: '', text: '' },
  lifetimes: {
    attached() {
      this.setData({
        icon: CYLSearchResources.imageNamed('refresh'),
        text: this.properties.label || CYLSearchResources.localizedString(undefined, 'tagList.refresh'),
      });
    },
  },
  methods: {
    onTap() {
      this.triggerEvent('tap', {});
    },
  },
});

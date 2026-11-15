// The placeholder gallery (iOS CYLSearchPlaceholderGalleryViewController): one section per CYLSearchPlaceholderStyle,
// headed by its image name, with the four built-in messages; then the custom section (a built-in image with your own
// text, your own image with a built-in message, your own image and text). A row opens the placeholder full screen.
const { cylDemoText } = require('../../utils/cyl_demo_text');
const { CYLSearchPlaceholderView } = require('../../components/core/CYLSearchPlaceholderView');

const STYLE_COUNT = 41;
const MESSAGE_KEYS = ['placeholder.empty', 'placeholder.search', 'placeholder.error', 'placeholder.network'];
const CUSTOM_KEYS = ['demo.custom.textOnly', 'demo.custom.imageOnly', 'demo.custom.both'];
const IMAGE_ROOT = '/components/images/placeholder/';

Page({
  data: { title: '', sections: [] },
  onLoad() {
    const messages = MESSAGE_KEYS.map((key) => cylDemoText(key));
    const sections = [];
    for (let style = 0; style < STYLE_COUNT; style += 1) {
      const name = CYLSearchPlaceholderView.imageNameForStyle(style);
      sections.push({
        header: name,
        rows: messages.map((text, message) => ({
          text, url: `/pages/placeholderDetail/index?style=${style}&message=${message}`,
          image: `${IMAGE_ROOT}${name}.png`, template: style !== 0,
        })),
      });
    }
    sections.push({
      header: cylDemoText('demo.custom'),
      rows: CUSTOM_KEYS.map((key, row) => ({
        text: cylDemoText(key), url: `/pages/placeholderDetail/index?custom=${row}`,
        image: row === 0 ? `${IMAGE_ROOT}CYLSearchNoResults.png` : '/assets/heart.fill.svg', template: true,
      })),
    });
    this.setData({ title: cylDemoText('demo.styles'), sections });
  },
  onRow(event) {
    wx.navigateTo({ url: event.currentTarget.dataset.url });
  },
});

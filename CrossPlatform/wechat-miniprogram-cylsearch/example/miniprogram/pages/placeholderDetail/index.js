// One placeholder full screen (iOS: a plain view controller titled with the row's text, the placeholder filling it).
// Options: style and message (a built-in image with a built-in message), or custom (0: the NoResults image with your
// own text; 1: your own image, a pink heart, with the network message; 2: your own image and text).
const { cylDemoText } = require('../../utils/cyl_demo_text');

const MESSAGE_KEYS = ['placeholder.empty', 'placeholder.search', 'placeholder.error', 'placeholder.network'];
const CUSTOM_KEYS = ['demo.custom.textOnly', 'demo.custom.imageOnly', 'demo.custom.both'];
const MESSAGE_NAMES = ['empty', 'noResults', 'error', 'network'];

Page({
  data: { title: '', placeholderStyle: 0, message: 'empty', text: '', image: '', tint: '' },
  onLoad(options) {
    if (options.custom !== undefined) {
      const row = Number(options.custom);
      this.setData({
        title: cylDemoText(CUSTOM_KEYS[row]),
        placeholderStyle: 'noResults',
        message: row === 1 ? 'network' : 'empty',
        text: row === 1 ? '' : cylDemoText('demo.custom.text'),
        image: row === 0 ? '' : '/assets/heart.fill.svg',
        tint: row === 0 ? '' : '#ff2d55',
      });
      return;
    }
    const message = Number(options.message) || 0;
    this.setData({
      title: cylDemoText(MESSAGE_KEYS[message]),
      placeholderStyle: Number(options.style) || 0,
      message: MESSAGE_NAMES[message],
    });
  },
});

const { CYLSearchPlaceholderView, CYLSearchPlaceholderStyle, CYLSearchPlaceholderMessage, CYLSearchPlaceholderKind } = require('../core/CYLSearchPlaceholderView');
const { CYLSearchResources } = require('../core/CYLSearchResources');

const MESSAGE_NAMES = ['empty', 'noResults', 'error', 'network'];

/** A style given by name ("noResults", "NoResults") or by number; the empty style when unknown. */
function styleIndex(value) {
  if (typeof value === 'number') return value;
  const text = String(value || '');
  if (/^\d+$/.test(text)) return Number(text);
  const key = Object.keys(CYLSearchPlaceholderStyle).find((name) => name.toLowerCase() === text.toLowerCase());
  return key !== undefined && typeof CYLSearchPlaceholderStyle[key] === 'number' ? CYLSearchPlaceholderStyle[key] : CYLSearchPlaceholderStyle.empty;
}

function messageIndex(value) {
  if (typeof value === 'number') return value;
  const index = MESSAGE_NAMES.indexOf(String(value || ''));
  return index < 0 ? CYLSearchPlaceholderMessage.empty : index;
}

/**
 * The placeholder view (iOS `CYLSearchPlaceholderView`): an image above a message, centered. Give `kind` ("empty",
 * "noResults", "error"); or `placeholderStyle` (one of the 41 `CYLSearchPlaceholderStyle` names) with `message`
 * ("empty", "noResults", "error", "network") or your own `text`; or your own `image` with `message` or `text`.
 * Built-in images other than the empty one are template images drawn in the secondary text color; `imageTintColor`
 * tints them (and your own image, when `tintsImage` is set) another color.
 */
Component({
  properties: {
    kind: { type: String, value: '' },
    placeholderStyle: { type: null, value: '' },
    message: { type: null, value: '' },
    text: { type: String, value: '' },
    image: { type: String, value: '' },
    imageTintColor: { type: String, value: '' },
    tintsImage: { type: Boolean, value: false },
  },
  data: { imagePath: '', shownText: '', templateImage: true },
  observers: {
    'kind, placeholderStyle, message, text, image': function () {
      this.update();
    },
  },
  lifetimes: {
    attached() {
      this.update();
    },
  },
  methods: {
    update() {
      const { kind, placeholderStyle, message, text, image, tintsImage } = this.properties;
      let style;
      let messageValue;
      if (kind) {
        const kinds = { empty: CYLSearchPlaceholderKind.empty, noResults: CYLSearchPlaceholderKind.noResults, error: CYLSearchPlaceholderKind.error };
        const kindValue = kinds[kind] !== undefined ? kinds[kind] : CYLSearchPlaceholderKind.empty;
        style = kindValue === CYLSearchPlaceholderKind.noResults ? CYLSearchPlaceholderStyle.noResults
          : kindValue === CYLSearchPlaceholderKind.error ? CYLSearchPlaceholderStyle.error : CYLSearchPlaceholderStyle.empty;
        messageValue = kindValue === CYLSearchPlaceholderKind.noResults ? CYLSearchPlaceholderMessage.noResults
          : kindValue === CYLSearchPlaceholderKind.error ? CYLSearchPlaceholderMessage.error : CYLSearchPlaceholderMessage.empty;
      } else {
        style = styleIndex(placeholderStyle);
        messageValue = messageIndex(message);
      }
      const imageName = CYLSearchPlaceholderView.imageNameForStyle(style);
      // An absolute path: a style's url() resolves against the page, not this component. `this.is` is
      // "components/cyl-search-placeholder/index" (or the miniprogram_npm path), so the package root is two up.
      const packageRoot = `/${String(this.is || '').replace(/[^/]+\/index$/, '')}`;
      this.setData({
        imagePath: image || `${packageRoot}images/placeholder/${imageName}.png`,
        // The empty style keeps its own colors; the other built-in images are templates (iOS .alwaysTemplate).
        templateImage: image ? tintsImage : style !== CYLSearchPlaceholderStyle.empty,
        shownText: text || CYLSearchPlaceholderView.localizedTextForMessage(undefined, messageValue),
      });
    },
  },
});

module.exports = { styleIndex, messageIndex };

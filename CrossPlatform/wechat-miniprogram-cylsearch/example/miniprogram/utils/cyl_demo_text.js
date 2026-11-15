// The example's texts and data, from the iOS bundles (utils/cyl_demo_resources.js), in the WeChat language:
// cylDemoText('demo.port.query', 'Swift') is "Query: Swift", as String(format:) gives on iOS.
const resources = require('./cyl_demo_resources');

let cachedLanguage = '';

/** The iOS localization for a WeChat language: zh_CN -> zh-Hans, zh_TW / zh_HK -> zh-Hant, ja -> ja, else en. */
function cylDemoLanguage(wechatLanguage) {
  const language = String(wechatLanguage || '').replace('_', '-').toLowerCase();
  if (/^zh-(tw|hk|mo|hant)/.test(language)) return 'zh-Hant';
  if (/^zh/.test(language)) return 'zh-Hans';
  if (/^ja/.test(language)) return 'ja';
  return 'en';
}

function currentLanguage() {
  if (cachedLanguage) return cachedLanguage;
  let language = 'en';
  try {
    const info = typeof wx !== 'undefined' && wx.getAppBaseInfo ? wx.getAppBaseInfo() : {};
    language = info.language || 'en';
  } catch (error) {
    language = 'en';
  }
  cachedLanguage = cylDemoLanguage(language);
  return cachedLanguage;
}

/** Fills an iOS format: %@, %d, %ld, %lu, %s and the positional %1$lu. */
function cylFormat(format, args) {
  let next = 0;
  return String(format).replace(/%(?:(\d+)\$)?(@|lu|ld|d|s|%)/g, (whole, position, kind) => {
    if (kind === '%') return '%';
    const index = position ? Number(position) - 1 : next++;
    return index < args.length ? String(args[index]) : whole;
  });
}

/** The text of a key in the current language (English when the key is missing), formatted with the arguments. */
function cylDemoText(key, ...args) {
  const language = currentLanguage();
  const table = resources.strings[language] || resources.strings.en;
  const format = table[key] !== undefined ? table[key] : (resources.strings.en[key] !== undefined ? resources.strings.en[key] : key);
  return args.length ? cylFormat(format, args) : format;
}

/** The discover data (search-discover.json) of the current language. */
function cylDiscoverData() {
  return resources.discover[currentLanguage()] || resources.discover.en;
}

/** The localized hot icon (热, 熱, HOT) of the current language. */
function cylHotIcon() {
  return `/assets/discover/discover-hot-${currentLanguage()}.png`;
}

/** For tests: forces a language ('' follows WeChat again). */
function cylSetDemoLanguage(language) {
  cachedLanguage = language;
}

module.exports = { cylDemoText, cylDemoLanguage, cylFormat, cylDiscoverData, cylHotIcon, cylSetDemoLanguage };

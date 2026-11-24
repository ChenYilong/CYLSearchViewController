// The resources module of cyl-search-miniprogram (iOS `CYLSearchResources.swift`): the package's images and localized
// strings, the suggestion cache (the `CYLSearchSuggestionCache` protocol, `CYLSearchSuggestionCachePolicy` and the
// private default store), the format of the core's strings, the navigation bar metrics of a "navigationStyle":
// "custom" page, and the few platform names the models were written against (ported from the HarmonyOS models).
// Merged from CYLSearchResources.js, CYLSearchStrings.js, CYLSearchSuggestionCache.js, CYLSearchPlatform.js,
// CYLSearchResourceReference.js and the component helpers cyl_search_suggestion_cache.js, cyl_format.js and
// cyl_navigation_metrics.js.
'use strict';

// Generated from harmonyos/cylsearch/src/main/resources/*/element/string.json (the Android strings). Do not edit.
const STRINGS = {
 "en": {
  "cyl_multisearch_add": "New search",
  "cyl_multisearch_item": "Search %1$d of %2$d",
  "cyl_multisearch_remove": "Remove search",
  "cyl_placeholder_empty": "No data",
  "cyl_placeholder_error": "Something went wrong",
  "cyl_placeholder_network": "Check your internet connection",
  "cyl_placeholder_search": "No matching results",
  "cyl_search_back": "Back",
  "cyl_search_cancel": "Cancel",
  "cyl_search_clear": "Clear text",
  "cyl_search_clearRecent": "Clear recent searches",
  "cyl_search_field": "Search",
  "cyl_search_placeholder": "Filter results",
  "cyl_search_recent": "Recent searches",
  "cyl_search_recentCleared": "Recent searches cleared",
  "cyl_search_submit": "Search",
  "cyl_search_suggestions": "Suggestions",
  "cyl_search_title": "Search",
  "cyl_search_voice": "Voice search",
  "cyl_tagList_refresh": "Refresh"
 },
 "ja": {
  "cyl_multisearch_add": "新しい検索",
  "cyl_multisearch_item": "検索 %1$d / %2$d",
  "cyl_multisearch_remove": "検索を削除",
  "cyl_placeholder_empty": "データがありません",
  "cyl_placeholder_error": "問題が発生しました",
  "cyl_placeholder_network": "インターネット接続を確認してください",
  "cyl_placeholder_search": "一致する結果がありません",
  "cyl_search_back": "戻る",
  "cyl_search_cancel": "キャンセル",
  "cyl_search_clear": "テキストを消去",
  "cyl_search_clearRecent": "最近の検索を消去",
  "cyl_search_field": "検索",
  "cyl_search_placeholder": "結果を絞り込む",
  "cyl_search_recent": "最近の検索",
  "cyl_search_recentCleared": "最近の検索を消去しました",
  "cyl_search_submit": "検索",
  "cyl_search_suggestions": "候補",
  "cyl_search_title": "検索",
  "cyl_search_voice": "音声検索",
  "cyl_tagList_refresh": "更新"
 },
 "zh-Hans": {
  "cyl_multisearch_add": "新建搜索",
  "cyl_multisearch_item": "第 %1$d 个搜索，共 %2$d 个",
  "cyl_multisearch_remove": "删除搜索",
  "cyl_placeholder_empty": "暂无数据",
  "cyl_placeholder_error": "出错了",
  "cyl_placeholder_network": "请检查网络连接",
  "cyl_placeholder_search": "没有匹配的结果",
  "cyl_search_back": "返回",
  "cyl_search_cancel": "取消",
  "cyl_search_clear": "清除文本",
  "cyl_search_clearRecent": "清除最近搜索",
  "cyl_search_field": "搜索",
  "cyl_search_placeholder": "筛选结果",
  "cyl_search_recent": "最近搜索",
  "cyl_search_recentCleared": "已清除最近搜索",
  "cyl_search_submit": "搜索",
  "cyl_search_suggestions": "搜索建议",
  "cyl_search_title": "搜索",
  "cyl_search_voice": "语音搜索",
  "cyl_tagList_refresh": "刷新"
 },
 "zh-Hant": {
  "cyl_multisearch_add": "新增搜尋",
  "cyl_multisearch_item": "第 %1$d 個搜尋，共 %2$d 個",
  "cyl_multisearch_remove": "刪除搜尋",
  "cyl_placeholder_empty": "暫無資料",
  "cyl_placeholder_error": "發生錯誤",
  "cyl_placeholder_network": "請檢查網路連線",
  "cyl_placeholder_search": "沒有符合的結果",
  "cyl_search_back": "返回",
  "cyl_search_cancel": "取消",
  "cyl_search_clear": "清除文字",
  "cyl_search_clearRecent": "清除最近搜尋",
  "cyl_search_field": "搜尋",
  "cyl_search_placeholder": "篩選結果",
  "cyl_search_recent": "最近搜尋",
  "cyl_search_recentCleared": "已清除最近搜尋",
  "cyl_search_submit": "搜尋",
  "cyl_search_suggestions": "搜尋建議",
  "cyl_search_title": "搜尋",
  "cyl_search_voice": "語音搜尋",
  "cyl_tagList_refresh": "重新整理"
 }
};

/**
 * The package's images and localized strings (iOS `CYLSearchResources`, the resource bundle of the pod).
 */
class CYLSearchResources {
  /**
   * The path of a bundled image ("camera", "mic", "search", "back", "clear", "submit", "trash", "refresh"), or undefined
   * (iOS `+imageNamed:`), relative to a component folder of this package.
   */
  static imageNamed(name) {
    return CYLSearchResources.imageNames.indexOf(name) >= 0 ? `${CYLSearchResources.imageRoot}/${name}.svg` : undefined;
  }

  /**
   * The string for `key` ("search.placeholder") in `language` ("zh-Hans", "ja"…), the system language by default,
   * else English, else the key (iOS `+localizedString:`). The first argument keeps the HarmonyOS signature.
   */
  static localizedString(context, key, language) {
    const name = `cyl_${String(key).replace(/\./g, '_')}`;
    const table = STRINGS[CYLSearchResources.languageFor(language)] || {};
    if (table[name] !== undefined) return table[name];
    return STRINGS.en[name] !== undefined ? STRINGS.en[name] : key;
  }

  /**
   * The table name for a language tag: "zh_CN", "zh-Hans-CN" give "zh-Hans"; "zh_TW", "zh-HK" give "zh-Hant".
   */
  static languageFor(language) {
    let tag = language;
    if (!tag) {
      try {
        tag = wx.getAppBaseInfo ? wx.getAppBaseInfo().language : wx.getSystemInfoSync().language;
      } catch (error) {
        tag = 'en';
      }
    }
    tag = String(tag || 'en').replace(/_/g, '-');
    if (/^zh-(Hant|TW|HK|MO)/i.test(tag)) return 'zh-Hant';
    if (/^zh/i.test(tag)) return 'zh-Hans';
    return tag.split('-')[0];
  }

  /**
   * Fills a format of the core's strings, which keep the iOS and Android forms: %@, %d, %ld, %lu, %s and the
   * positional %1$d ("Search %1$d of %2$d").
   */
  static formatString(format, args) {
    return cylFormatString(format, args);
  }
}

/**
 * The bundle name (iOS `resourceBundle`).
 */
CYLSearchResources.resourceBundle = 'cylsearch';

/**
 * Where the images are, from a component folder of this package.
 */
CYLSearchResources.imageRoot = '../images';

/**
 * The names `imageNamed` knows.
 */
CYLSearchResources.imageNames = ['camera', 'mic', 'search', 'back', 'clear', 'submit', 'trash', 'refresh'];

/**
 * Fills the formats of the core's strings: %@, %d, %ld, %lu, %s and the positional %1$d / %1$lu.
 */
function cylFormatString(format, args) {
  let next = 0;
  return String(format).replace(/%(?:(\d+)\$)?(@|lu|ld|d|s|%)/g, (whole, position, kind) => {
    if (kind === '%') return '%';
    const index = position ? Number(position) - 1 : next++;
    return index < args.length ? String(args[index]) : whole;
  });
}

// System symbols of the HarmonyOS models -> the package's images (src/images).
const SYMBOLS = {
  magnifyingglass: 'search', mic: 'mic', camera: 'camera', chevron_backward: 'back', xmark_circle_fill: 'clear',
  arrow_right: 'submit', trash: 'trash', archivebox: 'empty', exclamationmark_circle: 'error',
  exclamationmark_triangle: 'error', wifi_slash: 'network',
};
// System colors -> CSS colors (light appearance; the components follow the page's colors).
const COLORS = { comp_divider: '#e5e5ea', comp_background_primary: '#ffffff' };

/**
 * Resolves a resource reference of the HarmonyOS models (ArkUI `$r`): `app.string.cyl_x` gives the localized
 * string, `sys.symbol.x` an image path of this package, `sys.color.x` a CSS color.
 */
function $r(reference) {
  const [scope, kind, name] = String(reference).split('.');
  if (kind === 'string') return CYLSearchResources.localizedString(undefined, name.replace(/^cyl_/, '').replace(/_/g, '.'));
  if (kind === 'symbol') return `${CYLSearchResources.imageRoot}/${SYMBOLS[name] || 'empty'}.svg`;
  if (kind === 'color') return COLORS[name] || '#8e8e93';
  return scope === 'app' ? name : undefined;
}

/**
 * The height of the search field embedded in a navigation bar (docs/animated-icon-component.md, "The search bar is
 * always in a navigation bar"): a standard bar is 44 pt, the field 36.
 */
const CYL_NAVIGATION_FIELD_HEIGHT = 36;

/**
 * Where a bar that takes the navigation bar's place goes on a "navigationStyle": "custom" page, from the window and
 * menu button rectangles: below the status bar, as high as the navigation bar, clear of WeChat's menu button.
 */
function cylNavigationMetricsFrom(window, menuButton) {
  const statusBarHeight = (window && window.statusBarHeight) || 20;
  const windowWidth = (window && window.windowWidth) || 375;
  if (!menuButton || !menuButton.height) {
    return { statusBarHeight, navigationBarHeight: 44, trailingInset: 0, windowWidth, top: statusBarHeight, fieldHeight: CYL_NAVIGATION_FIELD_HEIGHT };
  }
  // The navigation bar is centered on the menu button, with the same gap above and below it.
  const gap = Math.max(0, menuButton.top - statusBarHeight);
  const navigationBarHeight = menuButton.height + gap * 2;
  // The bar ends where the menu button starts, with the same margin the menu button keeps from the screen edge.
  const trailingInset = Math.max(0, windowWidth - menuButton.left) + Math.max(0, windowWidth - menuButton.right);
  return { statusBarHeight, navigationBarHeight, trailingInset, windowWidth, top: statusBarHeight, fieldHeight: CYL_NAVIGATION_FIELD_HEIGHT };
}

/**
 * The navigation bar metrics of this device (see `cylNavigationMetricsFrom`).
 */
function cylNavigationMetrics() {
  let window = {};
  let menuButton = null;
  try {
    window = wx.getWindowInfo ? wx.getWindowInfo() : wx.getSystemInfoSync();
    menuButton = wx.getMenuButtonBoundingClientRect ? wx.getMenuButtonBoundingClientRect() : null;
  } catch (error) {
    menuButton = null;
  }
  return cylNavigationMetricsFrom(window, menuButton);
}

/**
 * Where the suggestion cache keeps the submitted queries (iOS `CYLSearchSuggestionCachePolicy`).
 */
const CYLSearchSuggestionCachePolicy = Object.freeze({
  none: 0,
  database: 1,
  userDefaults: 2,
  sandboxFile: 3,
});

/**
 * A suggestion cache (iOS `CYLSearchSuggestionCache` protocol): give `CYLSearchView.suggestionCache` an object with
 * `cachedQueries()`, `addQuery(query)`, `removeQuery(query)` and `removeAllQueries()` to keep the queries elsewhere.
 */
class CYLSearchSuggestionCache {
  /**
   * The cached queries, newest first.
   */
  cachedQueries() {
    return [];
  }

  /**
   * Adds a query, or moves it to the front.
   */
  addQuery() {}

  /**
   * Removes a query.
   */
  removeQuery() {}

  /**
   * Removes every query.
   */
  removeAllQueries() {}
}

// The default store (iOS: the private store behind `suggestionCachePolicy` / `suggestionCacheName`): newest first, at
// most `maximumCount` queries, one per policy and name. `database` keeps a storage key of its own, `userDefaults` one
// shared key holding every cache, `sandboxFile` a JSON file in wx.env.USER_DATA_PATH. `storage` is
// `{ getSync(key), setSync(key, value) }` (wx storage by default; tests give their own).
class CYLSearchSuggestionDefaultStore extends CYLSearchSuggestionCache {
  constructor(policy, name, storage) {
    super();
    this.policy = policy;
    this.name = name;
    this.maximumCount = 20;
    this.storage = storage || {
      getSync: (key) => wx.getStorageSync(key),
      setSync: (key, value) => wx.setStorageSync(key, value),
    };
    this.memory = [];
  }

  key() {
    return this.policy === CYLSearchSuggestionCachePolicy.database ? `CYLSearchSuggestions_${this.name}` : 'CYLSearchSuggestionDefaults';
  }

  filePath() {
    return `${wx.env.USER_DATA_PATH}/CYLSearchSuggestions_${this.name}.json`;
  }

  cachedQueries() {
    try {
      if (this.policy === CYLSearchSuggestionCachePolicy.sandboxFile) {
        const files = wx.getFileSystemManager();
        try {
          files.accessSync(this.filePath());
        } catch (missing) {
          return this.memory;
        }
        return parseQueries(files.readFileSync(this.filePath(), 'utf8'));
      }
      const value = this.storage.getSync(this.key());
      if (this.policy === CYLSearchSuggestionCachePolicy.database) return value ? parseQueries(value) : this.memory;
      return value && value[this.name] ? parseQueries(value[this.name]) : this.memory;
    } catch (error) {
      return this.memory;
    }
  }

  addQuery(query) {
    const text = String(query || '').trim();
    if (!text) return;
    const queries = this.cachedQueries().filter((item) => item !== text);
    queries.unshift(text);
    this.write(queries.slice(0, Math.max(0, this.maximumCount)));
  }

  removeQuery(query) {
    this.write(this.cachedQueries().filter((item) => item !== query));
  }

  removeAllQueries() {
    this.write([]);
  }

  write(queries) {
    this.memory = queries;
    try {
      if (this.policy === CYLSearchSuggestionCachePolicy.sandboxFile) {
        wx.getFileSystemManager().writeFileSync(this.filePath(), JSON.stringify(queries), 'utf8');
      } else if (this.policy === CYLSearchSuggestionCachePolicy.database) {
        this.storage.setSync(this.key(), queries);
      } else {
        const shared = this.storage.getSync(this.key()) || {};
        shared[this.name] = queries;
        this.storage.setSync(this.key(), shared);
      }
    } catch (error) {
      // The queries stay in memory for this run.
    }
  }
}

// A stored list: an array, or the JSON text earlier versions wrote; only strings are kept.
function parseQueries(value) {
  let values = value;
  if (typeof value === 'string') {
    try {
      values = JSON.parse(value);
    } catch (error) {
      values = [];
    }
  }
  return Array.isArray(values) ? values.filter((item) => typeof item === 'string') : [];
}

/**
 * The default cache for a policy and a name, or undefined for `none`; `CYLSearchView` creates it from
 * `suggestionCachePolicy` and `suggestionCacheName`.
 */
function cylSuggestionCache(policy, name, storage) {
  return policy === CYLSearchSuggestionCachePolicy.none ? undefined : new CYLSearchSuggestionDefaultStore(policy, name, storage);
}

/**
 * The animation curves the models name (ArkUI `Curve`); the components map them to CSS timing functions.
 */
const Curve = Object.freeze({ EaseIn: 'ease-in', EaseOut: 'ease-out', EaseInOut: 'ease-in-out', Linear: 'linear' });

/**
 * Applies `changes` at once (the components animate the result with CSS transitions of `options.duration` ms) and
 * calls `options.onFinish` when that time is over, like ArkUI `animateTo`.
 */
function animateTo(options, changes) {
  changes();
  if (options && typeof options.onFinish === 'function') setTimeout(options.onFinish, Math.max(0, options.duration || 0));
}

/**
 * The `<input>` type of the field (ArkUI `InputType`): the component maps it to the `type` attribute.
 */
const InputType = Object.freeze({ Normal: 'text', Number: 'number', PhoneNumber: 'number', Email: 'text', Password: 'safe-password' });

/**
 * The return key (ArkUI `EnterKeyType`): the component maps it to `confirm-type`.
 */
const EnterKeyType = Object.freeze({ Search: 'search', Done: 'done', Go: 'go', Next: 'next', Send: 'send' });

/**
 * How a long text ends (ArkUI `TextOverflow`): the component maps it to `text-overflow`.
 */
const TextOverflow = Object.freeze({ None: 'clip', Clip: 'clip', Ellipsis: 'ellipsis' });

module.exports = {
  CYLSearchResources,
  CYLSearchSuggestionCachePolicy,
  CYLSearchSuggestionCache,
  cylSuggestionCache,
  cylFormatString,
  cylNavigationMetrics,
  cylNavigationMetricsFrom,
  CYL_NAVIGATION_FIELD_HEIGHT,
  $r,
  Curve,
  animateTo,
  InputType,
  EnterKeyType,
  TextOverflow,
};

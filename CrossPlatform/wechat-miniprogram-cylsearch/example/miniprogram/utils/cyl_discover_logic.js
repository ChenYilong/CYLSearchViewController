// The rules of the Discover page without views (the tag fold is the core's cylFoldTags, core/CYLSearchView.js) (iOS CYLSearchDiscoverData and CYLSearchDiscoverViewController), tested
// with Node.

/**
 * The topics of page `page` of `pool`: whole pages of `count` records, the page number taken modulo the number of pages
 * (a negative page counts from the end). Returns the page number used and its topics.
 */
function cylTopicPage(pool, count, page) {
  const size = Math.max(1, Math.min(Math.max(0, count), pool.length));
  const pages = Math.max(1, Math.floor(pool.length / size));
  const index = ((page % pages) + pages) % pages;
  return { page: index, topics: pool.slice(index * size, (index + 1) * size) };
}

/** Refresh: the NEXT page, cyclically (page = (page + 1) mod pages); no random pick (iOS nextPage). */
function cylNextTopicPage(pool, count, page) {
  return cylTopicPage(pool, count, page + 1);
}

/** The recent searches after searching `text`: trimmed, moved to the front, once; unchanged for an empty text. */
function cylSearchedRecent(recent, text) {
  const query = String(text || '').trim();
  if (!query) return recent.slice();
  return [query].concat(recent.filter((item) => item !== query));
}

/**
 * The topics of a page as the tags of CollectionViewClassifyMenu's tag cloud (`<cyl-tag-cloud tags="...">`, CYLTag
 * objects as its `makeTag` builds them): the title, and for a hot topic the localized hot icon with its label, which
 * the cloud reads after the title ("Title, Hot"). The grid itself is the cloud's, not the page's.
 */
function cylDiscoverCloudTags(topics, hotIcon, hotLabel) {
  return topics.map((topic, index) => {
    const tag = { identifier: index, title: topic.title, isEnabled: true, isDeletable: false };
    if (topic.icon === 'hot') {
      tag.image = hotIcon;
      tag.imageLabel = hotLabel;
    }
    return tag;
  });
}

/**
 * The width of the hot icon in points: the @3x PNGs are 90 x 54 in English and Japanese (HOT) and 54 x 54 in Chinese
 * (the iOS example lets the icon keep its own size; the cloud's icon box is square and fits the image inside it).
 */
function cylHotIconSize(language) {
  return language === 'en' || language === 'ja' ? 30 : 18;
}

/**
 * The iOS example's `discoverStyle()` (`CYLMenuStyle.gridStyle(itemsPerRow: 2)` with its changes) over the cloud's full
 * `base` style (`require('cyl-tag-list-miniprogram').tagCloud.defaultStyle()`): two equal cells per row, plain 17 pt
 * medium titles (no fill, no border), 36 high, 24 apart in a row and 16 between rows, section insets {4, 16, 16, 16}.
 * `options.dark` picks the white title color; `options.iconSize` is the hot icon's box (`cylHotIconSize`).
 */
function cylDiscoverCloudStyle(base, options = {}) {
  const style = JSON.parse(JSON.stringify(base));
  // The one parameter: the glass is the tag background (no fill, no border here).
  style.backgroundStyle = 'liquidGlass';
  const text = options.dark ? '#FFFFFF' : '#000000';
  ['normal', 'selected', 'disabled'].forEach((state) => {
    Object.assign(style[state], {
      backgroundColor: 'transparent', borderColor: null, borderWidth: 0, fontSize: 17, fontWeight: 500, textColor: text,
      contentInsets: { top: 0, left: 0, bottom: 0, right: 0 },
    });
  });
  Object.assign(style, {
    numberOfItemsPerRow: 2, itemHeight: 36, interitemSpacing: 24, lineSpacing: 16, imageTitleSpacing: 6,
    imageSize: options.iconSize || 18, backgroundColor: 'transparent', sectionInsets: { top: 4, left: 16, bottom: 16, right: 16 },
  });
  return style;
}

module.exports = { cylTopicPage, cylNextTopicPage, cylSearchedRecent, cylDiscoverCloudTags, cylHotIconSize, cylDiscoverCloudStyle };

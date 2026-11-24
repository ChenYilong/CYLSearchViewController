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

module.exports = { cylTopicPage, cylNextTopicPage, cylSearchedRecent };

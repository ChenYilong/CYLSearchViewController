// The rules of the Discover page without views (the tag fold is the core's cylFoldTags, core/CYLSearchView.js) (iOS CYLSearchDiscoverData and CYLSearchDiscoverViewController), tested
// with Node.

/**
 * Another random selection of `count` topics from `pool`; it differs from `current` whenever the pool allows: topics
 * not shown now first, filled up with the others (iOS randomTopics(excluding:using:)). `random` returns [0, 1).
 */
function cylRandomTopics(pool, current, count, random) {
  const same = (a, b) => a.title === b.title && (a.icon || '') === (b.icon || '');
  const shuffle = (list) => {
    const copy = list.slice();
    for (let i = copy.length - 1; i > 0; i -= 1) {
      const j = Math.floor(random() * (i + 1));
      [copy[i], copy[j]] = [copy[j], copy[i]];
    }
    return copy;
  };
  const total = Math.min(Math.max(0, count), pool.length);
  const others = pool.filter((topic) => !current.some((shown) => same(shown, topic)));
  let picked = shuffle(others).slice(0, total);
  if (picked.length < total) {
    const rest = shuffle(pool.filter((topic) => !picked.some((chosen) => same(chosen, topic))));
    picked = picked.concat(rest.slice(0, total - picked.length));
  }
  return picked;
}

/** The recent searches after searching `text`: trimmed, moved to the front, once; unchanged for an empty text. */
function cylSearchedRecent(recent, text) {
  const query = String(text || '').trim();
  if (!query) return recent.slice();
  return [query].concat(recent.filter((item) => item !== query));
}

module.exports = { cylRandomTopics, cylSearchedRecent };

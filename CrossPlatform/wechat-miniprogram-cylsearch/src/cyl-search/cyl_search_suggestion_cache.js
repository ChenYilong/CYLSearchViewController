/**
 * Where the suggestion cache keeps the submitted queries (iOS `CYLSearchSuggestionCachePolicy`).
 */
const CYLSearchSuggestionCachePolicy = Object.freeze({
  none: 0,
  /** The default: the mini program's local storage under a key of its own (the "database"). */
  database: 1,
  /** The same storage, under one shared key (iOS user defaults). */
  userDefaults: 2,
  /** Storage again: a mini program has no file the app can read back in this API; kept for parity with iOS. */
  sandboxFile: 3,
});

/**
 * The built-in cache (iOS `CYLSearchSuggestionStore`): newest first, at most `maximumCount` queries, one per policy
 * and name. `storage` is `{ getSync(key), setSync(key, value) }`; the default is `wx.getStorageSync` /
 * `wx.setStorageSync`, and tests give their own.
 */
class CYLSearchSuggestionStore {
  /**
   * A cache for a policy and a name (iOS `-initWithPolicy:name:`).
   */
  constructor(policy, name, storage) {
    this.policy = policy;
    this.name = name;
    this.maximumCount = 20;
    this.storage = storage || {
      getSync: (key) => wx.getStorageSync(key),
      setSync: (key, value) => wx.setStorageSync(key, value),
    };
    this.memory = [];
  }

  /**
   * A cache for a policy, or null for `none` (iOS `+cacheWithPolicy:name:`).
   */
  static cache(policy, name, storage) {
    return policy === CYLSearchSuggestionCachePolicy.none ? null : new CYLSearchSuggestionStore(policy, name, storage);
  }

  key() {
    return this.policy === CYLSearchSuggestionCachePolicy.database
      ? `CYLSearchSuggestions_${this.name}`
      : 'CYLSearchSuggestionDefaults';
  }

  /**
   * The cached queries, newest first.
   */
  cachedQueries() {
    try {
      const value = this.storage.getSync(this.key());
      return Array.isArray(value) ? value.filter((item) => typeof item === 'string') : this.memory;
    } catch (error) {
      return this.memory;
    }
  }

  /**
   * Adds a query, or moves it to the front.
   */
  addQuery(query) {
    const text = String(query || '').trim();
    if (!text) return;
    const queries = this.cachedQueries().filter((item) => item !== text);
    queries.unshift(text);
    this.write(queries.slice(0, Math.max(0, this.maximumCount)));
  }

  /**
   * Removes a query.
   */
  removeQuery(query) {
    this.write(this.cachedQueries().filter((item) => item !== query));
  }

  /**
   * Removes every query.
   */
  removeAllQueries() {
    this.write([]);
  }

  write(queries) {
    this.memory = queries;
    try {
      this.storage.setSync(this.key(), queries);
    } catch (error) {
      // The queries stay in memory for this run.
    }
  }
}

module.exports = { CYLSearchSuggestionCachePolicy, CYLSearchSuggestionStore };

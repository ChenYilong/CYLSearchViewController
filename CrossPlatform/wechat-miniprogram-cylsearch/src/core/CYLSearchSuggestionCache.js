"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.CYLSearchSuggestionStore = exports.CYLSearchSuggestionCache = exports.CYLSearchSuggestionCachePolicy = void 0;
/**
 * Where the suggestion cache keeps the submitted queries (iOS `CYLSearchSuggestionCachePolicy`).
 */
var CYLSearchSuggestionCachePolicy;
(function (CYLSearchSuggestionCachePolicy) {
    /**
     * No cache.
     */
    CYLSearchSuggestionCachePolicy[CYLSearchSuggestionCachePolicy["none"] = 0] = "none";
    /**
     * A database (the default): a preferences store of its own, named after the cache.
     */
    CYLSearchSuggestionCachePolicy[CYLSearchSuggestionCachePolicy["database"] = 1] = "database";
    /**
     * The app's shared preferences (iOS user defaults).
     */
    CYLSearchSuggestionCachePolicy[CYLSearchSuggestionCachePolicy["userDefaults"] = 2] = "userDefaults";
    /**
     * A JSON file in the app's files directory.
     */
    CYLSearchSuggestionCachePolicy[CYLSearchSuggestionCachePolicy["sandboxFile"] = 3] = "sandboxFile";
})(CYLSearchSuggestionCachePolicy || (exports.CYLSearchSuggestionCachePolicy = CYLSearchSuggestionCachePolicy = {}));
/**
 * A suggestion cache (iOS `CYLSearchSuggestionCache`): implement it to keep the queries elsewhere.
 */
class CYLSearchSuggestionCache {
}
exports.CYLSearchSuggestionCache = CYLSearchSuggestionCache;
/**
 * The built-in caches (iOS `CYLSearchSuggestionStore`): one per policy and name, newest first, at most
 * `maximumCount` queries.
 */
class CYLSearchSuggestionStore {
    /**
     * A cache for a policy and a name (iOS `-initWithPolicy:name:`); the context gives the app's storage.
     */
    constructor(context, policy, name) {
        /**
         * The most queries kept. 20 by default.
         */
        this.maximumCount = 20;
        this.memory = [];
        this.context = context;
        this.policy = policy;
        this.name = name;
    }
    /**
     * A cache for a policy, or undefined for `none` (iOS `+cacheWithPolicy:name:`).
     */
    static cache(context, policy, name) {
        return policy === CYLSearchSuggestionCachePolicy.none ? undefined :
            new CYLSearchSuggestionStore(context, policy, name);
    }
    cachedQueries() {
        return this.read();
    }
    addQuery(query) {
        const text = query.trim();
        if (text.length === 0) {
            return;
        }
        const queries = this.read().filter((value) => value !== text);
        queries.unshift(text);
        this.write(queries.slice(0, Math.max(0, this.maximumCount)));
    }
    removeQuery(query) {
        this.write(this.read().filter((value) => value !== query));
    }
    removeAllQueries() {
        this.write([]);
    }
    // The wx storage key: a key of its own per cache (database), or one shared key holding every cache (user defaults).
    storageKey() {
        return this.policy === CYLSearchSuggestionCachePolicy.database ? `CYLSearchSuggestions_${this.name}` :
            'CYLSearchSuggestionDefaults';
    }
    filePath() {
        return `${wx.env.USER_DATA_PATH}/CYLSearchSuggestions_${this.name}.json`;
    }
    read() {
        try {
            if (this.policy === CYLSearchSuggestionCachePolicy.sandboxFile) {
                const files = wx.getFileSystemManager();
                try {
                    files.accessSync(this.filePath());
                }
                catch (missing) {
                    return [];
                }
                return CYLSearchSuggestionStore.parse(files.readFileSync(this.filePath(), 'utf8'));
            }
            if (this.policy === CYLSearchSuggestionCachePolicy.none) {
                return this.memory;
            }
            if (this.policy === CYLSearchSuggestionCachePolicy.database) {
                return CYLSearchSuggestionStore.parse(wx.getStorageSync(this.storageKey()) || '[]');
            }
            const shared = wx.getStorageSync(this.storageKey()) || {};
            return CYLSearchSuggestionStore.parse(shared[this.name] || '[]');
        }
        catch (error) {
            return this.memory;
        }
    }
    write(queries) {
        this.memory = queries;
        try {
            const text = JSON.stringify(queries);
            if (this.policy === CYLSearchSuggestionCachePolicy.sandboxFile) {
                wx.getFileSystemManager().writeFileSync(this.filePath(), text, 'utf8');
            }
            else if (this.policy === CYLSearchSuggestionCachePolicy.database) {
                wx.setStorageSync(this.storageKey(), text);
            }
            else if (this.policy === CYLSearchSuggestionCachePolicy.userDefaults) {
                const shared = wx.getStorageSync(this.storageKey()) || {};
                shared[this.name] = text;
                wx.setStorageSync(this.storageKey(), shared);
            }
        }
        catch (error) {
            // The queries stay in memory for this run.
        }
    }
    static parse(text) {
        const values = JSON.parse(text);
        const queries = [];
        if (Array.isArray(values)) {
            values.forEach((value) => {
                if (typeof value === 'string') {
                    queries.push(value);
                }
            });
        }
        return queries;
    }
}
exports.CYLSearchSuggestionStore = CYLSearchSuggestionStore;

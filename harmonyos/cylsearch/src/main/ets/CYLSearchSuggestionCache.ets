import { preferences, relationalStore } from '@kit.ArkData';
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';

const CYL_SUGGESTION_DATABASE: string = 'cyl_search_suggestions.db';
const CYL_SUGGESTION_TABLE: string = 'queries';
let cylSuggestionDatabasePromise: Promise<relationalStore.RdbStore> | undefined = undefined;
let cylSuggestionLastTime: number = 0;

/**
 * The shared suggestion database, opened once (Android `Helper`: the table `queries` with `cache`, `query` and `time`,
 * one row per cache and query).
 */
function cylSuggestionDatabase(context: common.Context): Promise<relationalStore.RdbStore> {
  if (cylSuggestionDatabasePromise === undefined) {
    const config: relationalStore.StoreConfig = {
      name: CYL_SUGGESTION_DATABASE,
      securityLevel: relationalStore.SecurityLevel.S1
    };
    let opening: Promise<relationalStore.RdbStore>;
    try {
      opening = relationalStore.getRdbStore(context.getApplicationContext(), config);
    } catch (error) {
      return Promise.reject(error);
    }
    cylSuggestionDatabasePromise = opening.then(async (store: relationalStore.RdbStore) => {
      await store.executeSql(`CREATE TABLE IF NOT EXISTS ${CYL_SUGGESTION_TABLE} (cache TEXT NOT NULL, ` +
        'query TEXT NOT NULL, time REAL NOT NULL, PRIMARY KEY (cache, query))');
      return store;
    });
    cylSuggestionDatabasePromise.catch(() => {
      // Opened again next time.
      cylSuggestionDatabasePromise = undefined;
    });
  }
  return cylSuggestionDatabasePromise;
}

/**
 * Milliseconds since 1970, strictly increasing, so queries added in the same millisecond keep their order (Android
 * `nextTime`).
 */
function cylSuggestionNextTime(): number {
  cylSuggestionLastTime = Math.max(Date.now(), cylSuggestionLastTime + 1);
  return cylSuggestionLastTime;
}

/**
 * Where the suggestion cache keeps the submitted queries (iOS `CYLSearchSuggestionCachePolicy`).
 */
export enum CYLSearchSuggestionCachePolicy {
  /**
   * No cache.
   */
  none = 0,
  /**
   * A database (the default): the SQLite table `queries` of `cyl_search_suggestions.db` (`relationalStore`), one row
   * per cache and query, as on Android.
   */
  database = 1,
  /**
   * The app's shared preferences (iOS user defaults).
   */
  userDefaults = 2,
  /**
   * A JSON file in the app's files directory.
   */
  sandboxFile = 3
}

/**
 * A suggestion cache (iOS `CYLSearchSuggestionCache`): implement it to keep the queries elsewhere.
 */
export interface CYLSearchSuggestionCache {
  /**
   * The cached queries, newest first.
   */
  cachedQueries(): string[];
  /**
   * Adds a query, or moves it to the front.
   */
  addQuery(query: string): void;
  /**
   * Removes a query.
   */
  removeQuery(query: string): void;
  /**
   * Removes every query.
   */
  removeAllQueries(): void;
}

/**
 * The built-in caches (iOS `CYLSearchSuggestionStore`): one per policy and name, newest first, at most
 * `maximumCount` queries.
 */
export class CYLSearchSuggestionStore implements CYLSearchSuggestionCache {
  /**
   * Where the queries are kept.
   */
  readonly policy: CYLSearchSuggestionCachePolicy;
  /**
   * The cache's name: two views with the same policy and name share their queries.
   */
  readonly name: string;
  /**
   * The most queries kept. 20 by default.
   */
  maximumCount: number = 20;
  /**
   * Called when the database policy has read the stored queries, which happens after the cache is made; the
   * search view shows them then. Other policies read at once and never call it.
   */
  onLoad: (() => void) | undefined = undefined;
  private context: common.Context;
  private memory: string[] = [];
  private loaded: boolean = false;
  private pending: Promise<void> = Promise.resolve();
  private queued: number = 0;

  /**
   * A cache for a policy and a name (iOS `-initWithPolicy:name:`); the context gives the app's storage.
   */
  constructor(context: common.Context, policy: CYLSearchSuggestionCachePolicy, name: string) {
    this.context = context;
    this.policy = policy;
    // An empty name is the default cache, as on Android.
    this.name = name.length > 0 ? name : 'CYLSearchView';
    if (policy === CYLSearchSuggestionCachePolicy.database) {
      this.enqueue(async (store: relationalStore.RdbStore) => {
        // The table is read after the last queued change (see `enqueue`), so changes asked for before this first
        // read are kept.
        await this.importPreferences(store);
        this.loaded = true;
      });
    }
  }

  /**
   * Whether the stored queries have been read. Always true except for the database policy before its first read.
   */
  get isLoaded(): boolean {
    return this.policy !== CYLSearchSuggestionCachePolicy.database || this.loaded;
  }

  /**
   * Resolves once every change made so far is stored (the database policy writes in order, in the background).
   */
  whenStored(): Promise<void> {
    return this.pending;
  }

  // Database operations run one after another, in the order they were asked for.
  private enqueue(operation: (store: relationalStore.RdbStore) => Promise<void>): void {
    this.queued++;
    this.pending = this.pending
      .then(() => cylSuggestionDatabase(this.context))
      .then(async (store: relationalStore.RdbStore) => {
        await operation(store);
        // After the last queued change, the memory mirrors the table again and the search view is told.
        if (this.queued === 1) {
          const before = JSON.stringify(this.memory);
          await this.reload(store);
          if (this.loaded && JSON.stringify(this.memory) !== before) {
            this.onLoad?.();
          }
        }
      })
      .catch(() => {
        // The queries stay in memory for this run.
      })
      .finally(() => {
        this.queued--;
      });
  }

  private async reload(store: relationalStore.RdbStore): Promise<void> {
    const queries: string[] = [];
    let result: relationalStore.ResultSet | undefined = undefined;
    try {
      result = await store.querySql(`SELECT query FROM ${CYL_SUGGESTION_TABLE} WHERE cache = ? ORDER BY time DESC`,
        [this.name]);
      while (result.goToNextRow()) {
        queries.push(result.getString(0));
      }
      result.close();
    } catch (error) {
      // The memory keeps what this run knows.
      try {
        result?.close();
      } catch (closeError) {
        // Already closed.
      }
      return;
    }
    this.memory = queries;
  }

  // Queries kept by the earlier preferences-based database policy move into the table once.
  private async importPreferences(store: relationalStore.RdbStore): Promise<void> {
    try {
      const old = preferences.getPreferencesSync(this.context, { name: `CYLSearchSuggestions_${this.name}` });
      const queries = CYLSearchSuggestionStore.parse(old.getSync(this.name, '[]') as string);
      if (queries.length === 0) {
        return;
      }
      for (let index = queries.length - 1; index >= 0; index--) {
        await store.executeSql(`INSERT OR IGNORE INTO ${CYL_SUGGESTION_TABLE} (cache, query, time) VALUES (?, ?, ?)`,
          [this.name, queries[index], cylSuggestionNextTime()]);
      }
      old.deleteSync(this.name);
      await old.flush();
    } catch (error) {
      // Nothing to import.
    }
  }

  /**
   * A cache for a policy, or undefined for `none` (iOS `+cacheWithPolicy:name:`).
   */
  static cache(context: common.Context, policy: CYLSearchSuggestionCachePolicy,
    name: string): CYLSearchSuggestionStore | undefined {
    return policy === CYLSearchSuggestionCachePolicy.none ? undefined :
      new CYLSearchSuggestionStore(context, policy, name);
  }

  cachedQueries(): string[] {
    return this.read();
  }

  addQuery(query: string): void {
    const text = query.trim();
    if (text.length === 0) {
      return;
    }
    const queries = this.read().filter((value: string) => value !== text);
    queries.unshift(text);
    // At least one query is kept (Android `maxOf(1, maximumCount)`).
    const limit = Math.max(1, this.maximumCount);
    this.write(queries.slice(0, limit));
    if (this.policy === CYLSearchSuggestionCachePolicy.database) {
      const time = cylSuggestionNextTime();
      this.enqueue(async (store: relationalStore.RdbStore) => {
        await store.executeSql(`INSERT OR REPLACE INTO ${CYL_SUGGESTION_TABLE} (cache, query, time) VALUES (?, ?, ?)`,
          [this.name, text, time]);
        await store.executeSql(`DELETE FROM ${CYL_SUGGESTION_TABLE} WHERE cache = ? AND query NOT IN (SELECT query ` +
          `FROM ${CYL_SUGGESTION_TABLE} WHERE cache = ? ORDER BY time DESC LIMIT ${limit})`, [this.name, this.name]);
      });
    }
  }

  removeQuery(query: string): void {
    this.write(this.read().filter((value: string) => value !== query));
    if (this.policy === CYLSearchSuggestionCachePolicy.database) {
      this.enqueue(async (store: relationalStore.RdbStore) => {
        await store.executeSql(`DELETE FROM ${CYL_SUGGESTION_TABLE} WHERE cache = ? AND query = ?`, [this.name, query]);
      });
    }
  }

  removeAllQueries(): void {
    this.write([]);
    if (this.policy === CYLSearchSuggestionCachePolicy.database) {
      this.enqueue(async (store: relationalStore.RdbStore) => {
        await store.executeSql(`DELETE FROM ${CYL_SUGGESTION_TABLE} WHERE cache = ?`, [this.name]);
      });
    }
  }

  private store(): preferences.Preferences | undefined {
    try {
      return preferences.getPreferencesSync(this.context, { name: 'CYLSearchSuggestionDefaults' });
    } catch (error) {
      return undefined;
    }
  }

  private filePath(): string {
    // The name is made safe for a file name, as on Android.
    const safe = this.name.replace(new RegExp('[^A-Za-z0-9]', 'g'), '_');
    return `${this.context.filesDir}/CYLSearchSuggestions_${safe}.json`;
  }

  private read(): string[] {
    try {
      if (this.policy === CYLSearchSuggestionCachePolicy.sandboxFile) {
        if (!fileIo.accessSync(this.filePath())) {
          return [];
        }
        return CYLSearchSuggestionStore.parse(fileIo.readTextSync(this.filePath()));
      }
      if (this.policy === CYLSearchSuggestionCachePolicy.none) {
        return [];
      }
      if (this.policy === CYLSearchSuggestionCachePolicy.database) {
        // The table is read in the background; the queries are mirrored in memory.
        return this.memory.slice();
      }
      return CYLSearchSuggestionStore.parse((this.store()?.getSync(this.name, '[]') ?? '[]') as string);
    } catch (error) {
      return this.memory;
    }
  }

  private write(queries: string[]): void {
    this.memory = queries;
    try {
      const text = JSON.stringify(queries);
      if (this.policy === CYLSearchSuggestionCachePolicy.sandboxFile) {
        const file = fileIo.openSync(this.filePath(),
          fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC);
        fileIo.writeSync(file.fd, text);
        fileIo.closeSync(file);
      } else if (this.policy === CYLSearchSuggestionCachePolicy.userDefaults) {
        const store = this.store();
        store?.putSync(this.name, text);
        store?.flush();
      }
    } catch (error) {
      // The queries stay in memory for this run.
    }
  }

  private static parse(text: string): string[] {
    const values = JSON.parse(text) as Object[];
    const queries: string[] = [];
    if (Array.isArray(values)) {
      values.forEach((value: Object) => {
        if (typeof value === 'string') {
          queries.push(value as string);
        }
      });
    }
    return queries;
  }
}

import { preferences } from '@kit.ArkData';
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';

/**
 * Where the suggestion cache keeps the submitted queries (iOS `CYLSearchSuggestionCachePolicy`).
 */
export enum CYLSearchSuggestionCachePolicy {
  /**
   * No cache.
   */
  none = 0,
  /**
   * A database (the default): a preferences store of its own, named after the cache.
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
  private context: common.Context;
  private memory: string[] = [];

  /**
   * A cache for a policy and a name (iOS `-initWithPolicy:name:`); the context gives the app's storage.
   */
  constructor(context: common.Context, policy: CYLSearchSuggestionCachePolicy, name: string) {
    this.context = context;
    this.policy = policy;
    this.name = name;
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
    this.write(queries.slice(0, Math.max(0, this.maximumCount)));
  }

  removeQuery(query: string): void {
    this.write(this.read().filter((value: string) => value !== query));
  }

  removeAllQueries(): void {
    this.write([]);
  }

  private store(): preferences.Preferences {
    const storeName = this.policy === CYLSearchSuggestionCachePolicy.database ? `CYLSearchSuggestions_${this.name}` :
      'CYLSearchSuggestionDefaults';
    return preferences.getPreferencesSync(this.context, { name: storeName });
  }

  private filePath(): string {
    return `${this.context.filesDir}/CYLSearchSuggestions_${this.name}.json`;
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
        return this.memory;
      }
      return CYLSearchSuggestionStore.parse(this.store().getSync(this.name, '[]') as string);
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
      } else if (this.policy !== CYLSearchSuggestionCachePolicy.none) {
        const store = this.store();
        store.putSync(this.name, text);
        store.flush();
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

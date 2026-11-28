import { common } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import { i18n } from '@kit.LocalizationKit';
import { util } from '@kit.ArkTS';
import { cylAppText } from '../../common/DemoCommon';

/**
 * A text of the contact tags demo (iOS `cylContactTagsText`): `contactTags.<key>` of `CYLContactTags.bundle`, imported
 * into the entry's string.json as `contactTags_<key>` (scripts/import-ios-resources.py), filled with `args`.
 */
export function cylContactTagsText(context: common.Context, key: string, ...args: (string | number)[]): string {
  return cylAppText(context, `contactTags_${key}`, ...args);
}

/**
 * A tag (iOS `CYLContactTag`): its id is its primary key (a reorder or a rename keeps it, and contacts are bound to it);
 * its title is what the lists show.
 */
export class CYLContactTag {
  id: string = '';
  title: string = '';

  constructor(id: string, title: string) {
    this.id = id;
    this.title = title;
  }
}

/**
 * A demo contact (iOS `CYLContactTagData.Contact`): a name and the ids of its tags.
 */
export class CYLContactTagContact {
  name: string = '';
  tags: string[] = [];
}

/**
 * The contents of contact-tags.json (iOS `CYLContactTagData`), version 2: tags with ids, the ids of the recently used
 * ones and of the tags the remark screen starts with, and the contacts.
 */
export class CYLContactTagData {
  version: number = 0;
  tags: CYLContactTag[] = [];
  recentTags: string[] = [];
  selectedTags: string[] = [];
  contacts: CYLContactTagContact[] = [];

  /**
   * The rawfile of the current language: contacttags/<qualifier>.json (base, ja_JP, zh_CN, zh_TW).
   */
  static bundled(context: common.Context): CYLContactTagData {
    const language = i18n.System.getSystemLanguage();
    let file = 'base';
    if (language.startsWith('zh')) {
      file = language.includes('Hant') || language.includes('TW') || language.includes('HK') ? 'zh_TW' : 'zh_CN';
    } else if (language.startsWith('ja')) {
      file = 'ja_JP';
    }
    try {
      const bytes = context.resourceManager.getRawFileContentSync(`contacttags/${file}.json`);
      return JSON.parse(new util.TextDecoder('utf-8').decodeToString(bytes)) as CYLContactTagData;
    } catch (error) {
      return new CYLContactTagData();
    }
  }
}

/**
 * Sections of tags ("mine", "recent") with their ids, as JSON: cache A and the server's cache B keep ids with the
 * titles, as iOS's `CYLTagListCacheItem`.
 */
export class CYLContactTagSections {
  static encode(sections: Map<string, CYLContactTag[]>): string {
    const record: Record<string, CYLContactTag[]> = {};
    sections.forEach((items: CYLContactTag[], key: string) => {
      record[key] = items;
    });
    return JSON.stringify(record);
  }

  static decode(text: string | undefined): Map<string, CYLContactTag[]> {
    const result = new Map<string, CYLContactTag[]>();
    if (text === undefined || text.length === 0) {
      return result;
    }
    try {
      const record = JSON.parse(text) as Record<string, CYLContactTag[]>;
      Object.keys(record).forEach((key: string) => {
        result.set(key, record[key].map((tag: CYLContactTag) => new CYLContactTag(tag.id, tag.title)));
      });
    } catch (error) {
      return result;
    }
    return result;
  }
}

/** The cache keys of "My Tags" and "Recent". */
export const CYL_CONTACT_TAGS_MINE: string = 'mine';
export const CYL_CONTACT_TAGS_RECENT: string = 'recent';
/** The names of cache A (the store) and cache B (the simulated server). */
export const CYL_CONTACT_TAGS_CACHE: string = 'CYLContactTags';
export const CYL_CONTACT_TAGS_SERVER: string = 'CYLContactTagsServer';
const SECTIONS_KEY: string = 'sections';

/**
 * Reads and writes a sections preference file (caches A and B).
 */
export class CYLContactTagPreferences {
  private store: preferences.Preferences | undefined = undefined;

  constructor(context: common.Context, name: string) {
    try {
      this.store = preferences.getPreferencesSync(context, { name: name });
    } catch (error) {
      this.store = undefined;
    }
  }

  read(): Map<string, CYLContactTag[]> {
    return CYLContactTagSections.decode(this.store?.getSync(SECTIONS_KEY, '') as string);
  }

  write(sections: Map<string, CYLContactTag[]>): void {
    this.store?.putSync(SECTIONS_KEY, CYLContactTagSections.encode(sections));
    this.store?.flush();
  }

  clear(): void {
    this.store?.clearSync();
    this.store?.flush();
  }
}

/**
 * The user's tags (iOS `CYLContactTagStore`), keyed by id: every tag in the user's order, and the recently used ones.
 * Changes are saved to `cache` (cache A) with their ids.
 */
export class CYLContactTagStore {
  /** Every tag, in the user's order ("My Tags"). */
  tags: CYLContactTag[] = [];
  /** The ids of the recently used tags, the most recent first ("Recent"). */
  recentIDs: string[] = [];
  /** How many recent tags are kept. */
  recentLimit: number = 8;
  /** The demo contacts and the ids of their tags. */
  contacts: CYLContactTagContact[] = [];
  /** Where the changes are saved (cache A); undefined keeps them in memory. */
  cache: CYLContactTagPreferences | undefined = undefined;

  constructor(tags: CYLContactTag[], recentIDs: string[] = []) {
    const seen = new Set<string>();
    this.tags = tags.filter((tag: CYLContactTag) => {
      if (seen.has(tag.id)) {
        return false;
      }
      seen.add(tag.id);
      return true;
    });
    this.recentIDs = recentIDs.filter((id: string) => seen.has(id)).slice(0, this.recentLimit);
  }

  /**
   * The demo tags of the current language, with cache A's saved order, names and contents on top.
   */
  static bundled(context: common.Context): CYLContactTagStore {
    const data = CYLContactTagData.bundled(context);
    const cache = new CYLContactTagPreferences(context, CYL_CONTACT_TAGS_CACHE);
    const saved = cache.read();
    const tags = saved.get(CYL_CONTACT_TAGS_MINE) ?? data.tags.map((tag: CYLContactTag) => new CYLContactTag(tag.id, tag.title));
    const recent = saved.get(CYL_CONTACT_TAGS_RECENT)?.map((tag: CYLContactTag) => tag.id) ?? data.recentTags;
    const store = new CYLContactTagStore(tags, recent);
    store.contacts = data.contacts ?? [];
    store.cache = cache;
    return store;
  }

  /** A tag name as stored: without surrounding spaces and new lines. */
  static normalizedName(name: string): string {
    return name.trim();
  }

  tag(id: string): CYLContactTag | undefined {
    return this.tags.find((tag: CYLContactTag) => tag.id === id);
  }

  title(id: string): string | undefined {
    return this.tag(id)?.title;
  }

  idOfTitle(title: string): string | undefined {
    return this.tags.find((tag: CYLContactTag) => tag.title === title)?.id;
  }

  get tagIDs(): string[] {
    return this.tags.map((tag: CYLContactTag) => tag.id);
  }

  contains(id: string): boolean {
    return this.tag(id) !== undefined;
  }

  /** The contacts that have the tag with `id` (bound to the id, so a renamed tag keeps them). */
  contactsWithTag(id: string): CYLContactTagContact[] {
    return this.contacts.filter((contact: CYLContactTagContact) => contact.tags.includes(id));
  }

  /** "My Tags" and "Recent" with their ids, for cache A and the server. */
  get cacheSections(): Map<string, CYLContactTag[]> {
    const sections = new Map<string, CYLContactTag[]>();
    sections.set(CYL_CONTACT_TAGS_MINE, this.tags.slice());
    const recent: CYLContactTag[] = [];
    this.recentIDs.forEach((id: string) => {
      const tag = this.tag(id);
      if (tag !== undefined) {
        recent.push(tag);
      }
    });
    sections.set(CYL_CONTACT_TAGS_RECENT, recent);
    return sections;
  }

  save(): void {
    this.cache?.write(this.cacheSections);
  }

  /**
   * The ids of the tags whose titles contain `query`, ignoring case and accents; those starting with it first.
   */
  tagsMatching(query: string): string[] {
    const q = CYLContactTagStore.normalizedName(query);
    if (q.length === 0) {
      return [];
    }
    const fold = (text: string): string => text.normalize('NFKD').replace(/[̀-ͯ]/g, '').toLowerCase();
    const folded = fold(q);
    const matches = this.tags.filter((tag: CYLContactTag) => fold(tag.title).includes(folded));
    const prefixed = matches.filter((tag: CYLContactTag) => fold(tag.title).startsWith(folded));
    const rest = matches.filter((tag: CYLContactTag) => !prefixed.includes(tag));
    return prefixed.concat(rest).map((tag: CYLContactTag) => tag.id);
  }

  /** Whether "+ New tag: <name>" is offered: a title that no tag has yet. */
  canCreate(name: string): boolean {
    const title = CYLContactTagStore.normalizedName(name);
    return title.length > 0 && this.idOfTitle(title) === undefined;
  }

  /** Adds a tag (a new id) at the end of "My Tags" and returns its id; an existing title returns its id. */
  createTag(name: string): string | undefined {
    const title = CYLContactTagStore.normalizedName(name);
    if (title.length === 0) {
      return undefined;
    }
    const existing = this.idOfTitle(title);
    if (existing !== undefined) {
      return existing;
    }
    const tag = new CYLContactTag('u-' + util.generateRandomUUID(false).slice(0, 8), title);
    this.tags = this.tags.concat([tag]);
    this.save();
    return tag.id;
  }

  /** Renames the tag with `id` (its id, place and contacts stay); an empty title does nothing. */
  renameTag(id: string, title: string): void {
    const name = CYLContactTagStore.normalizedName(title);
    if (name.length === 0 || !this.contains(id)) {
      return;
    }
    this.tags = this.tags.map((tag: CYLContactTag) => tag.id === id ? new CYLContactTag(id, name) : tag);
    this.save();
  }

  /** Moves the tag at `from` to `to` in "My Tags" (a drag in editing mode). */
  moveTag(from: number, to: number): void {
    if (from < 0 || to < 0 || from >= this.tags.length || to >= this.tags.length || from === to) {
      return;
    }
    const tags = this.tags.slice();
    const moved = tags.splice(from, 1)[0];
    tags.splice(to, 0, moved);
    this.tags = tags;
    this.save();
  }

  /** Takes sections downloaded from the server; returns whether anything changed. */
  apply(sections: Map<string, CYLContactTag[]>): boolean {
    let changed = false;
    const mine = sections.get(CYL_CONTACT_TAGS_MINE);
    if (mine !== undefined) {
      const downloaded = new CYLContactTagStore(mine).tags;
      const same = downloaded.length === this.tags.length &&
        downloaded.every((tag: CYLContactTag, index: number) => tag.id === this.tags[index].id && tag.title === this.tags[index].title);
      if (!same) {
        this.tags = downloaded;
        this.recentIDs = this.recentIDs.filter((id: string) => this.contains(id));
        changed = true;
      }
    }
    const recent = sections.get(CYL_CONTACT_TAGS_RECENT);
    if (recent !== undefined) {
      const ids = recent.map((tag: CYLContactTag) => tag.id).filter((id: string) => this.contains(id)).slice(0, this.recentLimit);
      if (ids.join('\n') !== this.recentIDs.join('\n')) {
        this.recentIDs = ids;
        changed = true;
      }
    }
    if (changed) {
      this.save();
    }
    return changed;
  }

  /** Empties "Recent". */
  clearRecent(): void {
    this.recentIDs = [];
    this.save();
  }

  /** Removes the tag with `id` from "My Tags" and "Recent". */
  deleteTag(id: string): void {
    this.tags = this.tags.filter((tag: CYLContactTag) => tag.id !== id);
    this.recentIDs = this.recentIDs.filter((recent: string) => recent !== id);
    this.save();
  }

  /** Moves the `used` ids to the front of "Recent" (when the editor is confirmed). */
  markUsed(used: string[]): void {
    const known = used.filter((id: string) => this.contains(id));
    this.recentIDs = known.concat(this.recentIDs.filter((id: string) => !known.includes(id))).slice(0, this.recentLimit);
    this.save();
  }
}

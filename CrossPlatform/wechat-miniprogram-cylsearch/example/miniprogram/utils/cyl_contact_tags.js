// The contact tags demo's data (iOS CYLContactTagStore + CYLContactTagServer): the tags with ids, the recent ones and the
// contacts of contact-tags.json (CYLContactTags.bundle, imported into utils/cyl_demo_resources.js), cache A (the store's
// storage) and the simulated server's cache B (another storage key, reached after a delay). Texts: cylDemoText('contactTags.x').
const resources = require('./cyl_demo_resources');
const { cylDemoLanguage, cylDemoText } = require('./cyl_demo_text');

const MINE = 'mine';
const RECENT = 'recent';
/** Cache A (the store) and cache B (the simulated server). */
const CACHE_KEY = 'CYLContactTags';
const SERVER_KEY = 'CYLContactTagsServer';

/** A text of the demo (iOS cylContactTagsText). */
function cylContactTagsText(key, ...args) {
  return cylDemoText(`contactTags.${key}`, ...args);
}

function language() {
  let wechat = 'en';
  try {
    wechat = (typeof wx !== 'undefined' && wx.getAppBaseInfo ? wx.getAppBaseInfo().language : 'en') || 'en';
  } catch (error) {
    wechat = 'en';
  }
  return cylDemoLanguage(wechat);
}

/** contact-tags.json of the current language (version 2: tags with ids). */
function bundledData(lang) {
  const data = resources.contactTags[lang || language()] || resources.contactTags.en;
  return JSON.parse(JSON.stringify(data));
}

function readSections(key) {
  try {
    const value = typeof wx !== 'undefined' ? wx.getStorageSync(key) : '';
    return value && typeof value === 'object' ? value : {};
  } catch (error) {
    return {};
  }
}

function writeSections(key, sections) {
  try {
    if (typeof wx !== 'undefined') wx.setStorageSync(key, sections);
  } catch (error) {
    // Storage full or unavailable: the edits stay in memory.
  }
}

function normalizedName(name) {
  return String(name || '').trim();
}

function fold(text) {
  return String(text).normalize('NFKD').replace(/[̀-ͯ]/g, '').toLowerCase();
}

/**
 * The user's tags (iOS CYLContactTagStore), keyed by id: every tag in the user's order, and the recently used ones.
 * Changes are saved to cache A with their ids.
 */
class CYLContactTagStore {
  constructor(tags, recentIDs = [], recentLimit = 8) {
    const seen = new Set();
    this.tags = (tags || []).filter((tag) => (seen.has(tag.id) ? false : seen.add(tag.id))).map((tag) => ({ id: tag.id, title: tag.title }));
    this.recentLimit = recentLimit;
    this.recentIDs = (recentIDs || []).filter((id) => seen.has(id)).slice(0, recentLimit);
    this.contacts = [];
    this.persists = false;
  }

  /** The demo tags of the current language, with cache A's saved order, names and contents on top. */
  static bundled(lang) {
    const data = bundledData(lang);
    const saved = readSections(CACHE_KEY);
    const store = new CYLContactTagStore(saved[MINE] || data.tags, (saved[RECENT] || []).map((tag) => tag.id).concat(saved[RECENT] ? [] : data.recentTags));
    store.contacts = data.contacts || [];
    store.persists = true;
    return store;
  }

  /** Forgets the saved edits (caches A and B). */
  static reset() {
    writeSections(CACHE_KEY, {});
    writeSections(SERVER_KEY, {});
  }

  tag(id) { return this.tags.find((tag) => tag.id === id); }
  title(id) { const tag = this.tag(id); return tag ? tag.title : undefined; }
  idOfTitle(title) { const tag = this.tags.find((t) => t.title === title); return tag ? tag.id : undefined; }
  contains(id) { return this.tag(id) !== undefined; }
  get tagIDs() { return this.tags.map((tag) => tag.id); }
  contactsWithTag(id) { return this.contacts.filter((contact) => (contact.tags || []).includes(id)); }

  /** "My Tags" and "Recent" with their ids, for cache A and the server. */
  get cacheSections() {
    return { [MINE]: this.tags.map((tag) => ({ ...tag })), [RECENT]: this.recentIDs.map((id) => this.tag(id)).filter(Boolean).map((tag) => ({ ...tag })) };
  }

  save() {
    if (this.persists) writeSections(CACHE_KEY, this.cacheSections);
  }

  /** The ids whose titles contain `query`, ignoring case and accents; those starting with it first. */
  tagsMatching(query) {
    const q = fold(normalizedName(query));
    if (!q) return [];
    const matches = this.tags.filter((tag) => fold(tag.title).includes(q));
    const prefixed = matches.filter((tag) => fold(tag.title).startsWith(q));
    return prefixed.concat(matches.filter((tag) => !prefixed.includes(tag))).map((tag) => tag.id);
  }

  canCreate(name) {
    const title = normalizedName(name);
    return title.length > 0 && this.idOfTitle(title) === undefined;
  }

  /** Adds a tag (a new id) at the end of "My Tags" and returns its id; an existing title returns its id. */
  createTag(name) {
    const title = normalizedName(name);
    if (!title) return undefined;
    const existing = this.idOfTitle(title);
    if (existing) return existing;
    const id = `u-${Math.random().toString(16).slice(2, 10)}`;
    this.tags = this.tags.concat([{ id, title }]);
    this.save();
    return id;
  }

  /** Renames the tag with `id` (its id, place and contacts stay). */
  renameTag(id, title) {
    const name = normalizedName(title);
    if (!name || !this.contains(id)) return;
    this.tags = this.tags.map((tag) => (tag.id === id ? { id, title: name } : tag));
    this.save();
  }

  moveTag(from, to) {
    if (from === to || from < 0 || to < 0 || from >= this.tags.length || to >= this.tags.length) return;
    const tags = this.tags.slice();
    tags.splice(to, 0, tags.splice(from, 1)[0]);
    this.tags = tags;
    this.save();
  }

  /** Takes sections downloaded from the server; returns whether anything changed. */
  apply(sections) {
    let changed = false;
    if (sections[MINE]) {
      const downloaded = new CYLContactTagStore(sections[MINE]).tags;
      if (JSON.stringify(downloaded) !== JSON.stringify(this.tags)) {
        this.tags = downloaded;
        this.recentIDs = this.recentIDs.filter((id) => this.contains(id));
        changed = true;
      }
    }
    if (sections[RECENT]) {
      const ids = sections[RECENT].map((tag) => tag.id).filter((id) => this.contains(id)).slice(0, this.recentLimit);
      if (ids.join('\n') !== this.recentIDs.join('\n')) {
        this.recentIDs = ids;
        changed = true;
      }
    }
    if (changed) this.save();
    return changed;
  }

  clearRecent() {
    this.recentIDs = [];
    this.save();
  }

  deleteTag(id) {
    this.tags = this.tags.filter((tag) => tag.id !== id);
    this.recentIDs = this.recentIDs.filter((recent) => recent !== id);
    this.save();
  }

  markUsed(used) {
    const known = used.filter((id) => this.contains(id));
    this.recentIDs = known.concat(this.recentIDs.filter((id) => !known.includes(id))).slice(0, this.recentLimit);
    this.save();
  }
}

/**
 * The simulated server (iOS CYLContactTagServer): cache B, reached after `latency` seconds, with the page's HUD
 * (`hud`: a CYLPlaceholderHUD of cyl-placeholder-hud): download ("Downloading…"), upload ("Uploading…") and an edit
 * simulated on another device (a random new tag, the first two tags swapped), pulled by the sync button.
 */
class CYLContactTagServer {
  constructor(hud, latency = 5) {
    this.hud = hud;
    this.latency = latency;
    this.timers = [];
    this.nextFetchStatus = undefined;
  }

  later(action) {
    this.timers.push(setTimeout(action, this.latency * 1000));
  }

  fetch(keys, completion) {
    const status = this.nextFetchStatus || cylContactTagsText('downloading');
    const finished = cylContactTagsText(this.nextFetchStatus ? 'synced' : 'downloaded');
    this.nextFetchStatus = undefined;
    if (this.hud) this.hud.showWithStatus(status);
    this.later(() => {
      const stored = readSections(SERVER_KEY);
      const sections = {};
      keys.forEach((key) => { if (stored[key]) sections[key] = stored[key]; });
      if (this.hud) this.hud.showSuccessWithStatus(finished);
      completion(sections);
    });
  }

  upload(sections) {
    if (this.hud) this.hud.showWithStatus(cylContactTagsText('uploading'));
    this.later(() => {
      writeSections(SERVER_KEY, { ...readSections(SERVER_KEY), ...sections });
      if (this.hud) this.hud.showSuccessWithStatus(cylContactTagsText('uploaded'));
    });
  }

  simulateOtherDeviceEdit(localItems) {
    const stored = readSections(SERVER_KEY);
    const tags = (stored[MINE] || localItems || []).slice();
    const titles = new Set(tags.map((tag) => tag.title));
    const pool = cylContactTagsText('otherDeviceTags').split(',').filter((title) => !titles.has(title));
    const added = pool.length ? pool[Math.floor(Math.random() * pool.length)] : `${cylContactTagsText('otherDeviceTags')} ${tags.length}`;
    tags.push({ id: `o-${Math.random().toString(16).slice(2, 10)}`, title: added });
    if (tags.length > 1) [tags[0], tags[1]] = [tags[1], tags[0]];
    writeSections(SERVER_KEY, { ...stored, [MINE]: tags });
    this.nextFetchStatus = cylContactTagsText('syncing');
    return added;
  }

  cancel() {
    this.timers.forEach((timer) => clearTimeout(timer));
    this.timers = [];
  }
}

/**
 * The demo's tag look (iOS CYLContactTagEditorViewController.tagStyle()) over cyl-tag-cloud's full `base` style
 * (model.defaultStyle()): gray tags, green selected tags, 16 pt, 36 pt tall, 12 pt apart.
 */
function cylContactTagStyle(base) {
  const style = JSON.parse(JSON.stringify(base));
  ['normal', 'selected', 'disabled'].forEach((state) => {
    Object.assign(style[state], { fontSize: 16, cornerRadius: 6, borderWidth: 0, borderColor: null, contentInsets: { top: 5, left: 14, bottom: 5, right: 14 } });
  });
  Object.assign(style.normal, { backgroundColor: '#F2F2F7', textColor: '#000000' });
  Object.assign(style.selected, { backgroundColor: 'rgba(7,193,96,0.1)', textColor: '#07C160' });
  Object.assign(style, { itemHeight: 36, interitemSpacing: 12, lineSpacing: 12, sectionInsets: { top: 4, left: 16, bottom: 12, right: 16 } });
  return style;
}

/** The store shared by the demo's pages (Edit Remarks opens Edit Tags with it). */
let sharedStore = null;
function cylContactTagsSharedStore(options = {}) {
  if (options.reset) {
    CYLContactTagStore.reset();
    sharedStore = null;
  }
  if (options.empty) {
    sharedStore = new CYLContactTagStore([]);
  } else if (!sharedStore) {
    sharedStore = CYLContactTagStore.bundled();
  }
  return sharedStore;
}

module.exports = {
  MINE, RECENT, CYLContactTagStore, cylContactTagStyle, CYLContactTagServer, cylContactTagsText, cylContactTagsSharedStore, bundledData,
};

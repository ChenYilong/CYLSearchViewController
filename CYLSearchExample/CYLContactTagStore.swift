//
//  CYLContactTagStore.swift
//  CYLSearchExample
//
//  The contact tags demo, ported from CollectionViewClassifyMenu's CYLTagEditorExample (CYLTagStore): the user's tags,
//  in the user's order, the recently used ones and the contacts. The demo data is read from CYLContactTags.bundle/
//  <language>.lproj/contact-tags.json (CYLContactTagData); every change (a reorder in editing mode, a deleted or added
//  tag, a cleared "Recent") is saved in CollectionViewClassifyMenu's tag list cache (CYLTagListStore, a SQLite database)
//  and restored at the next launch.
//

import UIKit
import CollectionViewClassifyMenu

/**
 * A tag: its id is its primary key (a reorder or a rename keeps it, and contacts are bound to it); its title is what
 * the lists show.
 */
struct CYLContactTag: Codable, Equatable {
    /**
     * The primary key.
     */
    var id: String

    /**
     * The name shown.
     */
    var title: String
}

/**
 * The user's tags (like a chat app's contact tags), keyed by id: every tag in the user's order, and the recently used
 * ones. New tags are added here; the editor only reads and asks it to change. Changes are saved to `cache` (cache A)
 * as CollectionViewClassifyMenu cache items (id and title).
 */
final class CYLContactTagStore {

    /**
     * Every tag, in the user's order ("My Tags").
     */
    private(set) var tags: [CYLContactTag]

    /**
     * The ids of the recently used tags, the most recent first ("Recent").
     */
    private(set) var recentIDs: [String]

    /**
     * How many recent tags are kept.
     */
    let recentLimit: Int

    /**
     * The demo contacts and the ids of their tags.
     */
    private(set) var contacts: [CYLContactTagData.Contact] = []

    /**
     * Where the changes are saved (CollectionViewClassifyMenu's `CYLTagListStore`, cache A); nil keeps them in memory.
     */
    var cache: CYLTagListCache?

    /**
     * The cache keys of "My Tags" and "Recent" (`CYLTagListView.cacheKey(forSection:)` of the editor).
     */
    static let mineCacheKey = "mine"
    static let recentCacheKey = "recent"

    /**
     * The name of the demo's cache (`CYLTagListView.cacheName` of the editor).
     */
    static let cacheName = "CYLContactTags"

    /**
     * A store with `tags` (duplicate ids dropped) and the `recentIDs` among them, at most `recentLimit`.
     */
    init(tags: [CYLContactTag], recentIDs: [String] = [], recentLimit: Int = 8) {
        var seen = Set<String>()
        self.tags = tags.filter { seen.insert($0.id).inserted }
        self.recentLimit = recentLimit
        self.recentIDs = Array(recentIDs.filter { seen.contains($0) }.prefix(recentLimit))
    }

    /**
     * The demo tags of the app's language (contact-tags.json), with cache A's saved order, names and contents on top.
     */
    static func bundled(cache: CYLTagListCache? = CYLTagListStore(policy: .database, name: cacheName)) -> CYLContactTagStore {
        guard let data = try? CYLContactTagData.bundled() else {
            return CYLContactTagStore(tags: [])
        }
        // The saved items (id and title) win over the bundled demo data.
        let tags = cache?.cachedItems?(forSection: mineCacheKey).map { $0.map { CYLContactTag(id: $0.identifier, title: $0.title) } }
            ?? data.tags
        let recent = cache?.cachedItems?(forSection: recentCacheKey)?.map(\.identifier) ?? data.recentTags
        let store = CYLContactTagStore(tags: tags, recentIDs: recent)
        store.contacts = data.contacts ?? []
        store.cache = cache
        return store
    }

    /**
     * The tag with `id`, if it exists.
     */
    func tag(withID id: String) -> CYLContactTag? {
        tags.first { $0.id == id }
    }

    /**
     * The title of the tag with `id`; nil when there is none.
     */
    func title(of id: String) -> String? {
        tag(withID: id)?.title
    }

    /**
     * The id of the tag titled exactly `title`, if any.
     */
    func id(ofTitle title: String) -> String? {
        tags.first { $0.title == title }?.id
    }

    /**
     * The ids in "My Tags", in order.
     */
    var tagIDs: [String] {
        tags.map(\.id)
    }

    /**
     * The contacts that have the tag with `id` (bound to the id, so a renamed tag keeps them), in the file's order.
     */
    func contacts(withTagID id: String) -> [CYLContactTagData.Contact] {
        contacts.filter { $0.tags.contains(id) }
    }

    /**
     * "My Tags" and "Recent" as cache items (id and title), for cache A and the server.
     */
    var cacheSections: [String: [CYLTagListCacheItem]] {
        [Self.mineCacheKey: tags.map { CYLTagListCacheItem(identifier: $0.id, title: $0.title) },
         Self.recentCacheKey: recentIDs.compactMap { id in title(of: id).map { CYLTagListCacheItem(identifier: id, title: $0) } }]
    }

    /**
     * Saves "My Tags" and "Recent" to `cache` (cache A), with their ids.
     */
    func save() {
        for (key, items) in cacheSections {
            if cache?.saveItems?(items, forSection: key) == nil {
                cache?.saveTitles(items.map(\.title), forSection: key)
            }
        }
    }

    /**
     * A tag name as stored: without surrounding spaces and new lines.
     */
    static func normalizedName(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /**
     * Whether a tag with `id` exists.
     */
    func contains(_ id: String) -> Bool {
        tag(withID: id) != nil
    }

    /**
     * The ids of the tags whose titles contain `query`, ignoring case and width ("ios" finds "iOS"); those starting with
     * it first.
     */
    func tags(matching query: String) -> [String] {
        let query = CYLContactTagStore.normalizedName(query)
        guard !query.isEmpty else { return [] }
        let options: String.CompareOptions = [.caseInsensitive, .widthInsensitive, .diacriticInsensitive]
        let matches = tags.filter { $0.title.range(of: query, options: options) != nil }
        let prefixed = matches.filter { $0.title.range(of: query, options: options.union(.anchored)) != nil }
        return (prefixed + matches.filter { !prefixed.contains($0) }).map(\.id)
    }

    /**
     * Whether "+ New tag: <name>" is offered: a title that no tag has yet (the exact title, as in the chat app).
     */
    func canCreate(_ name: String) -> Bool {
        let name = CYLContactTagStore.normalizedName(name)
        return !name.isEmpty && id(ofTitle: name) == nil
    }

    /**
     * Adds a tag (a new id) at the end of "My Tags" and returns its id; a tag with that title already is returned as
     * is; nil for an empty name.
     */
    @discardableResult
    func createTag(named name: String) -> String? {
        let name = CYLContactTagStore.normalizedName(name)
        guard !name.isEmpty else { return nil }
        if let existing = id(ofTitle: name) {
            return existing
        }
        let tag = CYLContactTag(id: "u-" + UUID().uuidString.prefix(8).lowercased(), title: name)
        tags.append(tag)
        save()
        return tag.id
    }

    /**
     * Renames the tag with `id` (its id, place and contacts stay); an empty title does nothing.
     */
    func renameTag(_ id: String, to title: String) {
        let title = CYLContactTagStore.normalizedName(title)
        guard !title.isEmpty, let index = tags.firstIndex(where: { $0.id == id }) else { return }
        tags[index].title = title
        save()
    }

    /**
     * Moves the tag at `from` to `to` in "My Tags" (a drag in editing mode).
     */
    func moveTag(from: Int, to: Int) {
        guard tags.indices.contains(from), tags.indices.contains(to), from != to else { return }
        tags.insert(tags.remove(at: from), at: to)
        save()
    }

    /**
     * Takes sections downloaded from the server (items with ids): "My Tags" and "Recent", each when present; returns
     * whether anything changed.
     */
    @discardableResult
    func apply(_ sections: [String: [CYLTagListCacheItem]]) -> Bool {
        var changed = false
        if let mine = sections[Self.mineCacheKey] {
            var seen = Set<String>()
            let downloaded = mine.filter { seen.insert($0.identifier).inserted }.map { CYLContactTag(id: $0.identifier, title: $0.title) }
            if downloaded != tags {
                tags = downloaded
                recentIDs = recentIDs.filter(contains)
                changed = true
            }
        }
        if let recent = sections[Self.recentCacheKey]?.map(\.identifier).filter(contains), recent != recentIDs {
            recentIDs = Array(recent.prefix(recentLimit))
            changed = true
        }
        if changed {
            save()
        }
        return changed
    }

    /**
     * Empties "Recent" (its trash button).
     */
    func clearRecent() {
        recentIDs.removeAll()
        save()
    }

    /**
     * Removes the tag with `id` from "My Tags" and "Recent".
     */
    func deleteTag(_ id: String) {
        tags.removeAll { $0.id == id }
        recentIDs.removeAll { $0 == id }
        save()
    }

    /**
     * Moves the tags with `used` ids to the front of "Recent" (when the editor is confirmed).
     */
    func markUsed(_ used: [String]) {
        let used = used.filter(contains)
        recentIDs = Array((used + recentIDs.filter { !used.contains($0) }).prefix(recentLimit))
        save()
    }
}

/**
 * The contents of contact-tags.json: the demo tags (id and title), the ids of the recently used ones and of the tags
 * the remark screen starts with, and the contacts.
 */
struct CYLContactTagData: Codable, Equatable {
    /**
     * The file format version (2: tags with ids).
     */
    var version: Int

    /**
     * Every tag, in order.
     */
    var tags: [CYLContactTag]

    /**
     * The ids of the recently used tags.
     */
    var recentTags: [String]

    /**
     * The ids of the tags the remark screen starts with.
     */
    var selectedTags: [String]

    /**
     * A demo contact: a name and the ids of its tags.
     */
    struct Contact: Codable, Equatable {
        /**
         * The contact's name.
         */
        var name: String

        /**
         * The ids of the contact's tags.
         */
        var tags: [String]
    }

    /**
     * The demo contacts (the contacts page of a tag).
     */
    var contacts: [Contact]?

    /**
     * contact-tags.json of the app's language.
     */
    static func bundled() throws -> CYLContactTagData {
        guard let url = CYLContactTagsLocalization.stringsBundle?.url(forResource: "contact-tags", withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile)
        }
        return try JSONDecoder().decode(CYLContactTagData.self, from: Data(contentsOf: url))
    }
}

/**
 * The example-level bundle of the contact tags demo (`CYLContactTags.bundle`, one `.lproj` per language).
 */
enum CYLContactTagsLocalization {
    /**
     * The bundle itself.
     */
    static let resourceBundle: Bundle? = Bundle.main.url(forResource: "CYLContactTags", withExtension: "bundle").flatMap(Bundle.init(url:))

    /**
     * The `.lproj` of the app's preferred language, else English.
     */
    static var stringsBundle: Bundle? {
        guard let bundle = resourceBundle else { return nil }
        let language = Bundle.preferredLocalizations(from: bundle.localizations, forPreferences: Locale.preferredLanguages).first ?? "en"
        return bundle.path(forResource: language, ofType: "lproj").flatMap(Bundle.init(path:))
            ?? bundle.path(forResource: "en", ofType: "lproj").flatMap(Bundle.init(path:))
    }
}

/**
 * A text of the contact tags demo (`contactTags.<key>` in `CYLContactTags.bundle`), formatted with `arguments`.
 */
func cylContactTagsText(_ key: String, _ arguments: CVarArg...) -> String {
    let fullKey = "contactTags." + key
    let format = CYLContactTagsLocalization.stringsBundle?.localizedString(forKey: fullKey, value: fullKey, table: "CYLContactTags") ?? fullKey
    return arguments.isEmpty ? format : String(format: format, arguments: arguments)
}

/**
 * The entry of the contact tags demo for the Objective-C Examples menu (row 6): its title and its first screen.
 */
@objc(CYLContactTagsDemo)
final class CYLContactTagsDemo: NSObject {
    /**
     * The menu row's title.
     */
    @objc static func rowTitle() -> String {
        cylContactTagsText("row")
    }

    /**
     * Forgets the saved edits (the demo's tag list cache).
     */
    @objc static func resetCache() {
        CYLTagListStore(policy: .database, name: CYLContactTagStore.cacheName).removeAllTitles()
        CYLContactTagServer().reset()
    }

    /**
     * "Edit Remarks" with the demo tags of the app's language, to push.
     */
    @objc static func viewController() -> UIViewController {
        // `-CYLContactTagsEmpty YES` on launch starts without tags (the CYLPlaceholderView empty states), for screenshots.
        if UserDefaults.standard.bool(forKey: "CYLContactTagsEmpty") {
            return CYLContactRemarkViewController(store: CYLContactTagStore(tags: []), tags: [])
        }
        // `-CYLContactTagsResetCache YES` on launch forgets the saved edits, for screenshots and tests.
        if UserDefaults.standard.bool(forKey: "CYLContactTagsResetCache") {
            resetCache()
        }
        let store = CYLContactTagStore.bundled()
        let selected = (try? CYLContactTagData.bundled().selectedTags) ?? []
        return CYLContactRemarkViewController(store: store, tags: selected.filter(store.contains))
    }
}

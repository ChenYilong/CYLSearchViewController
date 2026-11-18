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
 * The user's tags (like a chat app's contact tags): every tag in the user's order, and the recently used ones. New tags
 * are added here; the editor only reads and asks it to change.
 */
final class CYLContactTagStore {

    /**
     * Every tag, in the user's order ("My Tags").
     */
    private(set) var tags: [String]

    /**
     * The recently used tags, the most recent first ("Recent").
     */
    private(set) var recentTags: [String]

    /**
     * How many recent tags are kept.
     */
    let recentLimit: Int

    /**
     * The demo contacts and their tags.
     */
    private(set) var contacts: [CYLContactTagData.Contact] = []

    /**
     * Where the changes are saved (CollectionViewClassifyMenu's `CYLTagListStore`); nil keeps them in memory.
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
     * A store with `tags` (duplicates dropped) and the `recentTags` among them, at most `recentLimit`.
     */
    init(tags: [String], recentTags: [String] = [], recentLimit: Int = 8) {
        var seen = Set<String>()
        self.tags = tags.filter { seen.insert($0).inserted }
        self.recentLimit = recentLimit
        self.recentTags = Array(recentTags.filter { seen.contains($0) }.prefix(recentLimit))
    }

    /**
     * The demo tags of the app's language (contact-tags.json); an empty store when the file is missing or invalid.
     */
    static func bundled(cache: CYLTagListCache? = CYLTagListStore(policy: .database, name: cacheName)) -> CYLContactTagStore {
        guard let data = try? CYLContactTagData.bundled() else {
            return CYLContactTagStore(tags: [])
        }
        // The saved order and contents win over the bundled demo data.
        let tags = cache?.cachedTitles(forSection: mineCacheKey) ?? data.tags
        let recent = cache?.cachedTitles(forSection: recentCacheKey) ?? data.recentTags
        let store = CYLContactTagStore(tags: tags, recentTags: recent)
        store.contacts = data.contacts ?? []
        store.cache = cache
        return store
    }

    /**
     * The contacts that have `tag`, in the file's order.
     */
    func contacts(withTag tag: String) -> [CYLContactTagData.Contact] {
        contacts.filter { $0.tags.contains(tag) }
    }

    /**
     * Saves "My Tags" and "Recent" to `cache`.
     */
    func save() {
        cache?.saveTitles(tags, forSection: Self.mineCacheKey)
        cache?.saveTitles(recentTags, forSection: Self.recentCacheKey)
    }

    /**
     * A tag name as stored: without surrounding spaces and new lines.
     */
    static func normalizedName(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /**
     * Whether `tag` is one of the user's tags.
     */
    func contains(_ tag: String) -> Bool {
        tags.contains(tag)
    }

    /**
     * The tags containing `query`, ignoring case and width ("ios" finds "iOS"); those starting with it first.
     */
    func tags(matching query: String) -> [String] {
        let query = CYLContactTagStore.normalizedName(query)
        guard !query.isEmpty else { return [] }
        let options: String.CompareOptions = [.caseInsensitive, .widthInsensitive, .diacriticInsensitive]
        let matches = tags.filter { $0.range(of: query, options: options) != nil }
        let prefixed = matches.filter { $0.range(of: query, options: options.union(.anchored)) != nil }
        return prefixed + matches.filter { !prefixed.contains($0) }
    }

    /**
     * Whether "+ New tag: <name>" is offered: a name that is not a tag yet (the exact name, as in the chat app).
     */
    func canCreate(_ name: String) -> Bool {
        let name = CYLContactTagStore.normalizedName(name)
        return !name.isEmpty && !contains(name)
    }

    /**
     * Adds a tag at the end of "My Tags" and returns it; an existing tag is returned as is; nil for an empty name.
     */
    @discardableResult
    func createTag(named name: String) -> String? {
        let name = CYLContactTagStore.normalizedName(name)
        guard !name.isEmpty else { return nil }
        if !contains(name) {
            tags.append(name)
            save()
        }
        return name
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
     * Takes sections downloaded from the server (`CYLTagListView.loadSections(withKeys:completion:)`): "My Tags" and
     * "Recent", each when present; returns whether anything changed.
     */
    @discardableResult
    func apply(_ sections: [String: [String]]) -> Bool {
        var changed = false
        if let mine = sections[Self.mineCacheKey], mine != tags {
            var seen = Set<String>()
            tags = mine.filter { seen.insert($0).inserted }
            recentTags = recentTags.filter(contains)
            changed = true
        }
        if let recent = sections[Self.recentCacheKey]?.filter(contains), recent != recentTags {
            recentTags = Array(recent.prefix(recentLimit))
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
        recentTags.removeAll()
        save()
    }

    /**
     * Removes `tag` from "My Tags" and "Recent".
     */
    func deleteTag(_ tag: String) {
        tags.removeAll { $0 == tag }
        recentTags.removeAll { $0 == tag }
        save()
    }

    /**
     * Moves `used` to the front of "Recent" (when the editor is confirmed).
     */
    func markUsed(_ used: [String]) {
        let used = used.filter(contains)
        recentTags = Array((used + recentTags.filter { !used.contains($0) }).prefix(recentLimit))
        save()
    }
}

/**
 * The contents of contact-tags.json: the demo tags, the recently used ones and the tags the remark screen starts with.
 */
struct CYLContactTagData: Codable, Equatable {
    /**
     * The file format version.
     */
    var version: Int

    /**
     * Every tag, in order.
     */
    var tags: [String]

    /**
     * The recently used tags.
     */
    var recentTags: [String]

    /**
     * The tags the remark screen starts with.
     */
    var selectedTags: [String]

    /**
     * A demo contact: a name and tags.
     */
    struct Contact: Codable, Equatable {
        /**
         * The contact's name.
         */
        var name: String

        /**
         * The contact's tags.
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

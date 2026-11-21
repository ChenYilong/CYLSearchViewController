//
//  CYLSearchResources.swift
//  CYLSearchViewController
//
//  The pod's resources (images and localized strings of CYLSearchViewController.bundle) and the cache of submitted
//  queries that the suggestion list shows (docs/core-todo.md). The cache rules come from the legacy
//  CYLSearchController's search history (newest first, no duplicates, saved after every search, NSUserDefaults); the
//  database store is new and is the default.
//

import SQLite3
import UIKit

/**
 * Images and localized strings of `CYLSearchViewController.bundle`, the resource bundle of this pod.
 */
@objc(CYLSearchResources)
public final class CYLSearchResources: NSObject {

    private static let tableName = "CYLSearchViewController"

    /**
     * The resource bundle, found next to this class's framework or in the main bundle; nil when it is missing.
     */
    @objc public static let resourceBundle: Bundle? = {
        for container in [Bundle(for: CYLSearchResources.self), Bundle.main] {
            if let url = container.url(forResource: "CYLSearchViewController", withExtension: "bundle"),
               let bundle = Bundle(url: url) {
                return bundle
            }
        }
        NSLog("CYLSearchViewController: resource bundle not found.")
        return nil
    }()

    /**
     * The built-in store of submitted queries (database, `NSUserDefaults` or file, newest first, no duplicates) that
     * `CYLSearchView` uses, for other search screens such as `CYLSearchController.historyStore`; nil for the policy none.
     */
    @objc(suggestionCacheWithPolicy:name:)
    public static func suggestionCache(policy: CYLSearchSuggestionCachePolicy, name: String) -> CYLSearchSuggestionCache? {
        CYLSearchSuggestionStore.cache(policy: policy, name: name)
    }

    /**
     * An image of the resource bundle, or nil (logged) when it is missing.
     */
    @objc(imageNamed:)
    public static func image(named name: String) -> UIImage? {
        let image = resourceBundle.flatMap { UIImage(named: name, in: $0, compatibleWith: nil) }
        if image == nil {
            NSLog("CYLSearchViewController: resource image '%@' not found.", name)
        }
        return image
    }

    /**
     * The text of `key` in the language the app shows (the preferred languages), English when the key has no
     * translation, or the key itself (logged) when it is missing everywhere.
     */
    @objc(localizedStringForKey:)
    public static func localizedString(forKey key: String) -> String {
        localizedString(forKey: key, language: nil)
    }

    /**
     * The text of `key` in `language` (for example "zh-Hans"), or in the preferred languages when `language` is nil.
     */
    @objc(localizedStringForKey:language:)
    public static func localizedString(forKey key: String, language: String?) -> String {
        guard let bundle = resourceBundle else {
            return key
        }
        let preferences = language.map { $0.isEmpty ? Locale.preferredLanguages : [$0] } ?? Locale.preferredLanguages
        let resolved = Bundle.preferredLocalizations(from: bundle.localizations, forPreferences: preferences).first ?? "en"
        for code in [resolved, "en"] {
            if let path = bundle.path(forResource: code, ofType: "lproj"),
               let value = Bundle(path: path)?.localizedString(forKey: key, value: nil, table: tableName),
               value != key {
                return value
            }
        }
        NSLog("CYLSearchViewController: localization key '%@' not found.", key)
        return key
    }
}

/**
 * Where the suggestion cache keeps the submitted queries. More policies can be added later; an app can also plug in
 * its own store through `CYLSearchSuggestionCache`.
 */
@objc public enum CYLSearchSuggestionCachePolicy: Int {
    /**
     * No cache: the suggestion list shows only `suggestions`.
     */
    case none
    /**
     * A SQLite database in the app's Application Support folder (the local cache, the default).
     */
    case database
    /**
     * `NSUserDefaults`, as the legacy `CYLSearchController` did.
     */
    case userDefaults
    /**
     * A JSON file in the app's sandbox (Application Support).
     */
    case sandboxFile
}

/**
 * A store of submitted queries, newest first. `CYLSearchView` makes the built-in store of its `suggestionCachePolicy`;
 * implement this protocol and set `CYLSearchView.suggestionCache` to use another store.
 */
@objc public protocol CYLSearchSuggestionCache: NSObjectProtocol {
    /**
     * The cached queries, newest first.
     */
    func cachedQueries() -> [String]
    /**
     * Adds `query` at the front; an equal query already cached moves to the front instead of being repeated.
     */
    func addQuery(_ query: String)
    /**
     * Removes `query`.
     */
    func removeQuery(_ query: String)
    /**
     * Removes every cached query.
     */
    func removeAllQueries()
}

/**
 * The built-in caches: a database, `NSUserDefaults` or a file, behind one class. Internal to the module: `CYLSearchView`
 * creates it from `suggestionCachePolicy` and `suggestionCacheName`; apps read it through `suggestionCache`.
 */
final class CYLSearchSuggestionStore: NSObject, CYLSearchSuggestionCache {

    /**
     * The policy of this store.
     */
    let policy: CYLSearchSuggestionCachePolicy

    /**
     * Separates the caches of different search screens: the database table key, the defaults key or the file name.
     */
    let name: String

    /**
     * The largest number of queries kept; the oldest go first. 20 by default.
     */
    @objc var maximumCount = 20

    private var memory: [String] = []
    private var database: OpaquePointer?

    /**
     * Makes the store for `policy` and `name`; nil for `CYLSearchSuggestionCachePolicyNone`.
     */
    static func cache(policy: CYLSearchSuggestionCachePolicy, name: String) -> CYLSearchSuggestionStore? {
        policy == .none ? nil : CYLSearchSuggestionStore(policy: policy, name: name)
    }

    /**
     * Makes the store for `policy` (not `none`) and `name`.
     */
    init(policy: CYLSearchSuggestionCachePolicy, name: String) {
        self.policy = policy
        self.name = name.isEmpty ? "CYLSearchView" : name
        super.init()
        if policy == .database {
            openDatabase()
        }
    }

    deinit {
        sqlite3_close(database)
    }

    // MARK: - CYLSearchSuggestionCache

    /**
     * The cached queries, newest first.
     */
    func cachedQueries() -> [String] {
        switch policy {
        case .none:
            return []
        case .database:
            return database == nil ? memory : databaseQueries()
        case .userDefaults:
            return UserDefaults.standard.stringArray(forKey: defaultsKey) ?? []
        case .sandboxFile:
            guard let data = try? Data(contentsOf: fileURL) else {
                return []
            }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
    }

    /**
     * Adds `query` at the front, without repeating it.
     */
    func addQuery(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return
        }
        if policy == .database, database != nil {
            execute("INSERT OR REPLACE INTO queries (cache, query, time) VALUES (?, ?, ?)", [name, trimmed], time: Self.nextTime())
            execute("DELETE FROM queries WHERE cache = ? AND query NOT IN (SELECT query FROM queries WHERE cache = ? ORDER BY time DESC LIMIT \(max(1, maximumCount)))", [name, name])
            return
        }
        var queries = cachedQueries().filter { $0 != trimmed }
        queries.insert(trimmed, at: 0)
        save(Array(queries.prefix(max(1, maximumCount))))
    }

    /**
     * Removes `query`.
     */
    func removeQuery(_ query: String) {
        if policy == .database, database != nil {
            execute("DELETE FROM queries WHERE cache = ? AND query = ?", [name, query])
            return
        }
        save(cachedQueries().filter { $0 != query })
    }

    /**
     * Removes every cached query.
     */
    func removeAllQueries() {
        if policy == .database, database != nil {
            execute("DELETE FROM queries WHERE cache = ?", [name])
            return
        }
        save([])
    }

    // MARK: - Storage

    private var defaultsKey: String { "CYLSearchSuggestionCache." + name }

    private static var folder: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let folder = base.appendingPathComponent("CYLSearchViewController", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }

    private var fileURL: URL {
        let safe = name.map { $0.isLetter || $0.isNumber ? $0 : "_" }
        return Self.folder.appendingPathComponent("suggestions-" + String(safe) + ".json")
    }

    private func save(_ queries: [String]) {
        switch policy {
        case .userDefaults:
            UserDefaults.standard.set(queries, forKey: defaultsKey)
        case .sandboxFile:
            if let data = try? JSONEncoder().encode(queries) {
                try? data.write(to: fileURL, options: .atomic)
            }
        case .none, .database:
            memory = queries
        }
    }

    private func openDatabase() {
        let path = Self.folder.appendingPathComponent("suggestions.sqlite").path
        guard sqlite3_open(path, &database) == SQLITE_OK else {
            sqlite3_close(database)
            database = nil
            return
        }
        execute("CREATE TABLE IF NOT EXISTS queries (cache TEXT NOT NULL, query TEXT NOT NULL, time REAL NOT NULL, PRIMARY KEY (cache, query))", [])
    }

    private static var lastTime: Double = 0
    private static let timeLock = NSLock()

    /**
     * Seconds since 1970, strictly increasing, so queries added at the same instant keep their order.
     */
    private static func nextTime() -> Double {
        timeLock.lock()
        defer { timeLock.unlock() }
        lastTime = max(Date().timeIntervalSince1970, lastTime + 0.000_001)
        return lastTime
    }

    private static let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

    private func execute(_ sql: String, _ texts: [String], time: Double? = nil) {
        guard let database else {
            return
        }
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK else {
            return
        }
        defer { sqlite3_finalize(statement) }
        for (index, text) in texts.enumerated() {
            sqlite3_bind_text(statement, Int32(index + 1), text, -1, Self.transient)
        }
        if let time {
            sqlite3_bind_double(statement, Int32(texts.count + 1), time)
        }
        sqlite3_step(statement)
    }

    private func databaseQueries() -> [String] {
        guard let database else {
            return memory
        }
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(database, "SELECT query FROM queries WHERE cache = ? ORDER BY time DESC", -1, &statement, nil) == SQLITE_OK else {
            return []
        }
        defer { sqlite3_finalize(statement) }
        sqlite3_bind_text(statement, 1, name, -1, Self.transient)
        var queries: [String] = []
        while sqlite3_step(statement) == SQLITE_ROW {
            if let text = sqlite3_column_text(statement, 0) {
                queries.append(String(cString: text))
            }
        }
        return queries
    }
}

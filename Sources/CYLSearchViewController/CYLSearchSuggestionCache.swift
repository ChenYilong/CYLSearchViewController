//
//  CYLSearchSuggestionCache.swift
//  CYLSearchViewController
//
//  The cache of submitted queries that the suggestion list shows (docs/core-todo.md). The rules come from the legacy
//  CYLSearchController's search history (newest first, no duplicates, saved after every search, NSUserDefaults);
//  the database store is new and is the default.
//

import Foundation
import SQLite3

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
 * A store of submitted queries, newest first. The built-in stores are made by `+cacheWithPolicy:name:`; implement this
 * protocol to use another store.
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
 * The built-in caches: a database, `NSUserDefaults` or a file, behind one class.
 */
@objc(CYLSearchSuggestionStore)
public final class CYLSearchSuggestionStore: NSObject, CYLSearchSuggestionCache {

    /**
     * The policy of this store.
     */
    @objc public let policy: CYLSearchSuggestionCachePolicy

    /**
     * Separates the caches of different search screens: the database table key, the defaults key or the file name.
     */
    @objc public let name: String

    /**
     * The largest number of queries kept; the oldest go first. 20 by default.
     */
    @objc public var maximumCount = 20

    private var memory: [String] = []
    private var database: OpaquePointer?

    /**
     * Makes the store for `policy` and `name`; nil for `CYLSearchSuggestionCachePolicyNone`.
     */
    @objc(cacheWithPolicy:name:)
    public static func cache(policy: CYLSearchSuggestionCachePolicy, name: String) -> CYLSearchSuggestionStore? {
        policy == .none ? nil : CYLSearchSuggestionStore(policy: policy, name: name)
    }

    /**
     * Makes the store for `policy` (not `none`) and `name`.
     */
    @objc public init(policy: CYLSearchSuggestionCachePolicy, name: String) {
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
    public func cachedQueries() -> [String] {
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
    public func addQuery(_ query: String) {
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
    public func removeQuery(_ query: String) {
        if policy == .database, database != nil {
            execute("DELETE FROM queries WHERE cache = ? AND query = ?", [name, query])
            return
        }
        save(cachedQueries().filter { $0 != query })
    }

    /**
     * Removes every cached query.
     */
    public func removeAllQueries() {
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

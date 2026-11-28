//
//  CYLSearchDiscoverData.swift
//  CYLSearchExample
//
//  Copied from CollectionViewClassifyMenu's CYLMenuExample (commit e550a01). The data of the search history and
//  discover demo, from CYLSearchDiscover.bundle/<language>.lproj/search-discover.json
//  (one file per language, the same topics in the same order): recent searches, and a pool of pages of discover topics;
//  the refresh icon shows the next page, cyclically. Each page has one hot topic (its mark is in the topic's record) at a
//  different slot than on the next page (scripts/sync-discover-data.py --check).
//

import UIKit

/**
 * One discover topic: a title (in the file's language), and an optional icon after it: "hot" for the localized hot
 * icon (discover-hot.png of the same .lproj: 热, 熱, HOT).
 */
struct CYLDiscoverTopic: Codable, Equatable {
    let title: String
    var icon: String?
}

/**
 * The demo's data as stored in the JSON file.
 */
struct CYLSearchDiscoverData: Codable {
    var version: Int
    /**
     * How many topics the discover grid shows at a time.
     */
    var discoverCount: Int
    var recentSearches: [String]
    var discover: [CYLDiscoverTopic]

    enum LoadingError: Error {
        case missingFile
    }

    /**
     * The file of the app's language, else the English one.
     */
    static var fileURL: URL? {
        CYLSearchDiscoverLocalization.stringsBundle?.url(forResource: "search-discover", withExtension: "json")
    }

    /**
     * The hot icon of the app's language, labelled for VoiceOver (read as the tag's value).
     */
    static func hotIcon() -> UIImage? {
        let image = UIImage(named: "discover-hot", in: CYLSearchDiscoverLocalization.stringsBundle, compatibleWith: nil)
        image?.accessibilityLabel = cylDiscoverText("discover.hot")
        return image
    }

    /**
     * Reads and decodes the bundled file.
     */
    static func bundled() throws -> CYLSearchDiscoverData {
        guard let url = fileURL else { throw LoadingError.missingFile }
        return try JSONDecoder().decode(CYLSearchDiscoverData.self, from: Data(contentsOf: url))
    }

    /**
     * The number of whole pages of `discoverCount` topics in the pool.
     */
    var pageCount: Int {
        discoverCount > 0 ? discover.count / discoverCount : 0
    }

    /**
     * The topics of `page` (the page wraps around the pool): `discoverCount` records, each with its own hot mark.
     */
    func topics(onPage page: Int) -> [CYLDiscoverTopic] {
        guard pageCount > 0 else { return [] }
        let start = ((page % pageCount) + pageCount) % pageCount * discoverCount
        return Array(discover[start ..< start + discoverCount])
    }

    /**
     * The page after `page`, cyclically: refresh shows the next page, so the hot topic (one per page, at another slot
     * than on the next page) moves on every refresh.
     */
    func nextPage(after page: Int) -> Int {
        pageCount > 0 ? (page + 1) % pageCount : 0
    }

    /**
     * The first selection: page 0, so the first screen is always the same.
     */
    var initialTopics: [CYLDiscoverTopic] {
        topics(onPage: 0)
    }
}

/**
 * The example-level bundle of the discover demo (`CYLSearchDiscover.bundle`, one `.lproj` per language).
 */
enum CYLSearchDiscoverLocalization {
    /**
     * The bundle itself.
     */
    static let resourceBundle: Bundle? = Bundle.main.url(forResource: "CYLSearchDiscover", withExtension: "bundle").flatMap(Bundle.init(url:))

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
 * A text of the discover demo (the example-level lookup of `CYLSearchDiscover.bundle`), formatted with `arguments`.
 */
func cylDiscoverText(_ key: String, _ arguments: CVarArg...) -> String {
    let format = CYLSearchDiscoverLocalization.stringsBundle?.localizedString(forKey: key, value: key, table: "CYLSearchDiscover") ?? key
    return arguments.isEmpty ? format : String(format: format, arguments: arguments)
}

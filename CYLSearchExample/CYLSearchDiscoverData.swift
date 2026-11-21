//
//  CYLSearchDiscoverData.swift
//  CYLSearchExample
//
//  Copied from CollectionViewClassifyMenu's CYLMenuExample (commit e550a01). The data of the search history and
//  discover demo, from CYLSearchDiscover.bundle/<language>.lproj/search-discover.json
//  (one file per language, the same topics in the same order): recent searches, and a pool of discover topics from
//  which the More button picks another random selection.
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
     * The first selection: the first `discoverCount` topics, so the first screen is always the same.
     */
    var initialTopics: [CYLDiscoverTopic] {
        Array(discover.prefix(max(0, discoverCount)))
    }

    /**
     * Another random selection of `discoverCount` topics; it differs from `current` whenever the pool allows.
     */
    func randomTopics<G: RandomNumberGenerator>(excluding current: [CYLDiscoverTopic], using generator: inout G) -> [CYLDiscoverTopic] {
        let count = min(max(0, discoverCount), discover.count)
        let others = discover.filter { !current.contains($0) }
        // Prefer topics that are not shown now; fill up with the others when the pool is small.
        var picked = Array(others.shuffled(using: &generator).prefix(count))
        if picked.count < count {
            let rest = discover.filter { !picked.contains($0) }.shuffled(using: &generator)
            picked += rest.prefix(count - picked.count)
        }
        return picked
    }
}

/**
 * Any random number generator behind one type, so a screen can keep one and tests can swap in a seeded one.
 */
struct CYLAnyRandomNumberGenerator: RandomNumberGenerator {
    private let nextValue: () -> UInt64

    init<G: RandomNumberGenerator>(_ generator: G) {
        var generator = generator
        nextValue = { generator.next() }
    }

    mutating func next() -> UInt64 {
        nextValue()
    }
}

/**
 * A seeded generator (SplitMix64) for repeatable selections in tests.
 */
struct CYLSeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
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

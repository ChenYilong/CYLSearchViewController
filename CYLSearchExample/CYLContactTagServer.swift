//
//  CYLContactTagServer.swift
//  CYLSearchExample
//
//  The contact tags demo's simulated server (CollectionViewClassifyMenu's CYLTagListRemoteSource). The local cache, A,
//  is CYLTagListStore's database (CYLContactTagStore.cache); the server's data, B, is a second CYLTagListStore, a
//  JSON file in the sandbox, that stands for the server shared by the user's devices. Every request waits `latency`
//  (5 s) and shows CYLTableViewPlaceHolder's HUD (CYLPlaceholderHUD), as a slow network would:
//  - uploading copies A's sections to B ("Uploading…", then "Upload finished");
//  - downloading reads B as network data ("Downloading…");
//  - "Sync" simulates an edit on another device (a random new tag, the first two tags swapped, written to B), then
//    downloads it ("Syncing from other devices…").
//

import UIKit
import CollectionViewClassifyMenu
import CYLTableViewPlaceHolder

/**
 * The simulated server of the contact tags demo: cache B in the sandbox, reached with a delay and a HUD.
 */
final class CYLContactTagServer: NSObject, CYLTagListRemoteSource {

    /**
     * The server's data, cache B: a JSON file in the sandbox.
     */
    let storage = CYLTagListStore(policy: .sandboxFile, name: "CYLContactTagsServer")

    /**
     * How long every request takes: `CYLContactTagsServerLatency` in the user defaults (a launch argument, or the
     * tests' 0), else 5 seconds.
     */
    var latency: TimeInterval {
        UserDefaults.standard.object(forKey: "CYLContactTagsServerLatency") as? TimeInterval ?? 5
    }

    /**
     * The HUD status of the next download ("Downloading…" by default; "Syncing from other devices…" for a sync).
     */
    private var nextFetchStatus: String?

    // MARK: - CYLTagListRemoteSource

    /**
     * Downloads B's items (id and title) after `latency`, with a HUD.
     */
    func fetchItems(withKeys keys: [String], completion: @escaping ([String: [CYLTagListCacheItem]]?, Error?) -> Void) {
        let status = nextFetchStatus ?? cylContactTagsText("downloading")
        let finished = nextFetchStatus == nil ? cylContactTagsText("downloaded") : cylContactTagsText("synced")
        nextFetchStatus = nil
        CYLPlaceholderHUD.show(status: status)
        DispatchQueue.main.asyncAfter(deadline: .now() + latency) { [storage] in
            var sections: [String: [CYLTagListCacheItem]] = [:]
            for key in keys {
                if let items = storage.cachedItems(forSection: key) {
                    sections[key] = items
                }
            }
            CYLPlaceholderHUD.showSuccess(status: finished)
            completion(sections, nil)
        }
    }

    /**
     * Downloads B's titles after `latency`, with a HUD (the protocol's titles-only form).
     */
    func fetchSections(withKeys keys: [String], completion: @escaping ([String: [String]]?, Error?) -> Void) {
        let status = nextFetchStatus ?? cylContactTagsText("downloading")
        let finished = nextFetchStatus == nil ? cylContactTagsText("downloaded") : cylContactTagsText("synced")
        nextFetchStatus = nil
        CYLPlaceholderHUD.show(status: status)
        DispatchQueue.main.asyncAfter(deadline: .now() + latency) { [storage] in
            var sections: [String: [String]] = [:]
            for key in keys {
                if let titles = storage.cachedTitles(forSection: key) {
                    sections[key] = titles
                }
            }
            CYLPlaceholderHUD.showSuccess(status: finished)
            completion(sections, nil)
        }
    }

    // MARK: - Uploading and syncing

    /**
     * Uploads `sections` (cache A's, after editing): copies them to B after `latency`, with a HUD.
     */
    func upload(_ sections: [String: [CYLTagListCacheItem]], completion: (() -> Void)? = nil) {
        CYLPlaceholderHUD.show(status: cylContactTagsText("uploading"))
        DispatchQueue.main.asyncAfter(deadline: .now() + latency) { [storage] in
            for (key, items) in sections {
                storage.saveItems(items, forSection: key)
            }
            CYLPlaceholderHUD.showSuccess(status: cylContactTagsText("uploaded"))
            completion?()
        }
    }

    /**
     * Simulates an edit on another device, written to B: a random new tag (a new id) at the end of "My Tags" and its
     * first two tags swapped. `localItems` stands in when B has nothing yet. Returns the title added.
     */
    @discardableResult
    func simulateOtherDeviceEdit(localItems: [CYLTagListCacheItem]) -> String {
        var tags = storage.cachedItems(forSection: CYLContactTagStore.mineCacheKey) ?? localItems
        let titles = Set(tags.map(\.title))
        let pool = cylContactTagsText("otherDeviceTags").components(separatedBy: ",").filter { !titles.contains($0) }
        let added = pool.randomElement() ?? cylContactTagsText("otherDeviceTags") + " \(tags.count)"
        tags.append(CYLTagListCacheItem(identifier: "o-" + UUID().uuidString.prefix(8).lowercased(), title: added))
        if tags.count > 1 {
            tags.swapAt(0, 1)
        }
        storage.saveItems(tags, forSection: CYLContactTagStore.mineCacheKey)
        nextFetchStatus = cylContactTagsText("syncing")
        return added
    }

    /**
     * Forgets B (the demo's reset).
     */
    func reset() {
        storage.removeAllTitles()
    }
}

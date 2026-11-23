//
//  CYLSearchExampleAppDelegate.swift
//  CYLSearchExample
//
//  The example's app delegate and the tab bar it builds (translated from Objective-C, docs/swift-migration.md).
//

import CYLAnimatedItem
import CYLSearchViewController
import CYLTabBarController
import UIKit

/**
 * A tab title from CYLSearchTabs.bundle, as the configuration file's `CYLTabBarControllerLocalization` reads it.
 */
func cylSearchTabTitle(_ key: String) -> String {
    guard let path = Bundle.main.path(forResource: "CYLSearchTabs", ofType: "bundle"), let bundle = Bundle(path: path) else {
        return key
    }
    return bundle.localizedString(forKey: key, value: key, table: "CYLSearchTabs")
}

/**
 * Starts the app; `CYLSearchExampleSceneDelegate` creates the window (Info.plist, UIApplicationSceneManifest), since apps
 * built with the iOS 27 SDK must adopt the scene life cycle.
 */
@main
@objc(CYLSearchExampleAppDelegate)
public final class CYLSearchExampleAppDelegate: UIResponder, UIApplicationDelegate {

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        true
    }

    /**
     * The tab bar built from CYLTabBarConfiguration.json (search, examples and the plus page), or the examples menu when
     * the file cannot be read.
     */
    @objc public static func rootViewController() -> UIViewController {
        registerPages(CYLTabBarPageRegistry.shared)
        do {
            let tabBarController = try tabBarControllerForIconSource()
            // `-CYLDemoTab 1` on launch selects that tab, for screenshots.
            if let tab = UserDefaults.standard.string(forKey: "CYLDemoTab"), let index = Int(tab),
               index >= 0, index < (tabBarController.viewControllers?.count ?? 0) {
                tabBarController.selectedIndex = index
            }
            return tabBarController
        } catch {
            NSLog("CYLTabBarConfiguration.json: %@", String(describing: error))
            return navigationController(root: CYLSearchDemoMenuViewController(style: .grouped))
        }
    }

    /**
     * Where the tab icons come from (`-CYLDemoTabIconSource <n>` launch argument or user default), as CYLTabBarController's
     * Example-Rive: 0 SF Symbols (`CYLTabBarConfiguration.json`); 1 SVGA through the initialization keys
     * (`CYLTabBarSVGAURL`, `CYLTabBarSVGASize`); 2 SVGA through a configuration file (`CYLTabBarConfiguration_svga.json`).
     */
    private static func tabBarControllerForIconSource() throws -> CYLTabBarController {
        let source = UserDefaults.standard.integer(forKey: "CYLDemoTabIconSource")
        if source == 2 {
            return try CYLTabBarController(configurationFile: "CYLTabBarConfiguration_svga.json")
        }
        if source != 1 {
            return try CYLTabBarController(configurationFile: "CYLTabBarConfiguration.json")
        }
        // The initialization keys: the same tabs as CYLTabBarConfiguration.json, written in code, each with its SVGA file.
        // Search and Discover have a second file for dark mode (`CYLTabBarSVGADarkURL`), as the Rive demo's dark file.
        let darkFiles = ["search": "tab_activity", "discover": "tab_profile"]
        let definitions = [("search", "tab.search", "tab_search"), ("examples", "tab.examples", "tab_list"),
                           ("tagStyle", "tab.tagStyle", "tab_chat"), ("discover", "tab.discover", "tab_home")]
        let tabs: [[String: Any]] = definitions.map { identifier, title, file in
            var attributes: [String: Any] = [
                cylTabBarItemTitle: cylSearchTabTitle(title),
                cylTabBarItemIdentifier: identifier,
                cylTabBarItemPageIdentifier: identifier,
                CYLTabBarSVGAURL: Bundle.main.url(forResource: file, withExtension: "svga") as Any,
                CYLTabBarSVGASize: NSValue(cgSize: CGSize(width: 28, height: 28)),
            ]
            if let dark = darkFiles[identifier], let darkURL = Bundle.main.url(forResource: dark, withExtension: "svga") {
                attributes[CYLTabBarSVGADarkURL] = darkURL
            }
            return attributes
        }
        // `-CYLDemoTabBarStyle flatDesign` (or "liquidGlass", "default"): the same icons in another tab bar style.
        let style = UserDefaults.standard.string(forKey: "CYLDemoTabBarStyle") ?? "default"
        return try CYLTabBarController(configuration: [
            cylTabBarControllerContext: "CYLSearchExample",
            cylTabBarControllerStyleType: style,
            cylTabBarControllerTabBarItemsAttributes: tabs,
            cylTabBarControllerTitlePositionAdjustment: NSValue(uiOffset: UIOffset(horizontal: 0, vertical: -2)),
            cylTabBarControllerPlusButton: [
                cylTabBarItemTitle: cylSearchTabTitle("tab.searchBar"),
                cylTabBarItemImage: UIImage(named: "CYLPlusButton") as Any,
                cylTabBarItemIdentifier: "plus",
                cylTabBarItemPageIdentifier: "plus",
                // Raised above the bar, as in CYLTabBarConfiguration.json (AGENTS.md, "Raised plus button").
                cylPlusButtonAlignsTitle: false,
                cylPlusButtonSize: NSValue(cgSize: CGSize(width: 64, height: 84)),
                cylPlusButtonCenterYMultiplier: 0.3,
            ],
        ])
    }

    /**
     * Search pages live in navigation controllers, so `navigationItem.searchController` and the Issue #1317 workaround
     * (`hidesSearchBarWhenScrolling = NO`) keep working.
     */
    private static func registerPages(_ pages: CYLTabBarPageRegistry) {
        pages.register({ _, _ in
            let source = CYLSearchExampleDataSource()
            return navigationController(root: CYLSearchExampleViewController(searchDataSource: source, refreshProvider: source))
        }, forPageIdentifier: "search")
        pages.register({ _, _ in
            navigationController(root: CYLSearchDemoMenuViewController(style: .grouped))
        }, forPageIdentifier: "examples")
        pages.register({ _, _ in
            navigationController(root: CYLSearchBarDemoViewController())
        }, forPageIdentifier: "plus")
        // The suggestion style demos (docs/tag-view-suggestions.md): suggestions as tags, and the discover page copied from
        // CollectionViewClassifyMenu. The discover page draws its own search bar in place of the navigation bar.
        pages.register({ _, _ in
            navigationController(root: CYLSuggestionDemoPages.tagStyleViewController())
        }, forPageIdentifier: "tagStyle")
        pages.register({ _, _ in
            navigationController(root: CYLSuggestionDemoPages.discoverViewController())
        }, forPageIdentifier: "discover")
    }

    private static func navigationController(root: UIViewController) -> UINavigationController {
        UINavigationController(rootViewController: root)
    }
}

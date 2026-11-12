import CYLSearchViewController
import UIKit

/**
 * The pages of the suggestion style demos (docs/tag-view-suggestions.md), for the Objective-C app delegate, which
 * registers them for the "tagStyle" and "discover" tabs of CYLTabBarConfiguration.json.
 */
@objc(CYLSuggestionDemoPages)
public final class CYLSuggestionDemoPages: NSObject {

    /**
     * The "Tag style" tab: MaterialSearchView's six samples, the same suggestions and parameters as the list-style
     * ports, shown as tags (`CYLSearchView.suggestionStyle = .tags`).
     */
    @objc public static func tagStyleViewController() -> UIViewController {
        let menu = CYLMaterialSearchMenuViewController(style: .insetGrouped)
        menu.suggestionStyle = .tags
        return menu
    }

    /**
     * The "Discover" tab: the search history and discover page copied from CollectionViewClassifyMenu (recent searches
     * and discover topics as CYLTagListView tags).
     */
    @objc public static func discoverViewController() -> UIViewController {
        CYLSearchDiscoverViewController()
    }
}

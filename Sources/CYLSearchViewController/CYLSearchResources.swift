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

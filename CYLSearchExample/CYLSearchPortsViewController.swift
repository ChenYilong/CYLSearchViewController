import UIKit
import CYLSearchViewController

/**
 * A localized text of the example (the `demo.*` keys of CYLSearchViewController.bundle).
 */
func cylDemoText(_ key: String) -> String {
    CYLSearchResources.localizedString(forKey: key)
}

/**
 * A short message at the bottom of a view, like Android's `Snackbar.make(...).show()`.
 */
enum CYLSnackbar {
    /**
     * Shows `text` above the bottom safe area of `view` for a few seconds and announces it to VoiceOver.
     */
    static func show(_ text: String, in view: UIView) {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        let bar = UIView()
        bar.backgroundColor = UIColor(white: 0.2, alpha: 0.95)
        bar.layer.cornerRadius = 8
        bar.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(label)
        view.addSubview(bar)
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: bar.topAnchor, constant: 14),
            label.bottomAnchor.constraint(equalTo: bar.bottomAnchor, constant: -14),
            label.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -16),
            bar.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 8),
            bar.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -8),
            bar.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -8),
        ])
        UIAccessibility.post(notification: .announcement, argument: text)
        UIView.animate(withDuration: 0.25, delay: 2.75, options: []) {
            bar.alpha = 0
        } completion: { _ in
            bar.removeFromSuperview()
        }
    }
}

/**
 * The Swift ports of the examples of five search libraries (docs/search-api-comparison.md), as a demo tag list
 * (docs/instructions/example-demos.md): one tag per port with its name and icon, a tap opens it, a long press shows its
 * subtitle. Each port only passes data and style parameters to the core and handles taps.
 */
@objc(CYLSearchPortsViewController)
final class CYLSearchPortsViewController: CYLDemoTagListViewController {

    private static func tag(_ title: String, _ subtitle: String, _ symbol: String,
                            make: @escaping () -> UIViewController) -> CYLDemoTagItem {
        CYLDemoTagItem(title: title, image: UIImage(systemName: symbol), subtitle: subtitle) { host in
            host.navigationController?.pushViewController(make(), animated: true)
        }
    }

    init() {
        let items = [
            Self.tag("lapism/search", "MaterialSearchBar + MaterialSearchView", "magnifyingglass") { CYLLapismSearchViewController() },
            Self.tag("MiguelCatalan/MaterialSearchView", "Default, Themed, Voice, Sticky, Tabs, Input type", "mic") {
                CYLMaterialSearchMenuViewController(style: .insetGrouped)
            },
            Self.tag("yechaoa/MaterialDesign", "SearchViewActivity", "text.magnifyingglass") { CYLYechaoaSearchViewController() },
            Self.tag("android-cjj/MaterialSearchView", "Circular reveal", "circle.dashed") { CYLRevealSearchViewController() },
            Self.tag("iammert/MultiSearchView", "MultiSearchView", "square.stack") { CYLMultiSearchDemoViewController() },
        ]
        super.init(title: cylDemoText("demo.ports"),
                   sections: [CYLDemoTagSection(title: cylDemoText("demo.ports"), items: items)])
    }

    required init?(coder: NSCoder) {
        nil
    }
}

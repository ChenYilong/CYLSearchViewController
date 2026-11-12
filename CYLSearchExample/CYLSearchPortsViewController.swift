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
 * The Swift ports of the examples of five search libraries (docs/search-api-comparison.md). Each port only passes
 * data and style parameters to the core and handles taps.
 */
@objc(CYLSearchPortsViewController)
final class CYLSearchPortsViewController: UITableViewController {

    private struct Row {
        let title: String
        let subtitle: String
        let make: () -> UIViewController
    }

    private let rows: [Row] = [
        Row(title: "lapism/search", subtitle: "MaterialSearchBar + MaterialSearchView") { CYLLapismSearchViewController() },
        Row(title: "MiguelCatalan/MaterialSearchView", subtitle: "Default, Themed, Voice, Sticky, Tabs, Input type") {
            CYLMaterialSearchMenuViewController(style: .insetGrouped)
        },
        Row(title: "yechaoa/MaterialDesign", subtitle: "SearchViewActivity") { CYLYechaoaSearchViewController() },
        Row(title: "android-cjj/MaterialSearchView", subtitle: "Circular reveal") { CYLRevealSearchViewController() },
        Row(title: "iammert/MultiSearchView", subtitle: "MultiSearchView") { CYLMultiSearchDemoViewController() },
    ]

    override init(style: UITableView.Style) {
        super.init(style: style)
    }

    convenience init() {
        self.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = cylDemoText("demo.ports")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        var content = cell.defaultContentConfiguration()
        content.text = rows[indexPath.row].title
        content.secondaryText = rows[indexPath.row].subtitle
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(rows[indexPath.row].make(), animated: true)
    }
}

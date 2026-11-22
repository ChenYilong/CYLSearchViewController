//
//  CYLSearchControllerDemoViewController.swift
//  CYLSearchExample
//
//  The "Search controller" screen: a replica of QMUI's QDSearchViewController (QMUIDemo_iOS). A table of ten keywords
// with
//  a CYLSearchBar as its header; the search shows the core's launch view (recent searches as tags) while the text is
//  empty, the matching keywords (twenty rows each) with the match in the tint color, an empty view when nothing
// matches, and swipe to dismiss. The launch view is configured through the core's API only.
//

import CYLSearchViewController
import UIKit

/**
 * Ten keywords in a table whose header is a search bar. `CYLSearchController` shows the recent searches while the text
 * is empty, then the matching keywords, and leaves the search when the person swipes from the left edge.
 */
@objc(CYLSearchControllerDemoViewController)
public final class CYLSearchControllerDemoViewController: UITableViewController, CYLSearchControllerDelegate {

    static let keywords = ["Helps", "Maintain", "Liver", "Health", "Function", "Supports", "Healthy", "Fat", "Metabolism",
                           "Nuturally"]

    /// QMUI's eight suggestions: the tags of the launch view while there is no history.
    static let suggestions = ["Helps", "Maintain", "Liver", "Health", "Function", "Supports", "Healthy", "Fat"]

    /// The name of the history (`CYLSearchResources.suggestionCache`); tests use their own so runs do not share one.
    static var historyName = "CYLSearchControllerDemo"

    private var matches: [String] = []
    /// The search controller; this screen keeps it, as QMUI's demo does (the wrapper is not retained by UIKit).
    private(set) var cylSearchController: CYLSearchController?

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = cylDemoText("demo.searchController")
        let search = CYLSearchController(contentsViewController: self)
        search.searchResultsDelegate = self
        search.supportsSwipeToDismissSearch = true
        // The core's launch view: the history of submitted queries (a return key or a tapped tag submits), else QMUI's eight
        // suggestions, as tags; the title and the trash button come with it.
        search.historyStore = CYLSearchResources.suggestionCache(policy: .userDefaults, name: Self.historyName)
        search.suggestions = Self.suggestions
        search.showsSuggestionsLaunchView = true
        search.installSearchBar(asHeaderOf: tableView)
        cylSearchController = search
    }

    // MARK: - Table

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView === self.tableView ? Self.keywords.count : matches.count * 20
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CYLSearchControllerCell")
            ?? UITableViewCell(style: .default, reuseIdentifier: "CYLSearchControllerCell")
        if tableView === self.tableView {
            cell.textLabel?.text = Self.keywords[indexPath.row]
        } else {
            let keyword = matches[indexPath.row / 20]
            let text = NSMutableAttributedString(string: keyword, attributes: [.foregroundColor: UIColor.label])
            let search = cylSearchController?.searchBar.text ?? ""
            if !search.isEmpty, let range = keyword.range(of: search) {
                let tint = view.tintColor ?? UIColor.systemBlue
                text.addAttribute(.foregroundColor, value: tint, range: NSRange(range, in: keyword))
            }
            cell.textLabel?.attributedText = text
        }
        cell.textLabel?.adjustsFontForContentSizeCategory = true
        return cell
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView !== self.tableView else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        // A result opens a detail screen (the search stays behind it): the push, the interactive pop that can be cancelled,
        // and the push again are the scenario of QMUI issue #680 (docs/qmui-search-controller.md, row E21).
        let detail = UIViewController()
        detail.view.backgroundColor = .systemBackground
        detail.navigationItem.title = matches[indexPath.row / 20]
        let label = UILabel()
        label.text = matches[indexPath.row / 20]
        label.font = .preferredFont(forTextStyle: .title1)
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        detail.view.addSubview(label)
        NSLayoutConstraint.activate([label.centerXAnchor.constraint(equalTo: detail.view.centerXAnchor),
                                     label.centerYAnchor.constraint(equalTo: detail.view.centerYAnchor)])
        navigationController?.pushViewController(detail, animated: true)
    }

    // MARK: - CYLSearchControllerDelegate

    public func searchController(_ searchController: CYLSearchController, updateResultsFor searchString: String) {
        matches = searchString.isEmpty ? [] : Self.keywords.filter { $0.range(of: searchString) != nil }
        searchController.tableView?.reloadData()
        if matches.isEmpty {
            searchController.showEmptyView(text: cylDemoText("controller.noResults"), detailText: nil, buttonTitle: nil,
                                           buttonAction: nil)
        } else {
            searchController.hideEmptyView()
        }
    }
}

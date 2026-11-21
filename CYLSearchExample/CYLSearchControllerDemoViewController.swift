//
//  CYLSearchControllerDemoViewController.swift
//  CYLSearchExample
//
//  The "Search controller" screen: a replica of QMUI's QDSearchViewController (QMUIDemo_iOS). A table of ten keywords
// with
//  a CYLSearchBar as its header; the search shows a launch view of recent searches while the text is empty, the
// matching
//  keywords (twenty rows each) with the match in the tint color, an empty view when nothing matches, and swipe to
// dismiss.
//

import CollectionViewClassifyMenu
import CYLSearchViewController
import UIKit

/**
 * The recent searches (QMUI's `QDRecentSearchView`): a title with a bottom border and the suggestions as tags
 * (`CYLTagListView` of CollectionViewClassifyMenu in place of QMUI's float layout of ghost buttons). It fills the space
 * under the search bar: 26 pt of padding plus the safe area, 20 pt between the title and the tags.
 */
final class CYLRecentSearchLaunchView: UIView, CYLMenuDataSource {

    static let suggestions = ["Helps", "Maintain", "Liver", "Health", "Function", "Supports", "Healthy", "Fat"]

    let titleLabel = UILabel()
    let tagListView = CYLTagListView()
    /// The trash button at the trailing edge of the title row: clears the history (hidden while there is none).
    let clearButton = UIButton(type: .system)
    private let borderView = UIView()

    /// The submitted searches (`CYLSearchController.historyStore`, built by `CYLSearchResources`): newest first, no
    /// duplicates. While it is empty the launch view shows the eight suggestions, as QMUI's demo does.
    var historyStore: CYLSearchSuggestionCache? {
        didSet { reload() }
    }

    /// The tags on show: the history, or the suggestions without one.
    private(set) var queries = CYLRecentSearchLaunchView.suggestions

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        accessibilityIdentifier = "CYLRecentSearchLaunchView"

        titleLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: .systemFont(ofSize: 14))
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        titleLabel.text = cylDemoText("controller.recent")
        titleLabel.accessibilityTraits = .header
        addSubview(titleLabel)
        borderView.backgroundColor = .separator
        addSubview(borderView)
        clearButton.setImage(UIImage(systemName: "trash"), for: .normal)
        clearButton.accessibilityLabel = CYLSearchResources.localizedString(forKey: "search.clearRecent")
        clearButton.accessibilityIdentifier = "CYLRecentSearchClearButton"
        clearButton.isHidden = true
        clearButton.addTarget(self, action: #selector(clearHistory), for: .touchUpInside)
        addSubview(clearButton)

        let style = CYLMenuStyle()
        for state in [UIControl.State.normal, .selected, .disabled] {
            let appearance = style.appearance(for: state)
            appearance.font = .systemFont(ofSize: 14)
            appearance.textColor = tintColor
            appearance.backgroundColor = .clear
            appearance.borderColor = tintColor
            appearance.borderWidth = 1
            appearance.cornerRadius = 4
            appearance.margin = 20
        }
        style.itemHeight = 29
        style.interitemSpacing = 10
        style.lineSpacing = 10
        style.sectionInsets = .zero
        style.backgroundColor = .clear
        tagListView.style = style
        tagListView.showsSectionHeaders = false
        tagListView.selectionMode = .none
        tagListView.isScrollEnabled = false
        tagListView.menuDataSource = self
        tagListView.accessibilityLabel = cylDemoText("controller.launch.label")
        addSubview(tagListView)
        tagListView.reloadMenuData()
    }

    required init?(coder: NSCoder) {
        nil
    }

    /// Reads the history again: the tags are the history (newest first) or, without one, the suggestions.
    func reload() {
        let history = historyStore?.cachedQueries() ?? []
        queries = history.isEmpty ? Self.suggestions : history
        clearButton.isHidden = history.isEmpty
        tagListView.reloadMenuData()
        setNeedsLayout()
    }

    @objc private func clearHistory() {
        historyStore?.removeAllQueries()
        reload()
    }

    // The launch view is shown on every activation: the history may have changed since.
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil { reload() }
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        for state in [UIControl.State.normal, .selected, .disabled] {
            tagListView.style.appearance(for: state).textColor = tintColor
            tagListView.style.appearance(for: state).borderColor = tintColor
        }
        tagListView.reloadMenuData()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let safe = safeAreaInsets
        let padding = UIEdgeInsets(top: 26 + safe.top, left: 26 + safe.left, bottom: 26 + safe.bottom,
                                   right: 26 + safe.right)
        let width = max(0, bounds.width - padding.left - padding.right)
        let buttonWidth: CGFloat = clearButton.isHidden ? 0 : 36
        let fitting = titleLabel.sizeThatFits(CGSize(width: width - buttonWidth, height: .greatestFiniteMagnitude))
        let titleHeight = ceil(fitting.height) + 8
        titleLabel.frame = CGRect(x: padding.left, y: padding.top, width: width - buttonWidth, height: titleHeight - 8)
        clearButton.frame = CGRect(x: padding.left + width - 36, y: padding.top + (titleHeight - 8 - 36) / 2, width: 36, height: 36)
        let line = 1 / max(UIScreen.main.scale, 1)
        borderView.frame = CGRect(x: padding.left, y: padding.top + titleHeight - 1, width: width, height: line)
        let minY = padding.top + titleHeight + 20
        tagListView.frame = CGRect(x: padding.left, y: minY, width: width, height: max(0, bounds.height - minY))
    }

    // MARK: CYLMenuDataSource

    func numberOfSectionsInMenu() -> Int {
        1
    }

    func menuNumberOfItems(inSection section: Int) -> Int {
        queries.count
    }

    func menuTitle(forSection section: Int) -> String {
        cylDemoText("controller.recent")
    }

    func menuTitleForItem(at indexPath: IndexPath) -> String {
        queries[indexPath.item]
    }
}

/**
 * Ten keywords in a table whose header is a search bar. `CYLSearchController` shows the recent searches while the text
 * is empty, then the matching keywords, and leaves the search when the person swipes from the left edge.
 */
@objc(CYLSearchControllerDemoViewController)
public final class CYLSearchControllerDemoViewController: UITableViewController, CYLSearchControllerDelegate {

    static let keywords = ["Helps", "Maintain", "Liver", "Health", "Function", "Supports", "Healthy", "Fat", "Metabolism",
                           "Nuturally"]

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
        // The launch view is laid out by the controller: it fills the space under the bar.
        let launch = CYLRecentSearchLaunchView()
        // The history: a return key submits the query, the launch view lists the newest first and clears it.
        let store = CYLSearchResources.suggestionCache(policy: .userDefaults, name: Self.historyName)
        search.historyStore = store
        launch.historyStore = store
        search.launchView = launch
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

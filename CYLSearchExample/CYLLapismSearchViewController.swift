import UIKit
import CYLSearchViewController

/**
 * Port of lapism/search's README usage: a `MaterialSearchBar` (magnifier navigation icon, hint, taps open the
 * search) over a list, and a `MaterialSearchView` (arrow navigation icon, a filtered list added with `addView`,
 * query and focus listeners).
 */
@objc(CYLLapismSearchViewController)
final class CYLLapismSearchViewController: UIViewController {

    /**
     * The list shown under the bar and filtered inside the search view (the README's adapter).
     */
    private let items = (1...40).map { String.localizedStringWithFormat(cylDemoText("demo.port.item"), $0) }
    private var filteredItems: [String] = []

    private let searchBar = CYLSearchBarView(frame: .zero)
    private let searchView = CYLSearchView(frame: .zero)
    private let listView = UITableView(frame: .zero, style: .plain)
    private let resultsView = UITableView(frame: .zero, style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "lapism/search"
        view.backgroundColor = .systemBackground
        edgesForExtendedLayout = []
        filteredItems = items

        // MaterialSearchBar: navigationIconCompat = SEARCH, setHint, setOnClickListener / setNavigationOnClickListener.
        searchBar.navigationIcon = .search
        searchBar.searchIcon = nil
        searchBar.placeholder = cylDemoText("search.field")
        searchBar.fieldCornerRadius = -1
        searchBar.fieldShadowOpacity = 0.15
        searchBar.fieldBackgroundColor = .secondarySystemBackground
        searchBar.delegate = self
        searchBar.navigationHandler = { [weak self] _ in self?.searchView.showSearch() }
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)

        listView.dataSource = self
        listView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(listView)
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: guide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            listView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            listView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            listView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            listView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        // MaterialSearchView: addView(recyclerView), navigationIconCompat = ARROW, setHint, listeners.
        resultsView.dataSource = self
        searchView.contentView = resultsView
        searchView.searchBarView.navigationIcon = .arrow
        searchView.searchBarView.searchIcon = nil
        searchView.searchBarView.placeholder = cylDemoText("search.field")
        searchView.delegate = self
        searchView.install(in: view)
    }
}

extension CYLLapismSearchViewController: CYLSearchBarViewDelegate {
    func searchBarViewShouldBeginEditing(_ searchBarView: CYLSearchBarView) -> Bool {
        false
    }

    func searchBarViewDidTapWhileNotEditable(_ searchBarView: CYLSearchBarView) {
        searchView.showSearch()
    }
}

extension CYLLapismSearchViewController: CYLSearchViewDelegate {
    func searchView(_ searchView: CYLSearchView, textDidChange text: String) {
        // adapter.filter(newText)
        filteredItems = text.isEmpty ? items : items.filter { $0.localizedCaseInsensitiveContains(text) }
        resultsView.reloadData()
    }

    func searchView(_ searchView: CYLSearchView, didSubmitText text: String) -> Bool {
        true
    }

    func searchView(_ searchView: CYLSearchView, didChangeFocus focused: Bool) {
        searchBar.text = searchView.query
    }
}

extension CYLLapismSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView === resultsView ? filteredItems.count : items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        var content = cell.defaultContentConfiguration()
        content.text = tableView === resultsView ? filteredItems[indexPath.row] : items[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
}

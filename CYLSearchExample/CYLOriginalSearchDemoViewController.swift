//
//  CYLOriginalSearchDemoViewController.swift
//  CYLSearchExample
//
//  The original CYLSearchViewController demo (the README's screenshot) rebuilt on the Swift core's `CYLSearchView`,
//  replacing the Objective-C `CYLSearchController`, `CYLSearchResultViewController` and `CYLKenBurnsView`.
//

import CYLSearchViewController
import UIKit

/**
 * A text of the original demo's strings (CYLOriginalDemo.bundle).
 */
private func cylOriginalDemoText(_ key: String, _ arguments: CVarArg...) -> String {
    guard let path = Bundle.main.path(forResource: "CYLOriginalDemo", ofType: "bundle"), let bundle = Bundle(path: path) else {
        return key
    }
    let format = bundle.localizedString(forKey: key, value: key, table: "CYLOriginalDemo")
    return arguments.isEmpty ? format : String(format: format, arguments: arguments)
}

/**
 * The sky of the demo.
 */
private func cylOriginalDemoSky() -> CYLKenBurnsView {
    var image: UIImage?
    if let path = Bundle.main.path(forResource: "CYLOriginalDemo", ofType: "bundle"), let bundle = Bundle(path: path) {
        image = UIImage(contentsOfFile: bundle.bundlePath + "/clouds-1.png")
    }
    return CYLKenBurnsView(image: image)
}

/**
 * The original demo: a blue bar titled with the author's name, a search field over a Ken Burns sky; a tap on the field
 * opens `CYLSearchView` with the search history (newest first) and a "clear history" button below it, the sky still
 * showing under the list, and Cancel; Search lists the results under a "consultations about <term>" header and adds the
 * term to the history; a result opens a page with one centered button.
 */
@objc(CYLOriginalSearchDemoViewController)
final class CYLOriginalSearchDemoViewController: UIViewController, CYLSearchViewDelegate, CYLSearchViewDataSource {

    private let searchView = CYLSearchView(frame: .zero)
    private let searchField = CYLSearchBarView(frame: .zero)
    private var term = ""

    /**
     * The menu row's title.
     */
    static func rowTitle() -> String {
        cylOriginalDemoText("title")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // navigationItem.title: a view controller's title also renames its tab item.
        navigationItem.title = cylOriginalDemoText("title")
        // The GIF: a light gray strip behind a white field (UISearchBar's look); adaptive colors keep dark mode readable.
        view.backgroundColor = .systemGroupedBackground
        edgesForExtendedLayout = []
        installBlueBar()

        let sky = cylOriginalDemoSky()
        sky.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sky)

        // The field on the page: tapping it opens the search (a cover button; the real field lives in `searchView`).
        searchField.placeholder = cylOriginalDemoText("placeholder")
        searchField.fieldHeight = 30
        searchField.searchBarStyle = .plain
        searchField.fieldBackgroundColor = .secondarySystemGroupedBackground
        searchField.isUserInteractionEnabled = false
        searchField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchField)
        let cover = UIButton(type: .custom)
        cover.accessibilityLabel = cylOriginalDemoText("placeholder")
        cover.accessibilityIdentifier = "CYLOriginalDemoSearchField"
        cover.addAction(UIAction { [weak self] _ in self?.openSearch() }, for: .touchUpInside)
        cover.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cover)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: guide.topAnchor),
            searchField.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            searchField.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            sky.topAnchor.constraint(equalTo: searchField.bottomAnchor),
            sky.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sky.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sky.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            cover.topAnchor.constraint(equalTo: searchField.topAnchor),
            cover.leadingAnchor.constraint(equalTo: searchField.leadingAnchor),
            cover.trailingAnchor.constraint(equalTo: searchField.trailingAnchor),
            cover.bottomAnchor.constraint(equalTo: searchField.bottomAnchor),
        ])
        configureSearchView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    /**
     * The blue navigation bar with a white title.
     */
    private func installBlueBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0, green: 0.25, blue: 0.85, alpha: 1)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
    }

    private func configureSearchView() {
        searchView.delegate = self
        searchView.resultsDataSource = self
        searchView.searchBarView.placeholder = cylOriginalDemoText("placeholder")
        searchView.searchBarView.cancelButtonTitle = cylOriginalDemoText("cancel")
        // The GIF: Cancel ("取消") after the field closes the search; no back arrow before it.
        searchView.searchBarView.showsCancelButton = true
        searchView.searchBarView.navigationIcon = .none
        // The history: the queries the user submitted, newest first, kept across launches; the page has no suggestions of
        // its own.
        searchView.suggestions = []
        searchView.suggestionCachePolicy = .userDefaults
        searchView.suggestionCacheName = "CYLOriginalDemo"
        searchView.showsSuggestionsForEmptyQuery = true
        searchView.showsEmptySuggestionsPlaceholder = false
        // The clear button is a text button below the list, not the core's title and trash icon.
        searchView.showsSuggestionCacheHeader = false
        searchView.suggestionsTableView.tableFooterView = makeClearFooter()
        // The GIF: white history rows; only the area below the list shows the sky.
        searchView.suggestionCellConfiguration = { cell, _, _ in
            var background = UIBackgroundConfiguration.listPlainCell()
            background.backgroundColor = .systemBackground
            cell.backgroundConfiguration = background
        }
        // The sky stays under the list.
        searchView.contentView = cylOriginalDemoSky()
        searchView.closesOnSubmit = false
    }

    /**
     * "Clear search history": a bordered button centered below the history.
     */
    private func makeClearFooter() -> UIView {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 64))
        footer.backgroundColor = .systemBackground
        let button = UIButton(type: .system)
        button.setTitle(cylOriginalDemoText("clearHistory"), for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .footnote)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.separator.cgColor
        button.layer.cornerRadius = 4
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 24, bottom: 6, right: 24)
        button.accessibilityIdentifier = "CYLOriginalDemoClearHistory"
        button.addAction(UIAction { [weak self] _ in self?.searchView.clearSuggestionCache() }, for: .touchUpInside)
        button.sizeToFit()
        footer.addSubview(button)
        button.center = CGPoint(x: footer.bounds.midX, y: footer.bounds.midY)
        button.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        footer.autoresizingMask = .flexibleWidth
        return footer
    }

    private func openSearch() {
        searchView.showSearch(in: navigationController ?? self, animated: true)
    }

    // MARK: - CYLSearchViewDelegate

    func searchView(_ searchView: CYLSearchView, textDidChange text: String) {
        updateResultsHeader(for: text)
    }

    func searchView(_ searchView: CYLSearchView, didSubmitText text: String) -> Bool {
        updateResultsHeader(for: text)
        return true
    }

    func searchView(_ searchView: CYLSearchView, didSelectResult result: Any) {
        let detail = UIViewController()
        detail.navigationItem.title = nil
        detail.navigationItem.backButtonTitle = cylOriginalDemoText("back")
        detail.view.backgroundColor = .systemBackground
        let button = UIButton(type: .system)
        button.setTitle(cylOriginalDemoText("button"), for: .normal)
        button.sizeToFit()
        button.center = CGPoint(x: detail.view.bounds.midX, y: detail.view.bounds.midY)
        button.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        detail.view.addSubview(button)
        searchView.closeSearch()
        navigationController?.pushViewController(detail, animated: true)
    }

    /**
     * "Consultations about <term>" above the results.
     */
    private func updateResultsHeader(for text: String) {
        term = text
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        label.text = "  " + cylOriginalDemoText("resultsHeader", text)
        label.font = .preferredFont(forTextStyle: .footnote)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .systemTeal
        label.backgroundColor = .systemBackground
        label.accessibilityTraits = .header
        searchView.resultsTableView.tableHeaderView = label
    }

    // MARK: - CYLSearchViewDataSource

    func searchView(_ searchView: CYLSearchView, resultsForQuery query: String) -> [Any] {
        query.isEmpty ? [] : (1...4).map { cylOriginalDemoText("result", $0) }
    }

    func searchView(_ searchView: CYLSearchView, configureResultCell cell: UITableViewCell, withResult result: Any) {
        var content = UIListContentConfiguration.cell()
        content.text = result as? String
        cell.contentConfiguration = content
        cell.accessibilityTraits.insert(.button)
    }
}

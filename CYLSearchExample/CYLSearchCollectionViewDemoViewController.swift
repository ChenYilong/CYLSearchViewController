//
//  CYLSearchCollectionViewDemoViewController.swift
//  CYLSearchExample
//
//  The "Collection view" screen (QMUI issue #1313, row I5): the search bar sits in a container view that this screen owns,
//  above the collection view. After Cancel, UISearchController puts the bar back into its original superview; a bar inside
//  a reusable collection view header was re-laid out at that moment and jittered. A container of our own is laid out once
//  and never reused, so the bar returns to the frame it had.
//

import CYLSearchViewController
import UIKit

/**
 * Holds the search bar and lays it out to fill the container each time the container is laid out, so the frame is right as
 * soon as UIKit hands the bar back after Cancel.
 */
final class CYLSearchBarContainerView: UIView {

    let searchBar: UISearchBar

    init(searchBar: UISearchBar) {
        self.searchBar = searchBar
        super.init(frame: .zero)
        addSubview(searchBar)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if searchBar.superview === self { searchBar.frame = bounds }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: max(searchBar.intrinsicContentSize.height, 56))
    }
}

private final class CYLSearchDemoItemCell: UICollectionViewCell {

    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.frame = contentView.bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(label)
    }

    required init?(coder: NSCoder) {
        nil
    }
}

/**
 * A grid of items below a search bar in a container view (a plain view above the collection view, never a reusable view).
 */
@objc(CYLSearchCollectionViewDemoViewController)
public final class CYLSearchCollectionViewDemoViewController: UIViewController, CYLSearchControllerDelegate,
    UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    static let itemCount = 30
    private(set) var cylSearchController: CYLSearchController?
    private(set) var collectionView: UICollectionView?
    private(set) var searchContainer: UIView?
    private var matches: [String] = []

    private static func itemTitle(_ number: Int) -> String {
        String(format: cylDemoText("issue.item"), number)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = cylDemoText("demo.collectionView")
        view.backgroundColor = .systemBackground
        // The view starts below the navigation bar: the presentation fills this view, so the bar it holds is placed right
        // under the navigation bar (with the view under the bar, UIKit put it at the top of the screen, row I1 / #1319).
        edgesForExtendedLayout.remove(.top)
        let search = CYLSearchController(contentsViewController: self)
        search.searchResultsDelegate = self
        // The bar is in a container, not in a header: the navigation bar stays (as for a plain subview, row I2).
        search.hidesNavigationBarDuringPresentation = false
        cylSearchController = search

        let container = CYLSearchBarContainerView(searchBar: search.searchBar)
        container.translatesAutoresizingMaskIntoConstraints = false
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        let grid = UICollectionView(frame: .zero, collectionViewLayout: layout)
        grid.translatesAutoresizingMaskIntoConstraints = false
        grid.backgroundColor = .systemBackground
        grid.dataSource = self
        grid.delegate = self
        grid.register(CYLSearchDemoItemCell.self, forCellWithReuseIdentifier: "CYLSearchDemoItemCell")
        view.addSubview(grid)
        view.addSubview(container)
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            grid.topAnchor.constraint(equalTo: container.bottomAnchor),
            grid.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            grid.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            grid.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        collectionView = grid
        searchContainer = container
    }

    // MARK: - Collection view

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        Self.itemCount
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CYLSearchDemoItemCell", for: indexPath)
        (cell as? CYLSearchDemoItemCell)?.label.text = Self.itemTitle(indexPath.item + 1)
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 8 * 4) / 3
        return CGSize(width: floor(width), height: 88)
    }

    // MARK: - Results table (the delegate answers for it)

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        matches.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CYLSearchCollectionResultCell")
            ?? UITableViewCell(style: .default, reuseIdentifier: "CYLSearchCollectionResultCell")
        cell.textLabel?.text = matches[indexPath.row]
        cell.textLabel?.adjustsFontForContentSizeCategory = true
        return cell
    }

    // MARK: - CYLSearchControllerDelegate

    public func searchController(_ searchController: CYLSearchController, updateResultsFor searchString: String) {
        matches = searchString.isEmpty ? [] : (1...Self.itemCount).map(Self.itemTitle).filter {
            $0.range(of: searchString, options: .caseInsensitive) != nil
        }
        searchController.tableView?.reloadData()
        if matches.isEmpty && !searchString.isEmpty {
            searchController.showEmptyView(text: cylDemoText("controller.noResults"), detailText: nil, buttonTitle: nil,
                                           buttonAction: nil)
        } else {
            searchController.hideEmptyView()
        }
    }
}

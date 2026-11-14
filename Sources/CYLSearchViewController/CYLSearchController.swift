//
//  CYLSearchController.swift
//  CYLSearchViewController
//
//  Copyright (c) 2014 ChenYilong. All rights reserved.
//

import UIKit

/**
 * Events of a `CYLSearchController`.
 */
@objc(CYLSearchControllerDelegate)
public protocol CYLSearchControllerDelegate: NSObjectProtocol {
    /**
     * Cancel was tapped and the overlay is gone.
     */
    @objc(searchControllerDidCancel:)
    optional func searchControllerDidCancel(_ controller: CYLSearchController)
}

/**
 * An animated search overlay that uses the same injectable result source as `CYLSearchResultsViewController`. Keep
 * the controller while it is presented.
 */
@objc(CYLSearchController)
public final class CYLSearchController: UIViewController {

    /**
     * Receives the cancel event.
     */
    @objc public weak var delegate: CYLSearchControllerDelegate?

    /**
     * The results controller shown inside the overlay.
     */
    @objc public let resultsViewController: CYLSearchResultsViewController

    /**
     * YES while the overlay is on screen or animating in.
     */
    @objc(isPresented) public private(set) var presented = false

    private weak var overlayNavigationController: UINavigationController?
    private var dismissing = false
    private var dismissCompletions: [() -> Void] = []

    /**
     * Creates the overlay with the data source of its results.
     */
    @objc(initWithSearchDataSource:)
    public init(searchDataSource dataSource: CYLSearchResultsDataSource) {
        resultsViewController = CYLSearchResultsViewController(searchDataSource: dataSource)
        super.init(nibName: nil, bundle: nil)
    }

    /**
     * Not available: use `init(searchDataSource:)`.
     */
    @available(*, unavailable)
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) is not available; use init(searchDataSource:)")
    }

    /**
     * Not available: use `init(searchDataSource:)`.
     */
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) is not available; use init(searchDataSource:)")
    }

    /**
     * Keeps the view below the navigation bar and its search bar after every layout (a search bar never covers a
     * view).
     */
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cylKeepViewBelowNavigationBar()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        // The view starts below the navigation bar and its search bar: the search bar never covers this view.
        edgesForExtendedLayout.remove(.top)
        addChild(resultsViewController)
        let resultsView: UIView = resultsViewController.view
        resultsView.frame = view.bounds
        resultsView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(resultsView)
        resultsViewController.didMove(toParent: self)
        resultsViewController.navigationItem.searchController = nil
        navigationItem.searchController = resultsViewController.searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        // The search bar stays in the navigation bar, under the title. On iOS 26 an iPhone would otherwise float it
        // at the bottom of the screen, over the list: a search bar never covers a view.
        if #available(iOS 16.0, *) {
            navigationItem.preferredSearchBarPlacement = .stacked
        }
        if #available(iOS 26.0, *) {
            navigationItem.searchBarPlacementAllowsToolbarIntegration = false
        }
        definesPresentationContext = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelSearch))
    }

    /**
     * Adds a child navigation controller to the host and animates it into view.
     */
    @objc(showInViewController:)
    public func show(in controller: UIViewController) {
        if presented || dismissing {
            return
        }
        let navigationController = UINavigationController(rootViewController: self)
        loadViewIfNeeded()
        overlayNavigationController = navigationController
        presented = true
        controller.addChild(navigationController)
        navigationController.view.frame = controller.view.bounds
        navigationController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        navigationController.view.transform = CGAffineTransform(translationX: 0, y: 44)
        navigationController.view.alpha = 0
        controller.view.addSubview(navigationController.view)
        navigationController.didMove(toParent: controller)
        UIView.animate(withDuration: 0.25) {
            navigationController.view.transform = .identity
            navigationController.view.alpha = 1
        }
    }

    /**
     * Completion is called after the overlay is removed, including when not presented.
     */
    @objc(hide:)
    public func hide(_ completion: (() -> Void)?) {
        if let completion {
            dismissCompletions.append(completion)
        }
        if dismissing {
            return
        }
        guard let navigationController = overlayNavigationController, presented else {
            completeDismissal()
            return
        }
        dismissing = true
        resultsViewController.searchController.isActive = false
        navigationController.willMove(toParent: nil)
        UIView.animate(withDuration: 0.25) {
            navigationController.view.transform = CGAffineTransform(translationX: 0, y: 44)
            navigationController.view.alpha = 0
        } completion: { _ in
            navigationController.view.removeFromSuperview()
            navigationController.removeFromParent()
            self.overlayNavigationController = nil
            self.presented = false
            self.dismissing = false
            self.completeDismissal()
        }
    }

    private func completeDismissal() {
        let completions = dismissCompletions
        dismissCompletions.removeAll()
        completions.forEach { $0() }
    }

    @objc private func cancelSearch() {
        hide { [weak self] in
            guard let self else { return }
            self.delegate?.searchControllerDidCancel?(self)
        }
    }
}

//
//  CYLSearchNavigationBar.swift
//  CYLSearchViewController
//
//  The search bar in a navigation bar, always: `CYLSearchBarView.embedInNavigationBar(of:)` puts the bar into the
//  navigation bar of a view controller, and creates one, a `CYLSearchNavigationBar`, when the view controller has none
//  (docs/animated-icon-component.md, "Refresh, hot data and navigation bar contract", part C).
//

import UIKit

/**
 * A navigation bar the core creates for a view controller that has none, holding the search bar as its title view,
 * attached to the top edge so its background reaches under the status bar.
 */
@objc(CYLSearchNavigationBar)
public final class CYLSearchNavigationBar: UINavigationBar, UINavigationBarDelegate {

    /**
     * The height of a navigation bar below the status bar, 44 pt.
     */
    @objc public static let standardHeight: CGFloat = 44

    override public init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    /**
     * Attached to the top edge: the background extends under the status bar.
     */
    public func position(for bar: any UIBarPositioning) -> UIBarPosition {
        .topAttached
    }
}

extension CYLSearchBarView {

    /**
     * Puts this bar into the navigation bar of `viewController` and returns that navigation bar; a navigation bar always
     * exists afterwards. With a `navigationController` the bar becomes the `navigationItem`'s title view and the
     * controller's own navigation bar is returned. Without one the core creates a `CYLSearchNavigationBar` at the top of
     * the view controller's view, raises the view controller's top safe area by its height (so content laid out under
     * `safeAreaLayoutGuide.topAnchor` never sits under it) and returns it. The field becomes 36 pt high with no side inset
     * of its own (the navigation bar's 16 pt margin is the inset that lines it up with the tag lists), which fits the
     * 44 pt bar.
     */
    @objc(embedInNavigationBarOfViewController:)
    @discardableResult
    public func embedInNavigationBar(of viewController: UIViewController) -> UINavigationBar {
        removeFromSuperview()
        fieldHeight = 36
        contentInsets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        isEmbeddedInNavigationBar = true
        if let navigationController = viewController.navigationController {
            viewController.navigationItem.titleView = self
            return navigationController.navigationBar
        }
        viewController.loadViewIfNeeded()
        let height = CYLSearchNavigationBar.standardHeight
        let navigationBar = CYLSearchNavigationBar()
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        let item = UINavigationItem()
        item.titleView = self
        navigationBar.items = [item]
        let view = viewController.view!
        view.addSubview(navigationBar)
        viewController.additionalSafeAreaInsets.top += height
        NSLayoutConstraint.activate([
            // The guide includes the raised inset: the bar starts where the safe area started before.
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -height),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: height),
        ])
        return navigationBar
    }
}

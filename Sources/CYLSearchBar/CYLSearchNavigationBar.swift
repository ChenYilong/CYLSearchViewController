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
     * Called when the back button is tapped (a bar made with `showsBackButton`); the bar itself never pops, the host
     * decides (a Flutter route pops, a React Native screen closes).
     */
    @objc public var backHandler: (() -> Void)?

    /**
     * A navigation bar holding `searchBar` as its title view, with the bar set up for it (36 pt field, no side inset of
     * its own, `isEmbeddedInNavigationBar`). The bridges use it as the content of their native view.
     */
    @objc(navigationBarHoldingSearchBar:)
    public static func holding(_ searchBar: CYLSearchBarView) -> CYLSearchNavigationBar {
        holding(searchBar, showsBackButton: false)
    }

    /**
     * As `holding(_:)`, and with `showsBackButton` the bar has the back button of a second-level page on its leading
     * side (a root item titled "Back" below the item of the search bar); the search bar takes the width that is left.
     * A tap on it calls `backHandler`.
     */
    @objc(navigationBarHoldingSearchBar:showsBackButton:)
    public static func holding(_ searchBar: CYLSearchBarView, showsBackButton: Bool) -> CYLSearchNavigationBar {
        searchBar.removeFromSuperview()
        searchBar.fieldHeight = 36
        searchBar.contentInsets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        searchBar.isEmbeddedInNavigationBar = true
        let navigationBar = CYLSearchNavigationBar()
        let item = UINavigationItem()
        item.titleView = searchBar
        if showsBackButton {
            let root = UINavigationItem(title: CYLSearchResources.localizedString(forKey: "navigationBar.back"))
            navigationBar.items = [root, item]
        } else {
            navigationBar.items = [item]
        }
        return navigationBar
    }

    /**
     * The back button was tapped: the host's `backHandler` runs, the bar keeps its items.
     */
    public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        backHandler?()
        return false
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
        if let navigationController = viewController.navigationController {
            removeFromSuperview()
            fieldHeight = 36
            contentInsets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
            isEmbeddedInNavigationBar = true
            viewController.navigationItem.titleView = self
            return navigationController.navigationBar
        }
        viewController.loadViewIfNeeded()
        let height = CYLSearchNavigationBar.standardHeight
        let navigationBar = CYLSearchNavigationBar.holding(self)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
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

extension CYLSearchBarView {

    /**
     * The look of the input box of a navigation bar, the one every screen uses: a bordered capsule (`.bordered`, corner
     * radius 18) with a soft shadow, an opaque white (light) or black (dark) fill, no magnifier, 16 pt text that scales with Dynamic Type. The border, the divider
     * and the items (a camera, a search button) adapt to light and dark mode as in the core's bar. Call it before
     * `addItem(_:)` and `embedInNavigationBar(of:)`; items, text and delegate stay the caller's.
     */
    @objc(applyNavigationFieldStyle)
    public func applyNavigationFieldStyle() {
        searchIcon = nil
        searchBarStyle = .bordered
        fieldCornerRadius = 18
        fieldShadowOpacity = 0.06
        // An opaque fill in both modes (white, black) on any page: a sheet's elevated trait or a gradient never shows through.
        fieldBackgroundColor = UIColor { $0.userInterfaceStyle == .dark ? .black : .white }
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: 16))
    }
}

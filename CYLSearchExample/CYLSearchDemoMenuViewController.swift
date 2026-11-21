//
//  CYLSearchDemoMenuViewController.swift
//  CYLSearchExample
//
//  The examples menu, its placeholder gallery and the SVGA demo header (translated from Objective-C,
//  docs/swift-migration.md).
//

import CYLAnimatedItem
import CYLSearchViewController
import CYLTableViewPlaceHolder
import CollectionViewClassifyMenu
import UIKit

/**
 * A text of the example's own strings (CYLSearchTabs.bundle), as the tab titles.
 */
private func cylExampleText(_ key: String) -> String {
    cylSearchTabTitle(key)
}

/**
 * The SVGA demo above the Examples list, as CYLTabBarController's Example-Rive shows its Rive and SVGA demos above the Bell
 * list: a `CYLTagButton` (CollectionViewClassifyMenu) with an `.svga` `animationURL` that plays once (tap to play it again,
 * `playAnimation`), and a button that switches where the tab icons come from (SF Symbols, SVGA through the initialization
 * keys, SVGA through a configuration file) and rebuilds the tab bar (`CYLDemoTabIconSource`, also a launch argument).
 */
private final class CYLSVGADemoHeaderView: UIView {

    private let animationButton: CYLTagButton
    private let sourceButton = UIButton(type: .system)

    override init(frame: CGRect) {
        let url = Bundle.main.url(forResource: "tab_activity", withExtension: "svga")
        animationButton = CYLSVGADemoTagButton.button(title: cylExampleText("svga.demo"), animationURL: url)
        super.init(frame: frame)
        animationButton.accessibilityHint = cylExampleText("svga.demo.hint")
        animationButton.accessibilityIdentifier = "CYLSVGADemoTagButton"
        addSubview(animationButton)

        sourceButton.titleLabel?.numberOfLines = 0
        sourceButton.titleLabel?.adjustsFontForContentSizeCategory = true
        sourceButton.accessibilityIdentifier = "CYLSVGADemoSourceButton"
        sourceButton.accessibilityHint = cylExampleText("svga.source.hint")
        sourceButton.addTarget(self, action: #selector(switchSource), for: .touchUpInside)
        sourceButton.setTitle(String(format: cylExampleText("svga.source"), Self.sourceName()), for: .normal)
        addSubview(sourceButton)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        // Plays once when shown, as the tab icons do when selected.
        if window != nil {
            animationButton.playAnimation()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let inset: CGFloat = 16
        let width = bounds.width
        animationButton.frame = CGRect(x: inset, y: 12, width: width - inset * 2, height: 64)
        sourceButton.frame = CGRect(x: inset, y: 84, width: width - inset * 2, height: 44)
        sourceButton.contentHorizontalAlignment = .leading
    }

    private static func sourceName() -> String {
        let names = ["svga.source.symbols", "svga.source.keys", "svga.source.file"]
        let source = UserDefaults.standard.integer(forKey: "CYLDemoTabIconSource")
        return cylExampleText(names[max(0, min(source, 2))])
    }

    @objc private func switchSource() {
        let source = (UserDefaults.standard.integer(forKey: "CYLDemoTabIconSource") + 1) % 3
        UserDefaults.standard.set(source, forKey: "CYLDemoTabIconSource")
        // The examples tab stays selected in the new tab bar.
        UserDefaults.standard.set("1", forKey: "CYLDemoTab")
        window?.rootViewController = CYLSearchExampleAppDelegate.rootViewController()
        UserDefaults.standard.removeObject(forKey: "CYLDemoTab")
        UIAccessibility.post(notification: .screenChanged, argument: nil)
    }
}

/**
 * Every `CYLPlaceholderStyle` with four messages, and three custom placeholders. The styles, images and texts are
 * CYLTableViewPlaceHolder's `CYLPlaceholderView` (the core's former CYLSearchPlaceholderView was a duplicate of it and is
 * gone).
 */
@objc(CYLSearchPlaceholderGalleryViewController)
final class CYLSearchPlaceholderGalleryViewController: UITableViewController {

    private static let messages: [CYLPlaceholderMessage] = [.empty, .noResults, .noInternet, .error]
    private static let styleCount = CYLPlaceholderStyle.count.rawValue

    override func viewDidLoad() {
        super.viewDidLoad()
        title = cylDemoText("demo.styles")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        Self.styleCount + 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == Self.styleCount ? 3 : Self.messages.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == Self.styleCount { return cylDemoText("demo.custom") }
        return CYLPlaceholderStyle(rawValue: section).flatMap { CYLPlaceholderView.imageName(for: $0) }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CYLDemoOption")
            ?? UITableViewCell(style: .default, reuseIdentifier: "CYLDemoOption")
        let custom = ["demo.custom.textOnly", "demo.custom.imageOnly", "demo.custom.both"]
        if indexPath.section == Self.styleCount {
            cell.textLabel?.text = cylDemoText(custom[indexPath.row])
            cell.imageView?.image = indexPath.row == 0
                ? CYLPlaceholderView.image(for: .noResults)?.withRenderingMode(.alwaysTemplate)
                : UIImage(systemName: "heart.fill")
        } else if let style = CYLPlaceholderStyle(rawValue: indexPath.section) {
            cell.textLabel?.text = CYLPlaceholderView.localizedText(for: Self.messages[indexPath.row])
            let image = CYLPlaceholderView.image(for: style)
            cell.imageView?.image = style == .empty ? image : image?.withRenderingMode(.alwaysTemplate)
        }
        cell.imageView?.tintColor = .secondaryLabel
        cell.textLabel?.numberOfLines = 0
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let placeholder: CYLPlaceholderView
        if indexPath.section < Self.styleCount, let style = CYLPlaceholderStyle(rawValue: indexPath.section) {
            placeholder = CYLPlaceholderView(style: style, message: Self.messages[indexPath.row])
        } else if indexPath.row == 0 {
            placeholder = CYLPlaceholderView(style: .noResults, text: cylDemoText("demo.custom.text"))
        } else {
            let image = UIImage(systemName: "heart.fill")
            placeholder = CYLPlaceholderView(image: image, text: indexPath.row == 1 ? nil : cylDemoText("demo.custom.text"))
            placeholder.imageView.tintColor = .systemPink
        }
        let detail = UIViewController()
        detail.title = tableView.cellForRow(at: indexPath)?.textLabel?.text
        detail.view.backgroundColor = .systemBackground
        placeholder.frame = detail.view.bounds
        placeholder.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        detail.view.addSubview(placeholder)
        navigationController?.pushViewController(detail, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

/**
 * The examples menu: the SVGA demo above a list of the example screens.
 */
@objc(CYLSearchDemoMenuViewController)
public final class CYLSearchDemoMenuViewController: UITableViewController {

    /**
     * `-CYLDemoRow 2` on launch opens that row, once, for screenshots.
     */
    private static var openedLaunchRow = false

    public override func viewDidLoad() {
        super.viewDidLoad()
        // The navigation title only: `title` would also rename the tab this menu sits in.
        navigationItem.title = cylDemoText("demo.title")
        tableView.tableHeaderView = CYLSVGADemoHeaderView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 136))
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !Self.openedLaunchRow, let row = UserDefaults.standard.string(forKey: "CYLDemoRow"), !row.isEmpty else { return }
        Self.openedLaunchRow = true
        guard let index = Int(row), index >= 0, index < tableView(tableView, numberOfRowsInSection: 0) else { return }
        tableView(tableView, didSelectRowAt: IndexPath(row: index, section: 0))
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // The fifth row: the SVGA tab bar hosted in SwiftUI (CYLSVGASwiftUIDemo.swift); the sixth: the contact tags demo
        // ported from CollectionViewClassifyMenu (CYLContactTagStore.swift); the seventh: the original demo of the README
        // screenshot, rebuilt on CYLSearchView (CYLOriginalSearchDemoViewController.swift).
        // The eighth: the QMUI search bar styles screen (CYLSearchBarStylesViewController.swift).
        8
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CYLDemoMenu")
            ?? UITableViewCell(style: .default, reuseIdentifier: "CYLDemoMenu")
        let rows = ["demo.reproduction", "demo.styles", "demo.searchBar", "demo.ports"]
        if indexPath.row < rows.count {
            cell.textLabel?.text = cylDemoText(rows[indexPath.row])
        } else if indexPath.row == 4 {
            cell.textLabel?.text = cylExampleText("svga.swiftui")
        } else if indexPath.row == 7 {
            cell.textLabel?.text = cylDemoText("demo.searchBarStyles")
        } else if indexPath.row == 6 {
            cell.textLabel?.text = CYLOriginalSearchDemoViewController.rowTitle()
        } else {
            cell.textLabel?.text = CYLContactTagsDemo.rowTitle()
        }
        cell.textLabel?.numberOfLines = 0
        cell.accessibilityIdentifier = "CYLDemoRow\(indexPath.row)"
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { tableView.deselectRow(at: indexPath, animated: true) }
        if indexPath.row == 4 {
            // The SVGA tab bar hosted in SwiftUI, full screen (a tab bar cannot be pushed inside another one).
            present(CYLSVGASwiftUIDemo.viewController(), animated: true)
            return
        }
        let controller: UIViewController
        switch indexPath.row {
        case 5:
            // The contact tags demo: "Edit Remarks", whose tags open "Edit Tags" with CYLSearchBarView.
            controller = CYLContactTagsDemo.viewController()
        case 6:
            // The original demo (the README screenshot): a Ken Burns sky, the history, the results.
            controller = CYLOriginalSearchDemoViewController()
        case 7:
            // QMUI's QDSearchBarViewController: the styles of CYLSearchBar.
            controller = CYLSearchBarStylesViewController(style: .grouped)
        case 0:
            let source = CYLSearchExampleDataSource()
            controller = CYLSearchExampleViewController(searchDataSource: source, refreshProvider: source)
        case 1:
            controller = CYLSearchPlaceholderGalleryViewController(style: .grouped)
        case 2:
            controller = CYLSearchBarDemoViewController()
        default:
            // The Swift ports of five other search libraries' examples (docs/search-api-comparison.md).
            controller = CYLSearchPortsViewController(style: .insetGrouped)
        }
        navigationController?.pushViewController(controller, animated: true)
    }
}

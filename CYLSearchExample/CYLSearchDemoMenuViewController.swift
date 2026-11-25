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
 * One tag of a demo tag list: the cell's main title and icon; `subtitle` is what a long press shows (VoiceOver hint now; the
 * floating bubble with an arrow comes with ClassifyMenu's `menuSubtitleForItem`, PR #37).
 */
struct CYLDemoTagItem {
    let title: String
    let image: UIImage?
    let subtitle: String?
    let action: (UIViewController) -> Void
}

/**
 * A titled section of a demo tag list: a table view section's header and rows.
 */
struct CYLDemoTagSection {
    let title: String
    let items: [CYLDemoTagItem]
}

/**
 * The example's grouped demo lists (docs/instructions/example-demos.md): a sectioned CollectionViewClassifyMenu tag list in
 * place of a grouped table view. Every tag is a Liquid Glass tag (the core's one `backgroundStyle` parameter, set through
 * `CYLSearchTagListStyle`), a tag title may wrap, the tag width follows its content so a row holds as many tags as fit, each
 * section shows 3 rows and then the core's "more" / "less" fold control with its chevron, and a tap does what the cell did.
 */
class CYLDemoTagListViewController: UIViewController, CYLMenuDataSource, CYLMenuDelegate {

    /**
     * Rows shown while a section is folded.
     */
    static let foldedRows = 3

    let sections: [CYLDemoTagSection]
    let tagList = CYLTagListView(foldControl: CYLMenuFoldControl(position: .tail, content: .iconAndTitle))

    init(title: String, sections: [CYLDemoTagSection]) {
        self.sections = sections
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        CYLSearchTagListStyle.applyDefaultStyle(to: tagList)
        CYLSearchTagListStyle.applyBackgroundStyle(named: "liquidGlass", to: tagList)
        let style = tagList.style.copy() as! CYLMenuStyle
        style.titleWraps = true
        tagList.style = style
        tagList.selectionMode = .none
        tagList.defaultVisibleRows = Self.foldedRows
        tagList.menuDataSource = self
        tagList.menuDelegate = self
        tagList.accessibilityIdentifier = "CYLDemoTagList"
        tagList.frame = view.bounds
        tagList.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tagList)
        tagList.reloadMenuData()
    }

    // MARK: CYLMenuDataSource

    func numberOfSectionsInMenu() -> Int {
        sections.count
    }

    func menuNumberOfItems(inSection section: Int) -> Int {
        sections[section].items.count
    }

    func menuTitle(forSection section: Int) -> String {
        sections[section].title
    }

    func menuTitleForItem(at indexPath: IndexPath) -> String {
        sections[indexPath.section].items[indexPath.item].title
    }

    func menuImageForItem(at indexPath: IndexPath) -> UIImage? {
        sections[indexPath.section].items[indexPath.item].image
    }

    func menuAccessibilityHintForItem(at indexPath: IndexPath) -> String? {
        sections[indexPath.section].items[indexPath.item].subtitle
    }

    // MARK: CYLMenuDelegate

    func menu(_ menu: Any, didSelectItemAt indexPath: IndexPath) {
        sections[indexPath.section].items[indexPath.item].action(self)
    }
}

/**
 * Every `CYLPlaceholderStyle` with four messages, and three custom placeholders, as demo tag lists (a section per style).
 * The styles, images and texts are CYLTableViewPlaceHolder's `CYLPlaceholderView` (the core's former
 * CYLSearchPlaceholderView was a duplicate of it and is gone).
 */
@objc(CYLSearchPlaceholderGalleryViewController)
final class CYLSearchPlaceholderGalleryViewController: CYLDemoTagListViewController {

    private static let messages: [CYLPlaceholderMessage] = [.empty, .noResults, .noInternet, .error]
    private static let styleCount = CYLPlaceholderStyle.count.rawValue

    init() {
        super.init(title: cylDemoText("demo.styles"), sections: Self.makeSections())
    }

    required init?(coder: NSCoder) {
        nil
    }

    /**
     * A section per style (titled with the style's image name) and the custom section.
     */
    private static func makeSections() -> [CYLDemoTagSection] {
        var sections: [CYLDemoTagSection] = []
        for index in 0..<styleCount {
            guard let style = CYLPlaceholderStyle(rawValue: index) else { continue }
            let image = CYLPlaceholderView.image(for: style)
            let icon = (style == .empty ? image : image?.withRenderingMode(.alwaysTemplate))
            let title = CYLPlaceholderView.imageName(for: style) ?? "\(index)"
            sections.append(CYLDemoTagSection(title: title, items: messages.map { message in
                let text = CYLPlaceholderView.localizedText(for: message)
                return CYLDemoTagItem(title: text, image: icon, subtitle: nil) { host in
                    show(CYLPlaceholderView(style: style, message: message), title: text, from: host)
                }
            }))
        }
        let heart = UIImage(systemName: "heart.fill")
        let noResults = CYLPlaceholderView.image(for: .noResults)?.withRenderingMode(.alwaysTemplate)
        let custom: [(key: String, image: UIImage?, make: () -> CYLPlaceholderView)] = [
            ("demo.custom.textOnly", noResults, { CYLPlaceholderView(style: .noResults, text: cylDemoText("demo.custom.text")) }),
            ("demo.custom.imageOnly", heart, { customHeart(text: nil) }),
            ("demo.custom.both", heart, { customHeart(text: cylDemoText("demo.custom.text")) }),
        ]
        sections.append(CYLDemoTagSection(title: cylDemoText("demo.custom"), items: custom.map { entry in
            let text = cylDemoText(entry.key)
            return CYLDemoTagItem(title: text, image: entry.image, subtitle: nil) { host in
                show(entry.make(), title: text, from: host)
            }
        }))
        return sections
    }

    private static func customHeart(text: String?) -> CYLPlaceholderView {
        let placeholder = CYLPlaceholderView(image: UIImage(systemName: "heart.fill"), text: text)
        placeholder.imageView.tintColor = .systemPink
        return placeholder
    }

    /**
     * The tapped tag's placeholder, full screen, as the table row's tap pushed it.
     */
    private static func show(_ placeholder: CYLPlaceholderView, title: String, from host: UIViewController) {
        let detail = UIViewController()
        detail.title = title
        detail.view.backgroundColor = .systemBackground
        placeholder.frame = detail.view.bounds
        placeholder.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        detail.view.addSubview(placeholder)
        host.navigationController?.pushViewController(detail, animated: true)
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
        // The eighth: the QMUI search bar styles screen (CYLSearchBarStylesViewController.swift); the ninth: the QMUI search
        // controller screen (CYLSearchControllerDemoViewController.swift); the tenth to the thirteenth: the owner's issue
        // scenarios (docs/qmui-search-controller.md): navigation item (#1229), bar in a view (#1251), short list (#1160) and
        // collection view (#1313).
        13
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CYLDemoMenu")
            ?? UITableViewCell(style: .default, reuseIdentifier: "CYLDemoMenu")
        let rows = ["demo.reproduction", "demo.styles", "demo.searchBar", "demo.ports"]
        if indexPath.row < rows.count {
            cell.textLabel?.text = cylDemoText(rows[indexPath.row])
        } else if indexPath.row == 4 {
            cell.textLabel?.text = cylExampleText("svga.swiftui")
        } else if indexPath.row >= 9 {
            cell.textLabel?.text = cylDemoText(["demo.navigationItem", "demo.barInView", "demo.shortList",
                                                "demo.collectionView"][indexPath.row - 9])
        } else if indexPath.row == 8 {
            cell.textLabel?.text = cylDemoText("demo.searchController")
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
        case 9:
            controller = CYLSearchNavigationItemDemoViewController(style: .plain)
        case 10:
            controller = CYLSearchBarInViewDemoViewController()
        case 11:
            controller = CYLSearchShortListDemoViewController(style: .plain)
        case 12:
            controller = CYLSearchCollectionViewDemoViewController()
        case 8:
            // QMUI's QDSearchViewController: CYLSearchController with a launch view and swipe to dismiss.
            controller = CYLSearchControllerDemoViewController(style: .plain)
        case 7:
            // QMUI's QDSearchBarViewController: the styles of CYLSearchBar.
            controller = CYLSearchBarStylesViewController(style: .grouped)
        case 0:
            let source = CYLSearchExampleDataSource()
            controller = CYLSearchExampleViewController(searchDataSource: source, refreshProvider: source)
        case 1:
            controller = CYLSearchPlaceholderGalleryViewController()
        case 2:
            controller = CYLSearchBarDemoViewController()
        default:
            // The Swift ports of five other search libraries' examples (docs/search-api-comparison.md).
            controller = CYLSearchPortsViewController()
        }
        navigationController?.pushViewController(controller, animated: true)
    }
}

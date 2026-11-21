//
//  CYLSearchBarStylesViewController.swift
//  CYLSearchExample
//
//  The "Search bar styles" screen: a replica of QMUI's QDSearchBarViewController (QMUIDemo_iOS). Sections Placeholder,
//  Layout and AccessoryView drive one `CYLSearchBar` that is the table header.
//

import CYLSearchViewController
import UIKit

/**
 * Shows every style knob of `CYLSearchBar` the way QMUI's demo does: a centered placeholder, a changed placeholder, margins
 * of the text field at rest and of the Cancel button while searching, and leading and trailing accessory views that are
 * shown and hidden with or without animation. Text comes from the core's string table (four languages).
 */
@objc(CYLSearchBarStylesViewController)
public final class CYLSearchBarStylesViewController: CYLSearchBarHostTableViewController, UISearchBarDelegate {

    private enum Row: Int {
        case centerPlaceholder, changePlaceholder
        case adjustField, adjustCancel
        case animated, toggleCancel, toggleLeading, toggleTrailing
    }

    private static let sections: [[Row]] = [
        [.centerPlaceholder, .changePlaceholder],
        [.adjustField, .adjustCancel],
        [.animated, .toggleCancel, .toggleLeading, .toggleTrailing],
    ]

    private var animated = true
    /// Set once a row shows or hides Cancel by hand: editing then no longer toggles it.
    private var cancelPinned = false

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = cylDemoText("demo.searchBarStyles")
        view.backgroundColor = .systemGroupedBackground
    }

    public override func setUpSearchBar() {
        searchBar.delegate = self
        searchBar.leadingAccessoryView = Self.accessoryView()
        searchBar.trailingAccessoryView = Self.accessoryView()
        searchBar.leadingAccessoryViewMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        searchBar.trailingAccessoryViewMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        // For the demo: hidden first, shown by the person.
        searchBar.showsLeadingAccessoryView = false
        searchBar.showsTrailingAccessoryView = false
    }

    private static func accessoryView() -> UIView {
        let size = CGSize(width: 30, height: 30)
        let colors: [UIColor] = [.systemRed, .systemBlue, .systemGreen, .systemOrange, .systemPurple, .systemTeal]
        let color = colors.randomElement() ?? .systemBlue
        let image = UIGraphicsImageRenderer(size: size).image { _ in
            color.setStroke()
            let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size).insetBy(dx: 1.5, dy: 1.5), cornerRadius: 6)
            path.lineWidth = 3
            path.stroke()
        }
        let view = UIImageView(image: image)
        view.isAccessibilityElement = true
        view.accessibilityLabel = cylDemoText("styles.accessory.label")
        return view
    }

    // MARK: - Table

    public override func numberOfSections(in tableView: UITableView) -> Int {
        Self.sections.count
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Self.sections[section].count
    }

    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        cylDemoText(["styles.section.placeholder", "styles.section.layout", "styles.section.accessory"][section])
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = Self.sections[indexPath.section][indexPath.row]
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.accessibilityIdentifier = "CYLSearchBarStylesRow\(row.rawValue)"
        cell.accessibilityHint = cylDemoText("styles.row.hint")
        var content = cell.defaultContentConfiguration()
        content.text = title(for: row)
        content.textProperties.numberOfLines = 0
        cell.contentConfiguration = content
        switch row {
        case .centerPlaceholder, .animated:
            let toggle = UISwitch()
            toggle.isOn = row == .animated ? animated : searchBar.centersPlaceholder
            toggle.accessibilityLabel = content.text
            toggle.tag = row.rawValue
            toggle.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
            cell.accessoryView = toggle
            cell.selectionStyle = .none
        default:
            break
        }
        return cell
    }

    private func title(for row: Row) -> String {
        func toggleTitle(_ shown: Bool, _ nameKey: String) -> String {
            String(format: cylDemoText(shown ? "styles.hide" : "styles.show"), cylDemoText(nameKey))
        }
        switch row {
        case .centerPlaceholder: return cylDemoText("styles.centerPlaceholder")
        case .changePlaceholder: return cylDemoText("styles.changePlaceholder")
        case .adjustField: return cylDemoText("styles.adjustField")
        case .adjustCancel: return cylDemoText("styles.adjustCancel")
        case .animated: return cylDemoText("styles.animated")
        case .toggleCancel: return toggleTitle(searchBar.showsCancelButton, "styles.cancel")
        case .toggleLeading: return toggleTitle(searchBar.showsLeadingAccessoryView, "styles.leading")
        case .toggleTrailing: return toggleTitle(searchBar.showsTrailingAccessoryView, "styles.trailing")
        }
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = Self.sections[indexPath.section][indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        switch row {
        case .changePlaceholder:
            searchBar.placeholder = cylDemoText("styles.longPlaceholder")
        case .adjustField:
            searchBar.textFieldMarginsProvider = { _, active in
                active ? .zero : UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)
            }
        case .adjustCancel:
            searchBar.cancelButtonMarginsProvider = { _, active in
                active ? UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0) : .zero
            }
            if !searchBar.isFirstResponder { searchBar.becomeFirstResponder() }
        case .toggleCancel:
            cancelPinned = true
            searchBar.setShowsCancelButton(!searchBar.showsCancelButton, animated: animated)
            tableView.reloadRows(at: [indexPath], with: .fade)
        case .toggleLeading:
            searchBar.setShowsLeadingAccessoryView(!searchBar.showsLeadingAccessoryView, animated: animated)
            tableView.reloadRows(at: [indexPath], with: .fade)
        case .toggleTrailing:
            searchBar.setShowsTrailingAccessoryView(!searchBar.showsTrailingAccessoryView, animated: animated)
            tableView.reloadRows(at: [indexPath], with: .fade)
        case .centerPlaceholder, .animated:
            break
        }
    }

    @objc private func switchChanged(_ toggle: UISwitch) {
        switch Row(rawValue: toggle.tag) {
        case .centerPlaceholder: searchBar.centersPlaceholder = toggle.isOn
        case .animated: animated = toggle.isOn
        default: break
        }
    }

    // MARK: - UISearchBarDelegate

    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // A bar without a search controller shows Cancel by hand while it is edited.
        if !cancelPinned { searchBar.setShowsCancelButton(true, animated: true) }
    }

    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if !cancelPinned { searchBar.setShowsCancelButton(false, animated: true) }
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
    }
}

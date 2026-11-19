//
//  CYLSearchBarDemoViewController.swift
//  CYLSearchExample
//
//  Translated from Objective-C (docs/swift-migration.md).
//

import CYLSearchViewController
import UIKit

/**
 * Shows a `CYLSearchBarView` with a camera accessory and Cancel, and prints the text and the Search key below it. Used by
 * the "Search bar" demo row and as the plus page of the tab bar.
 */
@objc(CYLSearchBarDemoViewController)
public final class CYLSearchBarDemoViewController: UIViewController, CYLSearchBarViewDelegate {

    private let searchBarView = CYLSearchBarView(frame: .zero)
    private let statusLabel = UILabel()

    public override func viewDidLoad() {
        super.viewDidLoad()
        // navigationItem.title: as the plus page, title would rename the plus button's tab item.
        navigationItem.title = demoText("demo.searchBar")
        view.backgroundColor = .systemBackground

        searchBarView.placeholder = demoText("demo.searchBar.placeholder")
        searchBarView.showsCancelButton = true
        searchBarView.fieldShadowOpacity = 0.12
        searchBarView.delegate = self
        let camera = UIButton(type: .system)
        camera.setImage(UIImage(systemName: "camera"), for: .normal)
        camera.accessibilityLabel = demoText("demo.searchBar.camera")
        searchBarView.trailingAccessoryViews = [camera]
        searchBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBarView)

        statusLabel.font = .preferredFont(forTextStyle: .body)
        statusLabel.adjustsFontForContentSizeCategory = true
        statusLabel.textColor = .secondaryLabel
        statusLabel.numberOfLines = 0
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        show(text: "")

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            searchBarView.topAnchor.constraint(equalTo: guide.topAnchor),
            searchBarView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            searchBarView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            statusLabel.topAnchor.constraint(equalTo: searchBarView.bottomAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),
        ])
    }

    private func demoText(_ key: String) -> String {
        CYLSearchResources.localizedString(forKey: key)
    }

    private func show(text: String) {
        statusLabel.text = String(format: demoText("demo.searchBar.text"), text)
    }

    // MARK: - CYLSearchBarViewDelegate

    public func searchBarView(_ searchBarView: CYLSearchBarView, textDidChange text: String) {
        show(text: text)
    }

    public func searchBarViewSearchButtonClicked(_ searchBarView: CYLSearchBarView) {
        statusLabel.text = String(format: demoText("demo.searchBar.searched"), searchBarView.text ?? "")
        UIAccessibility.post(notification: .announcement, argument: statusLabel.text)
    }

    public func searchBarViewCancelButtonClicked(_ searchBarView: CYLSearchBarView) {
        searchBarView.text = nil
        show(text: "")
    }
}

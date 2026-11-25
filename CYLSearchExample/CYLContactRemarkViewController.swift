//
//  CYLContactRemarkViewController.swift
//  CYLSearchExample
//
//  "Edit Remarks": the screen the tag editor is presented from, as in a chat app's contact remarks, ported from
//  CollectionViewClassifyMenu's CYLTagEditorExample (CYLRemarkViewController). Its "Tags" row shows the chosen tags (a
//  display-only CYLTagListView); tapping it opens "Edit Tags" (CYLContactTagEditorViewController) as a sheet. Without
//  tags, CYLTableViewPlaceHolder's CYLPlaceholderView takes the list's place; tapping it opens the editor too.
//

import UIKit
import CollectionViewClassifyMenu
import CYLTableViewPlaceHolder

/**
 * "Edit Remarks": a remark name and the contact's tags; the tags open "Edit Tags".
 */
final class CYLContactRemarkViewController: UIViewController {

    /**
     * The user's tags.
     */
    let store: CYLContactTagStore

    /**
     * The ids of the contact's tags.
     */
    private(set) var tags: [String]

    /**
     * The large title, the remark name and the tags.
     */
    let titleLabel = UILabel()
    let nameField = UITextField()
    let tagsView = CYLTagListView()

    /**
     * CYLTableViewPlaceHolder's placeholder shown below "Tags" while the contact has no tags; nil before it is needed.
     */
    private(set) var emptyTagsView: CYLPlaceholderView?

    /**
     * The remark screen of a contact with `tags`, chosen from `store`.
     */
    init(store: CYLContactTagStore, tags: [String]) {
        self.store = store
        self.tags = tags
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        cylInstallDemoGradient()
        let done = UIBarButtonItem(title: cylContactTagsText("done"), style: .done, target: nil, action: nil)
        done.isEnabled = false
        navigationItem.rightBarButtonItem = done

        titleLabel.text = cylContactTagsText("editRemarks")
        titleLabel.font = UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: .systemFont(ofSize: 28, weight: .bold))
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.accessibilityTraits = .header

        nameField.placeholder = cylContactTagsText("remarkName")
        nameField.accessibilityLabel = cylContactTagsText("remarkName")
        nameField.font = .preferredFont(forTextStyle: .body)
        nameField.adjustsFontForContentSizeCategory = true
        nameField.borderStyle = .none
        nameField.backgroundColor = .systemGray6
        nameField.layer.cornerRadius = 8
        nameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        nameField.leftViewMode = .always

        // The chosen tags, display only (taps open the editor). "Tags >" is the list's own title view.
        tagsView.title = cylContactTagsText("tags")
        tagsView.titleImage = UIImage(systemName: "chevron.right")
        let titleStyle = CYLTagListView.defaultTitleStyle
        for state in [UIControl.State.normal, .selected, .disabled] {
            titleStyle.appearance(for: state).font = .preferredFont(forTextStyle: .subheadline)
            titleStyle.appearance(for: state).textColor = .secondaryLabel
            titleStyle.setIconColor(.tertiaryLabel, for: state)
        }
        titleStyle.imagePlacement = .trailing
        titleStyle.imageSize = CGSize(width: 12, height: 12)
        titleStyle.imageTitleSpacing = 4
        tagsView.titleStyle = titleStyle
        // A header that opens the editor: VoiceOver reads it as both.
        tagsView.titleView.accessibilityTraits = [.header, .button]
        tagsView.titleView.accessibilityHint = cylContactTagsText("hintEdit")
        let titleTap = UITapGestureRecognizer(target: self, action: #selector(tagsViewTapped(_:)))
        titleTap.cancelsTouchesInView = false
        tagsView.addGestureRecognizer(titleTap)
        tagsView.style = CYLContactTagEditorViewController.tagStyle()
        tagsView.selectionMode = .none
        tagsView.showsSectionHeaders = false
        tagsView.isScrollEnabled = false
        tagsView.menuDataSource = self
        tagsView.menuDelegate = self
        tagsView.accessibilityIdentifier = "CYLContactRemarkTags"

        for subview in [titleLabel, nameField, tagsView] as [UIView] {
            subview.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(subview)
        }
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 36),
            nameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameField.heightAnchor.constraint(greaterThanOrEqualToConstant: 48),
            tagsView.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 12),
            tagsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tagsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // Its height is its intrinsic content height (CYLTagListView.contentHeight).
        ])
        tagsView.reloadMenuData()
        updateEmptyTagsView()
        // `-CYLContactTagsEditor YES` on launch opens the editor, for screenshots.
        if UserDefaults.standard.bool(forKey: "CYLContactTagsEditor") {
            DispatchQueue.main.async { [weak self] in self?.editTags(animated: false) }
        }
    }

    /**
     * Presents "Edit Tags" as a sheet over this screen.
     */
    @discardableResult
    @objc(editTagsAnimated:)
    func editTags(animated: Bool) -> CYLContactTagEditorViewController {
        let editor = CYLContactTagEditorViewController(store: store, selectedTags: tags)
        editor.onDone = { [weak self] tags in
            self?.updateTags(tags)
        }
        // In a navigation controller, so a tag in "Manage" mode can push its contacts (the sheet hides the bar).
        let navigation = UINavigationController(rootViewController: editor)
        navigation.setNavigationBarHidden(true, animated: false)
        navigation.modalPresentationStyle = .pageSheet
        if let sheet = navigation.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [.custom(identifier: .init("tags")) { context in context.maximumDetentValue * 0.78 }, .large()]
            } else {
                sheet.detents = [.large()]
            }
            sheet.preferredCornerRadius = 16
        }
        present(navigation, animated: animated)
        return editor
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Below the "Tags" title, at its content size (`reportsContentSize`, `preferredMaxLayoutWidth`).
        if let placeholder = emptyTagsView {
            let width = view.bounds.width - 32
            placeholder.reportsContentSize = true
            placeholder.preferredMaxLayoutWidth = width
            let size = placeholder.intrinsicContentSize
            placeholder.frame = CGRect(x: 16 + (width - min(size.width, width)) / 2, y: tagsView.frame.maxY + 16,
                                       width: min(size.width, width), height: size.height)
        }
    }

    /**
     * Shows the placeholder while the contact has no tags, and hides it otherwise.
     */
    private func updateEmptyTagsView() {
        if tags.isEmpty, emptyTagsView == nil {
            let placeholder = CYLPlaceholderView(style: .empty, text: cylContactTagsText("remarkNoTags"))
            placeholder.accessibilityIdentifier = "CYLContactRemarkEmptyTags"
            placeholder.isAccessibilityElement = true
            placeholder.accessibilityLabel = cylContactTagsText("remarkNoTags")
            placeholder.accessibilityTraits = .button
            placeholder.accessibilityHint = cylContactTagsText("hintEdit")
            placeholder.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(emptyTagsTapped)))
            view.addSubview(placeholder)
            emptyTagsView = placeholder
        }
        emptyTagsView?.isHidden = !tags.isEmpty
        view.setNeedsLayout()
    }

    @objc private func emptyTagsTapped() {
        editTags(animated: true)
    }

    @objc private func tagsViewTapped(_ recognizer: UITapGestureRecognizer) {
        if tagsView.titleView.bounds.contains(recognizer.location(in: tagsView.titleView)) {
            editTags(animated: true)
        }
    }

    /**
     * Shows `tags` as the contact's tags (the editor's result).
     */
    @objc(updateTags:)
    func updateTags(_ tags: [String]) {
        self.tags = tags
        tagsView.reloadMenuData()
        updateEmptyTagsView()
        view.setNeedsLayout()
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
}

extension CYLContactRemarkViewController: CYLMenuDataSource, CYLMenuDelegate {

    func numberOfSectionsInMenu() -> Int {
        1
    }

    /**
     * The contact's tags; none while it has no tags (the placeholder shows instead).
     */
    func menuNumberOfItems(inSection section: Int) -> Int {
        tags.count
    }

    func menuTitle(forSection section: Int) -> String {
        cylContactTagsText("tags")
    }

    func menuTitleForItem(at indexPath: IndexPath) -> String {
        store.title(of: tags[indexPath.item]) ?? tags[indexPath.item]
    }

    func menu(_ menu: Any, didSelectItemAt indexPath: IndexPath) {
        editTags(animated: true)
    }
}

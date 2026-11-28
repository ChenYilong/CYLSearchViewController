//
//  CYLContactListViewController.swift
//  CYLSearchExample
//
//  The contacts that have a tag: the page a tap on a tag opens in the contact tags demo's "Manage" mode. A tag without
//  contacts (a new one, or one nobody has) shows CYLTableViewPlaceHolder's placeholder in the table (cyl_reloadData).
//

import UIKit
import CYLTableViewPlaceHolder

/**
 * The contacts that have `tag`, in a table; CYLTableViewPlaceHolder's placeholder when there are none.
 */
final class CYLContactListViewController: UITableViewController, CYLTableViewPlaceHolderDelegate {

    /**
     * The tag shown.
     */
    let tag: String

    /**
     * The contacts that have it.
     */
    let contacts: [CYLContactTagData.Contact]

    /**
     * The title of a tag id, for each contact's tags.
     */
    let titleOfTag: (String) -> String?

    /**
     * The contacts page of the tag titled `tag`; `contacts` were found by the tag's id.
     */
    init(tag: String, contacts: [CYLContactTagData.Contact], titleOfTag: @escaping (String) -> String? = { _ in nil }) {
        self.tag = tag
        self.contacts = contacts
        self.titleOfTag = titleOfTag
        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = cylContactTagsText("contactsTitle", tag, contacts.count)
        tableView.accessibilityIdentifier = "CYLContactList"
        // Opaque: inside the sheet a grouped table is clear by default, and the editor would show through.
        view.backgroundColor = .systemGroupedBackground
        tableView.backgroundColor = .systemGroupedBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CYLContact")
        tableView.cyl_reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contacts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CYLContact", for: indexPath)
        var content = UIListContentConfiguration.subtitleCell()
        let contact = contacts[indexPath.row]
        content.text = contact.name
        content.secondaryText = contact.tags.compactMap(titleOfTag).joined(separator: " · ")
        content.secondaryTextProperties.color = .secondaryLabel
        content.image = UIImage(systemName: "person.crop.circle.fill")
        content.imageProperties.tintColor = .systemGray3
        cell.contentConfiguration = content
        cell.selectionStyle = .none
        return cell
    }

    // MARK: - CYLTableViewPlaceHolderDelegate

    /**
     * No contact has the tag: CYLTableViewPlaceHolder's placeholder.
     */
    func makePlaceHolderView() -> UIView {
        let placeholder = CYLPlaceholderView(style: .personOff, text: cylContactTagsText("noContacts", tag))
        placeholder.accessibilityIdentifier = "CYLContactListEmpty"
        return placeholder
    }

    func enableScrollWhenPlaceHolderViewShowing() -> Bool {
        false
    }
}

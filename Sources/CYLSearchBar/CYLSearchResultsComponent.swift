/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

// Ported to Swift for CYLSearchViewController, 2026.
//
//  CYLSearchResultsComponent.swift
//  CYLSearchViewController
//
//  The results and empty-view pieces of the search core, written once (docs/qmui-search-controller.md, "Merge design",
//  row `tableView` / `showEmptyView`, and "Merge phase 3 log"). `CYLSearchView`, `CYLSearchController` and
//  `CYLSearchTableViewController` each own their results table (a table view they create, the table of a results view
//  controller, the table of the screen), so the table is not shared; what they do with it is: the placeholder they show
//  when nothing matches, where it sits, and the match highlight in the result rows.
//

import CYLTableViewPlaceHolder
import ObjectiveC
import UIKit

// MARK: - Empty view

/**
 * The one place that builds the empty view of every results screen: CYLTableViewPlaceHolder's `CYLPlaceholderStackView`.
 */
enum CYLSearchEmptyView {

    /**
     * One of CYLTableViewPlaceHolder's scenarios (the placeholder `CYLSearchView` shows for empty results).
     */
    static func scenario(_ scenario: CYLPlaceholderScenario, identifier: String? = nil) -> CYLPlaceholderStackView {
        let placeholder = CYLPlaceholderStackView(scenario: scenario, actions: nil)
        placeholder.accessibilityIdentifier = identifier
        return placeholder
    }

    /**
     * The "no results" animation with a title, an optional detail and an optional button (QMUI
     * `showEmptyViewWithText:detailText:buttonTitle:buttonAction:`).
     */
    static func message(text: String?, detailText: String?, buttonTitle: String? = nil,
                        buttonAction: (() -> Void)? = nil) -> CYLPlaceholderStackView {
        var components = [CYLPlaceholderComponent(bundledAnimation: "CYLPlaceholderNoResults.json",
                                                  fallbackStyle: .noResults, title: text,
                                                  size: CGSize(width: 96, height: 96), action: nil)]
        if let detailText, !detailText.isEmpty { components.append(CYLPlaceholderComponent.hint(text: detailText)) }
        var handlers: [CYLPlaceholderAction: CYLPlaceholderActionHandler] = [:]
        if let buttonTitle, !buttonTitle.isEmpty {
            components.append(CYLPlaceholderComponent.button(title: buttonTitle, style: .outlined, action: .retry))
            handlers[.retry] = { _, _ in buttonAction?() }
        }
        return CYLPlaceholderStackView(components: components, actions: handlers)
    }
}

/**
 * Holds the empty view of one screen: adopts a view, puts it into a container (once), hides it or takes it away.
 */
final class CYLSearchEmptyViewSlot {

    private(set) var view: UIView?

    /**
     * Whether the view is in a container and not hidden.
     */
    var isShowing: Bool {
        guard let view else { return false }
        return view.superview != nil && !view.isHidden
    }

    /**
     * Makes `newView` the slot's view; the previous one leaves its container. It is not in a container yet.
     */
    func adopt(_ newView: UIView) {
        if view !== newView { view?.removeFromSuperview() }
        view = newView
    }

    /**
     * Puts the view into `container` (below `sibling` when given) unless it is there, and unhides it.
     */
    func show(in container: UIView, below sibling: UIView? = nil) {
        guard let view else { return }
        if view.superview !== container {
            if let sibling { container.insertSubview(view, belowSubview: sibling) } else { container.addSubview(view) }
        }
        view.isHidden = false
    }

    /**
     * Hides the view and keeps it (its styling stays for the next time).
     */
    func hide() {
        view?.isHidden = true
    }

    /**
     * Takes the view out of its container and forgets it.
     */
    func remove() {
        view?.removeFromSuperview()
        view = nil
    }
}

// MARK: - Keyboard

/**
 * How far the keyboard reaches into a host view: the empty view of every results screen ends at the keyboard, so its
 * content centres in the part the keyboard leaves visible (docs/core-todo.md, "the empty-results placeholder sits under
 * the keyboard"). `CYLSearchView` (its page) and `CYLSearchController` (the results view) each own one.
 */
final class CYLSearchKeyboardOverlap: NSObject {

    /**
     * The height of the keyboard's part over the host, 0 while it is down or the host is not in a window. It is worked
     * out when asked, from the last keyboard frame, so a host that appears while the keyboard is up reads it right.
     */
    var overlap: CGFloat {
        guard let host = host(), let window = host.window, let keyboardFrame else { return 0 }
        let local = host.convert(keyboardFrame, from: window.screen.coordinateSpace)
        return max(0, host.bounds.maxY - local.minY)
    }
    private var keyboardFrame: CGRect?
    private let host: () -> UIView?
    private let changed: () -> Void

    init(host: @escaping () -> UIView?, changed: @escaping () -> Void) {
        self.host = host
        self.changed = changed
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChanged(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHidden(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardChanged(_ notification: Notification) {
        keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        changed()
    }

    @objc private func keyboardHidden(_ notification: Notification) {
        keyboardFrame = nil
        changed()
    }
}

// MARK: - Match highlight

/**
 * The match highlight option of the results (`highlightsResultMatches`, `resultMatchHighlightColor`): after the data
 * source configured a result row, the first match of the query in its text takes the highlight color (the tint color
 * when none is set). A case- and diacritic-insensitive match, like the suggestion filter.
 */
struct CYLSearchResultHighlight {

    var isEnabled = false
    var color: UIColor?

    /**
     * Highlights the match of `query` in the text of `cell` (the text label, or the text of a list content
     * configuration). Does nothing while the option is off or the query is empty.
     */
    func apply(to cell: UITableViewCell, query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isEnabled, !trimmed.isEmpty else { return }
        let color = self.color ?? cell.tintColor ?? .systemBlue
        if var content = cell.contentConfiguration as? UIListContentConfiguration {
            let source = content.attributedText ?? content.text.map {
                NSAttributedString(string: $0, attributes: Self.attributes(of: content.textProperties))
            }
            if let highlighted = Self.highlight(source, trimmed, color) {
                content.attributedText = highlighted
                cell.contentConfiguration = content
            }
        } else if let label = cell.textLabel {
            let base = Self.baseColor(of: label)
            let source = label.attributedText.flatMap { $0.length > 0 ? $0 : nil } ?? label.text.map {
                NSAttributedString(string: $0, attributes: [.font: label.font as Any, .foregroundColor: base])
            }
            if let highlighted = Self.highlight(source, trimmed, color) {
                label.attributedText = highlighted
                // UILabel takes its `textColor` from the first character of an attributed text: remember that value as the
                // one that is ours, so a reused label's text is not drawn in the highlight color the next time.
                objc_setAssociatedObject(label, &Self.labelStateKey, LabelState(base: base, synced: label.textColor),
                                         .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }

    private final class LabelState {
        let base: UIColor
        let synced: UIColor
        init(base: UIColor, synced: UIColor) {
            self.base = base
            self.synced = synced
        }
    }

    private static var labelStateKey = 0

    // The text color the data source gave the label: the remembered one while the label still shows the value UIKit
    // took from our own highlight, else its current one.
    private static func baseColor(of label: UILabel) -> UIColor {
        let current = label.textColor ?? .label
        if let state = objc_getAssociatedObject(label, &labelStateKey) as? LabelState, state.synced == current {
            return state.base
        }
        return current
    }

    private static func attributes(of properties: UIListContentConfiguration.TextProperties) -> [NSAttributedString.Key: Any] {
        [.font: properties.font, .foregroundColor: properties.resolvedColor()]
    }

    private static func highlight(_ source: NSAttributedString?, _ query: String, _ color: UIColor) -> NSAttributedString? {
        guard let source,
              let range = source.string.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) else { return nil }
        let text = NSMutableAttributedString(attributedString: source)
        text.addAttribute(.foregroundColor, value: color, range: NSRange(range, in: source.string))
        return text
    }
}

/**
 * The data source of a results table whose owner's own data source configures the rows: it forwards everything to the
 * owner and highlights the match after `cellForRowAt`. `CYLSearchController` puts it in front of its owner while
 * `highlightsResultMatches` is on, so the core can highlight rows it does not configure.
 */
final class CYLSearchResultsDataSourceProxy: NSObject, UITableViewDataSource {

    weak var target: UITableViewDataSource?
    var decorate: ((UITableViewCell) -> Void)?

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        target?.tableView(tableView, numberOfRowsInSection: section) ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = target?.tableView(tableView, cellForRowAt: indexPath) ?? UITableViewCell()
        decorate?(cell)
        return cell
    }

    override func responds(to aSelector: Selector!) -> Bool {
        super.responds(to: aSelector) || target?.responds(to: aSelector) == true
    }

    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        target?.responds(to: aSelector) == true ? target : super.forwardingTarget(for: aSelector)
    }
}

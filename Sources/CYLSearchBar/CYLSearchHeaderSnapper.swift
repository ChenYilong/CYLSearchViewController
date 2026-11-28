//
//  CYLSearchHeaderSnapper.swift
//  CYLSearchViewController
//
//  The #1160 / #1207 handling of a search bar that is a table view's header (docs/qmui-search-controller.md, rows I4 and
//  B10): UIKit's header can stay half visible and, with short content, cannot be scrolled out of sight. This object keeps
//  the header scrollable out of sight and settles it fully shown or fully hidden when a drag ends. It uses public API
//  only and never touches the table view's delegate.
//

import UIKit

/**
 * Keeps a header search bar scrollable and settles it. It adds a bottom inset only as large as the header needs to leave
 * the screen (a table of three rows is shorter than the screen), and settles the header when the drag of the pan gesture
 * recognizer ends. The table view's `delegate` is not replaced or wrapped: the end of the drag is seen through a target
 * on `panGestureRecognizer` (a delegate's `scrollViewWillEndDragging` could only be seen by taking the delegate's
 * place), and the rest offset UIKit would reach is projected from the release velocity with `decelerationRate`.
 */
final class CYLSearchHeaderSnapper: NSObject {

    private(set) weak var tableView: UITableView?
    private weak var searchBar: UIView?
    var header: UIView? { searchBar }
    private let isSearching: () -> Bool
    private var observations: [NSKeyValueObservation] = []
    private var addedBottomInset: CGFloat = 0
    private var appliedBottomInset: CGFloat?

    // Whether the bottom inset and the settling are on; turning it off takes the inset away.
    var isEnabled = true {
        didSet {
            guard isEnabled != oldValue else { return }
            refresh()
        }
    }

    /**
     * Keeps `searchBar`, the header of `tableView`; `isSearching` answers whether the search is presented (the header is
     * then not settled).
     */
    init(tableView: UITableView, searchBar: UIView, isSearching: @escaping () -> Bool) {
        self.tableView = tableView
        self.searchBar = searchBar
        self.isSearching = isSearching
        super.init()
        // Estimated heights make the content size (and so the scroll range of a short list) wrong until rows are
        // measured; QMUI's answer to #1160 is to turn them off.
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        observations = [
            tableView.observe(\.contentSize) { [weak self] _, _ in self?.refresh() },
            tableView.observe(\.bounds) { [weak self] _, _ in self?.refresh() },
        ]
        tableView.panGestureRecognizer.addTarget(self, action: #selector(handlePan(_:)))
        refresh()
    }


    // Removes the inset and the gesture target; the table view is left as it is otherwise.
    func detach() {
        observations = []
        guard let tableView else { return }
        tableView.panGestureRecognizer.removeTarget(self, action: #selector(handlePan(_:)))
        removeAddedInset()
    }

    deinit {
        if let tableView { tableView.panGestureRecognizer.removeTarget(self, action: #selector(handlePan(_:))) }
    }

    // MARK: - Header band

    // The header's height while the bar is the table's header and the search is not presented, else `nil`.
    private var headerHeight: CGFloat? {
        guard let tableView, let searchBar, tableView.tableHeaderView === searchBar,
              !isSearching() else { return nil }
        let height = searchBar.bounds.height
        return height > 0 ? height : nil
    }

    // The offset with the header fully shown, and the one with the header fully hidden.
    private func band(of tableView: UITableView, height: CGFloat) -> (shown: CGFloat, hidden: CGFloat) {
        let shown = -tableView.adjustedContentInset.top
        return (shown, shown + height)
    }

    // MARK: - Bottom inset

    /**
     * Adds the bottom inset the header needs to scroll out of sight: the largest offset
     * (`contentSize.height + adjustedBottom - bounds.height`) must reach the hidden offset. What this object added before
     * is taken out of the sums first, so the inset does not feed itself, and an inset changed by the owner in between is
     * kept as the base.
     */
    func refresh() {
        guard let tableView else { return }
        if let applied = appliedBottomInset, abs(applied - tableView.contentInset.bottom) > 0.5 { addedBottomInset = 0 }
        guard isEnabled, let height = headerHeight, tableView.bounds.height > 0 else {
            // Without the bar as the header (turned off, or hidden while an empty view shows) the inset is not needed.
            if !isEnabled || tableView.tableHeaderView !== searchBar { removeAddedInset() }
            return
        }
        let baseAdjustedBottom = tableView.adjustedContentInset.bottom - addedBottomInset
        let needed = tableView.bounds.height - tableView.adjustedContentInset.top + height - tableView.contentSize.height
            - baseAdjustedBottom
        let extra = max(0, ceil(needed))
        guard abs(extra - addedBottomInset) > 0.5 else { return }
        apply(extra: extra, to: tableView)
    }

    private func apply(extra: CGFloat, to tableView: UITableView) {
        var inset = tableView.contentInset
        inset.bottom = inset.bottom - addedBottomInset + extra
        addedBottomInset = extra
        appliedBottomInset = inset.bottom
        tableView.contentInset = inset
    }

    private func removeAddedInset() {
        guard let tableView, addedBottomInset != 0, appliedBottomInset != nil else { return }
        apply(extra: 0, to: tableView)
    }

    // MARK: - Settling

    /**
     * The offset the header should settle at when a drag ends at `offsetY` with the finger's vertical `velocityY`
     * (points per second, positive moving down), or `nil` when the rest offset is outside the header band (UIKit's own
     * deceleration is left alone) or the header cannot be settled now.
     */
    func settleOffsetY(from offsetY: CGFloat, velocityY: CGFloat) -> CGFloat? {
        guard isEnabled, let tableView, let height = headerHeight else { return nil }
        let band = band(of: tableView, height: height)
        let rate = tableView.decelerationRate.rawValue
        let projected = offsetY - velocityY / 1000 * rate / max(1 - rate, 0.0001)
        guard projected > band.shown + 0.5, projected < band.hidden - 0.5 else { return nil }
        return projected < band.shown + height / 2 ? band.shown : band.hidden
    }

    // Settles the header from the table's current offset (a drag that ends with `velocityY`); returns whether it moves.
    @discardableResult
    func settle(velocityY: CGFloat) -> Bool {
        guard let tableView, let target = settleOffsetY(from: tableView.contentOffset.y, velocityY: velocityY) else {
            return false
        }
        tableView.setContentOffset(CGPoint(x: tableView.contentOffset.x, y: target), animated: true)
        return true
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard gesture.state == .ended, let tableView else { return }
        settle(velocityY: gesture.velocity(in: tableView).y)
    }
}

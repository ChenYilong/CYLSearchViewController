/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

// Ported to Swift for CYLSearchViewController, 2026.
//
//  CYLSearchPresentationState.swift
//  CYLSearchViewController
//
//  The life cycle pieces of the search core, written once (docs/qmui-search-controller.md, "Merge design", rows
//  `dimmingColor`, `isActive` / `setActive` and `supportsSwipeToDismissSearch`, and "Merge phase 3 log"): the dimming
//  overlay (QMUI's replacement of UIDimmingView), the active state with its will / did events, and the rule of the edge
//  swipe that leaves the search. `CYLSearchView` and `CYLSearchController` both use them.
//

import UIKit

// MARK: - Dimming overlay

/**
 * The one overlay that dims what lies behind an open search: `CYLSearchView.scrimColor` and
 * `CYLSearchController.dimmingColor` both set its `color`; a tap on it ends the search (`onTap`).
 */
final class CYLSearchDimmingView: UIControl {

    var onTap: (() -> Void)?

    /**
     * The dimming color; nil is clear.
     */
    var color: UIColor? {
        didSet { backgroundColor = color ?? .clear }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        accessibilityIdentifier = "CYLSearchDimmingView"
        isAccessibilityElement = false
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        nil
    }

    @objc private func tapped() {
        onTap?()
    }
}

// MARK: - Active state

/**
 * The four moments of presenting and dismissing a search (QMUI's will / did present and dismiss).
 */
enum CYLSearchPresentationEvent {
    case willPresent
    case didPresent
    case willDismiss
    case didDismiss
}

/**
 * The active state of a search, one for both classes. `send(_:)` is the one event source: it moves the phase and tells
 * `onEvent`, which each class maps to its own delegate (`CYLSearchViewDelegate`, `CYLSearchControllerDelegate`).
 * `CYLSearchView` sends the events itself; `CYLSearchController` forwards what UIKit's `UISearchController` reports,
 * because UIKit alone presents that controller (Cancel, a tap in the bar, a navigation item).
 */
final class CYLSearchPresentationState {

    enum Phase {
        case inactive
        case presenting
        case active
        case dismissing
    }

    private(set) var phase = Phase.inactive
    /**
     * Counts the moments the search began presenting or dismissing: an animation completion that finds a newer count has
     * been overtaken (a show during a close) and leaves the view alone.
     */
    private(set) var generation = 0
    var onEvent: ((CYLSearchPresentationEvent) -> Void)?

    /**
     * Whether the search is on its way in or in: from the start of presenting to the start of dismissing.
     */
    var isActive: Bool {
        phase == .presenting || phase == .active
    }

    func send(_ event: CYLSearchPresentationEvent) {
        switch event {
        case .willPresent:
            phase = .presenting
            generation += 1
        case .didPresent:
            if phase == .presenting { phase = .active }
        case .willDismiss:
            phase = .dismissing
            generation += 1
        case .didDismiss:
            phase = .inactive
        }
        onEvent?(event)
    }
}

// MARK: - Edge swipe

/**
 * What both classes share of the swipe from the left edge that ends the search (QMUI `supportsSwipeToDismissSearch`):
 * the gesture, the rule that decides between leaving and coming back, and the duration of the animations.
 */
enum CYLSearchEdgeSwipe {

    /**
     * The recognizer for a swipe from the left screen edge.
     */
    static func makeGesture(target: Any, action: Selector, delegate: UIGestureRecognizerDelegate? = nil)
        -> UIScreenEdgePanGestureRecognizer {
        let gesture = UIScreenEdgePanGestureRecognizer(target: target, action: action)
        gesture.edges = .left
        gesture.delegate = delegate
        return gesture
    }

    /**
     * The swipe leaves the search when the page was dragged past a quarter of the width, moving right.
     */
    static func completes(offset: CGFloat, width: CGFloat, velocity: CGFloat) -> Bool {
        width > 0 && offset > width / 4 && velocity > 0
    }

    /**
     * The length of the animation that covers `distance` of `width`: 0.2 seconds for the whole width.
     */
    static func duration(distance: CGFloat, width: CGFloat) -> TimeInterval {
        0.2 * TimeInterval(distance / max(width, 1))
    }
}

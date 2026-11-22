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
import UIKit.UIGestureRecognizerSubclass

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

/**
 * A `UIScreenEdgePanGestureRecognizer` that decides by itself whether a touch is a swipe from the left edge.
 *
 * UIKit's own recognizer never left the possible state while a `UISearchController` was active (iOS 17.5 and 27.2: it
 * received the touch, a plain pan recognizer on the same view began, `gestureRecognizerShouldBegin` was never asked),
 * so `supportsSwipeToDismissSearch` did not start by touch. This one keeps the type (the public property keeps
 * `UIScreenEdgePanGestureRecognizer`, `edges` stays `.left`) and follows the touch: it begins when the touch went down
 * within `edgeWidth` points of the left edge of the window and moved right past the slop, more than it moved up or down.
 */
final class CYLSearchEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer {

    /**
     * The width of the strip at the left edge of the window where a swipe may start, in points.
     */
    static let edgeWidth: CGFloat = 24

    /**
     * How far the touch must move before the swipe begins, in points.
     */
    static let slop: CGFloat = 10

    private weak var tracked: UITouch?
    private var origin = CGPoint.zero
    private var current = CGPoint.zero
    private var lastSample = (point: CGPoint.zero, time: TimeInterval(0))
    private var smoothedVelocity = CGPoint.zero

    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        maximumNumberOfTouches = 1
    }

    // MARK: Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        guard tracked == nil, touches.count == 1, let touch = touches.first else {
            state = .failed
            return
        }
        let point = touch.location(in: nil)
        guard point.x <= Self.edgeWidth else {
            state = .failed
            return
        }
        tracked = touch
        origin = point
        current = point
        lastSample = (point, touch.timestamp)
        smoothedVelocity = .zero
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let touch = tracked, touches.contains(touch) else { return }
        let point = touch.location(in: nil)
        let elapsed = touch.timestamp - lastSample.time
        if elapsed > 0 {
            let instant = CGPoint(x: (point.x - lastSample.point.x) / CGFloat(elapsed),
                                  y: (point.y - lastSample.point.y) / CGFloat(elapsed))
            smoothedVelocity = CGPoint(x: smoothedVelocity.x * 0.5 + instant.x * 0.5,
                                       y: smoothedVelocity.y * 0.5 + instant.y * 0.5)
            lastSample = (point, touch.timestamp)
        }
        current = point
        switch state {
        case .possible:
            switch Self.verdict(from: origin, to: point) {
            case .fails: state = .failed
            case .begins: state = .began
            case .undecided: break
            }
        case .began, .changed:
            state = .changed
        default:
            break
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let touch = tracked, touches.contains(touch) else { return }
        current = touch.location(in: nil)
        state = state == .possible ? .failed : .ended
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let touch = tracked, touches.contains(touch) else { return }
        state = state == .possible ? .failed : .cancelled
    }

    override func reset() {
        tracked = nil
        smoothedVelocity = .zero
    }

    // MARK: Rule

    /**
     * What a touch that went down at `origin` and is now at `point` is: still undecided, a swipe to the right that
     * begins, or something else that fails (up, down or left).
     */
    enum Verdict {
        case undecided, begins, fails
    }

    static func verdict(from origin: CGPoint, to point: CGPoint) -> Verdict {
        let dx = point.x - origin.x
        let dy = point.y - origin.y
        if abs(dy) > slop && abs(dy) > abs(dx) || dx < -slop { return .fails }
        if dx > slop && abs(dx) > abs(dy) { return .begins }
        return .undecided
    }

    // MARK: Measures

    override func translation(in view: UIView?) -> CGPoint {
        CGPoint(x: current.x - origin.x, y: current.y - origin.y)
    }

    override func velocity(in view: UIView?) -> CGPoint {
        smoothedVelocity
    }

    override func location(in view: UIView?) -> CGPoint {
        guard let view else { return current }
        return view.convert(current, from: nil)
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
        let gesture = CYLSearchEdgePanGestureRecognizer(target: target, action: action)
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

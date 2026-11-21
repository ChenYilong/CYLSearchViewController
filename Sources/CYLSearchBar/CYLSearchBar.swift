/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

// Ported to Swift for CYLSearchViewController, 2026.
//
//  CYLSearchBar.swift
//  CYLSearchViewController
//
//  QMUISearchBar and the members of UISearchBar (QMUI) as one UISearchBar subclass. QMUI hooks private classes and
//  selectors; here the subclass overrides layoutSubviews / didMoveToWindow and uses the public API (searchTextField,
//  setPositionAdjustment(_:for:), setSearchFieldBackgroundImage(_:for:), ...). No swizzling, no private names.
//  docs/qmui-search-controller.md, rows B1 to B13.
//

import UIKit

/**
 * A `UISearchBar` that is styled by `CYLSearchBarAppearance` and adds what QMUI's `QMUISearchBar` and its
 * `UISearchBar (QMUI)` category add: a centered placeholder, placeholder / text colors and fonts, margins of the text field
 * and the Cancel button (per state), leading and trailing accessory views, an always enabled Cancel button, the bar's
 * background view and scope bar, and the fixes for `UISearchBar` quirks (the placeholder color lost when the bar moves
 * to a window, a text field frame that UIKit sets again).
 */
@objc(CYLSearchBar)
open class CYLSearchBar: UISearchBar {

    // MARK: - Style

    /**
     * The style applied to the bar (copied from `CYLSearchBarAppearance.defaultAppearance` when the bar is created).
     * Assigning a style applies it.
     */
    @objc public var appearanceStyle: CYLSearchBarAppearance = CYLSearchBarAppearance.default.copy() as? CYLSearchBarAppearance
        ?? CYLSearchBarAppearance() {
        didSet { applyAppearance(appearanceStyle) }
    }

    /**
     * Whether the bar is a table view's header view (QMUI `qmui_usedAsTableHeaderView`). Set by the screens that install
     * the bar as a header; default `false`. UIKit's header quirks of QMUI (#233, #830, #950, #1207, #1473) were checked on
     * iOS 27 (docs/qmui-search-controller.md, rows B7 to B9) and need no fix here.
     */
    @objc public var usedAsTableHeaderView = false

    /**
     * Whether the magnifier and the placeholder are centered in the field while the bar is not editing and has no text
     * (QMUI `qmui_centerPlaceholder`). Default `false`.
     */
    @objc public var centersPlaceholder = false {
        didSet {
            if !centersPlaceholder { setPositionAdjustment(.zero, for: .search) }
            setNeedsLayout()
        }
    }

    /**
     * The placeholder's color (QMUI `qmui_placeholderColor`); kept when the bar moves to a window and when the placeholder
     * changes.
     */
    @objc public var placeholderColor: UIColor? {
        didSet { applyPlaceholderStyle() }
    }

    /**
     * The color of the typed text (QMUI `qmui_textColor`).
     */
    @objc public var textColor: UIColor? {
        didSet {
            // Assigning nil to UIKit's own property is avoided: the field keeps its default look.
            if let textColor { searchTextField.textColor = textColor } else if oldValue != nil { searchTextField.textColor = .label }
        }
    }

    /**
     * The font of the typed text and of the placeholder (QMUI `qmui_font`).
     */
    @objc public var font: UIFont? {
        didSet {
            if let font { searchTextField.font = font } else if oldValue != nil {
                searchTextField.font = UIFont.preferredFont(forTextStyle: .body)
            }
            applyPlaceholderStyle()
            setNeedsLayout()
        }
    }

    // MARK: - Layout

    /**
     * The margins added to the text field's frame (QMUI `qmui_textFieldMargins`), on top of UIKit's own (10, 8, 10, 8). A
     * positive value shrinks the field, a negative one grows it.
     */
    @objc public var textFieldMargins: UIEdgeInsets = .zero {
        didSet { relayoutControls() }
    }

    /**
     * Returns the margins of the text field for the bar's state (`true` while searching); wins over `textFieldMargins`
     * (QMUI `qmui_textFieldMarginsBlock`).
     */
    @objc public var textFieldMarginsProvider: ((CYLSearchBar, Bool) -> UIEdgeInsets)? {
        didSet { relayoutControls() }
    }

    /**
     * The Cancel button, `nil` until UIKit creates it (QMUI `qmui_cancelButton`, found among the text field's siblings
     * without private keys). Its Objective-C name is `cyl_cancelButton`: `UISearchBar` itself answers `cancelButton`.
     */
    @objc(cyl_cancelButton)
    public var cancelButton: UIButton? {
        searchTextField.superview?.subviews.lazy.compactMap { $0 as? UIButton }.first {
            $0 !== leadingAccessoryView && $0 !== trailingAccessoryView
        }
    }

    /**
     * The font of the Cancel button's title (QMUI `qmui_cancelButtonFont`). iOS 26 and later draw an xmark without a title,
     * where it has no visible effect.
     */
    @objc public var cancelButtonFont: UIFont? {
        didSet { applyCancelButtonStyle() }
    }

    /**
     * Returns the margins applied to the Cancel button's frame for the bar's state (`true` while searching); a negative
     * left value moves it left and widens it (QMUI `qmui_cancelButtonMarginsBlock`).
     */
    @objc public var cancelButtonMarginsProvider: ((CYLSearchBar, Bool) -> UIEdgeInsets)? {
        didSet { relayoutControls() }
    }

    /**
     * Whether the Cancel button stays enabled although the keyboard is down (QMUI `qmui_alwaysEnableCancelButton`). Only
     * a bar without a `searchController` does this: UIKit disables Cancel when editing ends. Default `true`.
     */
    @objc public var alwaysEnablesCancelButton = true {
        didSet { enableCancelButtonIfNeeded() }
    }

    /**
     * The view that draws the bar's background, found without private names (QMUI `qmui_backgroundView`); `nil` when
     * UIKit has not built it.
     */
    @objc public var backgroundView: UIView? {
        guard let container = searchTextField.superview else { return nil }
        return container.superview?.subviews.first { $0 !== container && !searchTextField.isDescendant(of: $0) }
    }

    /**
     * The scope bar, a `UISegmentedControl` inside the bar (QMUI `qmui_segmentedControl`); `nil` without scope titles.
     */
    @objc public var segmentedControl: UISegmentedControl? {
        Self.firstSubview(of: UISegmentedControl.self, in: self)
    }

    /**
     * The `UISearchController` the bar belongs to (QMUI `qmui_searchController`), set by `CYLSearchController`;
     * `nil` for a bar used on its own.
     */
    @objc public internal(set) weak var searchController: UISearchController?

    // MARK: - Accessory views

    /**
     * The view left of the text field (QMUI `qmui_leftAccessoryView`), added next to the field and sized to fit.
     */
    @objc public var leadingAccessoryView: UIView? {
        didSet { accessoryDidChange(from: oldValue, to: leadingAccessoryView, shows: showsLeadingAccessoryView) }
    }

    /**
     * Whether the leading accessory view is shown (QMUI `qmui_showsLeftAccessoryView`), without animation. Default `true`.
     */
    @objc public var showsLeadingAccessoryView: Bool {
        get { leadingShows }
        set { setShowsLeadingAccessoryView(newValue, animated: false) }
    }

    /**
     * The space around the leading accessory view; `right` is the gap to the text field.
     */
    @objc public var leadingAccessoryViewMargins: UIEdgeInsets = .zero {
        didSet { updateAccessoryMargins() }
    }

    /**
     * The view right of the text field (QMUI `qmui_rightAccessoryView`), added next to the field and sized to fit.
     */
    @objc public var trailingAccessoryView: UIView? {
        didSet { accessoryDidChange(from: oldValue, to: trailingAccessoryView, shows: showsTrailingAccessoryView) }
    }

    /**
     * Whether the trailing accessory view is shown (QMUI `qmui_showsRightAccessoryView`), without animation. Default
     * `true`.
     */
    @objc public var showsTrailingAccessoryView: Bool {
        get { trailingShows }
        set { setShowsTrailingAccessoryView(newValue, animated: false) }
    }

    /**
     * The space around the trailing accessory view; `left` is the gap to the text field.
     */
    @objc public var trailingAccessoryViewMargins: UIEdgeInsets = .zero {
        didSet { updateAccessoryMargins() }
    }

    // MARK: - Private state

    private struct TrackedFrame {
        var base: CGRect
        var adjusted: CGRect
    }

    private struct CenteredPlaceholder {
        var fieldWidth: CGFloat
        var textWidth: CGFloat
        var iconMinX: CGFloat
    }

    private static let defaultTextFieldSideMargin: CGFloat = 8
    private static let accessoryAnimationDuration: TimeInterval = 0.25

    private var leadingShows = true
    private var trailingShows = true
    private var customTextFieldMargins = UIEdgeInsets.zero
    private var fieldFrame: TrackedFrame?
    private var cancelFrame: TrackedFrame?
    private weak var boundCancelButton: UIButton?
    private var fieldObservation: NSKeyValueObservation?
    private var cancelObservations: [NSKeyValueObservation] = []
    private var isApplyingPlaceholder = false
    private var centeredPlaceholder: CenteredPlaceholder?
    private var lastInterfaceStyle = UIUserInterfaceStyle.unspecified
    private static var cachedFieldHeight: CGFloat = 0

    // MARK: - Initializers

    /**
     * Creates a bar styled with the default appearance. An empty frame is sized with `sizeToFit()` (QMUI: the frame was
     * empty when the bar was created by code).
     */
    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    /**
     * Creates a bar from an archive or a storyboard, styled with the default appearance.
     */
    @objc public required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }

    private func sharedInit() {
        // Autocorrection and capitalization off: what qmui_styledAsQMUISearchBar sets.
        autocorrectionType = .no
        autocapitalizationType = .none
        applyDefaultAppearance()
        let center = NotificationCenter.default
        for name in [UITextField.textDidBeginEditingNotification, UITextField.textDidEndEditingNotification,
                     UITextField.textDidChangeNotification] {
            center.addObserver(self, selector: #selector(fieldEditingDidChange), name: name, object: searchTextField)
        }
        if frame.isEmpty { sizeToFit() }
    }

    /**
     * Applies `CYLSearchBarAppearance.defaultAppearance` (QMUI `qmui_styledAsQMUISearchBar`).
     */
    @objc open func applyDefaultAppearance() {
        appearanceStyle = CYLSearchBarAppearance.default.copy() as? CYLSearchBarAppearance ?? CYLSearchBarAppearance()
    }

    // MARK: - UISearchBar

    public override var placeholder: String? {
        didSet {
            applyPlaceholderStyle()
            setNeedsLayout()
        }
    }

    public override var text: String? {
        didSet { setNeedsLayout() }
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        // iOS 13 resets the placeholder label when the bar moves to a window (QMUI issue #830): apply it again.
        applyPlaceholderStyle()
        if font != nil { searchTextField.font = font }
        if let textColor { searchTextField.textColor = textColor }
        setNeedsLayout()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        applyInterfaceStyleChangeIfNeeded()
        bindControls()
        adjustTextFieldFrame()
        adjustCancelButtonFrame()
        positionAccessoryViews()
        updateCenteredPlaceholder()
    }

    // MARK: - Accessory views: show and hide

    /**
     * Shows or hides the leading accessory view, optionally sliding it in from or out to the left edge (QMUI
     * `qmui_setShowsLeftAccessoryView:animated:`). Toggling quickly ends in the last requested state.
     */
    @objc public func setShowsLeadingAccessoryView(_ shows: Bool, animated: Bool) {
        leadingShows = shows
        guard let view = leadingAccessoryView else { return }
        if animated {
            if shows {
                view.isHidden = false
                view.center = CGPoint(x: -view.bounds.width / 2, y: view.center.y)
                UIView.animate(withDuration: Self.accessoryAnimationDuration, delay: 0, options: .curveEaseInOut) {
                    self.updateAccessoryMargins()
                }
            } else {
                UIView.animate(withDuration: Self.accessoryAnimationDuration, delay: 0, options: .curveEaseInOut, animations: {
                    view.transform = CGAffineTransform(translationX: -view.frame.maxX, y: 0)
                    self.updateAccessoryMargins()
                }, completion: { _ in
                    // Toggling quickly between show and hide leaves a wrong state: only hide for the latest request.
                    if shows == self.leadingShows { view.isHidden = true }
                    view.transform = .identity
                })
            }
        } else {
            view.isHidden = !shows
            updateAccessoryMargins()
        }
    }

    /**
     * Shows or hides the trailing accessory view, optionally sliding it in from or out to the right edge (QMUI
     * `qmui_setShowsRightAccessoryView:animated:`). Toggling quickly ends in the last requested state.
     */
    @objc public func setShowsTrailingAccessoryView(_ shows: Bool, animated: Bool) {
        trailingShows = shows
        guard let view = trailingAccessoryView else { return }
        if animated {
            // The accessory flies in from the Cancel button, so the two overlap for a moment: fade it as well.
            let fades = showsCancelButton
            if shows {
                view.isHidden = false
                view.center = CGPoint(x: bounds.width + view.bounds.width / 2, y: view.center.y)
                if fades { view.alpha = 0 }
                UIView.animate(withDuration: Self.accessoryAnimationDuration, delay: 0, options: .curveEaseInOut) {
                    self.updateAccessoryMargins()
                    if fades { view.alpha = 1 }
                }
            } else {
                UIView.animate(withDuration: Self.accessoryAnimationDuration, delay: 0, options: .curveEaseInOut, animations: {
                    view.transform = CGAffineTransform(translationX: bounds.width - view.frame.minX, y: 0)
                    self.updateAccessoryMargins()
                }, completion: { _ in
                    if shows == self.trailingShows { view.isHidden = true }
                    view.transform = .identity
                    view.alpha = 1
                })
                if fades {
                    UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseIn) { view.alpha = 0 }
                }
            }
        } else {
            view.isHidden = !shows
            updateAccessoryMargins()
        }
    }

    // MARK: - Image generators

    /**
     * Returns a resizable image of a text field in `color`, as the field's background image (QMUI
     * `qmui_generateTextFieldBackgroundImageWithColor:`). The image's height decides the field's height, so it is
     * UIKit's default field height, measured once. The corners are rounded by the field, not by the image.
     */
    @objc public static func textFieldBackgroundImage(color: UIColor?) -> UIImage? {
        guard let color else { return nil }
        let size = CGSize(width: 60, height: defaultTextFieldHeight())
        let image = UIGraphicsImageRenderer(size: size).image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
        return image.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }

    /**
     * Returns a resizable image for the bar's background: `color` (white by default) with a one pixel bottom border in
     * `borderColor`, or `nil` when both are `nil` (QMUI `qmui_generateBackgroundImageWithColor:borderColor:`).
     */
    @objc public static func backgroundImage(color: UIColor?, borderColor: UIColor?) -> UIImage? {
        guard color != nil || borderColor != nil else { return nil }
        let size = CGSize(width: 10, height: 10)
        let format = UIGraphicsImageRendererFormat.preferred()
        let image = UIGraphicsImageRenderer(size: size, format: format).image { context in
            (color ?? .white).setFill()
            context.fill(CGRect(origin: .zero, size: size))
            if let borderColor {
                let line = 1 / max(format.scale, 1)
                borderColor.setFill()
                context.fill(CGRect(x: 0, y: size.height - line, width: size.width, height: line))
            }
        }
        return image.resizableImage(withCapInsets: UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1))
    }

    // MARK: - Appearance

    private func applyAppearance(_ style: CYLSearchBarAppearance) {
        font = style.font
        textColor = style.textColor
        placeholderColor = style.placeholderColor
        if let placeholderText = style.placeholder { placeholder = placeholderText }
        tintColor = style.tintColor
        if style.searchIconImage != nil || image(for: .search, state: .normal) != nil {
            setImage(style.searchIconImage, for: .search, state: .normal)
        }
        if style.clearIconImage != nil || image(for: .clear, state: .normal) != nil {
            setImage(style.clearIconImage, for: .clear, state: .normal)
        }
        applyFieldAndBarBackground(style)
        applyCancelButtonStyle()
        setNeedsLayout()
    }

    private func applyFieldAndBarBackground(_ style: CYLSearchBarAppearance) {
        lastInterfaceStyle = traitCollection.userInterfaceStyle
        let fieldColor = style.textFieldBackgroundColor?.resolvedColor(with: traitCollection)
        let fieldImage = style.textFieldBackgroundImage ?? Self.textFieldBackgroundImage(color: fieldColor)
        setSearchFieldBackgroundImage(fieldImage, for: .normal)
        let borderWidth = 1 / max(UIGraphicsImageRendererFormat.preferred().scale, 1)
        searchTextField.layer.borderWidth = style.textFieldBorderColor == nil ? 0 : borderWidth
        searchTextField.layer.borderColor = style.textFieldBorderColor?.resolvedColor(with: traitCollection).cgColor

        // A background image instead of barTintColor, so the bottom border's color can change as well.
        var background = style.barBackgroundImage
        if background == nil {
            background = Self.backgroundImage(
                color: style.barBackgroundColor?.resolvedColor(with: traitCollection),
                borderColor: style.barBorderColor?.resolvedColor(with: traitCollection))
        }
        if background == nil && style.hidesBarBackground { background = UIImage() }
        setBackgroundImage(background, for: .any, barMetrics: .default)
        setBackgroundImage(background, for: .any, barMetrics: .defaultPrompt)
    }

    private func applyInterfaceStyleChangeIfNeeded() {
        // The generated images hold resolved colors: draw them again when light and dark mode switch.
        if lastInterfaceStyle != traitCollection.userInterfaceStyle { applyFieldAndBarBackground(appearanceStyle) }
    }

    private func applyPlaceholderStyle() {
        guard !isApplyingPlaceholder, placeholderColor != nil || font != nil,
              let text = placeholder, !text.isEmpty else { return }
        isApplyingPlaceholder = true
        defer { isApplyingPlaceholder = false }
        var attributes: [NSAttributedString.Key: Any] = [.foregroundColor: placeholderColor ?? UIColor.placeholderText]
        if let font { attributes[.font] = font }
        searchTextField.attributedPlaceholder = NSAttributedString(string: text, attributes: attributes)
    }

    private func applyCancelButtonStyle() {
        guard let button = cancelButton else { return }
        if let cancelButtonFont {
            button.titleLabel?.font = cancelButtonFont
            if var configuration = button.configuration {
                let titleFont = cancelButtonFont
                configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
                    var attributes = attributes
                    attributes.font = titleFont
                    return attributes
                }
                button.configuration = configuration
            }
        }
        if let title = appearanceStyle.cancelTitle, !title.isEmpty {
            button.accessibilityLabel = title
            if button.title(for: .normal) != nil { button.setTitle(title, for: .normal) }
        }
    }

    private static func defaultTextFieldHeight() -> CGFloat {
        if cachedFieldHeight == 0 {
            // UIKit's field height depends on the system (36 before iOS 26, 44 after): measure a plain bar once.
            let probe = UISearchBar(frame: CGRect(x: 0, y: 0, width: 320, height: 56))
            probe.layoutIfNeeded()
            let height = probe.searchTextField.frame.height
            cachedFieldHeight = height > 0 ? height : 36
        }
        return cachedFieldHeight
    }

    // MARK: - Layout

    private var isSearchActive: Bool {
        searchController?.isActive ?? searchTextField.isEditing
    }

    private func relayoutControls() {
        setNeedsLayout()
        layoutIfNeeded()
    }

    @objc private func fieldEditingDidChange() {
        setNeedsLayout()
    }

    private func bindControls() {
        if fieldObservation == nil {
            // UIKit sets the field's frame again after layoutSubviews (QMUI hooks setFrame: for this): adjust it as soon as
            // it changes, and lay the rest out for the new size.
            fieldObservation = searchTextField.observe(\.frame) { [weak self] _, _ in
                self?.adjustTextFieldFrame()
                self?.setNeedsLayout()
            }
        }
        let button = cancelButton
        if button !== boundCancelButton {
            cancelObservations = []
            cancelFrame = nil
            boundCancelButton = button
            if let button {
                cancelObservations = [
                    button.observe(\.frame) { [weak self] _, _ in self?.adjustCancelButtonFrame() },
                    button.observe(\.isEnabled) { [weak self] _, _ in self?.enableCancelButtonIfNeeded() },
                ]
                applyCancelButtonStyle()
                enableCancelButtonIfNeeded()
            }
        }
    }

    /**
     * The frame UIKit chose: the current frame, unless it is the one this bar set last (then UIKit did not touch it).
     */
    private func baseFrame(of view: UIView, tracked: TrackedFrame?) -> CGRect {
        if let tracked, view.frame == tracked.adjusted { return tracked.base }
        return view.frame
    }

    private func adjustTextFieldFrame() {
        let field = searchTextField
        // Mid-animation widths can be zero or negative; wait for a real frame.
        guard field.bounds.size.width > 0, field.bounds.size.height > 0 else { return }
        let current = field.frame
        let base = baseFrame(of: field, tracked: fieldFrame)
        let margins = textFieldMarginsProvider?(self, isSearchActive) ?? textFieldMargins
        var frame = base
        if margins != .zero { frame = frame.inset(by: margins) }
        if customTextFieldMargins != .zero { frame = frame.inset(by: customTextFieldMargins) }
        fieldFrame = TrackedFrame(base: base, adjusted: frame)
        if frame != current { field.frame = frame }

        let radius = appearanceStyle.textFieldCornerRadius
        let cornerRadius = radius < 0 ? field.frame.height / 2 : radius
        if radius != 0 {
            field.layer.cornerRadius = cornerRadius
            field.clipsToBounds = true
        }
        positionAccessoryViews()
    }

    private func adjustCancelButtonFrame() {
        guard let button = cancelButton, button.bounds.size.width > 0 else { return }
        let current = button.frame
        let base = baseFrame(of: button, tracked: cancelFrame)
        var frame = base
        if let margins = cancelButtonMarginsProvider?(self, isSearchActive), margins != .zero {
            frame = frame.inset(by: margins)
        }
        cancelFrame = TrackedFrame(base: base, adjusted: frame)
        if frame != current { button.frame = frame }
    }

    private func enableCancelButtonIfNeeded() {
        guard alwaysEnablesCancelButton, searchController == nil, let button = cancelButton, !button.isEnabled else { return }
        button.isEnabled = true
    }

    // MARK: - Centered placeholder

    private func updateCenteredPlaceholder() {
        guard centersPlaceholder else {
            centeredPlaceholder = nil
            return
        }
        let field = searchTextField
        // Some intermediate states give the field a negative width; bounds.size.width keeps the sign, frame.width does not.
        guard field.bounds.size.width > 0 else { return }
        if field.isEditing || !(field.text ?? "").isEmpty {
            centeredPlaceholder = nil
            if positionAdjustment(for: .search) != .zero {
                setPositionAdjustment(.zero, for: .search)
                // Applied at once, so the switch between searching and not searching animates.
                field.setNeedsLayout()
                field.layoutIfNeeded()
            }
            return
        }
        guard let text = placeholder, !text.isEmpty else { return }
        field.layoutIfNeeded()
        let textFont = font ?? field.font ?? UIFont.preferredFont(forTextStyle: .body)
        let textWidth = ceil((text as NSString).size(withAttributes: [.font: textFont]).width)
        let fieldWidth = field.bounds.size.width
        // Nothing changed since the icon was placed: leave it.
        if let state = centeredPlaceholder, state.fieldWidth == fieldWidth, state.textWidth == textWidth,
           let icon = field.leftView, abs(icon.frame.minX - state.iconMinX) <= 1 { return }

        // positionAdjustment moves the icon from UIKit's own place, so measure that place with no adjustment first.
        setPositionAdjustment(.zero, for: .search)
        field.setNeedsLayout()
        field.layoutIfNeeded()
        guard let icon = field.leftView else { return }
        // The placeholder label is as wide as the free space, so the block is measured from its text: icon, gap, text.
        let gap = Self.placeholderLabel(in: field).map { $0.frame.minX - icon.frame.maxX } ?? 6
        let contentWidth = icon.frame.width + gap + textWidth
        let baseline = icon.frame.minX
        let horizontal = max(0, (fieldWidth - contentWidth) / 2 - baseline)
        if horizontal > 0 {
            setPositionAdjustment(UIOffset(horizontal: horizontal, vertical: 0), for: .search)
            field.setNeedsLayout()
            field.layoutIfNeeded()
        }
        centeredPlaceholder = CenteredPlaceholder(fieldWidth: fieldWidth, textWidth: textWidth, iconMinX: baseline + horizontal)
    }

    private static func placeholderLabel(in field: UISearchTextField) -> UILabel? {
        field.subviews.lazy.compactMap { $0 as? UILabel }.first
    }

    private static func firstSubview<T: UIView>(of type: T.Type, in view: UIView) -> T? {
        for subview in view.subviews {
            if let match = subview as? T { return match }
            if let match = firstSubview(of: type, in: subview) { return match }
        }
        return nil
    }

    // MARK: - Accessory layout

    private func accessoryDidChange(from old: UIView?, to new: UIView?, shows: Bool) {
        guard old !== new else { return }
        old?.removeFromSuperview()
        if let new {
            searchTextField.superview?.addSubview(new)
            new.isHidden = !shows
            new.sizeToFit()
        }
        updateAccessoryMargins()
    }

    /**
     * Recomputes the space the accessory views take from the text field. The flags decide, not `isHidden`: during an
     * animation `isHidden` is not updated yet.
     */
    private func updateAccessoryMargins() {
        let leading = leadingShows && leadingAccessoryView != nil
            ? leadingAccessoryView!.frame.width + leadingAccessoryViewMargins.left + leadingAccessoryViewMargins.right : 0
        let trailing = trailingShows && trailingAccessoryView != nil
            ? trailingAccessoryView!.frame.width + trailingAccessoryViewMargins.left + trailingAccessoryViewMargins.right : 0
        guard customTextFieldMargins.left != leading || customTextFieldMargins.right != trailing else { return }
        customTextFieldMargins = UIEdgeInsets(top: customTextFieldMargins.top, left: leading,
                                              bottom: customTextFieldMargins.bottom, right: trailing)
        relayoutControls()
    }

    /**
     * Places the accessory views next to the text field, centered on it. The position follows the frame UIKit chose for
     * the field, so the user's margins move the field only. Set through `center`: a frame is undefined under the slide
     * transform.
     */
    private func positionAccessoryViews() {
        guard let base = fieldFrame?.base, let container = searchTextField.superview else { return }
        let midY = searchTextField.frame.midY
        if let view = leadingAccessoryView {
            if view.superview !== container { container.addSubview(view) }
            if !view.isHidden {
                let x = base.minX - Self.defaultTextFieldSideMargin + leadingAccessoryViewMargins.left
                view.center = CGPoint(x: x + view.bounds.width / 2, y: midY)
            }
        }
        if let view = trailingAccessoryView {
            if view.superview !== container { container.addSubview(view) }
            if !view.isHidden {
                let x = base.maxX + Self.defaultTextFieldSideMargin - view.bounds.width - trailingAccessoryViewMargins.right
                view.center = CGPoint(x: x + view.bounds.width / 2, y: midY)
            }
        }
    }
}

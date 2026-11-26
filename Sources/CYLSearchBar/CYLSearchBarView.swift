// CYLAnimatedItemView, the base class of the bar items (through CollectionViewClassifyMenu's CYLTagButton). Swift Package
// Manager still compiles it into the CYLTabBarController module, where it is reached through CollectionViewClassifyMenu.
#if canImport(CYLAnimatedItem)
import CYLAnimatedItem
import CYLDeallocBlockExecutor
#endif
import CollectionViewClassifyMenu
import UIKit

/**
 * What a `CYLSearchBarView` holds: one field, or several searches side by side.
 */
@objc(CYLSearchBarMode)
public enum CYLSearchBarMode: Int {
    /**
     * One search field (the default).
     */
    case single
    /**
     * Several searches side by side (iammert `MultiSearchView`): `newSearchButton` starts a new search, a completed
     * search becomes an entry of `searches` in a horizontally scrolling row, with an indicator under the selected one
     * and a remove button on it. Use it to search by several categories at once.
     */
    case multiple
}

/**
 * The icon of the navigation button before the field (lapism `NavigationIconCompat`).
 */
@objc(CYLSearchBarNavigationIcon)
public enum CYLSearchBarNavigationIcon: Int {
    /**
     * No navigation button.
     */
    case none
    /**
     * A back arrow (`chevron.backward`).
     */
    case arrow
    /**
     * A magnifier (`magnifyingglass`).
     */
    case search
}

/**
 * Where the search button sits while the bar is iconified.
 */
@objc(CYLSearchBarIconPosition)
public enum CYLSearchBarIconPosition: Int {
    /**
     * At the trailing end, like an Android `SearchView` in a toolbar.
     */
    case trailing
    /**
     * In the middle, like a floating action button that opens a search card.
     */
    case center
    /**
     * At the leading end.
     */
    case leading
}

/**
 * How the field opens and closes when `iconified` changes with animation.
 */
@objc(CYLSearchBarExpansionAnimation)
public enum CYLSearchBarExpansionAnimation: Int {
    /**
     * The field grows from the icon and fades in.
     */
    case fade
    /**
     * A circle grows from the icon until it uncovers the whole field (Material circular reveal).
     */
    case circularReveal
}

/**
 * How an item appended to a search bar looks, like the FlatDesign tab bar's item appearance.
 */
@objc(CYLSearchBarItemStyle)
public enum CYLSearchBarItemStyle: Int {
    /**
     * An icon button with a 36 pt touch area (a camera, a filter).
     */
    case icon = 0
    /**
     * A thin vertical line between two items; it takes no taps and VoiceOver skips it.
     */
    case divider
    /**
     * A text button (a "Search" button); an image, when set, comes before the title.
     */
    case text
}

/**
 * What the default search button of a bar shows.
 */
@objc(CYLSearchBarSearchButtonStyle)
public enum CYLSearchBarSearchButtonStyle: Int {
    /**
     * The button shows a title, "Search" localized by default (`searchButtonTitle` changes it). The default.
     */
    case text = 0
    /**
     * The button shows an icon, the core's built-in magnifier by default (`searchButtonImage` changes it).
     */
    case icon = 1
}

/**
 * The fixed look of the whole bar: the field on the left stays, the items are appended after its text.
 */
@objc(CYLSearchBarStyle)
public enum CYLSearchBarStyle: Int {
    /**
     * The field as configured by its own properties (the default; nothing is changed).
     */
    case plain = 0
    /**
     * A capsule with a 1 pt secondary-label-colored border on the system background, the field and its items inside one
     * outline (the Discover search bar).
     */
    case bordered
}

/**
 * Events of a `CYLSearchBarView`.
 */
@objc(CYLSearchBarViewDelegate)
public protocol CYLSearchBarViewDelegate: NSObjectProtocol {
    /**
     * Asks whether a tap may start editing. Return NO to use the bar as a button that opens another search page
     * (lapism `MaterialSearchBar.setOnClickListener`); `-searchBarViewDidTapWhileNotEditable:` is called instead.
     */
    @objc(searchBarViewShouldBeginEditing:)
    optional func searchBarViewShouldBeginEditing(_ searchBarView: CYLSearchBarView) -> Bool

    /**
     * The bar was tapped while `-searchBarViewShouldBeginEditing:` refused editing.
     */
    @objc(searchBarViewDidTapWhileNotEditable:)
    optional func searchBarViewDidTapWhileNotEditable(_ searchBarView: CYLSearchBarView)

    /**
     * Editing started.
     */
    @objc(searchBarViewDidBeginEditing:)
    optional func searchBarViewDidBeginEditing(_ searchBarView: CYLSearchBarView)

    /**
     * Editing ended.
     */
    @objc(searchBarViewDidEndEditing:)
    optional func searchBarViewDidEndEditing(_ searchBarView: CYLSearchBarView)

    /**
     * The text changed (typing, the clear button, Cancel with `clearsTextOnCancel`).
     */
    @objc(searchBarView:textDidChange:)
    optional func searchBarView(_ searchBarView: CYLSearchBarView, textDidChange text: String)

    /**
     * The keyboard's Search key.
     */
    @objc(searchBarViewSearchButtonClicked:)
    optional func searchBarViewSearchButtonClicked(_ searchBarView: CYLSearchBarView)

    /**
     * Cancel was tapped.
     */
    @objc(searchBarViewCancelButtonClicked:)
    optional func searchBarViewCancelButtonClicked(_ searchBarView: CYLSearchBarView)

    /**
     * The navigation button before the field (`navigationIcon`, `navigationImage`).
     */
    @objc(searchBarViewNavigationButtonClicked:)
    optional func searchBarViewNavigationButtonClicked(_ searchBarView: CYLSearchBarView)

    /**
     * The voice button (`showsVoiceButton`). Start speech recognition here and pass the result to
     * `-setText:submit:`.
     */
    @objc(searchBarViewVoiceButtonClicked:)
    optional func searchBarViewVoiceButtonClicked(_ searchBarView: CYLSearchBarView)

    /**
     * Asks whether the query may be submitted (the Search key, the submit button or `-setText:submit:` with YES).
     * Return NO to keep it. Without this method, every non-empty query is submitted.
     */
    @objc(searchBarView:shouldSubmitText:)
    optional func searchBarView(_ searchBarView: CYLSearchBarView, shouldSubmitText text: String) -> Bool

    /**
     * The field opened or closed (`iconified`).
     */
    @objc(searchBarView:didChangeIconified:)
    optional func searchBarView(_ searchBarView: CYLSearchBarView, didChangeIconified iconified: Bool)

    /**
     * An appended item was tapped (`-[CYLSearchBarView addItem:]`), like `-tabBar:didSelectItem:`.
     */
    @objc(searchBarView:didSelectItem:)
    optional func searchBarView(_ searchBarView: CYLSearchBarView, didSelect item: CYLSearchBarItem)

    /**
     * `CYLSearchBarModeMultiple`: the text of the search being typed changed (MultiSearchView `onTextChanged`).
     * `CYLSearchBarModeSingle` reports `-searchBarView:textDidChange:` instead.
     */
    @objc(searchBarView:textDidChange:atIndex:)
    optional func searchBarView(_ searchBarView: CYLSearchBarView, textDidChange text: String, at index: Int)

    /**
     * `CYLSearchBarModeMultiple`: a search was completed and became an entry of `searches` (`onSearchComplete`).
     */
    @objc(searchBarView:didCompleteSearch:atIndex:)
    optional func searchBarView(_ searchBarView: CYLSearchBarView, didCompleteSearch text: String, at index: Int)

    /**
     * `CYLSearchBarModeMultiple`: a search was removed by its remove button or `-removeSearchAtIndex:`
     * (`onSearchItemRemoved`).
     */
    @objc(searchBarView:didRemoveSearchAtIndex:)
    optional func searchBarView(_ searchBarView: CYLSearchBarView, didRemoveSearchAt index: Int)

    /**
     * `CYLSearchBarModeMultiple`: a search was selected by a tap or `-selectSearchAtIndex:` (`onItemSelected`).
     */
    @objc(searchBarView:didSelectSearch:atIndex:)
    optional func searchBarView(_ searchBarView: CYLSearchBarView, didSelectSearch text: String, at index: Int)
}

/**
 * Returns the content insets of a `CYLSearchBarView` or the margins of its Cancel button for its state (`true` while
 * editing); the same shape as `CYLSearchBarMarginsProvider`.
 */
public typealias CYLSearchBarViewMarginsProvider = (CYLSearchBarView, Bool) -> UIEdgeInsets

/**
 * A configurable search bar: a rounded field with a magnifier, text and clear button, views of the host inside the
 * field after the text (a camera, a "Search" button) or before the field (a back button), and an optional Cancel
 * button. Use it as a navigation item's title view, a header, or anywhere in a layout. With `mode` set to
 * `CYLSearchBarModeMultiple` it holds several searches side by side instead (iammert `MultiSearchView`).
 */
@objc(CYLSearchBarView)
public final class CYLSearchBarView: UIView, UITextFieldDelegate {

    private static let iconSize: CGFloat = 18
    private static let spacing: CGFloat = 8
    private static let minimumTextShare: CGFloat = 0.4
    private static let maximumCancelShare: CGFloat = 0.3
    private static let minimumScale: CGFloat = 0.5
    private static let minimumAccessoryScale: CGFloat = 0.25
    private static let accessoryAnimationDuration: TimeInterval = 0.25
    private var accessoryGeneration = 0

    // MARK: - Subviews

    /**
     * Receives the events.
     */
    @objc public weak var delegate: CYLSearchBarViewDelegate?

    /**
     * The text field inside the field.
     */
    @objc public let textField: UITextField = CYLSearchBarTextField()

    /**
     * The rounded field that holds the magnifier, the text and `trailingAccessoryViews`.
     */
    @objc public let fieldView = UIView()

    /**
     * The magnifier at the start of the field (decorative: hidden from VoiceOver).
     */
    @objc public let searchIconView = UIImageView()

    /**
     * The Cancel button after the field (`showsCancelButton`).
     */
    @objc public let cancelButton = UIButton(configuration: CYLSearchBarView.plainConfiguration(insets: NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)), primaryAction: nil)

    /**
     * Draws the placeholder at the full font size, cut off with an ellipsis when it does not fit.
     */
    @objc public let placeholderLabel = UILabel()

    /**
     * The button before the field. It is shown when `navigationIcon` is not none or `navigationImage` is set, and
     * `leadingView` is nil; taps call `-searchBarViewNavigationButtonClicked:` and `navigationHandler`.
     */
    @objc public let navigationButton = CYLSearchBarView.iconButton()

    /**
     * A microphone inside the field, shown while the text is empty; it calls `-searchBarViewVoiceButtonClicked:`.
     */
    @objc public let voiceButton = CYLSearchBarView.iconButton()

    /**
     * A submit button inside the field, shown while there is text; it submits the query like the Search key.
     */
    @objc public let submitButton = CYLSearchBarView.iconButton()

    /**
     * The button shown while `iconified` is YES. VoiceOver reads it as "Search".
     */
    @objc public let iconButton = CYLSearchBarView.iconButton()

    private let clearButton = CYLSearchBarView.iconButton()
    private var animatingExpansion = false

    private static func plainConfiguration(insets: NSDirectionalEdgeInsets) -> UIButton.Configuration {
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = insets
        return configuration
    }

    private static func iconButton() -> UIButton {
        let button = UIButton(configuration: plainConfiguration(insets: NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)), primaryAction: nil)
        button.showsLargeContentViewer = true
        button.isPointerInteractionEnabled = true
        return button
    }

    // MARK: - Text

    /**
     * The text of the field.
     */
    @objc public var text: String? {
        get { textField.text }
        set { textField.text = newValue; textStateChanged(); textAssignedHandler?() }
    }

    /**
     * Called after `text` is assigned from code (typing and the clear button do not call it; the delegate reports those).
     * `CYLSearchController` uses it to update its results for a text set in code, as UIKit's search bar did.
     */
    var textAssignedHandler: (() -> Void)?

    /**
     * The placeholder, drawn by `placeholderLabel` and kept on the text field for VoiceOver.
     */
    @objc public var placeholder: String? {
        get { textField.placeholder }
        set {
            textField.placeholder = newValue
            placeholderLabel.text = newValue
            applyStyle()
        }
    }

    private var customFont: UIFont?

    /**
     * The font of the text, the placeholder and Cancel. The body text style by default, following Dynamic Type; a
     * custom font is used as given (pass a `UIFontMetrics` font to scale it).
     */
    @objc public var font: UIFont! {
        get { customFont ?? UIFont.preferredFont(forTextStyle: .body, compatibleWith: traitCollection) }
        set { customFont = newValue; applyStyle() }
    }

    private var customTextColor: UIColor?

    /**
     * The text color. `labelColor` by default.
     */
    @objc public var textColor: UIColor! {
        get { customTextColor ?? .label }
        set { customTextColor = newValue; applyStyle() }
    }

    /**
     * The placeholder color. `UIColor.secondaryLabel` when nil (readable in dark mode).
     */
    @objc public var placeholderColor: UIColor? { didSet { applyStyle() } }

    private var customCursorColor: UIColor?

    /**
     * The color of the text cursor (MaterialSearchView `setCursorDrawable`). The tint color by default.
     */
    @objc public var cursorColor: UIColor! {
        get { customCursorColor ?? tintColor }
        set { customCursorColor = newValue; textField.tintColor = newValue }
    }

    // MARK: - Field

    /**
     * The height of the field; it grows when the scaled text needs more. 36 by default.
     */
    @objc public var fieldHeight: CGFloat = 36 {
        didSet { fieldHeight = max(0, fieldHeight); invalidateIntrinsicContentSize(); setNeedsLayout() }
    }

    /**
     * The space around the field. (6, 16, 6, 16) by default: the same 16 pt as the tag list's section insets and
     * section header (CollectionViewClassifyMenu), so a bar placed edge to edge lines up with the suggestions below it.
     */
    @objc public var contentInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16) {
        didSet { invalidateIntrinsicContentSize(); setNeedsLayout() }
    }

    /**
     * The content insets for the bar's state (`true` while editing); wins over `contentInsets`, the resting value
     * (the same knob as `CYLSearchBar.textFieldMarginsProvider`). The bar's height is measured with `contentInsets`, so
     * it does not jump when editing starts.
     */
    @objc public var textFieldMarginsProvider: CYLSearchBarViewMarginsProvider? {
        didSet { setNeedsLayout() }
    }

    /**
     * Whether the magnifier and the placeholder are centered in the field while the bar is not editing and has no text
     * (the same knob as `CYLSearchBar.centersPlaceholder`). NO by default.
     */
    @objc public var centersPlaceholder = false {
        didSet { setNeedsLayout() }
    }

    /**
     * The style of the field, one `CYLSearchBarAppearance` for this bar and `CYLSearchBar`; nil by default (the bar keeps
     * its own look). Assigning a style maps it onto `font`, `textColor`, `placeholderColor`, `placeholder`,
     * `tintColor`, `searchIcon`, `fieldBackgroundColor`, `fieldBackgroundImage`, `fieldBorderColor`,
     * `fieldBorderWidth`, `fieldCornerRadius`, `cancelButtonTitle` and, when set, `backgroundColor`.
     */
    @objc public var appearanceStyle: CYLSearchBarAppearance? {
        didSet { applyAppearance() }
    }

    /**
     * Applies `CYLSearchBarAppearance.defaultAppearance` (the same method as `CYLSearchBar`).
     */
    @objc public func applyDefaultAppearance() {
        appearanceStyle = CYLSearchBarAppearance.defaultCopy()
    }

    private func applyAppearance() {
        guard let style = appearanceStyle else { return }
        let field = style.resolvedField(traits: traitCollection)
        font = style.font
        textColor = style.textColor
        placeholderColor = style.placeholderColor
        if let text = style.placeholder { placeholder = text }
        tintColor = style.tintColor
        searchIcon = style.searchIconImage ?? UIImage(systemName: "magnifyingglass")
        fieldBackgroundColor = style.textFieldBackgroundColor
        fieldBackgroundImage = field.backgroundImage
        fieldBorderColor = style.textFieldBorderColor
        fieldBorderWidth = field.borderWidth
        fieldCornerRadius = field.cornerRadius ?? -1
        cancelButtonTitle = style.cancelTitle
        if let color = style.barBackgroundColor { backgroundColor = color }
    }

    private var customFieldBackgroundColor: UIColor?

    /**
     * The field's background. `tertiarySystemFillColor` by default.
     */
    @objc public var fieldBackgroundColor: UIColor! {
        get { customFieldBackgroundColor ?? .tertiarySystemFill }
        set { customFieldBackgroundColor = newValue; applyStyle() }
    }

    /**
     * The field's corner radius; negative makes a capsule. -1 by default.
     */
    @objc public var fieldCornerRadius: CGFloat = -1 { didSet { setNeedsLayout() } }

    /**
     * The field's border color; nil draws no border.
     */
    @objc public var fieldBorderColor: UIColor? { didSet { applyStyle() } }

    /**
     * The field's border width, used with `fieldBorderColor`. 0 by default.
     */
    @objc public var fieldBorderWidth: CGFloat = 0 { didSet { fieldBorderWidth = max(0, fieldBorderWidth); applyStyle() } }

    /**
     * The field's shadow, 0 to 1. 0 by default.
     */
    @objc public var fieldShadowOpacity: CGFloat = 0 { didSet { fieldShadowOpacity = min(1, max(0, fieldShadowOpacity)); applyStyle() } }

    /**
     * The magnifier; nil shows none. `magnifyingglass` by default.
     */
    @objc public var searchIcon: UIImage? = UIImage(systemName: "magnifyingglass") {
        didSet { searchIconView.image = searchIcon; updateButtonImages() }
    }

    private var customSearchIconTintColor: UIColor?

    /**
     * The magnifier's tint. `secondaryLabelColor` by default.
     */
    @objc public var searchIconTintColor: UIColor! {
        get { customSearchIconTintColor ?? .secondaryLabel }
        set { customSearchIconTintColor = newValue; applyStyle() }
    }

    // MARK: - Accessory views

    /**
     * Views of yours inside the field after the text, scaled down when they would squeeze it.
     */
    @objc public var trailingAccessoryViews: [UIView] = [] {
        didSet {
            oldValue.forEach { $0.removeFromSuperview() }
            trailingAccessoryViews.forEach {
                fieldView.addSubview($0)
                if !trailingAccessoryViewsShow { $0.isHidden = true }
            }
            setNeedsLayout()
        }
    }

    private var trailingAccessoryViewsShow = true
    private var hidingTrailingAccessoryViews = false

    /**
     * Whether `trailingAccessoryViews` are shown, without animation. YES by default; hidden views give their room to
     * the text.
     */
    @objc public var showsTrailingAccessoryViews: Bool {
        get { trailingAccessoryViewsShow }
        set { setShowsTrailingAccessoryViews(newValue, animated: false) }
    }

    /**
     * Shows or hides `trailingAccessoryViews`, optionally fading them with the text taking or giving up their room
     * (QMUI `qmui_setShowsRightAccessoryView:animated:`, the same knob as `CYLSearchBar`). Toggling quickly ends in the
     * last requested state.
     */
    @objc public func setShowsTrailingAccessoryViews(_ shows: Bool, animated: Bool) {
        guard shows != trailingAccessoryViewsShow || hidingTrailingAccessoryViews else { return }
        trailingAccessoryViewsShow = shows
        let views = trailingAccessoryViews
        accessoryGeneration += 1
        let generation = accessoryGeneration
        guard animated else {
            hidingTrailingAccessoryViews = false
            views.forEach { $0.isHidden = !shows; $0.alpha = 1 }
            setNeedsLayout()
            return
        }
        if shows {
            hidingTrailingAccessoryViews = false
            for view in views {
                if view.bounds.isEmpty {
                    view.bounds = CGRect(origin: .zero, size: Self.fittingSize(of: view, height: fieldView.bounds.height))
                }
                view.alpha = 0
                view.isHidden = false
                view.center = CGPoint(x: fieldView.bounds.width, y: fieldView.bounds.height / 2)
            }
            UIView.animate(withDuration: Self.accessoryAnimationDuration, delay: 0, options: .curveEaseInOut) {
                self.layoutIfNeeded()
                views.forEach { $0.alpha = 1 }
            }
        } else {
            hidingTrailingAccessoryViews = true
            UIView.animate(withDuration: Self.accessoryAnimationDuration, delay: 0, options: .curveEaseInOut, animations: {
                self.layoutIfNeeded()
                views.forEach { $0.alpha = 0 }
            }, completion: { _ in
                guard generation == self.accessoryGeneration else { return }
                self.hidingTrailingAccessoryViews = false
                views.forEach { $0.isHidden = true; $0.alpha = 1 }
            })
        }
    }

    // MARK: - Items

    /**
     * The appended items, in order, after the text and after `trailingAccessoryViews` (like the FlatDesign tab bar's
     * `items`). The field stays; only items are appended.
     */
    @objc public private(set) var items: [CYLSearchBarItem] = []

    /**
     * The row of the items: one `CYLAnimatedItemStackView`, so the tint (the built-in default that follows dark mode, a
     * host's `itemTintColor`) and the dividers are the component's, not drawn per item here.
     */
    let itemStack = CYLAnimatedItemStackView()

    /**
     * Makes the stack hold the views of `items` in order; a divider item becomes the stack's built-in divider after the
     * item before it (none at the start, one for several in a row).
     */
    private func rebuildItemStack() {
        let content = items.filter { $0.style != .divider }
        var controls = content.map { $0.itemControl }
        // The default search button is the last control, after the owner's items, with a divider when an item precedes it.
        let showsDefaultButton = showsSearchButton && !isEditingBar && mode != .multiple
        if showsDefaultButton { controls.append(searchButtonItem.itemControl) }
        itemStack.replaceItemViews(controls)
        for view in itemStack.itemViews {
            itemStack.removeDivider(after: view)
        }
        for (index, item) in items.enumerated() where item.style == .divider {
            guard let before = items[..<index].last(where: { $0.style != .divider }) else { continue }
            itemStack.setDivider(after: before.itemControl, spacingBefore: Self.spacing, spacingAfter: Self.spacing)
        }
        if showsDefaultButton, let before = content.last {
            itemStack.setDivider(after: before.itemControl, spacingBefore: Self.spacing, spacingAfter: Self.spacing)
        }
        itemStack.isHidden = controls.isEmpty
        setNeedsLayout()
    }

    // MARK: - Default search button

    /**
     * Whether the bar shows its default search button, after the field and the items: YES by default (an editing bar and a bar in
     * `CYLSearchBarModeMultiple` never show it). A tap calls `searchButtonHandler`, else submits the text (`submit()`), and tells the
     * delegate `-searchBarViewSearchButtonClicked:` also when the text is empty.
     */
    @objc public var showsSearchButton = true {
        didSet { rebuildItemStack() }
    }

    /**
     * Whether the default search button shows a title (`.text`, the default) or an icon (`.icon`).
     */
    @objc public var searchButtonStyle: CYLSearchBarSearchButtonStyle = .text {
        didSet { rebuildSearchButton() }
    }

    /**
     * The title of the default search button (also its accessibility label in the icon style); nil is the localized "Search".
     */
    @objc public var searchButtonTitle: String? {
        didSet { rebuildSearchButton() }
    }

    /**
     * The icon of the default search button in the `.icon` style; nil is the core's built-in magnifier (SF Symbol
     * `magnifyingglass`).
     */
    @objc public var searchButtonImage: UIImage? {
        didSet { rebuildSearchButton() }
    }

    /**
     * Called instead of the default action when the default search button is tapped.
     */
    @objc public var searchButtonHandler: ((CYLSearchBarView) -> Void)?

    /**
     * The default search button as an item, for its tint, its badge or its accessibility identifier. It is not in `items`.
     * Replaced (with the tint and identifier kept) when the style, title or icon changes.
     */
    @objc public private(set) lazy var searchButtonItem: CYLSearchBarItem = makeSearchButtonItem()

    private func makeSearchButtonItem() -> CYLSearchBarItem {
        let title = searchButtonTitle ?? CYLSearchResources.localizedString(forKey: "search.button")
        let item: CYLSearchBarItem
        switch searchButtonStyle {
        case .text:
            item = CYLSearchBarItem(style: .text, title: title, image: nil)
        case .icon:
            item = CYLSearchBarItem(style: .icon, title: title, image: searchButtonImage ?? UIImage(systemName: "magnifyingglass"))
            // A filled capsule with the icon in the inverse color, at the end of the field (black with a white magnifier in light
            // mode, white with a black one in dark mode): one CYLAnimatedItemView, the icon and its background and corner together.
            item.backgroundColor = .label
            item.tintColor = .systemBackground
            item.cornerRadius = CYLAnimatedItemCornerRadiusCapsule
            item.itemHeight = 28
            item.contentInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        item.itemAccessibilityIdentifier = "CYLSearchBarSearchButton"
        item.searchBarView = self
        item.itemControl.addTarget(self, action: #selector(itemTapped(_:)), for: .touchUpInside)
        return item
    }

    private func rebuildSearchButton() {
        let old = searchButtonItem
        let item = makeSearchButtonItem()
        item.itemAccessibilityIdentifier = old.itemAccessibilityIdentifier
        old.itemControl.removeTarget(self, action: nil, for: .allEvents)
        old.itemControl.removeFromSuperview()
        old.searchBarView = nil
        searchButtonItem = item
        rebuildItemStack()
    }

    private func searchButtonTapped() {
        if let searchButtonHandler {
            searchButtonHandler(self)
        } else if !(text ?? "").isEmpty {
            _ = submit()
        } else {
            delegate?.searchBarViewSearchButtonClicked?(self)
        }
    }

    /**
     * The views of `items` (`CYLTagButton`s), in the same order.
     */
    @objc public var itemViews: [CYLTagButton] {
        items.map(\.itemView)
    }

    /**
     * The icon and title color of every item without its own `tintColor`; nil uses the label color.
     */
    @objc public var itemTintColor: UIColor? {
        didSet {
            items.forEach { $0.itemControl.reload() }
            searchButtonItem.itemControl.reload()
        }
    }

    /**
     * The fixed look of the bar. `.bordered` draws the field and its items inside one capsule outline.
     */
    @objc public var searchBarStyle: CYLSearchBarStyle = .plain {
        didSet { applySearchBarStyle() }
    }

    /**
     * An image drawn behind the field's content, clipped to its corners.
     */
    @objc public var fieldBackgroundImage: UIImage? {
        didSet {
            fieldBackgroundImageView.image = fieldBackgroundImage
            fieldBackgroundImageView.isHidden = fieldBackgroundImage == nil
            setNeedsLayout()
        }
    }

    /**
     * The first selected item (an item with `selectable` YES that was tapped on), or nil.
     */
    @objc public var selectedItem: CYLSearchBarItem? {
        items.first { $0.isSelected }
    }

    /**
     * The index of `selectedItem`, or `NSNotFound`.
     */
    @objc public var selectedIndex: Int {
        items.firstIndex { $0.isSelected } ?? NSNotFound
    }

    private let fieldBackgroundImageView = UIImageView()

    /**
     * Appends an item after the others.
     */
    @objc(addItem:)
    public func addItem(_ item: CYLSearchBarItem) {
        insertItem(item, at: items.count)
    }

    /**
     * Inserts an item at an index (clamped to `items`); an item already in a bar moves here.
     */
    @objc(insertItem:atIndex:)
    public func insertItem(_ item: CYLSearchBarItem, at index: Int) {
        itemShapes = nil
        item.searchBarView?.removeItem(item)
        items.insert(item, at: min(max(0, index), items.count))
        item.searchBarView = self
        let view = item.itemControl
        view.removeTarget(nil, action: nil, for: .allEvents)
        view.addTarget(self, action: #selector(itemTapped(_:)), for: .touchUpInside)
        rebuildItemStack()
        view.reload()
        setNeedsLayout()
    }

    /**
     * Creates an item and inserts it at an index; `NSNotFound` or a larger index appends it. Mirrors
     * `-addItemWithTitle:tabBarItemImage:tabBarItemSelectedImage:index:`.
     */
    @discardableResult
    @objc(addItemWithStyle:title:image:index:handler:)
    public func addItem(style: CYLSearchBarItemStyle, title: String?, image: UIImage?, index: Int, handler: ((CYLSearchBarItem) -> Void)?) -> CYLSearchBarItem {
        let item = CYLSearchBarItem(style: style, title: title, image: image)
        item.handler = handler
        insertItem(item, at: index == NSNotFound ? items.count : index)
        return item
    }

    /**
     * Removes an item from the bar.
     */
    @objc(removeItem:)
    public func removeItem(_ item: CYLSearchBarItem) {
        guard let index = items.firstIndex(of: item) else {
            return
        }
        itemShapes = nil
        items.remove(at: index)
        item.searchBarView = nil
        item.itemView.removeTarget(self, action: nil, for: .allEvents)
        item.itemView.removeFromSuperview()
        rebuildItemStack()
        setNeedsLayout()
    }

    /**
     * Removes every item.
     */
    @objc public func removeAllItems() {
        items.forEach { removeItem($0) }
    }

    /**
     * Replaces the items with the ones the dictionaries describe (`+itemWithDictionary:`), as the cross-platform bridges
     * send them. When only `animationLoops` and `animationSpeed` differ from the last call, the items stay and take the
     * two values, so the animation is not reloaded; any other difference rebuilds the items.
     */
    @objc(setItemsWithDictionaries:)
    public func setItems(dictionaries: [[String: Any]]) {
        let shapes = dictionaries.map { $0.filter { !Self.playbackKeys.contains($0.key) } }
        if let itemShapes, (itemShapes as NSArray).isEqual(to: shapes), items.count == shapes.count {
            for (item, dictionary) in zip(items, dictionaries) {
                item.animationLoops = dictionary["animationLoops"] as? Bool ?? false
                item.animationSpeed = CGFloat((dictionary["animationSpeed"] as? NSNumber)?.doubleValue ?? 1)
            }
            return
        }
        removeAllItems()
        dictionaries.forEach { addItem(CYLSearchBarItem.item(dictionary: $0)) }
        itemShapes = shapes
    }

    private static let playbackKeys: Set<String> = ["animationLoops", "animationSpeed"]

    // The item dictionaries of the last `setItems(dictionaries:)` without the playback keys; nil once an item was added
    // or removed in any other way.
    private var itemShapes: [[String: Any]]?

    /**
     * YES when an item of the style was appended (a text "Search" button), like `-hasPlusButton`.
     */
    @objc(hasItemOfStyle:)
    public func hasItem(of style: CYLSearchBarItemStyle) -> Bool {
        items.contains { $0.style == style }
    }

    @objc private func itemTapped(_ sender: UIControl) {
        guard let item = (sender as? CYLSearchBarItemButton)?.item, item.isEnabled else {
            return
        }
        if item === searchButtonItem {
            searchButtonTapped()
            return
        }
        if item.isSelectable {
            item.isSelected.toggle()
        }
        if item.animationURL != nil {
            // An animated icon plays on each tap, as a tab icon does (after the selection, which resets it).
            item.itemView.playAnimation()
        }
        delegate?.searchBarView?(self, didSelect: item)
        item.handler?(item)
    }

    private func applySearchBarStyle() {
        switch searchBarStyle {
        case .plain:
            break
        case .bordered:
            fieldBorderColor = .secondaryLabel
            fieldBorderWidth = 1
            fieldBackgroundColor = .systemBackground
            fieldCornerRadius = -1
        }
    }

    /**
     * A view of yours before the field (a back button); it wins over the navigation button.
     */
    @objc public var leadingView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let leadingView {
                addSubview(leadingView)
            }
            applyIconifiedVisibility()
            setNeedsLayout()
        }
    }

    private var leadingViewShows = true
    private var hidingLeadingView = false

    /**
     * Whether the view before the field (`leadingView`, or the navigation button) is shown, without animation. YES by
     * default; a hidden view gives its room to the field.
     */
    @objc public var showsLeadingView: Bool {
        get { leadingViewShows }
        set { setShowsLeadingView(newValue, animated: false) }
    }

    /**
     * Shows or hides the view before the field, optionally sliding it in from or out to the left edge while the field
     * takes or gives up its room (QMUI `qmui_setShowsLeftAccessoryView:animated:`). Toggling quickly ends in the last
     * requested state.
     */
    @objc public func setShowsLeadingView(_ shows: Bool, animated: Bool) {
        guard shows != leadingViewShows || hidingLeadingView else { return }
        leadingViewShows = shows
        accessoryGeneration += 1
        let generation = accessoryGeneration
        guard animated, let view = effectiveLeadingView else {
            hidingLeadingView = false
            applyIconifiedVisibility()
            setNeedsLayout()
            return
        }
        if shows {
            hidingLeadingView = false
            applyIconifiedVisibility()
            view.frame.origin.x = -view.frame.width
            UIView.animate(withDuration: Self.accessoryAnimationDuration, delay: 0, options: .curveEaseInOut) {
                self.layoutIfNeeded()
            }
        } else {
            hidingLeadingView = true
            UIView.animate(withDuration: Self.accessoryAnimationDuration, delay: 0, options: .curveEaseInOut, animations: {
                self.layoutIfNeeded()
                view.frame.origin.x = -view.frame.width
            }, completion: { _ in
                guard generation == self.accessoryGeneration else { return }
                self.hidingLeadingView = false
                self.applyIconifiedVisibility()
            })
        }
        setNeedsLayout()
    }

    // MARK: - Cancel button

    /**
     * Shows the Cancel button after the field. NO by default.
     */
    @objc public var showsCancelButton = false {
        didSet { applyIconifiedVisibility(); setNeedsLayout() }
    }

    private var hidingCancelButton = false
    private var cancelGeneration = 0

    /**
     * Shows or hides the Cancel button, optionally sliding and fading it while the field takes or gives up its room
     * (UIKit `setShowsCancelButton:animated:`, the same method as `CYLSearchBar`). Toggling quickly ends in the last
     * requested state.
     */
    @objc public func setShowsCancelButton(_ shows: Bool, animated: Bool) {
        guard animated, shows != showsCancelButton else {
            hidingCancelButton = false
            showsCancelButton = shows
            return
        }
        cancelGeneration += 1
        let generation = cancelGeneration
        if shows {
            hidingCancelButton = false
            cancelButton.alpha = 0
            cancelButton.frame.origin.x = bounds.width
            showsCancelButton = true
            UIView.animate(withDuration: Self.accessoryAnimationDuration, delay: 0, options: .curveEaseInOut) {
                self.layoutIfNeeded()
                self.cancelButton.alpha = 1
            }
        } else {
            hidingCancelButton = true
            showsCancelButton = false
            UIView.animate(withDuration: Self.accessoryAnimationDuration, delay: 0, options: .curveEaseInOut, animations: {
                self.layoutIfNeeded()
                self.cancelButton.alpha = 0
                self.cancelButton.frame.origin.x = self.bounds.width
            }, completion: { _ in
                guard generation == self.cancelGeneration else { return }
                self.hidingCancelButton = false
                self.cancelButton.alpha = 1
                self.applyIconifiedVisibility()
            })
        }
    }

    /**
     * Returns the margins applied to the Cancel button's frame for the bar's state (`true` while editing); a negative
     * left value moves it left and widens it (the same knob as `CYLSearchBar.cancelButtonMarginsProvider`).
     */
    @objc public var cancelButtonMarginsProvider: CYLSearchBarViewMarginsProvider? {
        didSet { setNeedsLayout() }
    }

    /**
     * The font of the Cancel button's title; `font` when nil (the same knob as `CYLSearchBar.cancelButtonFont`).
     */
    @objc public var cancelButtonFont: UIFont? {
        didSet { applyStyle() }
    }

    private var customCancelButtonTitle: String?

    /**
     * The Cancel title. The localized "Cancel" by default.
     */
    @objc public var cancelButtonTitle: String! {
        get { customCancelButtonTitle ?? CYLSearchResources.localizedString(forKey: "search.cancel") }
        set { customCancelButtonTitle = newValue; applyStyle() }
    }

    /**
     * Taps on Cancel also end editing and clear nothing. YES by default.
     */
    @objc public var cancelButtonEndsEditing = true

    /**
     * Taps on Cancel also clear the text (lapism `setTextClearOnBackPressed`). NO by default.
     */
    @objc public var clearsTextOnCancel = false

    // MARK: - Editing bar

    /**
     * Whether the bar is an editing bar (`editingBar(placeholder:actionTitle:)`): an edit field in the search bar's look,
     * whose trailing button submits instead of cancelling.
     */
    @objc public private(set) var isEditingBar = false {
        didSet { rebuildItemStack() }
    }

    /**
     * An editing bar's submit: the trimmed text, when its action button or the return key is tapped (after
     * `-searchBarView:shouldSubmitText:` and `-searchBarViewSearchButtonClicked:`). Empty text submits nothing.
     */
    @objc public var editingSubmitHandler: ((CYLSearchBarView, String) -> Void)?

    /**
     * An editing bar: the search bar's field and look for editing a name (a tag, a title), without the magnifier, with
     * `actionTitle` ("Add", "Done") as its trailing button, which submits through `editingSubmitHandler`, as the return key
     * does. Pin it above the keyboard with `pinToKeyboard(in:)`; change `cancelButtonTitle` to change the action.
     */
    @objc(editingBarWithPlaceholder:actionTitle:)
    public static func editingBar(placeholder: String?, actionTitle: String) -> CYLSearchBarView {
        let bar = CYLSearchBarView(frame: .zero)
        bar.isEditingBar = true
        bar.searchIcon = nil
        bar.placeholder = placeholder
        bar.showsCancelButton = true
        bar.cancelButtonTitle = actionTitle
        bar.cancelButtonEndsEditing = false
        bar.returnKeyType = .done
        // A name is typed as written: words capitalized, never autocorrected.
        bar.autocapitalizationType = .words
        bar.autocorrectionType = .no
        bar.backgroundColor = .systemBackground
        bar.accessibilityIdentifier = "CYLSearchEditingBar"
        return bar
    }

    /**
     * Pins the bar to the top of the keyboard in `view` (its keyboard layout guide, iOS 15): full width within the safe
     * area, at the bottom while the keyboard is down, riding on the keyboard while it is up, docked or not.
     */
    @objc(pinToKeyboardInView:)
    public func pinToKeyboard(in view: UIView) {
        if superview !== view {
            removeFromSuperview()
            view.addSubview(self)
        }
        translatesAutoresizingMaskIntoConstraints = false
        view.keyboardLayoutGuide.followsUndockedKeyboard = true
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
        ])
    }

    /**
     * An editing bar's submit: the delegate's `-searchBarView:shouldSubmitText:` and `-searchBarViewSearchButtonClicked:`
     * (`submit()`), then `editingSubmitHandler` with the trimmed text.
     */
    private func submitEditing() {
        let text = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, submit() else {
            return
        }
        editingSubmitHandler?(self, text)
    }

    /**
     * Ending editing also clears the text (lapism `setTextClearOnClearFocus`). NO by default.
     */
    @objc public var clearsTextOnEndEditing = false

    // MARK: - Navigation button

    /**
     * A built-in navigation icon. `CYLSearchBarNavigationIconNone` by default.
     */
    @objc public var navigationIcon: CYLSearchBarNavigationIcon = .none { didSet { updateButtonImages() } }

    /**
     * A custom navigation icon; it wins over `navigationIcon`.
     */
    @objc public var navigationImage: UIImage? { didSet { updateButtonImages() } }

    private var customNavigationAccessibilityLabel: String?

    /**
     * What VoiceOver reads for the navigation button. Defaults to "Back" for the arrow and "Search" for the magnifier.
     */
    @objc public var navigationAccessibilityLabel: String! {
        get {
            customNavigationAccessibilityLabel
                ?? CYLSearchResources.localizedString(forKey: navigationIcon == .search ? "search.field" : "search.back")
        }
        set { customNavigationAccessibilityLabel = newValue; updateButtonImages() }
    }

    /**
     * A circle drawn behind the navigation icon. Nil (none) by default.
     */
    @objc public var navigationBackgroundColor: UIColor? { didSet { updateButtonImages() } }

    /**
     * The shadow of that circle, 0 to 1 (lapism `setNavigationElevation`). 0 by default.
     */
    @objc public var navigationShadowOpacity: CGFloat = 0 {
        didSet { navigationShadowOpacity = min(1, max(0, navigationShadowOpacity)); updateButtonImages() }
    }

    /**
     * Called on taps on the navigation button, after the delegate.
     */
    @objc public var navigationHandler: ((CYLSearchBarView) -> Void)?

    // MARK: - Voice, submit and clear buttons

    /**
     * Shows `voiceButton` while the text is empty. NO by default.
     */
    @objc public var showsVoiceButton = false { didSet { setNeedsLayout() } }

    private var customVoiceImage: UIImage?

    /**
     * The voice button's icon. `mic` by default.
     */
    @objc public var voiceImage: UIImage! {
        get { customVoiceImage ?? UIImage(systemName: "mic") }
        set { customVoiceImage = newValue; updateButtonImages() }
    }

    /**
     * Shows `submitButton` while there is text (Android `isSubmitButtonEnabled`). NO by default.
     */
    @objc public var showsSubmitButton = false { didSet { setNeedsLayout() } }

    private var customSubmitImage: UIImage?

    /**
     * The submit button's icon. `arrow.forward.circle.fill` by default.
     */
    @objc public var submitImage: UIImage! {
        get { customSubmitImage ?? UIImage(systemName: "arrow.forward.circle.fill") }
        set { customSubmitImage = newValue; updateButtonImages() }
    }

    /**
     * A custom clear button icon, shown while editing with text. Nil keeps the system clear button.
     */
    @objc public var clearImage: UIImage? {
        didSet {
            if clearImage != nil {
                textField.clearButtonMode = .never
                textField.rightView = clearButton
                textField.rightViewMode = .whileEditing
            } else {
                textField.rightView = nil
                textField.clearButtonMode = .whileEditing
            }
            updateButtonImages()
            textStateChanged()
        }
    }

    // MARK: - Keyboard

    /**
     * The keyboard type (Android `inputType`). `UIKeyboardTypeDefault` by default.
     */
    @objc public var keyboardType: UIKeyboardType {
        get { textField.keyboardType }
        set { textField.keyboardType = newValue; textField.reloadInputViews(); multiSearchView.applyStyle() }
    }

    /**
     * The return key (Android `imeOptions`). `UIReturnKeySearch` by default.
     */
    @objc public var returnKeyType: UIReturnKeyType {
        get { textField.returnKeyType }
        set { textField.returnKeyType = newValue; textField.reloadInputViews(); multiSearchView.applyStyle() }
    }

    /**
     * Automatic capitalization. `UITextAutocapitalizationTypeSentences` by default.
     */
    @objc public var autocapitalizationType: UITextAutocapitalizationType {
        get { textField.autocapitalizationType }
        set { textField.autocapitalizationType = newValue; multiSearchView.applyStyle() }
    }

    /**
     * Automatic correction. `UITextAutocorrectionTypeDefault` by default.
     */
    @objc public var autocorrectionType: UITextAutocorrectionType {
        get { textField.autocorrectionType }
        set { textField.autocorrectionType = newValue }
    }

    /**
     * Hides the typed characters (Android `inputType="textPassword"`). NO by default.
     */
    @objc(secureTextEntry) public var isSecureTextEntry: Bool {
        @objc(isSecureTextEntry) get { textField.isSecureTextEntry }
        set { textField.isSecureTextEntry = newValue }
    }

    /**
     * The longest text a person can type (Android `maxLength`); 0 means no limit. 0 by default.
     */
    @objc public var maximumTextLength: UInt = 0 {
        didSet {
            if let current = textField.text, maximumTextLength > 0, (current as NSString).length > maximumTextLength {
                text = (current as NSString).substring(to: Int(maximumTextLength))
            }
        }
    }

    // MARK: - Iconified

    private var iconifiedState = false

    /**
     * Shows only a search button instead of the field (Android `SearchView.isIconified`). Tapping the button opens
     * the field and starts editing. NO by default.
     */
    @objc(iconified) public var isIconified: Bool {
        @objc(isIconified) get { iconifiedState }
        set { setIconified(newValue, animated: false) }
    }

    /**
     * When YES, the field closes back to its icon when editing ends with no text (Android
     * `setIconifiedByDefault`). NO by default.
     */
    @objc public var iconifiedByDefault = false {
        didSet {
            if iconifiedByDefault, !textField.isFirstResponder, (textField.text ?? "").isEmpty {
                setIconified(true, animated: false)
            }
        }
    }

    /**
     * How the field opens and closes. `CYLSearchBarExpansionAnimationFade` by default.
     */
    @objc public var expansionAnimation: CYLSearchBarExpansionAnimation = .fade

    /**
     * Where `iconButton` sits while iconified; the field opens from there. `CYLSearchBarIconPositionTrailing` by
     * default.
     */
    @objc public var iconPosition: CYLSearchBarIconPosition = .trailing { didSet { setNeedsLayout() } }

    /**
     * The length of the opening and closing animations, in seconds. 0.3 by default.
     */
    @objc public var animationDuration: TimeInterval = 0.3

    // MARK: - Multiple searches (CYLSearchBarModeMultiple)

    private let multiSearchView = CYLSearchBarMultiSearchView()
    private var customNewSearchImage: UIImage?
    private var customRemoveSearchImage: UIImage?

    /**
     * One field (`CYLSearchBarModeSingle`, the default) or several searches side by side
     * (`CYLSearchBarModeMultiple`, iammert `MultiSearchView`). The text style (`placeholder`, `font`, `textColor`,
     * `placeholderColor`, the keyboard options, `maximumTextLength`) and `animationDuration` apply to both.
     */
    @objc public var mode: CYLSearchBarMode = .single {
        didSet {
            guard mode != oldValue else {
                return
            }
            rebuildItemStack()
            textField.resignFirstResponder()
            multiSearchView.endEditing(true)
            applyIconifiedVisibility()
            multiSearchView.applyStyle()
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }

    /**
     * `CYLSearchBarModeMultiple`: the texts of the searches, completed searches first, then the one being typed.
     */
    @objc public var searches: [String] {
        multiSearchView.searches
    }

    /**
     * `CYLSearchBarModeMultiple`: the index of the selected search in `searches`, or `NSNotFound` when none is
     * selected.
     */
    @objc public var selectedSearchIndex: Int {
        multiSearchView.selectedIndex
    }

    /**
     * `CYLSearchBarModeMultiple`: YES while a new search is being typed (MultiSearchView `isInSearchMode`).
     */
    @objc public var isEditingNewSearch: Bool {
        multiSearchView.isEditingNewSearch
    }

    /**
     * `CYLSearchBarModeMultiple`: the button at the trailing end; it starts a new search, or completes the one being
     * typed. VoiceOver reads it as "New search".
     */
    @objc public var newSearchButton: UIButton {
        multiSearchView.searchButton
    }

    /**
     * `CYLSearchBarModeMultiple`: a search shorter than this is dropped by `-completeSearch`. 3 by default, as in
     * MultiSearchView.
     */
    @objc public var minimumTextLength: UInt = 3

    /**
     * `CYLSearchBarModeMultiple`: the color of the indicator under the selected search and of `newSearchButton`; the
     * tint color when nil.
     */
    @objc public var searchIndicatorColor: UIColor? { didSet { multiSearchView.applyStyle() } }

    /**
     * `CYLSearchBarModeMultiple`: the opacity of the searches that are not selected, 0 to 1. 0.5 by default.
     */
    @objc public var unselectedSearchAlpha: CGFloat = 0.5 {
        didSet { unselectedSearchAlpha = min(1, max(0, unselectedSearchAlpha)); multiSearchView.applyStyle() }
    }

    /**
     * `CYLSearchBarModeMultiple`: the width of the field of a new search, in points (at least 44). 160 by default.
     */
    @objc public var searchFieldWidth: CGFloat = 160 {
        didSet { searchFieldWidth = max(44, searchFieldWidth); multiSearchView.setNeedsLayout() }
    }

    /**
     * `CYLSearchBarModeMultiple`: the icon of `newSearchButton`. `magnifyingglass` by default.
     */
    @objc public var newSearchImage: UIImage! {
        get { customNewSearchImage ?? UIImage(systemName: "magnifyingglass") }
        set { customNewSearchImage = newValue; multiSearchView.applyStyle() }
    }

    /**
     * `CYLSearchBarModeMultiple`: the icon of the remove button on the selected search. `xmark.circle.fill` by
     * default.
     */
    @objc public var removeSearchImage: UIImage! {
        get { customRemoveSearchImage ?? UIImage(systemName: "xmark.circle.fill") }
        set { customRemoveSearchImage = newValue; multiSearchView.applyStyle() }
    }

    /**
     * `CYLSearchBarModeMultiple`: starts a new search and shows the keyboard (MultiSearchView `search`). Does nothing
     * while a search is being typed, or in `CYLSearchBarModeSingle`.
     */
    @objc public func beginNewSearch() {
        guard mode == .multiple else {
            return
        }
        multiSearchView.beginNewSearch()
    }

    /**
     * `CYLSearchBarModeMultiple`: completes the search being typed (`completeSearch`). It becomes the selected search,
     * or is dropped when shorter than `minimumTextLength`.
     */
    @objc public func completeSearch() {
        guard mode == .multiple else {
            return
        }
        multiSearchView.completeSearch()
    }

    /**
     * `CYLSearchBarModeMultiple`: adds a completed search without typing it, and selects it. An empty text is ignored.
     */
    @objc(addSearch:)
    public func addSearch(_ text: String) {
        guard mode == .multiple else {
            return
        }
        multiSearchView.addSearch(text)
    }

    /**
     * `CYLSearchBarModeMultiple`: selects a search, like a tap on it.
     */
    @objc(selectSearchAtIndex:)
    public func selectSearch(at index: Int) {
        guard mode == .multiple else {
            return
        }
        multiSearchView.selectSearch(at: index)
    }

    /**
     * `CYLSearchBarModeMultiple`: removes a search, like a tap on its remove button. The next search is selected, or
     * the previous one when the last search went away.
     */
    @objc(removeSearchAtIndex:)
    public func removeSearch(at index: Int) {
        guard mode == .multiple else {
            return
        }
        multiSearchView.removeSearch(at: index)
    }

    // MARK: - Initializers

    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    /**
     * Creates the bar from an archive (a storyboard or a XIB).
     */
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        addSubview(fieldView)
        fieldBackgroundImageView.contentMode = .scaleAspectFill
        fieldBackgroundImageView.clipsToBounds = true
        fieldBackgroundImageView.isHidden = true
        fieldBackgroundImageView.isAccessibilityElement = false
        fieldView.addSubview(fieldBackgroundImageView)
        searchIconView.image = searchIcon
        searchIconView.contentMode = .scaleAspectFit
        searchIconView.isAccessibilityElement = false
        fieldView.addSubview(searchIconView)
        textField.delegate = self
        textField.returnKeyType = .search
        textField.clearButtonMode = .whileEditing
        textField.adjustsFontForContentSizeCategory = true
        // The placeholder is not a label: it disappears once there is text.
        textField.accessibilityLabel = CYLSearchResources.localizedString(forKey: "search.field")
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        fieldView.addSubview(textField)
        itemStack.axis = .horizontal
        itemStack.contentMargin = 0
        itemStack.spacing = Self.spacing
        itemStack.dispatchesItemTaps = false
        itemStack.isHidden = true
        fieldView.addSubview(itemStack)
        // A placeholder set on the text field itself (not on the bar) is drawn by the bar's label, too: the text field's
        // own placeholder is a dim system gray that dark mode makes hard to read.
        (textField as? CYLSearchBarTextField)?.onPlaceholderChange = { [weak self] text in
            guard let self, self.placeholderLabel.text != text else {
                return
            }
            self.placeholderLabel.text = text
            self.applyStyle()
        }
        // The placeholder is drawn by this label at the full font size and cut off with an ellipsis when it does not
        // fit: UITextField's own placeholder shrinks to a quarter of the size at large Dynamic Type sizes. The text
        // field keeps the placeholder (in a clear color) for VoiceOver.
        placeholderLabel.lineBreakMode = .byTruncatingTail
        placeholderLabel.isAccessibilityElement = false
        placeholderLabel.isUserInteractionEnabled = false
        fieldView.addSubview(placeholderLabel)
        cancelButton.isHidden = true
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cancelButton.showsLargeContentViewer = true
        addSubview(cancelButton)

        navigationButton.isHidden = true
        navigationButton.addTarget(self, action: #selector(navigationTapped), for: .touchUpInside)
        addSubview(navigationButton)
        voiceButton.isHidden = true
        voiceButton.accessibilityLabel = CYLSearchResources.localizedString(forKey: "search.voice")
        voiceButton.addTarget(self, action: #selector(voiceTapped), for: .touchUpInside)
        fieldView.addSubview(voiceButton)
        submitButton.isHidden = true
        submitButton.accessibilityLabel = CYLSearchResources.localizedString(forKey: "search.submit")
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        fieldView.addSubview(submitButton)
        clearButton.accessibilityLabel = CYLSearchResources.localizedString(forKey: "search.clear")
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        clearButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        iconButton.isHidden = true
        iconButton.accessibilityLabel = CYLSearchResources.localizedString(forKey: "search.field")
        iconButton.addTarget(self, action: #selector(iconTapped), for: .touchUpInside)
        addSubview(iconButton)
        multiSearchView.searchBarView = self
        multiSearchView.isHidden = true
        addSubview(multiSearchView)
        addInteraction(UILargeContentViewerInteraction())
        updateButtonImages()
        rebuildItemStack()
        applyStyle()
    }

    // MARK: - Text and keyboard

    /**
     * Sets the text and, when `submit` is YES and the text is not empty, submits it as if the Search key were tapped
     * (MaterialSearchView `setQuery`, lapism `setTextQuery`).
     */
    @objc(setText:submit:)
    public func setText(_ text: String?, submit: Bool) {
        self.text = text
        if submit {
            self.submit()
        }
    }

    /**
     * Submits the current text: asks `-searchBarView:shouldSubmitText:`, then calls
     * `-searchBarViewSearchButtonClicked:`. Returns NO when the text is empty or the delegate refused it.
     */
    @objc(submit)
    @discardableResult
    public func submit() -> Bool {
        let text = textField.text ?? ""
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return false
        }
        if delegate?.searchBarView?(self, shouldSubmitText: text) == false {
            return false
        }
        delegate?.searchBarViewSearchButtonClicked?(self)
        return true
    }

    /**
     * Starts editing and shows the keyboard.
     */
    @objc public func showKeyboard() {
        textField.becomeFirstResponder()
    }

    // MARK: - First-level tap and the bar's own back button

    /**
     * Whether a tap on the field does not edit but calls `onFirstLevelTap` (and `performFirstLevelTap()`): the bar of a first-level
     * page (a tab root) shows the whole search look and a tap pushes the second-level search page. NO by default; no keyboard comes
     * up on the first-level page (the second-level page's bar focuses itself, `focusesOnAppear`).
     */
    @objc public var pushesOnTap = false {
        didSet {
            if pushesOnTap {
                textField.accessibilityTraits.insert(.button)
            } else {
                textField.accessibilityTraits.remove(.button)
            }
        }
    }

    /**
     * Called when the field of a `pushesOnTap` bar is tapped: push the second-level search page. The second-level page's bar brings
     * its back button in and shrinks alongside the push (`embedInNavigationBar(of:)` does it), so the host only pushes.
     */
    @objc public var onFirstLevelTap: ((CYLSearchBarView) -> Void)?

    /**
     * The tap of a first-level bar, also callable from code: runs `onFirstLevelTap`.
     */
    @objc public func performFirstLevelTap() {
        onFirstLevelTap?(self)
    }

    /**
     * Whether the back button (the navigation arrow before the field) is shown.
     */
    @objc public var isBackButtonShown: Bool {
        showsNavigationButton && leadingViewShows && !isIconified
    }

    /**
     * 1 while the bar's own back button (its navigation arrow before the field) is shown, 0 while it is hidden. It is for a host that
     * puts the bar where no navigation controller supplies a back button (a plain view, a sheet); in a navigation bar the system
     * back button is used. The progress is not interactive on iOS: setting it shows (from 0.5) or hides the arrow without animation.
     */
    @objc public var backButtonProgress: CGFloat {
        get { isBackButtonShown ? 1 : 0 }
        set { setShowsLeadingView(newValue >= 0.5, animated: false) }
    }

    /**
     * Brings the back button (the navigation arrow) in from the left, the field shrinking to make room.
     */
    @objc(showBackButtonAnimated:)
    public func showBackButton(animated: Bool = true) {
        if leadingView == nil, navigationIcon == .none { navigationIcon = .arrow }
        setShowsLeadingView(true, animated: animated)
    }

    /**
     * Takes the back button out to the left, the field growing back.
     */
    @objc(hideBackButtonAnimated:)
    public func hideBackButton(animated: Bool = true) {
        setShowsLeadingView(false, animated: animated)
    }

    /**
     * Back to the plain look: no outline, no fill of its own, capsule field, magnifier, no shadow, a left-aligned placeholder.
     * The presets start from it.
     */
    func resetFieldLook() {
        searchBarStyle = .plain
        fieldBorderColor = nil
        fieldBorderWidth = 0
        customFieldBackgroundColor = nil
        fieldCornerRadius = -1
        fieldShadowOpacity = 0
        centersPlaceholder = false
        searchIcon = UIImage(systemName: "magnifyingglass")
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: 16))
        applyStyle()
    }

    // MARK: - Focus on appear, keyboard on outside touch

    private static let focusOnAppearKey = "CYLSearchBarViewFocusOnAppear"
    private static let focusOnActiveKey = "CYLSearchBarViewFocusOnActive"
    private static let outsideTouchKey = "CYLSearchBarViewOutsideTouch"

    /**
     * Whether the field takes focus (and the keyboard, with the search key, shows) every time the bar appears on screen, like a
     * `viewDidAppear`: the first time its page is entered, after a push and pop, and after the app returns from the background, but
     * only on a second-level or deeper page (`isOnSecondLevelOrDeeperPage`: the page is not the first view controller of its
     * navigation controller): a first-level page, such as a root tab page, never focuses. The moments are CYLDeallocBlockExecutor's `didEnterScreen` and `appDidBecomeActiveOnScreen` of this
     * view, so it works in every container; during a screen transition the focus waits for the transition to end. Nothing is
     * observed while this is NO. NO by default.
     */
    @objc public var focusesOnAppear = false {
        didSet {
            guard focusesOnAppear != oldValue else { return }
            if focusesOnAppear {
                cylAddLifecycleCallback(for: .didEnterScreen, key: Self.focusOnAppearKey) { bar, _, _ in bar.focusIfAppearing() }
                cylAddLifecycleCallback(for: .appDidBecomeActiveOnScreen, key: Self.focusOnActiveKey) { bar, _, _ in bar.focusIfAppearing() }
                if isOnScreenNow { focusIfAppearing() }
            } else {
                cylCancelLifecycleCallback(key: Self.focusOnAppearKey)
                cylCancelLifecycleCallback(key: Self.focusOnActiveKey)
            }
        }
    }

    private var isOnScreenNow: Bool {
        window != nil && !isHidden && alpha > 0.01
    }

    /**
     * Whether the bar is on a second-level or deeper page: its page (the view controller that holds it, or the top one when the bar
     * is the title view of a navigation bar) is not the first view controller of its navigation controller; a bar in a
     * `CYLSearchNavigationBar` with a back item counts too. A root tab page, a plain bar and a bar outside any navigation stack are
     * first-level. This is the rule of `focusesOnAppear` (owner decision 2026-11-26: first-level pages never focus themselves).
     */
    var isOnSecondLevelOrDeeperPage: Bool {
        // A host that knows its depth (Flutter, React Native: no navigation controller to read) sets `pageDepth`.
        if pageDepth >= 0 { return pageDepth >= 1 }
        var responder: UIResponder? = self
        var owner: UIViewController?
        var navigation: UINavigationController?
        while let current = responder {
            if let coreBar = current as? CYLSearchNavigationBar {
                return (coreBar.items?.count ?? 0) > 1
            }
            if let found = current as? UINavigationController {
                navigation = found
                break
            }
            if owner == nil, let found = current as? UIViewController {
                owner = found
            }
            responder = current.next
        }
        guard let navigation else { return false }
        var candidate: UIViewController? = owner ?? navigation.topViewController
        while let page = candidate {
            if let index = navigation.viewControllers.firstIndex(of: page) { return index >= 1 }
            candidate = page.parent
        }
        return false
    }

    /**
     * The depth of the page the bar is on, set by a host that has no navigation controller to read: 0 is a first-level page, 1 or
     * more a second-level or deeper one. -1 (the default) reads the navigation stack (`isOnSecondLevelOrDeeperPage`).
     */
    @objc public var pageDepth = -1

    private func focusIfAppearing() {
        guard focusesOnAppear, window != nil, textField.isEnabled, isOnSecondLevelOrDeeperPage else { return }
        var responder: UIResponder? = self
        var controller: UIViewController?
        while let current = responder {
            if let found = current as? UIViewController {
                controller = found
                break
            }
            responder = current.next
        }
        if let coordinator = controller?.transitionCoordinator ?? controller?.navigationController?.transitionCoordinator {
            coordinator.animate(alongsideTransition: nil) { [weak self] context in
                if !context.isCancelled { self?.focusNow() }
            }
        } else {
            DispatchQueue.main.async { [weak self] in self?.focusNow() }
        }
    }

    private func focusNow() {
        guard focusesOnAppear, window != nil, !isHidden, !textField.isFirstResponder else { return }
        showKeyboard()
    }

    /**
     * Whether a touch anywhere in the window outside this bar (a tap, or the start of a scroll or drag in any container) hides the
     * keyboard while the field is editing: CYLDeallocBlockExecutor's `didTouchOutside`, observed only while editing. YES by default;
     * an editing bar (`editingBar(...)`) drives its own focus and never does. A pointer or trackpad scroll is not a touch.
     */
    @objc public var dismissesKeyboardOnOutsideTouch = true {
        didSet {
            if !dismissesKeyboardOnOutsideTouch { stopObservingOutsideTouches() }
            else if textField.isFirstResponder { startObservingOutsideTouches() }
        }
    }

    private func startObservingOutsideTouches() {
        guard dismissesKeyboardOnOutsideTouch, !isEditingBar else { return }
        cylAddLifecycleCallback(for: .didTouchOutside, key: Self.outsideTouchKey) { bar, _, _ in bar.hideKeyboardForOutsideTouch() }
    }

    private func stopObservingOutsideTouches() {
        cylCancelLifecycleCallback(key: Self.outsideTouchKey)
    }

    func hideKeyboardForOutsideTouch() {
        guard dismissesKeyboardOnOutsideTouch, textField.isFirstResponder else { return }
        hideKeyboard()
    }

    /**
     * Ends editing and hides the keyboard.
     */
    @objc public func hideKeyboard() {
        textField.resignFirstResponder()
    }

    // MARK: - Buttons

    private var showsNavigationButton: Bool {
        leadingView == nil && (navigationImage != nil || navigationIcon != .none)
    }

    private var effectiveLeadingView: UIView? {
        leadingView ?? (showsNavigationButton ? navigationButton : nil)
    }

    private var effectiveAccessoryViews: [UIView] {
        var views = (trailingAccessoryViewsShow ? trailingAccessoryViews : []) + (itemStack.itemViews.isEmpty ? [] : [itemStack as UIView])
        let hasText = !(textField.text ?? "").isEmpty
        if showsVoiceButton && !hasText {
            views.append(voiceButton)
        }
        if showsSubmitButton && hasText {
            views.append(submitButton)
        }
        return views
    }

    private func updateButtonImages() {
        var navigation = navigationImage
        if navigation == nil && navigationIcon == .arrow {
            navigation = UIImage(systemName: "chevron.backward")
        }
        if navigation == nil && navigationIcon == .search {
            navigation = UIImage(systemName: "magnifyingglass")
        }
        var configuration = navigationButton.configuration ?? .plain()
        configuration.image = navigation
        configuration.background.backgroundColor = navigationBackgroundColor ?? .clear
        configuration.cornerStyle = .capsule
        navigationButton.configuration = configuration
        navigationButton.layer.shadowOpacity = Float(navigationShadowOpacity)
        navigationButton.layer.shadowRadius = 3
        navigationButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        navigationButton.accessibilityLabel = navigationAccessibilityLabel
        navigationButton.largeContentTitle = navigationAccessibilityLabel
        voiceButton.setImage(voiceImage, for: .normal)
        submitButton.setImage(submitImage, for: .normal)
        clearButton.setImage(clearImage, for: .normal)
        iconButton.setImage(searchIcon, for: .normal)
        setNeedsLayout()
    }

    // MARK: - Iconified

    /**
     * Opens or closes the field, with `expansionAnimation` when `animated` is YES. Opening also starts editing.
     */
    @objc(setIconified:animated:)
    public func setIconified(_ iconified: Bool, animated: Bool) {
        if iconifiedState == iconified {
            if !iconified && animated {
                textField.becomeFirstResponder()
            }
            return
        }
        iconifiedState = iconified
        if iconified {
            textField.resignFirstResponder()
        }
        guard animated, animationDuration > 0, window != nil else {
            applyIconifiedVisibility()
            setNeedsLayout()
            layoutIfNeeded()
            if !iconified && animated {
                textField.becomeFirstResponder()
            }
            notifyIconified()
            return
        }
        layoutIfNeeded()
        let iconFrame = iconButton.frame
        animatingExpansion = true
        fieldView.isHidden = false
        iconButton.isHidden = false
        setNeedsLayout()
        layoutIfNeeded()
        let fieldFrame = fieldView.frame
        let center = convert(CGPoint(x: iconFrame.midX, y: iconFrame.midY), to: fieldView)
        let radius = hypot(max(center.x, fieldFrame.width - center.x), max(center.y, fieldFrame.height - center.y))
        let iconRadius = max(iconFrame.width, iconFrame.height) / 2
        if expansionAnimation == .circularReveal {
            let mask = CAShapeLayer()
            let small = UIBezierPath(arcCenter: center, radius: iconRadius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
            let large = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
            mask.path = (iconified ? small : large).cgPath
            fieldView.layer.mask = mask
            let reveal = CABasicAnimation(keyPath: "path")
            reveal.fromValue = (iconified ? large : small).cgPath
            reveal.toValue = (iconified ? small : large).cgPath
            reveal.duration = animationDuration
            reveal.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            mask.add(reveal, forKey: "reveal")
        } else {
            fieldView.frame = iconified ? fieldFrame : iconFrame
            fieldView.alpha = iconified ? 1 : 0
        }
        iconButton.alpha = iconified ? 0 : 1
        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
            if self.expansionAnimation == .fade {
                self.fieldView.frame = iconified ? iconFrame : fieldFrame
                self.fieldView.alpha = iconified ? 0 : 1
            }
            self.iconButton.alpha = iconified ? 1 : 0
        }, completion: { _ in
            self.animatingExpansion = false
            self.fieldView.layer.mask = nil
            self.fieldView.alpha = 1
            self.iconButton.alpha = 1
            self.applyIconifiedVisibility()
            self.setNeedsLayout()
            if !iconified {
                self.textField.becomeFirstResponder()
            }
            self.notifyIconified()
        })
    }

    private func applyIconifiedVisibility() {
        let multiple = mode == .multiple
        fieldView.isHidden = isIconified || multiple
        iconButton.isHidden = !isIconified || multiple
        cancelButton.isHidden = isIconified || (!showsCancelButton && !hidingCancelButton) || multiple
        effectiveLeadingView?.isHidden = isIconified || multiple || (!leadingViewShows && !hidingLeadingView)
        navigationButton.isHidden = isIconified || !showsNavigationButton || multiple
        multiSearchView.isHidden = !multiple
    }

    private func notifyIconified() {
        UIAccessibility.post(notification: .layoutChanged, argument: isIconified ? iconButton : textField)
        delegate?.searchBarView?(self, didChangeIconified: isIconified)
    }

    // MARK: - State restoration

    /**
     * Saves the text, whether it is editing and whether it is iconified (`onSaveInstanceState`).
     */
    override public func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        coder.encode(textField.text ?? "", forKey: "CYLSearchBarText")
        coder.encode(textField.isFirstResponder, forKey: "CYLSearchBarEditing")
        coder.encode(isIconified, forKey: "CYLSearchBarIconified")
    }

    /**
     * Restores the text, the iconified state and editing (`onRestoreInstanceState`).
     */
    override public func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        if let text = coder.decodeObject(of: NSString.self, forKey: "CYLSearchBarText") as String? {
            self.text = text
        }
        if coder.containsValue(forKey: "CYLSearchBarIconified") {
            setIconified(coder.decodeBool(forKey: "CYLSearchBarIconified"), animated: false)
        }
        if coder.decodeBool(forKey: "CYLSearchBarEditing") {
            DispatchQueue.main.async { self.textField.becomeFirstResponder() }
        }
    }

    // MARK: - Style

    /**
     * `fieldHeight`, or taller when the scaled text needs it.
     */
    private var effectiveFieldHeight: CGFloat {
        max(fieldHeight, ceil(font.lineHeight + 12))
    }

    private func applyStyle() {
        textField.font = font
        textField.textColor = textColor
        if let placeholder = placeholderLabel.text, !placeholder.isEmpty {
            textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: UIColor.clear, .font: font as UIFont])
        }
        placeholderLabel.font = font
        placeholderLabel.textColor = placeholderColor ?? .secondaryLabel
        updatePlaceholderVisibility()
        fieldView.backgroundColor = fieldBackgroundColor
        fieldView.layer.borderColor = fieldBorderColor?.resolvedColor(with: traitCollection).cgColor
        fieldView.layer.borderWidth = fieldBorderColor != nil ? fieldBorderWidth : 0
        fieldView.layer.shadowColor = UIColor.black.cgColor
        fieldView.layer.shadowOpacity = Float(fieldShadowOpacity)
        fieldView.layer.shadowRadius = 6
        fieldView.layer.shadowOffset = CGSize(width: 0, height: 2)
        searchIconView.tintColor = searchIconTintColor
        iconButton.tintColor = searchIconTintColor
        voiceButton.tintColor = searchIconTintColor
        clearButton.tintColor = searchIconTintColor
        // A configuration updates the title at once (a legacy button could keep drawing the previous one).
        var configuration = cancelButton.configuration ?? .plain()
        configuration.attributedTitle = AttributedString(NSAttributedString(string: cancelButtonTitle, attributes: [.font: cancelFont]))
        configuration.titleLineBreakMode = .byClipping
        cancelButton.configuration = configuration
        // The title may be drawn smaller to fit; VoiceOver and the large content viewer still get the whole title.
        cancelButton.accessibilityLabel = cancelButtonTitle
        cancelButton.largeContentTitle = cancelButtonTitle
        multiSearchView.applyStyle()
        setNeedsLayout()
    }

    private var cancelFont: UIFont {
        cancelButtonFont ?? font
    }

    private func setCancelTitleFont(_ titleFont: UIFont) {
        guard var configuration = cancelButton.configuration, let title = configuration.attributedTitle, !title.characters.isEmpty else {
            return
        }
        if NSAttributedString(title).attribute(.font, at: 0, effectiveRange: nil) as? UIFont == titleFont {
            return
        }
        configuration.attributedTitle = AttributedString(NSAttributedString(string: cancelButtonTitle, attributes: [.font: titleFont]))
        cancelButton.configuration = configuration
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyStyle()
        if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            invalidateIntrinsicContentSize()
        }
    }

    override public func tintColorDidChange() {
        super.tintColorDidChange()
        multiSearchView.applyStyle()
    }

    // MARK: - Layout

    /**
     * True after `embedInNavigationBar(of:)`: the bar is the title view of a navigation bar and fills its width.
     */
    @objc public internal(set) var isEmbeddedInNavigationBar = false {
        didSet { invalidateIntrinsicContentSize() }
    }

    override public var intrinsicContentSize: CGSize {
        if mode == .multiple {
            return CGSize(width: UIView.noIntrinsicMetric, height: multiSearchView.preferredHeight)
        }
        // In a navigation bar the title view takes the whole width the bar can give.
        let width = isEmbeddedInNavigationBar ? UIView.layoutFittingExpandedSize.width : UIView.noIntrinsicMetric
        return CGSize(width: width, height: effectiveFieldHeight + contentInsets.top + contentInsets.bottom)
    }

    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        // A navigation bar asks a title view with a zero width first: it answers with the whole width it may take.
        CGSize(width: isEmbeddedInNavigationBar ? UIView.layoutFittingExpandedSize.width : size.width, height: intrinsicContentSize.height)
    }

    private static func fittingSize(of view: UIView, height: CGFloat) -> CGSize {
        var size = view.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: height))
        if size.width <= 0 || size.height <= 0 {
            size = view.intrinsicContentSize
        }
        return CGSize(width: max(0, size.width), height: min(height, max(0, size.height)))
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        // A bar in a navigation bar is a system-owned view: CYLDeallocBlockExecutor re-evaluates its on-screen state only at window
        // moves, when a pushed page's bar may still be off screen. Ask again after every layout while it waits to focus.
        if focusesOnAppear, window != nil { cylRefreshScreenState() }
        if mode == .multiple {
            // The searches take the whole height; the field and its buttons are hidden.
            let width = max(0, bounds.width - contentInsets.left - contentInsets.right)
            multiSearchView.frame = CGRect(x: contentInsets.left, y: 0, width: width, height: bounds.height)
            return
        }
        let insets = CYLSearchBarAppearance.margins(of: textFieldMarginsProvider, bar: self, active: isSearchActive,
                                                    resting: contentInsets)
        let height = bounds.height
        let fieldHeight = min(effectiveFieldHeight, max(0, height - insets.top - insets.bottom))
        let y = floor((height - fieldHeight) / 2)
        var leading = insets.left
        var trailing = bounds.width - insets.right
        navigationButton.isHidden = isIconified || !showsNavigationButton
        if let leadingView = effectiveLeadingView, leadingViewShows {
            var size = Self.fittingSize(of: leadingView, height: max(fieldHeight, 44))
            size.width = max(size.width, 44)
            size.height = max(size.height, min(44, height))
            leadingView.frame = CGRect(x: leading - 8, y: floor((height - size.height) / 2), width: size.width, height: size.height)
            leading += size.width - 8 + 2
        }
        // Iconified: only the search button, at `iconPosition`.
        let iconSide = min(max(44, fieldHeight), height)
        var iconX = bounds.width - insets.right - iconSide
        if iconPosition == .center {
            iconX = floor((bounds.width - iconSide) / 2)
        } else if iconPosition == .leading {
            iconX = insets.left
        }
        iconButton.frame = CGRect(x: iconX, y: floor((height - iconSide) / 2), width: iconSide, height: iconSide)
        // At large text sizes the text keeps at least this share of the bar; Cancel and the accessory views shrink first.
        let available = max(0, trailing - leading)
        let minimumTextWidth = max(44, floor(available * Self.minimumTextShare))
        if showsCancelButton && !isIconified {
            // The title's own width: a button's fitting size can lag behind a title or font set in the same pass.
            let titleWidth = CYLSearchBarAppearance.textWidth(cancelButtonTitle, font: cancelFont)
            let maximumWidth = max(44, floor(available * Self.maximumCancelShare))
            let width = min(max(44, titleWidth + 12), maximumWidth)
            let scale = titleWidth + 12 > width ? max(Self.minimumScale, (width - 12) / max(1, titleWidth)) : 1
            setCancelTitleFont(cancelFont.withSize(cancelFont.pointSize * scale))
            cancelButton.frame = CGRect(x: trailing - width, y: y, width: width, height: fieldHeight).inset(
                by: CYLSearchBarAppearance.margins(of: cancelButtonMarginsProvider, bar: self, active: isSearchActive,
                                                   resting: .zero))
            trailing -= width + Self.spacing
        }
        var field = CGRect(x: leading, y: y, width: max(0, trailing - leading), height: fieldHeight)
        if !animatingExpansion || !fieldView.isHidden {
            fieldView.frame = field
        }
        field = fieldView.frame
        field.size = CGSize(width: max(0, trailing - leading), height: fieldHeight)
        fieldView.layer.cornerRadius = CYLSearchBarAppearance.cornerRadius(fieldCornerRadius, height: fieldHeight)
        fieldBackgroundImageView.frame = CGRect(origin: .zero, size: field.size)
        fieldBackgroundImageView.layer.cornerRadius = fieldView.layer.cornerRadius

        let inner = max(10, min(14, fieldHeight / 3))
        var x = inner
        if searchIcon != nil {
            searchIconView.frame = CGRect(x: x, y: floor((fieldHeight - Self.iconSize) / 2), width: Self.iconSize, height: Self.iconSize)
            x += Self.iconSize + 6
        } else {
            searchIconView.frame = .zero
        }
        let accessories = effectiveAccessoryViews
        // The default icon button is a capsule inside the field's capsule: the same gap above, below and at its right, so the two
        // outlines run concentric (the reference look); other trailing views keep the usual inner inset.
        let endsWithCapsuleButton = accessories.last === itemStack && showsSearchButton && !isEditingBar && mode != .multiple
            && searchButtonStyle == .icon && searchButtonItem.itemHeight > 0
        let capsuleGap = max(0, floor((fieldHeight - searchButtonItem.itemHeight) / 2))
        var end = field.width - (endsWithCapsuleButton ? capsuleGap : inner)
        voiceButton.isHidden = !accessories.contains(voiceButton)
        submitButton.isHidden = !accessories.contains(submitButton)
        var sizes: [CGSize] = []
        var accessoriesWidth: CGFloat = 0
        for view in accessories {
            view.transform = .identity
            let size = Self.fittingSize(of: view, height: fieldHeight)
            sizes.append(size)
            accessoriesWidth += size.width + Self.spacing
        }
        // Views that would squeeze the text are drawn smaller (scaled as a whole, so a symbol keeps its shape).
        let room = max(0, end - x - minimumTextWidth)
        let accessoryScale = accessoriesWidth > room && accessoriesWidth > 0 ? max(Self.minimumAccessoryScale, room / accessoriesWidth) : 1
        for (view, size) in zip(accessories, sizes).reversed() {
            let width = size.width * accessoryScale
            view.bounds = CGRect(origin: .zero, size: size)
            view.center = CGPoint(x: end - width / 2, y: fieldHeight / 2)
            view.transform = accessoryScale < 1 ? CGAffineTransform(scaleX: accessoryScale, y: accessoryScale) : .identity
            end -= width + Self.spacing * accessoryScale
        }
        textField.frame = CGRect(x: x, y: 0, width: max(0, end - x), height: fieldHeight)
        let textRect = textField.textRect(forBounds: textField.bounds)
        placeholderLabel.frame = textRect.offsetBy(dx: textField.frame.minX, dy: textField.frame.minY)
        centerPlaceholderBlock(fieldWidth: field.width, baseline: inner, textStart: x, end: end)
    }

    /**
     * `centersPlaceholder`: moves the magnifier and the placeholder label, not the text field, so that the block is
     * centered in the field while the bar is not editing and has no text. The shift is limited by the room left of
     * the accessory views.
     */
    private func centerPlaceholderBlock(fieldWidth: CGFloat, baseline: CGFloat, textStart: CGFloat, end: CGFloat) {
        guard centersPlaceholder, !isSearchActive, (textField.text ?? "").isEmpty,
              let text = placeholderLabel.text, !text.isEmpty else { return }
        let iconBlock = searchIcon != nil ? Self.iconSize + 6 : 0
        let contentWidth = iconBlock + CYLSearchBarAppearance.textWidth(text, font: placeholderLabel.font)
        let shift = CYLSearchBarAppearance.centeringOffset(
            fieldWidth: fieldWidth, contentWidth: contentWidth, baseline: baseline, room: end - baseline - contentWidth)
        guard shift > 0 else { return }
        searchIconView.frame.origin.x += shift
        placeholderLabel.frame.origin.x += shift
        placeholderLabel.frame.size.width = max(0, placeholderLabel.frame.width - shift)
    }

    /**
     * The bar is active while its text field is the first responder.
     */
    private var isSearchActive: Bool {
        textField.isFirstResponder
    }

    /**
     * Lays the bar out again for the new state: the centered placeholder, the margins and the Cancel margins follow
     * editing, animated like the system's search bar.
     */
    private func relayoutForActiveState() {
        guard centersPlaceholder || textFieldMarginsProvider != nil || cancelButtonMarginsProvider != nil else { return }
        UIView.animate(withDuration: Self.accessoryAnimationDuration, delay: 0, options: .curveEaseInOut) {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }

    // MARK: - Events

    private func updatePlaceholderVisibility() {
        placeholderLabel.isHidden = !(textField.text ?? "").isEmpty
    }

    private func textStateChanged() {
        updatePlaceholderVisibility()
        clearButton.isHidden = (textField.text ?? "").isEmpty
        setNeedsLayout()
    }

    @objc private func textChanged() {
        textStateChanged()
        delegate?.searchBarView?(self, textDidChange: textField.text ?? "")
    }

    @objc private func cancelTapped() {
        if isEditingBar {
            // An editing bar's trailing button is its action, not a cancel.
            submitEditing()
            return
        }
        if clearsTextOnCancel, !(textField.text ?? "").isEmpty {
            textField.text = ""
            textChanged()
        }
        if cancelButtonEndsEditing {
            textField.resignFirstResponder()
        }
        delegate?.searchBarViewCancelButtonClicked?(self)
    }

    @objc private func navigationTapped() {
        delegate?.searchBarViewNavigationButtonClicked?(self)
        navigationHandler?(self)
    }

    @objc private func voiceTapped() {
        delegate?.searchBarViewVoiceButtonClicked?(self)
    }

    @objc private func submitTapped() {
        submit()
    }

    @objc private func clearTapped() {
        textField.text = ""
        textChanged()
    }

    @objc private func iconTapped() {
        setIconified(false, animated: true)
    }

    // MARK: - UITextFieldDelegate

    /**
     * Asks the delegate whether editing may start; a refusal reports a tap instead.
     */
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if pushesOnTap {
            // A first-level bar: the tap pushes the second-level page instead of editing.
            performFirstLevelTap()
            return false
        }
        if delegate?.searchBarViewShouldBeginEditing?(self) == false {
            delegate?.searchBarViewDidTapWhileNotEditable?(self)
            return false
        }
        return true
    }

    /**
     * The return key submits the text.
     */
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if isEditingBar {
            submitEditing()
            return false
        }
        submit()
        return true
    }

    /**
     * Enforces `maximumTextLength`; deleting is always allowed.
     */
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if maximumTextLength == 0 {
            return true
        }
        let length = ((textField.text ?? "") as NSString).length - range.length + (string as NSString).length
        return length <= Int(maximumTextLength) || string.isEmpty
    }

    /**
     * Reports the start of editing.
     */
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        relayoutForActiveState()
        startObservingOutsideTouches()
        delegate?.searchBarViewDidBeginEditing?(self)
    }

    /**
     * Clears the text and closes to the icon when configured, then reports the end of editing.
     */
    public func textFieldDidEndEditing(_ textField: UITextField) {
        relayoutForActiveState()
        stopObservingOutsideTouches()
        if clearsTextOnEndEditing, !(textField.text ?? "").isEmpty {
            textField.text = ""
            textChanged()
        }
        if iconifiedByDefault, (textField.text ?? "").isEmpty, !isIconified {
            setIconified(true, animated: true)
        }
        delegate?.searchBarViewDidEndEditing?(self)
    }

    /**
     * Starts editing in the text field.
     */
    override public func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }

    /**
     * Ends editing; the bar itself also gives up first responder as UIKit expects.
     */
    override public func resignFirstResponder() -> Bool {
        let resigned = textField.resignFirstResponder()
        return super.resignFirstResponder() && resigned
    }
}

/**
 * One element after the text of a `CYLSearchBarView`: a model independent of its view, like `CYLFlatDesignTabBarItem`.
 * Append it with `-[CYLSearchBarView addItem:]`; its view is `itemView`.
 */
@objc(CYLSearchBarItem)
@MainActor
public final class CYLSearchBarItem: NSObject {

    // MARK: - Properties

    /**
     * How the item looks (icon, divider or text); set when the item is created.
     */
    @objc public let style: CYLSearchBarItemStyle

    /**
     * The text of a text item, and the VoiceOver label of an icon item without `accessibilityLabel`.
     */
    @objc public var title: String? { didSet { itemChanged() } }

    /**
     * The icon (a template image is tinted with `tintColor`).
     */
    @objc public var image: UIImage? { didSet { itemChanged() } }

    /**
     * The icon while `selected` is YES; nil uses `image`.
     */
    @objc public var selectedImage: UIImage? { didSet { itemChanged() } }

    /**
     * An animated icon (`+[UIImage animatedImageWithImages:duration:]`), drawn instead of `image` when set.
     */
    @objc public var animatedImage: UIImage? { didSet { itemChanged() } }

    /**
     * An animated icon file (Lottie .json, .pag, .riv, .svga, .gif), drawn by the item's `CYLTagButton` (a
     * `CYLAnimatedItemView`) when the app adds the engine of its type (`CYLAnimatedItem/<Type>`;
     * the core adds none) and played on each tap. Otherwise `image` shows, or the component's placeholder when there
     * is no `image`.
     */
    @objc public var animationURL: URL? { didSet { itemChanged() } }

    /**
     * Whether `animationURL` plays again after each pass; NO plays once on each tap. The same on every platform.
     */
    @objc public var animationLoops = false { didSet { itemChanged() } }

    /**
     * The playback speed of `animationURL`; 1 is the file's own. An engine without speed ignores it. The same on every
     * platform.
     */
    @objc public var animationSpeed: CGFloat = 1 { didSet { itemChanged() } }

    /**
     * Plays `animationURL` again from the start, as a tap does. Does nothing without an animation. The same on every
     * platform.
     */
    @objc public func restartAnimation() {
        if animationURL != nil {
            itemView.restartAnimation()
        }
    }

    /**
     * The icon size; zero uses 20 x 20 pt.
     */
    @objc public var imageSize: CGSize = .zero { didSet { itemChanged() } }

    /**
     * What VoiceOver reads; nil reads `title`.
     */
    @objc public var itemAccessibilityLabel: String? { didSet { itemChanged() } }

    /**
     * A test identifier for the item view.
     */
    @objc public var itemAccessibilityIdentifier: String? { didSet { itemChanged() } }

    /**
     * NO dims the item and ignores taps. YES by default.
     */
    @objc public var isEnabled = true { didSet { itemChanged() } }

    /**
     * YES makes each tap toggle `selected` (a filter that stays on). NO by default.
     */
    @objc public var isSelectable = false

    /**
     * The selected state (drawn with `selectedImage`, `selectedBackgroundColor` and the selected title attributes).
     */
    @objc public var isSelected = false { didSet { itemChanged() } }

    /**
     * The icon and title color; nil uses the bar's `itemTintColor`.
     */
    @objc public var tintColor: UIColor? { didSet { itemChanged() } }

    /**
     * The item background; nil is clear.
     */
    @objc public var backgroundColor: UIColor? { didSet { itemChanged() } }

    /**
     * The item background while selected; nil uses `backgroundColor`.
     */
    @objc public var selectedBackgroundColor: UIColor? { didSet { itemChanged() } }

    /**
     * Space around the icon and title inside the item; `UIEdgeInsetsZero` uses the style's default.
     */
    @objc public var contentInsets: UIEdgeInsets = .zero { didSet { itemChanged() } }

    /**
     * `cornerRadius` that follows the item: 10 pt with a background, square without one.
     */
    @objc public static let automaticCornerRadius: CGFloat = -1

    /**
     * The corner radius of the item's background and border, in points: 0 is square, `CYLAnimatedItemCornerRadiusCapsule` a capsule,
     * `automaticCornerRadius` (the default) 10 pt with a background and square without one. The icon, the background and the border
     * are one view, the item's `CYLAnimatedItemView`.
     */
    @objc public var cornerRadius: CGFloat = CYLSearchBarItem.automaticCornerRadius { didSet { itemChanged() } }

    /**
     * The border color of the item's own outline; nil (the default) draws none.
     */
    @objc public var borderColor: UIColor? { didSet { itemChanged() } }

    /**
     * The width of the item's own outline, in points; 0 by default.
     */
    @objc public var borderWidth: CGFloat = 0 { didSet { itemChanged() } }

    /**
     * The height of the item in points; 0 (the default) is the 36 pt touch size.
     */
    @objc public var itemHeight: CGFloat = 0 { didSet { itemChanged() } }

    /**
     * Moves the icon without changing the item's size.
     */
    @objc public var imagePositionAdjustment: UIOffset = .zero { didSet { itemChanged() } }

    /**
     * Moves the title without changing the item's size.
     */
    @objc public var titlePositionAdjustment: UIOffset = .zero { didSet { itemChanged() } }

    /**
     * The badge text; nil hides the badge, an empty string draws a dot.
     */
    @objc public var badgeValue: String? { didSet { itemChanged() } }

    /**
     * The badge background; nil is system red.
     */
    @objc public var badgeColor: UIColor? { didSet { itemChanged() } }

    /**
     * The smallest badge size; zero uses 16 x 16 pt (a dot is 8 x 8 pt).
     */
    @objc public var badgeSize: CGSize = .zero { didSet { itemChanged() } }

    /**
     * Space around the badge text.
     */
    @objc public var badgeContentInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4) { didSet { itemChanged() } }

    /**
     * Moves the badge from the icon's top trailing corner.
     */
    @objc public var badgePositionAdjustment: UIOffset = .zero { didSet { itemChanged() } }

    /**
     * Called on each tap, after `-searchBarView:didSelectItem:`.
     */
    @objc public var handler: ((CYLSearchBarItem) -> Void)?

    /**
     * The bar the item was appended to; nil before `-addItem:` and after `-removeItem:`.
     */
    @objc public internal(set) weak var searchBarView: CYLSearchBarView?

    /**
     * The item's position in its bar's `items`; `NSNotFound` when it is in no bar.
     */
    @objc public var index: Int {
        searchBarView?.items.firstIndex(of: self) ?? NSNotFound
    }

    /**
     * The item's view, a `CYLTagButton` (CollectionViewClassifyMenu) created on first use. The bar adds it inside its
     * field and sends its taps to `-searchBarView:didSelectItem:` and `handler`.
     */
    @objc public var itemView: CYLTagButton {
        itemControl
    }

    lazy var itemControl = CYLSearchBarItemButton(item: self)

    private var titleAttributes: [UInt: [NSAttributedString.Key: Any]] = [:]
    private var badgeAttributes: [UInt: [NSAttributedString.Key: Any]] = [:]

    // MARK: - Initializers

    /**
     * An item of the given style with a title and an icon.
     */
    @objc(initWithStyle:title:image:)
    public init(style: CYLSearchBarItemStyle, title: String?, image: UIImage?) {
        self.style = style
        self.title = title
        self.image = image
        super.init()
    }

    /**
     * An icon item, or a text item when the title is set and the image is nil.
     */
    @objc(initWithTitle:image:)
    public convenience init(title: String?, image: UIImage?) {
        self.init(style: image == nil && title != nil ? .text : .icon, title: title, image: image)
    }

    /**
     * Like `-initWithTitle:image:`, with an icon for the selected state.
     */
    @objc(initWithTitle:image:selectedImage:)
    public convenience init(title: String?, image: UIImage?, selectedImage: UIImage?) {
        self.init(title: title, image: image)
        self.selectedImage = selectedImage
    }

    /**
     * An icon item: the title is what VoiceOver reads.
     */
    @objc(iconItemWithImage:title:handler:)
    public static func iconItem(image: UIImage?, title: String?, handler: ((CYLSearchBarItem) -> Void)?) -> CYLSearchBarItem {
        let item = CYLSearchBarItem(style: .icon, title: title, image: image)
        item.handler = handler
        return item
    }

    /**
     * A text item (a "Search" button).
     */
    @objc(textItemWithTitle:handler:)
    public static func textItem(title: String, handler: ((CYLSearchBarItem) -> Void)?) -> CYLSearchBarItem {
        let item = CYLSearchBarItem(style: .text, title: title, image: nil)
        item.handler = handler
        return item
    }

    /**
     * A divider between two items.
     */
    @objc(dividerItem)
    public static func divider() -> CYLSearchBarItem {
        CYLSearchBarItem(style: .divider, title: nil, image: nil)
    }

    /**
     * An item from plain values, for the cross-platform wrappers (Flutter, React Native): `style` (`icon`, `divider`,
     * `text`), `title`, `image` (`camera`, `mic`, `search`, `back`, else an asset or SF Symbol name),
     * `accessibilityIdentifier`, `isEnabled`, `isSelectable`, `isSelected`, `badgeValue`. Android: `fromMap`.
     */
    @objc(itemWithDictionary:)
    public static func item(dictionary: [String: Any]) -> CYLSearchBarItem {
        let style: CYLSearchBarItemStyle
        switch dictionary["style"] as? String {
        case "divider":
            style = .divider
        case "text":
            style = .text
        default:
            style = .icon
        }
        let item = CYLSearchBarItem(style: style, title: dictionary["title"] as? String, image: namedImage(dictionary["image"] as? String))
        item.itemAccessibilityIdentifier = dictionary["accessibilityIdentifier"] as? String
        item.isEnabled = dictionary["isEnabled"] as? Bool ?? true
        item.isSelectable = dictionary["isSelectable"] as? Bool ?? false
        item.isSelected = dictionary["isSelected"] as? Bool ?? false
        item.badgeValue = dictionary["badgeValue"] as? String
        if let url = dictionary["animationURL"] as? String, !url.isEmpty {
            // A name with no scheme and no leading slash is a file in the app's main bundle ("tab_activity.svga").
            if url.contains(":") || url.hasPrefix("/") {
                item.animationURL = URL(string: url)
            } else {
                item.animationURL = Bundle.main.url(forResource: (url as NSString).deletingPathExtension,
                                                    withExtension: (url as NSString).pathExtension)
            }
        }
        item.animationLoops = dictionary["animationLoops"] as? Bool ?? false
        item.animationSpeed = CGFloat((dictionary["animationSpeed"] as? NSNumber)?.doubleValue ?? 1)
        if style == .icon {
            item.imageSize = CGSize(width: 22, height: 22)
        }
        return item
    }

    private static func namedImage(_ name: String?) -> UIImage? {
        guard let name, !name.isEmpty else {
            return nil
        }
        let symbols = ["camera": "camera.viewfinder", "mic": "mic", "search": "magnifyingglass", "back": "chevron.backward"]
        if let symbol = symbols[name] {
            return UIImage(systemName: symbol)
        }
        return UIImage(named: name) ?? UIImage(systemName: name)
    }

    // MARK: - Text attributes

    /**
     * The title attributes for a state (`UIControlStateNormal`, `UIControlStateSelected`, `UIControlStateDisabled`).
     */
    @objc(setTitleTextAttributes:forState:)
    public func setTitleTextAttributes(_ attributes: [NSAttributedString.Key: Any]?, for state: UIControl.State) {
        titleAttributes[state.rawValue] = attributes
        itemChanged()
    }

    /**
     * The title attributes set for a state, or nil.
     */
    @objc(titleTextAttributesForState:)
    public func titleTextAttributes(for state: UIControl.State) -> [NSAttributedString.Key: Any]? {
        titleAttributes[state.rawValue]
    }

    /**
     * The badge text attributes for a state.
     */
    @objc(setBadgeTextAttributes:forState:)
    public func setBadgeTextAttributes(_ attributes: [NSAttributedString.Key: Any]?, for state: UIControl.State) {
        badgeAttributes[state.rawValue] = attributes
        itemChanged()
    }

    /**
     * The badge text attributes set for a state, or nil.
     */
    @objc(badgeTextAttributesForState:)
    public func badgeTextAttributes(for state: UIControl.State) -> [NSAttributedString.Key: Any]? {
        badgeAttributes[state.rawValue]
    }

    /**
     * The view the badge is drawn in (the item view).
     */
    @objc public func actualBadgeSuperView() -> UIView {
        itemView
    }

    // MARK: - Private

    var currentState: UIControl.State {
        if !isEnabled {
            return .disabled
        }
        return isSelected ? .selected : .normal
    }

    private func itemChanged() {
        itemControl.reload()
        searchBarView?.setNeedsLayout()
    }
}

/**
 * The view of a `CYLSearchBarItem`: CollectionViewClassifyMenu's `CYLTagButton` (the one icon + title + animated icon
 * component), styled from the item for each state, plus what only a bar item has: the link to its item, the divider
 * line, the 36 pt touch area and the item's badge metrics. The item's `itemView` returns it.
 */
@MainActor
final class CYLSearchBarItemButton: CYLTagButton {

    private static let defaultImageSide: CGFloat = 20
    private static let minimumTouchSide: CGFloat = 36
    private static let dividerHeight: CGFloat = 18
    private static let imageTitleSpacing: CGFloat = 4
    private static let backgroundCornerRadius: CGFloat = 10
    /**
     * Square corners for a bar item without a background: 0 is square (CollectionViewClassifyMenu's numeric radius).
     */
    private static let squareCornerRadius: CGFloat = 0
    private static let disabledAlpha: CGFloat = 0.4
    private static let states: [UIControl.State] = [.normal, .selected, .disabled]

    /**
     * The item this view draws.
     */
    @objc private(set) weak var item: CYLSearchBarItem?

    private let dividerLayer = CALayer()

    /**
     * The view for an item; the item's `itemView` is the one the bar shows.
     */
    init(item: CYLSearchBarItem) {
        self.item = item
        super.init(frame: .zero)
        imageView.isUserInteractionEnabled = false
        titleLabel.isUserInteractionEnabled = false
        titleLabel.adjustsFontForContentSizeCategory = true
        badgeLabel.isUserInteractionEnabled = false
        layer.addSublayer(dividerLayer)
        showsLargeContentViewer = true
        addInteraction(UILargeContentViewerInteraction())
        addInteraction(UIPointerInteraction())
        reload()
    }

    /**
     * Not supported: an item view is created from its item.
     */
    required init?(coder: NSCoder) {
        nil
    }

    private var resolvedTint: UIColor? {
        item?.tintColor ?? item?.searchBarView?.itemTintColor
    }

    private var resolvedImageSize: CGSize {
        guard let size = item?.imageSize, size.width > 0, size.height > 0 else {
            return CGSize(width: Self.defaultImageSide, height: Self.defaultImageSide)
        }
        return size
    }

    private var resolvedInsets: UIEdgeInsets {
        guard let item, item.contentInsets == .zero else {
            return item?.contentInsets ?? .zero
        }
        switch item.style {
        case .text:
            return UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        case .icon, .divider:
            return .zero
        }
    }

    /**
     * The tag style that draws the item: no border, the item's background (clear by default), its tint for the title
     * and template icons, its title attributes per state, its icon size, insets and position adjustments.
     */
    private func makeStyle(for item: CYLSearchBarItem) -> CYLMenuStyle {
        let style = CYLMenuStyle()
        let tint = resolvedTint
        let insets = resolvedInsets
        let hasBackground = item.backgroundColor != nil || item.selectedBackgroundColor != nil
        style.imageSize = resolvedImageSize
        style.animationSize = resolvedImageSize
        // The item is the only source of the speed: the style agrees with it, so a tag that goes back to its style's
        // speed (`resetAnimationSpeed()`) does not fall back to 1.
        style.animationSpeed = item.animationSpeed
        style.imageTitleSpacing = Self.imageTitleSpacing
        style.itemHeight = item.style == .divider ? Self.dividerHeight : (item.itemHeight > 0 ? item.itemHeight : Self.minimumTouchSide)
        style.imagePositionAdjustment = item.imagePositionAdjustment
        style.titlePositionAdjustment = item.titlePositionAdjustment
        style.adjustsFontForContentSizeCategory = true
        for state in Self.states {
            let appearance = style.appearance(for: state)
            let attributes = item.titleTextAttributes(for: state) ?? item.titleTextAttributes(for: .normal)
            appearance.font = attributes?[.font] as? UIFont ?? .systemFont(ofSize: 17, weight: .semibold)
            // Colors the host did not set stay unset: the component draws its own default tint (label, the inherited
            // tint when selected, dimmed when disabled), which follows dark mode.
            if let color = attributes?[.foregroundColor] as? UIColor ?? tint {
                appearance.textColor = color
            }
            if let tint {
                appearance.iconColor = tint
            }
            let background = item.isSelected ? (item.selectedBackgroundColor ?? item.backgroundColor) : item.backgroundColor
            appearance.backgroundColor = background ?? .clear
            appearance.borderColor = item.borderColor
            appearance.borderWidth = item.borderColor == nil ? 0 : item.borderWidth
            appearance.contentInsets = insets
            if item.cornerRadius != CYLSearchBarItem.automaticCornerRadius {
                appearance.cornerRadius = item.cornerRadius
            } else {
                appearance.cornerRadius = hasBackground ? Self.backgroundCornerRadius : Self.squareCornerRadius
            }
        }
        return style
    }

    func reload() {
        guard let item else {
            return
        }
        style = makeStyle(for: item)
        // A text item shows its title (and its icon before it); an icon item only its icon, the title is what
        // VoiceOver reads; a divider neither.
        title = item.style == .text ? item.title : nil
        image = item.style == .divider ? nil : (item.animatedImage ?? item.image)
        selectedImage = item.style == .divider || item.animatedImage != nil ? nil : item.selectedImage
        animationURL = item.style == .divider ? nil : item.animationURL
        animationLoops = item.animationLoops
        animationSpeed = item.animationSpeed
        badgeValue = item.style == .divider ? nil : item.badgeValue
        badgeColor = item.badgeColor
        isEnabled = item.isEnabled
        isSelected = item.isSelected
        alpha = item.isEnabled ? 1 : Self.disabledAlpha
        dividerLayer.isHidden = item.style != .divider
        dividerLayer.backgroundColor = UIColor.separator.resolvedColor(with: traitCollection).cgColor
        isAccessibilityElement = item.style != .divider
        accessibilityLabel = item.itemAccessibilityLabel ?? item.title
        accessibilityIdentifier = item.itemAccessibilityIdentifier
        accessibilityTraits = item.isSelectable && item.isSelected ? [.button, .selected] : .button
        if !item.isEnabled {
            accessibilityTraits.insert(.notEnabled)
        }
        largeContentTitle = item.itemAccessibilityLabel ?? item.title
        largeContentImage = item.animatedImage ?? (item.isSelected ? (item.selectedImage ?? item.image) : item.image)
        isUserInteractionEnabled = item.style != .divider
        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        dividerLayer.backgroundColor = UIColor.separator.resolvedColor(with: traitCollection).cgColor
    }

    override var intrinsicContentSize: CGSize {
        sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let item else {
            return .zero
        }
        let fitting = super.intrinsicContentSize
        switch item.style {
        case .divider:
            let insets = resolvedInsets
            return CGSize(width: 1 + insets.left + insets.right, height: Self.dividerHeight)
        case .icon:
            if item.itemHeight > 0 {
                // A sized item (the default search button's capsule): its own height, as wide as its icon and insets need.
                return CGSize(width: max(item.itemHeight, fitting.width), height: item.itemHeight)
            }
            let side = max(Self.minimumTouchSide, max(fitting.width, fitting.height))
            return CGSize(width: side, height: side)
        case .text:
            return CGSize(width: max(Self.minimumTouchSide, fitting.width), height: max(Self.minimumTouchSide, fitting.height))
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let item else {
            return
        }
        if item.style == .divider {
            let insets = resolvedInsets
            dividerLayer.frame = CGRect(x: insets.left, y: floor((bounds.height - Self.dividerHeight) / 2), width: 1,
                                        height: min(Self.dividerHeight, bounds.height))
        }
        // The whole item is dimmed while disabled; the animated icon is not dimmed a second time.
        animationView?.alpha = 1
        layOutItemBadge(item: item)
    }

    /**
     * The item's badge metrics on the tag's badge: its text attributes, smallest size, text insets and position
     * adjustment, at the top trailing corner of the icon (or of the title).
     */
    private func layOutItemBadge(item: CYLSearchBarItem) {
        guard let value = item.badgeValue, item.style != .divider else {
            return
        }
        let attributes = item.badgeTextAttributes(for: currentItemState) ?? item.badgeTextAttributes(for: .normal)
        if let attributes, !value.isEmpty {
            badgeLabel.attributedText = NSAttributedString(string: value, attributes: attributes)
        }
        let isDot = value.isEmpty
        let minimum = item.badgeSize.width > 0 && item.badgeSize.height > 0 ? item.badgeSize : CGSize(width: 16, height: 16)
        var size = isDot ? CGSize(width: 8, height: 8) : minimum
        if !isDot {
            let text = badgeLabel.intrinsicContentSize
            size.width = max(size.width, ceil(text.width) + item.badgeContentInsets.left + item.badgeContentInsets.right)
            size.height = max(size.height, ceil(text.height) + item.badgeContentInsets.top + item.badgeContentInsets.bottom)
        }
        let anchor: CGRect
        if let animationView {
            anchor = animationView.frame
        } else if imageView.image != nil && imageView.bounds.width > 0 {
            anchor = imageView.frame
        } else {
            anchor = titleLabel.frame
        }
        // Kept inside the tag, which clips its content.
        let x = max(0, min(anchor.maxX - size.width / 2 + item.badgePositionAdjustment.horizontal, bounds.width - size.width))
        let y = max(0, min(anchor.minY - size.height / 2 + item.badgePositionAdjustment.vertical, bounds.height - size.height))
        badgeLabel.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
        badgeLabel.layer.cornerRadius = size.height / 2
    }

    private var currentItemState: UIControl.State {
        if !isEnabled {
            return .disabled
        }
        return isSelected ? .selected : .normal
    }
}

/**
 * One search of `CYLSearchBarModeMultiple`: its text field, and a remove button shown while it is selected.
 */
private final class CYLSearchBarSearchEntryView: UIView {
    @objc let textField = UITextField()
    @objc let removeButton = UIButton(configuration: .plain(), primaryAction: nil)
    var editing = false
}

/**
 * The content of a `CYLSearchBarView` in `CYLSearchBarModeMultiple`; it was the public `CYLMultiSearchView`, a port of
 * iammert `MultiSearchView`. The search button starts a new search; a completed search becomes an entry in a
 * horizontally scrolling row, with an indicator under the selected entry and a remove button on it. The style comes
 * from the bar, and the events go to the bar's delegate.
 */
private final class CYLSearchBarMultiSearchView: UIView, UITextFieldDelegate {

    private static let itemPadding: CGFloat = 12
    private static let removeSize: CGFloat = 28
    private static let indicatorHeight: CGFloat = 2

    weak var searchBarView: CYLSearchBarView?
    private(set) var selectedIndex = NSNotFound
    private(set) var isEditingNewSearch = false
    let searchButton = UIButton(configuration: .plain(), primaryAction: nil)
    @objc private(set) var items: [CYLSearchBarSearchEntryView] = []
    private let scrollView = UIScrollView()
    private let indicatorView = UIView()

    // MARK: - Style read from the bar

    private var placeholder: String {
        searchBarView?.placeholder ?? CYLSearchResources.localizedString(forKey: "search.field")
    }

    private var font: UIFont {
        searchBarView?.font ?? UIFont.preferredFont(forTextStyle: .body, compatibleWith: traitCollection)
    }

    private var textColor: UIColor {
        searchBarView?.textColor ?? .label
    }

    private var placeholderColor: UIColor {
        searchBarView?.placeholderColor ?? .secondaryLabel
    }

    private var animationDuration: TimeInterval {
        searchBarView?.animationDuration ?? 0.25
    }

    private var accentColor: UIColor {
        searchBarView?.searchIndicatorColor ?? tintColor
    }

    var searches: [String] {
        items.map { $0.textField.text ?? "" }
    }

    var preferredHeight: CGFloat {
        max(56, ceil(font.lineHeight) + 24 + Self.indicatorHeight)
    }

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = false
        addSubview(scrollView)
        indicatorView.isHidden = true
        indicatorView.isAccessibilityElement = false
        scrollView.addSubview(indicatorView)
        searchButton.accessibilityLabel = CYLSearchResources.localizedString(forKey: "multisearch.add")
        searchButton.accessibilityIdentifier = "CYLSearchBarNewSearch"
        searchButton.showsLargeContentViewer = true
        searchButton.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
        addSubview(searchButton)
        applyStyle()
    }

    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Style

    func applyStyle() {
        let accent = accentColor
        indicatorView.backgroundColor = accent
        var configuration = searchButton.configuration ?? .plain()
        configuration.image = searchBarView?.newSearchImage ?? UIImage(systemName: "magnifyingglass")
        searchButton.configuration = configuration
        searchButton.tintColor = accent
        for (index, item) in items.enumerated() {
            style(item, selected: index == selectedIndex)
        }
        setNeedsLayout()
    }

    private func style(_ item: CYLSearchBarSearchEntryView, selected: Bool) {
        let field = item.textField
        let currentFont = self.font
        field.font = currentFont
        field.adjustsFontForContentSizeCategory = true
        field.textColor = textColor
        field.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: placeholderColor, .font: currentFont])
        field.returnKeyType = searchBarView?.returnKeyType ?? .search
        field.keyboardType = searchBarView?.keyboardType ?? .default
        field.autocapitalizationType = searchBarView?.autocapitalizationType ?? .sentences
        field.alpha = selected || item.editing ? 1 : (searchBarView?.unselectedSearchAlpha ?? 0.5)
        item.removeButton.setImage(searchBarView?.removeSearchImage ?? UIImage(systemName: "xmark.circle.fill"), for: .normal)
        item.removeButton.tintColor = .secondaryLabel
        item.removeButton.isHidden = !selected || item.editing
        // VoiceOver: a completed search reads as a selectable button with its position.
        if !item.editing, let index = items.firstIndex(of: item) {
            field.accessibilityTraits = selected ? [.button, .selected] : .button
            field.accessibilityValue = String.localizedStringWithFormat(CYLSearchResources.localizedString(forKey: "multisearch.item"), UInt(index + 1), UInt(items.count))
        } else {
            field.accessibilityTraits = .none
            field.accessibilityValue = nil
        }
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        applyStyle()
    }

    // MARK: - Layout

    private func width(of item: CYLSearchBarSearchEntryView, selected: Bool) -> CGFloat {
        if item.editing {
            return searchBarView?.searchFieldWidth ?? 160
        }
        let textWidth = ceil(((item.textField.text ?? "") as NSString).size(withAttributes: [.font: font]).width)
        return textWidth + Self.itemPadding * 2 + (selected ? Self.removeSize : 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let height = bounds.height
        let buttonSide = min(max(44, height), height)
        searchButton.frame = CGRect(x: bounds.width - buttonSide, y: 0, width: buttonSide, height: height)
        scrollView.frame = CGRect(x: 0, y: 0, width: max(0, bounds.width - buttonSide), height: height)
        var x: CGFloat = 0
        let itemHeight = max(0, height - Self.indicatorHeight)
        for (index, item) in items.enumerated() {
            let selected = index == selectedIndex
            let width = width(of: item, selected: selected)
            item.frame = CGRect(x: x, y: 0, width: width, height: itemHeight)
            let removeWidth = item.removeButton.isHidden ? 0 : Self.removeSize
            item.textField.frame = CGRect(x: Self.itemPadding, y: 0, width: max(0, width - Self.itemPadding * 2 - removeWidth), height: itemHeight)
            item.removeButton.frame = CGRect(x: width - Self.itemPadding - Self.removeSize + 6, y: floor((itemHeight - 44) / 2), width: 44, height: 44)
            if selected || item.editing {
                indicatorView.frame = CGRect(x: x + Self.itemPadding, y: itemHeight, width: max(0, width - Self.itemPadding * 2), height: Self.indicatorHeight)
            }
            x += width
        }
        indicatorView.isHidden = selectedIndex == NSNotFound && !isEditingNewSearch
        scrollView.contentSize = CGSize(width: x, height: height)
    }

    private func scroll(to item: CYLSearchBarSearchEntryView, animated: Bool) {
        layoutIfNeeded()
        scrollView.scrollRectToVisible(item.frame, animated: animated)
    }

    // MARK: - Actions

    @objc private func searchTapped() {
        if isEditingNewSearch {
            completeSearch()
        } else {
            beginNewSearch()
        }
    }

    private func newItem() -> CYLSearchBarSearchEntryView {
        let item = CYLSearchBarSearchEntryView()
        item.textField.delegate = self
        item.textField.accessibilityLabel = placeholder
        item.textField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        item.addSubview(item.textField)
        item.removeButton.accessibilityLabel = CYLSearchResources.localizedString(forKey: "multisearch.remove")
        item.removeButton.showsLargeContentViewer = true
        item.removeButton.addTarget(self, action: #selector(removeTapped(_:)), for: .touchUpInside)
        item.addSubview(item.removeButton)
        item.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(itemTapped(_:))))
        return item
    }

    func beginNewSearch() {
        if isEditingNewSearch {
            return
        }
        isEditingNewSearch = true
        selectedIndex = NSNotFound
        let item = newItem()
        item.editing = true
        items.append(item)
        scrollView.addSubview(item)
        applyStyle()
        item.alpha = 0
        scroll(to: item, animated: true)
        UIView.animate(withDuration: animationDuration) {
            item.alpha = 1
        } completion: { _ in
            item.textField.becomeFirstResponder()
        }
        if window == nil {
            item.textField.becomeFirstResponder()
        }
    }

    func completeSearch() {
        guard isEditingNewSearch, let item = items.last else {
            return
        }
        isEditingNewSearch = false
        item.editing = false
        item.textField.resignFirstResponder()
        let text = item.textField.text ?? ""
        if text.isEmpty || text.count < Int(searchBarView?.minimumTextLength ?? 3) {
            remove(item, notify: false)
            return
        }
        let index = items.count - 1
        selectedIndex = index
        animateLayout()
        if let bar = searchBarView {
            bar.delegate?.searchBarView?(bar, didCompleteSearch: text, at: index)
        }
    }

    func addSearch(_ text: String) {
        if text.isEmpty {
            return
        }
        if isEditingNewSearch {
            completeSearch()
        }
        let item = newItem()
        let maximum = Int(searchBarView?.maximumTextLength ?? 0)
        item.textField.text = maximum > 0 && text.count > maximum ? String(text.prefix(maximum)) : text
        items.append(item)
        scrollView.addSubview(item)
        selectedIndex = items.count - 1
        applyStyle()
        scroll(to: item, animated: false)
    }

    func selectSearch(at index: Int) {
        guard items.indices.contains(index), !items[index].editing else {
            return
        }
        if isEditingNewSearch {
            completeSearch()
        }
        guard items.indices.contains(index) else {
            return
        }
        selectedIndex = index
        animateLayout()
        scroll(to: items[index], animated: true)
        if let bar = searchBarView {
            bar.delegate?.searchBarView?(bar, didSelectSearch: items[index].textField.text ?? "", at: index)
        }
    }

    func removeSearch(at index: Int) {
        guard items.indices.contains(index) else {
            return
        }
        remove(items[index], notify: true)
    }

    private func remove(_ item: CYLSearchBarSearchEntryView, notify: Bool) {
        guard let index = items.firstIndex(of: item) else {
            return
        }
        if item.editing {
            isEditingNewSearch = false
        }
        item.textField.resignFirstResponder()
        item.removeFromSuperview()
        items.remove(at: index)
        // As in MultiSearchView: the next entry is selected, or the previous one when the last entry went away.
        if items.isEmpty {
            selectedIndex = NSNotFound
        } else if selectedIndex == index || selectedIndex == NSNotFound {
            selectedIndex = min(index, items.count - 1)
        } else if selectedIndex > index {
            selectedIndex -= 1
        }
        animateLayout()
        if notify, let bar = searchBarView {
            bar.delegate?.searchBarView?(bar, didRemoveSearchAt: index)
        }
        let focus: Any = selectedIndex == NSNotFound ? searchButton : items[selectedIndex].textField
        UIAccessibility.post(notification: .layoutChanged, argument: focus)
    }

    private func animateLayout() {
        applyStyle()
        guard window != nil, animationDuration > 0 else {
            layoutIfNeeded()
            return
        }
        UIView.animate(withDuration: animationDuration) {
            self.layoutIfNeeded()
        }
    }

    @objc private func itemTapped(_ recognizer: UITapGestureRecognizer) {
        guard let item = recognizer.view as? CYLSearchBarSearchEntryView, let index = items.firstIndex(of: item), index != selectedIndex else {
            return
        }
        selectSearch(at: index)
    }

    @objc private func removeTapped(_ button: UIButton) {
        guard let item = button.superview as? CYLSearchBarSearchEntryView, let index = items.firstIndex(of: item) else {
            return
        }
        removeSearch(at: index)
    }

    @objc private func textChanged(_ field: UITextField) {
        guard let index = items.firstIndex(where: { $0.textField === field }) else {
            return
        }
        setNeedsLayout()
        if let bar = searchBarView {
            bar.delegate?.searchBarView?(bar, textDidChange: field.text ?? "", at: index)
        }
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard let item = textField.superview as? CYLSearchBarSearchEntryView else {
            return false
        }
        if !item.editing {
            if let index = items.firstIndex(of: item), index != selectedIndex {
                selectSearch(at: index)
            }
            return false
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        completeSearch()
        return false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maximum = Int(searchBarView?.maximumTextLength ?? 0)
        if maximum == 0 || string.isEmpty {
            return true
        }
        let length = (textField.text as NSString?)?.length ?? 0
        return length - range.length + (string as NSString).length <= maximum
    }
}

/**
 * The bar's text field: a placeholder assigned to it directly is handed to the bar, which draws it with `placeholderColor`.
 */
private final class CYLSearchBarTextField: UITextField {

    var onPlaceholderChange: ((String?) -> Void)?

    override var placeholder: String? {
        didSet {
            onPlaceholderChange?(placeholder)
        }
    }
}

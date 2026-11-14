import UIKit

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
}

/**
 * A configurable search bar: a rounded field with a magnifier, text and clear button, views of the host inside the
 * field after the text (a camera, a "Search" button) or before the field (a back button), and an optional Cancel
 * button. Use it as a navigation item's title view, a header, or anywhere in a layout.
 */
@objc(CYLSearchBarView)
public final class CYLSearchBarView: UIView, UITextFieldDelegate {

    private static let iconSize: CGFloat = 18
    private static let spacing: CGFloat = 8
    private static let minimumTextShare: CGFloat = 0.4
    private static let maximumCancelShare: CGFloat = 0.3
    private static let minimumScale: CGFloat = 0.5
    private static let minimumAccessoryScale: CGFloat = 0.25

    // MARK: - Subviews

    /**
     * Receives the events.
     */
    @objc public weak var delegate: CYLSearchBarViewDelegate?

    /**
     * The text field inside the field.
     */
    @objc public let textField = UITextField()

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
        set { textField.text = newValue; textStateChanged() }
    }

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
     * The placeholder color. `placeholderTextColor` when nil.
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
     * The space around the field. (6, 12, 6, 12) by default.
     */
    @objc public var contentInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12) {
        didSet { invalidateIntrinsicContentSize(); setNeedsLayout() }
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
            trailingAccessoryViews.forEach { fieldView.addSubview($0) }
            setNeedsLayout()
        }
    }

    // MARK: - Items

    /**
     * The appended items, in order, after the text and after `trailingAccessoryViews` (like the FlatDesign tab bar's
     * `items`). The field stays; only items are appended.
     */
    @objc public private(set) var items: [CYLSearchBarItem] = []

    /**
     * The views of `items`, in the same order.
     */
    @objc public var itemViews: [CYLSearchBarItemView] {
        items.map(\.itemView)
    }

    /**
     * The icon and title color of every item without its own `tintColor`; nil uses the label color.
     */
    @objc public var itemTintColor: UIColor? {
        didSet { items.forEach { $0.itemView.reload() } }
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
        item.searchBarView?.removeItem(item)
        items.insert(item, at: min(max(0, index), items.count))
        item.searchBarView = self
        let view = item.itemView
        view.removeTarget(nil, action: nil, for: .allEvents)
        view.addTarget(self, action: #selector(itemTapped(_:)), for: .touchUpInside)
        fieldView.addSubview(view)
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
        items.remove(at: index)
        item.searchBarView = nil
        item.itemView.removeTarget(self, action: nil, for: .allEvents)
        item.itemView.removeFromSuperview()
        setNeedsLayout()
    }

    /**
     * Removes every item.
     */
    @objc public func removeAllItems() {
        items.forEach { removeItem($0) }
    }

    /**
     * YES when an item of the style was appended (a text "Search" button), like `-hasPlusButton`.
     */
    @objc(hasItemOfStyle:)
    public func hasItem(of style: CYLSearchBarItemStyle) -> Bool {
        items.contains { $0.style == style }
    }

    @objc private func itemTapped(_ sender: CYLSearchBarItemView) {
        guard let item = sender.item, item.isEnabled else {
            return
        }
        if item.isSelectable {
            item.isSelected.toggle()
        }
        delegate?.searchBarView?(self, didSelect: item)
        item.handler?(item)
    }

    private func applySearchBarStyle() {
        switch searchBarStyle {
        case .plain:
            break
        case .bordered:
            fieldBorderColor = .separator
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

    // MARK: - Cancel button

    /**
     * Shows the Cancel button after the field. NO by default.
     */
    @objc public var showsCancelButton = false {
        didSet { cancelButton.isHidden = !showsCancelButton || isIconified; setNeedsLayout() }
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
        set { textField.keyboardType = newValue; textField.reloadInputViews() }
    }

    /**
     * The return key (Android `imeOptions`). `UIReturnKeySearch` by default.
     */
    @objc public var returnKeyType: UIReturnKeyType {
        get { textField.returnKeyType }
        set { textField.returnKeyType = newValue; textField.reloadInputViews() }
    }

    /**
     * Automatic capitalization. `UITextAutocapitalizationTypeSentences` by default.
     */
    @objc public var autocapitalizationType: UITextAutocapitalizationType {
        get { textField.autocapitalizationType }
        set { textField.autocapitalizationType = newValue }
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

    // MARK: - Initializers

    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

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
        addInteraction(UILargeContentViewerInteraction())
        updateButtonImages()
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
        var views = trailingAccessoryViews + itemViews.map { $0 as UIView }
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
        fieldView.isHidden = isIconified
        iconButton.isHidden = !isIconified
        cancelButton.isHidden = isIconified || !showsCancelButton
        effectiveLeadingView?.isHidden = isIconified
        navigationButton.isHidden = isIconified || !showsNavigationButton
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
        placeholderLabel.textColor = placeholderColor ?? .placeholderText
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
        configuration.attributedTitle = AttributedString(NSAttributedString(string: cancelButtonTitle, attributes: [.font: font as UIFont]))
        configuration.titleLineBreakMode = .byClipping
        cancelButton.configuration = configuration
        // The title may be drawn smaller to fit; VoiceOver and the large content viewer still get the whole title.
        cancelButton.accessibilityLabel = cancelButtonTitle
        cancelButton.largeContentTitle = cancelButtonTitle
        setNeedsLayout()
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

    // MARK: - Layout

    override public var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: effectiveFieldHeight + contentInsets.top + contentInsets.bottom)
    }

    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        CGSize(width: size.width, height: intrinsicContentSize.height)
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
        let insets = contentInsets
        let height = bounds.height
        let fieldHeight = min(effectiveFieldHeight, max(0, height - insets.top - insets.bottom))
        let y = floor((height - fieldHeight) / 2)
        var leading = insets.left
        var trailing = bounds.width - insets.right
        navigationButton.isHidden = isIconified || !showsNavigationButton
        if let leadingView = effectiveLeadingView {
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
            let titleWidth = ceil((cancelButtonTitle as NSString).size(withAttributes: [.font: font as UIFont]).width)
            let maximumWidth = max(44, floor(available * Self.maximumCancelShare))
            let width = min(max(44, titleWidth + 12), maximumWidth)
            let scale = titleWidth + 12 > width ? max(Self.minimumScale, (width - 12) / max(1, titleWidth)) : 1
            setCancelTitleFont(font.withSize(font.pointSize * scale))
            cancelButton.frame = CGRect(x: trailing - width, y: y, width: width, height: fieldHeight)
            trailing -= width + Self.spacing
        }
        var field = CGRect(x: leading, y: y, width: max(0, trailing - leading), height: fieldHeight)
        if !animatingExpansion || !fieldView.isHidden {
            fieldView.frame = field
        }
        field = fieldView.frame
        field.size = CGSize(width: max(0, trailing - leading), height: fieldHeight)
        fieldView.layer.cornerRadius = fieldCornerRadius < 0 ? fieldHeight / 2 : fieldCornerRadius
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
        var end = field.width - inner
        let accessories = effectiveAccessoryViews
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
        delegate?.searchBarViewDidBeginEditing?(self)
    }

    /**
     * Clears the text and closes to the icon when configured, then reports the end of editing.
     */
    public func textFieldDidEndEditing(_ textField: UITextField) {
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

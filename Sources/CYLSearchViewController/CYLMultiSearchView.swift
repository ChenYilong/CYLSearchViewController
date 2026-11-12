import UIKit

/**
 * Events of a `CYLMultiSearchView` (iammert `MultiSearchViewListener`).
 */
@objc(CYLMultiSearchViewDelegate)
public protocol CYLMultiSearchViewDelegate: NSObjectProtocol {
    /**
     * The text of the search being typed changed (`onTextChanged`).
     */
    @objc(multiSearchView:textDidChange:atIndex:)
    optional func multiSearchView(_ multiSearchView: CYLMultiSearchView, textDidChange text: String, at index: UInt)

    /**
     * A search was completed and became an item (`onSearchComplete`).
     */
    @objc(multiSearchView:didCompleteSearch:atIndex:)
    optional func multiSearchView(_ multiSearchView: CYLMultiSearchView, didCompleteSearch text: String, at index: UInt)

    /**
     * An item was removed (`onSearchItemRemoved`).
     */
    @objc(multiSearchView:didRemoveItemAtIndex:)
    optional func multiSearchView(_ multiSearchView: CYLMultiSearchView, didRemoveItemAt index: UInt)

    /**
     * An item was selected by a tap (`onItemSelected`).
     */
    @objc(multiSearchView:didSelectItem:atIndex:)
    optional func multiSearchView(_ multiSearchView: CYLMultiSearchView, didSelectItem text: String, at index: UInt)
}

/**
 * One search: its text field, and a remove button shown while it is selected.
 */
@objc(CYLMultiSearchItemView)
final class CYLMultiSearchItemView: UIView {
    @objc let textField = UITextField()
    @objc let removeButton = UIButton(configuration: .plain(), primaryAction: nil)
    var editing = false
}

/**
 * Several searches side by side (iammert `MultiSearchView`): the search button starts a new search; a completed
 * search becomes an item in a horizontally scrolling row, with an indicator under the selected item and a remove
 * button on it. Use it to search by several categories at once.
 */
@objc(CYLMultiSearchView)
public final class CYLMultiSearchView: UIView, UITextFieldDelegate {

    private static let itemPadding: CGFloat = 12
    private static let removeSize: CGFloat = 28
    private static let indicatorHeight: CGFloat = 2
    private static let noSelection = UInt(NSNotFound)

    /**
     * Receives the events.
     */
    @objc public weak var delegate: CYLMultiSearchViewDelegate?

    /**
     * The selected item, or `NSNotFound` when there is none.
     */
    @objc public private(set) var selectedIndex: UInt = CYLMultiSearchView.noSelection

    /**
     * YES while a new search is being typed (`isInSearchMode`).
     */
    @objc(isInSearchMode) public private(set) var inSearchMode = false

    /**
     * The button at the trailing end: it starts a search, or completes the one being typed.
     */
    @objc public let searchButton = UIButton(configuration: .plain(), primaryAction: nil)

    @objc private var items: [CYLMultiSearchItemView] = []
    private let scrollView = UIScrollView()
    private let indicatorView = UIView()

    // MARK: - Text style (iammert searchTextStyle)

    private var customPlaceholder: String?
    private var customFont: UIFont?
    private var customTextColor: UIColor?
    private var customPlaceholderColor: UIColor?
    private var customSearchImage: UIImage?
    private var customRemoveImage: UIImage?

    /**
     * The placeholder of a new search (`android:hint`). "Search" by default.
     */
    @objc public var placeholder: String! {
        get { customPlaceholder ?? CYLSearchResources.localizedString(forKey: "search.field") }
        set { customPlaceholder = newValue; applyStyle() }
    }

    /**
     * The font of the items (`android:textSize`). The body text style by default, following Dynamic Type.
     */
    @objc public var font: UIFont! {
        get { customFont ?? UIFont.preferredFont(forTextStyle: .body, compatibleWith: traitCollection) }
        set { customFont = newValue; applyStyle(); invalidateIntrinsicContentSize() }
    }

    /**
     * The text color (`android:textColor`). `labelColor` by default.
     */
    @objc public var textColor: UIColor! {
        get { customTextColor ?? .label }
        set { customTextColor = newValue; applyStyle() }
    }

    /**
     * The placeholder color (`android:textColorHint`). `placeholderTextColor` by default.
     */
    @objc public var placeholderColor: UIColor! {
        get { customPlaceholderColor ?? .placeholderText }
        set { customPlaceholderColor = newValue; applyStyle() }
    }

    /**
     * The longest search a person can type (`android:maxLength`); 0 means no limit. 0 by default.
     */
    @objc public var maximumTextLength: UInt = 0

    /**
     * A search shorter than this is dropped when it is completed. 3 by default, as in MultiSearchView.
     */
    @objc public var minimumTextLength: UInt = 3

    /**
     * The return key (`android:imeOptions`). `UIReturnKeySearch` by default.
     */
    @objc public var returnKeyType: UIReturnKeyType = .search { didSet { applyStyle() } }

    /**
     * The keyboard (`android:inputType`). `UIKeyboardTypeDefault` by default.
     */
    @objc public var keyboardType: UIKeyboardType = .default { didSet { applyStyle() } }

    /**
     * Capitalization (`textCapSentences`). `UITextAutocapitalizationTypeSentences` by default.
     */
    @objc public var autocapitalizationType: UITextAutocapitalizationType = .sentences { didSet { applyStyle() } }

    // MARK: - Other style

    /**
     * The color of the indicator under the selected item and of the buttons. `tintColor` by default.
     */
    @objc public var indicatorColor: UIColor? { didSet { applyStyle() } }

    /**
     * The opacity of items that are not selected. 0.5 by default.
     */
    @objc public var unselectedItemAlpha: CGFloat = 0.5 {
        didSet { unselectedItemAlpha = min(1, max(0, unselectedItemAlpha)); applyStyle() }
    }

    /**
     * The width of the field for a new search, in points. 160 by default.
     */
    @objc public var searchFieldWidth: CGFloat = 160 {
        didSet { searchFieldWidth = max(44, searchFieldWidth); setNeedsLayout() }
    }

    /**
     * The length of the animations, in seconds. 0.25 by default.
     */
    @objc public var animationDuration: TimeInterval = 0.25

    /**
     * The search button's icon. `magnifyingglass` by default.
     */
    @objc public var searchImage: UIImage! {
        get { customSearchImage ?? UIImage(systemName: "magnifyingglass") }
        set { customSearchImage = newValue; applyStyle() }
    }

    /**
     * The remove button's icon. `xmark.circle.fill` by default.
     */
    @objc public var removeImage: UIImage! {
        get { customRemoveImage ?? UIImage(systemName: "xmark.circle.fill") }
        set { customRemoveImage = newValue; applyStyle() }
    }

    /**
     * The texts of the items, completed searches first, then the one being typed.
     */
    @objc public var searchTexts: [String] {
        items.map { $0.textField.text ?? "" }
    }

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
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = false
        addSubview(scrollView)
        indicatorView.isHidden = true
        indicatorView.isAccessibilityElement = false
        scrollView.addSubview(indicatorView)
        searchButton.accessibilityLabel = CYLSearchResources.localizedString(forKey: "multisearch.add")
        searchButton.showsLargeContentViewer = true
        searchButton.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
        addSubview(searchButton)
        addInteraction(UILargeContentViewerInteraction())
        applyStyle()
    }

    // MARK: - Style

    private func applyStyle() {
        let accent = indicatorColor ?? tintColor
        indicatorView.backgroundColor = accent
        var configuration = searchButton.configuration ?? .plain()
        configuration.image = searchImage
        searchButton.configuration = configuration
        searchButton.tintColor = accent
        for (index, item) in items.enumerated() {
            style(item, selected: UInt(index) == selectedIndex)
        }
        setNeedsLayout()
    }

    private func style(_ item: CYLMultiSearchItemView, selected: Bool) {
        let field = item.textField
        field.font = font
        field.adjustsFontForContentSizeCategory = true
        field.textColor = textColor
        field.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: placeholderColor as UIColor, .font: font as UIFont])
        field.returnKeyType = returnKeyType
        field.keyboardType = keyboardType
        field.autocapitalizationType = autocapitalizationType
        field.alpha = selected || item.editing ? 1 : unselectedItemAlpha
        item.removeButton.setImage(removeImage, for: .normal)
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

    override public func tintColorDidChange() {
        super.tintColorDidChange()
        applyStyle()
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyStyle()
        invalidateIntrinsicContentSize()
    }

    // MARK: - Layout

    override public var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: max(56, ceil(font.lineHeight) + 24 + Self.indicatorHeight))
    }

    private func width(of item: CYLMultiSearchItemView, selected: Bool) -> CGFloat {
        if item.editing {
            return searchFieldWidth
        }
        let textWidth = ceil(((item.textField.text ?? "") as NSString).size(withAttributes: [.font: font as UIFont]).width)
        return textWidth + Self.itemPadding * 2 + (selected ? Self.removeSize : 0)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        let height = bounds.height
        let buttonSide = min(max(44, height), height)
        searchButton.frame = CGRect(x: bounds.width - buttonSide, y: 0, width: buttonSide, height: height)
        scrollView.frame = CGRect(x: 0, y: 0, width: max(0, bounds.width - buttonSide), height: height)
        var x: CGFloat = 0
        let itemHeight = height - Self.indicatorHeight
        for (index, item) in items.enumerated() {
            let selected = UInt(index) == selectedIndex
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
        indicatorView.isHidden = selectedIndex == Self.noSelection && !inSearchMode
        scrollView.contentSize = CGSize(width: x, height: height)
    }

    private func scroll(to item: CYLMultiSearchItemView, animated: Bool) {
        layoutIfNeeded()
        scrollView.scrollRectToVisible(item.frame, animated: animated)
    }

    // MARK: - Actions

    @objc private func searchTapped() {
        if inSearchMode {
            completeSearch()
        } else {
            search()
        }
    }

    private func newItem() -> CYLMultiSearchItemView {
        let item = CYLMultiSearchItemView()
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

    /**
     * Starts a new search and shows the keyboard (`search`). Does nothing while a search is being typed.
     */
    @objc public func search() {
        if inSearchMode {
            return
        }
        inSearchMode = true
        selectedIndex = Self.noSelection
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

    /**
     * Completes the search being typed (`completeSearch`): it becomes the selected item, or is dropped when shorter
     * than `minimumTextLength`.
     */
    @objc public func completeSearch() {
        guard inSearchMode, let item = items.last else {
            return
        }
        inSearchMode = false
        item.editing = false
        item.textField.resignFirstResponder()
        let text = item.textField.text ?? ""
        if text.count < minimumTextLength || text.isEmpty {
            remove(item, notify: false)
            return
        }
        let index = UInt(items.count - 1)
        selectedIndex = index
        animateLayout()
        delegate?.multiSearchView?(self, didCompleteSearch: text, at: index)
    }

    /**
     * Adds a completed search without typing it and selects it.
     */
    @objc(addSearchText:)
    public func addSearchText(_ text: String) {
        if text.isEmpty {
            return
        }
        if inSearchMode {
            completeSearch()
        }
        let item = newItem()
        item.textField.text = maximumTextLength > 0 && text.count > maximumTextLength ? String(text.prefix(Int(maximumTextLength))) : text
        items.append(item)
        scrollView.addSubview(item)
        selectedIndex = UInt(items.count - 1)
        applyStyle()
        scroll(to: item, animated: false)
    }

    /**
     * Selects an item, like a tap on it.
     */
    @objc(selectItemAtIndex:)
    public func selectItem(at index: UInt) {
        guard index < items.count, !items[Int(index)].editing else {
            return
        }
        if inSearchMode {
            completeSearch()
        }
        guard index < items.count else {
            return
        }
        selectedIndex = index
        animateLayout()
        scroll(to: items[Int(index)], animated: true)
        delegate?.multiSearchView?(self, didSelectItem: items[Int(index)].textField.text ?? "", at: index)
    }

    /**
     * Removes an item, like a tap on its remove button.
     */
    @objc(removeItemAtIndex:)
    public func removeItem(at index: UInt) {
        guard index < items.count else {
            return
        }
        remove(items[Int(index)], notify: true)
    }

    private func remove(_ item: CYLMultiSearchItemView, notify: Bool) {
        guard let position = items.firstIndex(of: item) else {
            return
        }
        let index = UInt(position)
        if item.editing {
            inSearchMode = false
        }
        item.textField.resignFirstResponder()
        item.removeFromSuperview()
        items.remove(at: position)
        // As in MultiSearchView: the next item is selected, or the previous one when the last item went away.
        if items.isEmpty {
            selectedIndex = Self.noSelection
        } else if selectedIndex == index || selectedIndex == Self.noSelection {
            selectedIndex = min(index, UInt(items.count - 1))
        } else if selectedIndex > index {
            selectedIndex -= 1
        }
        animateLayout()
        if notify {
            delegate?.multiSearchView?(self, didRemoveItemAt: index)
        }
        let focus: Any = selectedIndex == Self.noSelection ? searchButton : items[Int(selectedIndex)].textField
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
        guard let item = recognizer.view as? CYLMultiSearchItemView, let index = items.firstIndex(of: item), UInt(index) != selectedIndex else {
            return
        }
        selectItem(at: UInt(index))
    }

    @objc private func removeTapped(_ button: UIButton) {
        guard let item = button.superview as? CYLMultiSearchItemView, let index = items.firstIndex(of: item) else {
            return
        }
        removeItem(at: UInt(index))
    }

    @objc private func textChanged(_ field: UITextField) {
        guard let index = items.firstIndex(where: { $0.textField === field }) else {
            return
        }
        setNeedsLayout()
        delegate?.multiSearchView?(self, textDidChange: field.text ?? "", at: UInt(index))
    }

    // MARK: - UITextFieldDelegate

    /**
     * Only the search being typed is editable; a tap on a completed one selects it.
     */
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard let item = textField.superview as? CYLMultiSearchItemView else {
            return false
        }
        if !item.editing {
            if let index = items.firstIndex(of: item), UInt(index) != selectedIndex {
                selectItem(at: UInt(index))
            }
            return false
        }
        return true
    }

    /**
     * The return key completes the search.
     */
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        completeSearch()
        return false
    }

    /**
     * Enforces `maximumTextLength`.
     */
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if maximumTextLength == 0 || string.isEmpty {
            return true
        }
        let length = (textField.text as NSString?)?.length ?? 0
        return length - range.length + (string as NSString).length <= Int(maximumTextLength)
    }
}

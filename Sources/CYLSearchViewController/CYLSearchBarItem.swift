import UIKit

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
 * The fixed look of the whole bar: the field on the left stays, the items are appended after its text.
 */
@objc(CYLSearchBarStyle)
public enum CYLSearchBarStyle: Int {
    /**
     * The field as configured by its own properties (the default; nothing is changed).
     */
    case plain = 0
    /**
     * A capsule with a 1 pt separator-colored border on the system background, the field and its items inside one
     * outline (the Discover search bar).
     */
    case bordered
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
     * The item's view, created on first use.
     */
    @objc public private(set) lazy var itemView = CYLSearchBarItemView(item: self)

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
        itemView.reload()
        searchBarView?.setNeedsLayout()
    }
}

/**
 * The view of a `CYLSearchBarItem` (a control), like `CYLFlatDesignTabBarButton`.
 */
@objc(CYLSearchBarItemView)
@MainActor
public final class CYLSearchBarItemView: UIControl {

    private static let defaultImageSide: CGFloat = 20
    private static let minimumTouchSide: CGFloat = 36

    /**
     * The item this view draws.
     */
    @objc public private(set) weak var item: CYLSearchBarItem?

    /**
     * The icon.
     */
    @objc public let imageView = UIImageView()

    /**
     * The title of a text item.
     */
    @objc public let titleLabel = UILabel()

    /**
     * The badge (`badgeValue`).
     */
    @objc public let badgeLabel = UILabel()

    private let dividerLayer = CALayer()

    /**
     * The view for an item; the item's `itemView` is the one the bar shows.
     */
    @objc(initWithItem:)
    public init(item: CYLSearchBarItem) {
        self.item = item
        super.init(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: .systemFont(ofSize: 17, weight: .semibold))
        titleLabel.isUserInteractionEnabled = false
        badgeLabel.textAlignment = .center
        badgeLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        badgeLabel.textColor = .white
        badgeLabel.clipsToBounds = true
        badgeLabel.isUserInteractionEnabled = false
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(badgeLabel)
        layer.addSublayer(dividerLayer)
        showsLargeContentViewer = true
        addInteraction(UILargeContentViewerInteraction())
        addInteraction(UIPointerInteraction())
        reload()
    }

    /**
     * Not supported: an item view is created from its item.
     */
    public required init?(coder: NSCoder) {
        nil
    }

    /**
     * The view the badge is drawn in (this view).
     */
    @objc public func actualBadgeSuperView() -> UIView {
        self
    }

    private var resolvedTint: UIColor {
        item?.tintColor ?? item?.searchBarView?.itemTintColor ?? .label
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

    private var currentImage: UIImage? {
        guard let item else {
            return nil
        }
        if let animated = item.animatedImage {
            return animated
        }
        return item.isSelected ? (item.selectedImage ?? item.image) : item.image
    }

    func reload() {
        guard let item else {
            return
        }
        let state = item.currentState
        let tint = resolvedTint
        isEnabled = item.isEnabled
        isSelected = item.isSelected
        alpha = item.isEnabled ? 1 : 0.4
        imageView.image = currentImage
        imageView.tintColor = tint
        imageView.isHidden = item.style == .divider || currentImage == nil
        if item.animatedImage != nil {
            imageView.startAnimating()
        }
        let attributes = item.titleTextAttributes(for: state) ?? item.titleTextAttributes(for: .normal)
        if item.style == .text, let title = item.title {
            var merged: [NSAttributedString.Key: Any] = [.foregroundColor: tint, .font: titleLabel.font as Any]
            attributes?.forEach { merged[$0.key] = $0.value }
            titleLabel.attributedText = NSAttributedString(string: title, attributes: merged)
            titleLabel.isHidden = false
        } else {
            titleLabel.attributedText = nil
            titleLabel.isHidden = true
        }
        let background = item.isSelected ? (item.selectedBackgroundColor ?? item.backgroundColor) : item.backgroundColor
        backgroundColor = background
        dividerLayer.isHidden = item.style != .divider
        dividerLayer.backgroundColor = UIColor.separator.resolvedColor(with: traitCollection).cgColor
        reloadBadge(state: state)
        isAccessibilityElement = item.style != .divider
        accessibilityLabel = item.itemAccessibilityLabel ?? item.title
        accessibilityIdentifier = item.itemAccessibilityIdentifier
        accessibilityTraits = item.isSelectable && item.isSelected ? [.button, .selected] : .button
        if !item.isEnabled {
            accessibilityTraits.insert(.notEnabled)
        }
        largeContentTitle = item.itemAccessibilityLabel ?? item.title
        largeContentImage = currentImage
        isUserInteractionEnabled = item.style != .divider
        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }

    private func reloadBadge(state: UIControl.State) {
        guard let item, let value = item.badgeValue else {
            badgeLabel.isHidden = true
            return
        }
        badgeLabel.isHidden = false
        badgeLabel.backgroundColor = item.badgeColor ?? .systemRed
        let attributes = item.badgeTextAttributes(for: state) ?? item.badgeTextAttributes(for: .normal)
        badgeLabel.attributedText = NSAttributedString(string: value, attributes: attributes ?? [
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold),
            .foregroundColor: UIColor.white,
        ])
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        dividerLayer.backgroundColor = UIColor.separator.resolvedColor(with: traitCollection).cgColor
    }

    override public var intrinsicContentSize: CGSize {
        sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
    }

    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let item else {
            return .zero
        }
        let insets = resolvedInsets
        switch item.style {
        case .divider:
            return CGSize(width: 1 + insets.left + insets.right, height: 18)
        case .icon:
            let image = resolvedImageSize
            let side = max(Self.minimumTouchSide, max(image.width + insets.left + insets.right, image.height + insets.top + insets.bottom))
            return CGSize(width: side, height: side)
        case .text:
            let titleSize = titleLabel.attributedText.map { ceil($0.size().width) } ?? 0
            let imageWidth = currentImage == nil ? 0 : resolvedImageSize.width + 4
            let height = max(Self.minimumTouchSide, ceil(titleLabel.font.lineHeight) + insets.top + insets.bottom)
            return CGSize(width: max(Self.minimumTouchSide, titleSize + imageWidth + insets.left + insets.right), height: height)
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        guard let item else {
            return
        }
        let insets = resolvedInsets
        let content = bounds.inset(by: insets)
        let image = resolvedImageSize
        switch item.style {
        case .divider:
            dividerLayer.frame = CGRect(x: insets.left, y: floor((bounds.height - 18) / 2), width: 1, height: min(18, bounds.height))
        case .icon:
            imageView.frame = CGRect(x: content.midX - image.width / 2, y: content.midY - image.height / 2, width: image.width, height: image.height)
                .offsetBy(dx: item.imagePositionAdjustment.horizontal, dy: item.imagePositionAdjustment.vertical)
        case .text:
            var x = content.minX
            if currentImage != nil {
                imageView.frame = CGRect(x: x, y: content.midY - image.height / 2, width: image.width, height: image.height)
                    .offsetBy(dx: item.imagePositionAdjustment.horizontal, dy: item.imagePositionAdjustment.vertical)
                x += image.width + 4
            }
            titleLabel.frame = CGRect(x: x, y: content.minY, width: max(0, content.maxX - x), height: content.height)
                .offsetBy(dx: item.titlePositionAdjustment.horizontal, dy: item.titlePositionAdjustment.vertical)
        }
        layoutBadge(item: item)
        layer.cornerRadius = item.backgroundColor == nil && item.selectedBackgroundColor == nil ? 0 : min(bounds.height / 2, 10)
    }

    private func layoutBadge(item: CYLSearchBarItem) {
        guard !badgeLabel.isHidden else {
            return
        }
        let isDot = (item.badgeValue ?? "").isEmpty
        let minimum = item.badgeSize.width > 0 && item.badgeSize.height > 0 ? item.badgeSize : CGSize(width: 16, height: 16)
        var size = isDot ? CGSize(width: 8, height: 8) : minimum
        if !isDot {
            let text = badgeLabel.intrinsicContentSize
            size.width = max(size.width, ceil(text.width) + item.badgeContentInsets.left + item.badgeContentInsets.right)
            size.height = max(size.height, ceil(text.height) + item.badgeContentInsets.top + item.badgeContentInsets.bottom)
        }
        let anchor = imageView.isHidden ? titleLabel.frame : imageView.frame
        badgeLabel.frame = CGRect(x: anchor.maxX - size.width / 2, y: anchor.minY - size.height / 2, width: size.width, height: size.height)
            .offsetBy(dx: item.badgePositionAdjustment.horizontal, dy: item.badgePositionAdjustment.vertical)
        badgeLabel.layer.cornerRadius = size.height / 2
    }
}

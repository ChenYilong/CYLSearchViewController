import UIKit

/**
 * The common placeholder kinds: an empty list, no search results, or an error.
 */
@objc(CYLSearchPlaceholderKind)
public enum CYLSearchPlaceholderKind: Int {
    /**
     * Nothing to show yet.
     */
    case empty
    /**
     * The search found nothing.
     */
    case noResults
    /**
     * Loading failed.
     */
    case error
}

/**
 * The image of a placeholder; each style has an image in the resource bundle.
 */
@objc(CYLSearchPlaceholderStyle)
public enum CYLSearchPlaceholderStyle: Int {
    /**
     * The Empty placeholder image.
     */
    case empty
    /**
     * The NoResults placeholder image.
     */
    case noResults
    /**
     * The Error placeholder image.
     */
    case error
    /**
     * The WifiOff placeholder image.
     */
    case wifiOff
    /**
     * The SignalWifiOff placeholder image.
     */
    case signalWifiOff
    /**
     * The NoInternet placeholder image.
     */
    case noInternet
    /**
     * The CloudOff placeholder image.
     */
    case cloudOff
    /**
     * The SyncProblem placeholder image.
     */
    case syncProblem
    /**
     * The SyncDisabled placeholder image.
     */
    case syncDisabled
    /**
     * The NetworkLocked placeholder image.
     */
    case networkLocked
    /**
     * The BluetoothDisabled placeholder image.
     */
    case bluetoothDisabled
    /**
     * The LocationOff placeholder image.
     */
    case locationOff
    /**
     * The PublicOff placeholder image.
     */
    case publicOff
    /**
     * The ErrorOutline placeholder image.
     */
    case errorOutline
    /**
     * The Warning placeholder image.
     */
    case warning
    /**
     * The ReportProblem placeholder image.
     */
    case reportProblem
    /**
     * The Blocked placeholder image.
     */
    case blocked
    /**
     * The Help placeholder image.
     */
    case help
    /**
     * The Hourglass placeholder image.
     */
    case hourglass
    /**
     * The Locked placeholder image.
     */
    case locked
    /**
     * The VisibilityOff placeholder image.
     */
    case visibilityOff
    /**
     * The SearchOff placeholder image.
     */
    case searchOff
    /**
     * The FolderOff placeholder image.
     */
    case folderOff
    /**
     * The FolderOpen placeholder image.
     */
    case folderOpen
    /**
     * The DownloadOff placeholder image.
     */
    case downloadOff
    /**
     * The UploadOff placeholder image.
     */
    case uploadOff
    /**
     * The Inbox placeholder image.
     */
    case inbox
    /**
     * The BrokenImage placeholder image.
     */
    case brokenImage
    /**
     * The ImageUnavailable placeholder image.
     */
    case imageUnavailable
    /**
     * The PhotoLibrary placeholder image.
     */
    case photoLibrary
    /**
     * The MusicOff placeholder image.
     */
    case musicOff
    /**
     * The VideoOff placeholder image.
     */
    case videoOff
    /**
     * The PersonOff placeholder image.
     */
    case personOff
    /**
     * The GroupOff placeholder image.
     */
    case groupOff
    /**
     * The EventBusy placeholder image.
     */
    case eventBusy
    /**
     * The EmptyCart placeholder image.
     */
    case emptyCart
    /**
     * The Favorite placeholder image.
     */
    case favorite
    /**
     * The BatteryAlert placeholder image.
     */
    case batteryAlert
    /**
     * The UnknownDevice placeholder image.
     */
    case unknownDevice
    /**
     * The PhoneDisabled placeholder image.
     */
    case phoneDisabled
    /**
     * The WrongLocation placeholder image.
     */
    case wrongLocation
    /**
     * The Count placeholder image.
     */
    case count
}

/**
 * The localized message of a placeholder.
 */
@objc(CYLSearchPlaceholderMessage)
public enum CYLSearchPlaceholderMessage: Int {
    /**
     * "No data".
     */
    case empty
    /**
     * "No matching results".
     */
    case noResults
    /**
     * "Something went wrong".
     */
    case error
    /**
     * "Check your internet connection".
     */
    case network
}

/**
 * An image above a message, centered in its bounds: the empty, no-result and error states of a list.
 */
@objc(CYLSearchPlaceholderView)
public final class CYLSearchPlaceholderView: UIView {

    private static let imageNames = [
        "CYLSearchEmpty",
        "CYLSearchNoResults",
        "CYLSearchError",
        "CYLSearchWifiOff",
        "CYLSearchSignalWifiOff",
        "CYLSearchNoInternet",
        "CYLSearchCloudOff",
        "CYLSearchSyncProblem",
        "CYLSearchSyncDisabled",
        "CYLSearchNetworkLocked",
        "CYLSearchBluetoothDisabled",
        "CYLSearchLocationOff",
        "CYLSearchPublicOff",
        "CYLSearchErrorOutline",
        "CYLSearchWarning",
        "CYLSearchReportProblem",
        "CYLSearchBlocked",
        "CYLSearchHelp",
        "CYLSearchHourglass",
        "CYLSearchLocked",
        "CYLSearchVisibilityOff",
        "CYLSearchSearchOff",
        "CYLSearchFolderOff",
        "CYLSearchFolderOpen",
        "CYLSearchDownloadOff",
        "CYLSearchUploadOff",
        "CYLSearchInbox",
        "CYLSearchBrokenImage",
        "CYLSearchImageUnavailable",
        "CYLSearchPhotoLibrary",
        "CYLSearchMusicOff",
        "CYLSearchVideoOff",
        "CYLSearchPersonOff",
        "CYLSearchGroupOff",
        "CYLSearchEventBusy",
        "CYLSearchEmptyCart",
        "CYLSearchFavorite",
        "CYLSearchBatteryAlert",
        "CYLSearchUnknownDevice",
        "CYLSearchPhoneDisabled",
        "CYLSearchWrongLocation",
    ]

    /**
     * The image, 80 × 80 points, tinted with `secondaryLabelColor` (except the colored empty image).
     */
    @objc public let imageView: UIImageView

    /**
     * The message, in the body text style with Dynamic Type.
     */
    @objc public let textLabel: UILabel

    /**
     * The name of the image of `style` in the resource bundle.
     */
    @objc(imageNameForStyle:)
    public static func imageName(for style: CYLSearchPlaceholderStyle) -> String {
        // Objective-C callers can pass any integer: raise the same exception as the Objective-C version did.
        guard style != .count, imageNames.indices.contains(style.rawValue) else {
            raiseInvalidArgument("Unknown placeholder style: \(style.rawValue)")
            return ""
        }
        return imageNames[style.rawValue]
    }

    private static func raiseInvalidArgument(_ reason: String) {
        NSException(name: .invalidArgumentException, reason: reason, userInfo: nil).raise()
    }

    private static func image(for style: CYLSearchPlaceholderStyle) -> UIImage {
        let image = CYLSearchResources.image(named: imageName(for: style)) ?? UIImage()
        return style == .empty ? image : image.withRenderingMode(.alwaysTemplate)
    }

    private static func text(for message: CYLSearchPlaceholderMessage) -> String {
        // The raw value is checked first: an Objective-C caller can pass a value that is not a case.
        let keys = ["placeholder.empty", "placeholder.search", "placeholder.error", "placeholder.network"]
        guard keys.indices.contains(message.rawValue) else {
            raiseInvalidArgument("Unknown placeholder message: \(message.rawValue)")
            return ""
        }
        return CYLSearchResources.localizedString(forKey: keys[message.rawValue])
    }

    /**
     * A placeholder of a common kind with its built-in image and message.
     */
    @objc(initWithKind:)
    public convenience init(kind: CYLSearchPlaceholderKind) {
        let pairs: [(CYLSearchPlaceholderStyle, CYLSearchPlaceholderMessage)] = [(.empty, .empty), (.noResults, .noResults), (.error, .error)]
        guard pairs.indices.contains(kind.rawValue) else {
            Self.raiseInvalidArgument("Unknown placeholder kind: \(kind.rawValue)")
            self.init(style: .empty, message: .empty)
            return
        }
        self.init(style: pairs[kind.rawValue].0, message: pairs[kind.rawValue].1)
    }

    /**
     * A built-in image with a built-in message.
     */
    @objc(initWithStyle:message:)
    public convenience init(style: CYLSearchPlaceholderStyle, message: CYLSearchPlaceholderMessage) {
        self.init(image: Self.image(for: style), text: Self.text(for: message))
    }

    /**
     * A built-in image with your own text.
     */
    @objc(initWithStyle:text:)
    public convenience init(style: CYLSearchPlaceholderStyle, text: String) {
        self.init(image: Self.image(for: style), text: text)
    }

    /**
     * Your own image with a built-in message.
     */
    @objc(initWithImage:message:)
    public convenience init(image: UIImage, message: CYLSearchPlaceholderMessage) {
        self.init(image: image, text: Self.text(for: message))
    }

    /**
     * Your own image and text.
     */
    @objc(initWithImage:text:)
    public init(image: UIImage, text: String) {
        imageView = UIImageView(image: image)
        textLabel = UILabel()
        super.init(frame: .zero)
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        textLabel.text = text
        textLabel.font = .preferredFont(forTextStyle: .body)
        textLabel.adjustsFontForContentSizeCategory = true
        textLabel.textColor = .secondaryLabel
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        let stack = UIStackView(arrangedSubviews: [imageView, textLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            textLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: -32),
        ])
    }

    /**
     * Not available: use one of the initializers with an image and a text.
     */
    @available(*, unavailable)
    override init(frame: CGRect) {
        fatalError("init(frame:) is not available; use init(image:text:)")
    }

    /**
     * Not available: placeholders are created in code.
     */
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not available; use init(image:text:)")
    }
}

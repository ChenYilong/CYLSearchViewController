#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CYLSearchPlaceholderKind) {
    CYLSearchPlaceholderKindEmpty,
    CYLSearchPlaceholderKindNoResults,
    CYLSearchPlaceholderKindError,
};

/// The built-in image, independently selectable from the message.
typedef NS_ENUM(NSInteger, CYLSearchPlaceholderStyle) {
    CYLSearchPlaceholderStyleEmpty,
    CYLSearchPlaceholderStyleNoResults,
    CYLSearchPlaceholderStyleError,
    CYLSearchPlaceholderStyleWifiOff,
    CYLSearchPlaceholderStyleSignalWifiOff,
    CYLSearchPlaceholderStyleNoInternet,
    CYLSearchPlaceholderStyleCloudOff,
    CYLSearchPlaceholderStyleSyncProblem,
    CYLSearchPlaceholderStyleSyncDisabled,
    CYLSearchPlaceholderStyleNetworkLocked,
    CYLSearchPlaceholderStyleBluetoothDisabled,
    CYLSearchPlaceholderStyleLocationOff,
    CYLSearchPlaceholderStylePublicOff,
    CYLSearchPlaceholderStyleErrorOutline,
    CYLSearchPlaceholderStyleWarning,
    CYLSearchPlaceholderStyleReportProblem,
    CYLSearchPlaceholderStyleBlocked,
    CYLSearchPlaceholderStyleHelp,
    CYLSearchPlaceholderStyleHourglass,
    CYLSearchPlaceholderStyleLocked,
    CYLSearchPlaceholderStyleVisibilityOff,
    CYLSearchPlaceholderStyleSearchOff,
    CYLSearchPlaceholderStyleFolderOff,
    CYLSearchPlaceholderStyleFolderOpen,
    CYLSearchPlaceholderStyleDownloadOff,
    CYLSearchPlaceholderStyleUploadOff,
    CYLSearchPlaceholderStyleInbox,
    CYLSearchPlaceholderStyleBrokenImage,
    CYLSearchPlaceholderStyleImageUnavailable,
    CYLSearchPlaceholderStylePhotoLibrary,
    CYLSearchPlaceholderStyleMusicOff,
    CYLSearchPlaceholderStyleVideoOff,
    CYLSearchPlaceholderStylePersonOff,
    CYLSearchPlaceholderStyleGroupOff,
    CYLSearchPlaceholderStyleEventBusy,
    CYLSearchPlaceholderStyleEmptyCart,
    CYLSearchPlaceholderStyleFavorite,
    CYLSearchPlaceholderStyleBatteryAlert,
    CYLSearchPlaceholderStyleUnknownDevice,
    CYLSearchPlaceholderStylePhoneDisabled,
    CYLSearchPlaceholderStyleWrongLocation,
    /// Number of built-in styles, not a selectable style.
    CYLSearchPlaceholderStyleCount,
};

/// Built-in localized messages, independently selectable from the image.
typedef NS_ENUM(NSInteger, CYLSearchPlaceholderMessage) {
    CYLSearchPlaceholderMessageEmpty,
    CYLSearchPlaceholderMessageNoResults,
    CYLSearchPlaceholderMessageError,
    CYLSearchPlaceholderMessageNetwork,
};

/// A reusable empty-state view; use UIKit APIs on the main thread.
@interface CYLSearchPlaceholderView : UIView

@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UILabel *textLabel;
/// The image's resource name in CYLSearchViewController.bundle.
+ (NSString *)imageNameForStyle:(CYLSearchPlaceholderStyle)style;
/// Chooses matching built-in image and message.
- (instancetype)initWithKind:(CYLSearchPlaceholderKind)kind;
/// Combines any built-in image and localized message.
- (instancetype)initWithStyle:(CYLSearchPlaceholderStyle)style message:(CYLSearchPlaceholderMessage)message;
/// Uses a built-in image and caller-provided text, without localizing the text.
- (instancetype)initWithStyle:(CYLSearchPlaceholderStyle)style text:(NSString *)text;
/// Uses a caller-provided image and localized message.
- (instancetype)initWithImage:(UIImage *)image message:(CYLSearchPlaceholderMessage)message;
/// Uses a caller-provided image and text. Neither value is modified.
- (instancetype)initWithImage:(UIImage *)image text:(NSString *)text NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

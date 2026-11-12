#import "CYLSearchPlaceholderView.h"
#import <CYLSearchViewController/CYLSearchViewController-Swift.h>

@implementation CYLSearchPlaceholderView

static UIImage *CYLSearchPlaceholderImage(CYLSearchPlaceholderStyle style)
{
    NSString *name = [CYLSearchPlaceholderView imageNameForStyle:style];
    UIImage *image = [CYLSearchResources imageNamed:name];
    return style == CYLSearchPlaceholderStyleEmpty ? image : [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

+ (NSString *)imageNameForStyle:(CYLSearchPlaceholderStyle)style
{
    static NSArray<NSString *> *names;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        names = @[
            @"CYLSearchEmpty", @"CYLSearchNoResults", @"CYLSearchError",
            @"CYLSearchWifiOff", @"CYLSearchSignalWifiOff", @"CYLSearchNoInternet",
            @"CYLSearchCloudOff", @"CYLSearchSyncProblem", @"CYLSearchSyncDisabled",
            @"CYLSearchNetworkLocked", @"CYLSearchBluetoothDisabled", @"CYLSearchLocationOff",
            @"CYLSearchPublicOff", @"CYLSearchErrorOutline", @"CYLSearchWarning",
            @"CYLSearchReportProblem", @"CYLSearchBlocked", @"CYLSearchHelp",
            @"CYLSearchHourglass", @"CYLSearchLocked", @"CYLSearchVisibilityOff",
            @"CYLSearchSearchOff", @"CYLSearchFolderOff", @"CYLSearchFolderOpen",
            @"CYLSearchDownloadOff", @"CYLSearchUploadOff", @"CYLSearchInbox",
            @"CYLSearchBrokenImage", @"CYLSearchImageUnavailable", @"CYLSearchPhotoLibrary",
            @"CYLSearchMusicOff", @"CYLSearchVideoOff", @"CYLSearchPersonOff",
            @"CYLSearchGroupOff", @"CYLSearchEventBusy", @"CYLSearchEmptyCart",
            @"CYLSearchFavorite", @"CYLSearchBatteryAlert", @"CYLSearchUnknownDevice",
            @"CYLSearchPhoneDisabled", @"CYLSearchWrongLocation"
        ];
    });
    if (style < 0 || style >= CYLSearchPlaceholderStyleCount || names.count != CYLSearchPlaceholderStyleCount) {
        [NSException raise:NSInvalidArgumentException format:@"Unknown placeholder style: %ld", (long)style];
    }
    return names[style];
}

static NSString *CYLSearchPlaceholderText(CYLSearchPlaceholderMessage message)
{
    NSString *key;
    switch (message) {
        case CYLSearchPlaceholderMessageEmpty: key = @"placeholder.empty"; break;
        case CYLSearchPlaceholderMessageNoResults: key = @"placeholder.search"; break;
        case CYLSearchPlaceholderMessageError: key = @"placeholder.error"; break;
        case CYLSearchPlaceholderMessageNetwork: key = @"placeholder.network"; break;
        default: [NSException raise:NSInvalidArgumentException format:@"Unknown placeholder message: %ld", (long)message]; return nil;
    }
    return [CYLSearchResources localizedStringForKey:key];
}

- (instancetype)initWithKind:(CYLSearchPlaceholderKind)kind
{
    switch (kind) {
        case CYLSearchPlaceholderKindEmpty: return [self initWithStyle:CYLSearchPlaceholderStyleEmpty message:CYLSearchPlaceholderMessageEmpty];
        case CYLSearchPlaceholderKindNoResults: return [self initWithStyle:CYLSearchPlaceholderStyleNoResults message:CYLSearchPlaceholderMessageNoResults];
        case CYLSearchPlaceholderKindError: return [self initWithStyle:CYLSearchPlaceholderStyleError message:CYLSearchPlaceholderMessageError];
        default: [NSException raise:NSInvalidArgumentException format:@"Unknown placeholder kind: %ld", (long)kind]; return nil;
    }
}

- (instancetype)initWithStyle:(CYLSearchPlaceholderStyle)style message:(CYLSearchPlaceholderMessage)message
{
    return [self initWithImage:CYLSearchPlaceholderImage(style) text:CYLSearchPlaceholderText(message)];
}

- (instancetype)initWithStyle:(CYLSearchPlaceholderStyle)style text:(NSString *)text
{
    return [self initWithImage:CYLSearchPlaceholderImage(style) text:text];
}

- (instancetype)initWithImage:(UIImage *)image message:(CYLSearchPlaceholderMessage)message
{
    return [self initWithImage:image text:CYLSearchPlaceholderText(message)];
}

- (instancetype)initWithImage:(UIImage *)image text:(NSString *)text
{
    if (!image || !text) {
        [NSException raise:NSInvalidArgumentException format:@"Placeholder image and text must not be nil"];
    }
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _imageView = [[UIImageView alloc] initWithImage:image];
        _imageView.tintColor = UIColor.secondaryLabelColor;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _textLabel = [UILabel new];
        _textLabel.text = text;
        _textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _textLabel.adjustsFontForContentSizeCategory = YES;
        _textLabel.textColor = UIColor.secondaryLabelColor;
        _textLabel.numberOfLines = 0;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[_imageView, _textLabel]];
        stack.axis = UILayoutConstraintAxisVertical;
        stack.spacing = 12;
        stack.alignment = UIStackViewAlignmentCenter;
        stack.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:stack];
        [NSLayoutConstraint activateConstraints:@[
            [stack.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [stack.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
            [stack.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.leadingAnchor constant:16],
            [stack.trailingAnchor constraintLessThanOrEqualToAnchor:self.trailingAnchor constant:-16],
            [_imageView.widthAnchor constraintEqualToConstant:80],
            [_imageView.heightAnchor constraintEqualToConstant:80],
            [_textLabel.widthAnchor constraintLessThanOrEqualToAnchor:self.widthAnchor constant:-32]
        ]];
    }
    return self;
}

@end

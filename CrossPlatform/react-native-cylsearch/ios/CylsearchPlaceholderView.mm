#import "CylsearchPlaceholderView.h"
#import "CYLRNSearchSupport.h"

#import <react/renderer/components/CylsearchViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/CylsearchViewSpec/EventEmitters.h>
#import <react/renderer/components/CylsearchViewSpec/Props.h>
#import <react/renderer/components/CylsearchViewSpec/RCTComponentViewHelpers.h>

using namespace facebook::react;

/*!
 * The CYLPlaceholderStyle of a name, ignoring case ("noResults", "personOff"…); `CYLPlaceholderStyleEmpty` when unknown,
 * as on Android.
 */
static CYLPlaceholderStyle CYLRNPlaceholderStyle(NSString *name)
{
  static NSDictionary<NSString *, NSNumber *> *styles;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    styles = @{
    @"empty": @(CYLPlaceholderStyleEmpty),
    @"noresults": @(CYLPlaceholderStyleNoResults),
    @"error": @(CYLPlaceholderStyleError),
    @"wifioff": @(CYLPlaceholderStyleWifiOff),
    @"signalwifioff": @(CYLPlaceholderStyleSignalWifiOff),
    @"nointernet": @(CYLPlaceholderStyleNoInternet),
    @"cloudoff": @(CYLPlaceholderStyleCloudOff),
    @"syncproblem": @(CYLPlaceholderStyleSyncProblem),
    @"syncdisabled": @(CYLPlaceholderStyleSyncDisabled),
    @"networklocked": @(CYLPlaceholderStyleNetworkLocked),
    @"bluetoothdisabled": @(CYLPlaceholderStyleBluetoothDisabled),
    @"locationoff": @(CYLPlaceholderStyleLocationOff),
    @"publicoff": @(CYLPlaceholderStylePublicOff),
    @"erroroutline": @(CYLPlaceholderStyleErrorOutline),
    @"warning": @(CYLPlaceholderStyleWarning),
    @"reportproblem": @(CYLPlaceholderStyleReportProblem),
    @"blocked": @(CYLPlaceholderStyleBlocked),
    @"help": @(CYLPlaceholderStyleHelp),
    @"hourglass": @(CYLPlaceholderStyleHourglass),
    @"locked": @(CYLPlaceholderStyleLocked),
    @"visibilityoff": @(CYLPlaceholderStyleVisibilityOff),
    @"searchoff": @(CYLPlaceholderStyleSearchOff),
    @"folderoff": @(CYLPlaceholderStyleFolderOff),
    @"folderopen": @(CYLPlaceholderStyleFolderOpen),
    @"downloadoff": @(CYLPlaceholderStyleDownloadOff),
    @"uploadoff": @(CYLPlaceholderStyleUploadOff),
    @"inbox": @(CYLPlaceholderStyleInbox),
    @"brokenimage": @(CYLPlaceholderStyleBrokenImage),
    @"imageunavailable": @(CYLPlaceholderStyleImageUnavailable),
    @"photolibrary": @(CYLPlaceholderStylePhotoLibrary),
    @"musicoff": @(CYLPlaceholderStyleMusicOff),
    @"videooff": @(CYLPlaceholderStyleVideoOff),
    @"personoff": @(CYLPlaceholderStylePersonOff),
    @"groupoff": @(CYLPlaceholderStyleGroupOff),
    @"eventbusy": @(CYLPlaceholderStyleEventBusy),
    @"emptycart": @(CYLPlaceholderStyleEmptyCart),
    @"favorite": @(CYLPlaceholderStyleFavorite),
    @"batteryalert": @(CYLPlaceholderStyleBatteryAlert),
    @"unknowndevice": @(CYLPlaceholderStyleUnknownDevice),
    @"phonedisabled": @(CYLPlaceholderStylePhoneDisabled),
    @"wronglocation": @(CYLPlaceholderStyleWrongLocation),
    @"archive": @(CYLPlaceholderStyleArchive),
    @"info": @(CYLPlaceholderStyleInfo),
    @"refresh": @(CYLPlaceholderStyleRefresh),
    @"delete": @(CYLPlaceholderStyleDelete),
    @"search": @(CYLPlaceholderStyleSearch),
    @"mail": @(CYLPlaceholderStyleMail),
    @"image": @(CYLPlaceholderStyleImage),
    @"cloud": @(CYLPlaceholderStyleCloud),
    @"notificationsoff": @(CYLPlaceholderStyleNotificationsOff),
    @"history": @(CYLPlaceholderStyleHistory)
    };
  });
  NSNumber *style = styles[name.lowercaseString];
  return style ? (CYLPlaceholderStyle)style.integerValue : CYLPlaceholderStyleEmpty;
}

/*!
 * CYLTableViewPlaceHolder's CYLPlaceholderView in the component: the image of a `CYLPlaceholderStyle` above a text, at
 * its content size, centred.
 */
@implementation CylsearchPlaceholderView {
  CYLPlaceholderView *_placeholderView;
  NSString *_styleName;
  NSString *_text;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<CylsearchPlaceholderViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const CylsearchPlaceholderViewProps>();
    _props = defaultProps;
  }
  return self;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
  const auto &p = *std::static_pointer_cast<CylsearchPlaceholderViewProps const>(props);
  NSString *styleName = CYLRNString(p.placeholderStyle);
  NSString *text = CYLRNString(p.text);
  // Rebuilt only when the style or the text changes.
  if (!_placeholderView || ![styleName isEqualToString:_styleName] || ![text isEqualToString:_text]) {
    _styleName = styleName;
    _text = text;
    [_placeholderView removeFromSuperview];
    _placeholderView = [[CYLPlaceholderView alloc] initWithStyle:CYLRNPlaceholderStyle(styleName) text:text];
    _placeholderView.reportsContentSize = YES;
    [self addSubview:_placeholderView];
  }
  self.overrideUserInterfaceStyle = CYLRNInterfaceStyle(CYLRNString(p.colorScheme));
  [super updateProps:props oldProps:oldProps];
  [self setNeedsLayout];
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  CGRect bounds = self.bounds;
  _placeholderView.preferredMaxLayoutWidth = CGRectGetWidth(bounds);
  CGSize size = _placeholderView.intrinsicContentSize;
  size.width = MIN(CGRectGetWidth(bounds), size.width > 0 ? size.width : CGRectGetWidth(bounds));
  size.height = MIN(CGRectGetHeight(bounds), MAX(0, size.height));
  _placeholderView.frame = CGRectMake(CGRectGetMidX(bounds) - size.width / 2, CGRectGetMidY(bounds) - size.height / 2,
                                      size.width, size.height);
}

@end

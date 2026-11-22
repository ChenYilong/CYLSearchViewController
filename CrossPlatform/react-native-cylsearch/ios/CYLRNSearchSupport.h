#import <UIKit/UIKit.h>
// CYLTagButton's superclass, CYLAnimatedItemView: Objective-C++ cannot use the Swift header's @import, so it comes first.
#import <CYLAnimatedItem/CYLAnimatedItem.h>
#import <CollectionViewClassifyMenu/CollectionViewClassifyMenu-Swift.h>
// The types the generated Swift header uses (CYLPlaceholderScenario, CYLTagListView) come first.
#import <CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.h>
#import <CYLSearchViewController/CYLSearchViewController-Swift.h>
#import <string>
#import <vector>

NS_ASSUME_NONNULL_BEGIN

/*!
 * A C++ string as an NSString.
 */
static inline NSString *CYLRNString(const std::string &value)
{
  return [NSString stringWithUTF8String:value.c_str()] ?: @"";
}

/*!
 * A list of C++ strings as NSStrings.
 */
static inline NSArray<NSString *> *CYLRNStrings(const std::vector<std::string> &values)
{
  NSMutableArray<NSString *> *strings = [NSMutableArray arrayWithCapacity:values.size()];
  for (const auto &value : values) {
    [strings addObject:CYLRNString(value)];
  }
  return strings;
}

/*!
 * The fold control for "none", "inline", "bottom", "topTrailing" or "topLeading" and "icon", "title" or "iconAndTitle";
 * an inline icon by default.
 */
static inline CYLMenuFoldControl *CYLRNFoldControl(NSString *position, NSString *content)
{
  // The component's names, and CollectionViewClassifyMenu's own since its position rename (tail, footer, header…).
  NSDictionary<NSString *, NSNumber *> *positions = @{
    @"none": @(CYLMenuFoldControlPositionNone),
    @"inline": @(CYLMenuFoldControlPositionTail), @"tail": @(CYLMenuFoldControlPositionTail),
    @"bottom": @(CYLMenuFoldControlPositionFooter), @"footer": @(CYLMenuFoldControlPositionFooter),
    @"topTrailing": @(CYLMenuFoldControlPositionHeaderTrailing),
    @"headerTrailing": @(CYLMenuFoldControlPositionHeaderTrailing),
    @"topLeading": @(CYLMenuFoldControlPositionHeaderLeading),
    @"headerLeading": @(CYLMenuFoldControlPositionHeaderLeading)
  };
  NSDictionary<NSString *, NSNumber *> *contents = @{
    @"icon": @(CYLMenuFoldControlContentIcon), @"title": @(CYLMenuFoldControlContentTitle),
    @"iconAndTitle": @(CYLMenuFoldControlContentIconAndTitle)
  };
  return [[CYLMenuFoldControl alloc]
      initWithPosition:(CYLMenuFoldControlPosition)(positions[position] ?: @(CYLMenuFoldControlPositionTail)).integerValue
               content:(CYLMenuFoldControlContent)(contents[content] ?: @(CYLMenuFoldControlContentIcon)).integerValue];
}

/*!
 * The interface style for "dark" or anything else.
 */
static inline UIUserInterfaceStyle CYLRNInterfaceStyle(NSString *scheme)
{
  return [scheme isEqualToString:@"dark"] ? UIUserInterfaceStyleDark : UIUserInterfaceStyleLight;
}

/*!
 * A color of "#RRGGBB" or "#AARRGGBB"; nil for an empty or unreadable value.
 */
static inline UIColor *_Nullable CYLRNColor(NSString *value)
{
  NSString *hex = [value hasPrefix:@"#"] ? [value substringFromIndex:1] : value;
  if (hex.length != 6 && hex.length != 8) {
    return nil;
  }
  unsigned long long number = 0;
  if (![[NSScanner scannerWithString:hex] scanHexLongLong:&number]) {
    return nil;
  }
  CGFloat alpha = hex.length == 8 ? ((number >> 24) & 0xFF) / 255.0 : 1.0;
  return [UIColor colorWithRed:((number >> 16) & 0xFF) / 255.0 green:((number >> 8) & 0xFF) / 255.0 blue:(number & 0xFF) / 255.0 alpha:alpha];
}

/*!
 * The margins [top, left, bottom, right] of a JavaScript array; zero for a short array.
 */
static inline UIEdgeInsets CYLRNInsets(const std::vector<double> &values)
{
  return values.size() < 4 ? UIEdgeInsetsZero : UIEdgeInsetsMake(values[0], values[1], values[2], values[3]);
}

/*!
 * The object or the array of a JSON string; nil for an empty or unreadable one.
 */
static inline id _Nullable CYLRNJSON(NSString *json)
{
  NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
  return data.length > 0 ? [NSJSONSerialization JSONObjectWithData:data options:0 error:nil] : nil;
}

/*!
 * The core's history of a search view: `policyName` ("none", "userDefaults", "database" or "sandboxFile") and `name`; set only
 * when one of them changed (`defaultPolicy` for an unknown name), so the cache is not rebuilt on every prop update. One
 * mapping for `CylsearchView` and `CylsearchListView`.
 */
static inline void CYLRNApplySuggestionCache(CYLSearchView *searchView, NSString *policyName, NSString *name, NSString *defaultName,
                                             CYLSearchSuggestionCachePolicy defaultPolicy)
{
  NSDictionary<NSString *, NSNumber *> *policies = @{
    @"none": @(CYLSearchSuggestionCachePolicyNone), @"database": @(CYLSearchSuggestionCachePolicyDatabase),
    @"userDefaults": @(CYLSearchSuggestionCachePolicyUserDefaults), @"sandboxFile": @(CYLSearchSuggestionCachePolicySandboxFile)
  };
  CYLSearchSuggestionCachePolicy policy = (CYLSearchSuggestionCachePolicy)(policies[policyName] ?: @(defaultPolicy)).integerValue;
  NSString *cacheName = name.length > 0 ? name : defaultName;
  if (policy != searchView.suggestionCachePolicy || ![cacheName isEqualToString:searchView.suggestionCacheName]) {
    searchView.suggestionCacheName = cacheName;
    searchView.suggestionCachePolicy = policy;
  }
}

/*!
 * A stroked rounded square (QDSearchBarViewController's 30 x 30 accessory) of a JSON spec ({"size","color","label"}); nil for
 * no spec.
 */
UIView *_Nullable CYLRNSquare(NSDictionary *_Nullable spec);

NS_ASSUME_NONNULL_END

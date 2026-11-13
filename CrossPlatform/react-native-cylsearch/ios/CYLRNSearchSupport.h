#import <UIKit/UIKit.h>
#import <CollectionViewClassifyMenu/CollectionViewClassifyMenu-umbrella.h>
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
  NSDictionary<NSString *, NSNumber *> *positions = @{
    @"none": @(CYLMenuFoldControlPositionNone), @"inline": @(CYLMenuFoldControlPositionInline),
    @"bottom": @(CYLMenuFoldControlPositionBottom), @"topTrailing": @(CYLMenuFoldControlPositionTopTrailing),
    @"topLeading": @(CYLMenuFoldControlPositionTopLeading)
  };
  NSDictionary<NSString *, NSNumber *> *contents = @{
    @"icon": @(CYLMenuFoldControlContentIcon), @"title": @(CYLMenuFoldControlContentTitle),
    @"iconAndTitle": @(CYLMenuFoldControlContentIconAndTitle)
  };
  return [CYLMenuFoldControl foldControlWithPosition:(CYLMenuFoldControlPosition)(positions[position] ?: @(CYLMenuFoldControlPositionInline)).integerValue
                                             content:(CYLMenuFoldControlContent)(contents[content] ?: @(CYLMenuFoldControlContentIcon)).integerValue];
}

/*!
 * The interface style for "dark" or anything else.
 */
static inline UIUserInterfaceStyle CYLRNInterfaceStyle(NSString *scheme)
{
  return [scheme isEqualToString:@"dark"] ? UIUserInterfaceStyleDark : UIUserInterfaceStyleLight;
}

NS_ASSUME_NONNULL_END

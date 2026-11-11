#import <UIKit/UIKit.h>

@interface CYLSearchExampleAppDelegate : UIResponder <UIApplicationDelegate>

/*!
 * The tab bar built from CYLTabBarConfiguration.json (search, examples and the plus page), or the examples menu
 * when the file cannot be read.
 */
+ (UIViewController *)rootViewController;

@end

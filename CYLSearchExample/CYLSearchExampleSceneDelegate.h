#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 * Creates the example's window in its scene, with `+[CYLSearchExampleAppDelegate rootViewController]` as the root.
 * Apps built with the iOS 27 SDK must adopt the scene life cycle; without it the app does not launch.
 */
@interface CYLSearchExampleSceneDelegate : UIResponder <UIWindowSceneDelegate>

@property (nonatomic, strong, nullable) UIWindow *window;

@end

NS_ASSUME_NONNULL_END

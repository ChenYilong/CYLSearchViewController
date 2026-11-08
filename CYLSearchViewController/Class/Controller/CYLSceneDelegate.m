//
//  CYLSceneDelegate.m
//  CYLSearchViewController
//

#import "CYLSceneDelegate.h"
#import "CYLSearchAppCoordinator.h"

@implementation CYLSceneDelegate

- (void)scene:(UIScene *)scene
willConnectToSession:(UISceneSession *)session
      options:(UISceneConnectionOptions *)connectionOptions
{
    if (@available(iOS 13.0, *)) {
        if (![scene isKindOfClass:[UIWindowScene class]]) {
            return;
        }

        UIWindowScene *windowScene = (UIWindowScene *)scene;
        self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
        self.window.rootViewController = [CYLSearchAppCoordinator rootNavigationController];
        self.window.tintColor = UIColor.whiteColor;
        [self.window makeKeyAndVisible];
    }
}

@end

#import "CYLSearchExampleSceneDelegate.h"
#import "CYLSearchExampleAppDelegate.h"

@implementation CYLSearchExampleSceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions
{
    if (![scene isKindOfClass:UIWindowScene.class]) return;
    self.window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
    self.window.rootViewController = [CYLSearchExampleAppDelegate rootViewController];
    [self.window makeKeyAndVisible];
}

@end

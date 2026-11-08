#import "CYLSearchExampleAppDelegate.h"
#import "CYLSearchDemoMenuViewController.h"

@implementation CYLSearchExampleAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    CYLSearchDemoMenuViewController *controller = [[CYLSearchDemoMenuViewController alloc] initWithStyle:UITableViewStyleGrouped];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self.window makeKeyAndVisible];
    return YES;
}

@end

#import "CYLSearchExampleAppDelegate.h"
#import "CYLSearchExampleViewController.h"

@implementation CYLSearchExampleAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    CYLSearchExampleDataSource *dataSource = [[CYLSearchExampleDataSource alloc] init];
    CYLSearchExampleViewController *controller = [[CYLSearchExampleViewController alloc] initWithSearchDataSource:dataSource
                                                                                                 refreshProvider:dataSource];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self.window makeKeyAndVisible];
    return YES;
}

@end

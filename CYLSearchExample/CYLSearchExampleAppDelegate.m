#import "CYLSearchExampleAppDelegate.h"
#import "CYLSearchBarDemoViewController.h"
#import "CYLSearchDemoMenuViewController.h"
#import "CYLSearchExampleViewController.h"
#import <CYLTabBarController/CYLTabBarController.h>

@implementation CYLSearchExampleAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = [CYLSearchExampleAppDelegate rootViewController];
    [self.window makeKeyAndVisible];
    return YES;
}

+ (UIViewController *)rootViewController
{
    [self registerPages:CYLTabBarPageRegistry.sharedRegistry];
    NSError *error = nil;
    CYLTabBarController *tabBarController = [CYLTabBarController tabBarControllerWithConfigurationFile:@"CYLTabBarConfiguration.json" error:&error];
    if (tabBarController) {
        // `-CYLDemoTab 1` on launch selects that tab, for screenshots.
        NSString *tab = [NSUserDefaults.standardUserDefaults stringForKey:@"CYLDemoTab"];
        if (tab.length > 0 && tab.integerValue >= 0 && tab.integerValue < (NSInteger)tabBarController.viewControllers.count) {
            tabBarController.selectedIndex = tab.integerValue;
        }
        return tabBarController;
    }
    NSLog(@"CYLTabBarConfiguration.json: %@", error);
    return [self navigationControllerWithRoot:[[CYLSearchDemoMenuViewController alloc] initWithStyle:UITableViewStyleGrouped]];
}

+ (void)registerPages:(CYLTabBarPageRegistry *)pages
{
    // Search pages live in navigation controllers, so navigationItem.searchController and the Issue #1317
    // workaround (hidesSearchBarWhenScrolling = NO) keep working.
    [pages registerPageProvider:^UIViewController *(NSString *pageIdentifier, NSDictionary<NSString *, id> *tab) {
        CYLSearchExampleDataSource *source = [CYLSearchExampleDataSource new];
        return [self navigationControllerWithRoot:[[CYLSearchExampleViewController alloc] initWithSearchDataSource:source refreshProvider:source]];
    } forPageIdentifier:@"search"];
    [pages registerPageProvider:^UIViewController *(NSString *pageIdentifier, NSDictionary<NSString *, id> *tab) {
        return [self navigationControllerWithRoot:[[CYLSearchDemoMenuViewController alloc] initWithStyle:UITableViewStyleGrouped]];
    } forPageIdentifier:@"examples"];
    [pages registerPageProvider:^UIViewController *(NSString *pageIdentifier, NSDictionary<NSString *, id> *tab) {
        return [self navigationControllerWithRoot:[CYLSearchBarDemoViewController new]];
    } forPageIdentifier:@"plus"];
}

+ (UINavigationController *)navigationControllerWithRoot:(UIViewController *)root
{
    return [[UINavigationController alloc] initWithRootViewController:root];
}

@end

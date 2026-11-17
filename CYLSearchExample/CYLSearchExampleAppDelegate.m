#import "CYLSearchExampleAppDelegate.h"
#import "CYLSearchBarDemoViewController.h"
#import "CYLSearchDemoMenuViewController.h"
#import "CYLSearchExample-Swift.h"
#import <CYLTabBarController/CYLTabBarController.h>
// The SVGA animator lives in the CYLAnimatedItem pod (CYLAnimatedItem/SVGA) since CYLTabBarController c53d289.
#import <CYLAnimatedItem/CYLSVGATabBarItemAnimator.h>

/// A tab title from CYLSearchTabs.bundle, as the configuration file's `CYLTabBarControllerLocalization` reads it.
static NSString *CYLSearchTabTitle(NSString *key)
{
    NSBundle *bundle = [NSBundle bundleWithPath:[NSBundle.mainBundle pathForResource:@"CYLSearchTabs" ofType:@"bundle"]];
    return [bundle localizedStringForKey:key value:key table:@"CYLSearchTabs"];
}

@implementation CYLSearchExampleAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // CYLSearchExampleSceneDelegate creates the window (Info.plist, UIApplicationSceneManifest): apps built with the
    // iOS 27 SDK must adopt the scene life cycle.
    return YES;
}

+ (UIViewController *)rootViewController
{
    [self registerPages:CYLTabBarPageRegistry.sharedRegistry];
    NSError *error = nil;
    CYLTabBarController *tabBarController = [self tabBarControllerForIconSource:&error];
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

/// Where the tab icons come from (`-CYLDemoTabIconSource <n>` launch argument or user default), as CYLTabBarController's
/// Example-Rive: 0 SF Symbols (`CYLTabBarConfiguration.json`); 1 SVGA through the initialization keys
/// (`CYLTabBarSVGAURL`, `CYLTabBarSVGASize`); 2 SVGA through a configuration file (`CYLTabBarConfiguration_svga.json`).
+ (CYLTabBarController *)tabBarControllerForIconSource:(NSError **)error
{
    NSInteger source = [NSUserDefaults.standardUserDefaults integerForKey:@"CYLDemoTabIconSource"];
    if (source == 2) {
        return [CYLTabBarController tabBarControllerWithConfigurationFile:@"CYLTabBarConfiguration_svga.json" error:error];
    }
    if (source != 1) {
        return [CYLTabBarController tabBarControllerWithConfigurationFile:@"CYLTabBarConfiguration.json" error:error];
    }
    // The initialization keys: the same tabs as CYLTabBarConfiguration.json, written in code, each with its SVGA file.
    NSMutableArray<NSDictionary *> *tabs = [NSMutableArray array];
    // Search and Discover have a second file for dark mode (`CYLTabBarSVGADarkURL`), as the Rive demo's dark file.
    NSDictionary<NSString *, NSString *> *darkFiles = @{ @"search" : @"tab_activity", @"discover" : @"tab_profile" };
    for (NSArray<NSString *> *tab in @[ @[ @"search", @"tab.search", @"tab_search" ], @[ @"examples", @"tab.examples", @"tab_list" ],
                                        @[ @"tagStyle", @"tab.tagStyle", @"tab_chat" ], @[ @"discover", @"tab.discover", @"tab_home" ] ]) {
        NSURL *url = [NSBundle.mainBundle URLForResource:tab[2] withExtension:@"svga"];
        NSURL *darkURL = darkFiles[tab[0]] ? [NSBundle.mainBundle URLForResource:darkFiles[tab[0]] withExtension:@"svga"] : nil;
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        if (darkURL) attributes[CYLTabBarSVGADarkURL] = darkURL;
        [attributes addEntriesFromDictionary:@{
            CYLTabBarItemTitle : CYLSearchTabTitle(tab[1]),
            CYLTabBarItemIdentifier : tab[0],
            CYLTabBarItemPageIdentifier : tab[0],
            CYLTabBarSVGAURL : url,
            CYLTabBarSVGASize : [NSValue valueWithCGSize:CGSizeMake(28, 28)],
        }];
        [tabs addObject:attributes];
    }
    // `-CYLDemoTabBarStyle flatDesign` (or "liquidGlass", "default"): the same icons in another tab bar style.
    NSString *style = [NSUserDefaults.standardUserDefaults stringForKey:@"CYLDemoTabBarStyle"] ?: @"default";
    return [CYLTabBarController tabBarControllerWithConfiguration:@{
        CYLTabBarControllerContext : @"CYLSearchExample",
        CYLTabBarControllerStyleType : style,
        CYLTabBarControllerTabBarItemsAttributes : tabs,
        CYLTabBarControllerTitlePositionAdjustment : [NSValue valueWithUIOffset:UIOffsetMake(0, -2)],
        CYLTabBarControllerPlusButton : @{
            CYLTabBarItemTitle : CYLSearchTabTitle(@"tab.searchBar"),
            CYLTabBarItemImage : [UIImage systemImageNamed:@"plus.circle.fill"],
            CYLTabBarItemIdentifier : @"plus",
            CYLTabBarItemPageIdentifier : @"plus",
        },
    }];
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
    // The suggestion style demos (docs/tag-view-suggestions.md): suggestions as tags, and the discover page copied from
    // CollectionViewClassifyMenu. The discover page draws its own search bar in place of the navigation bar.
    [pages registerPageProvider:^UIViewController *(NSString *pageIdentifier, NSDictionary<NSString *, id> *tab) {
        return [self navigationControllerWithRoot:[CYLSuggestionDemoPages tagStyleViewController]];
    } forPageIdentifier:@"tagStyle"];
    [pages registerPageProvider:^UIViewController *(NSString *pageIdentifier, NSDictionary<NSString *, id> *tab) {
        return [self navigationControllerWithRoot:[CYLSuggestionDemoPages discoverViewController]];
    } forPageIdentifier:@"discover"];
}

+ (UINavigationController *)navigationControllerWithRoot:(UIViewController *)root
{
    return [[UINavigationController alloc] initWithRootViewController:root];
}

@end

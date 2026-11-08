//
//  AppDelegate.m
//  CYLSearchViewController
//
//  Created by http://weibo.com/luohanchenyilong/ on 15/4/29.
//  Copyright (c) 2015年 https://github.com/ChenYilong/CYLSearchViewController . All rights reserved.
//

#import "AppDelegate.h"
#import "CYLSearchAppCoordinator.h"
#import "CYLSceneDelegate.h"
//Views
#import "CYLKenBurnsView.h"

@interface AppDelegate () <CYLKenBurnsViewDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if ([UINavigationBar conformsToProtocol:@protocol(UIAppearanceContainer)]) {
        [UINavigationBar appearance].tintColor = [UIColor whiteColor];
        [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:18], NSForegroundColorAttributeName : [UIColor whiteColor]}];
        [[UINavigationBar appearance] setBarTintColor:
         [UIColor colorWithRed:22/255.0 green:59/255.0 blue:188/255.0 alpha:1]
         ] ;
        [[UINavigationBar appearance] setTranslucent:NO];
    }

    if (@available(iOS 13.0, *)) {
        return YES;
    }

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.tintColor = [UIColor whiteColor];
    self.navigationController = [CYLSearchAppCoordinator rootNavigationController];
    self.window.rootViewController = self.navigationController;

    CYLKenBurnsView *kenView = [[CYLKenBurnsView alloc] initWithFrame:self.window.bounds];
    kenView.layer.borderWidth = 1;
    kenView.layer.borderColor = [UIColor blackColor].CGColor;
    kenView.delegate = self;
    NSArray *images = @[[UIImage imageNamed:@"image3.png"]];
    [kenView animateWithImages:images transitionDuration:15 loop:YES isLandscape:YES];
    [self.window insertSubview:kenView atIndex:0];

    [self.window makeKeyAndVisible];
    return YES;
}

- (UISceneConfiguration *)application:(UIApplication *)application
configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession
                               options:(UISceneConnectionOptions *)options API_AVAILABLE(ios(13.0))
{
    UISceneConfiguration *configuration =
        [[UISceneConfiguration alloc] initWithName:@"Default Configuration"
                                       sessionRole:connectingSceneSession.role];
    configuration.delegateClass = [CYLSceneDelegate class];
    return configuration;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

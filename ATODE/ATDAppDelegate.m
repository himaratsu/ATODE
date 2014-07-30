//
//  ATDAppDelegate.m
//  ATODE
//
//  Created by himara2 on 2014/06/29.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ATDAppDelegate.h"
#import "GAI.h"
#import "Crittercism.h"
#import "UIViewController+GAInject.h"

@implementation ATDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Google Analytics
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 20;
    
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-53347390-1"];
    
    // GAIを仕込む
    [UIViewController exchangeMethod];
    
    // 見た目
    [self setAppearance];
    
    // Crittercism
//    [Crittercism enableWithAppID:@"531f7f9d0ee9483d3d000001"];

    return YES;
}


// 見た目の設定
- (void)setAppearance {
    [UITableViewCell appearance].separatorInset = UIEdgeInsetsZero;
    
    [UINavigationBar appearance].barTintColor = [UIColor colorWithRed:70/255.0 green:171/255.0 blue:235/255.0 alpha:1.0];
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    NSDictionary *attributes = @{
                                 NSFontAttributeName : [UIFont systemFontOfSize:18],
                                 NSForegroundColorAttributeName : [UIColor whiteColor]
                                 };
    [UINavigationBar appearance].titleTextAttributes = attributes;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

//
//  RCAppDelegate.m
//  Valt
//
//  Created by Rob Caraway on 12/10/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCAppDelegate.h"
#import "RCRootViewController.h"
#import "RCNetworking.h"
#import "RCPasswordManager.h"
#import <Parse/Parse.h>
#import "NSString+Encryption.h"
#import "RCNetworkListener.h"

#define LAUNCH_COUNT_KEY @"LAUNCH_COUNT_KEY"
#define FIRST_LAUNCH_COUNT_KEY @"FIRST_LAUNCH_COUNT_KEY"

@implementation RCAppDelegate

-(BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:@"HlDWnYtllU4xd5cYbDgyXMFbx1fNzetYwii4WLqB"
                  clientKey:@"JWR7JvgVZETnVcoj27teczJRY0DuF49QTXZl09VG"];
    [RCNetworkListener beginListening];
    [RCPasswordManager defaultManager];
    if ([[RCNetworking sharedNetwork] loggedIn]){
        [[RCNetworking sharedNetwork] defaultACLForUser:[PFUser currentUser]];
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self registerLaunchCount];
    [self incrementCount];
    self.rootController = [[RCRootViewController  alloc] initWithNibName:nil bundle:nil];
    self.window = [[UIWindow  alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window setRootViewController:self.rootController];
    [self.window makeKeyAndVisible];
    return YES;
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
    [RCNetworkListener stopListening];
}

#pragma mark - LaunchCount

-(void)registerLaunchCount
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{FIRST_LAUNCH_COUNT_KEY: @YES,
                                                              LAUNCH_COUNT_KEY : @0}];
}

-(void)incrementCount
{
    NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:LAUNCH_COUNT_KEY];
    BOOL first = [[NSUserDefaults standardUserDefaults] integerForKey:FIRST_LAUNCH_COUNT_KEY];
    if ((first && count > 15) || (!first && count > 25)){
        count = 0;
        first = NO;
    }else {
        count = count + 1;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:count forKey:LAUNCH_COUNT_KEY];
    [[NSUserDefaults standardUserDefaults] setBool:first forKey:FIRST_LAUNCH_COUNT_KEY];
}

-(BOOL)launchCountTriggered
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:FIRST_LAUNCH_COUNT_KEY]){
        return ([[NSUserDefaults standardUserDefaults] integerForKey:LAUNCH_COUNT_KEY] == 15);
    }else{
        return ([[NSUserDefaults standardUserDefaults] integerForKey:LAUNCH_COUNT_KEY] == 25);
    }
}

@end

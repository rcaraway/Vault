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
#import "RCNetworkListener.h"

#import <Parse/Parse.h>

#define LAUNCH_COUNT_KEY @"LAUNCH_COUNT_KEY"
#define FIRST_LAUNCH_COUNT_KEY @"FIRST_LAUNCH_COUNT_KEY"
#define RENEW_COUNT_KEY @"RENEW_COUNT_KEY"
#define LOCKS_ON_CLOSE @"LOCKS_ON_CLOSE"
#define SWIPE_RIGHT_TUTORIAL @"SWIPE_RIGHT_TUTORIAL"
#define AUTOFILL_TUTORIAL @"AUTOFILL_TUTORIAL"


@interface RCAppDelegate ()

@end

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
    [self registerDefaults];
    [self incrementCount];
    self.rootController = [[RCRootViewController  alloc] initWithNibName:nil bundle:nil];
    self.window = [[UIWindow  alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window setRootViewController:self.rootController];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if (self.locksOnClose){
        [[RCPasswordManager defaultManager] lockPasswordsCompletion:^{
        }];
        [self.rootController launchPasscode];
    }else{
        [[RCPasswordManager defaultManager] hideAllPasswordData];
    }
    if ([PFUser currentUser]){
         [PFUser logOut];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if ([[RCPasswordManager defaultManager] accessGranted]){
        [[RCPasswordManager defaultManager] reshowPasswordData];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [RCNetworkListener stopListening];
    [PFUser logOut];
}


#pragma mark - User Defaults

-(void)registerDefaults
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{FIRST_LAUNCH_COUNT_KEY: @YES,
                                                              LAUNCH_COUNT_KEY : @0,
                                                              RENEW_COUNT_KEY: @0,
                                                              LOCKS_ON_CLOSE : @YES,
                                                              SWIPE_RIGHT_TUTORIAL: @YES,
                                                              AUTOFILL_TUTORIAL: @YES}];
#ifdef NEW_USER_MODE
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SWIPE_RIGHT_TUTORIAL];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:AUTOFILL_TUTORIAL];
#endif
}

-(BOOL)swipeRightHint
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:SWIPE_RIGHT_TUTORIAL];
}

-(BOOL)locksOnClose
{
     return  [[NSUserDefaults standardUserDefaults] boolForKey:LOCKS_ON_CLOSE];
}

-(BOOL)autofillHints
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:AUTOFILL_TUTORIAL];
}

-(void)setSwipeRightHint:(BOOL)swipeRightHint
{
    [[NSUserDefaults standardUserDefaults] setBool:swipeRightHint forKey:SWIPE_RIGHT_TUTORIAL];
}

-(void)setLocksOnClose:(BOOL)locksOnClose
{
    [[NSUserDefaults standardUserDefaults] setBool:locksOnClose forKey:LOCKS_ON_CLOSE];
}

-(void)setAutofillHints:(BOOL)autofillHints
{
    [[NSUserDefaults standardUserDefaults] setBool:autofillHints forKey:AUTOFILL_TUTORIAL];
}

-(BOOL)shouldShowRenew
{
    static BOOL show = YES;
    NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:RENEW_COUNT_KEY];
    if (show){
        [[NSUserDefaults standardUserDefaults] setInteger:(count+1)%12 forKey:RENEW_COUNT_KEY];
        if (count == 0){
            return YES;
        }
    }
    return NO;
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

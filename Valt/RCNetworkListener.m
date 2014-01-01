//
//  RCNetworkQueue.m
//  Valt
//
//  Created by Robert Caraway on 12/31/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCNetworkListener.h"
#import "RCNetworking.h"
#import "RCPasswordManager.h"
#import "KGStatusBar.h"
#import "NSIndexPath+VaultPaths.h"



@interface RCNetworkListener ()

@property (nonatomic) BOOL shouldMerge;

@end


static RCNetworkListener * sharedQueue;

@implementation RCNetworkListener


#pragma mark - Class methods

+(BOOL)isListening
{
    return (sharedQueue != nil);
}

+(void)beginListening
{
    sharedQueue = [[RCNetworkListener alloc] init];
}

+(void)removeNetworking
{
    sharedQueue = nil;
}

+(void)setLoginAfterUse
{
    if (sharedQueue){
        sharedQueue.shouldMerge = YES;
    }
}

#pragma mark - Initialization

-(id)init
{
    self = super.init;
    if (self){
        self.shouldMerge = NO;
    }
    return self;
}


#pragma mark - Event Management

-(void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBeginLoggingIn) name:networkingDidBeginLoggingIn object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBeginSyncing) name:networkingDidBeginSyncing object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBeginFetching) name:networkingDidBeginFetching object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBeginDecrypting) name:networkingDidBeginDecrypting object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin) name:networkingDidLogin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFetch:) name:networkingDidFetchCredentials object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSync) name:networkingDidSync object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdatePasswords) name:passwordManagerDidUpdatePasswords object:nil];
}

-(void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - LifeCycle handling

-(void)didBecomeActive
{
    [[RCNetworking sharedNetwork] fetchFromServer];
}

-(void)didEnterBackground
{
    if ([[RCNetworking sharedNetwork] loggedIn] && [[RCPasswordManager defaultManager] accessGranted]){
        [[RCNetworking sharedNetwork] sync];
    }
}


#pragma mark - Progress Handling

-(void)didBeginLoggingIn
{
    if ([[RCPasswordManager defaultManager] accessGranted]) {
        [KGStatusBar showWithStatus:@"Logging In..."];
    }
}

-(void)didBeginSyncing
{
    [KGStatusBar showWithStatus:@"Saving..."];
}

-(void)didBeginFetching
{
    [KGStatusBar showWithStatus:@"Syncing..."];
}

-(void)didBeginDecrypting
{
    [KGStatusBar showWithStatus:@"Decrypting..."];
}


#pragma mark - Success Handling

-(void)didUpdatePasswords
{
    [[RCNetworking sharedNetwork] sync];
}

-(void)didLogin
{
    [[RCNetworking sharedNetwork] fetchFromServer];
}

-(void)didFetch:(NSNotification *)notification
{
    NSArray * passwords = notification.object;
    if (self.shouldMerge){
        [[RCPasswordManager defaultManager] addPasswords:passwords];
        self.shouldMerge = NO;
    }else{
        [[RCPasswordManager defaultManager] replaceAllPasswordsWithPasswords:passwords];
    }
}

-(void)didSync
{
    [KGStatusBar showSuccessWithStatus:@"Saved to Cloud."];
}

-(void)didGrantAccess
{
    [[RCNetworking sharedNetwork] fetchFromServer];
}

-(void)didLock
{
    
}

-(void)didDenyAccess
{
    [KGStatusBar showErrorWithStatus:@"Access Denied"];
}


#pragma mark - Failure Handling

-(void)didFailToGrantAccess
{
    [KGStatusBar showErrorWithStatus:@"Incorrect Password."];
}








@end

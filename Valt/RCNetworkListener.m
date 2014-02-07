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

#import "RCAppDelegate.h"
#import "RCRootViewController.h"
#import "RCListViewController.h"

#import "RCMessageView.h"
#import "RCTableView.h"

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
        [self addNotifications];
    }
    return self;
}


#pragma mark - Event Management

-(void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBeginExtendingPremium) name:networkingDidBeginExtendingPremium object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGoPremium) name:networkingDidGoPremium object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBeginLoggingIn) name:networkingDidBeginLoggingIn object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBeginSyncing) name:networkingDidBeginSyncing object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBeginFetching) name:networkingDidBeginFetching object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin) name:networkingDidLogin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFetch:) name:networkingDidFetchCredentials object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSync) name:networkingDidSync object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGrantPasswordAccess) name:passwordManagerAccessGranted object:nil];
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
//        [[RCNetworking sharedNetwork] sync];
    }
}

-(void)didGrantPasswordAccess
{
    [[RCNetworking sharedNetwork] fetchFromServer];
}

#pragma mark - Progress Handling

-(void)didBeginExtendingPremium
{
    [self showMessage:@"Saving Subscription..." autoDismiss:NO];
}

-(void)showMessage:(NSString *)message autoDismiss:(BOOL)autoDismiss
{
    [[[APP rootController] messageView] showMessage:message autoDismiss:autoDismiss];
}

-(void)didGoPremium
{
    [[RCNetworking sharedNetwork] sync];
}

-(void)didBeginLoggingIn
{
    if ([[RCPasswordManager defaultManager] accessGranted]) {
        [self showMessage:@"Logging In..." autoDismiss:NO];
    }
}

-(void)didBeginSyncing
{
    [self showMessage:@"Saving to Cloud..." autoDismiss:NO];
}

-(void)didBeginFetching
{
    [self showMessage:@"Syncing..." autoDismiss:NO];
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
    [[[[APP rootController] listController] tableView] reloadData];
}

-(void)didSync
{
    [self showMessage:@"Saved to Backup" autoDismiss:YES];
}

-(void)didGrantAccess
{
    NSString * username = [RCPasswordManager defaultManager].accountLogin;
    NSString * password = [RCPasswordManager defaultManager].accountPassword;
    if (username && password){
        [[RCNetworking sharedNetwork] loginWithEmail:username password:password];
    }
}

-(void)didLock
{
    
}

-(void)didDenyAccess
{
    [self showMessage:@"Access Denied" autoDismiss:YES];
}



@end

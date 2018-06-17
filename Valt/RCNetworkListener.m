//
//  RCNetworkQueue.m
//  Valt
//
//  Created by Robert Caraway on 12/31/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCNetworkListener.h"
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

+(void)stopListening
{
    [sharedQueue removeNotifications];
    sharedQueue = nil;
}

+(void)setShouldMerge
{
    sharedQueue.shouldMerge = YES;
}

#pragma mark - Initialization

-(id)init
{
    self = super.init;
    if (self){
        self.shouldMerge = YES;
        [self addNotifications];
    }
    return self;
}


#pragma mark - Event Management

-(void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLockPhone) name:UIApplicationProtectedDataWillBecomeUnavailable object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUnlockPhone) name:UIApplicationProtectedDataDidBecomeAvailable object:nil];
}

-(void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - LifeCycle handling

-(void)didLockPhone
{
    if ([[RCPasswordManager defaultManager] accessGranted]){
        [[RCPasswordManager defaultManager] hideAllPasswordData];
    }
}

-(void)didUnlockPhone
{
    if ([[RCPasswordManager defaultManager] accessGranted]){
        [[RCPasswordManager defaultManager] reshowPasswordData];
    }
    
}

-(void)didBecomeActive
{
}

#pragma mark - Progress Handling

-(void)didBeginUpgrading
{
    [self showMessage:@"Upgrading..." autoDismiss:NO];
}

-(void)didBeginExtendingPremium
{
    [self showMessage:@"Saving Subscription..." autoDismiss:NO];
}

-(void)showMessage:(NSString *)message autoDismiss:(BOOL)autoDismiss
{
    [[[APP rootController] messageView] showMessage:message autoDismiss:autoDismiss];
}

-(void)didBeginLoggingIn
{
    if ([[RCPasswordManager defaultManager] accessGranted]) {
        [self showMessage:@"Connecting..." autoDismiss:NO];
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

-(void)didPayForMonth
{
    [self showMessage:@"Month Purchased" autoDismiss:YES];
    [APP trackEvent:@"Purchased Month" properties:@{}];
}

-(void)didPayForYear
{
    [self showMessage:@"Year Purchased" autoDismiss:YES];
    [APP trackEvent:@"Purchased Year " properties:@{}];
}

-(void)didLogin
{
    if (![[RCPasswordManager defaultManager] accessGranted]){
        self.shouldMerge = YES;
    }
}

-(void)didFetch:(NSNotification *)notification
{
    NSArray * passwords = notification.object;
    [self showMessage:@"Synced" autoDismiss:YES];
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
    [self showMessage:@"Saved to Cloud" autoDismiss:YES];
}

-(void)didDenyAccess
{
    [self showMessage:@"Access Denied" autoDismiss:YES];
}

@end

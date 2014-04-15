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
#import "RCInAppPurchaser.h"

#import "RCAppDelegate.h"
#import "RCRootViewController.h"
#import "RCListViewController.h"

#import "RCMessageView.h"
#import "RCTableView.h"

#import "NSIndexPath+VaultPaths.h"
#import "RCRootViewController+purchaseSegues.h"

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBeginExtendingPremium) name:networkingDidBeginExtendingPremium object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGoPremium) name:networkingDidGoPremium object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBeginLoggingIn) name:networkingDidBeginLoggingIn object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBeginSyncing) name:networkingDidBeginSyncing object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBeginFetching) name:networkingDidBeginFetching object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin) name:networkingDidLogin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFetch:) name:networkingDidFetchCredentials object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSync) name:networkingDidSync object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGrantPasswordAccess) name:passwordManagerAccessGranted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLockPhone) name:UIApplicationProtectedDataWillBecomeUnavailable object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUnlockPhone) name:UIApplicationProtectedDataDidBecomeAvailable object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedToLogin) name:networkingDidFailToLogin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPayForMonth) name:purchaserDidPayMonthly object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPayForYear) name:purchaserDidPayYearly object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBeginUpgrading) name:purchaserDidBeginUpgrading object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailUpgrading) name:purchaserDidFail object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSaveNotes) name:passwordManagerDidSaveNotes object:nil];
}

-(void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - LifeCycle handling

-(void)didLockPhone
{
    if ([[RCPasswordManager defaultManager] accessGranted])
        [[RCPasswordManager defaultManager] hideAllPasswordData];
}

-(void)didUnlockPhone
{
    if ([[RCPasswordManager defaultManager] accessGranted])
        [[RCPasswordManager defaultManager] reshowPasswordData];
}

-(void)didBecomeActive
{
    if ([[RCPasswordManager defaultManager] accessGranted]){
         [self loginWithSavedData];
    }
}

-(void)didEnterBackground
{
    if ([[RCPasswordManager defaultManager] accessGranted]){
        
    }
}

-(void)didGrantPasswordAccess
{
    if ([[RCPasswordManager defaultManager] canLogin] && ![[RCNetworking sharedNetwork] loggedIn]){
        NSString * email = [[RCPasswordManager defaultManager] accountLogin];
        NSString * password = [[RCPasswordManager defaultManager] accountPassword];
        [[RCNetworking sharedNetwork] loginWithEmail:email password:password];
        [self showMessage:@"Connecting..." autoDismiss:NO];
        self.shouldMerge = NO;
    }else{
        [[RCNetworking sharedNetwork] fetchFromServer];
    }
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

-(void)didGoPremium
{
    [[RCNetworking sharedNetwork] saveToCloud];
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
    [APP trackEvent:@"Purchased" action:@"Month"];
}

-(void)didPayForYear
{
    [self showMessage:@"Year Purchased" autoDismiss:YES];
    [APP trackEvent:@"Purchased" action:@"Year"];
}

-(void)didUpdatePasswords
{
    [[RCNetworking sharedNetwork] saveToCloud];
}

-(void)didLogin
{
    if (![[RCPasswordManager defaultManager] accessGranted]){
        self.shouldMerge = YES;
    }
    if ([[RCNetworking sharedNetwork] premiumState] == RCPremiumStateExpired){
        [self showMessage:@"Premium Expired" autoDismiss:YES];
        if ([APP shouldShowRenew] && [[APP rootController].childViewControllers containsObject:[APP rootController].listController]){
            [[APP rootController] segueToPurchaseFromList];
        }
    }
    [[RCNetworking sharedNetwork] fetchFromServer];
}

-(void)didFetch:(NSNotification *)notification
{
    NSArray * passwords = notification.object;
    [self showMessage:@"Synced" autoDismiss:YES];
    if (self.shouldMerge){
        NSInteger count = [RCPasswordManager defaultManager].passwords.count;
        [[RCPasswordManager defaultManager] addPasswords:passwords];
        self.shouldMerge = NO;
        if (count > 0){
             [[RCNetworking sharedNetwork] saveToCloud];
        }
    }else{
        [[RCPasswordManager defaultManager] replaceAllPasswordsWithPasswords:passwords];
    }
    [[[[APP rootController] listController] tableView] reloadData];
}

-(void)didSync
{
    [self showMessage:@"Saved to Cloud" autoDismiss:YES];
}

-(void)didGrantAccess
{
    if (![[RCNetworking sharedNetwork] loggedIn]){
         [self loginWithSavedData];
    }else{
        [[RCNetworking sharedNetwork] fetchFromServer];
    }
}

-(void)didLock
{
    
}

-(void)didDenyAccess
{
    [self showMessage:@"Access Denied" autoDismiss:YES];
}

-(void)loginWithSavedData
{
    self.shouldMerge = NO;
    NSString * username = [RCPasswordManager defaultManager].accountLogin;
    NSString * password = [RCPasswordManager defaultManager].accountPassword;
    if (username && password){
        [[RCNetworking sharedNetwork] loginWithEmail:username password:password];
    }
}


#pragma mark - Failure Handling

-(void)failedToLogin
{
    [self showMessage:@"Connection Failed" autoDismiss:YES];
}

-(void)didFailUpgrading
{
    [self showMessage:@"Failed To Purchase" autoDismiss:YES];
}


#pragma mark - Convenience


@end

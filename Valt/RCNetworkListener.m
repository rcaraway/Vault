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
#import "NSIndexPath+VaultPaths.h"

static RCNetworkListener * sharedQueue;

@implementation RCNetworkListener


#pragma mark - Class methods

+(BOOL)isListening
{
    return (sharedQueue != nil);
}

+(void)beginNetworking
{
    sharedQueue = [[RCNetworkListener alloc] init];
}

+(void)removeNetworking
{
    sharedQueue = nil;
}

#pragma mark - Initialization

-(id)init
{
    return super.init;
}


#pragma mark - Event Management

-(void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin) name:networkingDidLogin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFetch) name:networkingDidFetchCredentials object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSync) name:networkingDidSync object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)removeNotifications
{
    
}

-(void)didBecomeActive
{
    if ([[RCNetworking sharedNetwork] loggedIn] && [[RCPasswordManager defaultManager] accessGranted]){
        
    }
}

-(void)didLogin
{
    
}

-(void)didFetch
{
    
}

-(void)didSync
{
    
}







@end

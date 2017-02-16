//
//  RCNetworking.m
//  Valt
//
//  Created by Robert Caraway on 12/23/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCNetworking.h"
#import "RCPasswordManager.h"

#import "RCInAppPurchaser.h"
#import "RCAppDelegate.h"
#import "RCRootViewController.h"

#import "RCMessageView.h"

#import "NSString+Encryption.h"


#define PASSWORDS_KEY @"PASSWORDS_KEY"
#define EXPIRATION_KEY @"ExpirationDate"



NSString * const networkingDidBeginLoggingIn = @"networkingDidBeginLoggingIn";
NSString * const networkingDidBeginSigningUp = @"networkingDidBeginSigningUp";
NSString * const networkingDidBeginFetching = @"networkingDidBeginFetching";
NSString * const networkingDidBeginSyncing = @"networkingDidBeginSyncing";
NSString * const networkingDidBeginDecrypting = @"networkingDidBeginDecrypting";
NSString * const networkingDidBeginGettingURLForTitle = @"networkingDidBeginGettingURLForTitle";
NSString * const networkingDidBeginExtendingPremium = @"networkingDidBeginExtendingPremium";

NSString * const networkingDidSignup = @"networkingDidSignup";
NSString * const networkingDidLogin = @"networkingDidLogin";
NSString * const networkingDidFetchCredentials = @"networkingDidFetchCredentials";
NSString * const networkingDidSync = @"networkingDidSync";
NSString * const networkingDidDecrypt = @"networkingDidDecrypt";
NSString * const networkingDidGoPremium = @"networkingDidGoPremium";
NSString * const networkingDidGetURLForTitle = @"networkingDidGetURLForTitle";

NSString * const networkingDidFailToSignup = @"networkingDidFailToSignup";
NSString * const networkingDidFailToLogin = @"networkingDidFailToLogin";
NSString * const networkingDidFailToFetchCredentials = @"networkingDidFailToFetchCredentials";
NSString * const networkingDidFailToSync = @"networkingDidFailToSync";
NSString * const networkingDidFailToGoPremium = @"networkingDidFailToGoPremium";
NSString * const networkingDidDenyFetch = @"networkingDidDenyFetch";
NSString * const networkingDidDenySync = @"networkingDidDenySync";
NSString * const networkingDidFailToGetURL = @"networkingDidFailToGetURL";


@interface RCNetworking ()


@end

static RCNetworking *sharedNetwork;

@implementation RCNetworking
{
    NSDate * beginDate;
}

#pragma mark - Class Methods

+(void)initialize
{
    sharedNetwork = [[RCNetworking alloc] init];
    if ([sharedNetwork loggedIn]){
    }
}

+(RCNetworking *)sharedNetwork
{
    return sharedNetwork;
}


#pragma mark - Main Methods

-(void)signupWithEmail:(NSString *)email password:(NSString *)password
{
    
}


-(void)loginWithEmail:(NSString *)email password:(NSString *)password
{
}

-(void)fetchFromServer
{
}

-(void)saveToCloud
{
}

-(void)extendPremiumToDate:(NSDate *)date
{
}

-(void)getUrlForTitle:(NSString *)title
{
    [[NSNotificationCenter defaultCenter] postNotificationName:networkingDidBeginGettingURLForTitle object:nil];
}

-(RCPremiumState)premiumState
{
    return RCPremiumStateCurrent;
}

#pragma mark - Convenience

-(void)pfObjectsToRCPasswords:(NSArray*)pfObjects completion:(void (^)(NSArray * passwords))completion
{
}

-(BOOL)objectIsSecureNotes:(PFObject *)object
{
    return NO;
}

-(void)RCPasswordsToPFObjects:(NSArray *)rcPasswords completion:(void (^)(NSArray * objects))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableArray * array = [NSMutableArray new];
        for (RCPassword *password in rcPasswords) {
            if ([[RCPasswordManager defaultManager] accessGranted]){
                PFObject * object = [password convertedObject];
                if (object){
                     [array addObject:object];
                }
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil);
                });
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(array);
        });
    });
}

-(BOOL)loggedIn
{
    return NO;
}

-(void)logOut
{
    
}

-(void)postErrorWithNotification:(NSString * )notification error:(NSError *)error object:(id)obj
{
    NSString * message =error.userInfo[@"error"];
    [[NSNotificationCenter defaultCenter] postNotificationName:notification object:obj];
    NSLog(@"Failure Message %@", message);
    if ([message rangeOfString:@"timeout"].location != NSNotFound){
        [[[APP rootController] messageView] showMessage:@"Request timed out" autoDismiss:YES];
    }
}


@end

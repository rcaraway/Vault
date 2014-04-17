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

#import <Parse/Parse.h>

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

@property(nonatomic, strong) PFQuery * fetchQuery;

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
        [PFUser logOut];
    }
}

+(RCNetworking *)sharedNetwork
{
    return sharedNetwork;
}


#pragma mark - Main Methods

-(void)signupWithEmail:(NSString *)email password:(NSString *)password
{
    if ([password isEqualToString:[[RCPasswordManager defaultManager] masterPassword]]){
        if (email.length >= 5 && password.length >=1){
            PFUser * user = [PFUser user];
            [user setEmail:email];
            [user setPassword:password];
            [user setUsername:email];
            [[NSNotificationCenter defaultCenter] postNotificationName:networkingDidBeginSigningUp object:nil];
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error){
                    [user setACL:[self defaultACLForUser:user]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:networkingDidSignup object:password];
                }else{
                    [self postErrorWithNotification:networkingDidFailToSignup error:error object:error.userInfo[@"error"]];
                }
            }];
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:networkingDidFailToSignup object:@"Fill out fields"];
        }
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:networkingDidFailToSignup object:@"Incorrect Password"];
    }
}

-(PFACL *)defaultACLForUser:(PFUser *)user
{
    PFACL * secure = [PFACL ACLWithUser:user];
    [secure setReadAccess:YES forUser:user];
    [secure setWriteAccess:YES forUser:user];
    [PFACL setDefaultACL:secure withAccessForCurrentUser:YES];
    return secure;
}

-(void)loginWithEmail:(NSString *)email password:(NSString *)password
{
    if (email.length >= 5 && password.length >=1){
        [[NSNotificationCenter defaultCenter] postNotificationName:networkingDidBeginLoggingIn object:nil];
        [PFUser logInWithUsernameInBackground:email password:password block:^(PFUser *user, NSError *error) {
            if (!error){
                [[NSNotificationCenter defaultCenter] postNotificationName:networkingDidLogin object:password];
            }else{
                [self postErrorWithNotification:networkingDidFailToLogin error:error object:error.userInfo[@"error"]];
            }
        }];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:networkingDidFailToLogin object:@"Fill out fields"];
    }
}

-(void)fetchFromServer
{
    if ([self premiumState] == RCPremiumStateCurrent && [[RCPasswordManager defaultManager] accessGranted]){
        PFQuery * query = [PFQuery queryWithClassName:PASSWORD_CLASS];
        [query whereKey:PASSWORD_OWNER equalTo:[PFUser currentUser].username];
        query.limit = 100000;
        [query orderByAscending:PASSWORD_INDEX];
        self.fetchQuery = query;
        [[NSNotificationCenter defaultCenter] postNotificationName:networkingDidBeginFetching object:nil];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            self.fetchQuery = nil;
            if (!error){
               [self pfObjectsToRCPasswords:objects completion:^(NSArray *passwords) {
                   if (passwords){
                       [[NSNotificationCenter defaultCenter] postNotificationName:networkingDidFetchCredentials object:passwords];
                   }else{
                       [[[APP rootController] messageView] showMessage:@"Sync Cancelled" autoDismiss:YES];
                   }
                }];
            }else{
                [self postErrorWithNotification:networkingDidFailToFetchCredentials error:error object:nil];
            }
        }];
    }else if ([self premiumState] == RCPremiumStateNone || [self premiumState] == RCPremiumStateExpired){
        [[NSNotificationCenter defaultCenter] postNotificationName:networkingDidDenyFetch object:nil];
    }
}

-(void)saveToCloud
{
    if ([self premiumState] == RCPremiumStateCurrent && [[RCPasswordManager defaultManager] accessGranted]){
        [[NSNotificationCenter defaultCenter] postNotificationName:networkingDidBeginSyncing object:nil];
        [self RCPasswordsToPFObjects:[[RCPasswordManager defaultManager] passwords] completion:^(NSArray *objects) {
            if (objects != nil && [self loggedIn]){
                NSMutableArray * mutable = [objects mutableCopy];
                if ([[RCPasswordManager defaultManager] secureNotes].length > 0){
                    PFObject * notes = [[RCPasswordManager defaultManager] passwordFromSecureNotes];
                    [mutable addObject:notes];
                }
                [[PFUser currentUser] setObject:mutable forKey:PASSWORDS_KEY];
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error){
                        [[NSNotificationCenter defaultCenter] postNotificationName:networkingDidSync object:nil];
                    }else{
                        [self postErrorWithNotification:networkingDidFailToSync error:error object:nil];
                    }
                }];
            }else{
                [[[APP rootController] messageView] showMessage:@"Saving Cancelled" autoDismiss:YES];
            }
        }];
    }else if ([self premiumState] == RCPremiumStateNone || [self premiumState] == RCPremiumStateExpired)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:networkingDidDenySync object:nil];
    }
}

-(void)extendPremiumToDate:(NSDate *)date
{
    if ([self loggedIn]){
        [[NSNotificationCenter defaultCenter] postNotificationName:networkingDidBeginExtendingPremium object:nil];
        [[PFUser currentUser] setObject:date forKey:EXPIRATION_KEY];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error){
                [[RCInAppPurchaser sharePurchaser] clearLocalDateCache];
                [[NSNotificationCenter defaultCenter] postNotificationName:networkingDidGoPremium object:nil];
            }else{
                [self postErrorWithNotification:networkingDidFailToGoPremium error:error object:nil];
            }
        }];
    }
}

-(void)getUrlForTitle:(NSString *)title
{
    [[NSNotificationCenter defaultCenter] postNotificationName:networkingDidBeginGettingURLForTitle object:nil];
    [PFCloud callFunctionInBackground:@"getURL" withParameters:@{@"URLTitle": title} block:^(id object, NSError *error) {
        if (!error){
            [[NSNotificationCenter defaultCenter] postNotificationName:networkingDidGetURLForTitle object:nil];
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:networkingDidFailToGetURL object:nil];
        }
    }];
}

-(RCPremiumState)premiumState
{
#ifdef RENEW_MODE
    if ([[RCPasswordManager defaultManager] canLogin]){
        return RCPremiumStateExpired;
    }
    return RCPremiumStateNone;
#endif
#ifdef TESTING_MODE
    return RCPremiumStateCurrent;
#else
    if ([self loggedIn]){
        if (!beginDate){
            beginDate = [NSDate date];
        }
        NSDate * date = [[PFUser currentUser]objectForKey:EXPIRATION_KEY];
        if (date){
            if ([date compare:beginDate] == NSOrderedAscending){
                return RCPremiumStateExpired;
            }else{
                return RCPremiumStateCurrent;
            }
        }else{
            return RCPremiumStateExpired;
        }
    }
    return RCPremiumStateNone;
#endif
}

#pragma mark - Convenience

-(void)pfObjectsToRCPasswords:(NSArray*)pfObjects completion:(void (^)(NSArray * passwords))completion
{
    [[NSNotificationCenter defaultCenter] postNotificationName:networkingDidBeginDecrypting object:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableArray * array = [NSMutableArray new];
        for (PFObject * object in pfObjects) {
            if ([[RCPasswordManager defaultManager] accessGranted]){
                if ([self objectIsSecureNotes:object]){
                    RCPassword * password = [RCPassword passwordFromPFObject:object];
                    if (password){
                        NSString * notes = password.notes;
                        [[RCPasswordManager defaultManager] saveSecureNotes:notes];
                    }
                }else{
                    RCPassword * password = [RCPassword passwordFromPFObject:object];
                    if (password){
                        if (![array containsObject:password]){
                            [array addObject:password];
                        }
                    }
                    else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(nil);
                        });
                    }
                }
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil);
                });
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:networkingDidDecrypt object:nil];
            completion(array);
        });
    });
}

-(BOOL)objectIsSecureNotes:(PFObject *)object
{
    NSInteger index = [[object objectForKey:PASSWORD_INDEX] integerValue];
    if (index == -1){
        return YES;
    }
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
    return [PFUser currentUser] != nil;
}

-(void)logOut
{
    if ([PFUser currentUser]){
        [PFUser logOut];
        if (self.fetchQuery){
            [self.fetchQuery cancel];
        }
    }
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

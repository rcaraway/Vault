//
//  RCNetworking.m
//  Valt
//
//  Created by Robert Caraway on 12/23/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCNetworking.h"
#import <Parse/Parse.h>
#import "RCPasswordManager.h"
#import "NSString+Encryption.h"

#define PASSWORDS_KEY @"PASSWORDS_KEY"


NSString * const networkingDidSignup = @"networkingDidSignup";
NSString * const networkingDidLogin = @"networkingDidLogin";
NSString * const networkingDidFetchCredentials = @"networkingDidFetchCredentials";
NSString * const networkingDidSync = @"networkingDidSync";
NSString * const networkingDidMergeCredentials = @"networkingDidMergeCredentials";

NSString * const networkingDidFailMergeCredentials = @"networkingDidFailMergeCredentials";
NSString * const networkingDidFailToSignup = @"networkingDidFailToSignup";
NSString * const networkingDidFailToLogin = @"networkingDidFailToLogin";
NSString * const networkingDidFailToFetchCredentials = @"networkingDidFailToFetchCredentials";
NSString * const networkingDidFailToSync = @"networkingDidFailToSync";

static RCNetworking *sharedNetwork;

@implementation RCNetworking


#pragma mark - Class Methods

+(void)initialize
{
    sharedNetwork = [[RCNetworking alloc] init];
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
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error){
                    [user setACL:[self defaultACLForUser:user]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:networkingDidSignup object:nil];
                }else{
                    [[NSNotificationCenter defaultCenter] postNotificationName:networkingDidFailToSignup object:error.userInfo[@"error"]];
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
        [PFUser logInWithUsernameInBackground:email password:password block:^(PFUser *user, NSError *error) {
            if (!error){
                [[NSNotificationCenter defaultCenter] postNotificationName:networkingDidLogin object:nil];
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:networkingDidFailToLogin object:error.userInfo[@"error"]];
            }
        }];
    }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:networkingDidFailToLogin object:@"Fill out fields"];
    }
}

-(void)fetchFromServer
{
    PFQuery * query = [PFQuery queryWithClassName:PASSWORD_CLASS];
    [query whereKey:PASSWORD_OWNER equalTo:[PFUser currentUser].objectId];
    query.limit = 100000;
    [query orderByAscending:PASSWORD_INDEX];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error){
            [self pfObjectsToRCPasswords:objects completion:^(NSArray *passwords) {
                [[NSNotificationCenter defaultCenter] postNotificationName:networkingDidFetchCredentials object:passwords];
            }];
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:networkingDidFailToFetchCredentials object:nil];
        }
    }];
}

-(void)sync
{
    [self RCPasswordsToPFObjects:[[RCPasswordManager defaultManager] passwords] completion:^(NSArray *objects) {
        [PFObject saveAllInBackground:objects block:^(BOOL succeeded, NSError *error) {
            if (!error){
                [[NSNotificationCenter defaultCenter] postNotificationName:networkingDidSync object:nil];
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:networkingDidFailToSync object:nil];
            }
        }];
    }];
}

-(void)pfObjectsToRCPasswords:(NSArray*)pfObjects completion:(void (^)(NSArray * passwords))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableArray * array = [NSMutableArray new];
        for (PFObject * object in pfObjects) {
            RCPassword * password = [RCPassword passwordFromPFObject:object];
            [password decrypt];
            [array addObject:password];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(array);
        });
    });
}

-(void)RCPasswordsToPFObjects:(NSArray *)rcPasswords completion:(void (^)(NSArray * objects))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableArray * array = [NSMutableArray new];
        for (RCPassword *password in rcPasswords) {
            [password encrypt];
            PFObject * object =[password convertedObject];
            [array addObject:object];
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


@end

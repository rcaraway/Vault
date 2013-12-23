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
#import "RCCryptography.h"

#define PASSWORDS_KEY @"PASSWORDS_KEY"

NSString * const networkingDidSignup = @"networkingDidSignup";
NSString * const networkingDidLogin = @"networkingDidLogin";
NSString * const networkingDidFetchCredentials = @"networkingDidFetchCredentials";
NSString * const networkingDidSync = @"networkingDidSync";

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

-(void)signup
{
    NSString * email = [[RCPasswordManager defaultManager] accountEmail];
    NSString * masterPassword = [[RCPasswordManager defaultManager] masterPassword];
    if (email && masterPassword){
        PFUser * user = [PFUser user];
        [user setEmail:email];
        [user setPassword:masterPassword];
        [user setUsername:email];
        PFACL * secure = [PFACL ACLWithUser:user];
        [secure setReadAccess:YES forUser:user];
        [secure setWriteAccess:YES forUser:user];
        [user setACL:secure];
        [PFACL setDefaultACL:secure withAccessForCurrentUser:YES];
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error){
                [[NSNotificationCenter defaultCenter] postNotificationName:networkingDidSignup object:nil];
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:networkingDidFailToSignup object:nil];
            }
        }];
    }
}

-(void)login
{
    NSString * email = [[RCPasswordManager defaultManager] accountEmail];
    NSString * masterPassword = [[RCPasswordManager defaultManager] masterPassword];
    if (email && masterPassword){
        [PFUser logInWithUsernameInBackground:email password:masterPassword block:^(PFUser *user, NSError *error) {
            if (!error){
                [[NSNotificationCenter defaultCenter] postNotificationName:networkingDidLogin object:nil];
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:networkingDidFailToLogin object:nil];
            }
        }];
    }
}

-(void)fetchFromServer
{
    
}

-(void)sync
{
    
}

-(void)pfObjectsToRCPasswords:(NSArray*)pfObjects completion:(void (^)(NSArray * passwords))completion
{
    
}

-(void)RCPasswordsToPFObjects:(NSArray *)rcPasswords completion:(void (^)(NSArray * objects))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableArray * array = [NSMutableArray new];
        for (RCPassword *password in rcPasswords) {
            
        }
        
    });
}

-(BOOL)loggedIn
{
    return [PFUser currentUser] != nil;
}


@end

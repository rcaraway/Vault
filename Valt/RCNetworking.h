//
//  RCNetworking.h
//  Valt
//
//  Created by Robert Caraway on 12/23/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PFACL;
@class PFUser;

@interface RCNetworking : NSObject

@property(nonatomic) BOOL shouldMerge; //merge happens when a user has existing data locally, then logs in and fetches his cloud data

-(void)signupWithEmail:(NSString *)email password:(NSString *)password;
-(void)loginWithEmail:(NSString *)email password:(NSString *)password;

-(void)fetchFromServer;
-(void)sync;
-(BOOL)loggedIn;

-(PFACL *)defaultACLForUser:(PFUser *)user;
+(RCNetworking *)sharedNetwork;



@end

extern NSString * const networkingDidSignup;
extern NSString * const networkingDidLogin;
extern NSString * const networkingDidFetchCredentials;
extern NSString * const networkingDidMergeCredentials;
extern NSString * const networkingDidSync;

extern NSString * const networkingDidFailToSignup;
extern NSString * const networkingDidFailToLogin;
extern NSString * const networkingDidFailToFetchCredentials;
extern NSString * const networkingDidFailMergeCredentials;
extern NSString * const networkingDidFailToSync;

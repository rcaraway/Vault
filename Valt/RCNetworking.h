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

typedef enum {
      RCPremiumStateNone,
    RCPremiumStateCurrent,
    RCPremiumStateExpired
} RCPremiumState;

@interface RCNetworking : NSObject

@property (nonatomic,readonly) RCPremiumState premiumState;

-(void)signupWithEmail:(NSString *)email password:(NSString *)password;
-(void)loginWithEmail:(NSString *)email password:(NSString *)password;

-(void)extendPremiumToDate:(NSDate *)date;
-(void)fetchFromServer;
-(void)saveToCloud;
-(void)getUrlForTitle:(NSString *)title;

-(BOOL)loggedIn;
-(void)logOut;
-(PFACL *)defaultACLForUser:(PFUser *)user;

+(RCNetworking *)sharedNetwork;



@end


extern NSString * const networkingDidBeginLoggingIn;
extern NSString * const networkingDidBeginSigningUp;
extern NSString * const networkingDidBeginFetching;
extern NSString * const networkingDidBeginDecrypting;
extern NSString * const networkingDidBeginSyncing;
extern NSString * const networkingDidBeginGettingURLForTitle;
extern NSString * const networkingDidBeginExtendingPremium;

extern NSString * const networkingDidGoPremium;
extern NSString * const networkingDidSignup;
extern NSString * const networkingDidLogin;
extern NSString * const networkingDidFetchCredentials;
extern NSString * const networkingDidSync;
extern NSString * const networkingDidDecrypt;
extern NSString * const networkingDidGetURLForTitle;

extern NSString * const networkingDidFailToGoPremium;
extern NSString * const networkingDidFailToSignup;
extern NSString * const networkingDidFailToLogin;
extern NSString * const networkingDidFailToFetchCredentials;
extern NSString * const networkingDidFailToSync;
extern NSString * const networkingDidFailToGetURL;

extern NSString * const networkingDidDenyFetch;
extern NSString * const networkingDidDenySync;
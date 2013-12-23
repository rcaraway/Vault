//
//  RCNetworking.h
//  Valt
//
//  Created by Robert Caraway on 12/23/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCNetworking : NSObject

-(void)signup;
-(void)login;

-(void)fetchFromServer;
-(void)sync;
-(BOOL)loggedIn;

+(RCNetworking *)sharedNetwork;



@end

extern NSString * const networkingDidSignup;
extern NSString * const networkingDidLogin;
extern NSString * const networkingDidFetchCredentials;
extern NSString * const networkingDidSync;

extern NSString * const networkingDidFailToSignup;
extern NSString * const networkingDidFailToLogin;
extern NSString * const networkingDidFailToFetchCredentials;
extern NSString * const networkingDidFailToSync;

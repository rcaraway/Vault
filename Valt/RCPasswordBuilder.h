//
//  RCPasswordBuilder.h
//  Valt
//
//  Created by Rob Caraway on 12/10/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RCPassword;

@interface RCPasswordBuilder : NSObject

+(void)createBlank;
+(void)setTitle:(NSString *)title;
+(void)setUsername:(NSString *)username;
+(void)setPassword:(NSString *)password;
+(void)addExtraField:(NSString *)options;
+(RCPassword *)build; //returns nil of 'createblank' not called


@end

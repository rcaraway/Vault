//
//  RCPassword.h
//  Valt
//
//  Created by Rob Caraway on 12/10/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AutoCoding.h"

#define PASSWORD_CLASS @"RCPassword"
#define PASSWORD_OWNER @"PASSWORD_OWNER"
#define PASSWORD_TITLE @"PASSWORD_TITLE"
#define PASSWORD_INDEX @"PASSWORD_INDEX"
#define PASSWORD_USERNAME @"PASSWORD_USERNAME"
#define PASSWORD_URLNAME @"PASSWORD_URLNAME"
#define PASSWORD_PASSWORD @"PASSWORD_PASSWORD"
#define PASSWORD_EXTRA_FRIELD @"PASSWORD_EXTRA_FRIELD"

@interface RCPassword : NSObject <NSCopying, NSCoding>

@property(nonatomic, copy) NSString * title;
@property(nonatomic, copy) NSString * username;
@property(nonatomic, copy) NSString * password;
@property(nonatomic, strong) NSString * urlName;
@property(nonatomic, strong) NSString * notes;

@property(nonatomic, strong) UIColor * webColor;

-(BOOL)isEmpty;
-(void)encrypt;
-(void)decrypt;
-(NSArray *)allFields;
-(BOOL)hasValidURL;

@end


extern NSString * const passwordDidGrabWebColor;

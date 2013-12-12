//
//  RCPasswordBuilder.m
//  Valt
//
//  Created by Rob Caraway on 12/10/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCPasswordBuilder.h"
#import "RCPassword.h"

static RCPasswordBuilder * builder;

@interface RCPasswordBuilder()

@property(nonatomic, strong) RCPassword * password;

@end

@implementation RCPasswordBuilder


-(id)init
{
    self = super.init;
    if (self){
        self.password = [[RCPassword  alloc] init];
    }
    return self;
}

+(void)createBlank
{
    builder = [[RCPasswordBuilder  alloc] init];
}

+(void)setTitle:(NSString *)title
{
    builder.password.title = title;
}

+(void)setUsername:(NSString *)username
{
    builder.password.username = username;
}

+(void)setPassword:(NSString *)password
{
    builder.password.password = password;
}

+(void)addExtraField:(NSString *)options
{
    NSArray * extraFields = builder.password.extraFields;
    NSMutableArray * mutableFields;
    if (extraFields)
        mutableFields = [NSMutableArray arrayWithArray:extraFields];
    else{
        mutableFields = [NSMutableArray new];
    }
    [mutableFields addObject:options];
    builder.password.extraFields = [NSArray arrayWithArray:mutableFields];
}

+(RCPassword *)build
{
    RCPassword * password = [builder.password copy];
    builder.password = nil;
    return password;
}

@end

//
//  RCPasswordManager.m
//  Valt
//
//  Created by Rob Caraway on 12/10/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#define MASTER_PASSWORD_KEY @"kMasterPasswordKey"

#import "RCPasswordManager.h"

static RCPasswordManager * manager;

@implementation RCPasswordManager

+(void)initialize
{
    manager = [[RCPasswordManager  alloc] init];
}

+(RCPasswordManager *)defaultManager
{
    return manager;
}

-(void)setMasterPassword:(NSString *)masterPassword
{
    [[PDKeychainBindings sharedKeychainBindings] setString:masterPassword forKey:MASTER_PASSWORD_KEY];
}

-(NSString *)masterPassword
{
    return [[PDKeychainBindings sharedKeychainBindings] stringForKey:MASTER_PASSWORD_KEY];
}

-(BOOL)masterPasswordExists
{
    return [[PDKeychainBindings sharedKeychainBindings] stringForKey:MASTER_PASSWORD_KEY] && [[PDKeychainBindings sharedKeychainBindings] stringForKey:MASTER_PASSWORD_KEY].length > 0;
}

-(NSArray *)dataForTitle:(NSString *)title
{
    return @[];
}

@end

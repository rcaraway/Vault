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

@implementation RCPasswordManager{
    NSMutableArray * mutablePasswords;
}

+(void)initialize
{
    manager = [[RCPasswordManager  alloc] init];
}

+(RCPasswordManager *)defaultManager
{
    return manager;
}

-(id)init
{
    self = super.init;
    if (self){
        mutablePasswords = [NSMutableArray new];
    }
    return self;
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

-(void)addPassword:(RCPassword *)password
{
    [mutablePasswords addObject:password];
}

-(void)removePassword:(RCPassword *)password
{
    [mutablePasswords removeObject:password];
}

-(void)removePasswordAtIndex:(NSInteger)index
{
    [mutablePasswords removeObjectAtIndex:index];
}

-(void)addPassword:(RCPassword *)password atIndex:(NSInteger)index
{
    [mutablePasswords insertObject:password atIndex:index];
}

-(void)movePasswordAtIndex:(NSInteger)passwordIndex toNewIndex:(NSInteger)newIndex
{
    RCPassword * password = [mutablePasswords objectAtIndex:passwordIndex];
    [mutablePasswords removeObjectAtIndex:passwordIndex];
    [mutablePasswords insertObject:password atIndex:newIndex];
}

-(NSArray *)allTitles
{
    NSMutableArray * titles = [NSMutableArray new];
    for (RCPassword * password in self.passwords) {
        [titles addObject:password.title];
    }
    return titles;
}


@end

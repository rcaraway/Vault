//
//  RCPasswordManager.m
//  Valt
//
//  Created by Rob Caraway on 12/10/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#define MASTER_PASSWORD_KEY @"kMasterPasswordKey"

#import "RCPasswordManager.h"
#import "PDKeychainBindings.h"
#import <objc/runtime.h>

#define STORED_TITLE_COUNT @"STORED_TITLE_COUNT"
#define STORED_TITLE_PREFIX @"STORED_TITLE_"
#define STORED_PASSWORD_PREFIX @"STORED_PASSWORD_"
#define STORED_EMAIL_PREFIX @"STORE_EMAIL_"
#define STORED_URL_PREFIX @"STORED_URL_"
#define STORED_NOTES1_PREFIX @"STORED_NOTES1_"
#define STORED_NOTES2_PREFIX @"STORED_NOTES2_"


static RCPasswordManager * manager;

@implementation RCPasswordManager
{
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
        [self grantAccessToPasswords];
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

-(BOOL)anyLoginsExist
{
    return ![[[PDKeychainBindings sharedKeychainBindings] stringForKey:STORED_TITLE_COUNT] isEqualToString:@""] && [[[PDKeychainBindings sharedKeychainBindings] stringForKey:STORED_TITLE_COUNT] integerValue] > 0;
}

-(BOOL)masterPasswordExists
{
    return [[PDKeychainBindings sharedKeychainBindings] stringForKey:MASTER_PASSWORD_KEY] && [[PDKeychainBindings sharedKeychainBindings] stringForKey:MASTER_PASSWORD_KEY].length > 0;
}

-(void)addPassword:(RCPassword *)password
{
    [mutablePasswords addObject:password];
    [self commitPasswordToKeyChain:password];
    [self commitTotalToKeychain];
}

-(void)removePassword:(RCPassword *)password
{
    [mutablePasswords removeObject:password];
    [self deletePasswordFromKeychain:password];
    [self commitTotalToKeychain];
}

-(void)removePasswordAtIndex:(NSInteger)index
{
    if (mutablePasswords.count > index){
        RCPassword * password = mutablePasswords[index];
        [mutablePasswords removeObjectAtIndex:index];
        [self deletePasswordFromKeychain:password];
        [self commitTotalToKeychain];
    }
}

-(void)addPassword:(RCPassword *)password atIndex:(NSInteger)index
{
    [mutablePasswords insertObject:password atIndex:index];
    [self commitAllPasswordsToKeyChain];
    [self commitTotalToKeychain];
}

-(void)movePasswordAtIndex:(NSInteger)passwordIndex toNewIndex:(NSInteger)newIndex
{
    if (passwordIndex != newIndex && newIndex < mutablePasswords.count){
        RCPassword * password = [mutablePasswords objectAtIndex:passwordIndex];
        [mutablePasswords removeObjectAtIndex:passwordIndex];
        [mutablePasswords insertObject:password atIndex:newIndex];
    }
}

-(void)saveAllToKeychain
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
           [self commitAllPasswordsToKeyChain];
    });
}

-(NSArray *)passwords
{
    return [NSArray arrayWithArray:mutablePasswords];
}

-(NSArray *)allTitles
{
    NSMutableArray * titles = [NSMutableArray new];
    for (RCPassword * password in self.passwords) {
        [titles addObject:password.title];
    }
    return titles;
}

-(void)lockPasswords
{
    [self commitAllPasswordsToKeyChain];
    [mutablePasswords removeAllObjects];
}

-(void)grantAccessToPasswords
{
    if ([self anyLoginsExist]){
        [self constructPasswordsFromKeychain];
    }else
        mutablePasswords = [NSMutableArray new];
}

-(RCPassword *)passwordForTitle:(NSString *)title
{
    for (RCPassword * singlePass in mutablePasswords) {
        if ([singlePass.title isEqualToString:title]){
            return singlePass;
        }
    }
    return nil;
}

#pragma mark - Keychain

-(void)constructPasswordsFromKeychain
{
    NSInteger count = [[[PDKeychainBindings sharedKeychainBindings] stringForKey:STORED_TITLE_COUNT] integerValue];
    NSMutableArray * passwords = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++) {
        RCPassword * rcPassword = [[RCPassword alloc] init];
        NSString * titleIndex = [NSString stringWithFormat:@"%@%d", STORED_TITLE_PREFIX, i];
        NSString * nameIndex = [NSString stringWithFormat:@"%@%d", STORED_EMAIL_PREFIX, i];
        NSString * passwordIndex = [NSString stringWithFormat:@"%@%d", STORED_PASSWORD_PREFIX, i];
        NSString * urlIndex = [NSString stringWithFormat:@"%@%d", STORED_URL_PREFIX, i];
        NSString * notes1Index = [NSString stringWithFormat:@"%@%d", STORED_NOTES1_PREFIX, i];
        NSString * notes2Index= [NSString stringWithFormat:@"%@%d", STORED_NOTES2_PREFIX, i];
        rcPassword.title = [[PDKeychainBindings sharedKeychainBindings] stringForKey:titleIndex];
        rcPassword.username = [[PDKeychainBindings sharedKeychainBindings] stringForKey:nameIndex];
        rcPassword.urlName = [[PDKeychainBindings sharedKeychainBindings] stringForKey:urlIndex];
        rcPassword.password = [[PDKeychainBindings sharedKeychainBindings] stringForKey:passwordIndex];
        NSString * notes1 = [[PDKeychainBindings sharedKeychainBindings] stringForKey:notes1Index];
        NSString * notes2 = [[PDKeychainBindings sharedKeychainBindings] stringForKey:notes2Index];
        if (notes1)[rcPassword.extraFields addObject:notes1];
        if (notes2)[rcPassword.extraFields addObject:notes2];
        NSLog(@"INDEX %d TITLE %@, NAME %@, PASSWORD %@, URL %@", i, rcPassword.title, rcPassword.username, rcPassword.password, rcPassword.urlName);
        [passwords addObject:rcPassword];
    }
    mutablePasswords = passwords;
}

-(void)commitAllPasswordsToKeyChain
{
    for (RCPassword * password in mutablePasswords) {
        NSInteger index = [mutablePasswords indexOfObject:password];
        NSString * titleIndex = [NSString stringWithFormat:@"%@%d", STORED_TITLE_PREFIX, index];
        NSString * nameIndex = [NSString stringWithFormat:@"%@%d", STORED_EMAIL_PREFIX, index];
        NSString * passwordIndex = [NSString stringWithFormat:@"%@%d", STORED_PASSWORD_PREFIX, index];
        NSString * urlIndex = [NSString stringWithFormat:@"%@%d", STORED_URL_PREFIX, index];
        NSString * notes1Index = [NSString stringWithFormat:@"%@%d", STORED_NOTES1_PREFIX, index];
        NSString * notes2Index= [NSString stringWithFormat:@"%@%d", STORED_NOTES2_PREFIX, index];
        NSLog(@"INDEX %d TITLE %@, NAME %@, PASSWORD %@, URL %@", index, password.title, password.username, password.password, password.urlName);
        [[PDKeychainBindings sharedKeychainBindings] setString:password.title forKey:titleIndex];
        [[PDKeychainBindings sharedKeychainBindings] setString:password.username forKey:nameIndex];
        [[PDKeychainBindings sharedKeychainBindings] setString:password.password forKey:passwordIndex];
        [[PDKeychainBindings sharedKeychainBindings] setString:password.urlName forKey:urlIndex];
        if (password.extraFields.count > 0){
            [[PDKeychainBindings sharedKeychainBindings] setString:password.extraFields[0] forKey:notes1Index];
        }
        if (password.extraFields.count > 1){
            [[PDKeychainBindings sharedKeychainBindings] setString:password.extraFields[1] forKey:notes2Index];
        }
    }
}

-(void)commitPasswordToKeyChain:(RCPassword *)password
{
    NSInteger index = [mutablePasswords indexOfObject:password];
    NSString * titleIndex = [NSString stringWithFormat:@"%@%d", STORED_TITLE_PREFIX, index];
    NSString * nameIndex = [NSString stringWithFormat:@"%@%d", STORED_EMAIL_PREFIX, index];
    NSString * passwordIndex = [NSString stringWithFormat:@"%@%d", STORED_PASSWORD_PREFIX, index];
    NSString * urlIndex = [NSString stringWithFormat:@"%@%d", STORED_URL_PREFIX, index];
    NSString * notes1Index = [NSString stringWithFormat:@"%@%d", STORED_NOTES1_PREFIX, index];
    NSString * notes2Index= [NSString stringWithFormat:@"%@%d", STORED_NOTES2_PREFIX, index];
    [[PDKeychainBindings sharedKeychainBindings] setString:password.title forKey:titleIndex];
    [[PDKeychainBindings sharedKeychainBindings] setString:password.username forKey:nameIndex];
    [[PDKeychainBindings sharedKeychainBindings] setString:password.password forKey:passwordIndex];
    [[PDKeychainBindings sharedKeychainBindings] setString:password.urlName forKey:urlIndex];
    if (password.extraFields.count > 0){
        [[PDKeychainBindings sharedKeychainBindings] setString:password.extraFields[0] forKey:notes1Index];
    }
    if (password.extraFields.count > 1){
        [[PDKeychainBindings sharedKeychainBindings] setString:password.extraFields[1] forKey:notes2Index];
    }
}

-(void)deletePasswordFromKeychain:(RCPassword *)password
{
    NSInteger index = [mutablePasswords indexOfObject:password];
    NSString * titleIndex = [NSString stringWithFormat:@"%@%d", STORED_TITLE_PREFIX, index];
    NSString * nameIndex = [NSString stringWithFormat:@"%@%d", STORED_EMAIL_PREFIX, index];
    NSString * passwordIndex = [NSString stringWithFormat:@"%@%d", STORED_PASSWORD_PREFIX, index];
    NSString * urlIndex = [NSString stringWithFormat:@"%@%d", STORED_URL_PREFIX, index];
    NSString * notes1Index = [NSString stringWithFormat:@"%@%d", STORED_NOTES1_PREFIX, index];
    NSString * notes2Index= [NSString stringWithFormat:@"%@%d", STORED_NOTES2_PREFIX, index];
    [[PDKeychainBindings sharedKeychainBindings] setString:@"" forKey:titleIndex];
    [[PDKeychainBindings sharedKeychainBindings] setString:@"" forKey:nameIndex];
    [[PDKeychainBindings sharedKeychainBindings] setString:@"" forKey:passwordIndex];
    [[PDKeychainBindings sharedKeychainBindings] setString:@"" forKey:urlIndex];
    [[PDKeychainBindings sharedKeychainBindings] setString:@"" forKey:notes1Index];
    [[PDKeychainBindings sharedKeychainBindings] setString:@"" forKey:notes2Index];
}

-(void)commitTotalToKeychain
{
    NSString * totalString = [NSString stringWithFormat:@"%d", mutablePasswords.count];
    [[PDKeychainBindings sharedKeychainBindings] setString:totalString forKey:STORED_TITLE_COUNT];
}

@end

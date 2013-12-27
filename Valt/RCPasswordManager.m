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
#import "NSString+Encryption.h"

#define MASTER_PASSWORD_ACCESS @"AbVxHzKQHdLmBsVVJb6yk3Pq" //WARNING: DO NOT CHANGE EVER

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
    NSString * randomKey;
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
    }
    return self;
}

-(void)setMasterPassword:(NSString *)masterPassword
{
    NSString * encrypted = [masterPassword stringByEncryptingWithKey:MASTER_PASSWORD_ACCESS];
    [[PDKeychainBindings sharedKeychainBindings] setString:encrypted forKey:MASTER_PASSWORD_KEY];
}

-(NSString *)masterPassword
{
#ifdef TESTING_MODE
    if (!randomKey){
        randomKey = [NSString randomString];
    }
    return randomKey;
#else
    NSString * decryptedPassword = [[[PDKeychainBindings sharedKeychainBindings] stringForKey:MASTER_PASSWORD_KEY] stringByDecryptingWithKey:MASTER_PASSWORD_ACCESS];
    return [[PDKeychainBindings sharedKeychainBindings] stringForKey:MASTER_PASSWORD_KEY];
#endif
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self commitPasswordToKeyChain:password];
        [self commitTotalToKeychain];
    });
}

-(void)addPasswords:(NSArray *)passwords
{
    [mutablePasswords addObjectsFromArray:passwords];
}

-(void)replaceAllPasswordsWithPasswords:(NSArray *)passwords
{
    [mutablePasswords removeAllObjects];
    [mutablePasswords addObjectsFromArray:passwords];
}

-(void)removePassword:(RCPassword *)password
{
    [mutablePasswords removeObject:password];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self deletePasswordFromKeychain:password];
        [self commitTotalToKeychain];
    });
}

-(void)removePasswordAtIndex:(NSInteger)index
{
    if (mutablePasswords.count > index){
        RCPassword * password = mutablePasswords[index];
        [mutablePasswords removeObjectAtIndex:index];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self deletePasswordFromKeychain:password];
            [self commitTotalToKeychain];
        });
    }
}

-(void)addPassword:(RCPassword *)password atIndex:(NSInteger)index
{
    if (index == mutablePasswords.count)
        [mutablePasswords addObject:password];
    else
        [mutablePasswords insertObject:password atIndex:index];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self commitAllPasswordsToKeyChain];
        [self commitTotalToKeychain];
    });
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
    if (mutablePasswords)
        return [NSArray arrayWithArray:mutablePasswords];
    return nil;
}

-(NSArray *)allTitles
{
    NSMutableArray * titles = [NSMutableArray new];
    for (RCPassword * password in self.passwords) {
        [titles addObject:password.title];
    }
    return titles;
}

-(void)lockPasswordsCompletion:(void(^)())completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self lockPasswords];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    });
}

-(void)lockPasswords
{
    [self commitAllPasswordsToKeyChain];
    mutablePasswords = nil;
}

-(void)grantPasswordAccess
{
    if ([self anyLoginsExist]){
        [self constructPasswordsFromKeychain];
    }else
        mutablePasswords = [NSMutableArray new];
}

-(void)grantPasswordAccess:(void(^)())completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self grantPasswordAccess];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    });
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
    NSDate * date = [NSDate date];
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
        [rcPassword decrypt];
        NSLog(@"INDEX %d TITLE %@, NAME %@, PASSWORD %@, URL %@", i, rcPassword.title, rcPassword.username, rcPassword.password, rcPassword.urlName);
        [passwords addObject:rcPassword];
    }
    mutablePasswords = passwords;
    NSLog(@"TIME SINCE START %f", -[date timeIntervalSinceNow]);
}

-(void)commitAllPasswordsToKeyChain
{
    NSMutableArray * mutableCopy = [mutablePasswords mutableCopy];
    for (RCPassword * password in mutableCopy) {
        NSInteger index = [mutablePasswords indexOfObject:password];
        NSString * titleIndex = [NSString stringWithFormat:@"%@%d", STORED_TITLE_PREFIX, index];
        NSString * nameIndex = [NSString stringWithFormat:@"%@%d", STORED_EMAIL_PREFIX, index];
        NSString * passwordIndex = [NSString stringWithFormat:@"%@%d", STORED_PASSWORD_PREFIX, index];
        NSString * urlIndex = [NSString stringWithFormat:@"%@%d", STORED_URL_PREFIX, index];
        NSString * notes1Index = [NSString stringWithFormat:@"%@%d", STORED_NOTES1_PREFIX, index];
        NSString * notes2Index= [NSString stringWithFormat:@"%@%d", STORED_NOTES2_PREFIX, index];
        NSLog(@"INDEX %d TITLE %@, NAME %@, PASSWORD %@, URL %@", index, password.title, password.username, password.password, password.urlName);
        [password encrypt];
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
    [password encrypt];
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

-(void)clearAllPasswordData
{
    NSInteger count = [[[PDKeychainBindings sharedKeychainBindings] stringForKey:STORED_TITLE_COUNT] integerValue];
    for (int i = 0; i < count; i++) {
        NSString * titleIndex = [NSString stringWithFormat:@"%@%d", STORED_TITLE_PREFIX, i];
        NSString * nameIndex = [NSString stringWithFormat:@"%@%d", STORED_EMAIL_PREFIX, i];
        NSString * passwordIndex = [NSString stringWithFormat:@"%@%d", STORED_PASSWORD_PREFIX, i];
        NSString * urlIndex = [NSString stringWithFormat:@"%@%d", STORED_URL_PREFIX, i];
        NSString * notes1Index = [NSString stringWithFormat:@"%@%d", STORED_NOTES1_PREFIX, i];
        NSString * notes2Index= [NSString stringWithFormat:@"%@%d", STORED_NOTES2_PREFIX, i];
        [[PDKeychainBindings sharedKeychainBindings] setString:@"" forKey:titleIndex];
        [[PDKeychainBindings sharedKeychainBindings] setString:@"" forKey:nameIndex];
        [[PDKeychainBindings sharedKeychainBindings] setString:@"" forKey:passwordIndex];
        [[PDKeychainBindings sharedKeychainBindings] setString:@"" forKey:urlIndex];
        [[PDKeychainBindings sharedKeychainBindings] setString:@"" forKey:notes1Index];
        [[PDKeychainBindings sharedKeychainBindings] setString:@"" forKey:notes2Index];
    }
    [[PDKeychainBindings sharedKeychainBindings] setString:@"" forKey:STORED_TITLE_COUNT];
    if (mutablePasswords){
        [mutablePasswords removeAllObjects];
    }
}

-(void)commitTotalToKeychain
{
    NSString * totalString = [NSString stringWithFormat:@"%d", mutablePasswords.count];
    [[PDKeychainBindings sharedKeychainBindings] setString:totalString forKey:STORED_TITLE_COUNT];
}

@end

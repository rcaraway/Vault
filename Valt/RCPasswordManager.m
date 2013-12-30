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


//KEYCHAIN
//addNewPassword
//addPasswordAtIndex
//addNewPasswords
//rewriteWithPasswords
//removePasswordAtIndex
//movePasswordAtIndex:ToIndex

static RCPasswordManager * manager;

@implementation RCPasswordManager
{
    NSMutableArray * mutablePasswords;
    NSString * randomKey;
    dispatch_queue_t keyChainQueue;
    BOOL cancelQueue;
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
        keyChainQueue = dispatch_queue_create("kcQueue", DISPATCH_QUEUE_SERIAL);
        mutablePasswords = [NSMutableArray new];
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
    //decrypt
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
    if (password){
        [mutablePasswords addObject:password];
        dispatch_async(keyChainQueue, ^{
            [self addNewPasswordToKeychain:password]; //correct, should just add to end, +1 to total
            [self commitTotalToKeychain];
        });
    }
}


-(void)addPasswords:(NSArray *)passwords
{
    [mutablePasswords addObjectsFromArray:passwords];
#ifdef TESTING_MODE
    [self addNewPasswordsToKeychain:passwords];
    [self commitTotalToKeychain];
#else
    dispatch_async(keyChainQueue, ^{
        [self addNewPasswordsToKeychain:passwords];
        [self commitTotalToKeychain];
    });
#endif
}

-(void)replaceAllPasswordsWithPasswords:(NSArray *)passwords
{
    [mutablePasswords removeAllObjects];
    [mutablePasswords addObjectsFromArray:passwords];
#ifdef TESTING_MODE
    [self replaceKeychainPasswordsWith:passwords];
    [self commitTotalToKeychain];

#else
    dispatch_async(keyChainQueue, ^{
        [self replaceKeychainPasswordsWith:passwords];
        [self commitTotalToKeychain];
    });
#endif
}

-(void)removePassword:(RCPassword *)password
{
    NSUInteger index = [mutablePasswords indexOfObject:password];
    [mutablePasswords removeObject:password];
#ifdef TESTING_MODE
    if (index == mutablePasswords.count)
        [self deleteKeychainPasswordAtIndex:index];
    else{
        [self decrementKeychainValuesStartingAtIndex:index];
    }
    [self commitTotalToKeychain];
#else
    dispatch_async(keyChainQueue, ^{
        if (index == mutablePasswords.count)
            [self deleteKeychainPasswordAtIndex:index];
        else{
            [self decrementKeychainValuesStartingAtIndex:index];
        }
        [self commitTotalToKeychain];
    });
#endif
    
}

-(void)removePasswordAtIndex:(NSInteger)index
{
    if (mutablePasswords.count > index){
        [mutablePasswords removeObjectAtIndex:index];
#ifdef TESTING_MODE
        if (index == mutablePasswords.count)
            [self deleteKeychainPasswordAtIndex:index];
        else{
            [self decrementKeychainValuesStartingAtIndex:index];
        }
#else
        dispatch_async(keyChainQueue, ^{
            if (index == mutablePasswords.count)
                [self deleteKeychainPasswordAtIndex:index];
            else{
                [self decrementKeychainValuesStartingAtIndex:index];
            }
        });
#endif
    }
}

-(void)addPassword:(RCPassword *)password atIndex:(NSInteger)index
{
    if (password){
        if (index == mutablePasswords.count){
            [mutablePasswords addObject:password];
#ifdef TESTING_MODE
            [self addNewPasswordToKeychain:password];
            [self commitTotalToKeychain];
#else
            dispatch_async(keyChainQueue, ^{
                [self addNewPasswordToKeychain:password];
                [self commitTotalToKeychain];
            });
#endif
        }
        else if (index < mutablePasswords.count && index >= 0){
            [mutablePasswords insertObject:password atIndex:index];
#ifdef TESTING_MODE
            [self incrementKeychainValuesStartingAtIndex:index];
            [self addNewPasswordToKeychain:password atIndex:index];
            [self commitTotalToKeychain];
#else
            dispatch_async(keyChainQueue, ^{
                [self incrementKeychainValuesStartingAtIndex:index];
                [self addNewPasswordToKeychain:password atIndex:index];
                [self commitTotalToKeychain];
            });
#endif
        }
    }
}

-(void)movePasswordAtIndex:(NSInteger)passwordIndex toNewIndex:(NSInteger)newIndex
{
    if (passwordIndex != newIndex && newIndex < mutablePasswords.count){
        RCPassword * password = [mutablePasswords objectAtIndex:passwordIndex];
        [mutablePasswords removeObjectAtIndex:passwordIndex];
        [mutablePasswords insertObject:password atIndex:newIndex];
#ifdef TESTING_MODE
    [self moveKeychainPasswordAtIndex:passwordIndex toIndex:newIndex];
#else
    dispatch_async(keyChainQueue, ^{
        [self moveKeychainPasswordAtIndex:passwordIndex toIndex:newIndex];
    });
#endif
    }
}

-(void)updatePassword:(RCPassword *)password
{
#ifdef TESTING_MODE
      [self updatePasswordInKeychain:password];
#else
    dispatch_async(keyChainQueue, ^{
        [self updatePasswordInKeychain:password];
    });
#endif
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
//        NSLog(@"CONSTRUCTING INDEX %d TITLE %@, NAME %@, PASSWORD %@, URL %@", i, rcPassword.title, rcPassword.username, rcPassword.password, rcPassword.urlName);
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
//        NSLog(@"COMMITTING INDEX %d TITLE %@, NAME %@, PASSWORD %@, URL %@", index, password.title, password.username, password.password, password.urlName);
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

-(void)updatePasswordInKeychain:(RCPassword *)password
{
    NSUInteger index = [mutablePasswords indexOfObject:password];
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

-(void)addNewPasswordToKeychain:(RCPassword *)password
{
    NSInteger index = mutablePasswords.count-1;
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

-(void)addNewPasswordToKeychain:(RCPassword *)password atIndex:(NSInteger)index
{
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

-(void)addNewPasswordsToKeychain:(NSArray *)passwords
{
    NSUInteger startIndex = mutablePasswords.count-passwords.count;
    for (RCPassword * password in passwords) {
        NSString * titleIndex = [NSString stringWithFormat:@"%@%d", STORED_TITLE_PREFIX, startIndex];
        NSString * nameIndex = [NSString stringWithFormat:@"%@%d", STORED_EMAIL_PREFIX, startIndex];
        NSString * passwordIndex = [NSString stringWithFormat:@"%@%d", STORED_PASSWORD_PREFIX, startIndex];
        NSString * urlIndex = [NSString stringWithFormat:@"%@%d", STORED_URL_PREFIX, startIndex];
        NSString * notes1Index = [NSString stringWithFormat:@"%@%d", STORED_NOTES1_PREFIX, startIndex];
        NSString * notes2Index= [NSString stringWithFormat:@"%@%d", STORED_NOTES2_PREFIX, startIndex];
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
        startIndex++;
    }
}

-(void)replaceKeychainPasswordsWith:(NSArray *)passwords
{
    NSUInteger keyChainCount =[[[PDKeychainBindings sharedKeychainBindings] stringForKey:STORED_TITLE_COUNT] integerValue];
    NSUInteger count = (passwords.count >= keyChainCount)?passwords.count:keyChainCount;
    for (int i = 0; i < count; i++) {
        if (i < passwords.count){
            RCPassword * password = passwords[i];
            NSString * titleIndex = [NSString stringWithFormat:@"%@%d", STORED_TITLE_PREFIX, i];
            NSString * nameIndex = [NSString stringWithFormat:@"%@%d", STORED_EMAIL_PREFIX, i];
            NSString * passwordIndex = [NSString stringWithFormat:@"%@%d", STORED_PASSWORD_PREFIX, i];
            NSString * urlIndex = [NSString stringWithFormat:@"%@%d", STORED_URL_PREFIX, i];
            NSString * notes1Index = [NSString stringWithFormat:@"%@%d", STORED_NOTES1_PREFIX, i];
            NSString * notes2Index= [NSString stringWithFormat:@"%@%d", STORED_NOTES2_PREFIX, i];
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
        }else{
            [self deleteKeychainPasswordAtIndex:i];
        }
    }
}

-(void)moveKeychainPasswordAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    //get from indexes
    NSString * titleIndex = [NSString stringWithFormat:@"%@%d", STORED_TITLE_PREFIX, fromIndex];
    NSString * nameIndex = [NSString stringWithFormat:@"%@%d", STORED_EMAIL_PREFIX, fromIndex];
    NSString * passwordIndex = [NSString stringWithFormat:@"%@%d", STORED_PASSWORD_PREFIX, fromIndex];
    NSString * urlIndex = [NSString stringWithFormat:@"%@%d", STORED_URL_PREFIX, fromIndex];
    NSString * notes1Index = [NSString stringWithFormat:@"%@%d", STORED_NOTES1_PREFIX, fromIndex];
    NSString * notes2Index= [NSString stringWithFormat:@"%@%d", STORED_NOTES2_PREFIX, fromIndex];

    //get from indexes
    NSString * titleIndex2 = [NSString stringWithFormat:@"%@%d", STORED_TITLE_PREFIX, toIndex];
    NSString * nameIndex2 = [NSString stringWithFormat:@"%@%d", STORED_EMAIL_PREFIX, toIndex];
    NSString * passwordIndex2 = [NSString stringWithFormat:@"%@%d", STORED_PASSWORD_PREFIX, toIndex];
    NSString * urlIndex2 = [NSString stringWithFormat:@"%@%d", STORED_URL_PREFIX, toIndex];
    NSString * notes1Index2 = [NSString stringWithFormat:@"%@%d", STORED_NOTES1_PREFIX, toIndex];
    NSString * notes2Index2= [NSString stringWithFormat:@"%@%d", STORED_NOTES2_PREFIX, toIndex];

    //get values
    NSString * title = [[PDKeychainBindings sharedKeychainBindings] stringForKey:titleIndex];
    NSString * name = [[PDKeychainBindings sharedKeychainBindings] stringForKey:nameIndex];
    NSString * password = [[PDKeychainBindings sharedKeychainBindings] stringForKey:passwordIndex];
    NSString * url = [[PDKeychainBindings sharedKeychainBindings] stringForKey:urlIndex];
    NSString * notes1 = [[PDKeychainBindings sharedKeychainBindings] stringForKey:notes1Index];
    NSString * notes2 = [[PDKeychainBindings sharedKeychainBindings] stringForKey:notes2Index];
    
    if (fromIndex == mutablePasswords.count){
        [self deleteKeychainPasswordAtIndex:fromIndex];
    }else{
         [self decrementKeychainValuesStartingAtIndex:fromIndex];
    }
    [self incrementKeychainValuesStartingAtIndex:toIndex];
    
    [[PDKeychainBindings sharedKeychainBindings] setString:title forKey:titleIndex2];
    [[PDKeychainBindings sharedKeychainBindings] setString:name forKey:nameIndex2];
    [[PDKeychainBindings sharedKeychainBindings] setString:password forKey:passwordIndex2];
    [[PDKeychainBindings sharedKeychainBindings] setString:url forKey:urlIndex2];
    [[PDKeychainBindings sharedKeychainBindings] setString:notes1 forKey:notes1Index2];
    [[PDKeychainBindings sharedKeychainBindings] setString:notes2 forKey:notes2Index2];
}

-(void)incrementKeychainValuesStartingAtIndex:(NSInteger)index
{
    NSInteger i = [[[PDKeychainBindings sharedKeychainBindings] stringForKey:STORED_TITLE_COUNT] integerValue]-1;
    while (i >= index) {
        //get indexes
        NSString * titleIndex = [NSString stringWithFormat:@"%@%d", STORED_TITLE_PREFIX, i];
        NSString * nameIndex = [NSString stringWithFormat:@"%@%d", STORED_EMAIL_PREFIX, i];
        NSString * passwordIndex = [NSString stringWithFormat:@"%@%d", STORED_PASSWORD_PREFIX, i];
        NSString * urlIndex = [NSString stringWithFormat:@"%@%d", STORED_URL_PREFIX, i];
        NSString * notes1Index = [NSString stringWithFormat:@"%@%d", STORED_NOTES1_PREFIX, i];
        NSString * notes2Index= [NSString stringWithFormat:@"%@%d", STORED_NOTES2_PREFIX, i];
        
        //get values
        NSString * title = [[PDKeychainBindings sharedKeychainBindings] stringForKey:titleIndex];
        NSString * name = [[PDKeychainBindings sharedKeychainBindings] stringForKey:nameIndex];
        NSString * password = [[PDKeychainBindings sharedKeychainBindings] stringForKey:passwordIndex];
        NSString * url = [[PDKeychainBindings sharedKeychainBindings] stringForKey:urlIndex];
        NSString * notes1 = [[PDKeychainBindings sharedKeychainBindings] stringForKey:notes1Index];
        NSString * notes2 = [[PDKeychainBindings sharedKeychainBindings] stringForKey:notes2Index];
        
        //shift values up 1 index
        [[PDKeychainBindings sharedKeychainBindings] setString:title forKey:[NSString stringWithFormat:@"%@%d", STORED_TITLE_PREFIX, i+1]];
        //        NSLog(@"MADE IT 1");
        [[PDKeychainBindings sharedKeychainBindings] setString:name forKey:[NSString stringWithFormat:@"%@%d", STORED_EMAIL_PREFIX, i+1]];
        //        NSLog(@"MADE IT 2");
        [[PDKeychainBindings sharedKeychainBindings] setString:password forKey:[NSString stringWithFormat:@"%@%d", STORED_PASSWORD_PREFIX, i+1]];
        //        NSLog(@"MADE IT 3");
        [[PDKeychainBindings sharedKeychainBindings] setString:url forKey:[NSString stringWithFormat:@"%@%d", STORED_URL_PREFIX, i+1]];
        //        NSLog(@"MADE IT 4");
        [[PDKeychainBindings sharedKeychainBindings] setString:notes1 forKey:[NSString stringWithFormat:@"%@%d", STORED_NOTES1_PREFIX, i+1]];
        //        NSLog(@"MADE IT 5");
        [[PDKeychainBindings sharedKeychainBindings] setString:notes2 forKey:[NSString stringWithFormat:@"%@%d", STORED_NOTES2_PREFIX, i+1]];
        
        --i;
    }
}

-(void)decrementKeychainValuesStartingAtIndex:(NSUInteger)index
{
    NSUInteger startIndex = index+1;
    NSUInteger keychainCount = [[[PDKeychainBindings sharedKeychainBindings] stringForKey:STORED_TITLE_COUNT] integerValue];
    for (int i = startIndex; i < keychainCount; i++) {
        //get indexes
        NSString * titleIndex = [NSString stringWithFormat:@"%@%d", STORED_TITLE_PREFIX, i];
        NSString * nameIndex = [NSString stringWithFormat:@"%@%d", STORED_EMAIL_PREFIX, i];
        NSString * passwordIndex = [NSString stringWithFormat:@"%@%d", STORED_PASSWORD_PREFIX, i];
        NSString * urlIndex = [NSString stringWithFormat:@"%@%d", STORED_URL_PREFIX, i];
        NSString * notes1Index = [NSString stringWithFormat:@"%@%d", STORED_NOTES1_PREFIX, i];
        NSString * notes2Index= [NSString stringWithFormat:@"%@%d", STORED_NOTES2_PREFIX, i];
        
        //get values
        NSString * title = [[PDKeychainBindings sharedKeychainBindings] stringForKey:titleIndex];
        NSString * name = [[PDKeychainBindings sharedKeychainBindings] stringForKey:nameIndex];
        NSString * password = [[PDKeychainBindings sharedKeychainBindings] stringForKey:passwordIndex];
        NSString * url = [[PDKeychainBindings sharedKeychainBindings] stringForKey:urlIndex];
        NSString * notes1 = [[PDKeychainBindings sharedKeychainBindings] stringForKey:notes1Index];
        NSString * notes2 = [[PDKeychainBindings sharedKeychainBindings] stringForKey:notes2Index];
        
        //shift values down 1 index
        [[PDKeychainBindings sharedKeychainBindings] setString:title forKey:[NSString stringWithFormat:@"%@%d", STORED_TITLE_PREFIX, i-1]];
        [[PDKeychainBindings sharedKeychainBindings] setString:name forKey:[NSString stringWithFormat:@"%@%d", STORED_EMAIL_PREFIX, i-1]];
        [[PDKeychainBindings sharedKeychainBindings] setString:password forKey:[NSString stringWithFormat:@"%@%d", STORED_PASSWORD_PREFIX, i-1]];
        [[PDKeychainBindings sharedKeychainBindings] setString:url forKey:[NSString stringWithFormat:@"%@%d", STORED_URL_PREFIX, i-1]];
        [[PDKeychainBindings sharedKeychainBindings] setString:notes1 forKey:[NSString stringWithFormat:@"%@%d", STORED_NOTES1_PREFIX, i-1]];
        [[PDKeychainBindings sharedKeychainBindings] setString:notes2 forKey:[NSString stringWithFormat:@"%@%d", STORED_NOTES2_PREFIX, i-1]];
    }
}

-(void)deleteKeychainPasswordAtIndex:(NSUInteger)i
{
    NSString * titleIndex = [NSString stringWithFormat:@"%@%d", STORED_TITLE_PREFIX, i];
    NSString * nameIndex = [NSString stringWithFormat:@"%@%d", STORED_EMAIL_PREFIX, i];
    NSString * passwordIndex = [NSString stringWithFormat:@"%@%d", STORED_PASSWORD_PREFIX, i];
    NSString * urlIndex = [NSString stringWithFormat:@"%@%d", STORED_URL_PREFIX, i];
    NSString * notes1Index = [NSString stringWithFormat:@"%@%d", STORED_NOTES1_PREFIX, i];
    NSString * notes2Index= [NSString stringWithFormat:@"%@%d", STORED_NOTES2_PREFIX, i];
    [[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:titleIndex];
    [[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:nameIndex];
    [[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:passwordIndex];
    [[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:urlIndex];
    [[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:notes1Index];
    [[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:notes2Index];
}

-(void)clearAllPasswordData
{
    NSInteger count = [[[PDKeychainBindings sharedKeychainBindings] stringForKey:STORED_TITLE_COUNT] integerValue];
    for (int i = 0; i < count; i++) {
        [self deleteKeychainPasswordAtIndex:i];
    }
    [[PDKeychainBindings sharedKeychainBindings] setString:@"0" forKey:STORED_TITLE_COUNT];
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

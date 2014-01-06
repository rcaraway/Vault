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

#define STORED_TITLE_COUNT "STORED_TITLE_COUNT"
#define STORED_TITLE_PREFIX "STORED_TITLE_"
#define STORED_PASSWORD_PREFIX "STORED_PASSWORD_"
#define STORED_EMAIL_PREFIX "STORE_EMAIL_"
#define STORED_URL_PREFIX "STORED_URL_"
#define STORED_NOTES_PREFIX "STORED_NOTES_"


NSString * const passwordManagerAccessGranted = @"passwordManagerAccessGranted";
NSString * const passwordManagerAccessFailedToGrant = @"passwordManagerAccessFailedToGrant";
NSString * const passwordManagerAccessDenied = @"passwordManagerAccessDenied";
NSString * const passwordManagerDidLock = @"passwordManagerDidLock";
NSString * const passwordManagerDidCreateMasterPassword = @"passwordManagerDidCreateMasterPassword";
NSString * const passwordManagerDidChangeMasterPassword = @"passwordManagerDidChangeMasterPassword";
NSString * const passwordManagerDidFailToChangeMasterPassword = @"passwordManagerDidFailToChangeMasterPassword";
NSString * const passwordManagerDidUpdatePasswords = @"passwordManagerDidUpdatePasswords";

static RCPasswordManager * manager;


#pragma mark - C functions

typedef struct {
    char * titleKey;
    char * passwordKey;
    char * emailKey;
    char * urlKey;
    char * notesKey;
} KeychainKeySet;

static inline __attribute__ ((always_inline)) char* concat(char *s1, char *s2)
{
    char *result = malloc(strlen(s1)+strlen(s2)+1);
    strcpy(result, s1);
    strcat(result, s2);
    return result;
}

static inline __attribute__ ((always_inline)) char * titleKey(char * index)
{
    return concat(STORED_TITLE_PREFIX, index);
}

static inline __attribute__ ((always_inline)) char * emailKey(char * index)
{
    return concat(STORED_EMAIL_PREFIX, index);
}

static inline __attribute__ ((always_inline)) char * passwordKey(char * index)
{
    return concat(STORED_PASSWORD_PREFIX, index);
}

static inline __attribute__ ((always_inline)) char * urlKey(char * index)
{
    return concat(STORED_URL_PREFIX, index);
}

static inline __attribute__ ((always_inline)) char * notesKey(char * index)
{
    return concat(STORED_NOTES_PREFIX, index);
}

static inline __attribute__ ((always_inline)) KeychainKeySet keyChainKeys(int index)
{
    KeychainKeySet keychainSet;
    char charIndex[5];
    sprintf(charIndex, "%d", index);
    keychainSet.titleKey = titleKey(charIndex);
    keychainSet.emailKey = emailKey(charIndex);
    keychainSet.passwordKey = passwordKey(charIndex);
    keychainSet.urlKey = urlKey(charIndex);
    keychainSet.notesKey = notesKey(charIndex);
    return keychainSet;
}











@implementation RCPasswordManager
{
    NSMutableArray * mutablePasswords;
    NSString * randomKey;
    dispatch_queue_t keyChainQueue;
    BOOL cancelQueue;
    BOOL allowOverridePassword;
}


#pragma mark - Class Methods

+(void)initialize
{
    manager = [[RCPasswordManager  alloc] init];
}

+(RCPasswordManager *)defaultManager
{
    return manager;
}

#pragma mark - Initialization

-(id)init
{
    self = super.init;
    if (self){
        keyChainQueue = dispatch_queue_create("kcQueue", DISPATCH_QUEUE_SERIAL);
        mutablePasswords = [NSMutableArray new];
    }
    return self;
}


#pragma mark - Accessing / Master Password

-(void)setMasterPassword:(NSString *)masterPassword
{
    NSString * mPw = [[PDKeychainBindings sharedKeychainBindings] stringForKey:MASTER_PASSWORD_KEY];
    if (!mPw || mPw.length == 0 || allowOverridePassword){
         [[PDKeychainBindings sharedKeychainBindings] setString:masterPassword forKey:MASTER_PASSWORD_KEY];
        if (!allowOverridePassword)
            [self grantPasswordAccess];
    }else{
        [self didDenyAccess:@"Access Denied"];
    }
}

-(void)removeMasterPassword
{
    [[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:MASTER_PASSWORD_KEY];
}

-(NSString *)masterPassword
{
#ifdef TESTING_MODE
    if (!randomKey){
        randomKey = [NSString randomString];
    }
    return randomKey;
#else
    if (_accessGranted){
        return [[PDKeychainBindings sharedKeychainBindings] stringForKey:MASTER_PASSWORD_KEY];
    }
#endif
    return nil;
}

-(BOOL)anyLoginsExist
{
    return ![[[PDKeychainBindings sharedKeychainBindings] stringForKey:STORED_TITLE_COUNT] isEqualToString:@""] && [[[PDKeychainBindings sharedKeychainBindings] stringForKey:STORED_TITLE_COUNT] integerValue] > 0;
}

-(BOOL)masterPasswordExists
{
    return [[PDKeychainBindings sharedKeychainBindings] stringForKey:MASTER_PASSWORD_KEY] && [[PDKeychainBindings sharedKeychainBindings] stringForKey:MASTER_PASSWORD_KEY].length > 0;
}

-(void)attemptToUnlockWithCodeInBackground:(NSString *)password
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString * mPw = [[PDKeychainBindings sharedKeychainBindings] stringForKey:MASTER_PASSWORD_KEY];
        if ([password isEqualToString:mPw]){
            [self grantPasswordAccess];
            dispatch_async(dispatch_get_main_queue(), ^{
                _accessGranted = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:passwordManagerAccessGranted object:nil];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                _accessGranted = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:passwordManagerAccessFailedToGrant object:nil];
            });
        }
    });
}

-(void)attemptToUnlockWithCode:(NSString *)password
{
    NSString * mPw;
#ifdef TESTING_MODE
    mPw = [self masterPassword];
#else
     mPw = [[PDKeychainBindings sharedKeychainBindings] stringForKey:MASTER_PASSWORD_KEY];
#endif
    if ([password isEqualToString:mPw]){
        [self grantPasswordAccess];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:passwordManagerAccessFailedToGrant object:nil];
        });
    }
}


#pragma mark - Password Mutation Editing

-(void)addPassword:(RCPassword *)password
{
    if (password && _accessGranted){
        [mutablePasswords addObject:password];
        dispatch_async(keyChainQueue, ^{
            [self addNewPasswordToKeychain:password]; //correct, should just add to end, +1 to total
            [self commitTotalToKeychain];
        });
        [[NSNotificationCenter defaultCenter] postNotificationName:passwordManagerDidUpdatePasswords object:nil];
    }
}

-(void)addPasswords:(NSArray *)passwords
{
    if (passwords && _accessGranted){
        [mutablePasswords addObjectsFromArray:passwords];
#ifdef TESTING_MODE
        [self addNewPasswordsToKeychain:passwords];
        [self commitTotalToKeychain];
#else
        dispatch_async(keyChainQueue, ^{
            [self addNewPasswordsToKeychain:passwords];
            [self commitTotalToKeychain];
        });
        [[NSNotificationCenter defaultCenter] postNotificationName:passwordManagerDidUpdatePasswords object:nil];
#endif
    }
}

-(void)replaceAllPasswordsWithPasswords:(NSArray *)passwords
{
    if (passwords && _accessGranted){
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
        [[NSNotificationCenter defaultCenter] postNotificationName:passwordManagerDidUpdatePasswords object:nil];
#endif
    }
}

-(void)removePassword:(RCPassword *)password
{
    if (password && _accessGranted){
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
        [[NSNotificationCenter defaultCenter] postNotificationName:passwordManagerDidUpdatePasswords object:nil];
#endif
    }
    
}

-(void)removePasswordAtIndex:(NSInteger)index
{
    if (mutablePasswords.count > index && _accessGranted){
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
        [[NSNotificationCenter defaultCenter] postNotificationName:passwordManagerDidUpdatePasswords object:nil];
#endif
    }
}

-(void)addPassword:(RCPassword *)password atIndex:(NSInteger)index
{
    if (password && _accessGranted){
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
            [[NSNotificationCenter defaultCenter] postNotificationName:passwordManagerDidUpdatePasswords object:nil];
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
            [[NSNotificationCenter defaultCenter] postNotificationName:passwordManagerDidUpdatePasswords object:nil];
#endif
        }
    }
}

-(void)movePasswordAtIndex:(NSInteger)passwordIndex toNewIndex:(NSInteger)newIndex
{
    if (_accessGranted && passwordIndex != newIndex && newIndex < mutablePasswords.count){
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
    if (password && _accessGranted){
#ifdef TESTING_MODE
        [self updatePasswordInKeychain:password];
#else
        dispatch_async(keyChainQueue, ^{
            [self updatePasswordInKeychain:password];
        });
        [[NSNotificationCenter defaultCenter] postNotificationName:passwordManagerDidUpdatePasswords object:nil];
#endif
    }
}


#pragma mark - Properties Accessors

-(NSArray *)passwords
{
    if (_accessGranted && mutablePasswords)
        return [NSArray arrayWithArray:mutablePasswords];
    return nil;
}

-(NSArray *)allTitles
{
    if (_accessGranted){
        NSMutableArray * titles = [NSMutableArray new];
        for (RCPassword * password in self.passwords) {
            if (password.title)
                [titles addObject:password.title];
            else{
                [titles addObject:@""];
            }
        }
        return titles;
    }
    return nil;
}

-(RCPassword *)passwordForTitle:(NSString *)title
{
    if (_accessGranted){
        for (RCPassword * singlePass in mutablePasswords) {
            if ([singlePass.title isEqualToString:title]){
                return singlePass;
            }
        }
    }
    return nil;
}


#pragma mark - State handling

-(void)lockPasswordsCompletion:(void(^)())completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self lockPasswords];
        _accessGranted = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    });
}

-(void)lockPasswords
{
    [self commitAllPasswordsToKeyChain];
    _accessGranted = NO;
    mutablePasswords = nil;
}

-(void)grantPasswordAccess
{
    _accessGranted = YES;
    if ([self anyLoginsExist]){
        [self constructPasswordsFromKeychain];
    }else
        mutablePasswords = [NSMutableArray new];
}

-(void)didDenyAccess:(NSString *)message
{
    [[NSNotificationCenter defaultCenter] postNotificationName:passwordManagerAccessDenied object:message];
}



#pragma mark - Keychain

-(void)constructPasswordsFromKeychain
{
    if (_accessGranted){
        NSInteger count = [[[PDKeychainBindings sharedKeychainBindings] stringForKey:STORED_TITLE_COUNT] integerValue];
        NSMutableArray * passwords = [NSMutableArray arrayWithCapacity:count];
        for (int i = 0; i < count; i++) {
            RCPassword * rcPassword = [[RCPassword alloc] init];
            NSString * titleIndex = [NSString stringWithFormat:@"%@%d", STORED_TITLE_PREFIX, i];
            NSString * nameIndex = [NSString stringWithFormat:@"%@%d", STORED_EMAIL_PREFIX, i];
            NSString * passwordIndex = [NSString stringWithFormat:@"%@%d", STORED_PASSWORD_PREFIX, i];
            NSString * urlIndex = [NSString stringWithFormat:@"%@%d", STORED_URL_PREFIX, i];
            NSString * notesIndex = [NSString stringWithFormat:@"%@%d", STORED_NOTES_PREFIX, i];
            rcPassword.title = [[PDKeychainBindings sharedKeychainBindings] stringForKey:titleIndex];
            rcPassword.username = [[PDKeychainBindings sharedKeychainBindings] stringForKey:nameIndex];
            rcPassword.urlName = [[PDKeychainBindings sharedKeychainBindings] stringForKey:urlIndex];
            rcPassword.password = [[PDKeychainBindings sharedKeychainBindings] stringForKey:passwordIndex];
            rcPassword.notes = [[PDKeychainBindings sharedKeychainBindings] stringForKey:notesIndex];
            //        NSLog(@"CONSTRUCTING INDEX %d TITLE %@, NAME %@, PASSWORD %@, URL %@", i, rcPassword.title, rcPassword.username, rcPassword.password, rcPassword.urlName);
            [passwords addObject:rcPassword];
        }
        mutablePasswords = passwords;
    }
}

-(void)commitAllPasswordsToKeyChain
{
    if (_accessGranted){
        NSMutableArray * mutableCopy = [mutablePasswords mutableCopy];
        for (RCPassword * password in mutableCopy) {
            NSInteger index = [mutablePasswords indexOfObject:password];
            NSString * titleIndex = [NSString stringWithFormat:@"%@%d", STORED_TITLE_PREFIX, index];
            NSString * nameIndex = [NSString stringWithFormat:@"%@%d", STORED_EMAIL_PREFIX, index];
            NSString * passwordIndex = [NSString stringWithFormat:@"%@%d", STORED_PASSWORD_PREFIX, index];
            NSString * urlIndex = [NSString stringWithFormat:@"%@%d", STORED_URL_PREFIX, index];
            NSString * notesIndex = [NSString stringWithFormat:@"%@%d", STORED_NOTES_PREFIX, index];
            //        NSLog(@"COMMITTING INDEX %d TITLE %@, NAME %@, PASSWORD %@, URL %@", index, password.title, password.username, password.password, password.urlName);
            [[PDKeychainBindings sharedKeychainBindings] setString:password.title forKey:titleIndex];
            [[PDKeychainBindings sharedKeychainBindings] setString:password.username forKey:nameIndex];
            [[PDKeychainBindings sharedKeychainBindings] setString:password.password forKey:passwordIndex];
            [[PDKeychainBindings sharedKeychainBindings] setString:password.urlName forKey:urlIndex];
            [[PDKeychainBindings sharedKeychainBindings] setString:password.notes forKey:notesIndex];
        }
    }
}

-(void)updatePasswordInKeychain:(RCPassword *)password
{
    if (_accessGranted && password){
        NSUInteger index = [mutablePasswords indexOfObject:password];
        NSString * titleIndex = [NSString stringWithFormat:@"%@%d", STORED_TITLE_PREFIX, index];
        NSString * nameIndex = [NSString stringWithFormat:@"%@%d", STORED_EMAIL_PREFIX, index];
        NSString * passwordIndex = [NSString stringWithFormat:@"%@%d", STORED_PASSWORD_PREFIX, index];
        NSString * urlIndex = [NSString stringWithFormat:@"%@%d", STORED_URL_PREFIX, index];
       NSString * notesIndex = [NSString stringWithFormat:@"%@%d", STORED_NOTES_PREFIX, index];
        [[PDKeychainBindings sharedKeychainBindings] setString:password.title forKey:titleIndex];
        [[PDKeychainBindings sharedKeychainBindings] setString:password.username forKey:nameIndex];
        [[PDKeychainBindings sharedKeychainBindings] setString:password.password forKey:passwordIndex];
        [[PDKeychainBindings sharedKeychainBindings] setString:password.urlName forKey:urlIndex];
        [[PDKeychainBindings sharedKeychainBindings] setString:password.notes forKey:notesIndex];
    }
}

-(void)addNewPasswordToKeychain:(RCPassword *)password
{
    if (_accessGranted && password){
        NSInteger index = mutablePasswords.count-1;
        NSString * titleIndex = [NSString stringWithFormat:@"%@%d", STORED_TITLE_PREFIX, index];
        NSString * nameIndex = [NSString stringWithFormat:@"%@%d", STORED_EMAIL_PREFIX, index];
        NSString * passwordIndex = [NSString stringWithFormat:@"%@%d", STORED_PASSWORD_PREFIX, index];
        NSString * urlIndex = [NSString stringWithFormat:@"%@%d", STORED_URL_PREFIX, index];
       NSString * notesIndex = [NSString stringWithFormat:@"%@%d", STORED_NOTES_PREFIX, index];
        [[PDKeychainBindings sharedKeychainBindings] setString:password.title forKey:titleIndex];
        [[PDKeychainBindings sharedKeychainBindings] setString:password.username forKey:nameIndex];
        [[PDKeychainBindings sharedKeychainBindings] setString:password.password forKey:passwordIndex];
        [[PDKeychainBindings sharedKeychainBindings] setString:password.urlName forKey:urlIndex];
        [[PDKeychainBindings sharedKeychainBindings] setString:password.notes forKey:notesIndex];
    }
}

-(void)addNewPasswordToKeychain:(RCPassword *)password atIndex:(NSInteger)index
{
    if (_accessGranted && password){
        NSString * titleIndex = [NSString stringWithFormat:@"%@%d", STORED_TITLE_PREFIX, index];
        NSString * nameIndex = [NSString stringWithFormat:@"%@%d", STORED_EMAIL_PREFIX, index];
        NSString * passwordIndex = [NSString stringWithFormat:@"%@%d", STORED_PASSWORD_PREFIX, index];
        NSString * urlIndex = [NSString stringWithFormat:@"%@%d", STORED_URL_PREFIX, index];
        NSString * notesIndex = [NSString stringWithFormat:@"%@%d", STORED_NOTES_PREFIX, index];
        [[PDKeychainBindings sharedKeychainBindings] setString:password.title forKey:titleIndex];
        [[PDKeychainBindings sharedKeychainBindings] setString:password.username forKey:nameIndex];
        [[PDKeychainBindings sharedKeychainBindings] setString:password.password forKey:passwordIndex];
        [[PDKeychainBindings sharedKeychainBindings] setString:password.urlName forKey:urlIndex];
        [[PDKeychainBindings sharedKeychainBindings] setString:password.notes forKey:notesIndex];
    }
}

-(void)addNewPasswordsToKeychain:(NSArray *)passwords
{
    if (_accessGranted && passwords){
        NSUInteger startIndex = mutablePasswords.count-passwords.count;
        for (RCPassword * password in passwords) {
            NSString * titleIndex = [NSString stringWithFormat:@"%@%d", STORED_TITLE_PREFIX, startIndex];
            NSString * nameIndex = [NSString stringWithFormat:@"%@%d", STORED_EMAIL_PREFIX, startIndex];
            NSString * passwordIndex = [NSString stringWithFormat:@"%@%d", STORED_PASSWORD_PREFIX, startIndex];
            NSString * urlIndex = [NSString stringWithFormat:@"%@%d", STORED_URL_PREFIX, startIndex];
           NSString * notesIndex = [NSString stringWithFormat:@"%@%d", STORED_NOTES_PREFIX, startIndex];
            [[PDKeychainBindings sharedKeychainBindings] setString:password.title forKey:titleIndex];
            [[PDKeychainBindings sharedKeychainBindings] setString:password.username forKey:nameIndex];
            [[PDKeychainBindings sharedKeychainBindings] setString:password.password forKey:passwordIndex];
            [[PDKeychainBindings sharedKeychainBindings] setString:password.urlName forKey:urlIndex];
            [[PDKeychainBindings sharedKeychainBindings] setString:password.notes forKey:notesIndex];
            startIndex++;
        }
    }
}

-(void)replaceKeychainPasswordsWith:(NSArray *)passwords
{
    if (_accessGranted){
        NSUInteger keyChainCount =[[[PDKeychainBindings sharedKeychainBindings] stringForKey:STORED_TITLE_COUNT] integerValue];
        NSUInteger count = (passwords.count >= keyChainCount)?passwords.count:keyChainCount;
        for (int i = 0; i < count; i++) {
            if (i < passwords.count){
                RCPassword * password = passwords[i];
                NSString * titleIndex = [NSString stringWithFormat:@"%@%d", STORED_TITLE_PREFIX, i];
                NSString * nameIndex = [NSString stringWithFormat:@"%@%d", STORED_EMAIL_PREFIX, i];
                NSString * passwordIndex = [NSString stringWithFormat:@"%@%d", STORED_PASSWORD_PREFIX, i];
                NSString * urlIndex = [NSString stringWithFormat:@"%@%d", STORED_URL_PREFIX, i];
               NSString * notesIndex = [NSString stringWithFormat:@"%@%d", STORED_NOTES_PREFIX, i];
                [[PDKeychainBindings sharedKeychainBindings] setString:password.title forKey:titleIndex];
                [[PDKeychainBindings sharedKeychainBindings] setString:password.username forKey:nameIndex];
                [[PDKeychainBindings sharedKeychainBindings] setString:password.password forKey:passwordIndex];
                [[PDKeychainBindings sharedKeychainBindings] setString:password.urlName forKey:urlIndex];
                [[PDKeychainBindings sharedKeychainBindings] setString:password.notes forKey:notesIndex];
            }else{
                [self deleteKeychainPasswordAtIndex:i];
            }
        }
    }
}

-(void)moveKeychainPasswordAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    if (_accessGranted){
        //get from indexes
        NSString * titleIndex = [NSString stringWithFormat:@"%@%d", STORED_TITLE_PREFIX, fromIndex];
        NSString * nameIndex = [NSString stringWithFormat:@"%@%d", STORED_EMAIL_PREFIX, fromIndex];
        NSString * passwordIndex = [NSString stringWithFormat:@"%@%d", STORED_PASSWORD_PREFIX, fromIndex];
        NSString * urlIndex = [NSString stringWithFormat:@"%@%d", STORED_URL_PREFIX, fromIndex];
       NSString * notesIndex = [NSString stringWithFormat:@"%@%d", STORED_NOTES_PREFIX, fromIndex];
        
        //get from indexes
        NSString * titleIndex2 = [NSString stringWithFormat:@"%@%d", STORED_TITLE_PREFIX, toIndex];
        NSString * nameIndex2 = [NSString stringWithFormat:@"%@%d", STORED_EMAIL_PREFIX, toIndex];
        NSString * passwordIndex2 = [NSString stringWithFormat:@"%@%d", STORED_PASSWORD_PREFIX, toIndex];
        NSString * urlIndex2 = [NSString stringWithFormat:@"%@%d", STORED_URL_PREFIX, toIndex];
        NSString * notesIndex2 = [NSString stringWithFormat:@"%@%d", STORED_NOTES_PREFIX, toIndex];

        //get values
        NSString * title = [[PDKeychainBindings sharedKeychainBindings] stringForKey:titleIndex];
        NSString * name = [[PDKeychainBindings sharedKeychainBindings] stringForKey:nameIndex];
        NSString * password = [[PDKeychainBindings sharedKeychainBindings] stringForKey:passwordIndex];
        NSString * url = [[PDKeychainBindings sharedKeychainBindings] stringForKey:urlIndex];
        NSString * notes = [[PDKeychainBindings sharedKeychainBindings] stringForKey:notesIndex];
        
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
        [[PDKeychainBindings sharedKeychainBindings] setString:notes forKey:notesIndex2];
    }
}

-(void)incrementKeychainValuesStartingAtIndex:(NSInteger)index
{
    if (_accessGranted){
        NSInteger i = [[[PDKeychainBindings sharedKeychainBindings] stringForKey:STORED_TITLE_COUNT] integerValue]-1;
        while (i >= index) {
            //get indexes
            NSString * titleIndex = [NSString stringWithFormat:@"%@%d", STORED_TITLE_PREFIX, i];
            NSString * nameIndex = [NSString stringWithFormat:@"%@%d", STORED_EMAIL_PREFIX, i];
            NSString * passwordIndex = [NSString stringWithFormat:@"%@%d", STORED_PASSWORD_PREFIX, i];
            NSString * urlIndex = [NSString stringWithFormat:@"%@%d", STORED_URL_PREFIX, i];
            NSString * notesIndex = [NSString stringWithFormat:@"%@%d", STORED_NOTES_PREFIX, index];
            
            //get values
            NSString * title = [[PDKeychainBindings sharedKeychainBindings] stringForKey:titleIndex];
            NSString * name = [[PDKeychainBindings sharedKeychainBindings] stringForKey:nameIndex];
            NSString * password = [[PDKeychainBindings sharedKeychainBindings] stringForKey:passwordIndex];
            NSString * url = [[PDKeychainBindings sharedKeychainBindings] stringForKey:urlIndex];
            NSString * notes = [[PDKeychainBindings sharedKeychainBindings] stringForKey:notesIndex];
            
            //shift values up 1 index
            [[PDKeychainBindings sharedKeychainBindings] setString:title forKey:[NSString stringWithFormat:@"%@%d", STORED_TITLE_PREFIX, i+1]];
            [[PDKeychainBindings sharedKeychainBindings] setString:name forKey:[NSString stringWithFormat:@"%@%d", STORED_EMAIL_PREFIX, i+1]];
            [[PDKeychainBindings sharedKeychainBindings] setString:password forKey:[NSString stringWithFormat:@"%@%d", STORED_PASSWORD_PREFIX, i+1]];
            [[PDKeychainBindings sharedKeychainBindings] setString:url forKey:[NSString stringWithFormat:@"%@%d", STORED_URL_PREFIX, i+1]];
            [[PDKeychainBindings sharedKeychainBindings] setString:notes forKey:[NSString stringWithFormat:@"%@%d", STORED_NOTES_PREFIX, i+1]];
            --i;
        }
    }
}

-(void)decrementKeychainValuesStartingAtIndex:(NSUInteger)index
{
    if (_accessGranted){
        NSUInteger startIndex = index+1;
        NSUInteger keychainCount = [[[PDKeychainBindings sharedKeychainBindings] stringForKey:STORED_TITLE_COUNT] integerValue];
        for (int i = startIndex; i < keychainCount; i++) {
            //get indexes
            NSString * titleIndex = [NSString stringWithFormat:@"%@%d", STORED_TITLE_PREFIX, i];
            NSString * nameIndex = [NSString stringWithFormat:@"%@%d", STORED_EMAIL_PREFIX, i];
            NSString * passwordIndex = [NSString stringWithFormat:@"%@%d", STORED_PASSWORD_PREFIX, i];
            NSString * urlIndex = [NSString stringWithFormat:@"%@%d", STORED_URL_PREFIX, i];
            NSString * notesIndex = [NSString stringWithFormat:@"%@%d", STORED_NOTES_PREFIX, index];
            
            //get values
            NSString * title = [[PDKeychainBindings sharedKeychainBindings] stringForKey:titleIndex];
            NSString * name = [[PDKeychainBindings sharedKeychainBindings] stringForKey:nameIndex];
            NSString * password = [[PDKeychainBindings sharedKeychainBindings] stringForKey:passwordIndex];
            NSString * url = [[PDKeychainBindings sharedKeychainBindings] stringForKey:urlIndex];
            NSString * notes = [[PDKeychainBindings sharedKeychainBindings] stringForKey:notesIndex];
            
            //shift values down 1 index
            [[PDKeychainBindings sharedKeychainBindings] setString:title forKey:[NSString stringWithFormat:@"%@%d", STORED_TITLE_PREFIX, i-1]];
            [[PDKeychainBindings sharedKeychainBindings] setString:name forKey:[NSString stringWithFormat:@"%@%d", STORED_EMAIL_PREFIX, i-1]];
            [[PDKeychainBindings sharedKeychainBindings] setString:password forKey:[NSString stringWithFormat:@"%@%d", STORED_PASSWORD_PREFIX, i-1]];
            [[PDKeychainBindings sharedKeychainBindings] setString:url forKey:[NSString stringWithFormat:@"%@%d", STORED_URL_PREFIX, i-1]];
            [[PDKeychainBindings sharedKeychainBindings] setString:notes forKey:[NSString stringWithFormat:@"%@%d", STORED_NOTES_PREFIX, i-1]];
        }
    }
}

-(void)deleteKeychainPasswordAtIndex:(NSUInteger)i
{
    if (_accessGranted){
        NSString * titleIndex = [NSString stringWithFormat:@"%@%d", STORED_TITLE_PREFIX, i];
        NSString * nameIndex = [NSString stringWithFormat:@"%@%d", STORED_EMAIL_PREFIX, i];
        NSString * passwordIndex = [NSString stringWithFormat:@"%@%d", STORED_PASSWORD_PREFIX, i];
        NSString * urlIndex = [NSString stringWithFormat:@"%@%d", STORED_URL_PREFIX, i];
        NSString * notesIndex = [NSString stringWithFormat:@"%@%d", STORED_NOTES_PREFIX, i];
        [[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:titleIndex];
        [[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:nameIndex];
        [[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:passwordIndex];
        [[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:urlIndex];
        [[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:notesIndex];
    }
}

-(void)clearAllPasswordData
{
    NSInteger count = [[[PDKeychainBindings sharedKeychainBindings] stringForKey:STORED_TITLE_COUNT] integerValue];
    for (int i = 0; i < count; i++) {
        [self deleteKeychainPasswordAtIndex:i];
    }
    [[PDKeychainBindings sharedKeychainBindings] setString:@"0" forKey:STORED_TITLE_COUNT];
    [self removeMasterPassword];
    if (mutablePasswords){
        [mutablePasswords removeAllObjects];
    }
}

-(void)commitTotalToKeychain
{
    if (_accessGranted){
        NSString * totalString = [NSString stringWithFormat:@"%d", mutablePasswords.count];
        [[PDKeychainBindings sharedKeychainBindings] setString:totalString forKey:STORED_TITLE_COUNT];
    }
}

@end

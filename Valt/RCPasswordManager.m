//
//  RCPasswordManager.m
//  Valt
//
//  Created by Rob Caraway on 12/10/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#define MASTER_PASSWORD_KEY @"kMasterPasswordKey"
#define ACCOUNT_LOGIN_KEY @"ACCOUNT_LOGIN_KEY"
#define ACCOUNT_PASSWORD_KEY @"ACCOUNT_PASSWORD_KEY"

#import "RCPasswordManager.h"
#import "PDKeychainBindings.h"
#import "RCNetworking.h"

#import "NSString+Encryption.h"

#import <Parse/Parse.h>

#define MASTER_PASSWORD_ACCESS @"AbVxHzKQHdLmBsVVJb6yk3Pq" //WARNING: DO NOT CHANGE EVER

#define STORED_TITLE_COUNT @"STORED_TITLE_COUNT"
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

static RCPasswordManager * manager;


#pragma mark - C functions

typedef struct {
    char * title;
    char * password;
    char * email;
    char * url;
    char * notes;
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
    keychainSet.title = titleKey(charIndex);
    keychainSet.email = emailKey(charIndex);
    keychainSet.password = passwordKey(charIndex);
    keychainSet.url = urlKey(charIndex);
    keychainSet.notes = notesKey(charIndex);
    return keychainSet;
}

static inline __attribute__ ((always_inline)) RCPassword * keychainPassword(int index)
{
    KeychainKeySet keychainSet = keyChainKeys(index);
    RCPassword * password = [[RCPassword  alloc] init];
    password.title = [[PDKeychainBindings sharedKeychainBindings] stringForKey:[NSString stringWithCString:keychainSet.title encoding:[NSString defaultCStringEncoding]]];
    password.username = [[PDKeychainBindings sharedKeychainBindings] stringForKey:[NSString stringWithCString:keychainSet.email encoding:[NSString defaultCStringEncoding]]] ;
    password.password = [[PDKeychainBindings sharedKeychainBindings] stringForKey:[NSString stringWithCString:keychainSet.password encoding:[NSString defaultCStringEncoding]]];
    password.urlName = [[PDKeychainBindings sharedKeychainBindings] stringForKey:[NSString stringWithCString:keychainSet.url encoding:[NSString defaultCStringEncoding]]];
    password.notes = [[PDKeychainBindings sharedKeychainBindings] stringForKey:[NSString stringWithCString:keychainSet.notes encoding:[NSString defaultCStringEncoding]]];
    return password;
}

static inline __attribute__ ((always_inline)) void setKeychainPassword(RCPassword * password, int index)
{
    KeychainKeySet keyset = keyChainKeys(index);
    [[PDKeychainBindings sharedKeychainBindings] setString:password.title forKey:[NSString stringWithCString:keyset.title encoding:[NSString defaultCStringEncoding]]];
    [[PDKeychainBindings sharedKeychainBindings] setString:password.username forKey:[NSString stringWithCString:keyset.email encoding:[NSString defaultCStringEncoding]]];
    [[PDKeychainBindings sharedKeychainBindings] setString:password.password forKey:[NSString stringWithCString:keyset.password encoding:[NSString defaultCStringEncoding]]];
    [[PDKeychainBindings sharedKeychainBindings] setString:password.urlName forKey:[NSString stringWithCString:keyset.url encoding:[NSString defaultCStringEncoding]]];
    [[PDKeychainBindings sharedKeychainBindings] setString:password.notes forKey:[NSString stringWithCString:keyset.notes encoding:[NSString defaultCStringEncoding]]];
}

static inline __attribute__ ((always_inline)) void deleteKeychainPassword(int index)
{
    KeychainKeySet keyset = keyChainKeys(index);
    [[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:[NSString stringWithCString:keyset.title encoding:[NSString defaultCStringEncoding]]];
    [[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:[NSString stringWithCString:keyset.email encoding:[NSString defaultCStringEncoding]]];
    [[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:[NSString stringWithCString:keyset.password encoding:[NSString defaultCStringEncoding]]];
    [[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:[NSString stringWithCString:keyset.url encoding:[NSString defaultCStringEncoding]]];
    [[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:[NSString stringWithCString:keyset.notes encoding:[NSString defaultCStringEncoding]]];
}

static inline __attribute__ ((always_inline)) void setKeychainTotal(int index)
{
    NSString * totalString = [NSString stringWithFormat:@"%d", index];
    [[PDKeychainBindings sharedKeychainBindings] setString:totalString forKey:STORED_TITLE_COUNT];
}

static inline __attribute__ ((always_inline)) NSMutableArray * allKeychainPasswords()
{
    NSInteger count = [[[PDKeychainBindings sharedKeychainBindings] stringForKey:STORED_TITLE_COUNT] integerValue];
    NSMutableArray * passwords = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++) {
        RCPassword * rcPassword = keychainPassword(i);
        [passwords addObject:rcPassword];
    }
    return passwords;
}

static inline __attribute__ ((always_inline)) void saveKeychainPasswords(NSArray * passwords)
{
    NSMutableArray * mutableCopy = [passwords mutableCopy];
    for (RCPassword * password in mutableCopy) {
        NSInteger index = [passwords indexOfObject:password];
        setKeychainPassword(password, (int)index);
    }
}

static inline __attribute__ ((always_inline)) void updateKeychain(RCPassword * password, NSInteger index)
{
    if (password){
        if (index != NSNotFound)
        setKeychainPassword(password, (int)index);
    }
}


@interface RCPasswordManager ()

@property(nonatomic, copy) NSString * currentPassword;
@property(atomic, assign) BOOL accessGranted;

@end

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
#ifdef NEW_USER_MODE
        [self clearAllPasswordData];
        [self removeLoginInfo];
#endif
#ifdef LOGGED_OUT_MODE
        [self removeLoginInfo];
#endif
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin:) name:networkingDidLogin object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin:) name:networkingDidSignup object:nil];
    }
    return self;
}

-(void)didLogin:(NSNotification *)notification
{
    NSString * string = [PFUser currentUser].username;
    NSString * password = notification.object;
    [[PDKeychainBindings sharedKeychainBindings] setString:string forKey:ACCOUNT_LOGIN_KEY];
    [[PDKeychainBindings sharedKeychainBindings] setString:password forKey:ACCOUNT_PASSWORD_KEY];
}

-(BOOL)canLogin
{
    return [[PDKeychainBindings sharedKeychainBindings] stringForKey:ACCOUNT_LOGIN_KEY].length > 0
    && [[PDKeychainBindings sharedKeychainBindings] stringForKey:ACCOUNT_PASSWORD_KEY].length > 0;
}

-(void)removeLoginInfo
{
    [[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:ACCOUNT_LOGIN_KEY];
    [[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:ACCOUNT_PASSWORD_KEY];
}

#pragma mark - Accessing / Master Password

-(void)setMasterPassword:(NSString *)masterPassword
{
    NSString * mPw = [[PDKeychainBindings sharedKeychainBindings] stringForKey:MASTER_PASSWORD_KEY];
    if (!mPw || mPw.length == 0 || self.accessGranted){
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
    if (self.accessGranted){
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
                self.accessGranted = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:passwordManagerAccessGranted object:nil];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.accessGranted = NO;
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

-(void)hideAllPasswordData
{
    mutablePasswords = nil;
}

-(void)reshowPasswordData
{
    if ([self anyLoginsExist]){
        mutablePasswords = allKeychainPasswords();
    }else
        mutablePasswords = [NSMutableArray new];
}


#pragma mark - Password Mutation Editing

-(void)addPassword:(RCPassword *)password
{
    if (password && self.accessGranted){
        [mutablePasswords addObject:password];
        dispatch_async(keyChainQueue, ^{
            [self addNewPasswordToKeychain:password]; //correct, should just add to end, +1 to total
            setKeychainTotal((int)mutablePasswords.count);
        });
    }
}

-(void)addPasswords:(NSArray *)passwords
{
    if (passwords && self.accessGranted){
        NSMutableArray * mutPasswords = [passwords mutableCopy];
        for (RCPassword * password in passwords) {
            for (RCPassword * ogPassword in mutablePasswords) {
                if ([password isEqual:ogPassword]){
                    [mutPasswords removeObject:password];
                }
            }
        }
        [mutablePasswords addObjectsFromArray:mutPasswords];
#ifdef TESTING_MODE
        [self addNewPasswordsToKeychain:mutPasswords];
        setKeychainTotal((int)mutablePasswords.count);
#else
        dispatch_async(keyChainQueue, ^{
            [self addNewPasswordsToKeychain:mutPasswords];
            setKeychainTotal((int)mutablePasswords.count);
        });
#endif
    }
}

-(void)replaceAllPasswordsWithPasswords:(NSArray *)passwords
{
    if (passwords && self.accessGranted){
        [mutablePasswords removeAllObjects];
        [mutablePasswords addObjectsFromArray:passwords];
#ifdef TESTING_MODE
        [self replaceKeychainPasswordsWith:passwords];
        setKeychainTotal((int)mutablePasswords.count);
#else
        dispatch_async(keyChainQueue, ^{
            [self replaceKeychainPasswordsWith:passwords];
           setKeychainTotal((int)mutablePasswords.count);
        });
#endif
    }
}

-(void)removePassword:(RCPassword *)password
{
    if (password && self.accessGranted){
        NSUInteger index = [mutablePasswords indexOfObject:password];
        [mutablePasswords removeObject:password];
#ifdef TESTING_MODE
        if (index == mutablePasswords.count)
            deleteKeychainPassword((int)index);
        else if (index != NSNotFound){
            [self decrementKeychainValuesStartingAtIndex:index];
        }
        setKeychainTotal((int)mutablePasswords.count);
#else
        dispatch_async(keyChainQueue, ^{
            if (index == mutablePasswords.count)
                deleteKeychainPassword((int)index);
            else if (index != NSNotFound){
                [self decrementKeychainValuesStartingAtIndex:index];
            }
            setKeychainTotal((int)mutablePasswords.count);
        });
#endif
    }
}

-(void)removePasswordAtIndex:(NSInteger)index
{
    if (mutablePasswords.count > index && self.accessGranted){
        [mutablePasswords removeObjectAtIndex:index];
#ifdef TESTING_MODE
        if (index == mutablePasswords.count)
                deleteKeychainPassword((int)index);
        else{
            [self decrementKeychainValuesStartingAtIndex:index];
        }
        setKeychainTotal((int)mutablePasswords.count);
#else
        dispatch_async(keyChainQueue, ^{
            if (index == mutablePasswords.count)
                deleteKeychainPassword((int)index);
            else{
                [self decrementKeychainValuesStartingAtIndex:index];
            }
            setKeychainTotal((int)mutablePasswords.count);
        });
#endif
    }
}

-(void)addPassword:(RCPassword *)password atIndex:(NSInteger)index
{
    if (password && self.accessGranted){
        if (index == mutablePasswords.count){
            [mutablePasswords addObject:password];
#ifdef TESTING_MODE
            [self addNewPasswordToKeychain:password];
            setKeychainTotal((int)mutablePasswords.count);
#else
            dispatch_async(keyChainQueue, ^{
                [self addNewPasswordToKeychain:password];
                setKeychainTotal((int)mutablePasswords.count);
            });
#endif
        }
        else if (index < mutablePasswords.count && index >= 0){
            [mutablePasswords insertObject:password atIndex:index];
#ifdef TESTING_MODE
            [self incrementKeychainValuesStartingAtIndex:index];
            setKeychainPassword(password, (int)index);
            setKeychainTotal((int)mutablePasswords.count);
#else
            dispatch_async(keyChainQueue, ^{
                [self incrementKeychainValuesStartingAtIndex:index];
                setKeychainPassword(password, (int)index);
                setKeychainTotal((int)mutablePasswords.count);
            });
#endif
        }
    }
}

-(void)movePasswordAtIndex:(NSInteger)passwordIndex toNewIndex:(NSInteger)newIndex
{
    if (self.accessGranted && passwordIndex != newIndex && newIndex < mutablePasswords.count){
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
    if (password && self.accessGranted){
#ifdef TESTING_MODE
        updateKeychain(password, (int)([mutablePasswords indexOfObject:password]));
#else
        dispatch_async(keyChainQueue, ^{
            updateKeychain(password, (int)[mutablePasswords indexOfObject:password]);
        });
#endif
    }
}


#pragma mark - Properties Accessors

-(NSArray *)passwords
{
    if (self.accessGranted && mutablePasswords)
        return [NSArray arrayWithArray:mutablePasswords];
    return nil;
}

-(NSArray *)allTitles
{
    if (self.accessGranted){
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
    if (self.accessGranted){
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
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    });
}

-(void)lockPasswords
{
    self.currentPassword = nil;
    self.accessGranted = NO;
    mutablePasswords = nil;
}

-(void)grantPasswordAccess
{
    self.accessGranted = YES;
    if ([self anyLoginsExist]){
        mutablePasswords = allKeychainPasswords();
    }else
        mutablePasswords = [NSMutableArray new];
}

-(void)didDenyAccess:(NSString *)message
{
    [[NSNotificationCenter defaultCenter] postNotificationName:passwordManagerAccessDenied object:message];
}


-(NSString *)accountLogin
{
    if (self.accessGranted){
         return [[PDKeychainBindings sharedKeychainBindings] stringForKey:ACCOUNT_LOGIN_KEY];
    }
    return nil;
}

-(NSString *)accountPassword
{
    if (self.accessGranted){
        return [[PDKeychainBindings sharedKeychainBindings] stringForKey:ACCOUNT_PASSWORD_KEY];
    }
    return nil;
}

#pragma mark - Keychain


-(void)addNewPasswordToKeychain:(RCPassword *)password
{
    if (self.accessGranted && password){
        NSInteger index = mutablePasswords.count-1;
        setKeychainPassword(password, (int)index);
    }
}

-(void)addNewPasswordsToKeychain:(NSArray *)passwords
{
    if (self.accessGranted && passwords){
        NSUInteger startIndex = mutablePasswords.count-passwords.count;
        for (RCPassword * password in passwords) {
            setKeychainPassword(password, (int)startIndex);
            startIndex++;
        }
    }
}

-(void)replaceKeychainPasswordsWith:(NSArray *)passwords
{
    if (self.accessGranted){
        NSUInteger keyChainCount = [[[PDKeychainBindings sharedKeychainBindings] stringForKey:STORED_TITLE_COUNT] integerValue];
        NSUInteger count = (passwords.count >= keyChainCount)?passwords.count:keyChainCount;
        for (int i = 0; i < count; i++) {
            if (i < passwords.count){
                RCPassword * password = passwords[i];
                setKeychainPassword(password, i);
            }else{
                deleteKeychainPassword(i);
            }
        }
    }
}

-(void)moveKeychainPasswordAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    if (self.accessGranted){
        RCPassword * password = keychainPassword((int)fromIndex);
        if (fromIndex == mutablePasswords.count){
            deleteKeychainPassword((int)fromIndex);
        }else{
            [self decrementKeychainValuesStartingAtIndex:fromIndex];
        }
        [self incrementKeychainValuesStartingAtIndex:toIndex];
        setKeychainPassword(password, (int)toIndex);
    }
}

-(void)incrementKeychainValuesStartingAtIndex:(NSInteger)index
{
    if (self.accessGranted){
        NSInteger i = [[[PDKeychainBindings sharedKeychainBindings] stringForKey:STORED_TITLE_COUNT] integerValue]-1;
        while (i >= index) {
            RCPassword * password = keychainPassword((int)i);
            setKeychainPassword(password, (int)i+1);
            --i;
        }
    }
}

-(void)decrementKeychainValuesStartingAtIndex:(NSUInteger)index
{
    if (self.accessGranted){
        NSInteger startIndex = index+1;
        NSInteger keychainCount = [[[PDKeychainBindings sharedKeychainBindings] stringForKey:STORED_TITLE_COUNT] integerValue];
        for (int i = startIndex; i < keychainCount; i++) {
            RCPassword * password = keychainPassword(i);
            setKeychainPassword(password, (int)i-1);
        }
    }
}

-(void)clearAllPasswordData
{
    NSInteger count = [[[PDKeychainBindings sharedKeychainBindings] stringForKey:STORED_TITLE_COUNT] integerValue];
    for (int i = 0; i < count; i++) {
        deleteKeychainPassword(i);
    }
    [[PDKeychainBindings sharedKeychainBindings] setString:@"0" forKey:STORED_TITLE_COUNT];
    [self removeMasterPassword];
    if (mutablePasswords){
        [mutablePasswords removeAllObjects];
    }
}

@end

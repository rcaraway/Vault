//
//  RCPasswordManager.h
//  Valt
//
//  Created by Rob Caraway on 12/10/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCPassword.h"


@interface RCPasswordManager : NSObject

@property(nonatomic, strong,readonly) NSArray * passwords;
@property(nonatomic, copy, readonly) NSString * accountLogin;
@property(nonatomic, copy ,readonly) NSString * accountPassword;
@property(nonatomic, copy, readonly) NSString * secureNotes;

@property (atomic, readonly) BOOL accessGranted;
@property (nonatomic, readonly) BOOL canLogin;


-(NSArray *)allTitles;
-(void)clearAllPasswordData;
-(void)addPassword:(RCPassword *)password;
-(void)addPassword:(RCPassword *)password atIndex:(NSInteger)index;
-(void)addPasswords:(NSArray *)passwords;
-(void)replaceAllPasswordsWithPasswords:(NSArray *)passwords;
-(void)removePassword:(RCPassword *)password;
-(void)removePasswordAtIndex:(NSInteger )index;
-(void)movePasswordAtIndex:(NSInteger)passwordIndex toNewIndex:(NSInteger)newIndex;
-(void)updatePassword:(RCPassword *)password;
-(void)saveSecureNotes:(NSString *)notes;
-(RCPassword *)passwordForTitle:(NSString *)title;

-(void)hideAllPasswordData;
-(void)reshowPasswordData;

-(void)attemptToUnlockWithCodeInBackground:(NSString *)password;
-(void)attemptToUnlockWithCode:(NSString *)password;
-(void)setMasterPassword:(NSString *)masterPassword;
-(NSString *)masterPassword;
-(BOOL)masterPasswordExists;

-(void)lockPasswords;
-(void)lockPasswordsCompletion:(void(^)())completion;

+(RCPasswordManager *)defaultManager;

@end

extern NSString * const passwordManagerDidCreateMasterPassword;
extern NSString * const passwordManagerDidChangeMasterPassword;
extern NSString * const passwordManagerAccessGranted;
extern NSString * const passwordManagerAccessFailedToGrant;
extern NSString * const passwordManagerAccessDenied;
extern NSString * const passwordManagerDidLock;
extern NSString * const passwordManagerDidFailToChangeMasterPassword;
extern NSString * const passwordManagerDidSaveNotes;


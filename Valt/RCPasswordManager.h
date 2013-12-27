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
@property(nonatomic, copy) NSString * accountEmail;

-(NSArray *)allTitles;

-(void)clearAllPasswordData;
-(void)addPassword:(RCPassword *)password;
-(void)addPassword:(RCPassword *)password atIndex:(NSInteger)index;
-(void)addPasswords:(NSArray *)passwords;
-(void)replaceAllPasswordsWithPasswords:(NSArray *)passwords;
-(void)removePassword:(RCPassword *)password;
-(void)removePasswordAtIndex:(NSInteger )index;
-(void)movePasswordAtIndex:(NSInteger)passwordIndex toNewIndex:(NSInteger)newIndex;
-(void)commitPasswordToKeyChain:(RCPassword *)password;
-(void)saveAllToKeychain;

-(RCPassword *)passwordForTitle:(NSString *)title;

-(void)setMasterPassword:(NSString *)masterPassword;
-(NSString *)masterPassword;

-(BOOL)masterPasswordExists;

-(void)lockPasswords;
-(void)grantPasswordAccess:(void(^)())completion; //asynchronous
-(void)grantPasswordAccess;

+(RCPasswordManager *)defaultManager;

@end


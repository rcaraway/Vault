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

-(NSArray *)allTitles;

-(void)addPassword:(RCPassword *)password;
-(void)addPassword:(RCPassword *)password atIndex:(NSInteger)index;
-(void)removePassword:(RCPassword *)password;
-(void)removePasswordAtIndex:(NSInteger )index;
-(void)movePasswordAtIndex:(NSInteger)passwordIndex toNewIndex:(NSInteger)newIndex;

-(void)setMasterPassword:(NSString *)masterPassword;
-(NSString *)masterPassword;
-(BOOL)masterPasswordExists;

+(RCPasswordManager *)defaultManager;

@end

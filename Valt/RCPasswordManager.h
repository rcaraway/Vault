//
//  RCPasswordManager.h
//  Valt
//
//  Created by Rob Caraway on 12/10/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCPasswordManager : NSObject

@property(nonatomic, strong) NSArray * passwordTitleList;

-(NSArray *)dataForTitle:(NSString *)title;
-(void)setMasterPassword:(NSString *)masterPassword;
-(NSString *)masterPassword;
-(BOOL)masterPasswordExists;

+(RCPasswordManager *)defaultManager;

@end

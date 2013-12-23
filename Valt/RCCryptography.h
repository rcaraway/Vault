//
//  RCCryptography.h
//  Valt
//
//  Created by Robert Caraway on 12/23/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RCPassword;

RCPassword *  encryptPassword(RCPassword * password);
RCPassword * decryptPassword(RCPassword * password);
NSString * encryptString(NSString * string);
NSString * decryptString(NSString * string);

@interface RCCryptography : NSObject
@end


//
//  NSString+Encryption.h
//  Valt
//
//  Created by Rob Caraway on 12/23/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Encryption)

-(NSString *)stringByDecryptingWithKey:(NSString *)key;
-(NSString *)stringByEncryptingWithKey:(NSString *)key;


+(NSString *)randomString;

@end

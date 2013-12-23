//
//  NSString+Encryption.m
//  Valt
//
//  Created by Rob Caraway on 12/23/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "NSString+Encryption.h"
#import "RNEncryptor.h"
#import "RNDecryptor.h"
#import "NSData+Base64.h"

@implementation NSString (Encryption)


-(NSString *)stringByEncryptingWithKey:(NSString *)key
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSData *encryptedData = [RNEncryptor encryptData:data
                                        withSettings:kRNCryptorAES256Settings
                                            password:key
                                               error:&error];
    NSString * string = [encryptedData base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength];
    return string;
}

-(NSString *)stringByDecryptingWithKey:(NSString *)key
{
    NSData * encryptedData = [NSData dataFromBase64String:self];
    NSError *error;
    NSData *decryptedData = [RNDecryptor decryptData:encryptedData
                                        withPassword:key
                                               error:&error];
    NSString * string = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
    return string;
}

-(NSData *)base64DecodedData
{
    return [self dataUsingEncoding:NSDataBase64Encoding76CharacterLineLength];
}



@end

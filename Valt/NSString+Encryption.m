//
//  NSString+Encryption.m
//  Valt
//
//  Created by Rob Caraway on 12/23/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "NSString+Encryption.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation NSString (Encryption)


-(NSString *)stringByEncryptingWithKey:(NSString *)key
{
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char * keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
    bzero( keyPtr, sizeof(keyPtr) ); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString: keyPtr maxLength: sizeof(keyPtr) encoding: NSUTF8StringEncoding];
    
    // encrypts in-place, since this is a mutable data object
    size_t numBytesEncrypted = 0;
    NSMutableData * stringData = [[self dataUsingEncoding:[NSString defaultCStringEncoding]] mutableCopy];
    CCCryptorStatus result = CCCrypt( kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                     keyPtr, kCCKeySizeAES256,
                                     NULL /* initialization vector (optional) */,
                                     [stringData mutableBytes], [stringData length], /* input */
                                     [stringData mutableBytes], [stringData length], /* output */
                                     &numBytesEncrypted );
    
    if (result == kCCSuccess){
        NSString * final = [[NSString  alloc] initWithData:stringData encoding:[NSString defaultCStringEncoding]];
        NSLog(@"ENCRYPTED %@", final);
        return final;
    }
    return nil;
}

-(NSString *)stringByDecryptingWithKey:(NSString *)key
{
    
}

@end

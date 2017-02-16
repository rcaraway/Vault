//
//  RCPassword.m
//  Valt
//
//  Created by Rob Caraway on 12/10/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCPassword.h"
#import "RCPasswordManager.h"

#import "NSString+Encryption.h"


NSString * const passwordDidGrabWebColor = @"passwordDidGrabWebColor";

@interface RCPassword ()

@end



@implementation RCPassword


-(id)init
{
    self = super.init;
    if (self){
        self.notes = @"";
        self.title = @"";
        self.username = @"";
        self.password = @"";
        self.urlName = @"";
    }
    return self;
}

-(NSArray *)allFields
{
    NSMutableArray * allFields = [NSMutableArray new];
    if (self.title){
        [allFields addObject:self.title];
    }
    if (self.username){
        [allFields addObject:self.username];
    }
    if (self.password){
        [allFields addObject:self.password];
    }
    if (self.urlName){
        [allFields addObject:self.urlName];
    }
    if (self.notes){
        [allFields addObject:self.notes];
    }
    return allFields;
}

-(void)encrypt
{
    self.username = [self.username stringByEncryptingWithKey:[[RCPasswordManager defaultManager] masterPassword]];
    self.password = [self.password stringByEncryptingWithKey:[[RCPasswordManager defaultManager] masterPassword]];
    self.notes = [self.notes stringByEncryptingWithKey:[[RCPasswordManager defaultManager] masterPassword]];
}

-(void)decrypt
{
    self.username = [self.username stringByDecryptingWithKey:[[RCPasswordManager defaultManager] masterPassword]];
    self.password = [self.password stringByDecryptingWithKey:[[RCPasswordManager defaultManager] masterPassword]];
    self.notes = [self.notes stringByDecryptingWithKey:[[RCPasswordManager defaultManager] masterPassword]];
}

-(RCPassword * )encryptedCopy
{
    RCPassword * password = [self copy];
    password.username = [password.username stringByEncryptingWithKey:[[RCPasswordManager defaultManager] masterPassword]];
    password.password = [password.password stringByEncryptingWithKey:[[RCPasswordManager defaultManager] masterPassword]];
    password.notes = [password.notes stringByEncryptingWithKey:[[RCPasswordManager defaultManager] masterPassword]];
    return password;
}

-(RCPassword *)decryptedCopy
{
    RCPassword * password = [self copy];
    password.username = [password.username stringByDecryptingWithKey:[[RCPasswordManager defaultManager] masterPassword]];
    password.password = [password.password stringByDecryptingWithKey:[[RCPasswordManager defaultManager] masterPassword]];
    password.notes = [password.notes stringByDecryptingWithKey:[[RCPasswordManager defaultManager] masterPassword]];
    return password;
}

-(BOOL)isEmpty
{
    BOOL usernameEmpty = (!self.username || self.username.length ==0);
    BOOL titleEmpty = (!self.title || self.title.length == 0);
    BOOL passwordEmpty = (!self.password || self.password.length == 0);
    BOOL urlEmpty = (!self.urlName || self.urlName.length == 0);
    BOOL notesEmpty = (!self.notes || self.notes.length == 0);
    return (usernameEmpty && titleEmpty && urlEmpty && passwordEmpty && notesEmpty);
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"Password: Title %@, Login Name %@, Password %@, URL %@, Notes %@", self.title, self.username, self.password, self.urlName, self.notes];
}

-(BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[RCPassword class]]){
        return NO;
    }
    RCPassword * password = object;
    if (password == self)return YES;
    if ([self.title isEqualToString:password.title] &&
        [self.username isEqualToString:password.username] &&
        [self.password isEqualToString:password.password] &&
        [self.urlName isEqualToString:password.urlName])
        return YES;
    return NO;
}

-(BOOL)hasValidURL
{
    NSURL * url = [NSURL URLWithString:self.urlName];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    if ([NSURLConnection canHandleRequest:request]){
        return YES;
    }
    return NO;
}




-(UIImage *)faviconImage
{
    NSString * faviconURL = [self favIconFromUrl];
    if (faviconURL){
        NSURL * url = [NSURL URLWithString:faviconURL];
        NSData * imageData = [NSData dataWithContentsOfURL:url];
        UIImage * favicon = [UIImage imageWithData:imageData];
        return favicon;
    }
    return nil;
}

-(NSString*)favIconFromUrl
{
    NSURL * url = [NSURL URLWithString:self.urlName];
    NSString * faviconPath = [NSString stringWithFormat:@"http://www.google.com/s2/favicons?domain=%@://%@", [url scheme], [url host]];
	return faviconPath;
}

@end

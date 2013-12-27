//
//  RCPassword.m
//  Valt
//
//  Created by Rob Caraway on 12/10/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCPassword.h"
#import "RCPasswordManager.h"
#import <Parse/Parse.h>
#import "NSString+Encryption.h"
#import <objc/runtime.h>

@interface RCPassword ()

@property(nonatomic, strong) PFObject * object;

@end

@implementation RCPassword



-(PFObject *)convertedObject
{
    if (self.object){
        NSInteger index = [[[RCPasswordManager defaultManager] passwords] indexOfObject:self];
        if (index == NSNotFound){
            return nil;
        }
        [self.object setObject:[NSNumber numberWithInt:index] forKey:PASSWORD_INDEX];
        return self.object;
    }
    
    if ([PFUser currentUser]){
        NSInteger index = [[[RCPasswordManager defaultManager] passwords] indexOfObject:self];
        if (index == NSNotFound){
            return nil;
        }
        PFObject * pfObject = [PFObject objectWithClassName:PASSWORD_CLASS];
        NSString * ownerId = [PFUser currentUser].objectId;
        [pfObject setObject:ownerId forKey:PASSWORD_OWNER];
        [pfObject setObject:[NSNumber numberWithInt:index] forKey:PASSWORD_INDEX];
        [pfObject setObject:self.title forKey:PASSWORD_TITLE];
        [pfObject setObject:self.username forKey:PASSWORD_USERNAME];
        [pfObject setObject:self.password forKey:PASSWORD_PASSWORD];
        [pfObject setObject:self.urlName forKey:PASSWORD_URLNAME];
        [pfObject setObject:self.extraFields forKey:PASSWORD_EXTRA_FRIELDS];
        return pfObject;
    }
    return nil;
}

+(RCPassword *)passwordFromPFObject:(PFObject *)object
{
    RCPassword * password = [[RCPassword alloc] init];
    password.title = [object objectForKey:PASSWORD_TITLE];
    password.password = [object objectForKey:PASSWORD_PASSWORD];
    password.urlName = [object objectForKey:PASSWORD_URLNAME];
    password.username = [object objectForKey:PASSWORD_USERNAME];
    password.extraFields = [object objectForKey:PASSWORD_EXTRA_FRIELDS];
    password.object = object;
    return password;
}

-(id)init
{
    self = super.init;
    if (self){
        self.extraFields = NSMutableArray.new;
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
    if (self.extraFields && self.extraFields.count > 0){
        [allFields addObjectsFromArray:self.extraFields];
    }
    return allFields;
}

-(void)encrypt
{
    self.username = [self.username stringByEncryptingWithKey:[[RCPasswordManager defaultManager] masterPassword]];
    self.password = [self.password stringByEncryptingWithKey:[[RCPasswordManager defaultManager] masterPassword]];
    if (self.extraFields.count > 0){
        self.extraFields[0] = [self.extraFields[0] stringByEncryptingWithKey:[[RCPasswordManager defaultManager] masterPassword]];
        if (self.extraFields.count > 1){
            self.extraFields[1] = [self.extraFields[1] stringByEncryptingWithKey:[[RCPasswordManager defaultManager] masterPassword]];
        }
    }
}

-(void)decrypt
{
    self.username = [self.username stringByDecryptingWithKey:[[RCPasswordManager defaultManager] masterPassword]];
    self.password = [self.password stringByDecryptingWithKey:[[RCPasswordManager defaultManager] masterPassword]];
    if (self.extraFields.count > 0){
        self.extraFields[0] = [self.extraFields[0] stringByDecryptingWithKey:[[RCPasswordManager defaultManager] masterPassword]];
        if (self.extraFields.count > 1){
            self.extraFields[1] = [self.extraFields[1] stringByDecryptingWithKey:[[RCPasswordManager defaultManager] masterPassword]];
        }
    }
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"Password: Title %@, Login Name %@, Password %@, URL %@, Extra Fields %@", self.title, self.username, self.password, self.urlName, self.extraFields];
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

@end

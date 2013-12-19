//
//  RCPassword.m
//  Valt
//
//  Created by Rob Caraway on 12/10/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCPassword.h"

@implementation RCPassword

+(BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    return YES;
}

-(id)init
{
    self = super.init;
    if (self){
        self.extraFields = [NSMutableArray new];
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

//
//  RCPassword.m
//  Valt
//
//  Created by Rob Caraway on 12/10/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCPassword.h"

@implementation RCPassword

-(id)init
{
    self = super.init;
    if (self){
        self.extraFields = [NSMutableArray new];
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
    if (self.extraFields && self.extraFields.count > 0){
        [allFields addObjectsFromArray:self.extraFields];
    }
    return allFields;
}

@end

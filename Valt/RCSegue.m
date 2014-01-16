//
//  RCSegue.m
//  Valt
//
//  Created by Rob Caraway on 1/16/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCSegue.h"


@implementation RCSegue

-(id)initWithRootController:(RCRootViewController *)root
{
    self = super.init;
    if (self){
        self.rootVC = root;
    }
    return self;
}

-(id)init
{
    return nil;
}

@end

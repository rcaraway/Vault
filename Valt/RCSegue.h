//
//  RCSegue.h
//  Valt
//
//  Created by Rob Caraway on 1/16/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RCRootViewController;

@interface RCSegue : NSObject

@property(nonatomic, weak) RCRootViewController * rootVC;

-(id)initWithRootController:(RCRootViewController *)root;

@end

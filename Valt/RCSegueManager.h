//
//  RCSegueManager.h
//  Valt
//
//  Created by Robert Caraway on 1/14/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCSegueManager : NSObject


-(void)transitionFromPasscodeToList;
-(void)transitionBackToPasscode;

+(RCSegueManager *)sharedManager;


@end

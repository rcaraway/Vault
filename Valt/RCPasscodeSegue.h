//
//  RCSegueManager.h
//  Valt
//
//  Created by Robert Caraway on 1/14/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCSegue.h"

@interface RCPasscodeSegue : RCSegue

-(void)segueToList;
-(void)returnToPasscodeFromSearch;
-(void)returnToPasscodeFromList;

@end

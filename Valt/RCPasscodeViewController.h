//
//  RCPasscodeViewController.h
//  Valt
//
//  Created by Rob Caraway on 12/10/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCViewController.h"

@class RCValtView;

@interface RCPasscodeViewController : RCViewController

@property(nonatomic, strong) UIView * fieldBackView;
@property(nonatomic, strong) RCValtView * valtView;
@property(nonatomic, strong) UITextField * passwordField;

@property (nonatomic) BOOL opened;

-(void)freeAllMemory;

-(id)initWithNewUser:(BOOL)newUser;

@end

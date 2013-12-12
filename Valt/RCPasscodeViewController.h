//
//  RCPasscodeViewController.h
//  Valt
//
//  Created by Rob Caraway on 12/10/13.
//  Copyright (c) 2013 Rob Caraway. All rights reserved.
//

#import "RCViewController.h"
@class SPLockScreen;


@interface RCPasscodeViewController : RCViewController

@property(nonatomic, strong) SPLockScreen * lockscreen;
@property(nonatomic, strong) UIImageView * imageView;
@property(nonatomic, strong) UITextField * numberField;
@property(nonatomic, strong) UITextField * confirmField;
@property(nonatomic, strong) UILabel * enterPassword;
@property(nonatomic, strong) UIButton * doneButton;

-(id)initWithNewUser:(BOOL)newUser;

@end
